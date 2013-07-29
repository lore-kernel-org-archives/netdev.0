From: William Manley <william.manley@youview.com>
Subject: [PATCH v3 2/2] net: igmp: Allow user-space configuration of igmp unsolicited report interval
Date: Mon, 29 Jul 2013 15:21:51 +0100
Message-ID: <1375107711-9029-2-git-send-email-william.manley@youview.com>
References: <20130726163610.GF3890@order.stressinduktion.org>
 <1375107711-9029-1-git-send-email-william.manley@youview.com>
Cc: William Manley <william.manley@youview.com>
To: netdev@vger.kernel.org, bcrl@kvack.org, hannes@stressinduktion.org,
	luky-37@hotmail.com, sergei.shtylyov@cogentembedded.com,
	bhutchings@solarflare.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:50812 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752355Ab3G2OWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 10:22:39 -0400
In-Reply-To: <1375107711-9029-1-git-send-email-william.manley@youview.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds the new procfs knobs:

    /proc/sys/net/ipv4/conf/*/igmpv2_unsolicited_report_interval
    /proc/sys/net/ipv4/conf/*/igmpv3_unsolicited_report_interval

Which will allow userspace configuration of the IGMP unsolicited report
interval (see below) in milliseconds.  The default 1000ms for IGMPv2 and
10000 for IGMPv3 in accordance with RFC2236 and RFC3376.

Background:

If an IGMP join packet is lost you will not receive data sent to the
multicast group so if no data arrives from that multicast group in a
period of time after the IGMP join a second IGMP join will be sent.  The
delay between joins is the "IGMP Unsolicited Report Interval".

Prior to this patch this value was hard coded in the kernel to 10s for
IGMPv2 and 1s for IGMPv3.  10s is unsuitable for some use-cases, such as
IPTV as it can cause channel change to be slow in the presence of packet
loss.

This patch allows the value to be overridden from userspace changed for
both IGMPv2 and IGMPv3 such that it can be tuned accoding to the network.

Tested with Wireshark and a simple program to join a (non-existent)
multicast group.  The distribution of timings for the second join differ
based upon setting
/proc/sys/net/ipv4/conf/eth0/force_igmp_unsolicited_report_interval.

igmpvX_unsolicited_report_interval is intended to follow the pattern
established by force_igmp_version, and while a procfs entry has been added
a corresponding sysctl knob has not as it is my understanding that sysctl
is deprecated[1].

[1]: http://lwn.net/Articles/247243/

Signed-off-by: William Manley <william.manley@youview.com>
---
 include/linux/inetdevice.h |    4 ++++
 net/ipv4/devinet.c         |    8 ++++++++
 net/ipv4/igmp.c            |   19 +++++++++++++++++--
 3 files changed, 29 insertions(+), 2 deletions(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index ea1e3b8..d100e4c 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -30,6 +30,8 @@ enum
 	IPV4_DEVCONF_NOXFRM,
 	IPV4_DEVCONF_NOPOLICY,
 	IPV4_DEVCONF_FORCE_IGMP_VERSION,
+	IPV4_DEVCONF_IGMPV2_UNSOLICITED_REPORT_INTERVAL,
+	IPV4_DEVCONF_IGMPV3_UNSOLICITED_REPORT_INTERVAL,
 	IPV4_DEVCONF_ARP_ANNOUNCE,
 	IPV4_DEVCONF_ARP_IGNORE,
 	IPV4_DEVCONF_PROMOTE_SECONDARIES,
@@ -62,6 +64,8 @@ struct in_device {
 	unsigned long		mr_v1_seen;
 	unsigned long		mr_v2_seen;
 	unsigned long		mr_maxdelay;
+	unsigned long		mr_v2_unsolicited_report_interval;
+	unsigned long		mr_v3_unsolicited_report_interval;
 	unsigned char		mr_qrv;
 	unsigned char		mr_gq_running;
 	unsigned char		mr_ifc_count;
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index dfc39d4..f681518 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -73,6 +73,8 @@ static struct ipv4_devconf ipv4_devconf = {
 		[IPV4_DEVCONF_SEND_REDIRECTS - 1] = 1,
 		[IPV4_DEVCONF_SECURE_REDIRECTS - 1] = 1,
 		[IPV4_DEVCONF_SHARED_MEDIA - 1] = 1,
+		[IPV4_DEVCONF_IGMPV2_UNSOLICITED_REPORT_INTERVAL - 1] = 10000 /*ms*/,
+		[IPV4_DEVCONF_IGMPV3_UNSOLICITED_REPORT_INTERVAL - 1] =  1000 /*ms*/,
 	},
 };
 
@@ -83,6 +85,8 @@ static struct ipv4_devconf ipv4_devconf_dflt = {
 		[IPV4_DEVCONF_SECURE_REDIRECTS - 1] = 1,
 		[IPV4_DEVCONF_SHARED_MEDIA - 1] = 1,
 		[IPV4_DEVCONF_ACCEPT_SOURCE_ROUTE - 1] = 1,
+		[IPV4_DEVCONF_IGMPV2_UNSOLICITED_REPORT_INTERVAL - 1] = 10000 /*ms*/,
+		[IPV4_DEVCONF_IGMPV3_UNSOLICITED_REPORT_INTERVAL - 1] =  1000 /*ms*/,
 	},
 };
 
@@ -2099,6 +2103,10 @@ static struct devinet_sysctl_table {
 		DEVINET_SYSCTL_FLUSHING_ENTRY(NOPOLICY, "disable_policy"),
 		DEVINET_SYSCTL_FLUSHING_ENTRY(FORCE_IGMP_VERSION,
 					      "force_igmp_version"),
+		DEVINET_SYSCTL_FLUSHING_ENTRY(IGMPV2_UNSOLICITED_REPORT_INTERVAL,
+					      "igmpv2_unsolicited_report_interval"),
+		DEVINET_SYSCTL_FLUSHING_ENTRY(IGMPV3_UNSOLICITED_REPORT_INTERVAL,
+					      "igmpv3_unsolicited_report_interval"),
 		DEVINET_SYSCTL_FLUSHING_ENTRY(PROMOTE_SECONDARIES,
 					      "promote_secondaries"),
 		DEVINET_SYSCTL_FLUSHING_ENTRY(ROUTE_LOCALNET,
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 9f0aaea..035ee77 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -141,10 +141,25 @@
 
 static int unsolicited_report_interval(struct in_device *in_dev)
 {
+	int interval_ms, interval_jiffies;
+
 	if (IGMP_V1_SEEN(in_dev) || IGMP_V2_SEEN(in_dev))
-		return IGMP_V2_Unsolicited_Report_Interval;
+		interval_ms = IPV4_DEVCONF_ALL(
+			dev_net(in_dev->dev),
+			IGMPV2_UNSOLICITED_REPORT_INTERVAL);
 	else /* v3 */
-		return IGMP_V3_Unsolicited_Report_Interval;
+		interval_ms = IPV4_DEVCONF_ALL(
+			dev_net(in_dev->dev),
+			IGMPV3_UNSOLICITED_REPORT_INTERVAL);
+
+	interval_jiffies = msecs_to_jiffies(interval_ms);
+
+	/* _timer functions can't handle a delay of 0 jiffies so ensure
+	 *  we always return a positive value.
+	 */
+	if (interval_jiffies <= 0)
+		interval_jiffies = 1;
+	return interval_jiffies;
 }
 
 static void igmpv3_add_delrec(struct in_device *in_dev, struct ip_mc_list *im);
-- 
1.7.10.4
