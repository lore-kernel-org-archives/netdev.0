From: Flavio Leitner <fleitner@redhat.com>
Subject: [PATCH 2/3] bonding: fix to rejoin multicast groups immediately
Date: Tue,  5 Oct 2010 21:23:58 -0300
Message-ID: <1286324639-22314-2-git-send-email-fleitner@redhat.com>
References: <20101005220757.GB19931@redhat.com>
Cc: bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	Flavio Leitner <fleitner@redhat.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17970 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757955Ab0JFAYY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Oct 2010 20:24:24 -0400
In-Reply-To: <20101005220757.GB19931@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The IGMP specs states that if the system receives a
membership report, it shouldn't send another for the
next minute. However, if a link failure happens right
after that, the backup slave and the switch connected
to this slave will not know about the multicast and
the traffic will hang for about a minute.

This patch fixes it to rejoin multicast groups immediately
after a failover restoring the multicast traffic.

Signed-off-by: Flavio Leitner <fleitner@redhat.com>
---
 net/ipv4/igmp.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 2a4bb76..25f3396 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1269,14 +1269,14 @@ void ip_mc_rejoin_group(struct ip_mc_list *im)
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
1.7.0.1

