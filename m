From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 6/8] net: ipv6: mld: refactor query processing into v1/v2 functions
Date: Tue,  3 Sep 2013 09:59:36 +0200
Message-ID: <1378195178-21002-7-git-send-email-dborkman@redhat.com>
References: <1378195178-21002-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16738 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932456Ab3ICH7x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 03:59:53 -0400
In-Reply-To: <1378195178-21002-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make igmp6_event_query() a bit easier to read by refactoring code
parts into mld_process_v1() and mld_process_v2().

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/mcast.c | 89 +++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 56 insertions(+), 33 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 75a4324..b01aa32 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1207,6 +1207,55 @@ static void mld_update_qri(struct inet6_dev *idev,
 	idev->mc_qri = msecs_to_jiffies(mldv2_mrc(mlh2));
 }
 
+static int mld_process_v1(struct inet6_dev *idev, struct mld_msg *mld,
+			  unsigned long *max_delay)
+{
+	unsigned long mldv1_md;
+
+	/* Ignore v1 queries */
+	if (mld_in_v2_mode_only(idev))
+		return -EINVAL;
+
+	/* MLDv1 router present */
+	mldv1_md = ntohs(mld->mld_maxdelay);
+	*max_delay = max(msecs_to_jiffies(mldv1_md), 1UL);
+
+	mld_set_v1_mode(idev);
+
+	/* cancel MLDv2 report timer */
+	idev->mc_gq_running = 0;
+	if (del_timer(&idev->mc_gq_timer))
+		__in6_dev_put(idev);
+
+	/* cancel the interface change timer */
+	idev->mc_ifc_count = 0;
+	if (del_timer(&idev->mc_ifc_timer))
+		__in6_dev_put(idev);
+
+	/* clear deleted report items */
+	mld_clear_delrec(idev);
+
+	return 0;
+}
+
+static int mld_process_v2(struct inet6_dev *idev, struct mld2_query *mld,
+			  unsigned long *max_delay)
+{
+	/* hosts need to stay in MLDv1 mode, discard MLDv2 queries */
+	if (mld_in_v1_mode(idev))
+		return -EINVAL;
+
+	*max_delay = max(msecs_to_jiffies(mldv2_mrc(mld)), 1UL);
+
+	mld_update_qrv(idev, mld);
+	mld_update_qi(idev, mld);
+	mld_update_qri(idev, mld);
+
+	idev->mc_maxdelay = *max_delay;
+
+	return 0;
+}
+
 /* called with rcu_read_lock() */
 int igmp6_event_query(struct sk_buff *skb)
 {
@@ -1218,7 +1267,7 @@ int igmp6_event_query(struct sk_buff *skb)
 	struct mld_msg *mld;
 	int group_type;
 	int mark = 0;
-	int len;
+	int len, err;
 
 	if (!pskb_may_pull(skb, sizeof(struct in6_addr)))
 		return -EINVAL;
@@ -1244,47 +1293,21 @@ int igmp6_event_query(struct sk_buff *skb)
 		return -EINVAL;
 
 	if (len == MLD_V1_QUERY_LEN) {
-		unsigned long mldv1_md;
-
-		/* Ignore v1 queries */
-		if (mld_in_v2_mode_only(idev))
-			return 0;
-
-		/* MLDv1 router present */
-		mldv1_md = ntohs(mld->mld_maxdelay);
-		max_delay = max(msecs_to_jiffies(mldv1_md), 1UL);
-
-		mld_set_v1_mode(idev);
-
-		/* cancel MLDv2 report timer */
-		idev->mc_gq_running = 0;
-		if (del_timer(&idev->mc_gq_timer))
-			__in6_dev_put(idev);
-
-		/* cancel the interface change timer */
-		idev->mc_ifc_count = 0;
-		if (del_timer(&idev->mc_ifc_timer))
-			__in6_dev_put(idev);
-		/* clear deleted report items */
-		mld_clear_delrec(idev);
+		err = mld_process_v1(idev, mld, &max_delay);
+		if (err < 0)
+			return err;
 	} else if (len >= MLD_V2_QUERY_LEN_MIN) {
 		int srcs_offset = sizeof(struct mld2_query) -
 				  sizeof(struct icmp6hdr);
 
-		/* hosts need to stay in MLDv1 mode, discard MLDv2 queries */
-		if (mld_in_v1_mode(idev))
-			return 0;
 		if (!pskb_may_pull(skb, srcs_offset))
 			return -EINVAL;
 
 		mlh2 = (struct mld2_query *)skb_transport_header(skb);
 
-		max_delay = max(msecs_to_jiffies(mldv2_mrc(mlh2)), 1UL);
-		idev->mc_maxdelay = max_delay;
-
-		mld_update_qrv(idev, mlh2);
-		mld_update_qi(idev, mlh2);
-		mld_update_qri(idev, mlh2);
+		err = mld_process_v2(idev, mlh2, &max_delay);
+		if (err < 0)
+			return err;
 
 		if (group_type == IPV6_ADDR_ANY) { /* general query */
 			if (mlh2->mld2q_nsrcs)
-- 
1.7.11.7
