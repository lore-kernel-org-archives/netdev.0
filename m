From: Vishwanath Pai <vpai@akamai.com>
Subject: [PATCH 1/2] netfilter/xt_hashlimit: new feature/algorithm for xt_hashlimit
Date: Fri, 18 Aug 2017 16:58:59 -0400
Message-ID: <1503089939-15938-1-git-send-email-vpai@akamai.com>
Cc: johunt@akamai.com, fw@strlen.de, netdev@vger.kernel.org,
        pai.vishwain@gmail.com
To: pablo@netfilter.org, kadlec@blackhole.kfki.hu,
        netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a new feature to hashlimit that allows matching on the
current packet/byte rate without rate limiting. This can be enabled
with a new flag --hashlimit-rate-match. The match returns true if the
current rate of packets is above/below the user specified value.

The main difference between the existing algorithm and the new one is
that the existing algorithm rate-limits the flow whereas the new
algorithm does not. Instead it *classifies* the flow based on whether
it is above or below a certain rate. I will demonstrate this with an
example below. Let us assume this rule:

iptables -A INPUT -m hashlimit --hashlimit-above 10/s -j new_chain

If the packet rate is 15/s, the existing algorithm would ACCEPT 10
packets every second and send 5 packets to "new_chain".

But with the new algorithm, as long as the rate of 15/s is sustained,
all packets will continue to match and every packet is sent to new_chain.

This new functionality will let us classify different flows based on
their current rate, so that further decisions can be made on them based on
what the current rate is.

This is how the new algorithm works:
We divide time into intervals of 1 (sec/min/hour) as specified by
the user. We keep track of the number of packets/bytes processed in the
current interval. After each interval we reset the counter to 0.

When we receive a packet for match, we look at the packet rate
during the current interval and the previous interval to make a
decision:

if [ prev_rate < user and cur_rate < user ]
        return Below
else
        return Above

Where cur_rate is the number of packets/bytes seen in the current
interval, prev is the number of packets/bytes seen in the previous
interval and 'user' is the rate specified by the user.

We also provide flexibility to the user for choosing the time
interval using the option --hashilmit-interval. For example the user can
keep a low rate like x/hour but still keep the interval as small as 1
second.

To preserve backwards compatibility we have to add this feature in a new
revision, so I've created revision 3 for hashlimit. The two new options
we add are:

--hashlimit-rate-match
--hashlimit-rate-interval

I have updated the help text to add these new options. Also added a few
tests for the new options.

Suggested-by: Igor Lubashev <ilubashe@akamai.com>
Reviewed-by: Josh Hunt <johunt@akamai.com>
Signed-off-by: Vishwanath Pai <vpai@akamai.com>
---
 include/linux/netfilter/xt_hashlimit.h      |   3 +-
 include/uapi/linux/netfilter/xt_hashlimit.h |  36 +++-
 net/netfilter/xt_hashlimit.c                | 275 +++++++++++++++++++++++++---
 3 files changed, 284 insertions(+), 30 deletions(-)

diff --git a/include/linux/netfilter/xt_hashlimit.h b/include/linux/netfilter/xt_hashlimit.h
index 074790c..0fc458b 100644
--- a/include/linux/netfilter/xt_hashlimit.h
+++ b/include/linux/netfilter/xt_hashlimit.h
@@ -5,5 +5,6 @@
 
 #define XT_HASHLIMIT_ALL (XT_HASHLIMIT_HASH_DIP | XT_HASHLIMIT_HASH_DPT | \
 			  XT_HASHLIMIT_HASH_SIP | XT_HASHLIMIT_HASH_SPT | \
-			  XT_HASHLIMIT_INVERT | XT_HASHLIMIT_BYTES)
+			  XT_HASHLIMIT_INVERT | XT_HASHLIMIT_BYTES |\
+			  XT_HASHLIMIT_RATE_MATCH)
 #endif /*_XT_HASHLIMIT_H*/
diff --git a/include/uapi/linux/netfilter/xt_hashlimit.h b/include/uapi/linux/netfilter/xt_hashlimit.h
index 79da349..aa98573 100644
--- a/include/uapi/linux/netfilter/xt_hashlimit.h
+++ b/include/uapi/linux/netfilter/xt_hashlimit.h
@@ -19,12 +19,13 @@
 struct xt_hashlimit_htable;
 
 enum {
-	XT_HASHLIMIT_HASH_DIP = 1 << 0,
-	XT_HASHLIMIT_HASH_DPT = 1 << 1,
-	XT_HASHLIMIT_HASH_SIP = 1 << 2,
-	XT_HASHLIMIT_HASH_SPT = 1 << 3,
-	XT_HASHLIMIT_INVERT   = 1 << 4,
-	XT_HASHLIMIT_BYTES    = 1 << 5,
+	XT_HASHLIMIT_HASH_DIP		= 1 << 0,
+	XT_HASHLIMIT_HASH_DPT		= 1 << 1,
+	XT_HASHLIMIT_HASH_SIP		= 1 << 2,
+	XT_HASHLIMIT_HASH_SPT		= 1 << 3,
+	XT_HASHLIMIT_INVERT		= 1 << 4,
+	XT_HASHLIMIT_BYTES		= 1 << 5,
+	XT_HASHLIMIT_RATE_MATCH		= 1 << 6,
 };
 
 struct hashlimit_cfg {
@@ -79,6 +80,21 @@ struct hashlimit_cfg2 {
 	__u8 srcmask, dstmask;
 };
 
+struct hashlimit_cfg3 {
+	__u64 avg;		/* Average secs between packets * scale */
+	__u64 burst;		/* Period multiplier for upper limit. */
+	__u32 mode;		/* bitmask of XT_HASHLIMIT_HASH_* */
+
+	/* user specified */
+	__u32 size;		/* how many buckets */
+	__u32 max;		/* max number of entries */
+	__u32 gc_interval;	/* gc interval */
+	__u32 expire;		/* when do entries expire? */
+
+	__u32 interval;
+	__u8 srcmask, dstmask;
+};
+
 struct xt_hashlimit_mtinfo1 {
 	char name[IFNAMSIZ];
 	struct hashlimit_cfg1 cfg;
@@ -95,4 +111,12 @@ struct xt_hashlimit_mtinfo2 {
 	struct xt_hashlimit_htable *hinfo __attribute__((aligned(8)));
 };
 
+struct xt_hashlimit_mtinfo3 {
+	char name[NAME_MAX];
+	struct hashlimit_cfg3 cfg;
+
+	/* Used internally by the kernel */
+	struct xt_hashlimit_htable *hinfo __attribute__((aligned(8)));
+};
+
 #endif /* _UAPI_XT_HASHLIMIT_H */
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 762e187..df57989 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -56,6 +56,7 @@ static inline struct hashlimit_net *hashlimit_pernet(struct net *net)
 }
 
 /* need to declare this at the top */
+static const struct file_operations dl_file_ops_v2;
 static const struct file_operations dl_file_ops_v1;
 static const struct file_operations dl_file_ops;
 
@@ -87,8 +88,19 @@ struct dsthash_ent {
 	unsigned long expires;		/* precalculated expiry time */
 	struct {
 		unsigned long prev;	/* last modification */
-		u_int64_t credit;
-		u_int64_t credit_cap, cost;
+		union {
+			struct {
+				u_int64_t credit;
+				u_int64_t credit_cap;
+				u_int64_t cost;
+			};
+			struct {
+				u_int32_t interval, prev_window;
+				u_int64_t current_rate;
+				u_int64_t rate;
+				int64_t burst;
+			};
+		};
 	} rateinfo;
 	struct rcu_head rcu;
 };
@@ -99,7 +111,7 @@ struct xt_hashlimit_htable {
 	u_int8_t family;
 	bool rnd_initialized;
 
-	struct hashlimit_cfg2 cfg;	/* config */
+	struct hashlimit_cfg3 cfg;	/* config */
 
 	/* used internally */
 	spinlock_t lock;		/* lock for list_head */
@@ -116,7 +128,7 @@ struct xt_hashlimit_htable {
 };
 
 static int
-cfg_copy(struct hashlimit_cfg2 *to, void *from, int revision)
+cfg_copy(struct hashlimit_cfg3 *to, const void *from, int revision)
 {
 	if (revision == 1) {
 		struct hashlimit_cfg1 *cfg = from;
@@ -131,7 +143,19 @@ struct xt_hashlimit_htable {
 		to->srcmask = cfg->srcmask;
 		to->dstmask = cfg->dstmask;
 	} else if (revision == 2) {
-		memcpy(to, from, sizeof(struct hashlimit_cfg2));
+		struct hashlimit_cfg2 *cfg = (struct hashlimit_cfg2 *)from;
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
+	} else if (revision == 3) {
+		memcpy(to, from, sizeof(struct hashlimit_cfg3));
 	} else {
 		return -EINVAL;
 	}
@@ -240,13 +264,14 @@ static void dsthash_free_rcu(struct rcu_head *head)
 }
 static void htable_gc(struct work_struct *work);
 
-static int htable_create(struct net *net, struct hashlimit_cfg2 *cfg,
+static int htable_create(struct net *net, struct hashlimit_cfg3 *cfg,
 			 const char *name, u_int8_t family,
 			 struct xt_hashlimit_htable **out_hinfo,
 			 int revision)
 {
 	struct hashlimit_net *hashlimit_net = hashlimit_pernet(net);
 	struct xt_hashlimit_htable *hinfo;
+	const struct file_operations *fops;
 	unsigned int size, i;
 	int ret;
 
@@ -268,7 +293,7 @@ static int htable_create(struct net *net, struct hashlimit_cfg2 *cfg,
 	*out_hinfo = hinfo;
 
 	/* copy match config into hashtable config */
-	ret = cfg_copy(&hinfo->cfg, (void *)cfg, 2);
+	ret = cfg_copy(&hinfo->cfg, (void *)cfg, 3);
 
 	if (ret)
 		return ret;
@@ -293,11 +318,21 @@ static int htable_create(struct net *net, struct hashlimit_cfg2 *cfg,
 	}
 	spin_lock_init(&hinfo->lock);
 
+	switch (revision) {
+	case 1:
+		fops = &dl_file_ops_v1;
+		break;
+	case 2:
+		fops = &dl_file_ops_v2;
+		break;
+	default:
+		fops = &dl_file_ops;
+	}
+
 	hinfo->pde = proc_create_data(name, 0,
 		(family == NFPROTO_IPV4) ?
 		hashlimit_net->ipt_hashlimit : hashlimit_net->ip6t_hashlimit,
-		(revision == 1) ? &dl_file_ops_v1 : &dl_file_ops,
-		hinfo);
+		fops, hinfo);
 	if (hinfo->pde == NULL) {
 		kfree(hinfo->name);
 		vfree(hinfo);
@@ -482,6 +517,25 @@ static u32 user2credits_byte(u32 user)
 	return (u32) (us >> 32);
 }
 
+static u64 user2rate(u64 user)
+{
+	if (user != 0) {
+		return div64_u64(XT_HASHLIMIT_SCALE_v2, user);
+	} else {
+		pr_warn("invalid rate from userspace: %llu\n", user);
+		return 0;
+	}
+}
+
+static u64 user2rate_bytes(u64 user)
+{
+	u64 r;
+
+	r = user ? 0xFFFFFFFFULL / user : 0xFFFFFFFFULL;
+	r = (r - 1) << 4;
+	return r;
+}
+
 static void rateinfo_recalc(struct dsthash_ent *dh, unsigned long now,
 			    u32 mode, int revision)
 {
@@ -491,6 +545,21 @@ static void rateinfo_recalc(struct dsthash_ent *dh, unsigned long now,
 	if (delta == 0)
 		return;
 
+	if (revision >= 3 && mode & XT_HASHLIMIT_RATE_MATCH) {
+		u64 interval = dh->rateinfo.interval * HZ;
+
+		if (delta < interval)
+			return;
+
+		dh->rateinfo.prev = now;
+		dh->rateinfo.prev_window =
+			((dh->rateinfo.current_rate * interval) >
+			 (delta * dh->rateinfo.rate));
+		dh->rateinfo.current_rate = 0;
+
+		return;
+	}
+
 	dh->rateinfo.prev = now;
 
 	if (mode & XT_HASHLIMIT_BYTES) {
@@ -515,7 +584,23 @@ static void rateinfo_init(struct dsthash_ent *dh,
 			  struct xt_hashlimit_htable *hinfo, int revision)
 {
 	dh->rateinfo.prev = jiffies;
-	if (hinfo->cfg.mode & XT_HASHLIMIT_BYTES) {
+	if (revision >= 3 && hinfo->cfg.mode & XT_HASHLIMIT_RATE_MATCH) {
+		dh->rateinfo.prev_window = 0;
+		dh->rateinfo.current_rate = 0;
+		if (hinfo->cfg.mode & XT_HASHLIMIT_BYTES) {
+			dh->rateinfo.rate = user2rate_bytes(hinfo->cfg.avg);
+			if (hinfo->cfg.burst)
+				dh->rateinfo.burst =
+					hinfo->cfg.burst * dh->rateinfo.rate;
+			else
+				dh->rateinfo.burst = dh->rateinfo.rate;
+		} else {
+			dh->rateinfo.rate = user2rate(hinfo->cfg.avg);
+			dh->rateinfo.burst =
+				hinfo->cfg.burst + dh->rateinfo.rate;
+		}
+		dh->rateinfo.interval = hinfo->cfg.interval;
+	} else if (hinfo->cfg.mode & XT_HASHLIMIT_BYTES) {
 		dh->rateinfo.credit = CREDITS_PER_JIFFY_BYTES * HZ;
 		dh->rateinfo.cost = user2credits_byte(hinfo->cfg.avg);
 		dh->rateinfo.credit_cap = hinfo->cfg.burst;
@@ -648,7 +733,7 @@ static u32 hashlimit_byte_cost(unsigned int len, struct dsthash_ent *dh)
 static bool
 hashlimit_mt_common(const struct sk_buff *skb, struct xt_action_param *par,
 		    struct xt_hashlimit_htable *hinfo,
-		    const struct hashlimit_cfg2 *cfg, int revision)
+		    const struct hashlimit_cfg3 *cfg, int revision)
 {
 	unsigned long now = jiffies;
 	struct dsthash_ent *dh;
@@ -680,6 +765,20 @@ static u32 hashlimit_byte_cost(unsigned int len, struct dsthash_ent *dh)
 		rateinfo_recalc(dh, now, hinfo->cfg.mode, revision);
 	}
 
+	if (cfg->mode & XT_HASHLIMIT_RATE_MATCH) {
+		cost = (cfg->mode & XT_HASHLIMIT_BYTES) ? skb->len : 1;
+		dh->rateinfo.current_rate += cost;
+
+		if (!dh->rateinfo.prev_window &&
+		    (dh->rateinfo.current_rate <= dh->rateinfo.burst)) {
+			spin_unlock(&dh->lock);
+			rcu_read_unlock_bh();
+			return !(cfg->mode & XT_HASHLIMIT_INVERT);
+		} else {
+			goto overlimit;
+		}
+	}
+
 	if (cfg->mode & XT_HASHLIMIT_BYTES)
 		cost = hashlimit_byte_cost(skb->len, dh);
 	else
@@ -693,6 +792,7 @@ static u32 hashlimit_byte_cost(unsigned int len, struct dsthash_ent *dh)
 		return !(cfg->mode & XT_HASHLIMIT_INVERT);
 	}
 
+overlimit:
 	spin_unlock(&dh->lock);
 	rcu_read_unlock_bh();
 	/* default match is underlimit - so over the limit, we need to invert */
@@ -708,7 +808,7 @@ static u32 hashlimit_byte_cost(unsigned int len, struct dsthash_ent *dh)
 {
 	const struct xt_hashlimit_mtinfo1 *info = par->matchinfo;
 	struct xt_hashlimit_htable *hinfo = info->hinfo;
-	struct hashlimit_cfg2 cfg = {};
+	struct hashlimit_cfg3 cfg = {};
 	int ret;
 
 	ret = cfg_copy(&cfg, (void *)&info->cfg, 1);
@@ -720,17 +820,33 @@ static u32 hashlimit_byte_cost(unsigned int len, struct dsthash_ent *dh)
 }
 
 static bool
-hashlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
+hashlimit_mt_v2(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_hashlimit_mtinfo2 *info = par->matchinfo;
 	struct xt_hashlimit_htable *hinfo = info->hinfo;
+	struct hashlimit_cfg3 cfg = {};
+	int ret;
+
+	ret = cfg_copy(&cfg, (void *)&info->cfg, 2);
+
+	if (ret)
+		return ret;
+
+	return hashlimit_mt_common(skb, par, hinfo, &cfg, 2);
+}
+
+static bool
+hashlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	const struct xt_hashlimit_mtinfo3 *info = par->matchinfo;
+	struct xt_hashlimit_htable *hinfo = info->hinfo;
 
-	return hashlimit_mt_common(skb, par, hinfo, &info->cfg, 2);
+	return hashlimit_mt_common(skb, par, hinfo, &info->cfg, 3);
 }
 
 static int hashlimit_mt_check_common(const struct xt_mtchk_param *par,
 				     struct xt_hashlimit_htable **hinfo,
-				     struct hashlimit_cfg2 *cfg,
+				     struct hashlimit_cfg3 *cfg,
 				     const char *name, int revision)
 {
 	struct net *net = par->net;
@@ -753,7 +869,17 @@ static int hashlimit_mt_check_common(const struct xt_mtchk_param *par,
 	}
 
 	/* Check for overflow. */
-	if (cfg->mode & XT_HASHLIMIT_BYTES) {
+	if (revision >= 3 && cfg->mode & XT_HASHLIMIT_RATE_MATCH) {
+		if (cfg->avg == 0) {
+			pr_info("hashlimit invalid rate\n");
+			return -ERANGE;
+		}
+
+		if (cfg->interval == 0) {
+			pr_info("hashlimit invalid interval\n");
+			return -EINVAL;
+		}
+	} else if (cfg->mode & XT_HASHLIMIT_BYTES) {
 		if (user2credits_byte(cfg->avg) == 0) {
 			pr_info("overflow, rate too high: %llu\n", cfg->avg);
 			return -EINVAL;
@@ -784,7 +910,7 @@ static int hashlimit_mt_check_common(const struct xt_mtchk_param *par,
 static int hashlimit_mt_check_v1(const struct xt_mtchk_param *par)
 {
 	struct xt_hashlimit_mtinfo1 *info = par->matchinfo;
-	struct hashlimit_cfg2 cfg = {};
+	struct hashlimit_cfg3 cfg = {};
 	int ret;
 
 	if (info->name[sizeof(info->name) - 1] != '\0')
@@ -799,15 +925,40 @@ static int hashlimit_mt_check_v1(const struct xt_mtchk_param *par)
 					 &cfg, info->name, 1);
 }
 
-static int hashlimit_mt_check(const struct xt_mtchk_param *par)
+static int hashlimit_mt_check_v2(const struct xt_mtchk_param *par)
 {
 	struct xt_hashlimit_mtinfo2 *info = par->matchinfo;
+	struct hashlimit_cfg3 cfg = {};
+	int ret;
+
+	if (info->name[sizeof(info->name) - 1] != '\0')
+		return -EINVAL;
+
+	ret = cfg_copy(&cfg, (void *)&info->cfg, 2);
+
+	if (ret)
+		return ret;
+
+	return hashlimit_mt_check_common(par, &info->hinfo,
+					 &cfg, info->name, 2);
+}
+
+static int hashlimit_mt_check(const struct xt_mtchk_param *par)
+{
+	struct xt_hashlimit_mtinfo3 *info = par->matchinfo;
 
 	if (info->name[sizeof(info->name) - 1] != '\0')
 		return -EINVAL;
 
 	return hashlimit_mt_check_common(par, &info->hinfo, &info->cfg,
-					 info->name, 2);
+					 info->name, 3);
+}
+
+static void hashlimit_mt_destroy_v2(const struct xt_mtdtor_param *par)
+{
+	const struct xt_hashlimit_mtinfo2 *info = par->matchinfo;
+
+	htable_put(info->hinfo);
 }
 
 static void hashlimit_mt_destroy_v1(const struct xt_mtdtor_param *par)
@@ -819,7 +970,7 @@ static void hashlimit_mt_destroy_v1(const struct xt_mtdtor_param *par)
 
 static void hashlimit_mt_destroy(const struct xt_mtdtor_param *par)
 {
-	const struct xt_hashlimit_mtinfo2 *info = par->matchinfo;
+	const struct xt_hashlimit_mtinfo3 *info = par->matchinfo;
 
 	htable_put(info->hinfo);
 }
@@ -840,9 +991,20 @@ static void hashlimit_mt_destroy(const struct xt_mtdtor_param *par)
 		.name           = "hashlimit",
 		.revision       = 2,
 		.family         = NFPROTO_IPV4,
-		.match          = hashlimit_mt,
+		.match          = hashlimit_mt_v2,
 		.matchsize      = sizeof(struct xt_hashlimit_mtinfo2),
 		.usersize	= offsetof(struct xt_hashlimit_mtinfo2, hinfo),
+		.checkentry     = hashlimit_mt_check_v2,
+		.destroy        = hashlimit_mt_destroy_v2,
+		.me             = THIS_MODULE,
+	},
+	{
+		.name           = "hashlimit",
+		.revision       = 3,
+		.family         = NFPROTO_IPV4,
+		.match          = hashlimit_mt,
+		.matchsize      = sizeof(struct xt_hashlimit_mtinfo3),
+		.usersize	= offsetof(struct xt_hashlimit_mtinfo3, hinfo),
 		.checkentry     = hashlimit_mt_check,
 		.destroy        = hashlimit_mt_destroy,
 		.me             = THIS_MODULE,
@@ -863,9 +1025,20 @@ static void hashlimit_mt_destroy(const struct xt_mtdtor_param *par)
 		.name           = "hashlimit",
 		.revision       = 2,
 		.family         = NFPROTO_IPV6,
-		.match          = hashlimit_mt,
+		.match          = hashlimit_mt_v2,
 		.matchsize      = sizeof(struct xt_hashlimit_mtinfo2),
 		.usersize	= offsetof(struct xt_hashlimit_mtinfo2, hinfo),
+		.checkentry     = hashlimit_mt_check_v2,
+		.destroy        = hashlimit_mt_destroy_v2,
+		.me             = THIS_MODULE,
+	},
+	{
+		.name           = "hashlimit",
+		.revision       = 3,
+		.family         = NFPROTO_IPV6,
+		.match          = hashlimit_mt,
+		.matchsize      = sizeof(struct xt_hashlimit_mtinfo3),
+		.usersize	= offsetof(struct xt_hashlimit_mtinfo3, hinfo),
 		.checkentry     = hashlimit_mt_check,
 		.destroy        = hashlimit_mt_destroy,
 		.me             = THIS_MODULE,
@@ -947,6 +1120,21 @@ static void dl_seq_print(struct dsthash_ent *ent, u_int8_t family,
 	}
 }
 
+static int dl_seq_real_show_v2(struct dsthash_ent *ent, u_int8_t family,
+			       struct seq_file *s)
+{
+	const struct xt_hashlimit_htable *ht = s->private;
+
+	spin_lock(&ent->lock);
+	/* recalculate to show accurate numbers */
+	rateinfo_recalc(ent, jiffies, ht->cfg.mode, 2);
+
+	dl_seq_print(ent, family, s);
+
+	spin_unlock(&ent->lock);
+	return seq_has_overflowed(s);
+}
+
 static int dl_seq_real_show_v1(struct dsthash_ent *ent, u_int8_t family,
 			       struct seq_file *s)
 {
@@ -969,7 +1157,7 @@ static int dl_seq_real_show(struct dsthash_ent *ent, u_int8_t family,
 
 	spin_lock(&ent->lock);
 	/* recalculate to show accurate numbers */
-	rateinfo_recalc(ent, jiffies, ht->cfg.mode, 2);
+	rateinfo_recalc(ent, jiffies, ht->cfg.mode, 3);
 
 	dl_seq_print(ent, family, s);
 
@@ -977,6 +1165,20 @@ static int dl_seq_real_show(struct dsthash_ent *ent, u_int8_t family,
 	return seq_has_overflowed(s);
 }
 
+static int dl_seq_show_v2(struct seq_file *s, void *v)
+{
+	struct xt_hashlimit_htable *htable = s->private;
+	unsigned int *bucket = (unsigned int *)v;
+	struct dsthash_ent *ent;
+
+	if (!hlist_empty(&htable->hash[*bucket])) {
+		hlist_for_each_entry(ent, &htable->hash[*bucket], node)
+			if (dl_seq_real_show_v2(ent, htable->family, s))
+				return -1;
+	}
+	return 0;
+}
+
 static int dl_seq_show_v1(struct seq_file *s, void *v)
 {
 	struct xt_hashlimit_htable *htable = s->private;
@@ -1012,6 +1214,13 @@ static int dl_seq_show(struct seq_file *s, void *v)
 	.show  = dl_seq_show_v1
 };
 
+static const struct seq_operations dl_seq_ops_v2 = {
+	.start = dl_seq_start,
+	.next  = dl_seq_next,
+	.stop  = dl_seq_stop,
+	.show  = dl_seq_show_v2
+};
+
 static const struct seq_operations dl_seq_ops = {
 	.start = dl_seq_start,
 	.next  = dl_seq_next,
@@ -1019,6 +1228,18 @@ static int dl_seq_show(struct seq_file *s, void *v)
 	.show  = dl_seq_show
 };
 
+static int dl_proc_open_v2(struct inode *inode, struct file *file)
+{
+	int ret = seq_open(file, &dl_seq_ops_v2);
+
+	if (!ret) {
+		struct seq_file *sf = file->private_data;
+
+		sf->private = PDE_DATA(inode);
+	}
+	return ret;
+}
+
 static int dl_proc_open_v1(struct inode *inode, struct file *file)
 {
 	int ret = seq_open(file, &dl_seq_ops_v1);
@@ -1042,6 +1263,14 @@ static int dl_proc_open(struct inode *inode, struct file *file)
 	return ret;
 }
 
+static const struct file_operations dl_file_ops_v2 = {
+	.owner   = THIS_MODULE,
+	.open    = dl_proc_open_v2,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release
+};
+
 static const struct file_operations dl_file_ops_v1 = {
 	.owner   = THIS_MODULE,
 	.open    = dl_proc_open_v1,
-- 
1.9.1

