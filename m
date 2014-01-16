From: Flavio Leitner <fbl@redhat.com>
Subject: [PATCH v2] ipv6: send Change Status Report after DAD is completed
Date: Thu, 16 Jan 2014 19:27:59 -0200
Message-ID: <1389907679-15346-1-git-send-email-fbl@redhat.com>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Flavio Leitner <fbl@redhat.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55812 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750750AbaAPV1G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 16:27:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The RFC 3810 defines two type of messages for multicast
listeners. The "Current State Report" message, as the name
implies, refreshes the *current* state to the querier.
Since the querier sends Query messages periodically, there
is no need to retransmit the report.

On the other hand, any change should be reported immediately
using "State Change Report" messages. Since it's an event
triggered by a change and that it can be affected by packet
loss, the rfc states it should be retransmitted [RobVar] times
to make sure routers will receive timely.

Currently, we are sending "Current State Reports" after
DAD is completed.  Before that, we send messages using
unspecified address (::) which should be silently discarded
by routers.

This patch changes to send "State Change Report" messages
after DAD is completed fixing the behavior to be RFC compliant
and also to pass TAHI IPv6 testsuite.

Signed-off-by: Flavio Leitner <fbl@redhat.com>
---
 net/ipv6/mcast.c | 57 ++++++++++++++++++++++++++++++++------------------------
 1 file changed, 33 insertions(+), 24 deletions(-)

v2: refreshed against current net-next tree
    simplified the code

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 7ff82b3..e1e4735 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1665,7 +1665,7 @@ static struct sk_buff *add_grhead(struct sk_buff *skb, struct ifmcaddr6 *pmc,
 	skb_tailroom(skb)) : 0)
 
 static struct sk_buff *add_grec(struct sk_buff *skb, struct ifmcaddr6 *pmc,
-	int type, int gdeleted, int sdeleted)
+	int type, int gdeleted, int sdeleted, int crsend)
 {
 	struct inet6_dev *idev = pmc->idev;
 	struct net_device *dev = idev->dev;
@@ -1757,7 +1757,7 @@ empty_source:
 		if (type == MLD2_ALLOW_NEW_SOURCES ||
 		    type == MLD2_BLOCK_OLD_SOURCES)
 			return skb;
-		if (pmc->mca_crcount || isquery) {
+		if (pmc->mca_crcount || isquery || crsend) {
 			/* make sure we have room for group header */
 			if (skb && AVAILABLE(skb) < sizeof(struct mld2_grec)) {
 				mld_sendpack(skb);
@@ -1789,7 +1789,7 @@ static void mld_send_report(struct inet6_dev *idev, struct ifmcaddr6 *pmc)
 				type = MLD2_MODE_IS_EXCLUDE;
 			else
 				type = MLD2_MODE_IS_INCLUDE;
-			skb = add_grec(skb, pmc, type, 0, 0);
+			skb = add_grec(skb, pmc, type, 0, 0, 0);
 			spin_unlock_bh(&pmc->mca_lock);
 		}
 	} else {
@@ -1798,7 +1798,7 @@ static void mld_send_report(struct inet6_dev *idev, struct ifmcaddr6 *pmc)
 			type = MLD2_MODE_IS_EXCLUDE;
 		else
 			type = MLD2_MODE_IS_INCLUDE;
-		skb = add_grec(skb, pmc, type, 0, 0);
+		skb = add_grec(skb, pmc, type, 0, 0, 0);
 		spin_unlock_bh(&pmc->mca_lock);
 	}
 	read_unlock_bh(&idev->lock);
@@ -1843,13 +1843,13 @@ static void mld_send_cr(struct inet6_dev *idev)
 		if (pmc->mca_sfmode == MCAST_INCLUDE) {
 			type = MLD2_BLOCK_OLD_SOURCES;
 			dtype = MLD2_BLOCK_OLD_SOURCES;
-			skb = add_grec(skb, pmc, type, 1, 0);
-			skb = add_grec(skb, pmc, dtype, 1, 1);
+			skb = add_grec(skb, pmc, type, 1, 0, 0);
+			skb = add_grec(skb, pmc, dtype, 1, 1, 0);
 		}
 		if (pmc->mca_crcount) {
 			if (pmc->mca_sfmode == MCAST_EXCLUDE) {
 				type = MLD2_CHANGE_TO_INCLUDE;
-				skb = add_grec(skb, pmc, type, 1, 0);
+				skb = add_grec(skb, pmc, type, 1, 0, 0);
 			}
 			pmc->mca_crcount--;
 			if (pmc->mca_crcount == 0) {
@@ -1880,8 +1880,8 @@ static void mld_send_cr(struct inet6_dev *idev)
 			type = MLD2_ALLOW_NEW_SOURCES;
 			dtype = MLD2_BLOCK_OLD_SOURCES;
 		}
-		skb = add_grec(skb, pmc, type, 0, 0);
-		skb = add_grec(skb, pmc, dtype, 0, 1);	/* deleted sources */
+		skb = add_grec(skb, pmc, type, 0, 0, 0);
+		skb = add_grec(skb, pmc, dtype, 0, 1, 0);	/* deleted sources */
 
 		/* filter mode changes */
 		if (pmc->mca_crcount) {
@@ -1889,7 +1889,7 @@ static void mld_send_cr(struct inet6_dev *idev)
 				type = MLD2_CHANGE_TO_EXCLUDE;
 			else
 				type = MLD2_CHANGE_TO_INCLUDE;
-			skb = add_grec(skb, pmc, type, 0, 0);
+			skb = add_grec(skb, pmc, type, 0, 0, 0);
 			pmc->mca_crcount--;
 		}
 		spin_unlock_bh(&pmc->mca_lock);
@@ -1997,27 +1997,36 @@ err_out:
 	goto out;
 }
 
-static void mld_resend_report(struct inet6_dev *idev)
+static void mld_send_initial_cr(struct inet6_dev *idev)
 {
-	if (mld_in_v1_mode(idev)) {
-		struct ifmcaddr6 *mcaddr;
-		read_lock_bh(&idev->lock);
-		for (mcaddr = idev->mc_list; mcaddr; mcaddr = mcaddr->next) {
-			if (!(mcaddr->mca_flags & MAF_NOREPORT))
-				igmp6_send(&mcaddr->mca_addr, idev->dev,
-					   ICMPV6_MGM_REPORT);
-		}
-		read_unlock_bh(&idev->lock);
-	} else {
-		mld_send_report(idev, NULL);
+	struct sk_buff *skb;
+	struct ifmcaddr6 *pmc;
+	int type;
+
+	if (mld_in_v1_mode(idev))
+		return;
+
+	skb = NULL;
+	read_lock_bh(&idev->lock);
+	for (pmc=idev->mc_list; pmc; pmc=pmc->next) {
+		spin_lock_bh(&pmc->mca_lock);
+		if (pmc->mca_sfcount[MCAST_EXCLUDE])
+			type = MLD2_CHANGE_TO_EXCLUDE;
+		else
+			type = MLD2_CHANGE_TO_INCLUDE;
+		skb = add_grec(skb, pmc, type, 0, 0, 1);
+		spin_unlock_bh(&pmc->mca_lock);
 	}
+	read_unlock_bh(&idev->lock);
+	if (skb)
+		mld_sendpack(skb);
 }
 
 void ipv6_mc_dad_complete(struct inet6_dev *idev)
 {
 	idev->mc_dad_count = idev->mc_qrv;
 	if (idev->mc_dad_count) {
-		mld_resend_report(idev);
+		mld_send_initial_cr(idev);
 		idev->mc_dad_count--;
 		if (idev->mc_dad_count)
 			mld_dad_start_timer(idev, idev->mc_maxdelay);
@@ -2028,7 +2037,7 @@ static void mld_dad_timer_expire(unsigned long data)
 {
 	struct inet6_dev *idev = (struct inet6_dev *)data;
 
-	mld_resend_report(idev);
+	mld_send_initial_cr(idev);
 	if (idev->mc_dad_count) {
 		idev->mc_dad_count--;
 		if (idev->mc_dad_count)
-- 
1.8.4.2
