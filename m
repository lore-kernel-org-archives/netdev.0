From: Adrian Bunk <bunk@stusta.de>
Subject: [-mm patch] net/: possible cleanups
Date: Wed, 4 Apr 2007 17:25:43 +0200
Message-ID: <20070404152543.GM27660@stusta.de>
References: <20070402224745.71a25af7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S2992950AbXDDPZs@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070402224745.71a25af7.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 02, 2007 at 10:47:45PM -0700, Andrew Morton wrote:
>...
> Changes since 2.6.21-rc5-mm3:
>...
>  git-net.patch
>...
>  git trees.
>...


This patch contains the following possible cleanups:
- make the following needlessly global variables static:
  - core/rtnetlink.c: struct rtnl_msg_handlers[]
  - netfilter/nf_conntrack_proto.c: struct nf_ct_protos[] 
- make the following needlessly global functions static:
  - core/rtnetlink.c: rtnl_dump_all()
  - netlink/af_netlink.c: netlink_queue_skip()

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 include/net/netfilter/nf_conntrack_l4proto.h |    1 -
 include/net/netlink.h                        |    2 --
 include/net/rtnetlink.h                      |    1 -
 net/core/rtnetlink.c                         |    6 ++----
 net/netfilter/nf_conntrack_proto.c           |    2 +-
 net/netlink/af_netlink.c                     |    4 ++--
 6 files changed, 5 insertions(+), 11 deletions(-)

--- linux-2.6.21-rc5-mm4/include/net/rtnetlink.h.old	2007-04-03 23:58:30.000000000 +0200
+++ linux-2.6.21-rc5-mm4/include/net/rtnetlink.h	2007-04-03 23:58:35.000000000 +0200
@@ -13,7 +13,6 @@
 			      rtnl_doit_func, rtnl_dumpit_func);
 extern int	rtnl_unregister(int protocol, int msgtype);
 extern void	rtnl_unregister_all(int protocol);
-extern int	rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb);
 
 static inline int rtnl_msg_family(struct nlmsghdr *nlh)
 {
--- linux-2.6.21-rc5-mm4/net/core/rtnetlink.c.old	2007-04-03 23:34:49.000000000 +0200
+++ linux-2.6.21-rc5-mm4/net/core/rtnetlink.c	2007-04-03 23:58:44.000000000 +0200
@@ -101,7 +101,7 @@
 	return 0;
 }
 
-struct rtnl_link *rtnl_msg_handlers[NPROTO];
+static struct rtnl_link *rtnl_msg_handlers[NPROTO];
 
 static inline int rtm_msgindex(int msgtype)
 {
@@ -771,7 +771,7 @@
 	return err;
 }
 
-int rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
+static int rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	int idx;
 	int s_idx = cb->family;
@@ -795,8 +795,6 @@
 	return skb->len;
 }
 
-EXPORT_SYMBOL_GPL(rtnl_dump_all);
-
 void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change)
 {
 	struct sk_buff *skb;
--- linux-2.6.21-rc5-mm4/include/net/netfilter/nf_conntrack_l4proto.h.old	2007-04-04 01:22:41.000000000 +0200
+++ linux-2.6.21-rc5-mm4/include/net/netfilter/nf_conntrack_l4proto.h	2007-04-04 01:22:50.000000000 +0200
@@ -97,7 +97,6 @@
 extern struct nf_conntrack_l4proto nf_conntrack_l4proto_generic;
 
 #define MAX_NF_CT_PROTO 256
-extern struct nf_conntrack_l4proto **nf_ct_protos[PF_MAX];
 
 extern struct nf_conntrack_l4proto *
 __nf_ct_l4proto_find(u_int16_t l3proto, u_int8_t l4proto);
--- linux-2.6.21-rc5-mm4/net/netfilter/nf_conntrack_proto.c.old	2007-04-04 00:00:26.000000000 +0200
+++ linux-2.6.21-rc5-mm4/net/netfilter/nf_conntrack_proto.c	2007-04-04 00:00:43.000000000 +0200
@@ -28,7 +28,7 @@
 #include <net/netfilter/nf_conntrack_l4proto.h>
 #include <net/netfilter/nf_conntrack_core.h>
 
-struct nf_conntrack_l4proto **nf_ct_protos[PF_MAX] __read_mostly;
+static struct nf_conntrack_l4proto **nf_ct_protos[PF_MAX] __read_mostly;
 struct nf_conntrack_l3proto *nf_ct_l3protos[AF_MAX] __read_mostly;
 EXPORT_SYMBOL_GPL(nf_ct_l3protos);
 
--- linux-2.6.21-rc5-mm4/include/net/netlink.h.old	2007-04-04 00:01:21.000000000 +0200
+++ linux-2.6.21-rc5-mm4/include/net/netlink.h	2007-04-04 00:01:52.000000000 +0200
@@ -217,8 +217,6 @@
 extern void		netlink_run_queue(struct sock *sk, unsigned int *qlen,
 					  int (*cb)(struct sk_buff *,
 						    struct nlmsghdr *));
-extern void		netlink_queue_skip(struct nlmsghdr *nlh,
-					   struct sk_buff *skb);
 extern int		nlmsg_notify(struct sock *sk, struct sk_buff *skb,
 				     u32 pid, unsigned int group, int report,
 				     gfp_t flags);
--- linux-2.6.21-rc5-mm4/net/netlink/af_netlink.c.old	2007-04-04 00:01:59.000000000 +0200
+++ linux-2.6.21-rc5-mm4/net/netlink/af_netlink.c	2007-04-04 00:02:22.000000000 +0200
@@ -117,6 +117,7 @@
 
 static int netlink_dump(struct sock *sk);
 static void netlink_destroy_callback(struct netlink_callback *cb);
+static void netlink_queue_skip(struct nlmsghdr *nlh, struct sk_buff *skb);
 
 static DEFINE_RWLOCK(nl_table_lock);
 static atomic_t nl_table_users = ATOMIC_INIT(0);
@@ -1555,7 +1556,7 @@
  * Pulls the given netlink message off the socket buffer so the next
  * call to netlink_queue_run() will not reconsider the message.
  */
-void netlink_queue_skip(struct nlmsghdr *nlh, struct sk_buff *skb)
+static void netlink_queue_skip(struct nlmsghdr *nlh, struct sk_buff *skb)
 {
 	int msglen = NLMSG_ALIGN(nlh->nlmsg_len);
 
@@ -1838,7 +1839,6 @@
 
 EXPORT_SYMBOL(netlink_ack);
 EXPORT_SYMBOL(netlink_run_queue);
-EXPORT_SYMBOL(netlink_queue_skip);
 EXPORT_SYMBOL(netlink_broadcast);
 EXPORT_SYMBOL(netlink_dump_start);
 EXPORT_SYMBOL(netlink_kernel_create);
