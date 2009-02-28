From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] iptables: xt_hashlimit fix
Date: Sat, 28 Feb 2009 02:54:22 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0902280253370.20614@fbirervta.pbzchgretzou.qr>
References: <20090218051906.174295181@vyatta.com> <20090218052747.321329022@vyatta.com> <20090219114719.560999b5@extreme> <499DEF49.3040602@cosmosbay.com> <499EF222.3060507@cosmosbay.com> <alpine.LSU.2.00.0902201919390.5911@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.00.0902201919390.5911@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Friday 2009-02-20 19:33, Jan Engelhardt wrote:
>On Friday 2009-02-20 19:10, Eric Dumazet wrote:
>>
>>Damned this broke xt_hashlimit, version=0
>>Look file "net/netfilter/xt_hashlimit.c" line 706
>>
>>    /* Ugly hack: For SMP, we only want to use one set */
>>    r->u.master = r;
>>
>>So, it appears some modules are using pointers to themselves, what a hack :(
>>We probably need an audit of other modules.
>
>xt_limit and xt_statistic are affected; I'll happily fix that up.

Please have a look!

---8<---
parent b2bd9ab764d65237232c4aad5ab8d5d8b5714f72 (v2.6.29-rc6-31-gb2bd9ab)
commit 3e7ee1dcc808b8eec82eddfa0436f78e31d2004a
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Sat Feb 28 02:49:28 2009 +0100

netfilter: xtables: avoid pointer to self

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 include/linux/netfilter/xt_limit.h     |    9 +++--
 include/linux/netfilter/xt_statistic.h |    7 ++--
 net/netfilter/xt_limit.c               |   40 +++++++++++++++++------
 net/netfilter/xt_statistic.c           |   28 +++++++++++++---
 4 files changed, 61 insertions(+), 23 deletions(-)

diff --git a/include/linux/netfilter/xt_limit.h b/include/linux/netfilter/xt_limit.h
index b3ce653..fda222c 100644
--- a/include/linux/netfilter/xt_limit.h
+++ b/include/linux/netfilter/xt_limit.h
@@ -4,6 +4,8 @@
 /* timings are in milliseconds. */
 #define XT_LIMIT_SCALE 10000
 
+struct xt_limit_priv;
+
 /* 1/10,000 sec period => max of 10,000/sec.  Min rate is then 429490
    seconds, or one every 59 hours. */
 struct xt_rateinfo {
@@ -11,11 +13,10 @@ struct xt_rateinfo {
 	u_int32_t burst;  /* Period multiplier for upper limit. */
 
 	/* Used internally by the kernel */
-	unsigned long prev;
-	u_int32_t credit;
+	unsigned long prev; /* moved to xt_limit_priv */
+	u_int32_t credit; /* moved to xt_limit_priv */
 	u_int32_t credit_cap, cost;
 
-	/* Ugly, ugly fucker. */
-	struct xt_rateinfo *master;
+	struct xt_limit_priv *master;
 };
 #endif /*_XT_RATE_H*/
diff --git a/include/linux/netfilter/xt_statistic.h b/include/linux/netfilter/xt_statistic.h
index 3d38bc9..8f521ab 100644
--- a/include/linux/netfilter/xt_statistic.h
+++ b/include/linux/netfilter/xt_statistic.h
@@ -13,6 +13,8 @@ enum xt_statistic_flags {
 };
 #define XT_STATISTIC_MASK		0x1
 
+struct xt_statistic_priv;
+
 struct xt_statistic_info {
 	u_int16_t			mode;
 	u_int16_t			flags;
@@ -23,11 +25,10 @@ struct xt_statistic_info {
 		struct {
 			u_int32_t	every;
 			u_int32_t	packet;
-			/* Used internally by the kernel */
-			u_int32_t	count;
+			u_int32_t	count; /* unused */
 		} nth;
 	} u;
-	struct xt_statistic_info	*master __attribute__((aligned(8)));
+	struct xt_statistic_priv *master __attribute__((aligned(8)));
 };
 
 #endif /* _XT_STATISTIC_H */
diff --git a/net/netfilter/xt_limit.c b/net/netfilter/xt_limit.c
index c908d69..2e8089e 100644
--- a/net/netfilter/xt_limit.c
+++ b/net/netfilter/xt_limit.c
@@ -14,6 +14,11 @@
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_limit.h>
 
+struct xt_limit_priv {
+	unsigned long prev;
+	uint32_t credit;
+};
+
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Herve Eychenne <rv@wallfire.org>");
 MODULE_DESCRIPTION("Xtables: rate-limit match");
@@ -60,18 +65,18 @@ static DEFINE_SPINLOCK(limit_lock);
 static bool
 limit_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 {
-	struct xt_rateinfo *r =
-		((const struct xt_rateinfo *)par->matchinfo)->master;
+	const struct xt_rateinfo *r = par->matchinfo;
+	struct xt_limit_priv *priv = r->master;
 	unsigned long now = jiffies;
 
 	spin_lock_bh(&limit_lock);
-	r->credit += (now - xchg(&r->prev, now)) * CREDITS_PER_JIFFY;
-	if (r->credit > r->credit_cap)
-		r->credit = r->credit_cap;
+	priv->credit += (now - xchg(&priv->prev, now)) * CREDITS_PER_JIFFY;
+	if (priv->credit > r->credit_cap)
+		priv->credit = r->credit_cap;
 
-	if (r->credit >= r->cost) {
+	if (priv->credit >= r->cost) {
 		/* We're not limited. */
-		r->credit -= r->cost;
+		priv->credit -= r->cost;
 		spin_unlock_bh(&limit_lock);
 		return true;
 	}
@@ -95,6 +100,7 @@ user2credits(u_int32_t user)
 static bool limit_mt_check(const struct xt_mtchk_param *par)
 {
 	struct xt_rateinfo *r = par->matchinfo;
+	struct xt_limit_priv *priv;
 
 	/* Check for overflow. */
 	if (r->burst == 0
@@ -104,19 +110,30 @@ static bool limit_mt_check(const struct xt_mtchk_param *par)
 		return false;
 	}
 
-	/* For SMP, we only want to use one set of counters. */
-	r->master = r;
+	priv = kmalloc(sizeof(*priv), GFP_KERNEL);
+	if (priv == NULL)
+		return -ENOMEM;
+
+	/* For SMP, we only want to use one set of state. */
+	r->master = priv;
 	if (r->cost == 0) {
 		/* User avg in seconds * XT_LIMIT_SCALE: convert to jiffies *
 		   128. */
-		r->prev = jiffies;
-		r->credit = user2credits(r->avg * r->burst);	 /* Credits full. */
+		priv->prev = jiffies;
+		priv->credit = user2credits(r->avg * r->burst); /* Credits full. */
 		r->credit_cap = user2credits(r->avg * r->burst); /* Credits full. */
 		r->cost = user2credits(r->avg);
 	}
 	return true;
 }
 
+static void limit_mt_destroy(const struct xt_mtdtor_param *par)
+{
+	const struct xt_rateinfo *info = par->matchinfo;
+
+	kfree(info->master);
+}
+
 #ifdef CONFIG_COMPAT
 struct compat_xt_rateinfo {
 	u_int32_t avg;
@@ -167,6 +184,7 @@ static struct xt_match limit_mt_reg __read_mostly = {
 	.family           = NFPROTO_UNSPEC,
 	.match            = limit_mt,
 	.checkentry       = limit_mt_check,
+	.destroy          = limit_mt_destroy,
 	.matchsize        = sizeof(struct xt_rateinfo),
 #ifdef CONFIG_COMPAT
 	.compatsize       = sizeof(struct compat_xt_rateinfo),
diff --git a/net/netfilter/xt_statistic.c b/net/netfilter/xt_statistic.c
index 0d75141..d8c0f8f 100644
--- a/net/netfilter/xt_statistic.c
+++ b/net/netfilter/xt_statistic.c
@@ -16,6 +16,10 @@
 #include <linux/netfilter/xt_statistic.h>
 #include <linux/netfilter/x_tables.h>
 
+struct xt_statistic_priv {
+	uint32_t count;
+};
+
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
 MODULE_DESCRIPTION("Xtables: statistics-based matching (\"Nth\", random)");
@@ -27,7 +31,7 @@ static DEFINE_SPINLOCK(nth_lock);
 static bool
 statistic_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 {
-	struct xt_statistic_info *info = (void *)par->matchinfo;
+	const struct xt_statistic_info *info = par->matchinfo;
 	bool ret = info->flags & XT_STATISTIC_INVERT;
 
 	switch (info->mode) {
@@ -36,10 +40,9 @@ statistic_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 			ret = !ret;
 		break;
 	case XT_STATISTIC_MODE_NTH:
-		info = info->master;
 		spin_lock_bh(&nth_lock);
-		if (info->u.nth.count++ == info->u.nth.every) {
-			info->u.nth.count = 0;
+		if (info->master->count++ == info->u.nth.every) {
+			info->master->count = 0;
 			ret = !ret;
 		}
 		spin_unlock_bh(&nth_lock);
@@ -56,16 +59,31 @@ static bool statistic_mt_check(const struct xt_mtchk_param *par)
 	if (info->mode > XT_STATISTIC_MODE_MAX ||
 	    info->flags & ~XT_STATISTIC_MASK)
 		return false;
-	info->master = info;
+
+	info->master = kzalloc(sizeof(*info->master), GFP_KERNEL);
+	if (info->master == NULL) {
+		printk(KERN_ERR KBUILD_MODNAME ": Out of memory\n");
+		return false;
+	}
+	info->master->count = info->u.nth.count;
+
 	return true;
 }
 
+static void statistic_mt_destroy(const struct xt_mtdtor_param *par)
+{
+	const struct xt_statistic_info *info = par->matchinfo;
+
+	kfree(info->master);
+}
+
 static struct xt_match xt_statistic_mt_reg __read_mostly = {
 	.name       = "statistic",
 	.revision   = 0,
 	.family     = NFPROTO_UNSPEC,
 	.match      = statistic_mt,
 	.checkentry = statistic_mt_check,
+	.destroy    = statistic_mt_destroy,
 	.matchsize  = sizeof(struct xt_statistic_info),
 	.me         = THIS_MODULE,
 };
-- 
# Created with git-export-patch
