From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/3] ipv6: mld: rename mc_maxdelay into mc_uri
Date: Tue, 23 Sep 2014 09:03:46 +0200
Message-ID: <1411455828-5196-2-git-send-email-dborkman@redhat.com>
References: <1411455828-5196-1-git-send-email-dborkman@redhat.com>
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29462 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751641AbaIWHD4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 03:03:56 -0400
In-Reply-To: <1411455828-5196-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The name mc_maxdelay is quite confusing as it actually denotes the
unsolicited report interval. Since we have query response interval
named as mc_qri, name unsolicited report interval analogously as
mc_uri. Note that both are not the same!

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/net/if_inet6.h |  2 +-
 net/ipv6/mcast.c       | 12 ++++++------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index d07b1a6..8daf683 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -180,7 +180,7 @@ struct inet6_dev {
 	unsigned long		mc_v1_seen;	/* Max time we stay in MLDv1 mode */
 	unsigned long		mc_qi;		/* Query Interval */
 	unsigned long		mc_qri;		/* Query Response Interval */
-	unsigned long		mc_maxdelay;
+	unsigned long		mc_uri;		/* Unsolicited Report Interval */
 
 	struct timer_list	mc_gq_timer;	/* general query timer */
 	struct timer_list	mc_ifc_timer;	/* interface change timer */
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 592eba6..3d0e8fc 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -996,7 +996,7 @@ bool ipv6_chk_mcast_addr(struct net_device *dev, const struct in6_addr *group,
 
 static void mld_gq_start_timer(struct inet6_dev *idev)
 {
-	unsigned long tv = prandom_u32() % idev->mc_maxdelay;
+	unsigned long tv = prandom_u32() % idev->mc_uri;
 
 	idev->mc_gq_running = 1;
 	if (!mod_timer(&idev->mc_gq_timer, jiffies+tv+2))
@@ -1274,7 +1274,7 @@ static int mld_process_v2(struct inet6_dev *idev, struct mld2_query *mld,
 	mld_update_qi(idev, mld);
 	mld_update_qri(idev, mld);
 
-	idev->mc_maxdelay = *max_delay;
+	idev->mc_uri = *max_delay;
 
 	return 0;
 }
@@ -2037,7 +2037,7 @@ void ipv6_mc_dad_complete(struct inet6_dev *idev)
 		mld_send_initial_cr(idev);
 		idev->mc_dad_count--;
 		if (idev->mc_dad_count)
-			mld_dad_start_timer(idev, idev->mc_maxdelay);
+			mld_dad_start_timer(idev, idev->mc_uri);
 	}
 }
 
@@ -2049,7 +2049,7 @@ static void mld_dad_timer_expire(unsigned long data)
 	if (idev->mc_dad_count) {
 		idev->mc_dad_count--;
 		if (idev->mc_dad_count)
-			mld_dad_start_timer(idev, idev->mc_maxdelay);
+			mld_dad_start_timer(idev, idev->mc_uri);
 	}
 	in6_dev_put(idev);
 }
@@ -2407,7 +2407,7 @@ static void mld_ifc_timer_expire(unsigned long data)
 	if (idev->mc_ifc_count) {
 		idev->mc_ifc_count--;
 		if (idev->mc_ifc_count)
-			mld_ifc_start_timer(idev, idev->mc_maxdelay);
+			mld_ifc_start_timer(idev, idev->mc_uri);
 	}
 	in6_dev_put(idev);
 }
@@ -2481,8 +2481,8 @@ static void ipv6_mc_reset(struct inet6_dev *idev)
 	idev->mc_qrv = sysctl_mld_qrv;
 	idev->mc_qi = MLD_QI_DEFAULT;
 	idev->mc_qri = MLD_QRI_DEFAULT;
+	idev->mc_uri = unsolicited_report_interval(idev);
 	idev->mc_v1_seen = 0;
-	idev->mc_maxdelay = unsolicited_report_interval(idev);
 }
 
 /* Device going up */
-- 
1.7.11.7
