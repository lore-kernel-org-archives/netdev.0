From: pablo@netfilter.org
Subject: [PATCH 5/5] netfilter: hashlimit: byte-based limit mode
Date: Wed,  9 May 2012 13:33:08 +0200
Message-ID: <1336563188-6720-6-git-send-email-pablo@netfilter.org>
References: <1336563188-6720-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1336563188-6720-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

can be used e.g. for ingress traffic policing or
to detect when a host/port consumes more bandwidth than expected.

This is done by optionally making cost to mean
"cost per 16-byte-chunk-of-data" instead of "cost per packet".

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/xt_hashlimit.h |   10 ++-
 net/netfilter/xt_hashlimit.c           |  116 ++++++++++++++++++++++++++------
 2 files changed, 106 insertions(+), 20 deletions(-)

diff --git a/include/linux/netfilter/xt_hashlimit.h b/include/linux/netfilter/xt_hashlimit.h
index b1925b5..05fe799 100644
--- a/include/linux/netfilter/xt_hashlimit.h
+++ b/include/linux/netfilter/xt_hashlimit.h
@@ -6,7 +6,11 @@
 /* timings are in milliseconds. */
 #define XT_HASHLIMIT_SCALE 10000
 /* 1/10,000 sec period => max of 10,000/sec.  Min rate is then 429490
-   seconds, or one every 59 hours. */
+ * seconds, or one packet every 59 hours.
+ */
+
+/* packet length accounting is done in 16-byte steps */
+#define XT_HASHLIMIT_BYTE_SHIFT 4
 
 /* details of this structure hidden by the implementation */
 struct xt_hashlimit_htable;
@@ -17,6 +21,10 @@ enum {
 	XT_HASHLIMIT_HASH_SIP = 1 << 2,
 	XT_HASHLIMIT_HASH_SPT = 1 << 3,
 	XT_HASHLIMIT_INVERT   = 1 << 4,
+	XT_HASHLIMIT_BYTES    = 1 << 5,
+#ifdef __KERNEL__
+	XT_HASHLIMIT_MAX      = 1 << 6,
+#endif
 };
 
 struct hashlimit_cfg {
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index b6bbd06..d0424f9 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -388,6 +388,18 @@ static void htable_put(struct xt_hashlimit_htable *hinfo)
 
 #define CREDITS_PER_JIFFY POW2_BELOW32(MAX_CPJ)
 
+/* in byte mode, the lowest possible rate is one packet/second.
+ * credit_cap is used as a counter that tells us how many times we can
+ * refill the "credits available" counter when it becomes empty.
+ */
+#define MAX_CPJ_BYTES (0xFFFFFFFF / HZ)
+#define CREDITS_PER_JIFFY_BYTES POW2_BELOW32(MAX_CPJ_BYTES)
+
+static u32 xt_hashlimit_len_to_chunks(u32 len)
+{
+	return (len >> XT_HASHLIMIT_BYTE_SHIFT) + 1;
+}
+
 /* Precision saver. */
 static u32 user2credits(u32 user)
 {
@@ -399,21 +411,53 @@ static u32 user2credits(u32 user)
 	return (user * HZ * CREDITS_PER_JIFFY) / XT_HASHLIMIT_SCALE;
 }
 
-static void rateinfo_recalc(struct dsthash_ent *dh, unsigned long now)
+static u32 user2credits_byte(u32 user)
 {
-	dh->rateinfo.credit += (now - dh->rateinfo.prev) * CREDITS_PER_JIFFY;
-	if (dh->rateinfo.credit > dh->rateinfo.credit_cap)
-		dh->rateinfo.credit = dh->rateinfo.credit_cap;
+	u64 us = user;
+	us *= HZ * CREDITS_PER_JIFFY_BYTES;
+	return (u32) (us >> 32);
+}
+
+static void rateinfo_recalc(struct dsthash_ent *dh, unsigned long now, u32 mode)
+{
+	unsigned long delta = now - dh->rateinfo.prev;
+	u32 cap;
+
+	if (delta == 0)
+		return;
+
 	dh->rateinfo.prev = now;
+
+	if (mode & XT_HASHLIMIT_BYTES) {
+		u32 tmp = dh->rateinfo.credit;
+		dh->rateinfo.credit += CREDITS_PER_JIFFY_BYTES * delta;
+		cap = CREDITS_PER_JIFFY_BYTES * HZ;
+		if (tmp >= dh->rateinfo.credit) {/* overflow */
+			dh->rateinfo.credit = cap;
+			return;
+		}
+	} else {
+		dh->rateinfo.credit += delta * CREDITS_PER_JIFFY;
+		cap = dh->rateinfo.credit_cap;
+	}
+	if (dh->rateinfo.credit > cap)
+		dh->rateinfo.credit = cap;
 }
 
 static void rateinfo_init(struct dsthash_ent *dh,
 			  struct xt_hashlimit_htable *hinfo)
 {
 	dh->rateinfo.prev = jiffies;
-	dh->rateinfo.credit = user2credits(hinfo->cfg.avg * hinfo->cfg.burst);
-	dh->rateinfo.cost = user2credits(hinfo->cfg.avg);
-	dh->rateinfo.credit_cap = dh->rateinfo.credit;
+	if (hinfo->cfg.mode & XT_HASHLIMIT_BYTES) {
+		dh->rateinfo.credit = CREDITS_PER_JIFFY_BYTES * HZ;
+		dh->rateinfo.cost = user2credits_byte(hinfo->cfg.avg);
+		dh->rateinfo.credit_cap = hinfo->cfg.burst;
+	} else {
+		dh->rateinfo.credit = user2credits(hinfo->cfg.avg *
+						   hinfo->cfg.burst);
+		dh->rateinfo.cost = user2credits(hinfo->cfg.avg);
+		dh->rateinfo.credit_cap = dh->rateinfo.credit;
+	}
 }
 
 static inline __be32 maskl(__be32 a, unsigned int l)
@@ -519,6 +563,21 @@ hashlimit_init_dst(const struct xt_hashlimit_htable *hinfo,
 	return 0;
 }
 
+static u32 hashlimit_byte_cost(unsigned int len, struct dsthash_ent *dh)
+{
+	u64 tmp = xt_hashlimit_len_to_chunks(len);
+	tmp = tmp * dh->rateinfo.cost;
+
+	if (unlikely(tmp > CREDITS_PER_JIFFY_BYTES * HZ))
+		tmp = CREDITS_PER_JIFFY_BYTES * HZ;
+
+	if (dh->rateinfo.credit < tmp && dh->rateinfo.credit_cap) {
+		dh->rateinfo.credit_cap--;
+		dh->rateinfo.credit = CREDITS_PER_JIFFY_BYTES * HZ;
+	}
+	return (u32) tmp;
+}
+
 static bool
 hashlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
@@ -527,6 +586,7 @@ hashlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	unsigned long now = jiffies;
 	struct dsthash_ent *dh;
 	struct dsthash_dst dst;
+	u32 cost;
 
 	if (hashlimit_init_dst(hinfo, &dst, skb, par->thoff) < 0)
 		goto hotdrop;
@@ -544,12 +604,17 @@ hashlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	} else {
 		/* update expiration timeout */
 		dh->expires = now + msecs_to_jiffies(hinfo->cfg.expire);
-		rateinfo_recalc(dh, now);
+		rateinfo_recalc(dh, now, hinfo->cfg.mode);
 	}
 
-	if (dh->rateinfo.credit >= dh->rateinfo.cost) {
+	if (info->cfg.mode & XT_HASHLIMIT_BYTES)
+		cost = hashlimit_byte_cost(skb->len, dh);
+	else
+		cost = dh->rateinfo.cost;
+
+	if (dh->rateinfo.credit >= cost) {
 		/* below the limit */
-		dh->rateinfo.credit -= dh->rateinfo.cost;
+		dh->rateinfo.credit -= cost;
 		spin_unlock(&dh->lock);
 		rcu_read_unlock_bh();
 		return !(info->cfg.mode & XT_HASHLIMIT_INVERT);
@@ -571,14 +636,6 @@ static int hashlimit_mt_check(const struct xt_mtchk_param *par)
 	struct xt_hashlimit_mtinfo1 *info = par->matchinfo;
 	int ret;
 
-	/* Check for overflow. */
-	if (info->cfg.burst == 0 ||
-	    user2credits(info->cfg.avg * info->cfg.burst) <
-	    user2credits(info->cfg.avg)) {
-		pr_info("overflow, try lower: %u/%u\n",
-			info->cfg.avg, info->cfg.burst);
-		return -ERANGE;
-	}
 	if (info->cfg.gc_interval == 0 || info->cfg.expire == 0)
 		return -EINVAL;
 	if (info->name[sizeof(info->name)-1] != '\0')
@@ -591,6 +648,26 @@ static int hashlimit_mt_check(const struct xt_mtchk_param *par)
 			return -EINVAL;
 	}
 
+	if (info->cfg.mode >= XT_HASHLIMIT_MAX) {
+		pr_info("Unknown mode mask %X, kernel too old?\n",
+						info->cfg.mode);
+		return -EINVAL;
+	}
+
+	/* Check for overflow. */
+	if (info->cfg.mode & XT_HASHLIMIT_BYTES) {
+		if (user2credits_byte(info->cfg.avg) == 0) {
+			pr_info("overflow, rate too high: %u\n", info->cfg.avg);
+			return -EINVAL;
+		}
+	} else if (info->cfg.burst == 0 ||
+		    user2credits(info->cfg.avg * info->cfg.burst) <
+		    user2credits(info->cfg.avg)) {
+			pr_info("overflow, try lower: %u/%u\n",
+				info->cfg.avg, info->cfg.burst);
+			return -ERANGE;
+	}
+
 	mutex_lock(&hashlimit_mutex);
 	info->hinfo = htable_find_get(net, info->name, par->family);
 	if (info->hinfo == NULL) {
@@ -683,10 +760,11 @@ static int dl_seq_real_show(struct dsthash_ent *ent, u_int8_t family,
 				   struct seq_file *s)
 {
 	int res;
+	const struct xt_hashlimit_htable *ht = s->private;
 
 	spin_lock(&ent->lock);
 	/* recalculate to show accurate numbers */
-	rateinfo_recalc(ent, jiffies);
+	rateinfo_recalc(ent, jiffies, ht->cfg.mode);
 
 	switch (family) {
 	case NFPROTO_IPV4:
-- 
1.7.9.5

