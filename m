From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] ipv6: add missing /proc/sys/net/ipv6/ping_group_range
Date: Sat,  8 Jun 2013 17:54:35 +0800
Message-ID: <1370685275-22059-1-git-send-email-amwang@redhat.com>
Cc: Lorenzo Colitti <lorenzo@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39287 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751503Ab3FHJzI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Jun 2013 05:55:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

commit 6d0bfe22611602f366 (net: ipv6: Add IPv6 support to the ping socket.)
adds IPv6 ping socket support, but forgot to create
/proc/sys/net/ipv6/ping_group_range, therefore it wrongly shares
/proc/sys/net/ipv4/ping_group_range with IPv4.

This patch adds the missing /proc/sys/net/ipv6/ping_group_range interface.

Cc: Lorenzo Colitti <lorenzo@google.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
 include/net/netns/ipv6.h   |    1 +
 include/net/ping.h         |    2 +-
 net/ipv4/ping.c            |    5 +--
 net/ipv6/ping.c            |   29 +++++++++++++++++-
 net/ipv6/sysctl_net_ipv6.c |   70 ++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 102 insertions(+), 5 deletions(-)

diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 005e2c2..ede6ffd 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -28,6 +28,7 @@ struct netns_sysctl_ipv6 {
 	int ip6_rt_mtu_expires;
 	int ip6_rt_min_advmss;
 	int icmpv6_time;
+	kgid_t ping_group_range[2];
 };
 
 struct netns_ipv6 {
diff --git a/include/net/ping.h b/include/net/ping.h
index 5db0224..3201acc 100644
--- a/include/net/ping.h
+++ b/include/net/ping.h
@@ -69,7 +69,6 @@ int  ping_get_port(struct sock *sk, unsigned short ident);
 void ping_hash(struct sock *sk);
 void ping_unhash(struct sock *sk);
 
-int  ping_init_sock(struct sock *sk);
 void ping_close(struct sock *sk, long timeout);
 int  ping_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len);
 void ping_err(struct sk_buff *skb, int offset, u32 info);
@@ -110,5 +109,6 @@ extern void ping_proc_exit(void);
 void __init ping_init(void);
 int  __init pingv6_init(void);
 void pingv6_exit(void);
+void inet6_get_ping_group_range(kgid_t *data, kgid_t *low, kgid_t *high);
 
 #endif /* _PING_H */
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 1f1b2dd..73c6482 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -245,7 +245,7 @@ static void inet_get_ping_group_range_net(struct net *net, kgid_t *low,
 }
 
 
-int ping_init_sock(struct sock *sk)
+static int ping_v4_init_sock(struct sock *sk)
 {
 	struct net *net = sock_net(sk);
 	kgid_t group = current_egid();
@@ -270,7 +270,6 @@ int ping_init_sock(struct sock *sk)
 
 	return -EACCES;
 }
-EXPORT_SYMBOL_GPL(ping_init_sock);
 
 void ping_close(struct sock *sk, long timeout)
 {
@@ -964,7 +963,7 @@ EXPORT_SYMBOL_GPL(ping_rcv);
 struct proto ping_prot = {
 	.name =		"PING",
 	.owner =	THIS_MODULE,
-	.init =		ping_init_sock,
+	.init =		ping_v4_init_sock,
 	.close =	ping_close,
 	.connect =	ip4_datagram_connect,
 	.disconnect =	udp_disconnect,
diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index a431103..e6c1953 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -26,10 +26,37 @@
 #include <net/transp_v6.h>
 #include <net/ping.h>
 
+static int ping_v6_init_sock(struct sock *sk)
+{
+	struct net *net = sock_net(sk);
+	kgid_t group = current_egid();
+	struct group_info *group_info = get_current_groups();
+	int i, j, count = group_info->ngroups;
+	kgid_t low, high;
+
+	inet6_get_ping_group_range(net->ipv6.sysctl.ping_group_range,
+				   &low, &high);
+	if (gid_lte(low, group) && gid_lte(group, high))
+		return 0;
+
+	for (i = 0; i < group_info->nblocks; i++) {
+		int cp_count = min_t(int, NGROUPS_PER_BLOCK, count);
+		for (j = 0; j < cp_count; j++) {
+			kgid_t gid = group_info->blocks[i][j];
+			if (gid_lte(low, gid) && gid_lte(gid, high))
+				return 0;
+		}
+
+		count -= cp_count;
+	}
+
+	return -EACCES;
+}
+
 struct proto pingv6_prot = {
 	.name =		"PINGv6",
 	.owner =	THIS_MODULE,
-	.init =		ping_init_sock,
+	.init =		ping_v6_init_sock,
 	.close =	ping_close,
 	.connect =	ip6_datagram_connect,
 	.disconnect =	udp_disconnect,
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index e85c48b..3fc4ff9 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -15,6 +15,67 @@
 #include <net/ipv6.h>
 #include <net/addrconf.h>
 #include <net/inet_frag.h>
+#include <net/ping.h>
+
+static DEFINE_SEQLOCK(sysctl_ping_group_range);
+static int ip6_ping_group_range_min[] = { 0, 0 };
+static int ip6_ping_group_range_max[] = { GID_T_MAX, GID_T_MAX };
+
+void inet6_get_ping_group_range(kgid_t *data, kgid_t *low, kgid_t *high)
+{
+	unsigned int seq;
+	do {
+		seq = read_seqbegin(&sysctl_ping_group_range);
+
+		*low = data[0];
+		*high = data[1];
+	} while (read_seqretry(&sysctl_ping_group_range, seq));
+}
+
+static void set_ping_group_range(struct ctl_table *table, kgid_t low, kgid_t high)
+{
+	kgid_t *data = table->data;
+	write_seqlock(&sysctl_ping_group_range);
+	data[0] = low;
+	data[1] = high;
+	write_sequnlock(&sysctl_ping_group_range);
+}
+
+/* Validate changes from /proc interface. */
+static int ipv6_ping_group_range(ctl_table *table, int write,
+				 void __user *buffer,
+				 size_t *lenp, loff_t *ppos)
+{
+	struct user_namespace *user_ns = current_user_ns();
+	int ret;
+	gid_t urange[2];
+	kgid_t low, high;
+	ctl_table tmp = {
+		.data = &urange,
+		.maxlen = sizeof(urange),
+		.mode = table->mode,
+		.extra1 = &ip6_ping_group_range_min,
+		.extra2 = &ip6_ping_group_range_max,
+	};
+
+	inet6_get_ping_group_range(table->data, &low, &high);
+	urange[0] = from_kgid_munged(user_ns, low);
+	urange[1] = from_kgid_munged(user_ns, high);
+	ret = proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos);
+
+	if (write && ret == 0) {
+		low = make_kgid(user_ns, urange[0]);
+		high = make_kgid(user_ns, urange[1]);
+		if (!gid_valid(low) || !gid_valid(high) ||
+		    (urange[1] < urange[0]) || gid_lt(high, low)) {
+			low = make_kgid(&init_user_ns, 1);
+			high = make_kgid(&init_user_ns, 0);
+		}
+		set_ping_group_range(table, low, high);
+	}
+
+	return ret;
+}
 
 static ctl_table ipv6_table_template[] = {
 	{
@@ -24,6 +85,13 @@ static ctl_table ipv6_table_template[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "ping_group_range",
+		.data		= &init_net.ipv6.sysctl.ping_group_range,
+		.maxlen		= sizeof(gid_t)*2,
+		.mode		= 0644,
+		.proc_handler	= ipv6_ping_group_range,
+	},
 	{ }
 };
 
@@ -51,6 +119,8 @@ static int __net_init ipv6_sysctl_net_init(struct net *net)
 	if (!ipv6_table)
 		goto out;
 	ipv6_table[0].data = &net->ipv6.sysctl.bindv6only;
+	net->ipv6.sysctl.ping_group_range[0] = make_kgid(&init_user_ns, 1);
+	net->ipv6.sysctl.ping_group_range[1] = make_kgid(&init_user_ns, 0);
 
 	ipv6_route_table = ipv6_route_sysctl_init(net);
 	if (!ipv6_route_table)
