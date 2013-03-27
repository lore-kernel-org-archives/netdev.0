From: Hong Zhiguo <honkiko@gmail.com>
Subject: [PATCH 1/6] net-next: replace obsolete NLMSG_* with type safe nlmsg_*
Date: Thu, 28 Mar 2013 00:47:04 +0800
Message-ID: <1364402824-32680-1-git-send-email-honkiko@gmail.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org, tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
---
 net/bridge/netfilter/ebt_ulog.c      |    4 ++--
 net/core/rtnetlink.c                 |    4 ++--
 net/decnet/dn_table.c                |    4 ++--
 net/decnet/netfilter/dn_rtmsg.c      |   12 ++++++------
 net/ieee802154/netlink.c             |    4 ++--
 net/ipv4/fib_frontend.c              |    6 +++---
 net/ipv4/ipmr.c                      |   10 +++++-----
 net/ipv4/netfilter/ipt_ULOG.c        |    4 ++--
 net/ipv4/udp_diag.c                  |    6 +++---
 net/ipv6/ip6mr.c                     |   10 +++++-----
 net/netfilter/ipset/ip_set_core.c    |    5 ++---
 net/netfilter/nfnetlink.c            |    7 +++----
 net/netfilter/nfnetlink_log.c        |    4 ++--
 net/netfilter/nfnetlink_queue_core.c |    2 +-
 net/netlink/af_netlink.c             |    4 ++--
 net/sched/cls_api.c                  |    4 ++--
 net/sched/sch_api.c                  |    2 +-
 net/tipc/netlink.c                   |    6 +++---
 18 files changed, 48 insertions(+), 50 deletions(-)

diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulog.c
index 3bf43f7..75f23ba 100644
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -35,7 +35,7 @@
 #include <linux/skbuff.h>
 #include <linux/kernel.h>
 #include <linux/timer.h>
-#include <linux/netlink.h>
+#include <net/netlink.h>
 #include <linux/netdevice.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_bridge/ebtables.h>
@@ -134,7 +134,7 @@ static void ebt_ulog_packet(unsigned int hooknr, const struct sk_buff *skb,
 	else
 		copy_len = uloginfo->cprange;
 
-	size = NLMSG_SPACE(sizeof(*pm) + copy_len);
+	size = nlmsg_total_size(sizeof(*pm) + copy_len);
 	if (size > nlbufsiz) {
 		pr_debug("Size %Zd needed, but nlbufsiz=%d\n", size, nlbufsiz);
 		return;
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index aeb8131..6fdfac8 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2613,10 +2613,10 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	type -= RTM_BASE;
 
 	/* All the messages must have at least 1 byte length */
-	if (nlh->nlmsg_len < NLMSG_LENGTH(sizeof(struct rtgenmsg)))
+	if (nlmsg_len(nlh) < sizeof(struct rtgenmsg))
 		return 0;
 
-	family = ((struct rtgenmsg *)NLMSG_DATA(nlh))->rtgen_family;
+	family = ((struct rtgenmsg *)nlmsg_data(nlh))->rtgen_family;
 	sz_idx = type>>2;
 	kind = type&3;
 
diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
index fc42a0a..b15c1d1 100644
--- a/net/decnet/dn_table.c
+++ b/net/decnet/dn_table.c
@@ -19,7 +19,7 @@
 #include <linux/sockios.h>
 #include <linux/init.h>
 #include <linux/skbuff.h>
-#include <linux/netlink.h>
+#include <net/netlink.h>
 #include <linux/rtnetlink.h>
 #include <linux/proc_fs.h>
 #include <linux/netdevice.h>
@@ -492,7 +492,7 @@ int dn_fib_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	if (!net_eq(net, &init_net))
 		return 0;
 
-	if (NLMSG_PAYLOAD(cb->nlh, 0) >= sizeof(struct rtmsg) &&
+	if (nlmsg_len(cb->nlh) >= sizeof(struct rtmsg) &&
 		((struct rtmsg *)nlmsg_data(cb->nlh))->rtm_flags&RTM_F_CLONED)
 			return dn_cache_dump(skb, cb);
 
diff --git a/net/decnet/netfilter/dn_rtmsg.c b/net/decnet/netfilter/dn_rtmsg.c
index dfe4201..4ff1cfb 100644
--- a/net/decnet/netfilter/dn_rtmsg.c
+++ b/net/decnet/netfilter/dn_rtmsg.c
@@ -19,7 +19,7 @@
 #include <linux/netdevice.h>
 #include <linux/netfilter.h>
 #include <linux/spinlock.h>
-#include <linux/netlink.h>
+#include <net/netlink.h>
 #include <linux/netfilter_decnet.h>
 
 #include <net/sock.h>
@@ -39,21 +39,21 @@ static struct sk_buff *dnrmg_build_message(struct sk_buff *rt_skb, int *errp)
 	unsigned char *ptr;
 	struct nf_dn_rtmsg *rtm;
 
-	size = NLMSG_SPACE(rt_skb->len);
-	size += NLMSG_ALIGN(sizeof(struct nf_dn_rtmsg));
-	skb = alloc_skb(size, GFP_ATOMIC);
+	size = NLMSG_ALIGN(rt_skb->len) + 
+	       NLMSG_ALIGN(sizeof(struct nf_dn_rtmsg));
+	skb = nlmsg_new(size, GFP_ATOMIC);
 	if (!skb) {
 		*errp = -ENOMEM;
 		return NULL;
 	}
 	old_tail = skb->tail;
-	nlh = nlmsg_put(skb, 0, 0, 0, size - sizeof(*nlh), 0);
+	nlh = nlmsg_put(skb, 0, 0, 0, size, 0);
 	if (!nlh) {
 		kfree_skb(skb);
 		*errp = -ENOMEM;
 		return NULL;
 	}
-	rtm = (struct nf_dn_rtmsg *)NLMSG_DATA(nlh);
+	rtm = (struct nf_dn_rtmsg *)nlmsg_data(nlh);
 	rtm->nfdn_ifindex = rt_skb->dev->ifindex;
 	ptr = NFDN_RTMSG(rtm);
 	skb_copy_from_linear_data(rt_skb, ptr, rt_skb->len);
diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
index 97351e1..9247252 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -65,7 +65,7 @@ struct sk_buff *ieee802154_nl_create(int flags, u8 req)
 int ieee802154_nl_mcast(struct sk_buff *msg, unsigned int group)
 {
 	/* XXX: nlh is right at the start of msg */
-	void *hdr = genlmsg_data(NLMSG_DATA(msg->data));
+	void *hdr = genlmsg_data(nlmsg_data(msg->data));
 
 	if (genlmsg_end(msg, hdr) < 0)
 		goto out;
@@ -98,7 +98,7 @@ struct sk_buff *ieee802154_nl_new_reply(struct genl_info *info,
 int ieee802154_nl_reply(struct sk_buff *msg, struct genl_info *info)
 {
 	/* XXX: nlh is right at the start of msg */
-	void *hdr = genlmsg_data(NLMSG_DATA(msg->data));
+	void *hdr = genlmsg_data(nlmsg_data(msg->data));
 
 	if (genlmsg_end(msg, hdr) < 0)
 		goto out;
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 0e74398..c7629a2 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -957,8 +957,8 @@ static void nl_fib_input(struct sk_buff *skb)
 
 	net = sock_net(skb->sk);
 	nlh = nlmsg_hdr(skb);
-	if (skb->len < NLMSG_SPACE(0) || skb->len < nlh->nlmsg_len ||
-	    nlh->nlmsg_len < NLMSG_LENGTH(sizeof(*frn)))
+	if (skb->len < NLMSG_HDRLEN || skb->len < nlh->nlmsg_len ||
+	    nlmsg_len(nlh) < sizeof(*frn))
 		return;
 
 	skb = skb_clone(skb, GFP_KERNEL);
@@ -966,7 +966,7 @@ static void nl_fib_input(struct sk_buff *skb)
 		return;
 	nlh = nlmsg_hdr(skb);
 
-	frn = (struct fib_result_nl *) NLMSG_DATA(nlh);
+	frn = (struct fib_result_nl *) nlmsg_data(nlh);
 	tb = fib_get_table(net, frn->tb_id_in);
 
 	nl_fib_lookup(frn, tb);
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 5f95b3a..e7b4bde 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -626,9 +626,9 @@ static void ipmr_destroy_unres(struct mr_table *mrt, struct mfc_cache *c)
 		if (ip_hdr(skb)->version == 0) {
 			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct iphdr));
 			nlh->nlmsg_type = NLMSG_ERROR;
-			nlh->nlmsg_len = NLMSG_LENGTH(sizeof(struct nlmsgerr));
+			nlh->nlmsg_len = nlmsg_msg_size(sizeof(struct nlmsgerr));
 			skb_trim(skb, nlh->nlmsg_len);
-			e = NLMSG_DATA(nlh);
+			e = nlmsg_data(nlh);
 			e->error = -ETIMEDOUT;
 			memset(&e->msg, 0, sizeof(e->msg));
 
@@ -910,14 +910,14 @@ static void ipmr_cache_resolve(struct net *net, struct mr_table *mrt,
 		if (ip_hdr(skb)->version == 0) {
 			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct iphdr));
 
-			if (__ipmr_fill_mroute(mrt, skb, c, NLMSG_DATA(nlh)) > 0) {
+			if (__ipmr_fill_mroute(mrt, skb, c, nlmsg_data(nlh)) > 0) {
 				nlh->nlmsg_len = skb_tail_pointer(skb) -
 						 (u8 *)nlh;
 			} else {
 				nlh->nlmsg_type = NLMSG_ERROR;
-				nlh->nlmsg_len = NLMSG_LENGTH(sizeof(struct nlmsgerr));
+				nlh->nlmsg_len = nlmsg_msg_size(sizeof(struct nlmsgerr));
 				skb_trim(skb, nlh->nlmsg_len);
-				e = NLMSG_DATA(nlh);
+				e = nlmsg_data(nlh);
 				e->error = -EMSGSIZE;
 				memset(&e->msg, 0, sizeof(e->msg));
 			}
diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index 7d168dc..e7f8cad 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -37,7 +37,7 @@
 #include <linux/skbuff.h>
 #include <linux/kernel.h>
 #include <linux/timer.h>
-#include <linux/netlink.h>
+#include <net/netlink.h>
 #include <linux/netdevice.h>
 #include <linux/mm.h>
 #include <linux/moduleparam.h>
@@ -172,7 +172,7 @@ static void ipt_ulog_packet(unsigned int hooknum,
 	else
 		copy_len = loginfo->copy_range;
 
-	size = NLMSG_SPACE(sizeof(*pm) + copy_len);
+	size = nlmsg_total_size(sizeof(*pm) + copy_len);
 
 	ub = &ulog_buffers[groupnum];
 
diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index 505b30a..467fb92 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -64,9 +64,9 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
 		goto out;
 
 	err = -ENOMEM;
-	rep = alloc_skb(NLMSG_SPACE((sizeof(struct inet_diag_msg) +
-				     sizeof(struct inet_diag_meminfo) +
-				     64)), GFP_KERNEL);
+	rep = nlmsg_new(sizeof(struct inet_diag_msg) +
+				     sizeof(struct inet_diag_meminfo) + 64,
+				     GFP_KERNEL);
 	if (!rep)
 		goto out;
 
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 96bfb4e..241fb8a 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -842,9 +842,9 @@ static void ip6mr_destroy_unres(struct mr6_table *mrt, struct mfc6_cache *c)
 		if (ipv6_hdr(skb)->version == 0) {
 			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct ipv6hdr));
 			nlh->nlmsg_type = NLMSG_ERROR;
-			nlh->nlmsg_len = NLMSG_LENGTH(sizeof(struct nlmsgerr));
+			nlh->nlmsg_len = nlmsg_msg_size(sizeof(struct nlmsgerr));
 			skb_trim(skb, nlh->nlmsg_len);
-			((struct nlmsgerr *)NLMSG_DATA(nlh))->error = -ETIMEDOUT;
+			((struct nlmsgerr *)nlmsg_data(nlh))->error = -ETIMEDOUT;
 			rtnl_unicast(skb, net, NETLINK_CB(skb).portid);
 		} else
 			kfree_skb(skb);
@@ -1100,13 +1100,13 @@ static void ip6mr_cache_resolve(struct net *net, struct mr6_table *mrt,
 		if (ipv6_hdr(skb)->version == 0) {
 			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct ipv6hdr));
 
-			if (__ip6mr_fill_mroute(mrt, skb, c, NLMSG_DATA(nlh)) > 0) {
+			if (__ip6mr_fill_mroute(mrt, skb, c, nlmsg_data(nlh)) > 0) {
 				nlh->nlmsg_len = skb_tail_pointer(skb) - (u8 *)nlh;
 			} else {
 				nlh->nlmsg_type = NLMSG_ERROR;
-				nlh->nlmsg_len = NLMSG_LENGTH(sizeof(struct nlmsgerr));
+				nlh->nlmsg_len = nlmsg_msg_size(sizeof(struct nlmsgerr));
 				skb_trim(skb, nlh->nlmsg_len);
-				((struct nlmsgerr *)NLMSG_DATA(nlh))->error = -EMSGSIZE;
+				((struct nlmsgerr *)nlmsg_data(nlh))->error = -EMSGSIZE;
 			}
 			rtnl_unicast(skb, net, NETLINK_CB(skb).portid);
 		} else
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 1ba9dbc..86f5e26 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -15,7 +15,6 @@
 #include <linux/ip.h>
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
-#include <linux/netlink.h>
 #include <linux/rculist.h>
 #include <net/netlink.h>
 
@@ -1085,7 +1084,7 @@ static int
 dump_init(struct netlink_callback *cb)
 {
 	struct nlmsghdr *nlh = nlmsg_hdr(cb->skb);
-	int min_len = NLMSG_SPACE(sizeof(struct nfgenmsg));
+	int min_len = nlmsg_total_size(sizeof(struct nfgenmsg));
 	struct nlattr *cda[IPSET_ATTR_CMD_MAX+1];
 	struct nlattr *attr = (void *)nlh + min_len;
 	u32 dump_type;
@@ -1301,7 +1300,7 @@ call_ad(struct sock *ctnl, struct sk_buff *skb, struct ip_set *set,
 		struct sk_buff *skb2;
 		struct nlmsgerr *errmsg;
 		size_t payload = sizeof(*errmsg) + nlmsg_len(nlh);
-		int min_len = NLMSG_SPACE(sizeof(struct nfgenmsg));
+		int min_len = nlmsg_total_size(sizeof(struct nfgenmsg));
 		struct nlattr *cda[IPSET_ATTR_CMD_MAX+1];
 		struct nlattr *cmdattr;
 		u32 *errline;
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 0b1b32c..bc4c499 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -24,10 +24,9 @@
 #include <linux/skbuff.h>
 #include <asm/uaccess.h>
 #include <net/sock.h>
-#include <net/netlink.h>
 #include <linux/init.h>
 
-#include <linux/netlink.h>
+#include <net/netlink.h>
 #include <linux/netfilter/nfnetlink.h>
 
 MODULE_LICENSE("GPL");
@@ -144,7 +143,7 @@ static int nfnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return -EPERM;
 
 	/* All the messages must at least contain nfgenmsg */
-	if (nlh->nlmsg_len < NLMSG_LENGTH(sizeof(struct nfgenmsg)))
+	if (nlmsg_len(nlh) < sizeof(struct nfgenmsg))
 		return 0;
 
 	type = nlh->nlmsg_type;
@@ -172,7 +171,7 @@ replay:
 	}
 
 	{
-		int min_len = NLMSG_SPACE(sizeof(struct nfgenmsg));
+		int min_len = nlmsg_total_size(sizeof(struct nfgenmsg));
 		u_int8_t cb_id = NFNL_MSG_TYPE(nlh->nlmsg_type);
 		struct nlattr *cda[ss->cb[cb_id].attr_count + 1];
 		struct nlattr *attr = (void *)nlh + min_len;
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index f248db5..4a2593f 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -19,7 +19,7 @@
 #include <linux/ipv6.h>
 #include <linux/netdevice.h>
 #include <linux/netfilter.h>
-#include <linux/netlink.h>
+#include <net/netlink.h>
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_log.h>
 #include <linux/spinlock.h>
@@ -609,7 +609,7 @@ nfulnl_log_packet(u_int8_t pf,
 	/* FIXME: do we want to make the size calculation conditional based on
 	 * what is actually present?  way more branches and checks, but more
 	 * memory efficient... */
-	size =    NLMSG_SPACE(sizeof(struct nfgenmsg))
+	size =    nlmsg_total_size(sizeof(struct nfgenmsg))
 		+ nla_total_size(sizeof(struct nfulnl_msg_packet_hdr))
 		+ nla_total_size(sizeof(u_int32_t))	/* ifindex */
 		+ nla_total_size(sizeof(u_int32_t))	/* ifindex */
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 1cb4854..ae70b9e 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -236,7 +236,7 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 	struct nf_conn *ct = NULL;
 	enum ip_conntrack_info uninitialized_var(ctinfo);
 
-	size =    NLMSG_SPACE(sizeof(struct nfgenmsg))
+	size =    nlmsg_total_size(sizeof(struct nfgenmsg))
 		+ nla_total_size(sizeof(struct nfqnl_msg_packet_hdr))
 		+ nla_total_size(sizeof(u_int32_t))	/* ifindex */
 		+ nla_total_size(sizeof(u_int32_t))	/* ifindex */
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index a500ce2..ce2e006 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1646,7 +1646,7 @@ struct nlmsghdr *
 __nlmsg_put(struct sk_buff *skb, u32 portid, u32 seq, int type, int len, int flags)
 {
 	struct nlmsghdr *nlh;
-	int size = NLMSG_LENGTH(len);
+	int size = nlmsg_msg_size(len);
 
 	nlh = (struct nlmsghdr*)skb_put(skb, NLMSG_ALIGN(size));
 	nlh->nlmsg_type = type;
@@ -1655,7 +1655,7 @@ __nlmsg_put(struct sk_buff *skb, u32 portid, u32 seq, int type, int len, int fla
 	nlh->nlmsg_pid = portid;
 	nlh->nlmsg_seq = seq;
 	if (!__builtin_constant_p(size) || NLMSG_ALIGN(size) - size != 0)
-		memset(NLMSG_DATA(nlh) + len, 0, NLMSG_ALIGN(size) - size);
+		memset(nlmsg_data(nlh) + len, 0, NLMSG_ALIGN(size) - size);
 	return nlh;
 }
 EXPORT_SYMBOL(__nlmsg_put);
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 9d71d4d..5c81b26 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -22,7 +22,7 @@
 #include <linux/skbuff.h>
 #include <linux/init.h>
 #include <linux/kmod.h>
-#include <linux/netlink.h>
+#include <net/netlink.h>
 #include <linux/err.h>
 #include <linux/slab.h>
 #include <net/net_namespace.h>
@@ -428,7 +428,7 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 	const struct Qdisc_class_ops *cops;
 	struct tcf_dump_args arg;
 
-	if (cb->nlh->nlmsg_len < NLMSG_LENGTH(sizeof(*tcm)))
+	if (nlmsg_len(cb->nlh) < sizeof(*tcm))
 		return skb->len;
 	dev = __dev_get_by_index(net, tcm->tcm_ifindex);
 	if (!dev)
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index d7468ba..2b935e7 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1642,7 +1642,7 @@ static int tc_dump_tclass(struct sk_buff *skb, struct netlink_callback *cb)
 	struct net_device *dev;
 	int t, s_t;
 
-	if (cb->nlh->nlmsg_len < NLMSG_LENGTH(sizeof(*tcm)))
+	if (nlmsg_len(cb->nlh) < sizeof(*tcm))
 		return 0;
 	dev = dev_get_by_index(net, tcm->tcm_ifindex);
 	if (!dev)
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index 6675914..8bcd498 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -44,7 +44,7 @@ static int handle_cmd(struct sk_buff *skb, struct genl_info *info)
 	struct nlmsghdr *rep_nlh;
 	struct nlmsghdr *req_nlh = info->nlhdr;
 	struct tipc_genlmsghdr *req_userhdr = info->userhdr;
-	int hdr_space = NLMSG_SPACE(GENL_HDRLEN + TIPC_GENL_HDRLEN);
+	int hdr_space = nlmsg_total_size(GENL_HDRLEN + TIPC_GENL_HDRLEN);
 	u16 cmd;
 
 	if ((req_userhdr->cmd & 0xC000) && (!capable(CAP_NET_ADMIN)))
@@ -53,8 +53,8 @@ static int handle_cmd(struct sk_buff *skb, struct genl_info *info)
 		cmd = req_userhdr->cmd;
 
 	rep_buf = tipc_cfg_do_cmd(req_userhdr->dest, cmd,
-			NLMSG_DATA(req_nlh) + GENL_HDRLEN + TIPC_GENL_HDRLEN,
-			NLMSG_PAYLOAD(req_nlh, GENL_HDRLEN + TIPC_GENL_HDRLEN),
+			nlmsg_data(req_nlh) + GENL_HDRLEN + TIPC_GENL_HDRLEN,
+			nlmsg_attrlen(req_nlh, GENL_HDRLEN + TIPC_GENL_HDRLEN),
 			hdr_space);
 
 	if (rep_buf) {
-- 
1.7.10.4
