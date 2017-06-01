From: Vladislav Yasevich <vyasevic@redhat.com>
Subject: [PATCH V7 net-next iproute] ip: Add IFLA_EVENT output to ip monitor
Date: Thu,  1 Jun 2017 11:01:16 -0400
Message-ID: <1496329276-31106-1-git-send-email-vyasevic@redhat.com>
Cc: stephen@networkplumber.org, dsahern@gmail.com,
        Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56804 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751091AbdFAPBV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 11:01:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add IFLA_EVENT output so that event types can be viewed with
'monitor' command.  This gives a little more information for why
a given message was received.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
v7: change the names to make it more generic then just netdev events.
    Updated initialization.

 include/linux/if_link.h | 11 +++++++++++
 ip/ipaddress.c          | 22 ++++++++++++++++++++++
 2 files changed, 33 insertions(+)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 5a3a048..c0a6769 100644
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
+	IFLA_EVENT_NONE,
+	IFLA_EVENT_REBOOT,		/* internal reset / reboot */
+	IFLA_EVENT_FEATURES,		/* change in offload features */
+	IFLA_EVENT_BONDING_FAILOVER,	/* hange in active slave */
+	IFLA_EVENT_NOTIFY_PEERS,	/* re-sent grat. arp/ndisc */
+	IFLA_EVENT_IGMP_RESEND,		/* re-sent IGMP JOIN */
+	IFLA_EVENT_BONDING_OPTIONS,	/* change in bonding options */
+};
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index b8d9c7d..cea4389 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -753,6 +753,25 @@ int print_linkinfo_brief(const struct sockaddr_nl *who,
 	return 0;
 }
 
+static const char *link_events[] = {
+	[IFLA_EVENT_NONE] = "NONE",
+	[IFLA_EVENT_REBOOT] = "REBOOT",
+	[IFLA_EVENT_FEATURES] = "FEATURE CHANGE",
+	[IFLA_EVENT_BONDING_FAILOVER] = "BONDING FAILOVER",
+	[IFLA_EVENT_NOTIFY_PEERS] = "NOTIFY PEERS",
+	[IFLA_EVENT_IGMP_RESEND] = "RESEND IGMP",
+	[IFLA_EVENT_BONDING_OPTIONS] = "BONDING OPTION"};
+
+static void print_link_event(FILE *f, __u32 event)
+{
+	if (event >= ARRAY_SIZE(link_events))
+		fprintf(f, "event %d ", event);
+	else {
+		if (event)
+			fprintf(f, "event %s ", link_events[event]);
+	}
+}
+
 int print_linkinfo(const struct sockaddr_nl *who,
 		   struct nlmsghdr *n, void *arg)
 {
@@ -858,6 +877,9 @@ int print_linkinfo(const struct sockaddr_nl *who,
 	if (filter.showqueue)
 		print_queuelen(fp, tb);
 
+	if (tb[IFLA_EVENT])
+		print_link_event(fp, rta_getattr_u32(tb[IFLA_EVENT]));
+
 	if (!filter.family || filter.family == AF_PACKET || show_details) {
 		SPRINT_BUF(b1);
 		fprintf(fp, "%s", _SL_);
-- 
2.7.4
