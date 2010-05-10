From: kaber@trash.net
Subject: [PATCH 48/84] netfilter: xtables: remove xt_hashlimit revision 0
Date: Mon, 10 May 2010 22:18:19 +0200
Message-ID: <1273522735-24672-49-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

Superseded by xt_hashlimit revision 1 (linux v2.6.24-6212-g09e410d,
iptables 1.4.1-rc1).

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/netfilter/xt_hashlimit.c |  221 ------------------------------------------
 1 files changed, 0 insertions(+), 221 deletions(-)

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index c89fde7..5470bb0 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -193,76 +193,6 @@ dsthash_free(struct xt_hashlimit_htable *ht, struct dsthash_ent *ent)
 }
 static void htable_gc(unsigned long htlong);
 
-static int htable_create_v0(struct net *net, struct xt_hashlimit_info *minfo, u_int8_t family)
-{
-	struct hashlimit_net *hashlimit_net = hashlimit_pernet(net);
-	struct xt_hashlimit_htable *hinfo;
-	unsigned int size;
-	unsigned int i;
-
-	if (minfo->cfg.size)
-		size = minfo->cfg.size;
-	else {
-		size = ((totalram_pages << PAGE_SHIFT) / 16384) /
-		       sizeof(struct list_head);
-		if (totalram_pages > (1024 * 1024 * 1024 / PAGE_SIZE))
-			size = 8192;
-		if (size < 16)
-			size = 16;
-	}
-	/* FIXME: don't use vmalloc() here or anywhere else -HW */
-	hinfo = vmalloc(sizeof(struct xt_hashlimit_htable) +
-			sizeof(struct list_head) * size);
-	if (!hinfo)
-		return -ENOMEM;
-	minfo->hinfo = hinfo;
-
-	/* copy match config into hashtable config */
-	hinfo->cfg.mode        = minfo->cfg.mode;
-	hinfo->cfg.avg         = minfo->cfg.avg;
-	hinfo->cfg.burst       = minfo->cfg.burst;
-	hinfo->cfg.max         = minfo->cfg.max;
-	hinfo->cfg.gc_interval = minfo->cfg.gc_interval;
-	hinfo->cfg.expire      = minfo->cfg.expire;
-
-	if (family == NFPROTO_IPV4)
-		hinfo->cfg.srcmask = hinfo->cfg.dstmask = 32;
-	else
-		hinfo->cfg.srcmask = hinfo->cfg.dstmask = 128;
-
-	hinfo->cfg.size = size;
-	if (!hinfo->cfg.max)
-		hinfo->cfg.max = 8 * hinfo->cfg.size;
-	else if (hinfo->cfg.max < hinfo->cfg.size)
-		hinfo->cfg.max = hinfo->cfg.size;
-
-	for (i = 0; i < hinfo->cfg.size; i++)
-		INIT_HLIST_HEAD(&hinfo->hash[i]);
-
-	hinfo->use = 1;
-	hinfo->count = 0;
-	hinfo->family = family;
-	hinfo->rnd_initialized = false;
-	spin_lock_init(&hinfo->lock);
-	hinfo->pde = proc_create_data(minfo->name, 0,
-		(family == NFPROTO_IPV4) ?
-		hashlimit_net->ipt_hashlimit : hashlimit_net->ip6t_hashlimit,
-		&dl_file_ops, hinfo);
-	if (!hinfo->pde) {
-		vfree(hinfo);
-		return -ENOMEM;
-	}
-	hinfo->net = net;
-
-	setup_timer(&hinfo->timer, htable_gc, (unsigned long )hinfo);
-	hinfo->timer.expires = jiffies + msecs_to_jiffies(hinfo->cfg.gc_interval);
-	add_timer(&hinfo->timer);
-
-	hlist_add_head(&hinfo->node, &hashlimit_net->htables);
-
-	return 0;
-}
-
 static int htable_create(struct net *net, struct xt_hashlimit_mtinfo1 *minfo,
 			 u_int8_t family)
 {
@@ -571,57 +501,6 @@ hashlimit_init_dst(const struct xt_hashlimit_htable *hinfo,
 }
 
 static bool
-hashlimit_mt_v0(const struct sk_buff *skb, const struct xt_match_param *par)
-{
-	const struct xt_hashlimit_info *r = par->matchinfo;
-	struct xt_hashlimit_htable *hinfo = r->hinfo;
-	unsigned long now = jiffies;
-	struct dsthash_ent *dh;
-	struct dsthash_dst dst;
-
-	if (hashlimit_init_dst(hinfo, &dst, skb, par->thoff) < 0)
-		goto hotdrop;
-
-	spin_lock_bh(&hinfo->lock);
-	dh = dsthash_find(hinfo, &dst);
-	if (!dh) {
-		dh = dsthash_alloc_init(hinfo, &dst);
-		if (!dh) {
-			spin_unlock_bh(&hinfo->lock);
-			goto hotdrop;
-		}
-
-		dh->expires = jiffies + msecs_to_jiffies(hinfo->cfg.expire);
-		dh->rateinfo.prev = jiffies;
-		dh->rateinfo.credit = user2credits(hinfo->cfg.avg *
-						   hinfo->cfg.burst);
-		dh->rateinfo.credit_cap = user2credits(hinfo->cfg.avg *
-						       hinfo->cfg.burst);
-		dh->rateinfo.cost = user2credits(hinfo->cfg.avg);
-	} else {
-		/* update expiration timeout */
-		dh->expires = now + msecs_to_jiffies(hinfo->cfg.expire);
-		rateinfo_recalc(dh, now);
-	}
-
-	if (dh->rateinfo.credit >= dh->rateinfo.cost) {
-		/* We're underlimit. */
-		dh->rateinfo.credit -= dh->rateinfo.cost;
-		spin_unlock_bh(&hinfo->lock);
-		return true;
-	}
-
-	spin_unlock_bh(&hinfo->lock);
-
-	/* default case: we're overlimit, thus don't match */
-	return false;
-
-hotdrop:
-	*par->hotdrop = true;
-	return false;
-}
-
-static bool
 hashlimit_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 {
 	const struct xt_hashlimit_mtinfo1 *info = par->matchinfo;
@@ -671,45 +550,6 @@ hashlimit_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	return false;
 }
 
-static int hashlimit_mt_check_v0(const struct xt_mtchk_param *par)
-{
-	struct net *net = par->net;
-	struct xt_hashlimit_info *r = par->matchinfo;
-	int ret;
-
-	/* Check for overflow. */
-	if (r->cfg.burst == 0 ||
-	    user2credits(r->cfg.avg * r->cfg.burst) < user2credits(r->cfg.avg)) {
-		pr_info("overflow, try lower: %u/%u\n",
-			r->cfg.avg, r->cfg.burst);
-		return -ERANGE;
-	}
-	if (r->cfg.mode == 0 ||
-	    r->cfg.mode > (XT_HASHLIMIT_HASH_DPT |
-			   XT_HASHLIMIT_HASH_DIP |
-			   XT_HASHLIMIT_HASH_SIP |
-			   XT_HASHLIMIT_HASH_SPT))
-		return -EINVAL;
-	if (!r->cfg.gc_interval)
-		return -EINVAL;
-	if (!r->cfg.expire)
-		return -EINVAL;
-	if (r->name[sizeof(r->name) - 1] != '\0')
-		return -EINVAL;
-
-	mutex_lock(&hashlimit_mutex);
-	r->hinfo = htable_find_get(net, r->name, par->family);
-	if (r->hinfo == NULL) {
-		ret = htable_create_v0(net, r, par->family);
-		if (ret < 0) {
-			mutex_unlock(&hashlimit_mutex);
-			return ret;
-		}
-	}
-	mutex_unlock(&hashlimit_mutex);
-	return 0;
-}
-
 static int hashlimit_mt_check(const struct xt_mtchk_param *par)
 {
 	struct net *net = par->net;
@@ -749,14 +589,6 @@ static int hashlimit_mt_check(const struct xt_mtchk_param *par)
 	return 0;
 }
 
-static void
-hashlimit_mt_destroy_v0(const struct xt_mtdtor_param *par)
-{
-	const struct xt_hashlimit_info *r = par->matchinfo;
-
-	htable_put(r->hinfo);
-}
-
 static void hashlimit_mt_destroy(const struct xt_mtdtor_param *par)
 {
 	const struct xt_hashlimit_mtinfo1 *info = par->matchinfo;
@@ -764,47 +596,8 @@ static void hashlimit_mt_destroy(const struct xt_mtdtor_param *par)
 	htable_put(info->hinfo);
 }
 
-#ifdef CONFIG_COMPAT
-struct compat_xt_hashlimit_info {
-	char name[IFNAMSIZ];
-	struct hashlimit_cfg cfg;
-	compat_uptr_t hinfo;
-	compat_uptr_t master;
-};
-
-static void hashlimit_mt_compat_from_user(void *dst, const void *src)
-{
-	int off = offsetof(struct compat_xt_hashlimit_info, hinfo);
-
-	memcpy(dst, src, off);
-	memset(dst + off, 0, sizeof(struct compat_xt_hashlimit_info) - off);
-}
-
-static int hashlimit_mt_compat_to_user(void __user *dst, const void *src)
-{
-	int off = offsetof(struct compat_xt_hashlimit_info, hinfo);
-
-	return copy_to_user(dst, src, off) ? -EFAULT : 0;
-}
-#endif
-
 static struct xt_match hashlimit_mt_reg[] __read_mostly = {
 	{
-		.name		= "hashlimit",
-		.revision	= 0,
-		.family		= NFPROTO_IPV4,
-		.match		= hashlimit_mt_v0,
-		.matchsize	= sizeof(struct xt_hashlimit_info),
-#ifdef CONFIG_COMPAT
-		.compatsize	= sizeof(struct compat_xt_hashlimit_info),
-		.compat_from_user = hashlimit_mt_compat_from_user,
-		.compat_to_user	= hashlimit_mt_compat_to_user,
-#endif
-		.checkentry	= hashlimit_mt_check_v0,
-		.destroy	= hashlimit_mt_destroy_v0,
-		.me		= THIS_MODULE
-	},
-	{
 		.name           = "hashlimit",
 		.revision       = 1,
 		.family         = NFPROTO_IPV4,
@@ -816,20 +609,6 @@ static struct xt_match hashlimit_mt_reg[] __read_mostly = {
 	},
 #if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_MODULE)
 	{
-		.name		= "hashlimit",
-		.family		= NFPROTO_IPV6,
-		.match		= hashlimit_mt_v0,
-		.matchsize	= sizeof(struct xt_hashlimit_info),
-#ifdef CONFIG_COMPAT
-		.compatsize	= sizeof(struct compat_xt_hashlimit_info),
-		.compat_from_user = hashlimit_mt_compat_from_user,
-		.compat_to_user	= hashlimit_mt_compat_to_user,
-#endif
-		.checkentry	= hashlimit_mt_check_v0,
-		.destroy	= hashlimit_mt_destroy_v0,
-		.me		= THIS_MODULE
-	},
-	{
 		.name           = "hashlimit",
 		.revision       = 1,
 		.family         = NFPROTO_IPV6,
-- 
1.7.0.4

