From: Steven Whitehouse <steve@chygwyn.com>
Subject: Re: Rules and groups
Date: Wed, 9 Aug 2006 11:03:26 +0100
Message-ID: <20060809100326.GA23935@souterrain.chygwyn.com>
References: <20060809080139.GA19555@souterrain.chygwyn.com> <20060809.010125.78708459.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, netdev@vger.kernel.org, patrick@tykepenguin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from souterrain.chygwyn.com ([194.39.143.233]:26537 "EHLO
	souterrain.chygwyn.com") by vger.kernel.org with ESMTP
	id S1030632AbWHIJ7W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 05:59:22 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060809.010125.78708459.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, Aug 09, 2006 at 01:01:25AM -0700, David Miller wrote:
> From: Steven Whitehouse <steve@chygwyn.com>
> Date: Wed, 9 Aug 2006 09:01:39 +0100
> 
> > Is there anything to stop me using RTNLGRP_NOP3 for that? (suitable
> > renamed of course!) So far as I can see its never been assigned to
> > anything else...
> 
> I have no objection to you using it.
>
Excellent. Please find attached my attempt at doing the conversion to the
generic rules code. It appears to work ok for me. You can also pull this
patch from the decnet git tree at:

git://git.kernel.org/pub/scm/linux/kernel/git/steve/decnet-2.6.19.git

which was cloned from net-2.6.19.git quite recently. In addition the
git tree has another patch which is in a following email.

Patrick: does this patch get your blessing?

Steve.

-----------------------------------------------------------------------------

[DECnet] Covert rules to use generic code

This patch converts the DECnet rules code to use the generic
rules system created by Thomas Graf <tgraf@suug.ch>.

Signed-off-by: Steven Whitehouse <steve@chygwyn.com>

---

 include/linux/rtnetlink.h |    3 
 include/net/dn_fib.h      |    8 -
 net/decnet/Kconfig        |    1 
 net/decnet/af_decnet.c    |    1 
 net/decnet/dn_dev.c       |    3 
 net/decnet/dn_fib.c       |    1 
 net/decnet/dn_route.c     |    3 
 net/decnet/dn_rules.c     |  492 +++++++++++++++++----------------------------
 net/decnet/dn_table.c     |    1 
 9 files changed, 195 insertions(+), 318 deletions(-)

0ff88cb56e1674234a8aaacb7869bc004252c0c2
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index bf35353..ea02e7d 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -885,7 +885,8 @@ enum rtnetlink_groups {
 	RTNLGRP_NOP2,
 	RTNLGRP_DECnet_ROUTE,
 #define RTNLGRP_DECnet_ROUTE	RTNLGRP_DECnet_ROUTE
-	RTNLGRP_NOP3,
+	RTNLGRP_DECnet_RULE,
+#define RTNLGRP_DECnet_RULE	RTNLGRP_DECnet_RULE
 	RTNLGRP_NOP4,
 	RTNLGRP_IPV6_PREFIX,
 #define RTNLGRP_IPV6_PREFIX	RTNLGRP_IPV6_PREFIX
diff --git a/include/net/dn_fib.h b/include/net/dn_fib.h
index a15dcf0..32bc8ce 100644
--- a/include/net/dn_fib.h
+++ b/include/net/dn_fib.h
@@ -22,7 +22,7 @@ struct dn_kern_rta
 };
 
 struct dn_fib_res {
-	struct dn_fib_rule *r;
+	struct fib_rule *r;
 	struct dn_fib_info *fi;
 	unsigned char prefixlen;
 	unsigned char nh_sel;
@@ -147,10 +147,8 @@ extern void dn_fib_table_cleanup(void);
  */
 extern void dn_fib_rules_init(void);
 extern void dn_fib_rules_cleanup(void);
-extern void dn_fib_rule_put(struct dn_fib_rule *);
-extern __le16 dn_fib_rules_policy(__le16 saddr, struct dn_fib_res *res, unsigned *flags);
 extern unsigned dnet_addr_type(__le16 addr);
-extern int dn_fib_lookup(const struct flowi *fl, struct dn_fib_res *res);
+extern int dn_fib_lookup(struct flowi *fl, struct dn_fib_res *res);
 
 /*
  * rtnetlink interface
@@ -176,7 +174,7 @@ static inline void dn_fib_res_put(struct
 	if (res->fi)
 		dn_fib_info_put(res->fi);
 	if (res->r)
-		dn_fib_rule_put(res->r);
+		fib_rule_put(res->r);
 }
 
 extern struct dn_fib_table *dn_fib_tables[];
diff --git a/net/decnet/Kconfig b/net/decnet/Kconfig
index 92f2ec4..36e72cb 100644
--- a/net/decnet/Kconfig
+++ b/net/decnet/Kconfig
@@ -27,6 +27,7 @@ config DECNET
 config DECNET_ROUTER
 	bool "DECnet: router support (EXPERIMENTAL)"
 	depends on DECNET && EXPERIMENTAL
+	select FIB_RULES
 	---help---
 	  Add support for turning your DECnet Endnode into a level 1 or 2
 	  router.  This is an experimental, but functional option.  If you
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 5486247..70e0273 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -130,6 +130,7 @@ Version 0.0.6    2.1.110   07-aug-98   E
 #include <linux/poll.h>
 #include <net/neighbour.h>
 #include <net/dst.h>
+#include <net/fib_rules.h>
 #include <net/dn.h>
 #include <net/dn_nsp.h>
 #include <net/dn_dev.h>
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 476455f..9ab2e5b 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -45,6 +45,7 @@
 #include <net/neighbour.h>
 #include <net/dst.h>
 #include <net/flow.h>
+#include <net/fib_rules.h>
 #include <net/dn.h>
 #include <net/dn_dev.h>
 #include <net/dn_route.h>
@@ -1417,8 +1418,6 @@ static struct rtnetlink_link dnet_rtnetl
 	[RTM_DELROUTE - RTM_BASE] = { .doit	= dn_fib_rtm_delroute,	},
 	[RTM_GETROUTE - RTM_BASE] = { .doit	= dn_cache_getroute,
 				      .dumpit	= dn_fib_dump,		},
-	[RTM_NEWRULE  - RTM_BASE] = { .doit	= dn_fib_rtm_newrule,	},
-	[RTM_DELRULE  - RTM_BASE] = { .doit	= dn_fib_rtm_delrule,	},
 	[RTM_GETRULE  - RTM_BASE] = { .dumpit	= dn_fib_dump_rules,	},
 #else
 	[RTM_GETROUTE - RTM_BASE] = { .doit	= dn_cache_getroute,
diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
index fa20e2e..846df39 100644
--- a/net/decnet/dn_fib.c
+++ b/net/decnet/dn_fib.c
@@ -34,6 +34,7 @@
 #include <net/neighbour.h>
 #include <net/dst.h>
 #include <net/flow.h>
+#include <net/fib_rules.h>
 #include <net/dn.h>
 #include <net/dn_route.h>
 #include <net/dn_fib.h>
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 1355614..41d6310 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -80,6 +80,7 @@
 #include <net/neighbour.h>
 #include <net/dst.h>
 #include <net/flow.h>
+#include <net/fib_rules.h>
 #include <net/dn.h>
 #include <net/dn_dev.h>
 #include <net/dn_nsp.h>
@@ -1279,7 +1280,7 @@ static int dn_route_input_slow(struct sk
 		dev_hold(out_dev);
 
 		if (res.r)
-			src_map = dn_fib_rules_policy(fl.fld_src, &res, &flags);
+			src_map = fl.fld_src; /* no NAT support for now */
 
 		gateway = DN_FIB_RES_GW(res);
 		if (res.type == RTN_NAT) {
diff --git a/net/decnet/dn_rules.c b/net/decnet/dn_rules.c
index 6986be7..096f127 100644
--- a/net/decnet/dn_rules.c
+++ b/net/decnet/dn_rules.c
@@ -11,259 +11,198 @@
  *
  *
  * Changes:
+ *              Steve Whitehouse <steve@chygwyn.com>
+ *              Updated for Thomas Graf's generic rules
  *
  */
-#include <linux/string.h>
 #include <linux/net.h>
-#include <linux/socket.h>
-#include <linux/sockios.h>
 #include <linux/init.h>
-#include <linux/skbuff.h>
 #include <linux/netlink.h>
 #include <linux/rtnetlink.h>
-#include <linux/proc_fs.h>
 #include <linux/netdevice.h>
-#include <linux/timer.h>
 #include <linux/spinlock.h>
-#include <linux/in_route.h>
 #include <linux/list.h>
 #include <linux/rcupdate.h>
-#include <asm/atomic.h>
-#include <asm/uaccess.h>
 #include <net/neighbour.h>
 #include <net/dst.h>
 #include <net/flow.h>
+#include <net/fib_rules.h>
 #include <net/dn.h>
 #include <net/dn_fib.h>
 #include <net/dn_neigh.h>
 #include <net/dn_dev.h>
 
+static struct fib_rules_ops dn_fib_rules_ops;
+
 struct dn_fib_rule
 {
-	struct hlist_node	r_hlist;
-	atomic_t		r_clntref;
-	u32			r_preference;
-	unsigned char		r_table;
-	unsigned char		r_action;
-	unsigned char		r_dst_len;
-	unsigned char		r_src_len;
-	__le16			r_src;
-	__le16			r_srcmask;
-	__le16			r_dst;
-	__le16			r_dstmask;
-	__le16			r_srcmap;
-	u8			r_flags;
+	struct fib_rule		common;
+	unsigned char		dst_len;
+	unsigned char		src_len;
+	__le16			src;
+	__le16			srcmask;
+	__le16			dst;
+	__le16			dstmask;
+	__le16			srcmap;
+	u8			flags;
 #ifdef CONFIG_DECNET_ROUTE_FWMARK
-	u32			r_fwmark;
+	u32			fwmark;
 #endif
-	int			r_ifindex;
-	char			r_ifname[IFNAMSIZ];
-	int			r_dead;
-	struct rcu_head		rcu;
 };
 
 static struct dn_fib_rule default_rule = {
-	.r_clntref =		ATOMIC_INIT(2),
-	.r_preference =		0x7fff,
-	.r_table =		RT_TABLE_MAIN,
-	.r_action =		RTN_UNICAST
+	.common = {
+		.refcnt =		ATOMIC_INIT(2),
+		.pref =			0x7fff,
+		.table =		RT_TABLE_MAIN,
+		.action =		FR_ACT_TO_TBL,
+	},
 };
 
-static struct hlist_head dn_fib_rules;
+static LIST_HEAD(dn_fib_rules);
+
 
-int dn_fib_rtm_delrule(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+int dn_fib_lookup(struct flowi *flp, struct dn_fib_res *res)
 {
-	struct rtattr **rta = arg;
-	struct rtmsg *rtm = NLMSG_DATA(nlh);
-	struct dn_fib_rule *r;
-	struct hlist_node *node;
-	int err = -ESRCH;
-
-	hlist_for_each_entry(r, node, &dn_fib_rules, r_hlist) {
-		if ((!rta[RTA_SRC-1] || memcmp(RTA_DATA(rta[RTA_SRC-1]), &r->r_src, 2) == 0) &&
-			rtm->rtm_src_len == r->r_src_len &&
-			rtm->rtm_dst_len == r->r_dst_len &&
-			(!rta[RTA_DST-1] || memcmp(RTA_DATA(rta[RTA_DST-1]), &r->r_dst, 2) == 0) &&
-#ifdef CONFIG_DECNET_ROUTE_FWMARK
-			(!rta[RTA_PROTOINFO-1] || memcmp(RTA_DATA(rta[RTA_PROTOINFO-1]), &r->r_fwmark, 4) == 0) &&
-#endif
-			(!rtm->rtm_type || rtm->rtm_type == r->r_action) &&
-			(!rta[RTA_PRIORITY-1] || memcmp(RTA_DATA(rta[RTA_PRIORITY-1]), &r->r_preference, 4) == 0) &&
-			(!rta[RTA_IIF-1] || rtattr_strcmp(rta[RTA_IIF-1], r->r_ifname) == 0) &&
-			(!rtm->rtm_table || (r && rtm->rtm_table == r->r_table))) {
-
-			err = -EPERM;
-			if (r == &default_rule)
-				break;
-
-			hlist_del_rcu(&r->r_hlist);
-			r->r_dead = 1;
-			dn_fib_rule_put(r);
-			err = 0;
-			break;
-		}
-	}
+	struct fib_lookup_arg arg = {
+		.result = res,
+	};
+	int err;
+
+	err = fib_rules_lookup(&dn_fib_rules_ops, flp, 0, &arg);
+	res->r = arg.rule;
 
 	return err;
 }
 
-static inline void dn_fib_rule_put_rcu(struct rcu_head *head)
+int dn_fib_rule_action(struct fib_rule *rule, struct flowi *flp, int flags,
+		       struct fib_lookup_arg *arg)
 {
-	struct dn_fib_rule *r = container_of(head, struct dn_fib_rule, rcu);
-	kfree(r);
-}
+	int err = -EAGAIN;
+	struct dn_fib_table *tbl;
 
-void dn_fib_rule_put(struct dn_fib_rule *r)
-{
-	if (atomic_dec_and_test(&r->r_clntref)) {
-		if (r->r_dead)
-			call_rcu(&r->rcu, dn_fib_rule_put_rcu);
-		else
-			printk(KERN_DEBUG "Attempt to free alive dn_fib_rule\n");
-	}
+	switch(rule->action) {
+	case FR_ACT_TO_TBL:
+		break;
+
+	case FR_ACT_UNREACHABLE:
+		err = -ENETUNREACH;
+		goto errout;
+
+	case FR_ACT_PROHIBIT:
+		err = -EACCES;
+		goto errout;
+
+	case FR_ACT_BLACKHOLE:
+	default:
+		err = -EINVAL;
+		goto errout;
+	}
+
+	tbl = dn_fib_get_table(rule->table, 0);
+	if (tbl == NULL)
+		goto errout;
+
+	err = tbl->lookup(tbl, flp, (struct dn_fib_res *)arg->result);
+	if (err > 0)
+		err = -EAGAIN;
+errout:
+	return err;
 }
 
+static struct nla_policy dn_fib_rule_policy[FRA_MAX+1] __read_mostly = {
+	[FRA_IFNAME]	= { .type = NLA_STRING },
+	[FRA_PRIORITY]	= { .type = NLA_U32 },
+	[FRA_SRC]	= { .type = NLA_U16 },
+	[FRA_DST]	= { .type = NLA_U16 },
+	[FRA_FWMARK]	= { .type = NLA_U32 },
+};
 
-int dn_fib_rtm_newrule(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static int dn_fib_rule_match(struct fib_rule *rule, struct flowi *fl, int flags)
 {
-	struct rtattr **rta = arg;
-	struct rtmsg *rtm = NLMSG_DATA(nlh);
-	struct dn_fib_rule *r, *new_r, *last = NULL;
-	struct hlist_node *node = NULL;
-	unsigned char table_id;
-
-	if (rtm->rtm_src_len > 16 || rtm->rtm_dst_len > 16)
-		return -EINVAL;
-
-	if (rta[RTA_IIF-1] && RTA_PAYLOAD(rta[RTA_IIF-1]) > IFNAMSIZ)
-		return -EINVAL;
-
-	if (rtm->rtm_type == RTN_NAT)
-		return -EINVAL;
-
-	table_id = rtm->rtm_table;
-	if (table_id == RT_TABLE_UNSPEC) {
-		struct dn_fib_table *tb;
-		if (rtm->rtm_type == RTN_UNICAST) {
-			if ((tb = dn_fib_empty_table()) == NULL)
-				return -ENOBUFS;
-			table_id = tb->n;
-		}
-	}
+	struct dn_fib_rule *r = (struct dn_fib_rule *)rule;
+	u16 daddr = fl->fld_dst;
+	u16 saddr = fl->fld_src;
+
+	if (((saddr ^ r->src) & r->srcmask) ||
+	    ((daddr ^ r->dst) & r->dstmask))
+		return 0;
 
-	new_r = kzalloc(sizeof(*new_r), GFP_KERNEL);
-	if (!new_r)
-		return -ENOMEM;
-
-	if (rta[RTA_SRC-1])
-		memcpy(&new_r->r_src, RTA_DATA(rta[RTA_SRC-1]), 2);
-	if (rta[RTA_DST-1])
-		memcpy(&new_r->r_dst, RTA_DATA(rta[RTA_DST-1]), 2);
-	if (rta[RTA_GATEWAY-1])
-		memcpy(&new_r->r_srcmap, RTA_DATA(rta[RTA_GATEWAY-1]), 2);
-	new_r->r_src_len = rtm->rtm_src_len;
-	new_r->r_dst_len = rtm->rtm_dst_len;
-	new_r->r_srcmask = dnet_make_mask(rtm->rtm_src_len);
-	new_r->r_dstmask = dnet_make_mask(rtm->rtm_dst_len);
 #ifdef CONFIG_DECNET_ROUTE_FWMARK
-	if (rta[RTA_PROTOINFO-1])
-		memcpy(&new_r->r_fwmark, RTA_DATA(rta[RTA_PROTOINFO-1]), 4);
+	if (r->fwmark && (r->fwmark != fl->fld_fwmark))
+		return 0;
 #endif
-	new_r->r_action = rtm->rtm_type;
-	new_r->r_flags = rtm->rtm_flags;
-	if (rta[RTA_PRIORITY-1])
-		memcpy(&new_r->r_preference, RTA_DATA(rta[RTA_PRIORITY-1]), 4);
-	new_r->r_table = table_id;
-	if (rta[RTA_IIF-1]) {
-		struct net_device *dev;
-		rtattr_strlcpy(new_r->r_ifname, rta[RTA_IIF-1], IFNAMSIZ);
-		new_r->r_ifindex = -1;
-		dev = dev_get_by_name(new_r->r_ifname);
-		if (dev) {
-			new_r->r_ifindex = dev->ifindex;
-			dev_put(dev);
-		}
-	}
 
-	r = container_of(dn_fib_rules.first, struct dn_fib_rule, r_hlist);
-	if (!new_r->r_preference) {
-		if (r && r->r_hlist.next != NULL) {
-			r = container_of(r->r_hlist.next, struct dn_fib_rule, r_hlist);
-			if (r->r_preference)
-				new_r->r_preference = r->r_preference - 1;
+	return 1;
+}
+
+static int dn_fib_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
+				 struct nlmsghdr *nlh, struct fib_rule_hdr *frh,
+				 struct nlattr **tb)
+{
+	int err = -EINVAL;
+	struct dn_fib_rule *r = (struct dn_fib_rule *)rule;
+
+	if (frh->src_len > 16 || frh->dst_len > 16 || frh->tos)
+		goto  errout;
+
+	if (rule->table == RT_TABLE_UNSPEC) {
+		if (rule->action == FR_ACT_TO_TBL) {
+			struct dn_fib_table *table;
+
+			table = dn_fib_empty_table();
+			if (table == NULL) {
+				err = -ENOBUFS;
+				goto errout;
+			}
+
+			rule->table = table->n;
 		}
 	}
 
-	hlist_for_each_entry(r, node, &dn_fib_rules, r_hlist) {
-		if (r->r_preference > new_r->r_preference)
-			break;
-		last = r;
-	}
-	atomic_inc(&new_r->r_clntref);
+	if (tb[FRA_SRC])
+		r->src = nla_get_u16(tb[FRA_SRC]);
 
-	if (last)
-		hlist_add_after_rcu(&last->r_hlist, &new_r->r_hlist);
-	else
-		hlist_add_before_rcu(&new_r->r_hlist, &r->r_hlist);
-	return 0;
-}
+	if (tb[FRA_DST])
+		r->dst = nla_get_u16(tb[FRA_DST]);
+
+#ifdef CONFIG_DECNET_ROUTE_FWMARK
+	if (tb[FRA_FWMARK])
+		r->fwmark = nla_get_u32(tb[FRA_FWMARK]);
+#endif
 
+	r->src_len = frh->src_len;
+	r->srcmask = dnet_make_mask(r->src_len);
+	r->dst_len = frh->dst_len;
+	r->dstmask = dnet_make_mask(r->dst_len);
+	err = 0;
+errout:
+	return err;
+}
 
-int dn_fib_lookup(const struct flowi *flp, struct dn_fib_res *res)
+static int dn_fib_rule_compare(struct fib_rule *rule, struct fib_rule_hdr *frh,
+			       struct nlattr **tb)
 {
-	struct dn_fib_rule *r, *policy;
-	struct dn_fib_table *tb;
-	__le16 saddr = flp->fld_src;
-	__le16 daddr = flp->fld_dst;
-	struct hlist_node *node;
-	int err;
+	struct dn_fib_rule *r = (struct dn_fib_rule *)rule;
+
+	if (frh->src_len && (r->src_len != frh->src_len))
+		return 0;
 
-	rcu_read_lock();
+	if (frh->dst_len && (r->dst_len != frh->dst_len))
+		return 0;
 
-	hlist_for_each_entry_rcu(r, node, &dn_fib_rules, r_hlist) {
-		if (((saddr^r->r_src) & r->r_srcmask) ||
-		    ((daddr^r->r_dst) & r->r_dstmask) ||
 #ifdef CONFIG_DECNET_ROUTE_FWMARK
-		    (r->r_fwmark && r->r_fwmark != flp->fld_fwmark) ||
+	if (tb[FRA_FWMARK] && (r->fwmark != nla_get_u32(tb[FRA_FWMARK])))
+		return 0;
 #endif
-		    (r->r_ifindex && r->r_ifindex != flp->iif))
-			continue;
 
-		switch(r->r_action) {
-			case RTN_UNICAST:
-			case RTN_NAT:
-				policy = r;
-				break;
-			case RTN_UNREACHABLE:
-				rcu_read_unlock();
-				return -ENETUNREACH;
-			default:
-			case RTN_BLACKHOLE:
-				rcu_read_unlock();
-				return -EINVAL;
-			case RTN_PROHIBIT:
-				rcu_read_unlock();
-				return -EACCES;
-		}
+	if (tb[FRA_SRC] && (r->src != nla_get_u32(tb[FRA_SRC])))
+		return 0;
 
-		if ((tb = dn_fib_get_table(r->r_table, 0)) == NULL)
-			continue;
-		err = tb->lookup(tb, flp, res);
-		if (err == 0) {
-			res->r = policy;
-			if (policy)
-				atomic_inc(&policy->r_clntref);
-			rcu_read_unlock();
-			return 0;
-		}
-		if (err < 0 && err != -EAGAIN) {
-			rcu_read_unlock();
-			return err;
-		}
-	}
+	if (tb[FRA_DST] && (r->dst != nla_get_u32(tb[FRA_DST])))
+		return 0;
 
-	rcu_read_unlock();
-	return -ESRCH;
+	return 1;
 }
 
 unsigned dnet_addr_type(__le16 addr)
@@ -284,142 +223,77 @@ unsigned dnet_addr_type(__le16 addr)
 	return ret;
 }
 
-__le16 dn_fib_rules_policy(__le16 saddr, struct dn_fib_res *res, unsigned *flags)
+static int dn_fib_rule_fill(struct fib_rule *rule, struct sk_buff *skb,
+			    struct nlmsghdr *nlh, struct fib_rule_hdr *frh)
 {
-	struct dn_fib_rule *r = res->r;
+	struct dn_fib_rule *r = (struct dn_fib_rule *)rule;
 
-	if (r->r_action == RTN_NAT) {
-		int addrtype = dnet_addr_type(r->r_srcmap);
+	frh->family = AF_DECnet;
+	frh->dst_len = r->dst_len;
+	frh->src_len = r->src_len;
+	frh->tos = 0;
 
-		if (addrtype == RTN_NAT) {
-			saddr = (saddr&~r->r_srcmask)|r->r_srcmap;
-			*flags |= RTCF_SNAT;
-		} else if (addrtype == RTN_LOCAL || r->r_srcmap == 0) {
-			saddr = r->r_srcmap;
-			*flags |= RTCF_MASQ;
-		}
-	}
-	return saddr;
-}
-
-static void dn_fib_rules_detach(struct net_device *dev)
-{
-	struct hlist_node *node;
-	struct dn_fib_rule *r;
-
-	hlist_for_each_entry(r, node, &dn_fib_rules, r_hlist) {
-		if (r->r_ifindex == dev->ifindex)
-			r->r_ifindex = -1;
-	}
-}
+#ifdef CONFIG_DECNET_ROUTE_FWMARK
+	if (r->fwmark)
+		NLA_PUT_U32(skb, FRA_FWMARK, r->fwmark);
+#endif
+	if (r->dst_len)
+		NLA_PUT_U16(skb, FRA_DST, r->dst);
+	if (r->src_len)
+		NLA_PUT_U16(skb, FRA_SRC, r->src);
 
-static void dn_fib_rules_attach(struct net_device *dev)
-{
-	struct hlist_node *node;
-	struct dn_fib_rule *r;
+	return 0;
 
-	hlist_for_each_entry(r, node, &dn_fib_rules, r_hlist) {
-		if (r->r_ifindex == -1 && strcmp(dev->name, r->r_ifname) == 0)
-			r->r_ifindex = dev->ifindex;
-	}
+nla_put_failure:
+	return -ENOBUFS;
 }
 
-static int dn_fib_rules_event(struct notifier_block *this, unsigned long event, void *ptr)
+static u32 dn_fib_rule_default_pref(void)
 {
-	struct net_device *dev = ptr;
+	struct list_head *pos;
+	struct fib_rule *rule;
 
-	switch(event) {
-		case NETDEV_UNREGISTER:
-			dn_fib_rules_detach(dev);
-			dn_fib_sync_down(0, dev, 1);
-		case NETDEV_REGISTER:
-			dn_fib_rules_attach(dev);
-			dn_fib_sync_up(dev);
+	if (!list_empty(&dn_fib_rules)) {
+		pos = dn_fib_rules.next;
+		if (pos->next != &dn_fib_rules) {
+			rule = list_entry(pos->next, struct fib_rule, list);
+			if (rule->pref)
+				return rule->pref - 1;
+		}
 	}
 
-	return NOTIFY_DONE;
-}
-
-
-static struct notifier_block dn_fib_rules_notifier = {
-	.notifier_call =	dn_fib_rules_event,
-};
-
-static int dn_fib_fill_rule(struct sk_buff *skb, struct dn_fib_rule *r,
-			    struct netlink_callback *cb, unsigned int flags)
-{
-	struct rtmsg *rtm;
-	struct nlmsghdr *nlh;
-	unsigned char *b = skb->tail;
-
-
-	nlh = NLMSG_NEW_ANSWER(skb, cb, RTM_NEWRULE, sizeof(*rtm), flags);
-	rtm = NLMSG_DATA(nlh);
-	rtm->rtm_family = AF_DECnet;
-	rtm->rtm_dst_len = r->r_dst_len;
-	rtm->rtm_src_len = r->r_src_len;
-	rtm->rtm_tos = 0;
-#ifdef CONFIG_DECNET_ROUTE_FWMARK
-	if (r->r_fwmark)
-		RTA_PUT(skb, RTA_PROTOINFO, 4, &r->r_fwmark);
-#endif
-	rtm->rtm_table = r->r_table;
-	rtm->rtm_protocol = 0;
-	rtm->rtm_scope = 0;
-	rtm->rtm_type = r->r_action;
-	rtm->rtm_flags = r->r_flags;
-
-	if (r->r_dst_len)
-		RTA_PUT(skb, RTA_DST, 2, &r->r_dst);
-	if (r->r_src_len)
-		RTA_PUT(skb, RTA_SRC, 2, &r->r_src);
-	if (r->r_ifname[0])
-		RTA_PUT(skb, RTA_IIF, IFNAMSIZ, &r->r_ifname);
-	if (r->r_preference)
-		RTA_PUT(skb, RTA_PRIORITY, 4, &r->r_preference);
-	if (r->r_srcmap)
-		RTA_PUT(skb, RTA_GATEWAY, 2, &r->r_srcmap);
-	nlh->nlmsg_len = skb->tail - b;
-	return skb->len;
-
-nlmsg_failure:
-rtattr_failure:
-	skb_trim(skb, b - skb->data);
-	return -1;
+	return 0;
 }
 
 int dn_fib_dump_rules(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	int idx = 0;
-	int s_idx = cb->args[0];
-	struct dn_fib_rule *r;
-	struct hlist_node *node;
-
-	rcu_read_lock();
-	hlist_for_each_entry(r, node, &dn_fib_rules, r_hlist) {
-		if (idx < s_idx)
-			goto next;
-		if (dn_fib_fill_rule(skb, r, cb, NLM_F_MULTI) < 0)
-			break;
-next:
-		idx++;
-	}
-	rcu_read_unlock();
-	cb->args[0] = idx;
-
-	return skb->len;
+	return fib_rules_dump(skb, cb, AF_DECnet);
 }
 
+static struct fib_rules_ops dn_fib_rules_ops = {
+	.family		= AF_DECnet,
+	.rule_size	= sizeof(struct dn_fib_rule),
+	.action		= dn_fib_rule_action,
+	.match		= dn_fib_rule_match,
+	.configure	= dn_fib_rule_configure,
+	.compare	= dn_fib_rule_compare,
+	.fill		= dn_fib_rule_fill,
+	.default_pref	= dn_fib_rule_default_pref,
+	.nlgroup	= RTNLGRP_DECnet_RULE,
+	.policy		= dn_fib_rule_policy,
+	.rules_list	= &dn_fib_rules,
+	.owner		= THIS_MODULE,
+};
+
 void __init dn_fib_rules_init(void)
 {
-	INIT_HLIST_HEAD(&dn_fib_rules);
-	hlist_add_head(&default_rule.r_hlist, &dn_fib_rules);
-	register_netdevice_notifier(&dn_fib_rules_notifier);
+	list_add_tail(&default_rule.common.list, &dn_fib_rules);
+	fib_rules_register(&dn_fib_rules_ops);
 }
 
 void __exit dn_fib_rules_cleanup(void)
 {
-	unregister_netdevice_notifier(&dn_fib_rules_notifier);
+	fib_rules_unregister(&dn_fib_rules_ops);
 }
 
 
diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
index e926c95..2e01b67 100644
--- a/net/decnet/dn_table.c
+++ b/net/decnet/dn_table.c
@@ -30,6 +30,7 @@
 #include <net/neighbour.h>
 #include <net/dst.h>
 #include <net/flow.h>
+#include <net/fib_rules.h>
 #include <net/dn.h>
 #include <net/dn_route.h>
 #include <net/dn_fib.h>
-- 
1.2.2

