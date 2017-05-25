From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH V5 iproute] ip: Add support for netdev events to monitor
Date: Thu, 25 May 2017 11:31:56 -0400
Message-ID: <1495726316-27626-4-git-send-email-vyasevic@redhat.com>
References: <1495726316-27626-1-git-send-email-vyasevic@redhat.com>
Cc: dsahern@gmail.com, roopa@cumulusnetworks.com, jiri@resnulli.us,
        vfalico@gmail.com, andy@greyhouse.net,
        Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:35768 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965382AbdEYPcW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 11:32:22 -0400
Received: by mail-qk0-f193.google.com with SMTP id k74so30608199qke.2
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 08:32:21 -0700 (PDT)
In-Reply-To: <1495726316-27626-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add IFLA_EVENT handling so that event types can be viewed with
'monitor' command.  This gives a little more information for why
a given message was receivied.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 include/linux/if_link.h | 11 +++++++++++
 ip/ipaddress.c          | 21 +++++++++++++++++++++
 2 files changed, 32 insertions(+)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 5a3a048..7e10274 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -157,6 +157,7 @@ enum {
 	IFLA_GSO_MAX_SIZE,
 	IFLA_PAD,
 	IFLA_XDP,
+	IFLA_EVENT,
 	__IFLA_MAX
 };
 
@@ -909,4 +910,14 @@ enum {
 
 #define IFLA_XDP_MAX (__IFLA_XDP_MAX - 1)
 
+enum {
+	IFLA_EVENT_UNSPEC,
+	IFLA_EVENT_REBOOT,
+	IFLA_EVENT_FEAT_CHANGE,
+	IFLA_EVENT_BONDING_FAILOVER,
+	IFLA_EVENT_NOTIFY_PEERS,
+	IFLA_EVENT_RESEND_IGMP,
+	IFLA_EVENT_CHANGE_INFO_DATA,
+};
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index b8d9c7d..d37b4b2 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -753,6 +753,24 @@ int print_linkinfo_brief(const struct sockaddr_nl *who,
 	return 0;
 }
 
+static const char *netdev_events[] = {"UNKNOWN",
+				      "REBOOT",
+				      "FEATURE_CHANGE",
+				      "BONDING_FAILOVER",
+				      "NOTIFY_PEERS",
+				      "RESEND_IGMP",
+				      "CHANGE_INFO_DATA"};
+
+static void print_dev_event(FILE *f, __u32 event)
+{
+	if (event >= ARRAY_SIZE(netdev_events))
+		fprintf(f, "event %d ", event);
+	else {
+		if (event)
+			fprintf(f, "event %s ", netdev_events[event]);
+	}
+}
+
 int print_linkinfo(const struct sockaddr_nl *who,
 		   struct nlmsghdr *n, void *arg)
 {
@@ -858,6 +876,9 @@ int print_linkinfo(const struct sockaddr_nl *who,
 	if (filter.showqueue)
 		print_queuelen(fp, tb);
 
+	if (tb[IFLA_EVENT])
+		print_dev_event(fp, rta_getattr_u32(tb[IFLA_EVENT]));
+
 	if (!filter.family || filter.family == AF_PACKET || show_details) {
 		SPRINT_BUF(b1);
 		fprintf(fp, "%s", _SL_);
-- 
2.7.4
