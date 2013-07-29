From: William Manley <william.manley@youview.com>
Subject: [PATCH v3 1/2] net: igmp: Reduce Unsolicited report interval to 1s when using IGMPv3
Date: Mon, 29 Jul 2013 15:21:50 +0100
Message-ID: <1375107711-9029-1-git-send-email-william.manley@youview.com>
References: <20130726163610.GF3890@order.stressinduktion.org>
Cc: William Manley <william.manley@youview.com>
To: netdev@vger.kernel.org, bcrl@kvack.org, hannes@stressinduktion.org,
	luky-37@hotmail.com, sergei.shtylyov@cogentembedded.com,
	bhutchings@solarflare.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:37923 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750857Ab3G2OWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 10:22:30 -0400
In-Reply-To: <20130726163610.GF3890@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an IGMP join packet is lost you will not receive data sent to the
multicast group so if no data arrives from that multicast group in a
period of time after the IGMP join a second IGMP join will be sent.  The
delay between joins is the "IGMP Unsolicited Report Interval".

Previously this value was hard coded to be chosen randomly between 0-10s.
This can be too long for some use-cases, such as IPTV as it can cause
channel change to be slow in the presence of packet loss.

The value 10s has come from IGMPv2 RFC2236, which was reduced to 1s in
IGMPv3 RFC3376.  This patch makes the kernel use the 1s value from the
later RFC if we are operating in IGMPv3 mode.  IGMPv2 behaviour is
unaffected.

Tested with Wireshark and a simple program to join a (non-existent)
multicast group.  The distribution of timings for the second join differ
based upon setting /proc/sys/net/ipv4/conf/eth0/force_igmp_version.

Signed-off-by: William Manley <william.manley@youview.com>
---
 net/ipv4/igmp.c |   16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index d8c2327..9f0aaea 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -113,7 +113,8 @@
 
 #define IGMP_V1_Router_Present_Timeout		(400*HZ)
 #define IGMP_V2_Router_Present_Timeout		(400*HZ)
-#define IGMP_Unsolicited_Report_Interval	(10*HZ)
+#define IGMP_V2_Unsolicited_Report_Interval	(10*HZ)
+#define IGMP_V3_Unsolicited_Report_Interval	(1*HZ)
 #define IGMP_Query_Response_Interval		(10*HZ)
 #define IGMP_Unsolicited_Report_Count		2
 
@@ -138,6 +139,14 @@
 	 ((in_dev)->mr_v2_seen && \
 	  time_before(jiffies, (in_dev)->mr_v2_seen)))
 
+static int unsolicited_report_interval(struct in_device *in_dev)
+{
+	if (IGMP_V1_SEEN(in_dev) || IGMP_V2_SEEN(in_dev))
+		return IGMP_V2_Unsolicited_Report_Interval;
+	else /* v3 */
+		return IGMP_V3_Unsolicited_Report_Interval;
+}
+
 static void igmpv3_add_delrec(struct in_device *in_dev, struct ip_mc_list *im);
 static void igmpv3_del_delrec(struct in_device *in_dev, __be32 multiaddr);
 static void igmpv3_clear_delrec(struct in_device *in_dev);
@@ -719,7 +728,8 @@ static void igmp_ifc_timer_expire(unsigned long data)
 	igmpv3_send_cr(in_dev);
 	if (in_dev->mr_ifc_count) {
 		in_dev->mr_ifc_count--;
-		igmp_ifc_start_timer(in_dev, IGMP_Unsolicited_Report_Interval);
+		igmp_ifc_start_timer(in_dev,
+				     unsolicited_report_interval(in_dev));
 	}
 	__in_dev_put(in_dev);
 }
@@ -744,7 +754,7 @@ static void igmp_timer_expire(unsigned long data)
 
 	if (im->unsolicit_count) {
 		im->unsolicit_count--;
-		igmp_start_timer(im, IGMP_Unsolicited_Report_Interval);
+		igmp_start_timer(im, unsolicited_report_interval(in_dev));
 	}
 	im->reporter = 1;
 	spin_unlock(&im->lock);
-- 
1.7.10.4
