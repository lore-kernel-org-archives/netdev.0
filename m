From: Flavio Leitner <fleitner@redhat.com>
Subject: [PATCH] bonding: fix to rejoin multicast groups immediately
Date: Wed, 29 Sep 2010 04:12:07 -0300
Message-ID: <1285744327-1194-1-git-send-email-fleitner@redhat.com>
Cc: Flavio Leitner <fleitner@redhat.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15921 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751756Ab0I2HMN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Sep 2010 03:12:13 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o8T7CDEU006334
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 29 Sep 2010 03:12:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It should rejoin multicast groups immediately when
the failover happens to restore the multicast traffic.

Signed-off-by: Flavio Leitner <fleitner@redhat.com>
---
 net/ipv4/igmp.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 1fdcacd..b81d674 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1257,14 +1257,14 @@ void ip_mc_rejoin_group(struct ip_mc_list *im)
 	if (im->multiaddr == IGMP_ALL_HOSTS)
 		return;
 
-	if (IGMP_V1_SEEN(in_dev) || IGMP_V2_SEEN(in_dev)) {
-		igmp_mod_timer(im, IGMP_Initial_Report_Delay);
-		return;
-	}
-	/* else, v3 */
-	im->crcount = in_dev->mr_qrv ? in_dev->mr_qrv :
-		IGMP_Unsolicited_Report_Count;
-	igmp_ifc_event(in_dev);
+	/* a failover is happening and switches
+	 * must be notified immediately */
+	if (IGMP_V1_SEEN(in_dev))
+		igmp_send_report(in_dev, im, IGMP_HOST_MEMBERSHIP_REPORT);
+	else if (IGMP_V2_SEEN(in_dev))
+		igmp_send_report(in_dev, im, IGMPV2_HOST_MEMBERSHIP_REPORT);
+	else
+		igmp_send_report(in_dev, im, IGMPV3_HOST_MEMBERSHIP_REPORT);
 #endif
 }
 EXPORT_SYMBOL(ip_mc_rejoin_group);
-- 
1.7.2.3

