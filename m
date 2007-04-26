From: akpm@linux-foundation.org
Subject: [patch 02/15] net/: possible cleanups
Date: Thu, 26 Apr 2007 00:27:22 -0700
Message-ID: <200704260727.l3Q7RMSV023946@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, bunk@stusta.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:51456 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933430AbXDZH2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 03:28:12 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>

- make the following needlessly global variables static:
  - core/rtnetlink.c: struct rtnl_msg_handlers[]
  - netfilter/nf_conntrack_proto.c: struct nf_ct_protos[]
- make the following needlessly global functions static:
  - core/rtnetlink.c: rtnl_dump_all()
  - netlink/af_netlink.c: netlink_queue_skip()

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/net/netfilter/nf_conntrack_l4proto.h |    1 -
 include/net/netlink.h                        |    2 --
 include/net/rtnetlink.h                      |    1 -
 net/core/rtnetlink.c                         |    6 ++----
 net/netfilter/nf_conntrack_proto.c           |    2 +-
 net/netlink/af_netlink.c                     |    4 ++--
 6 files changed, 5 insertions(+), 11 deletions(-)

diff -puN include/net/netfilter/nf_conntrack_l4proto.h~net-possible-cleanups include/net/netfilter/nf_conntrack_l4proto.h
--- a/include/net/netfilter/nf_conntrack_l4proto.h~net-possible-cleanups
+++ a/include/net/netfilter/nf_conntrack_l4proto.h
@@ -97,7 +97,6 @@ extern struct nf_conntrack_l4proto nf_co
 extern struct nf_conntrack_l4proto nf_conntrack_l4proto_generic;
 
 #define MAX_NF_CT_PROTO 256
-extern struct nf_conntrack_l4proto **nf_ct_protos[PF_MAX];
 
 extern struct nf_conntrack_l4proto *
 __nf_ct_l4proto_find(u_int16_t l3proto, u_int8_t l4proto);
diff -puN include/net/netlink.h~net-possible-cleanups include/net/netlink.h
--- a/include/net/netlink.h~net-possible-cleanups
+++ a/include/net/netlink.h
@@ -217,8 +217,6 @@ struct nl_info {
 extern void		netlink_run_queue(struct sock *sk, unsigned int *qlen,
 					  int (*cb)(struct sk_buff *,
 						    struct nlmsghdr *));
-extern void		netlink_queue_skip(struct nlmsghdr *nlh,
-					   struct sk_buff *skb);
 extern int		nlmsg_notify(struct sock *sk, struct sk_buff *skb,
 				     u32 pid, unsigned int group, int report,
 				     gfp_t flags);
diff -puN include/net/rtnetlink.h~net-possible-cleanups include/net/rtnetlink.h
--- a/include/net/rtnetlink.h~net-possible-cleanups
+++ a/include/net/rtnetlink.h
@@ -13,7 +13,6 @@ extern void	rtnl_register(int protocol, 
 			      rtnl_doit_func, rtnl_dumpit_func);
 extern int	rtnl_unregister(int protocol, int msgtype);
 extern void	rtnl_unregister_all(int protocol);
-extern int	rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb);
 
 static inline int rtnl_msg_family(struct nlmsghdr *nlh)
 {
diff -puN net/core/rtnetlink.c~net-possible-cleanups net/core/rtnetlink.c
--- a/net/core/rtnetlink.c~net-possible-cleanups
+++ a/net/core/rtnetlink.c
@@ -97,7 +97,7 @@ int rtattr_parse(struct rtattr *tb[], in
 	return 0;
 }
 
-struct rtnl_link *rtnl_msg_handlers[NPROTO];
+static struct rtnl_link *rtnl_msg_handlers[NPROTO];
 
 static inline int rtm_msgindex(int msgtype)
 {
@@ -765,7 +765,7 @@ errout:
 	return err;
 }
 
-int rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
+static int rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	int idx;
 	int s_idx = cb->family;
@@ -789,8 +789,6 @@ int rtnl_dump_all(struct sk_buff *skb, s
 	return skb->len;
 }
 
-EXPORT_SYMBOL_GPL(rtnl_dump_all);
-
 void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change)
 {
 	struct sk_buff *skb;
diff -puN net/netfilter/nf_conntrack_proto.c~net-possible-cleanups net/netfilter/nf_conntrack_proto.c
--- a/net/netfilter/nf_conntrack_proto.c~net-possible-cleanups
+++ a/net/netfilter/nf_conntrack_proto.c
@@ -28,7 +28,7 @@
 #include <net/netfilter/nf_conntrack_l4proto.h>
 #include <net/netfilter/nf_conntrack_core.h>
 
-struct nf_conntrack_l4proto **nf_ct_protos[PF_MAX] __read_mostly;
+static struct nf_conntrack_l4proto **nf_ct_protos[PF_MAX] __read_mostly;
 struct nf_conntrack_l3proto *nf_ct_l3protos[AF_MAX] __read_mostly;
 EXPORT_SYMBOL_GPL(nf_ct_l3protos);
 
diff -puN net/netlink/af_netlink.c~net-possible-cleanups net/netlink/af_netlink.c
--- a/net/netlink/af_netlink.c~net-possible-cleanups
+++ a/net/netlink/af_netlink.c
@@ -121,6 +121,7 @@ static DECLARE_WAIT_QUEUE_HEAD(nl_table_
 
 static int netlink_dump(struct sock *sk);
 static void netlink_destroy_callback(struct netlink_callback *cb);
+static void netlink_queue_skip(struct nlmsghdr *nlh, struct sk_buff *skb);
 
 static DEFINE_RWLOCK(nl_table_lock);
 static atomic_t nl_table_users = ATOMIC_INIT(0);
@@ -1568,7 +1569,7 @@ void netlink_run_queue(struct sock *sk, 
  * Pulls the given netlink message off the socket buffer so the next
  * call to netlink_queue_run() will not reconsider the message.
  */
-void netlink_queue_skip(struct nlmsghdr *nlh, struct sk_buff *skb)
+static void netlink_queue_skip(struct nlmsghdr *nlh, struct sk_buff *skb)
 {
 	int msglen = NLMSG_ALIGN(nlh->nlmsg_len);
 
@@ -1851,7 +1852,6 @@ core_initcall(netlink_proto_init);
 
 EXPORT_SYMBOL(netlink_ack);
 EXPORT_SYMBOL(netlink_run_queue);
-EXPORT_SYMBOL(netlink_queue_skip);
 EXPORT_SYMBOL(netlink_broadcast);
 EXPORT_SYMBOL(netlink_dump_start);
 EXPORT_SYMBOL(netlink_kernel_create);
_
