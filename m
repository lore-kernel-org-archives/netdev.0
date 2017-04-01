From: Vladislav Yasevich <vyasevic@redhat.com>
Subject: [PATCH v2] ip: Add support for netdev events to monitor
Date: Fri, 31 Mar 2017 22:50:27 -0400
Message-ID: <1491015027-1141-1-git-send-email-vyasevic@redhat.com>
Cc: roopa@cumulusnetworks.com, dsa@cumulusnetworks.com,
        davem@davemloft.net, Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60254 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750816AbdDACua (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 31 Mar 2017 22:50:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add IFLA_EVENT handling so that event types can be viewed with
'moniotr' command.  This gives a little more information for why
a given message was recevied.

V2: Adds all events recently proposed.  This way all currently supported
 events can be viewed.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 include/linux/if_link.h | 19 +++++++++++++++++++
 ip/ipaddress.c          | 29 +++++++++++++++++++++++++++++
 2 files changed, 48 insertions(+)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index b0bdbd6..6cc0b36 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -157,6 +157,7 @@ enum {
 	IFLA_GSO_MAX_SIZE,
 	IFLA_PAD,
 	IFLA_XDP,
+	IFLA_EVENT,
 	__IFLA_MAX
 };
 
@@ -890,4 +891,22 @@ enum {
 
 #define IFLA_XDP_MAX (__IFLA_XDP_MAX - 1)
 
+enum {
+	IFLA_EVENT_UNSPEC,
+	IFLA_EVENT_REBOOT,
+	IFLA_EVENT_CHANGE_MTU,
+	IFLA_EVENT_CHANGE_NAME,
+	IFLA_EVENT_FEAT_CHANGE,
+	IFLA_EVENT_BONDING_FAILOVER,
+	IFLA_EVENT_NOTIFY_PEERS,
+	IFLA_EVENT_CHANGE_UPPER,
+	IFLA_EVENT_RESEND_IGMP,
+	IFLA_EVENT_PRE_CHANGE_MTU,
+	IFLA_EVENT_CHANGE_INFO_DATA,
+	IFLA_EVENT_PRE_CHANGE_UPPER,
+	IFLA_EVENT_CHANGE_LOWER_STATE,
+	IFLA_EVENT_UDP_TUNNEL_PUSH_INFO,
+	IFLA_EVENT_CHANGE_TX_QUEUE_LEN,
+};
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index b8d9c7d..dfe93f3 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -753,6 +753,32 @@ int print_linkinfo_brief(const struct sockaddr_nl *who,
 	return 0;
 }
 
+static const char *netdev_events[] = {"UNKNONWN",
+				      "REBOOT",
+				      "CHANGE_MTU",
+				      "CHANGE_NAME",
+				      "FEATURE_CHANGE",
+				      "BONDING_FAILOVER",
+				      "NOTIFY_PEERS",
+				      "CHANGE_UPPER",
+				      "RESEND_IGMP",
+				      "PRE_CHANGE_MTU",
+				      "CHANGE_INFO_DATA",
+				      "PRE_CHANGE_UPPER",
+				      "CHANGE_LOWER_STATE",
+				      "UDP_TUNNEL_PUSH_INFO",
+				      "CHANGE_TXQUEUE_LEN"};
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
@@ -858,6 +884,9 @@ int print_linkinfo(const struct sockaddr_nl *who,
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
