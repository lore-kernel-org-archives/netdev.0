From: kaber@trash.net
Subject: [PATCH 46/84] netfilter: xtables: slightly better error reporting
Date: Mon, 10 May 2010 22:18:17 +0200
Message-ID: <1273522735-24672-47-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

When extended status codes are available, such as ENOMEM on failed
allocations, or subsequent functions (e.g. nf_ct_get_l3proto), passing
them up to userspace seems like a good idea compared to just always
EINVAL.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/ipv4/netfilter/ipt_CLUSTERIP.c |   11 ++++++-----
 net/netfilter/xt_CONNSECMARK.c     |    8 +++++---
 net/netfilter/xt_CT.c              |   11 +++++++++--
 net/netfilter/xt_DSCP.c            |    2 +-
 net/netfilter/xt_HL.c              |    2 +-
 net/netfilter/xt_LED.c             |    4 ++--
 net/netfilter/xt_NFQUEUE.c         |    2 +-
 net/netfilter/xt_RATEEST.c         |    9 ++++++---
 net/netfilter/xt_SECMARK.c         |   16 +++++++++-------
 net/netfilter/xt_cluster.c         |    2 +-
 net/netfilter/xt_connbytes.c       |    6 ++++--
 net/netfilter/xt_connlimit.c       |    8 +++++---
 net/netfilter/xt_connmark.c        |   14 ++++++++++----
 net/netfilter/xt_conntrack.c       |    7 +++++--
 net/netfilter/xt_dscp.c            |    2 +-
 net/netfilter/xt_hashlimit.c       |   32 ++++++++++++++++++++------------
 net/netfilter/xt_helper.c          |    6 ++++--
 net/netfilter/xt_limit.c           |    4 ++--
 net/netfilter/xt_quota.c           |    2 +-
 net/netfilter/xt_rateest.c         |    2 ++
 net/netfilter/xt_recent.c          |    5 ++++-
 net/netfilter/xt_state.c           |    7 +++++--
 net/netfilter/xt_statistic.c       |    2 +-
 net/netfilter/xt_string.c          |    2 +-
 net/netfilter/xt_time.c            |    2 +-
 25 files changed, 107 insertions(+), 61 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 1302de2..1faf5fa 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -351,8 +351,8 @@ static int clusterip_tg_check(const struct xt_tgchk_param *par)
 {
 	struct ipt_clusterip_tgt_info *cipinfo = par->targinfo;
 	const struct ipt_entry *e = par->entryinfo;
-
 	struct clusterip_config *config;
+	int ret;
 
 	if (cipinfo->hash_mode != CLUSTERIP_HASHMODE_SIP &&
 	    cipinfo->hash_mode != CLUSTERIP_HASHMODE_SIP_SPT &&
@@ -387,7 +387,7 @@ static int clusterip_tg_check(const struct xt_tgchk_param *par)
 			if (!dev) {
 				pr_info("no such interface %s\n",
 					e->ip.iniface);
-				return -EINVAL;
+				return -ENOENT;
 			}
 
 			config = clusterip_config_init(cipinfo,
@@ -395,17 +395,18 @@ static int clusterip_tg_check(const struct xt_tgchk_param *par)
 			if (!config) {
 				pr_info("cannot allocate config\n");
 				dev_put(dev);
-				return -EINVAL;
+				return -ENOMEM;
 			}
 			dev_mc_add(config->dev,config->clustermac, ETH_ALEN, 0);
 		}
 	}
 	cipinfo->config = config;
 
-	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
+	ret = nf_ct_l3proto_try_module_get(par->family);
+	if (ret < 0) {
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
-		return -EINVAL;
+		return ret;
 	}
 
 	return 0;
diff --git a/net/netfilter/xt_CONNSECMARK.c b/net/netfilter/xt_CONNSECMARK.c
index 2287a82..105a62e 100644
--- a/net/netfilter/xt_CONNSECMARK.c
+++ b/net/netfilter/xt_CONNSECMARK.c
@@ -87,6 +87,7 @@ connsecmark_tg(struct sk_buff *skb, const struct xt_target_param *par)
 static int connsecmark_tg_check(const struct xt_tgchk_param *par)
 {
 	const struct xt_connsecmark_target_info *info = par->targinfo;
+	int ret;
 
 	if (strcmp(par->table, "mangle") != 0 &&
 	    strcmp(par->table, "security") != 0) {
@@ -102,13 +103,14 @@ static int connsecmark_tg_check(const struct xt_tgchk_param *par)
 
 	default:
 		pr_info("invalid mode: %hu\n", info->mode);
-		return false;
+		return -EINVAL;
 	}
 
-	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
+	ret = nf_ct_l3proto_try_module_get(par->family);
+	if (ret < 0) {
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
-		return -EINVAL;
+		return ret;
 	}
 	return 0;
 }
diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index ee566e2..65dd348 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -59,6 +59,7 @@ static int xt_ct_tg_check(const struct xt_tgchk_param *par)
 	struct nf_conntrack_tuple t;
 	struct nf_conn_help *help;
 	struct nf_conn *ct;
+	int ret = 0;
 	u8 proto;
 
 	if (info->flags & ~XT_CT_NOTRACK)
@@ -75,28 +76,34 @@ static int xt_ct_tg_check(const struct xt_tgchk_param *par)
 		goto err1;
 #endif
 
-	if (nf_ct_l3proto_try_module_get(par->family) < 0)
+	ret = nf_ct_l3proto_try_module_get(par->family);
+	if (ret < 0)
 		goto err1;
 
 	memset(&t, 0, sizeof(t));
 	ct = nf_conntrack_alloc(par->net, info->zone, &t, &t, GFP_KERNEL);
+	ret = PTR_ERR(ct);
 	if (IS_ERR(ct))
 		goto err2;
 
+	ret = 0;
 	if ((info->ct_events || info->exp_events) &&
 	    !nf_ct_ecache_ext_add(ct, info->ct_events, info->exp_events,
 				  GFP_KERNEL))
 		goto err3;
 
 	if (info->helper[0]) {
+		ret = -ENOENT;
 		proto = xt_ct_find_proto(par);
 		if (!proto)
 			goto err3;
 
+		ret = -ENOMEM;
 		help = nf_ct_helper_ext_add(ct, GFP_KERNEL);
 		if (help == NULL)
 			goto err3;
 
+		ret = -ENOENT;
 		help->helper = nf_conntrack_helper_try_module_get(info->helper,
 								  par->family,
 								  proto);
@@ -115,7 +122,7 @@ err3:
 err2:
 	nf_ct_l3proto_module_put(par->family);
 err1:
-	return -EINVAL;
+	return ret;
 }
 
 static void xt_ct_tg_destroy(const struct xt_tgdtor_param *par)
diff --git a/net/netfilter/xt_DSCP.c b/net/netfilter/xt_DSCP.c
index aa263b8..969634f 100644
--- a/net/netfilter/xt_DSCP.c
+++ b/net/netfilter/xt_DSCP.c
@@ -66,7 +66,7 @@ static int dscp_tg_check(const struct xt_tgchk_param *par)
 
 	if (info->dscp > XT_DSCP_MAX) {
 		pr_info("dscp %x out of range\n", info->dscp);
-		return -EINVAL;
+		return -EDOM;
 	}
 	return 0;
 }
diff --git a/net/netfilter/xt_HL.c b/net/netfilter/xt_HL.c
index 7a47383..77b99f7 100644
--- a/net/netfilter/xt_HL.c
+++ b/net/netfilter/xt_HL.c
@@ -107,7 +107,7 @@ static int ttl_tg_check(const struct xt_tgchk_param *par)
 
 	if (info->mode > IPT_TTL_MAXMODE) {
 		pr_info("TTL: invalid or unknown mode %u\n", info->mode);
-		return false;
+		return -EINVAL;
 	}
 	if (info->mode != IPT_TTL_SET && info->ttl == 0)
 		return -EINVAL;
diff --git a/net/netfilter/xt_LED.c b/net/netfilter/xt_LED.c
index 22b5b70..efcf56d 100644
--- a/net/netfilter/xt_LED.c
+++ b/net/netfilter/xt_LED.c
@@ -93,7 +93,7 @@ static int led_tg_check(const struct xt_tgchk_param *par)
 
 	ledinternal = kzalloc(sizeof(struct xt_led_info_internal), GFP_KERNEL);
 	if (!ledinternal)
-		return -EINVAL;
+		return -ENOMEM;
 
 	ledinternal->netfilter_led_trigger.name = ledinfo->id;
 
@@ -115,7 +115,7 @@ static int led_tg_check(const struct xt_tgchk_param *par)
 
 exit_alloc:
 	kfree(ledinternal);
-	return -EINVAL;
+	return err;
 }
 
 static void led_tg_destroy(const struct xt_tgdtor_param *par)
diff --git a/net/netfilter/xt_NFQUEUE.c b/net/netfilter/xt_NFQUEUE.c
index add1789..f9217cb 100644
--- a/net/netfilter/xt_NFQUEUE.c
+++ b/net/netfilter/xt_NFQUEUE.c
@@ -98,7 +98,7 @@ static int nfqueue_tg_v1_check(const struct xt_tgchk_param *par)
 	if (maxid > 0xffff) {
 		pr_err("NFQUEUE: number of queues (%u) out of range (got %u)\n",
 		       info->queues_total, maxid);
-		return -EINVAL;
+		return -ERANGE;
 	}
 	return 0;
 }
diff --git a/net/netfilter/xt_RATEEST.c b/net/netfilter/xt_RATEEST.c
index 7af5fba..40751c6 100644
--- a/net/netfilter/xt_RATEEST.c
+++ b/net/netfilter/xt_RATEEST.c
@@ -93,6 +93,7 @@ static int xt_rateest_tg_checkentry(const struct xt_tgchk_param *par)
 		struct nlattr		opt;
 		struct gnet_estimator	est;
 	} cfg;
+	int ret;
 
 	if (unlikely(!rnd_inited)) {
 		get_random_bytes(&jhash_rnd, sizeof(jhash_rnd));
@@ -115,6 +116,7 @@ static int xt_rateest_tg_checkentry(const struct xt_tgchk_param *par)
 		return 0;
 	}
 
+	ret = -ENOMEM;
 	est = kzalloc(sizeof(*est), GFP_KERNEL);
 	if (!est)
 		goto err1;
@@ -130,8 +132,9 @@ static int xt_rateest_tg_checkentry(const struct xt_tgchk_param *par)
 	cfg.est.interval	= info->interval;
 	cfg.est.ewma_log	= info->ewma_log;
 
-	if (gen_new_estimator(&est->bstats, &est->rstats, &est->lock,
-			      &cfg.opt) < 0)
+	ret = gen_new_estimator(&est->bstats, &est->rstats,
+				&est->lock, &cfg.opt);
+	if (ret < 0)
 		goto err2;
 
 	info->est = est;
@@ -141,7 +144,7 @@ static int xt_rateest_tg_checkentry(const struct xt_tgchk_param *par)
 err2:
 	kfree(est);
 err1:
-	return -EINVAL;
+	return ret;
 }
 
 static void xt_rateest_tg_destroy(const struct xt_tgdtor_param *par)
diff --git a/net/netfilter/xt_SECMARK.c b/net/netfilter/xt_SECMARK.c
index 39098fc..a91d4a7 100644
--- a/net/netfilter/xt_SECMARK.c
+++ b/net/netfilter/xt_SECMARK.c
@@ -50,7 +50,7 @@ secmark_tg(struct sk_buff *skb, const struct xt_target_param *par)
 	return XT_CONTINUE;
 }
 
-static bool checkentry_selinux(struct xt_secmark_target_info *info)
+static int checkentry_selinux(struct xt_secmark_target_info *info)
 {
 	int err;
 	struct xt_secmark_target_selinux_info *sel = &info->u.sel;
@@ -62,27 +62,28 @@ static bool checkentry_selinux(struct xt_secmark_target_info *info)
 		if (err == -EINVAL)
 			pr_info("invalid SELinux context \'%s\'\n",
 				sel->selctx);
-		return false;
+		return err;
 	}
 
 	if (!sel->selsid) {
 		pr_info("unable to map SELinux context \'%s\'\n", sel->selctx);
-		return false;
+		return -ENOENT;
 	}
 
 	err = selinux_secmark_relabel_packet_permission(sel->selsid);
 	if (err) {
 		pr_info("unable to obtain relabeling permission\n");
-		return false;
+		return err;
 	}
 
 	selinux_secmark_refcount_inc();
-	return true;
+	return 0;
 }
 
 static int secmark_tg_check(const struct xt_tgchk_param *par)
 {
 	struct xt_secmark_target_info *info = par->targinfo;
+	int err;
 
 	if (strcmp(par->table, "mangle") != 0 &&
 	    strcmp(par->table, "security") != 0) {
@@ -99,8 +100,9 @@ static int secmark_tg_check(const struct xt_tgchk_param *par)
 
 	switch (info->mode) {
 	case SECMARK_MODE_SEL:
-		if (!checkentry_selinux(info))
-			return -EINVAL;
+		err = checkentry_selinux(info);
+		if (err <= 0)
+			return err;
 		break;
 
 	default:
diff --git a/net/netfilter/xt_cluster.c b/net/netfilter/xt_cluster.c
index 30cb776..6c941e1 100644
--- a/net/netfilter/xt_cluster.c
+++ b/net/netfilter/xt_cluster.c
@@ -145,7 +145,7 @@ static int xt_cluster_mt_checkentry(const struct xt_mtchk_param *par)
 	if (info->node_mask >= (1ULL << info->total_nodes)) {
 		pr_info("this node mask cannot be "
 			"higher than the total number of nodes\n");
-		return -EINVAL;
+		return -EDOM;
 	}
 	return 0;
 }
diff --git a/net/netfilter/xt_connbytes.c b/net/netfilter/xt_connbytes.c
index bf8e286..2ff332e 100644
--- a/net/netfilter/xt_connbytes.c
+++ b/net/netfilter/xt_connbytes.c
@@ -96,6 +96,7 @@ connbytes_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 static int connbytes_mt_check(const struct xt_mtchk_param *par)
 {
 	const struct xt_connbytes_info *sinfo = par->matchinfo;
+	int ret;
 
 	if (sinfo->what != XT_CONNBYTES_PKTS &&
 	    sinfo->what != XT_CONNBYTES_BYTES &&
@@ -107,10 +108,11 @@ static int connbytes_mt_check(const struct xt_mtchk_param *par)
 	    sinfo->direction != XT_CONNBYTES_DIR_BOTH)
 		return -EINVAL;
 
-	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
+	ret = nf_ct_l3proto_try_module_get(par->family);
+	if (ret < 0) {
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
-		return -EINVAL;
+		return ret;
 	}
 
 	return 0;
diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index 68e89f0..370088e 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -220,22 +220,24 @@ static int connlimit_mt_check(const struct xt_mtchk_param *par)
 {
 	struct xt_connlimit_info *info = par->matchinfo;
 	unsigned int i;
+	int ret;
 
 	if (unlikely(!connlimit_rnd_inited)) {
 		get_random_bytes(&connlimit_rnd, sizeof(connlimit_rnd));
 		connlimit_rnd_inited = true;
 	}
-	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
+	ret = nf_ct_l3proto_try_module_get(par->family);
+	if (ret < 0) {
 		pr_info("cannot load conntrack support for "
 			"address family %u\n", par->family);
-		return -EINVAL;
+		return ret;
 	}
 
 	/* init private data */
 	info->data = kmalloc(sizeof(struct xt_connlimit_data), GFP_KERNEL);
 	if (info->data == NULL) {
 		nf_ct_l3proto_module_put(par->family);
-		return -EINVAL;
+		return -ENOMEM;
 	}
 
 	spin_lock_init(&info->data->lock);
diff --git a/net/netfilter/xt_connmark.c b/net/netfilter/xt_connmark.c
index e137af5..71e38a1 100644
--- a/net/netfilter/xt_connmark.c
+++ b/net/netfilter/xt_connmark.c
@@ -76,10 +76,13 @@ connmark_tg(struct sk_buff *skb, const struct xt_target_param *par)
 
 static int connmark_tg_check(const struct xt_tgchk_param *par)
 {
-	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
+	int ret;
+
+	ret = nf_ct_l3proto_try_module_get(par->family);
+	if (ret < 0) {
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
-		return -EINVAL;
+		return ret;
 	}
 	return 0;
 }
@@ -105,10 +108,13 @@ connmark_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 
 static int connmark_mt_check(const struct xt_mtchk_param *par)
 {
-	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
+	int ret;
+
+	ret = nf_ct_l3proto_try_module_get(par->family);
+	if (ret < 0) {
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
-		return -EINVAL;
+		return ret;
 	}
 	return 0;
 }
diff --git a/net/netfilter/xt_conntrack.c b/net/netfilter/xt_conntrack.c
index 26e34aa..e0bcf8d 100644
--- a/net/netfilter/xt_conntrack.c
+++ b/net/netfilter/xt_conntrack.c
@@ -208,10 +208,13 @@ conntrack_mt_v2(const struct sk_buff *skb, const struct xt_match_param *par)
 
 static int conntrack_mt_check(const struct xt_mtchk_param *par)
 {
-	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
+	int ret;
+
+	ret = nf_ct_l3proto_try_module_get(par->family);
+	if (ret < 0) {
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
-		return -EINVAL;
+		return ret;
 	}
 	return 0;
 }
diff --git a/net/netfilter/xt_dscp.c b/net/netfilter/xt_dscp.c
index f355fb9..9db51fd 100644
--- a/net/netfilter/xt_dscp.c
+++ b/net/netfilter/xt_dscp.c
@@ -48,7 +48,7 @@ static int dscp_mt_check(const struct xt_mtchk_param *par)
 
 	if (info->dscp > XT_DSCP_MAX) {
 		pr_info("dscp %x out of range\n", info->dscp);
-		return -EINVAL;
+		return -EDOM;
 	}
 
 	return 0;
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 0c01529..c89fde7 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -214,7 +214,7 @@ static int htable_create_v0(struct net *net, struct xt_hashlimit_info *minfo, u_
 	hinfo = vmalloc(sizeof(struct xt_hashlimit_htable) +
 			sizeof(struct list_head) * size);
 	if (!hinfo)
-		return -1;
+		return -ENOMEM;
 	minfo->hinfo = hinfo;
 
 	/* copy match config into hashtable config */
@@ -250,7 +250,7 @@ static int htable_create_v0(struct net *net, struct xt_hashlimit_info *minfo, u_
 		&dl_file_ops, hinfo);
 	if (!hinfo->pde) {
 		vfree(hinfo);
-		return -1;
+		return -ENOMEM;
 	}
 	hinfo->net = net;
 
@@ -285,7 +285,7 @@ static int htable_create(struct net *net, struct xt_hashlimit_mtinfo1 *minfo,
 	hinfo = vmalloc(sizeof(struct xt_hashlimit_htable) +
 	                sizeof(struct list_head) * size);
 	if (hinfo == NULL)
-		return -1;
+		return -ENOMEM;
 	minfo->hinfo = hinfo;
 
 	/* copy match config into hashtable config */
@@ -311,7 +311,7 @@ static int htable_create(struct net *net, struct xt_hashlimit_mtinfo1 *minfo,
 		&dl_file_ops, hinfo);
 	if (hinfo->pde == NULL) {
 		vfree(hinfo);
-		return -1;
+		return -ENOMEM;
 	}
 	hinfo->net = net;
 
@@ -675,13 +675,14 @@ static int hashlimit_mt_check_v0(const struct xt_mtchk_param *par)
 {
 	struct net *net = par->net;
 	struct xt_hashlimit_info *r = par->matchinfo;
+	int ret;
 
 	/* Check for overflow. */
 	if (r->cfg.burst == 0 ||
 	    user2credits(r->cfg.avg * r->cfg.burst) < user2credits(r->cfg.avg)) {
 		pr_info("overflow, try lower: %u/%u\n",
 			r->cfg.avg, r->cfg.burst);
-		return -EINVAL;
+		return -ERANGE;
 	}
 	if (r->cfg.mode == 0 ||
 	    r->cfg.mode > (XT_HASHLIMIT_HASH_DPT |
@@ -698,9 +699,12 @@ static int hashlimit_mt_check_v0(const struct xt_mtchk_param *par)
 
 	mutex_lock(&hashlimit_mutex);
 	r->hinfo = htable_find_get(net, r->name, par->family);
-	if (!r->hinfo && htable_create_v0(net, r, par->family) != 0) {
-		mutex_unlock(&hashlimit_mutex);
-		return -EINVAL;
+	if (r->hinfo == NULL) {
+		ret = htable_create_v0(net, r, par->family);
+		if (ret < 0) {
+			mutex_unlock(&hashlimit_mutex);
+			return ret;
+		}
 	}
 	mutex_unlock(&hashlimit_mutex);
 	return 0;
@@ -710,6 +714,7 @@ static int hashlimit_mt_check(const struct xt_mtchk_param *par)
 {
 	struct net *net = par->net;
 	struct xt_hashlimit_mtinfo1 *info = par->matchinfo;
+	int ret;
 
 	/* Check for overflow. */
 	if (info->cfg.burst == 0 ||
@@ -717,7 +722,7 @@ static int hashlimit_mt_check(const struct xt_mtchk_param *par)
 	    user2credits(info->cfg.avg)) {
 		pr_info("overflow, try lower: %u/%u\n",
 			info->cfg.avg, info->cfg.burst);
-		return -EINVAL;
+		return -ERANGE;
 	}
 	if (info->cfg.gc_interval == 0 || info->cfg.expire == 0)
 		return -EINVAL;
@@ -733,9 +738,12 @@ static int hashlimit_mt_check(const struct xt_mtchk_param *par)
 
 	mutex_lock(&hashlimit_mutex);
 	info->hinfo = htable_find_get(net, info->name, par->family);
-	if (!info->hinfo && htable_create(net, info, par->family) != 0) {
-		mutex_unlock(&hashlimit_mutex);
-		return -EINVAL;
+	if (info->hinfo == NULL) {
+		ret = htable_create(net, info, par->family);
+		if (ret < 0) {
+			mutex_unlock(&hashlimit_mutex);
+			return ret;
+		}
 	}
 	mutex_unlock(&hashlimit_mutex);
 	return 0;
diff --git a/net/netfilter/xt_helper.c b/net/netfilter/xt_helper.c
index eb308b3..b8b3e13 100644
--- a/net/netfilter/xt_helper.c
+++ b/net/netfilter/xt_helper.c
@@ -57,11 +57,13 @@ helper_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 static int helper_mt_check(const struct xt_mtchk_param *par)
 {
 	struct xt_helper_info *info = par->matchinfo;
+	int ret;
 
-	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
+	ret = nf_ct_l3proto_try_module_get(par->family);
+	if (ret < 0) {
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
-		return -EINVAL;
+		return ret;
 	}
 	info->name[29] = '\0';
 	return 0;
diff --git a/net/netfilter/xt_limit.c b/net/netfilter/xt_limit.c
index 5ff0580..e2a284e 100644
--- a/net/netfilter/xt_limit.c
+++ b/net/netfilter/xt_limit.c
@@ -107,12 +107,12 @@ static int limit_mt_check(const struct xt_mtchk_param *par)
 	    || user2credits(r->avg * r->burst) < user2credits(r->avg)) {
 		pr_info("Overflow, try lower: %u/%u\n",
 			r->avg, r->burst);
-		return -EINVAL;
+		return -ERANGE;
 	}
 
 	priv = kmalloc(sizeof(*priv), GFP_KERNEL);
 	if (priv == NULL)
-		return -EINVAL;
+		return -ENOMEM;
 
 	/* For SMP, we only want to use one set of state. */
 	r->master = priv;
diff --git a/net/netfilter/xt_quota.c b/net/netfilter/xt_quota.c
index 766e71c..3e5cbd8 100644
--- a/net/netfilter/xt_quota.c
+++ b/net/netfilter/xt_quota.c
@@ -52,7 +52,7 @@ static int quota_mt_check(const struct xt_mtchk_param *par)
 
 	q->master = kmalloc(sizeof(*q->master), GFP_KERNEL);
 	if (q->master == NULL)
-		return -EINVAL;
+		return -ENOMEM;
 
 	q->master->quota = q->quota;
 	return 0;
diff --git a/net/netfilter/xt_rateest.c b/net/netfilter/xt_rateest.c
index 0b5c612..23805f8 100644
--- a/net/netfilter/xt_rateest.c
+++ b/net/netfilter/xt_rateest.c
@@ -78,6 +78,7 @@ static int xt_rateest_mt_checkentry(const struct xt_mtchk_param *par)
 {
 	struct xt_rateest_match_info *info = par->matchinfo;
 	struct xt_rateest *est1, *est2;
+	int ret = false;
 
 	if (hweight32(info->flags & (XT_RATEEST_MATCH_ABS |
 				     XT_RATEEST_MATCH_REL)) != 1)
@@ -95,6 +96,7 @@ static int xt_rateest_mt_checkentry(const struct xt_mtchk_param *par)
 		goto err1;
 	}
 
+	ret  = -ENOENT;
 	est1 = xt_rateest_lookup(info->name1);
 	if (!est1)
 		goto err1;
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 0994ff5..0d9f80b 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -355,8 +355,10 @@ static int recent_mt_check(const struct xt_mtchk_param *par)
 
 	t = kzalloc(sizeof(*t) + sizeof(t->iphash[0]) * ip_list_hash_size,
 		    GFP_KERNEL);
-	if (t == NULL)
+	if (t == NULL) {
+		ret = -ENOMEM;
 		goto out;
+	}
 	t->refcnt = 1;
 	strcpy(t->name, info->name);
 	INIT_LIST_HEAD(&t->lru_list);
@@ -367,6 +369,7 @@ static int recent_mt_check(const struct xt_mtchk_param *par)
 		  &recent_mt_fops, t);
 	if (pde == NULL) {
 		kfree(t);
+		ret = -ENOMEM;
 		goto out;
 	}
 	pde->uid = ip_list_uid;
diff --git a/net/netfilter/xt_state.c b/net/netfilter/xt_state.c
index 8e8c9df..2b75230 100644
--- a/net/netfilter/xt_state.c
+++ b/net/netfilter/xt_state.c
@@ -39,10 +39,13 @@ state_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 
 static int state_mt_check(const struct xt_mtchk_param *par)
 {
-	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
+	int ret;
+
+	ret = nf_ct_l3proto_try_module_get(par->family);
+	if (ret < 0) {
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
-		return -EINVAL;
+		return ret;
 	}
 	return 0;
 }
diff --git a/net/netfilter/xt_statistic.c b/net/netfilter/xt_statistic.c
index 29d76f8..8ed2b29 100644
--- a/net/netfilter/xt_statistic.c
+++ b/net/netfilter/xt_statistic.c
@@ -62,7 +62,7 @@ static int statistic_mt_check(const struct xt_mtchk_param *par)
 
 	info->master = kzalloc(sizeof(*info->master), GFP_KERNEL);
 	if (info->master == NULL)
-		return -EINVAL;
+		return -ENOMEM;
 	info->master->count = info->u.nth.count;
 
 	return 0;
diff --git a/net/netfilter/xt_string.c b/net/netfilter/xt_string.c
index e1f22a7..b0f8292 100644
--- a/net/netfilter/xt_string.c
+++ b/net/netfilter/xt_string.c
@@ -63,7 +63,7 @@ static int string_mt_check(const struct xt_mtchk_param *par)
 	ts_conf = textsearch_prepare(conf->algo, conf->pattern, conf->patlen,
 				     GFP_KERNEL, flags);
 	if (IS_ERR(ts_conf))
-		return -EINVAL;
+		return PTR_ERR(ts_conf);
 
 	conf->config = ts_conf;
 	return 0;
diff --git a/net/netfilter/xt_time.c b/net/netfilter/xt_time.c
index 8dde5e5..d8556fd 100644
--- a/net/netfilter/xt_time.c
+++ b/net/netfilter/xt_time.c
@@ -225,7 +225,7 @@ static int time_mt_check(const struct xt_mtchk_param *par)
 	    info->daytime_stop > XT_TIME_MAX_DAYTIME) {
 		pr_info("invalid argument - start or "
 			"stop time greater than 23:59:59\n");
-		return -EINVAL;
+		return -EDOM;
 	}
 
 	return 0;
-- 
1.7.0.4

