From: Florian Westphal <fw@strlen.de>
Subject: [PATCH] syncookies: remove last_synq_overflow from struct tcp_sock
Date: Sun, 19 Apr 2009 21:43:48 +0200
Message-ID: <1240170228-26241-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:41764 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754179AbZDSTmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Apr 2009 15:42:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

last_synq_overflow eats 4 or 8 bytes in struct tcp_sock, even
though it is only used when a listening sockets syn queue
is full.

We can (ab)use rx_opt.ts_recent_stamp to store the same information;
it is not used otherwise as long as a socket is in listen state.

Move linger2 around to avoid splitting struct mtu_probe
across cacheline boundary on 32 bit arches.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/tcp.h   |    4 +---
 include/net/tcp.h     |   13 +++++++++++++
 net/ipv4/syncookies.c |    5 ++---
 net/ipv6/syncookies.c |    4 ++--
 4 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 9d5078b..8afac76 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -377,7 +377,7 @@ struct tcp_sock {
 	unsigned int		keepalive_time;	  /* time before keep alive takes place */
 	unsigned int		keepalive_intvl;  /* time interval between keep alive probes */
 
-	unsigned long last_synq_overflow; 
+	int			linger2;
 
 /* Receiver side RTT estimation */
 	struct {
@@ -406,8 +406,6 @@ struct tcp_sock {
 /* TCP MD5 Signagure Option information */
 	struct tcp_md5sig_info	*md5sig_info;
 #endif
-
-	int			linger2;
 };
 
 static inline struct tcp_sock *tcp_sk(const struct sock *sk)
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 1b94b9b..b55b489 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -265,6 +265,19 @@ static inline int tcp_too_many_orphans(struct sock *sk, int num)
 		 atomic_read(&tcp_memory_allocated) > sysctl_tcp_mem[2]);
 }
 
+/* syncookies: remember time of last synqueue overflow */
+static inline void tcp_synq_overflow(struct sock *sk)
+{
+	tcp_sk(sk)->rx_opt.ts_recent_stamp = jiffies;
+}
+
+/* syncookies: no recent synqueue overflow on this listening socket? */
+static inline int tcp_synq_no_recent_overflow(const struct sock *sk)
+{
+	unsigned long last_overflow = tcp_sk(sk)->rx_opt.ts_recent_stamp;
+	return time_after(jiffies, last_overflow + TCP_TIMEOUT_INIT);
+}
+
 extern struct proto tcp_prot;
 
 #define TCP_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.tcp_statistics, field)
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index b35a950..cd2b97f 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -161,13 +161,12 @@ static __u16 const msstab[] = {
  */
 __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, __u16 *mssp)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
 	const struct iphdr *iph = ip_hdr(skb);
 	const struct tcphdr *th = tcp_hdr(skb);
 	int mssind;
 	const __u16 mss = *mssp;
 
-	tp->last_synq_overflow = jiffies;
+	tcp_synq_overflow(sk);
 
 	/* XXX sort msstab[] by probability?  Binary search? */
 	for (mssind = 0; mss > msstab[mssind + 1]; mssind++)
@@ -268,7 +267,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	if (!sysctl_tcp_syncookies || !th->ack)
 		goto out;
 
-	if (time_after(jiffies, tp->last_synq_overflow + TCP_TIMEOUT_INIT) ||
+	if (tcp_synq_no_recent_overflow(sk) ||
 	    (mss = cookie_check(skb, cookie)) == 0) {
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESFAILED);
 		goto out;
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 711175e..8c25139 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -131,7 +131,7 @@ __u32 cookie_v6_init_sequence(struct sock *sk, struct sk_buff *skb, __u16 *mssp)
 	int mssind;
 	const __u16 mss = *mssp;
 
-	tcp_sk(sk)->last_synq_overflow = jiffies;
+	tcp_synq_overflow(sk);
 
 	for (mssind = 0; mss > msstab[mssind + 1]; mssind++)
 		;
@@ -175,7 +175,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	if (!sysctl_tcp_syncookies || !th->ack)
 		goto out;
 
-	if (time_after(jiffies, tp->last_synq_overflow + TCP_TIMEOUT_INIT) ||
+	if (tcp_synq_no_recent_overflow(sk) ||
 		(mss = cookie_check(skb, cookie)) == 0) {
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESFAILED);
 		goto out;
-- 
1.6.0.6

