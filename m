From: pablo@netfilter.org
Subject: [PATCH 09/12] netfilter: xt_hashlimit: fix race that results in duplicated entries
Date: Fri, 28 Dec 2012 12:52:48 +0100
Message-ID: <1356695571-3305-10-git-send-email-pablo@netfilter.org>
References: <1356695571-3305-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1356695571-3305-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Two packets may race to create the same entry in the hashtable,
double check if this packet lost race. This double checking only
happens in the path of the packet that creates the hashtable for
first time.

Note that, with this patch, no packet drops occur if the race happens.

Reported-by: Feng Gao <gfree.wind@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_hashlimit.c |   25 +++++++++++++++++++++----
 1 file changed, 21 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 26a668a..cc430f9 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -157,11 +157,22 @@ dsthash_find(const struct xt_hashlimit_htable *ht,
 /* allocate dsthash_ent, initialize dst, put in htable and lock it */
 static struct dsthash_ent *
 dsthash_alloc_init(struct xt_hashlimit_htable *ht,
-		   const struct dsthash_dst *dst)
+		   const struct dsthash_dst *dst, bool *race)
 {
 	struct dsthash_ent *ent;
 
 	spin_lock(&ht->lock);
+
+	/* Two or more packets may race to create the same entry in the
+	 * hashtable, double check if this packet lost race.
+	 */
+	ent = dsthash_find(ht, dst);
+	if (ent != NULL) {
+		spin_unlock(&ht->lock);
+		*race = true;
+		return ent;
+	}
+
 	/* initialize hash with random val at the time we allocate
 	 * the first hashtable entry */
 	if (unlikely(!ht->rnd_initialized)) {
@@ -585,6 +596,7 @@ hashlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	unsigned long now = jiffies;
 	struct dsthash_ent *dh;
 	struct dsthash_dst dst;
+	bool race = false;
 	u32 cost;
 
 	if (hashlimit_init_dst(hinfo, &dst, skb, par->thoff) < 0)
@@ -593,13 +605,18 @@ hashlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	rcu_read_lock_bh();
 	dh = dsthash_find(hinfo, &dst);
 	if (dh == NULL) {
-		dh = dsthash_alloc_init(hinfo, &dst);
+		dh = dsthash_alloc_init(hinfo, &dst, &race);
 		if (dh == NULL) {
 			rcu_read_unlock_bh();
 			goto hotdrop;
+		} else if (race) {
+			/* Already got an entry, update expiration timeout */
+			dh->expires = now + msecs_to_jiffies(hinfo->cfg.expire);
+			rateinfo_recalc(dh, now, hinfo->cfg.mode);
+		} else {
+			dh->expires = jiffies + msecs_to_jiffies(hinfo->cfg.expire);
+			rateinfo_init(dh, hinfo);
 		}
-		dh->expires = jiffies + msecs_to_jiffies(hinfo->cfg.expire);
-		rateinfo_init(dh, hinfo);
 	} else {
 		/* update expiration timeout */
 		dh->expires = now + msecs_to_jiffies(hinfo->cfg.expire);
-- 
1.7.10.4

