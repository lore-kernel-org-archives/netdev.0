From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: [PATCH net-next v2 2/2] xfrm: configure policy hash table thresholds by netlink
Date: Fri,  1 Aug 2014 11:12:28 +0200
Message-ID: <1406884348-12423-3-git-send-email-christophe.gouault@6wind.com>
References: <1399902325-1788-1-git-send-email-christophe.gouault@6wind.com>
 <1406884348-12423-1-git-send-email-christophe.gouault@6wind.com>
Cc: netdev@vger.kernel.org,
	Christophe Gouault <christophe.gouault@6wind.com>
To: "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:57675 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734AbaHAJNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 05:13:22 -0400
Received: by mail-wg0-f43.google.com with SMTP id l18so3936427wgh.2
        for <netdev@vger.kernel.org>; Fri, 01 Aug 2014 02:13:19 -0700 (PDT)
In-Reply-To: <1406884348-12423-1-git-send-email-christophe.gouault@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable to specify local and remote prefix length thresholds for the
policy hash table via a netlink XFRM_MSG_NEWSPDINFO message.

prefix length thresholds are specified by XFRMA_SPD_IPV4_HTHRESH and
XFRMA_SPD_IPV6_HTHRESH optional attributes (struct xfrmu_spdhthresh).

example:

    struct xfrmu_spdhthresh thresh4 = {
        .lbits = 0;
        .rbits = 24;
    };
    struct xfrmu_spdhthresh thresh6 = {
        .lbits = 0;
        .rbits = 56;
    };
    struct nlmsghdr *hdr;
    struct nl_msg *msg;

    msg = nlmsg_alloc();
    hdr = nlmsg_put(msg, NL_AUTO_PORT, NL_AUTO_SEQ, XFRMA_SPD_IPV4_HTHRESH, sizeof(__u32), NLM_F_REQUEST);
    nla_put(msg, XFRMA_SPD_IPV4_HTHRESH, sizeof(thresh4), &thresh4);
    nla_put(msg, XFRMA_SPD_IPV6_HTHRESH, sizeof(thresh6), &thresh6);
    nla_send_auto(sk, msg);

The numbers are the policy selector minimum prefix lengths to put a
policy in the hash table.

- lbits is the local threshold (source address for out policies,
  destination address for in and fwd policies).

- rbits is the remote threshold (destination address for out
  policies, source address for in and fwd policies).

The default values are:

XFRMA_SPD_IPV4_HTHRESH: 32 32
XFRMA_SPD_IPV6_HTHRESH: 128 128

Dynamic re-building of the SPD is performed when the thresholds values
are changed.

The kernel replies to XFRM_MSG_GETSPDINFO and XFRM_MSG_NEWSPDINFO
requests by an XFRM_MSG_NEWSPDINFO message, with both attributes
XFRMA_SPD_IPV4_HTHRESH and XFRMA_SPD_IPV6_HTHRESH.

Signed-off-by: Christophe Gouault <christophe.gouault@6wind.com>
---
v2:
- use netlink instead of /proc
---
 include/net/netns/xfrm.h  | 10 ++++++
 include/net/xfrm.h        |  1 +
 include/uapi/linux/xfrm.h |  7 ++++
 net/xfrm/xfrm_policy.c    | 90 ++++++++++++++++++++++++++++++++++++++++++++++
 net/xfrm/xfrm_user.c      | 91 +++++++++++++++++++++++++++++++++++++++++++++--
 5 files changed, 196 insertions(+), 3 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 41902a8..9da7982 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -19,6 +19,15 @@ struct xfrm_policy_hash {
 	u8			sbits6;
 };
 
+struct xfrm_policy_hthresh {
+	struct work_struct	work;
+	seqlock_t		lock;
+	u8			lbits4;
+	u8			rbits4;
+	u8			lbits6;
+	u8			rbits6;
+};
+
 struct netns_xfrm {
 	struct list_head	state_all;
 	/*
@@ -45,6 +54,7 @@ struct netns_xfrm {
 	struct xfrm_policy_hash	policy_bydst[XFRM_POLICY_MAX * 2];
 	unsigned int		policy_count[XFRM_POLICY_MAX * 2];
 	struct work_struct	policy_hash_work;
+	struct xfrm_policy_hthresh policy_hthresh;
 
 
 	struct sock		*nlsk;
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 721e9c3..dc4865e 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1591,6 +1591,7 @@ struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net, u32 mark,
 struct xfrm_policy *xfrm_policy_byid(struct net *net, u32 mark, u8, int dir,
 				     u32 id, int delete, int *err);
 int xfrm_policy_flush(struct net *net, u8 type, bool task_valid);
+void xfrm_policy_hash_rebuild(struct net *net);
 u32 xfrm_get_acqseq(void);
 int verify_spi_info(u8 proto, u32 min, u32 max);
 int xfrm_alloc_spi(struct xfrm_state *x, u32 minspi, u32 maxspi);
diff --git a/include/uapi/linux/xfrm.h b/include/uapi/linux/xfrm.h
index 25e5dd9..02d5125 100644
--- a/include/uapi/linux/xfrm.h
+++ b/include/uapi/linux/xfrm.h
@@ -328,6 +328,8 @@ enum xfrm_spdattr_type_t {
 	XFRMA_SPD_UNSPEC,
 	XFRMA_SPD_INFO,
 	XFRMA_SPD_HINFO,
+	XFRMA_SPD_IPV4_HTHRESH,
+	XFRMA_SPD_IPV6_HTHRESH,
 	__XFRMA_SPD_MAX
 
 #define XFRMA_SPD_MAX (__XFRMA_SPD_MAX - 1)
@@ -347,6 +349,11 @@ struct xfrmu_spdhinfo {
 	__u32 spdhmcnt;
 };
 
+struct xfrmu_spdhthresh {
+	__u8 lbits;
+	__u8 rbits;
+};
+
 struct xfrm_usersa_info {
 	struct xfrm_selector		sel;
 	struct xfrm_id			id;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 312828c..c7d7a7e 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -13,6 +13,8 @@
  *
  */
 
+#define pr_fmt(fmt) "IPsec: " fmt
+
 #include <linux/err.h>
 #include <linux/slab.h>
 #include <linux/kmod.h>
@@ -566,6 +568,89 @@ static void xfrm_hash_resize(struct work_struct *work)
 	mutex_unlock(&hash_resize_mutex);
 }
 
+static void xfrm_hash_rebuild(struct work_struct *work)
+{
+	struct net *net = container_of(work, struct net,
+				       xfrm.policy_hthresh.work);
+	unsigned int hmask;
+	struct xfrm_policy *pol;
+	struct xfrm_policy *policy;
+	struct hlist_head *chain;
+	struct hlist_head *odst;
+	struct hlist_node *newpos;
+	int i;
+	int dir;
+	unsigned seq;
+	u8 lbits4, rbits4, lbits6, rbits6;
+
+	mutex_lock(&hash_resize_mutex);
+
+	/* read selector prefixlen thresholds */
+	do {
+		seq = read_seqbegin(&net->xfrm.policy_hthresh.lock);
+
+		lbits4 = net->xfrm.policy_hthresh.lbits4;
+		rbits4 = net->xfrm.policy_hthresh.rbits4;
+		lbits6 = net->xfrm.policy_hthresh.lbits6;
+		rbits6 = net->xfrm.policy_hthresh.rbits6;
+	} while (read_seqretry(&net->xfrm.policy_hthresh.lock, seq));
+
+	write_lock_bh(&net->xfrm.xfrm_policy_lock);
+
+	pr_info("rebuilding SPD hash table: thresholds (%u,%u)(%u,%u)\n",
+		lbits4, rbits4, lbits6, rbits6);
+
+	/* reset the bydst and inexact table in all directions */
+	for (dir = 0; dir < XFRM_POLICY_MAX * 2; dir++) {
+		INIT_HLIST_HEAD(&net->xfrm.policy_inexact[dir]);
+		hmask = net->xfrm.policy_bydst[dir].hmask;
+		odst = net->xfrm.policy_bydst[dir].table;
+		for (i = hmask; i >= 0; i--)
+			INIT_HLIST_HEAD(odst + i);
+		if ((dir & XFRM_POLICY_MASK) == XFRM_POLICY_OUT) {
+			/* dir out => dst = remote, src = local */
+			net->xfrm.policy_bydst[dir].dbits4 = rbits4;
+			net->xfrm.policy_bydst[dir].sbits4 = lbits4;
+			net->xfrm.policy_bydst[dir].dbits6 = rbits6;
+			net->xfrm.policy_bydst[dir].sbits6 = lbits6;
+		} else {
+			/* dir in/fwd => dst = local, src = remote */
+			net->xfrm.policy_bydst[dir].dbits4 = lbits4;
+			net->xfrm.policy_bydst[dir].sbits4 = rbits4;
+			net->xfrm.policy_bydst[dir].dbits6 = lbits6;
+			net->xfrm.policy_bydst[dir].sbits6 = rbits6;
+		}
+	}
+
+	/* re-insert all policies by order of creation */
+	list_for_each_entry_reverse(policy, &net->xfrm.policy_all, walk.all) {
+		newpos = NULL;
+		chain = policy_hash_bysel(net, &policy->selector,
+					  policy->family,
+					  xfrm_policy_id2dir(policy->index));
+		hlist_for_each_entry(pol, chain, bydst) {
+			if (policy->priority >= pol->priority)
+				newpos = &pol->bydst;
+			else
+				break;
+		}
+		if (newpos)
+			hlist_add_after(newpos, &policy->bydst);
+		else
+			hlist_add_head(&policy->bydst, chain);
+	}
+
+	write_unlock_bh(&net->xfrm.xfrm_policy_lock);
+
+	mutex_unlock(&hash_resize_mutex);
+}
+
+void xfrm_policy_hash_rebuild(struct net *net)
+{
+	schedule_work(&net->xfrm.policy_hthresh.work);
+}
+EXPORT_SYMBOL(xfrm_policy_hash_rebuild);
+
 /* Generate new index... KAME seems to generate them ordered by cost
  * of an absolute inpredictability of ordering of rules. This will not pass. */
 static u32 xfrm_gen_index(struct net *net, int dir, u32 index)
@@ -2870,9 +2955,14 @@ static int __net_init xfrm_policy_init(struct net *net)
 		htab->dbits6 = 128;
 		htab->sbits6 = 128;
 	}
+	net->xfrm.policy_hthresh.lbits4 = 32;
+	net->xfrm.policy_hthresh.rbits4 = 32;
+	net->xfrm.policy_hthresh.lbits6 = 128;
+	net->xfrm.policy_hthresh.rbits6 = 128;
 
 	INIT_LIST_HEAD(&net->xfrm.policy_all);
 	INIT_WORK(&net->xfrm.policy_hash_work, xfrm_hash_resize);
+	INIT_WORK(&net->xfrm.policy_hthresh.work, xfrm_hash_rebuild);
 	if (net_eq(net, &init_net))
 		register_netdevice_notifier(&xfrm_dev_notifier);
 	return 0;
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 412d9dc..a3549fa 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -965,7 +965,9 @@ static inline size_t xfrm_spdinfo_msgsize(void)
 {
 	return NLMSG_ALIGN(4)
 	       + nla_total_size(sizeof(struct xfrmu_spdinfo))
-	       + nla_total_size(sizeof(struct xfrmu_spdhinfo));
+	       + nla_total_size(sizeof(struct xfrmu_spdhinfo))
+	       + nla_total_size(sizeof(struct xfrmu_spdhthresh))
+	       + nla_total_size(sizeof(struct xfrmu_spdhthresh));
 }
 
 static int build_spdinfo(struct sk_buff *skb, struct net *net,
@@ -974,9 +976,11 @@ static int build_spdinfo(struct sk_buff *skb, struct net *net,
 	struct xfrmk_spdinfo si;
 	struct xfrmu_spdinfo spc;
 	struct xfrmu_spdhinfo sph;
+	struct xfrmu_spdhthresh spt4, spt6;
 	struct nlmsghdr *nlh;
 	int err;
 	u32 *f;
+	unsigned lseq;
 
 	nlh = nlmsg_put(skb, portid, seq, XFRM_MSG_NEWSPDINFO, sizeof(u32), 0);
 	if (nlh == NULL) /* shouldn't really happen ... */
@@ -994,9 +998,22 @@ static int build_spdinfo(struct sk_buff *skb, struct net *net,
 	sph.spdhcnt = si.spdhcnt;
 	sph.spdhmcnt = si.spdhmcnt;
 
+	do {
+		lseq = read_seqbegin(&net->xfrm.policy_hthresh.lock);
+
+		spt4.lbits = net->xfrm.policy_hthresh.lbits4;
+		spt4.rbits = net->xfrm.policy_hthresh.rbits4;
+		spt6.lbits = net->xfrm.policy_hthresh.lbits6;
+		spt6.rbits = net->xfrm.policy_hthresh.rbits6;
+	} while (read_seqretry(&net->xfrm.policy_hthresh.lock, lseq));
+
 	err = nla_put(skb, XFRMA_SPD_INFO, sizeof(spc), &spc);
 	if (!err)
 		err = nla_put(skb, XFRMA_SPD_HINFO, sizeof(sph), &sph);
+	if (!err)
+		err = nla_put(skb, XFRMA_SPD_IPV4_HTHRESH, sizeof(spt4), &spt4);
+	if (!err)
+		err = nla_put(skb, XFRMA_SPD_IPV6_HTHRESH, sizeof(spt6), &spt6);
 	if (err) {
 		nlmsg_cancel(skb, nlh);
 		return err;
@@ -1005,6 +1022,62 @@ static int build_spdinfo(struct sk_buff *skb, struct net *net,
 	return nlmsg_end(skb, nlh);
 }
 
+static int xfrm_set_spdinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
+			    struct nlattr **attrs)
+{
+	struct net *net = sock_net(skb->sk);
+	struct sk_buff *r_skb;
+	u32 *flags = nlmsg_data(nlh);
+	u32 sportid = NETLINK_CB(skb).portid;
+	u32 seq = nlh->nlmsg_seq;
+	struct xfrmu_spdhthresh *thresh4 = NULL;
+	struct xfrmu_spdhthresh *thresh6 = NULL;
+
+	/* selector prefixlen thresholds to hash policies */
+	if (attrs[XFRMA_SPD_IPV4_HTHRESH]) {
+		struct nlattr *rta = attrs[XFRMA_SPD_IPV4_HTHRESH];
+
+		if (nla_len(rta) < sizeof(*thresh4))
+			return -EINVAL;
+		thresh4 = nla_data(rta);
+		if (thresh4->lbits > 32 || thresh4->rbits > 32)
+			return -EINVAL;
+	}
+	if (attrs[XFRMA_SPD_IPV6_HTHRESH]) {
+		struct nlattr *rta = attrs[XFRMA_SPD_IPV6_HTHRESH];
+
+		if (nla_len(rta) < sizeof(*thresh6))
+			return -EINVAL;
+		thresh6 = nla_data(rta);
+		if (thresh6->lbits > 128 || thresh6->rbits > 128)
+			return -EINVAL;
+	}
+
+	if (thresh4 || thresh6) {
+		write_seqlock(&net->xfrm.policy_hthresh.lock);
+		if (thresh4) {
+			net->xfrm.policy_hthresh.lbits4 = thresh4->lbits;
+			net->xfrm.policy_hthresh.rbits4 = thresh4->rbits;
+		}
+		if (thresh6) {
+			net->xfrm.policy_hthresh.lbits6 = thresh6->lbits;
+			net->xfrm.policy_hthresh.rbits6 = thresh6->rbits;
+		}
+		write_sequnlock(&net->xfrm.policy_hthresh.lock);
+
+		xfrm_policy_hash_rebuild(net);
+	}
+
+	r_skb = nlmsg_new(xfrm_spdinfo_msgsize(), GFP_ATOMIC);
+	if (r_skb == NULL)
+		return -ENOMEM;
+
+	if (build_spdinfo(r_skb, net, sportid, seq, *flags) < 0)
+		BUG();
+
+	return nlmsg_unicast(net->xfrm.nlsk, r_skb, sportid);
+}
+
 static int xfrm_get_spdinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
 		struct nlattr **attrs)
 {
@@ -2275,6 +2348,7 @@ static const int xfrm_msg_min[XFRM_NR_MSGTYPES] = {
 	[XFRM_MSG_REPORT      - XFRM_MSG_BASE] = XMSGSIZE(xfrm_user_report),
 	[XFRM_MSG_MIGRATE     - XFRM_MSG_BASE] = XMSGSIZE(xfrm_userpolicy_id),
 	[XFRM_MSG_GETSADINFO  - XFRM_MSG_BASE] = sizeof(u32),
+	[XFRM_MSG_NEWSPDINFO  - XFRM_MSG_BASE] = sizeof(u32),
 	[XFRM_MSG_GETSPDINFO  - XFRM_MSG_BASE] = sizeof(u32),
 };
 
@@ -2309,10 +2383,17 @@ static const struct nla_policy xfrma_policy[XFRMA_MAX+1] = {
 	[XFRMA_ADDRESS_FILTER]	= { .len = sizeof(struct xfrm_address_filter) },
 };
 
+static const struct nla_policy xfrma_spd_policy[XFRMA_SPD_MAX+1] = {
+	[XFRMA_SPD_IPV4_HTHRESH] = { .len = sizeof(struct xfrmu_spdhthresh) },
+	[XFRMA_SPD_IPV6_HTHRESH] = { .len = sizeof(struct xfrmu_spdhthresh) },
+};
+
 static const struct xfrm_link {
 	int (*doit)(struct sk_buff *, struct nlmsghdr *, struct nlattr **);
 	int (*dump)(struct sk_buff *, struct netlink_callback *);
 	int (*done)(struct netlink_callback *);
+	const struct nla_policy *nla_pol;
+	int nla_max;
 } xfrm_dispatch[XFRM_NR_MSGTYPES] = {
 	[XFRM_MSG_NEWSA       - XFRM_MSG_BASE] = { .doit = xfrm_add_sa        },
 	[XFRM_MSG_DELSA       - XFRM_MSG_BASE] = { .doit = xfrm_del_sa        },
@@ -2336,6 +2417,9 @@ static const struct xfrm_link {
 	[XFRM_MSG_GETAE       - XFRM_MSG_BASE] = { .doit = xfrm_get_ae  },
 	[XFRM_MSG_MIGRATE     - XFRM_MSG_BASE] = { .doit = xfrm_do_migrate    },
 	[XFRM_MSG_GETSADINFO  - XFRM_MSG_BASE] = { .doit = xfrm_get_sadinfo   },
+	[XFRM_MSG_NEWSPDINFO  - XFRM_MSG_BASE] = { .doit = xfrm_set_spdinfo,
+						   .nla_pol = xfrma_spd_policy,
+						   .nla_max = XFRMA_SPD_MAX },
 	[XFRM_MSG_GETSPDINFO  - XFRM_MSG_BASE] = { .doit = xfrm_get_spdinfo   },
 };
 
@@ -2372,8 +2456,9 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		}
 	}
 
-	err = nlmsg_parse(nlh, xfrm_msg_min[type], attrs, XFRMA_MAX,
-			  xfrma_policy);
+	err = nlmsg_parse(nlh, xfrm_msg_min[type], attrs,
+			  link->nla_max ? : XFRMA_MAX,
+			  link->nla_pol ? : xfrma_policy);
 	if (err < 0)
 		return err;
 
-- 
1.9.1
