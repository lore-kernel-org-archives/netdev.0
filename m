From: William Manley <william.manley@youview.com>
Subject: [PATCH 2/2] net: igmp: Allow user-space configuration of igmp unsolicited report interval
Date: Thu, 25 Jul 2013 13:14:05 +0100
Message-ID: <1374754445-5608-2-git-send-email-william.manley@youview.com>
References: <1374527349.1635.55.camel@bwh-desktop.uk.level5networks.com>
 <1374754445-5608-1-git-send-email-william.manley@youview.com>
Cc: William Manley <william.manley@youview.com>
To: netdev@vger.kernel.org, bcrl@kvack.org, hannes@stressinduktion.org,
	luky-37@hotmail.com, sergei.shtylyov@cogentembedded.com,
	bhutchings@solarflare.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:49230 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755382Ab3GYMOm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 08:14:42 -0400
In-Reply-To: <1374754445-5608-1-git-send-email-william.manley@youview.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds a new procfs knob:

    /proc/sys/net/ipv4/conf/*/force_igmp_unsolicited_report_interval

Which will allow userspace configuration of the IGMP unsolicited report
interval (see below) in milliseconds.  The default is -1 which means use
default behaviour (10s for IGMPv3 and 1s for IGMPv2 in accordance with
RFC2236 and RFC3376).

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

force_igmp_unsolicited_report_interval is intended to follow the pattern
established by force_igmp_version, and while a procfs entry has been added
a corresponding sysctl knob has not as it is my understanding that sysctl
is deprecated[1].

[1]: http://lwn.net/Articles/247243/

Signed-off-by: William Manley <william.manley@youview.com>
---
 include/linux/inetdevice.h |    2 ++
 net/ipv4/devinet.c         |    4 ++++
 net/ipv4/igmp.c            |   13 ++++++++++++-
 3 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index ea1e3b8..d8019f5 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -30,6 +30,7 @@ enum
 	IPV4_DEVCONF_NOXFRM,
 	IPV4_DEVCONF_NOPOLICY,
 	IPV4_DEVCONF_FORCE_IGMP_VERSION,
+	IPV4_DEVCONF_FORCE_IGMP_UNSOLICITED_REPORT_INTERVAL,
 	IPV4_DEVCONF_ARP_ANNOUNCE,
 	IPV4_DEVCONF_ARP_IGNORE,
 	IPV4_DEVCONF_PROMOTE_SECONDARIES,
@@ -62,6 +63,7 @@ struct in_device {
 	unsigned long		mr_v1_seen;
 	unsigned long		mr_v2_seen;
 	unsigned long		mr_maxdelay;
+	unsigned long		mr_unsolicited_report_interval;
 	unsigned char		mr_qrv;
 	unsigned char		mr_gq_running;
 	unsigned char		mr_ifc_count;
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index dfc39d4..cd9b0f1 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -73,6 +73,7 @@ static struct ipv4_devconf ipv4_devconf = {
 		[IPV4_DEVCONF_SEND_REDIRECTS - 1] = 1,
 		[IPV4_DEVCONF_SECURE_REDIRECTS - 1] = 1,
 		[IPV4_DEVCONF_SHARED_MEDIA - 1] = 1,
+		[IPV4_DEVCONF_FORCE_IGMP_UNSOLICITED_REPORT_INTERVAL - 1] = -1,
 	},
 };
 
@@ -83,6 +84,7 @@ static struct ipv4_devconf ipv4_devconf_dflt = {
 		[IPV4_DEVCONF_SECURE_REDIRECTS - 1] = 1,
 		[IPV4_DEVCONF_SHARED_MEDIA - 1] = 1,
 		[IPV4_DEVCONF_ACCEPT_SOURCE_ROUTE - 1] = 1,
+		[IPV4_DEVCONF_FORCE_IGMP_UNSOLICITED_REPORT_INTERVAL - 1] = -1,
 	},
 };
 
@@ -2099,6 +2101,8 @@ static struct devinet_sysctl_table {
 		DEVINET_SYSCTL_FLUSHING_ENTRY(NOPOLICY, "disable_policy"),
 		DEVINET_SYSCTL_FLUSHING_ENTRY(FORCE_IGMP_VERSION,
 					      "force_igmp_version"),
+		DEVINET_SYSCTL_FLUSHING_ENTRY(FORCE_IGMP_UNSOLICITED_REPORT_INTERVAL,
+					      "force_igmp_unsolicited_report_interval"),
 		DEVINET_SYSCTL_FLUSHING_ENTRY(PROMOTE_SECONDARIES,
 					      "promote_secondaries"),
 		DEVINET_SYSCTL_FLUSHING_ENTRY(ROUTE_LOCALNET,
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 12ffc2b..4f681ff 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -141,7 +141,18 @@
 
 static int unsolicited_report_interval(struct in_device *in_dev)
 {
-	if (IGMP_V2_SEEN(in_dev))
+	int interval_ms = IPV4_DEVCONF_ALL(
+		dev_net(in_dev->dev),
+		FORCE_IGMP_UNSOLICITED_REPORT_INTERVAL);
+	if (interval_ms >= 0) {
+		/* _timer functions can't handle a delay of 0 jiffies so ensure
+		 *  we always return a positive value.
+		 */
+		int interval_jiffies = msecs_to_jiffies(interval_ms);
+		if (interval_jiffies == 0)
+			interval_jiffies = 1;
+		return interval_jiffies;
+	} else if (IGMP_V2_SEEN(in_dev))
 		return IGMP_V2_Unsolicited_Report_Interval;
 	else /* v3 */
 		return IGMP_V3_Unsolicited_Report_Interval;
-- 
1.7.10.4
