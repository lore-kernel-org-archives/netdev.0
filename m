From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v2] net: Make table id type u32
Date: Tue,  1 Sep 2015 12:50:16 -0600
Message-ID: <1441133416-29523-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:38111 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751700AbbIASuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 14:50:51 -0400
Received: by igbut12 with SMTP id ut12so8243274igb.1
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 11:50:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A number of VRF patches used 'int' for table id. It should be u32 to be
consistent with the rest of the stack.

Fixes:
4e3c89920cd3a ("net: Introduce VRF related flags and helpers")
15be405eb2ea9 ("net: Add inet_addr lookup by table")
30bbaa1950055 ("net: Fix up inet_addr_type checks")
021dd3b8a142d ("net: Add routes to the table associated with the device")
dc028da54ed35 ("inet: Move VRF table lookup to inlined function")
f6d3c19274c74 ("net: FIB tracepoints")

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v2
- update tracepoint as well (thanks, Nikolay)

 include/net/route.h        |  2 +-
 include/net/vrf.h          | 24 ++++++++++++------------
 include/trace/events/fib.h |  4 ++--
 net/ipv4/af_inet.c         |  2 +-
 net/ipv4/fib_frontend.c    | 10 +++++-----
 net/ipv4/fib_semantics.c   |  2 +-
 6 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 395d79bb556c..cc61cb95f059 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -188,7 +188,7 @@ void ipv4_sk_redirect(struct sk_buff *skb, struct sock *sk);
 void ip_rt_send_redirect(struct sk_buff *skb);
 
 unsigned int inet_addr_type(struct net *net, __be32 addr);
-unsigned int inet_addr_type_table(struct net *net, __be32 addr, int tb_id);
+unsigned int inet_addr_type_table(struct net *net, __be32 addr, u32 tb_id);
 unsigned int inet_dev_addr_type(struct net *net, const struct net_device *dev,
 				__be32 addr);
 unsigned int inet_addr_type_dev_table(struct net *net,
diff --git a/include/net/vrf.h b/include/net/vrf.h
index 5bfb16237fd7..593e6094ddd4 100644
--- a/include/net/vrf.h
+++ b/include/net/vrf.h
@@ -66,9 +66,9 @@ static inline int vrf_master_ifindex(const struct net_device *dev)
 }
 
 /* called with rcu_read_lock */
-static inline int vrf_dev_table_rcu(const struct net_device *dev)
+static inline u32 vrf_dev_table_rcu(const struct net_device *dev)
 {
-	int tb_id = 0;
+	u32 tb_id = 0;
 
 	if (dev) {
 		struct net_vrf_dev *vrf_ptr;
@@ -80,9 +80,9 @@ static inline int vrf_dev_table_rcu(const struct net_device *dev)
 	return tb_id;
 }
 
-static inline int vrf_dev_table(const struct net_device *dev)
+static inline u32 vrf_dev_table(const struct net_device *dev)
 {
-	int tb_id;
+	u32 tb_id;
 
 	rcu_read_lock();
 	tb_id = vrf_dev_table_rcu(dev);
@@ -91,10 +91,10 @@ static inline int vrf_dev_table(const struct net_device *dev)
 	return tb_id;
 }
 
-static inline int vrf_dev_table_ifindex(struct net *net, int ifindex)
+static inline u32 vrf_dev_table_ifindex(struct net *net, int ifindex)
 {
 	struct net_device *dev;
-	int tb_id = 0;
+	u32 tb_id = 0;
 
 	if (!ifindex)
 		return 0;
@@ -111,9 +111,9 @@ static inline int vrf_dev_table_ifindex(struct net *net, int ifindex)
 }
 
 /* called with rtnl */
-static inline int vrf_dev_table_rtnl(const struct net_device *dev)
+static inline u32 vrf_dev_table_rtnl(const struct net_device *dev)
 {
-	int tb_id = 0;
+	u32 tb_id = 0;
 
 	if (dev) {
 		struct net_vrf_dev *vrf_ptr;
@@ -149,22 +149,22 @@ static inline int vrf_master_ifindex(const struct net_device *dev)
 	return 0;
 }
 
-static inline int vrf_dev_table_rcu(const struct net_device *dev)
+static inline u32 vrf_dev_table_rcu(const struct net_device *dev)
 {
 	return 0;
 }
 
-static inline int vrf_dev_table(const struct net_device *dev)
+static inline u32 vrf_dev_table(const struct net_device *dev)
 {
 	return 0;
 }
 
-static inline int vrf_dev_table_ifindex(struct net *net, int ifindex)
+static inline u32 vrf_dev_table_ifindex(struct net *net, int ifindex)
 {
 	return 0;
 }
 
-static inline int vrf_dev_table_rtnl(const struct net_device *dev)
+static inline u32 vrf_dev_table_rtnl(const struct net_device *dev)
 {
 	return 0;
 }
diff --git a/include/trace/events/fib.h b/include/trace/events/fib.h
index acd1d22571a2..e9cea16d1515 100644
--- a/include/trace/events/fib.h
+++ b/include/trace/events/fib.h
@@ -11,12 +11,12 @@
 
 TRACE_EVENT(fib_table_lookup,
 
-	TP_PROTO(int tb_id, const struct flowi4 *flp),
+	TP_PROTO(u32 tb_id, const struct flowi4 *flp),
 
 	TP_ARGS(tb_id, flp),
 
 	TP_STRUCT__entry(
-		__field(	int,	tb_id		)
+		__field(	u32,	tb_id		)
 		__field(	int,	oif		)
 		__field(	int,	iif		)
 		__field(	__u8,	tos		)
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 96773a2f95a7..1d0c3adb6f34 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -428,7 +428,7 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	struct net *net = sock_net(sk);
 	unsigned short snum;
 	int chk_addr_ret;
-	int tb_id = RT_TABLE_LOCAL;
+	u32 tb_id = RT_TABLE_LOCAL;
 	int err;
 
 	/* If the socket has its own bind function then use it. (RAW) */
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 4036c94dfbe1..6fcbd215cdbc 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -213,7 +213,7 @@ void fib_flush_external(struct net *net)
  */
 static inline unsigned int __inet_dev_addr_type(struct net *net,
 						const struct net_device *dev,
-						__be32 addr, int tb_id)
+						__be32 addr, u32 tb_id)
 {
 	struct flowi4		fl4 = { .daddr = addr };
 	struct fib_result	res;
@@ -240,7 +240,7 @@ static inline unsigned int __inet_dev_addr_type(struct net *net,
 	return ret;
 }
 
-unsigned int inet_addr_type_table(struct net *net, __be32 addr, int tb_id)
+unsigned int inet_addr_type_table(struct net *net, __be32 addr, u32 tb_id)
 {
 	return __inet_dev_addr_type(net, NULL, addr, tb_id);
 }
@@ -255,7 +255,7 @@ EXPORT_SYMBOL(inet_addr_type);
 unsigned int inet_dev_addr_type(struct net *net, const struct net_device *dev,
 				__be32 addr)
 {
-	int rt_table = vrf_dev_table(dev) ? : RT_TABLE_LOCAL;
+	u32 rt_table = vrf_dev_table(dev) ? : RT_TABLE_LOCAL;
 
 	return __inet_dev_addr_type(net, dev, addr, rt_table);
 }
@@ -268,7 +268,7 @@ unsigned int inet_addr_type_dev_table(struct net *net,
 				      const struct net_device *dev,
 				      __be32 addr)
 {
-	int rt_table = vrf_dev_table(dev) ? : RT_TABLE_LOCAL;
+	u32 rt_table = vrf_dev_table(dev) ? : RT_TABLE_LOCAL;
 
 	return __inet_dev_addr_type(net, NULL, addr, rt_table);
 }
@@ -803,7 +803,7 @@ static int inet_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 static void fib_magic(int cmd, int type, __be32 dst, int dst_len, struct in_ifaddr *ifa)
 {
 	struct net *net = dev_net(ifa->ifa_dev->dev);
-	int tb_id = vrf_dev_table_rtnl(ifa->ifa_dev->dev);
+	u32 tb_id = vrf_dev_table_rtnl(ifa->ifa_dev->dev);
 	struct fib_table *tb;
 	struct fib_config cfg = {
 		.fc_protocol = RTPROT_KERNEL,
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 992a9597daf8..064bd3caaa4f 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -863,7 +863,7 @@ static bool fib_valid_prefsrc(struct fib_config *cfg, __be32 fib_prefsrc)
 {
 	if (cfg->fc_type != RTN_LOCAL || !cfg->fc_dst ||
 	    fib_prefsrc != cfg->fc_dst) {
-		int tb_id = cfg->fc_table;
+		u32 tb_id = cfg->fc_table;
 
 		if (tb_id == RT_TABLE_MAIN)
 			tb_id = RT_TABLE_LOCAL;
-- 
2.3.2 (Apple Git-55)
