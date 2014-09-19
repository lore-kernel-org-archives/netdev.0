From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] icmp: add a global rate limitation
Date: Fri, 19 Sep 2014 07:38:40 -0700
Message-ID: <1411137520.26859.13.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:49681 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753398AbaISOim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 10:38:42 -0400
Received: by mail-pd0-f181.google.com with SMTP id r10so66880pdi.12
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 07:38:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Current ICMP rate limiting uses inetpeer cache, which is an RBL tree
protected by a lock, meaning that hosts can be stuck hard if all cpus
want to check ICMP limits.

When say a DNS or NTP server process is restarted, inetpeer tree grows
quick and machine comes to its knees.

iptables can not help because the bottleneck happens before ICMP
messages are even cooked and sent.

This patch adds a new global limitation, using a token bucket filter,
controlled by two new sysctl :

icmp_msgs_per_sec - INTEGER
    Limit maximal number of ICMP packets sent per second from this host.
    Only messages whose type matches icmp_ratemask are
    controlled by this limit.
    Default: 1000

icmp_msgs_burst - INTEGER
    icmp_msgs_per_sec controls number of ICMP packets sent per second,
    while icmp_msgs_burst controls the burst size of these packets.
    Default: 50

Note that if we really want to send millions of ICMP messages per
second, we might extend idea and infra added in commit 04ca6973f7c1a
("ip: make IP identifiers less predictable") :
add a token bucket in the ip_idents hash and no longer rely on inetpeer.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 Documentation/networking/ip-sysctl.txt |   13 ++++
 include/net/ip.h                       |    4 +
 net/ipv4/icmp.c                        |   64 +++++++++++++++++++++--
 net/ipv4/sysctl_net_ipv4.c             |   16 +++++
 net/ipv6/icmp.c                        |   20 ++++---
 5 files changed, 105 insertions(+), 12 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 1b5581a30d77..c7a81ace35d0 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -769,8 +769,21 @@ icmp_ratelimit - INTEGER
 	icmp_ratemask (see below) to specific targets.
 	0 to disable any limiting,
 	otherwise the minimal space between responses in milliseconds.
+	Note that another sysctl, icmp_msgs_per_sec limits the number
+	of ICMP packets	sent on all targets.
 	Default: 1000
 
+icmp_msgs_per_sec - INTEGER
+	Limit maximal number of ICMP packets sent per second from this host.
+	Only messages whose type matches icmp_ratemask (see below) are
+	controlled by this limit.
+	Default: 1000
+
+icmp_msgs_burst - INTEGER
+	icmp_msgs_per_sec controls number of ICMP packets sent per second,
+	while icmp_msgs_burst controls the burst size of these packets.
+	Default: 50
+
 icmp_ratemask - INTEGER
 	Mask made of ICMP types for which rates are being limited.
 	Significant bits: IHGFEDCBA9876543210
diff --git a/include/net/ip.h b/include/net/ip.h
index 14bfc8e1bcf9..fcd9068fb8c3 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -548,6 +548,10 @@ void ip_icmp_error(struct sock *sk, struct sk_buff *skb, int err, __be16 port,
 void ip_local_error(struct sock *sk, int err, __be32 daddr, __be16 dport,
 		    u32 info);
 
+bool icmp_global_allow(void);
+extern int sysctl_icmp_msgs_per_sec;
+extern int sysctl_icmp_msgs_burst;
+
 #ifdef CONFIG_PROC_FS
 int ip_misc_proc_init(void);
 #endif
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index ea7d4afe8205..ba86c146a4ab 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -231,12 +231,62 @@ static inline void icmp_xmit_unlock(struct sock *sk)
 	spin_unlock_bh(&sk->sk_lock.slock);
 }
 
+int sysctl_icmp_msgs_per_sec __read_mostly = 1000;
+int sysctl_icmp_msgs_burst __read_mostly = 50;
+
+static struct {
+	spinlock_t	lock;
+	u32		credit;
+	u32		stamp;
+} icmp_global = {
+	.lock		= __SPIN_LOCK_UNLOCKED(icmp_global.lock),
+};
+
+/**
+ * icmp_global_allow - Are we allowed to send one more ICMP message ?
+ *
+ * Uses a token bucket to limit our ICMP messages to sysctl_icmp_msgs_per_sec.
+ * Returns false if we reached the limit and can not send another packet.
+ * Note: called with BH disabled
+ */
+bool icmp_global_allow(void)
+{
+	u32 credit, delta, incr = 0, now = (u32)jiffies;
+	bool rc = false;
+
+	/* Check if token bucket is empty and cannot be refilled
+	 * without taking the spinlock.
+	 */
+	if (!icmp_global.credit) {
+		delta = min_t(u32, now - icmp_global.stamp, HZ);
+		if (delta < HZ / 50)
+			return false;
+	}
+
+	spin_lock(&icmp_global.lock);
+	delta = min_t(u32, now - icmp_global.stamp, HZ);
+	if (delta >= HZ / 50) {
+		incr = sysctl_icmp_msgs_per_sec * delta / HZ ;
+		if (incr)
+			icmp_global.stamp = now;
+	}
+	credit = min_t(u32, icmp_global.credit + incr, sysctl_icmp_msgs_burst);
+	if (credit) {
+		credit--;
+		rc = true;
+	}
+	icmp_global.credit = credit;
+	spin_unlock(&icmp_global.lock);
+	return rc;
+}
+EXPORT_SYMBOL(icmp_global_allow);
+
 /*
  *	Send an ICMP frame.
  */
 
-static inline bool icmpv4_xrlim_allow(struct net *net, struct rtable *rt,
-				      struct flowi4 *fl4, int type, int code)
+static bool icmpv4_xrlim_allow(struct net *net, struct rtable *rt,
+			       struct flowi4 *fl4, int type, int code)
 {
 	struct dst_entry *dst = &rt->dst;
 	bool rc = true;
@@ -253,8 +303,14 @@ static inline bool icmpv4_xrlim_allow(struct net *net, struct rtable *rt,
 		goto out;
 
 	/* Limit if icmp type is enabled in ratemask. */
-	if ((1 << type) & net->ipv4.sysctl_icmp_ratemask) {
-		struct inet_peer *peer = inet_getpeer_v4(net->ipv4.peers, fl4->daddr, 1);
+	if (!((1 << type) & net->ipv4.sysctl_icmp_ratemask))
+		goto out;
+
+	rc = false;
+	if (icmp_global_allow()) {
+		struct inet_peer *peer;
+
+		peer = inet_getpeer_v4(net->ipv4.peers, fl4->daddr, 1);
 		rc = inet_peer_xrlim_allow(peer,
 					   net->ipv4.sysctl_icmp_ratelimit);
 		if (peer)
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 1599966f4639..8a25509c35b3 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -731,6 +731,22 @@ static struct ctl_table ipv4_table[] = {
 		.extra2		= &one,
 	},
 	{
+		.procname	= "icmp_msgs_per_sec",
+		.data		= &sysctl_icmp_msgs_per_sec,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+	},
+	{
+		.procname	= "icmp_msgs_burst",
+		.data		= &sysctl_icmp_msgs_burst,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+	},
+	{
 		.procname	= "udp_mem",
 		.data		= &sysctl_udp_mem,
 		.maxlen		= sizeof(sysctl_udp_mem),
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 394bb824fe4b..141e1f3ab74e 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -170,11 +170,11 @@ static bool is_ineligible(const struct sk_buff *skb)
 /*
  * Check the ICMP output rate limit
  */
-static inline bool icmpv6_xrlim_allow(struct sock *sk, u8 type,
-				      struct flowi6 *fl6)
+static bool icmpv6_xrlim_allow(struct sock *sk, u8 type,
+			       struct flowi6 *fl6)
 {
-	struct dst_entry *dst;
 	struct net *net = sock_net(sk);
+	struct dst_entry *dst;
 	bool res = false;
 
 	/* Informational messages are not limited. */
@@ -199,16 +199,20 @@ static inline bool icmpv6_xrlim_allow(struct sock *sk, u8 type,
 	} else {
 		struct rt6_info *rt = (struct rt6_info *)dst;
 		int tmo = net->ipv6.sysctl.icmpv6_time;
-		struct inet_peer *peer;
 
 		/* Give more bandwidth to wider prefixes. */
 		if (rt->rt6i_dst.plen < 128)
 			tmo >>= ((128 - rt->rt6i_dst.plen)>>5);
 
-		peer = inet_getpeer_v6(net->ipv6.peers, &rt->rt6i_dst.addr, 1);
-		res = inet_peer_xrlim_allow(peer, tmo);
-		if (peer)
-			inet_putpeer(peer);
+		if (icmp_global_allow()) {
+			struct inet_peer *peer;
+
+			peer = inet_getpeer_v6(net->ipv6.peers,
+					       &rt->rt6i_dst.addr, 1);
+			res = inet_peer_xrlim_allow(peer, tmo);
+			if (peer)
+				inet_putpeer(peer);
+		}
 	}
 	dst_release(dst);
 	return res;
