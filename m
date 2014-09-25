From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/4] xfrm: configure policy hash table thresholds by netlink
Date: Thu, 25 Sep 2014 11:10:24 +0200
Message-ID: <1411636225-4433-4-git-send-email-steffen.klassert@secunet.com>
References: <1411636225-4433-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:54395 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753005AbaIYJKr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2014 05:10:47 -0400
In-Reply-To: <1411636225-4433-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christophe Gouault <christophe.gouault@6wind.com>

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

The current thresholds can be read via a XFRM_MSG_GETSPDINFO request:
the kernel replies to XFRM_MSG_GETSPDINFO requests by an
XFRM_MSG_NEWSPDINFO message, with both attributes
XFRMA_SPD_IPV4_HTHRESH and XFRMA_SPD_IPV6_HTHRESH.

Signed-off-by: Christophe Gouault <christophe.gouault@6wind.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/netns/xfrm.h  | 10 ++++++
 include/net/xfrm.h        |  1 +
 include/uapi/linux/xfrm.h |  7 ++++
 net/xfrm/xfrm_policy.c    | 87 +++++++++++++++++++++++++++++++++++++++++++++++
 net/xfrm/xfrm_user.c      | 80 +++++++++++++++++++++++++++++++++++++++++--
 5 files changed, 182 insertions(+), 3 deletions(-)

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
index e6ff7b4..55bcb86 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -566,6 +566,86 @@ static void xfrm_hash_resize(struct work_struct *work)
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
+			hlist_add_behind(&policy->bydst, newpos);
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
@@ -2872,9 +2952,16 @@ static int __net_init xfrm_policy_init(struct net *net)
 		htab->dbits6 = 128;
 		htab->sbits6 = 128;
 	}
+	net->xfrm.policy_hthresh.lbits4 = 32;
+	net->xfrm.policy_hthresh.rbits4 = 32;
+	net->xfrm.policy_hthresh.lbits6 = 128;
+	net->xfrm.policy_hthresh.rbits6 = 128;
+
+	seqlock_init(&net->xfrm.policy_hthresh.lock);
 
 	INIT_LIST_HEAD(&net->xfrm.policy_all);
 	INIT_WORK(&net->xfrm.policy_hash_work, xfrm_hash_resize);
+	INIT_WORK(&net->xfrm.policy_hthresh.work, xfrm_hash_rebuild);
 	if (net_eq(net, &init_net))
 		register_netdevice_notifier(&xfrm_dev_notifier);
 	return 0;
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index d4db6eb..eaf8a8f 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -964,7 +964,9 @@ static inline size_t xfrm_spdinfo_msgsize(void)
 {
 	return NLMSG_ALIGN(4)
 	       + nla_total_size(sizeof(struct xfrmu_spdinfo))
-	       + nla_total_size(sizeof(struct xfrmu_spdhinfo));
+	       + nla_total_size(sizeof(struct xfrmu_spdhinfo))
+	       + nla_total_size(sizeof(struct xfrmu_spdhthresh))
+	       + nla_total_size(sizeof(struct xfrmu_spdhthresh));
 }
 
 static int build_spdinfo(struct sk_buff *skb, struct net *net,
@@ -973,9 +975,11 @@ static int build_spdinfo(struct sk_buff *skb, struct net *net,
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
@@ -993,9 +997,22 @@ static int build_spdinfo(struct sk_buff *skb, struct net *net,
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
@@ -1004,6 +1021,51 @@ static int build_spdinfo(struct sk_buff *skb, struct net *net,
 	return nlmsg_end(skb, nlh);
 }
 
+static int xfrm_set_spdinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
+			    struct nlattr **attrs)
+{
+	struct net *net = sock_net(skb->sk);
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
+	return 0;
+}
+
 static int xfrm_get_spdinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
 		struct nlattr **attrs)
 {
@@ -2274,6 +2336,7 @@ static const int xfrm_msg_min[XFRM_NR_MSGTYPES] = {
 	[XFRM_MSG_REPORT      - XFRM_MSG_BASE] = XMSGSIZE(xfrm_user_report),
 	[XFRM_MSG_MIGRATE     - XFRM_MSG_BASE] = XMSGSIZE(xfrm_userpolicy_id),
 	[XFRM_MSG_GETSADINFO  - XFRM_MSG_BASE] = sizeof(u32),
+	[XFRM_MSG_NEWSPDINFO  - XFRM_MSG_BASE] = sizeof(u32),
 	[XFRM_MSG_GETSPDINFO  - XFRM_MSG_BASE] = sizeof(u32),
 };
 
@@ -2308,10 +2371,17 @@ static const struct nla_policy xfrma_policy[XFRMA_MAX+1] = {
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
@@ -2335,6 +2405,9 @@ static const struct xfrm_link {
 	[XFRM_MSG_GETAE       - XFRM_MSG_BASE] = { .doit = xfrm_get_ae  },
 	[XFRM_MSG_MIGRATE     - XFRM_MSG_BASE] = { .doit = xfrm_do_migrate    },
 	[XFRM_MSG_GETSADINFO  - XFRM_MSG_BASE] = { .doit = xfrm_get_sadinfo   },
+	[XFRM_MSG_NEWSPDINFO  - XFRM_MSG_BASE] = { .doit = xfrm_set_spdinfo,
+						   .nla_pol = xfrma_spd_policy,
+						   .nla_max = XFRMA_SPD_MAX },
 	[XFRM_MSG_GETSPDINFO  - XFRM_MSG_BASE] = { .doit = xfrm_get_spdinfo   },
 };
 
@@ -2371,8 +2444,9 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
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
