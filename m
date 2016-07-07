From: Vishwanath Pai <vpai@akamai.com>
Subject: [PATCH v2 2/2] netfilter: Create revision 2 of xt_hashlimit to
 support higher pps rates
Date: Thu, 7 Jul 2016 19:33:12 -0400
Message-ID: <20160707233312.GB5026@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johunt@akamai.com, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	pai.vishwain@gmail.com
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179]:12795 "EHLO
	prod-mail-xrelay05.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753044AbcGGXdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 19:33:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removed the call to BUG() in cfg_copy, we return -EINVAL
instead and all calls to cfg_copy check for this

--

netfilter: Create revision 2 of xt_hashlimit to support higher pps rates

Create a new revision for the hashlimit iptables extension module. Rev 2
will support higher pps of upto 1 million, Version 1 supports only 10k.

To support this we have to increase the size of the variables avg and
burst in hashlimit_cfg to 64-bit. Create two new structs hashlimit_cfg2
and xt_hashlimit_mtinfo2 and also create newer versions of all the
functions for match, checkentry and destroy.

Some of the functions like hashlimit_mt, hashlimit_mt_check etc are very
similar in both rev1 and rev2 with only minor changes, so I have split
those functions and moved all the common code to a *_common function.

Signed-off-by: Vishwanath Pai <vpai@akamai.com>
Signed-off-by: Joshua Hunt <johunt@akamai.com>
---
 include/uapi/linux/netfilter/xt_hashlimit.h |  23 ++
 net/netfilter/xt_hashlimit.c                | 330 ++++++++++++++++++++++------
 2 files changed, 285 insertions(+), 68 deletions(-)

diff --git a/include/uapi/linux/netfilter/xt_hashlimit.h b/include/uapi/linux/netfilter/xt_hashlimit.h
index ea8c1c0..be5d2e1 100644
--- a/include/uapi/linux/netfilter/xt_hashlimit.h
+++ b/include/uapi/linux/netfilter/xt_hashlimit.h
@@ -6,6 +6,7 @@
 
 /* timings are in milliseconds. */
 #define XT_HASHLIMIT_SCALE_v1 10000
+#define XT_HASHLIMIT_SCALE 1000000llu
 /* 1/10,000 sec period => max of 10,000/sec.  Min rate is then 429490
  * seconds, or one packet every 59 hours.
  */
@@ -63,6 +64,20 @@ struct hashlimit_cfg1 {
 	__u8 srcmask, dstmask;
 };
 
+struct hashlimit_cfg2 {
+	__u32 mode;	  /* bitmask of XT_HASHLIMIT_HASH_* */
+	__u64 avg;    /* Average secs between packets * scale */
+	__u64 burst;  /* Period multiplier for upper limit. */
+
+	/* user specified */
+	__u32 size;		/* how many buckets */
+	__u32 max;		/* max number of entries */
+	__u32 gc_interval;	/* gc interval */
+	__u32 expire;	/* when do entries expire? */
+
+	__u8 srcmask, dstmask;
+};
+
 struct xt_hashlimit_mtinfo1 {
 	char name[IFNAMSIZ];
 	struct hashlimit_cfg1 cfg;
@@ -71,4 +86,12 @@ struct xt_hashlimit_mtinfo1 {
 	struct xt_hashlimit_htable *hinfo __attribute__((aligned(8)));
 };
 
+struct xt_hashlimit_mtinfo2 {
+	char name[NAME_MAX];
+	struct hashlimit_cfg2 cfg;
+
+	/* Used internally by the kernel */
+	struct xt_hashlimit_htable *hinfo __attribute__((aligned(8)));
+};
+
 #endif /* _UAPI_XT_HASHLIMIT_H */
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 6b0ad93..69d317c 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -57,6 +57,7 @@ static inline struct hashlimit_net *hashlimit_pernet(struct net *net)
 
 /* need to declare this at the top */
 static const struct file_operations dl_file_ops_v1;
+static const struct file_operations dl_file_ops;
 
 /* hash table crap */
 struct dsthash_dst {
@@ -86,8 +87,8 @@ struct dsthash_ent {
 	unsigned long expires;		/* precalculated expiry time */
 	struct {
 		unsigned long prev;	/* last modification */
-		u_int32_t credit;
-		u_int32_t credit_cap, cost;
+		u_int64_t credit;
+		u_int64_t credit_cap, cost;
 	} rateinfo;
 	struct rcu_head rcu;
 };
@@ -98,7 +99,7 @@ struct xt_hashlimit_htable {
 	u_int8_t family;
 	bool rnd_initialized;
 
-	struct hashlimit_cfg1 cfg;	/* config */
+	struct hashlimit_cfg2 cfg;	/* config */
 
 	/* used internally */
 	spinlock_t lock;		/* lock for list_head */
@@ -114,6 +115,30 @@ struct xt_hashlimit_htable {
 	struct hlist_head hash[0];	/* hashtable itself */
 };
 
+static int
+cfg_copy(struct hashlimit_cfg2 *to, void *from, int revision)
+{
+	if (revision == 1) {
+		struct hashlimit_cfg1 *cfg = (struct hashlimit_cfg1 *)from;
+
+		to->mode = cfg->mode;
+		to->avg = cfg->avg;
+		to->burst = cfg->burst;
+		to->size = cfg->size;
+		to->max = cfg->max;
+		to->gc_interval = cfg->gc_interval;
+		to->expire = cfg->expire;
+		to->srcmask = cfg->srcmask;
+		to->dstmask = cfg->dstmask;
+	} else if (revision == 2) {
+		memcpy(to, from, sizeof(struct hashlimit_cfg2));
+	} else {
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
 static DEFINE_MUTEX(hashlimit_mutex);	/* protects htables list */
 static struct kmem_cache *hashlimit_cachep __read_mostly;
 
@@ -215,16 +240,18 @@ dsthash_free(struct xt_hashlimit_htable *ht, struct dsthash_ent *ent)
 }
 static void htable_gc(struct work_struct *work);
 
-static int htable_create_v1(struct net *net, struct xt_hashlimit_mtinfo1 *minfo,
-			    u_int8_t family)
+static int htable_create(struct net *net, struct hashlimit_cfg2 *cfg,
+			 const char *name, u_int8_t family,
+			 struct xt_hashlimit_htable **out_hinfo,
+			 int revision)
 {
 	struct hashlimit_net *hashlimit_net = hashlimit_pernet(net);
 	struct xt_hashlimit_htable *hinfo;
-	unsigned int size;
-	unsigned int i;
+	unsigned int size, i;
+	int ret;
 
-	if (minfo->cfg.size) {
-		size = minfo->cfg.size;
+	if (cfg->size) {
+		size = cfg->size;
 	} else {
 		size = (totalram_pages << PAGE_SHIFT) / 16384 /
 		       sizeof(struct list_head);
@@ -238,10 +265,14 @@ static int htable_create_v1(struct net *net, struct xt_hashlimit_mtinfo1 *minfo,
 	                sizeof(struct list_head) * size);
 	if (hinfo == NULL)
 		return -ENOMEM;
-	minfo->hinfo = hinfo;
+	*out_hinfo = hinfo;
 
 	/* copy match config into hashtable config */
-	memcpy(&hinfo->cfg, &minfo->cfg, sizeof(hinfo->cfg));
+	ret = cfg_copy(&hinfo->cfg, (void *)cfg, revision);
+
+	if (ret)
+		return ret;
+
 	hinfo->cfg.size = size;
 	if (hinfo->cfg.max == 0)
 		hinfo->cfg.max = 8 * hinfo->cfg.size;
@@ -255,17 +286,18 @@ static int htable_create_v1(struct net *net, struct xt_hashlimit_mtinfo1 *minfo,
 	hinfo->count = 0;
 	hinfo->family = family;
 	hinfo->rnd_initialized = false;
-	hinfo->name = kstrdup(minfo->name, GFP_KERNEL);
+	hinfo->name = kstrdup(name, GFP_KERNEL);
 	if (!hinfo->name) {
 		vfree(hinfo);
 		return -ENOMEM;
 	}
 	spin_lock_init(&hinfo->lock);
 
-	hinfo->pde = proc_create_data(minfo->name, 0,
+	hinfo->pde = proc_create_data(name, 0,
 		(family == NFPROTO_IPV4) ?
 		hashlimit_net->ipt_hashlimit : hashlimit_net->ip6t_hashlimit,
-		&dl_file_ops_v1, hinfo);
+		(revision == 1) ? &dl_file_ops_v1 : &dl_file_ops,
+		hinfo);
 	if (hinfo->pde == NULL) {
 		kfree(hinfo->name);
 		vfree(hinfo);
@@ -399,6 +431,7 @@ static void htable_put(struct xt_hashlimit_htable *hinfo)
    CREDITS_PER_JIFFY*HZ*60*60*24 < 2^32 ie.
 */
 #define MAX_CPJ_v1 (0xFFFFFFFF / (HZ*60*60*24))
+#define MAX_CPJ (0xFFFFFFFFFFFFFFFF / (HZ*60*60*24))
 
 /* Repeated shift and or gives us all 1s, final shift and add 1 gives
  * us the power of 2 below the theoretical max, so GCC simply does a
@@ -408,8 +441,11 @@ static void htable_put(struct xt_hashlimit_htable *hinfo)
 #define _POW2_BELOW8(x) (_POW2_BELOW4(x)|_POW2_BELOW4((x)>>4))
 #define _POW2_BELOW16(x) (_POW2_BELOW8(x)|_POW2_BELOW8((x)>>8))
 #define _POW2_BELOW32(x) (_POW2_BELOW16(x)|_POW2_BELOW16((x)>>16))
+#define _POW2_BELOW64(x) (_POW2_BELOW32(x)|_POW2_BELOW32((x)>>32))
 #define POW2_BELOW32(x) ((_POW2_BELOW32(x)>>1) + 1)
+#define POW2_BELOW64(x) ((_POW2_BELOW64(x)>>1) + 1)
 
+#define CREDITS_PER_JIFFY POW2_BELOW64(MAX_CPJ)
 #define CREDITS_PER_JIFFY_v1 POW2_BELOW32(MAX_CPJ_v1)
 
 /* in byte mode, the lowest possible rate is one packet/second.
@@ -425,15 +461,24 @@ static u32 xt_hashlimit_len_to_chunks(u32 len)
 }
 
 /* Precision saver. */
-static u32 user2credits(u32 user)
+static u64 user2credits(u64 user, int revision)
 {
-	/* If multiplying would overflow... */
-	if (user > 0xFFFFFFFF / (HZ*CREDITS_PER_JIFFY_v1))
-		/* Divide first. */
-		return (user / XT_HASHLIMIT_SCALE_v1) *\
-					HZ * CREDITS_PER_JIFFY_v1;
+	if (revision == 1) {
+		/* If multiplying would overflow... */
+		if (user > 0xFFFFFFFF / (HZ*CREDITS_PER_JIFFY_v1))
+			/* Divide first. */
+			return (user / XT_HASHLIMIT_SCALE_v1) *\
+						HZ * CREDITS_PER_JIFFY_v1;
+
+		return (user * HZ * CREDITS_PER_JIFFY_v1) \
+						/ XT_HASHLIMIT_SCALE_v1;
+	} else {
+		if (user > 0xFFFFFFFFFFFFFFFF / (HZ*CREDITS_PER_JIFFY))
+			return (user / XT_HASHLIMIT_SCALE) *\
+						HZ * CREDITS_PER_JIFFY;
 
-	return (user * HZ * CREDITS_PER_JIFFY_v1) / XT_HASHLIMIT_SCALE_v1;
+		return (user * HZ * CREDITS_PER_JIFFY) / XT_HASHLIMIT_SCALE;
+	}
 }
 
 static u32 user2credits_byte(u32 user)
@@ -443,10 +488,11 @@ static u32 user2credits_byte(u32 user)
 	return (u32) (us >> 32);
 }
 
-static void rateinfo_recalc(struct dsthash_ent *dh, unsigned long now, u32 mode)
+static void rateinfo_recalc(struct dsthash_ent *dh, unsigned long now,
+			    u32 mode, int revision)
 {
 	unsigned long delta = now - dh->rateinfo.prev;
-	u32 cap;
+	u64 cap, cpj;
 
 	if (delta == 0)
 		return;
@@ -454,7 +500,7 @@ static void rateinfo_recalc(struct dsthash_ent *dh, unsigned long now, u32 mode)
 	dh->rateinfo.prev = now;
 
 	if (mode & XT_HASHLIMIT_BYTES) {
-		u32 tmp = dh->rateinfo.credit;
+		u64 tmp = dh->rateinfo.credit;
 		dh->rateinfo.credit += CREDITS_PER_JIFFY_BYTES * delta;
 		cap = CREDITS_PER_JIFFY_BYTES * HZ;
 		if (tmp >= dh->rateinfo.credit) {/* overflow */
@@ -462,7 +508,9 @@ static void rateinfo_recalc(struct dsthash_ent *dh, unsigned long now, u32 mode)
 			return;
 		}
 	} else {
-		dh->rateinfo.credit += delta * CREDITS_PER_JIFFY_v1;
+		cpj = (revision == 1) ?
+			CREDITS_PER_JIFFY_v1 : CREDITS_PER_JIFFY;
+		dh->rateinfo.credit += delta * cpj;
 		cap = dh->rateinfo.credit_cap;
 	}
 	if (dh->rateinfo.credit > cap)
@@ -470,7 +518,7 @@ static void rateinfo_recalc(struct dsthash_ent *dh, unsigned long now, u32 mode)
 }
 
 static void rateinfo_init(struct dsthash_ent *dh,
-			  struct xt_hashlimit_htable *hinfo)
+			  struct xt_hashlimit_htable *hinfo, int revision)
 {
 	dh->rateinfo.prev = jiffies;
 	if (hinfo->cfg.mode & XT_HASHLIMIT_BYTES) {
@@ -479,8 +527,8 @@ static void rateinfo_init(struct dsthash_ent *dh,
 		dh->rateinfo.credit_cap = hinfo->cfg.burst;
 	} else {
 		dh->rateinfo.credit = user2credits(hinfo->cfg.avg *
-						   hinfo->cfg.burst);
-		dh->rateinfo.cost = user2credits(hinfo->cfg.avg);
+						   hinfo->cfg.burst, revision);
+		dh->rateinfo.cost = user2credits(hinfo->cfg.avg, revision);
 		dh->rateinfo.credit_cap = dh->rateinfo.credit;
 	}
 }
@@ -604,15 +652,15 @@ static u32 hashlimit_byte_cost(unsigned int len, struct dsthash_ent *dh)
 }
 
 static bool
-hashlimit_mt_v1(const struct sk_buff *skb, struct xt_action_param *par)
+hashlimit_mt_common(const struct sk_buff *skb, struct xt_action_param *par,
+		    struct xt_hashlimit_htable *hinfo,
+		    const struct hashlimit_cfg2 *cfg, int revision)
 {
-	const struct xt_hashlimit_mtinfo1 *info = par->matchinfo;
-	struct xt_hashlimit_htable *hinfo = info->hinfo;
 	unsigned long now = jiffies;
 	struct dsthash_ent *dh;
 	struct dsthash_dst dst;
 	bool race = false;
-	u32 cost;
+	u64 cost;
 
 	if (hashlimit_init_dst(hinfo, &dst, skb, par->thoff) < 0)
 		goto hotdrop;
@@ -627,18 +675,18 @@ hashlimit_mt_v1(const struct sk_buff *skb, struct xt_action_param *par)
 		} else if (race) {
 			/* Already got an entry, update expiration timeout */
 			dh->expires = now + msecs_to_jiffies(hinfo->cfg.expire);
-			rateinfo_recalc(dh, now, hinfo->cfg.mode);
+			rateinfo_recalc(dh, now, hinfo->cfg.mode, revision);
 		} else {
 			dh->expires = jiffies + msecs_to_jiffies(hinfo->cfg.expire);
-			rateinfo_init(dh, hinfo);
+			rateinfo_init(dh, hinfo, revision);
 		}
 	} else {
 		/* update expiration timeout */
 		dh->expires = now + msecs_to_jiffies(hinfo->cfg.expire);
-		rateinfo_recalc(dh, now, hinfo->cfg.mode);
+		rateinfo_recalc(dh, now, hinfo->cfg.mode, revision);
 	}
 
-	if (info->cfg.mode & XT_HASHLIMIT_BYTES)
+	if (cfg->mode & XT_HASHLIMIT_BYTES)
 		cost = hashlimit_byte_cost(skb->len, dh);
 	else
 		cost = dh->rateinfo.cost;
@@ -648,70 +696,126 @@ hashlimit_mt_v1(const struct sk_buff *skb, struct xt_action_param *par)
 		dh->rateinfo.credit -= cost;
 		spin_unlock(&dh->lock);
 		rcu_read_unlock_bh();
-		return !(info->cfg.mode & XT_HASHLIMIT_INVERT);
+		return !(cfg->mode & XT_HASHLIMIT_INVERT);
 	}
 
 	spin_unlock(&dh->lock);
 	rcu_read_unlock_bh();
 	/* default match is underlimit - so over the limit, we need to invert */
-	return info->cfg.mode & XT_HASHLIMIT_INVERT;
+	return cfg->mode & XT_HASHLIMIT_INVERT;
 
  hotdrop:
 	par->hotdrop = true;
 	return false;
 }
 
-static int hashlimit_mt_check_v1(const struct xt_mtchk_param *par)
+static bool
+hashlimit_mt_v1(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	const struct xt_hashlimit_mtinfo1 *info = par->matchinfo;
+	struct xt_hashlimit_htable *hinfo = info->hinfo;
+	struct hashlimit_cfg2 cfg = {};
+	int ret;
+
+	ret = cfg_copy(&cfg, (void *)&info->cfg, 1);
+
+	if (ret)
+		return ret;
+
+	return hashlimit_mt_common(skb, par, hinfo, &cfg, 1);
+}
+
+static bool
+hashlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	const struct xt_hashlimit_mtinfo2 *info = par->matchinfo;
+	struct xt_hashlimit_htable *hinfo = info->hinfo;
+
+	return hashlimit_mt_common(skb, par, hinfo, &info->cfg, 2);
+}
+
+static int hashlimit_mt_check_common(const struct xt_mtchk_param *par,
+				     struct xt_hashlimit_htable **hinfo,
+				     struct hashlimit_cfg2 *cfg,
+				     const char *name, int revision)
 {
 	struct net *net = par->net;
-	struct xt_hashlimit_mtinfo1 *info = par->matchinfo;
 	int ret;
 
-	if (info->cfg.gc_interval == 0 || info->cfg.expire == 0)
-		return -EINVAL;
-	if (info->name[sizeof(info->name)-1] != '\0')
+	if (cfg->gc_interval == 0 || cfg->expire == 0)
 		return -EINVAL;
 	if (par->family == NFPROTO_IPV4) {
-		if (info->cfg.srcmask > 32 || info->cfg.dstmask > 32)
+		if (cfg->srcmask > 32 || cfg->dstmask > 32)
 			return -EINVAL;
 	} else {
-		if (info->cfg.srcmask > 128 || info->cfg.dstmask > 128)
+		if (cfg->srcmask > 128 || cfg->dstmask > 128)
 			return -EINVAL;
 	}
 
-	if (info->cfg.mode & ~XT_HASHLIMIT_ALL) {
+	if (cfg->mode & ~XT_HASHLIMIT_ALL) {
 		pr_info("Unknown mode mask %X, kernel too old?\n",
-						info->cfg.mode);
+						cfg->mode);
 		return -EINVAL;
 	}
 
 	/* Check for overflow. */
-	if (info->cfg.mode & XT_HASHLIMIT_BYTES) {
-		if (user2credits_byte(info->cfg.avg) == 0) {
-			pr_info("overflow, rate too high: %u\n", info->cfg.avg);
+	if (cfg->mode & XT_HASHLIMIT_BYTES) {
+		if (user2credits_byte(cfg->avg) == 0) {
+			pr_info("overflow, rate too high: %llu\n", cfg->avg);
 			return -EINVAL;
 		}
-	} else if (info->cfg.burst == 0 ||
-		    user2credits(info->cfg.avg * info->cfg.burst) <
-		    user2credits(info->cfg.avg)) {
-			pr_info("overflow, try lower: %u/%u\n",
-				info->cfg.avg, info->cfg.burst);
+	} else if (cfg->burst == 0 ||
+		    user2credits(cfg->avg * cfg->burst, revision) <
+		    user2credits(cfg->avg, revision)) {
+			pr_info("overflow, try lower: %llu/%llu\n",
+				cfg->avg, cfg->burst);
 			return -ERANGE;
 	}
 
 	mutex_lock(&hashlimit_mutex);
-	info->hinfo = htable_find_get(net, info->name, par->family);
-	if (info->hinfo == NULL) {
-		ret = htable_create_v1(net, info, par->family);
+	*hinfo = htable_find_get(net, name, par->family);
+	if (*hinfo == NULL) {
+		ret = htable_create(net, cfg, name, par->family,
+				    hinfo, revision);
 		if (ret < 0) {
 			mutex_unlock(&hashlimit_mutex);
 			return ret;
 		}
 	}
 	mutex_unlock(&hashlimit_mutex);
+
 	return 0;
 }
 
+static int hashlimit_mt_check_v1(const struct xt_mtchk_param *par)
+{
+	struct xt_hashlimit_mtinfo1 *info = par->matchinfo;
+	struct hashlimit_cfg2 cfg = {};
+	int ret;
+
+	if (info->name[sizeof(info->name) - 1] != '\0')
+		return -EINVAL;
+
+	ret = cfg_copy(&cfg, (void *)&info->cfg, 1);
+
+	if (ret)
+		return ret;
+
+	return hashlimit_mt_check_common(par, &info->hinfo,
+					 &cfg, info->name, 1);
+}
+
+static int hashlimit_mt_check(const struct xt_mtchk_param *par)
+{
+	struct xt_hashlimit_mtinfo2 *info = par->matchinfo;
+
+	if (info->name[sizeof(info->name) - 1] != '\0')
+		return -EINVAL;
+
+	return hashlimit_mt_check_common(par, &info->hinfo, &info->cfg,
+					 info->name, 2);
+}
+
 static void hashlimit_mt_destroy_v1(const struct xt_mtdtor_param *par)
 {
 	const struct xt_hashlimit_mtinfo1 *info = par->matchinfo;
@@ -719,6 +823,13 @@ static void hashlimit_mt_destroy_v1(const struct xt_mtdtor_param *par)
 	htable_put(info->hinfo);
 }
 
+static void hashlimit_mt_destroy(const struct xt_mtdtor_param *par)
+{
+	const struct xt_hashlimit_mtinfo2 *info = par->matchinfo;
+
+	htable_put(info->hinfo);
+}
+
 static struct xt_match hashlimit_mt_reg[] __read_mostly = {
 	{
 		.name           = "hashlimit",
@@ -730,6 +841,16 @@ static struct xt_match hashlimit_mt_reg[] __read_mostly = {
 		.destroy        = hashlimit_mt_destroy_v1,
 		.me             = THIS_MODULE,
 	},
+	{
+		.name           = "hashlimit",
+		.revision       = 2,
+		.family         = NFPROTO_IPV4,
+		.match          = hashlimit_mt,
+		.matchsize      = sizeof(struct xt_hashlimit_mtinfo2),
+		.checkentry     = hashlimit_mt_check,
+		.destroy        = hashlimit_mt_destroy,
+		.me             = THIS_MODULE,
+	},
 #if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	{
 		.name           = "hashlimit",
@@ -741,6 +862,16 @@ static struct xt_match hashlimit_mt_reg[] __read_mostly = {
 		.destroy        = hashlimit_mt_destroy_v1,
 		.me             = THIS_MODULE,
 	},
+	{
+		.name           = "hashlimit",
+		.revision       = 2,
+		.family         = NFPROTO_IPV6,
+		.match          = hashlimit_mt,
+		.matchsize      = sizeof(struct xt_hashlimit_mtinfo2),
+		.checkentry     = hashlimit_mt_check,
+		.destroy        = hashlimit_mt_destroy,
+		.me             = THIS_MODULE,
+	},
 #endif
 };
 
@@ -787,18 +918,12 @@ static void dl_seq_stop(struct seq_file *s, void *v)
 	spin_unlock_bh(&htable->lock);
 }
 
-static int dl_seq_real_show_v1(struct dsthash_ent *ent, u_int8_t family,
-			       struct seq_file *s)
+static void dl_seq_print(struct dsthash_ent *ent, u_int8_t family,
+			 struct seq_file *s)
 {
-	const struct xt_hashlimit_htable *ht = s->private;
-
-	spin_lock(&ent->lock);
-	/* recalculate to show accurate numbers */
-	rateinfo_recalc(ent, jiffies, ht->cfg.mode);
-
 	switch (family) {
 	case NFPROTO_IPV4:
-		seq_printf(s, "%ld %pI4:%u->%pI4:%u %u %u %u\n",
+		seq_printf(s, "%ld %pI4:%u->%pI4:%u %llu %llu %llu\n",
 			   (long)(ent->expires - jiffies)/HZ,
 			   &ent->dst.ip.src,
 			   ntohs(ent->dst.src_port),
@@ -809,7 +934,7 @@ static int dl_seq_real_show_v1(struct dsthash_ent *ent, u_int8_t family,
 		break;
 #if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	case NFPROTO_IPV6:
-		seq_printf(s, "%ld %pI6:%u->%pI6:%u %u %u %u\n",
+		seq_printf(s, "%ld %pI6:%u->%pI6:%u %llu %llu %llu\n",
 			   (long)(ent->expires - jiffies)/HZ,
 			   &ent->dst.ip6.src,
 			   ntohs(ent->dst.src_port),
@@ -822,6 +947,34 @@ static int dl_seq_real_show_v1(struct dsthash_ent *ent, u_int8_t family,
 	default:
 		BUG();
 	}
+}
+
+static int dl_seq_real_show_v1(struct dsthash_ent *ent, u_int8_t family,
+			       struct seq_file *s)
+{
+	const struct xt_hashlimit_htable *ht = s->private;
+
+	spin_lock(&ent->lock);
+	/* recalculate to show accurate numbers */
+	rateinfo_recalc(ent, jiffies, ht->cfg.mode, 1);
+
+	dl_seq_print(ent, family, s);
+
+	spin_unlock(&ent->lock);
+	return seq_has_overflowed(s);
+}
+
+static int dl_seq_real_show(struct dsthash_ent *ent, u_int8_t family,
+			    struct seq_file *s)
+{
+	const struct xt_hashlimit_htable *ht = s->private;
+
+	spin_lock(&ent->lock);
+	/* recalculate to show accurate numbers */
+	rateinfo_recalc(ent, jiffies, ht->cfg.mode, 2);
+
+	dl_seq_print(ent, family, s);
+
 	spin_unlock(&ent->lock);
 	return seq_has_overflowed(s);
 }
@@ -840,6 +993,20 @@ static int dl_seq_show_v1(struct seq_file *s, void *v)
 	return 0;
 }
 
+static int dl_seq_show(struct seq_file *s, void *v)
+{
+	struct xt_hashlimit_htable *htable = s->private;
+	unsigned int *bucket = (unsigned int *)v;
+	struct dsthash_ent *ent;
+
+	if (!hlist_empty(&htable->hash[*bucket])) {
+		hlist_for_each_entry(ent, &htable->hash[*bucket], node)
+			if (dl_seq_real_show(ent, htable->family, s))
+				return -1;
+	}
+	return 0;
+}
+
 static const struct seq_operations dl_seq_ops_v1 = {
 	.start = dl_seq_start,
 	.next  = dl_seq_next,
@@ -847,6 +1014,13 @@ static const struct seq_operations dl_seq_ops_v1 = {
 	.show  = dl_seq_show_v1
 };
 
+static const struct seq_operations dl_seq_ops = {
+	.start = dl_seq_start,
+	.next  = dl_seq_next,
+	.stop  = dl_seq_stop,
+	.show  = dl_seq_show
+};
+
 static int dl_proc_open_v1(struct inode *inode, struct file *file)
 {
 	int ret = seq_open(file, &dl_seq_ops_v1);
@@ -858,6 +1032,18 @@ static int dl_proc_open_v1(struct inode *inode, struct file *file)
 	return ret;
 }
 
+static int dl_proc_open(struct inode *inode, struct file *file)
+{
+	int ret = seq_open(file, &dl_seq_ops);
+
+	if (!ret) {
+		struct seq_file *sf = file->private_data;
+
+		sf->private = PDE_DATA(inode);
+	}
+	return ret;
+}
+
 static const struct file_operations dl_file_ops_v1 = {
 	.owner   = THIS_MODULE,
 	.open    = dl_proc_open_v1,
@@ -866,6 +1052,14 @@ static const struct file_operations dl_file_ops_v1 = {
 	.release = seq_release
 };
 
+static const struct file_operations dl_file_ops = {
+	.owner   = THIS_MODULE,
+	.open    = dl_proc_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release
+};
+
 static int __net_init hashlimit_proc_net_init(struct net *net)
 {
 	struct hashlimit_net *hashlimit_net = hashlimit_pernet(net);
-- 
1.9.1
