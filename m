From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v2 3/8] net: ipv6: mld: get rid of MLDV2_MRC and simplify calculation
Date: Wed,  4 Sep 2013 00:19:39 +0200
Message-ID: <1378246784-21067-4-git-send-email-dborkman@redhat.com>
References: <1378246784-21067-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7523 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761173Ab3ICWT5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 18:19:57 -0400
In-Reply-To: <1378246784-21067-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of MLDV2_MRC and use our new macros for mantisse and
exponent to calculate Maximum Response Delay out of the Maximum
Response Code.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 This will give a merge conflict in net/bridge/br_multicast.c with
 net tree. You can resolve it by simply taking this version as we
 already do msecs_to_jiffies() here.

 include/net/mld.h         | 28 +++++++++++++++++++---------
 net/bridge/br_multicast.c |  3 ++-
 net/ipv6/mcast.c          | 18 ++----------------
 3 files changed, 23 insertions(+), 26 deletions(-)

diff --git a/include/net/mld.h b/include/net/mld.h
index 2b5421f..faa1d16 100644
--- a/include/net/mld.h
+++ b/include/net/mld.h
@@ -63,15 +63,6 @@ struct mld2_query {
 #define mld2q_mrc		mld2q_hdr.icmp6_maxdelay
 #define mld2q_resv1		mld2q_hdr.icmp6_dataun.un_data16[1]
 
-/* Max Response Code, TODO: transform this to use the below */
-#define MLDV2_MASK(value, nb) ((nb)>=32 ? (value) : ((1<<(nb))-1) & (value))
-#define MLDV2_EXP(thresh, nbmant, nbexp, value) \
-	((value) < (thresh) ? (value) : \
-	((MLDV2_MASK(value, nbmant) | (1<<(nbmant))) << \
-	(MLDV2_MASK((value) >> (nbmant), nbexp) + (nbexp))))
-
-#define MLDV2_MRC(value) MLDV2_EXP(0x8000, 12, 3, value)
-
 /* RFC3810, 5.1.3. Maximum Response Code:
  *
  * If Maximum Response Code >= 32768, Maximum Response Code represents a
@@ -97,4 +88,23 @@ struct mld2_query {
 #define MLDV2_QQIC_EXP(value)	(((value) >> 4) & 0x07)
 #define MLDV2_QQIC_MAN(value)	((value) & 0x0f)
 
+static inline unsigned long mldv2_mrc(const struct mld2_query *mlh2)
+{
+	/* RFC3810, 5.1.3. Maximum Response Code */
+	unsigned long ret, mc_mrc = ntohs(mlh2->mld2q_mrc);
+
+	if (mc_mrc < 32768) {
+		ret = mc_mrc;
+	} else {
+		unsigned long mc_man, mc_exp;
+
+		mc_exp = MLDV2_MRC_EXP(mc_mrc);
+		mc_man = MLDV2_MRC_MAN(mc_mrc);
+
+		ret = (mc_man | 0x1000) << (mc_exp + 3);
+	}
+
+	return ret;
+}
+
 #endif
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 08e576a..4accd0d 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1203,7 +1203,8 @@ static int br_ip6_multicast_query(struct net_bridge *br,
 		mld2q = (struct mld2_query *)icmp6_hdr(skb);
 		if (!mld2q->mld2q_nsrcs)
 			group = &mld2q->mld2q_mca;
-		max_delay = mld2q->mld2q_mrc ? MLDV2_MRC(ntohs(mld2q->mld2q_mrc)) : 1;
+
+		max_delay = max(msecs_to_jiffies(mldv2_mrc(mld2q)), 1UL);
 	}
 
 	br_multicast_query_received(br, port, !ipv6_addr_any(&ip6h->saddr),
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index f86e26b..005b22f 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1195,20 +1195,7 @@ static void mld_update_qri(struct inet6_dev *idev,
 	 *  - 5.1.3. Maximum Response Code
 	 *  - 9.3. Query Response Interval
 	 */
-	unsigned long mc_qri, mc_mrc = ntohs(mlh2->mld2q_mrc);
-
-	if (mc_mrc < 32768) {
-		mc_qri = mc_mrc;
-	} else {
-		unsigned long mc_man, mc_exp;
-
-		mc_exp = MLDV2_MRC_EXP(mc_mrc);
-		mc_man = MLDV2_MRC_MAN(mc_mrc);
-
-		mc_qri = (mc_man | 0x1000) << (mc_exp + 3);
-	}
-
-	idev->mc_qri = msecs_to_jiffies(mc_qri);
+	idev->mc_qri = msecs_to_jiffies(mldv2_mrc(mlh2));
 }
 
 /* called with rcu_read_lock() */
@@ -1277,8 +1264,7 @@ int igmp6_event_query(struct sk_buff *skb)
 
 		mlh2 = (struct mld2_query *)skb_transport_header(skb);
 
-		max_delay = max(msecs_to_jiffies(MLDV2_MRC(ntohs(mlh2->mld2q_mrc))), 1UL);
-
+		max_delay = max(msecs_to_jiffies(mldv2_mrc(mlh2)), 1UL);
 		idev->mc_maxdelay = max_delay;
 
 		mld_update_qrv(idev, mlh2);
-- 
1.7.11.7
