From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v2 7/8] net: ipv6: mld: introduce mld_{gq,ifc,dad}_stop_timer functions
Date: Wed,  4 Sep 2013 00:19:43 +0200
Message-ID: <1378246784-21067-8-git-send-email-dborkman@redhat.com>
References: <1378246784-21067-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18977 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933127Ab3ICWUP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 18:20:15 -0400
In-Reply-To: <1378246784-21067-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We already have mld_{gq,ifc,dad}_start_timer() functions, so introduce
mld_{gq,ifc,dad}_stop_timer() functions to reduce code size and make it
more readable.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/mcast.c | 41 +++++++++++++++++++++++++----------------
 1 file changed, 25 insertions(+), 16 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 3be4fe0..ffae869 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1006,6 +1006,13 @@ static void mld_gq_start_timer(struct inet6_dev *idev)
 		in6_dev_hold(idev);
 }
 
+static void mld_gq_stop_timer(struct inet6_dev *idev)
+{
+	idev->mc_gq_running = 0;
+	if (del_timer(&idev->mc_gq_timer))
+		__in6_dev_put(idev);
+}
+
 static void mld_ifc_start_timer(struct inet6_dev *idev, unsigned long delay)
 {
 	unsigned long tv = net_random() % delay;
@@ -1014,6 +1021,13 @@ static void mld_ifc_start_timer(struct inet6_dev *idev, unsigned long delay)
 		in6_dev_hold(idev);
 }
 
+static void mld_ifc_stop_timer(struct inet6_dev *idev)
+{
+	idev->mc_ifc_count = 0;
+	if (del_timer(&idev->mc_ifc_timer))
+		__in6_dev_put(idev);
+}
+
 static void mld_dad_start_timer(struct inet6_dev *idev, unsigned long delay)
 {
 	unsigned long tv = net_random() % delay;
@@ -1022,6 +1036,12 @@ static void mld_dad_start_timer(struct inet6_dev *idev, unsigned long delay)
 		in6_dev_hold(idev);
 }
 
+static void mld_dad_stop_timer(struct inet6_dev *idev)
+{
+	if (del_timer(&idev->mc_dad_timer))
+		__in6_dev_put(idev);
+}
+
 /*
  *	IGMP handling (alias multicast ICMPv6 messages)
  */
@@ -1234,15 +1254,9 @@ static int mld_process_v1(struct inet6_dev *idev, struct mld_msg *mld,
 	mld_set_v1_mode(idev);
 
 	/* cancel MLDv2 report timer */
-	idev->mc_gq_running = 0;
-	if (del_timer(&idev->mc_gq_timer))
-		__in6_dev_put(idev);
-
+	mld_gq_stop_timer(idev);
 	/* cancel the interface change timer */
-	idev->mc_ifc_count = 0;
-	if (del_timer(&idev->mc_ifc_timer))
-		__in6_dev_put(idev);
-
+	mld_ifc_stop_timer(idev);
 	/* clear deleted report items */
 	mld_clear_delrec(idev);
 
@@ -2434,14 +2448,9 @@ void ipv6_mc_down(struct inet6_dev *idev)
 	/* Withdraw multicast list */
 
 	read_lock_bh(&idev->lock);
-	idev->mc_ifc_count = 0;
-	if (del_timer(&idev->mc_ifc_timer))
-		__in6_dev_put(idev);
-	idev->mc_gq_running = 0;
-	if (del_timer(&idev->mc_gq_timer))
-		__in6_dev_put(idev);
-	if (del_timer(&idev->mc_dad_timer))
-		__in6_dev_put(idev);
+	mld_ifc_stop_timer(idev);
+	mld_gq_stop_timer(idev);
+	mld_dad_stop_timer(idev);
 
 	for (i = idev->mc_list; i; i=i->next)
 		igmp6_group_dropped(i);
-- 
1.7.11.7
