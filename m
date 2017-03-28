From: Vladislav Yasevich <vyasevic@redhat.com>
Subject: [PATCH iproute] ip: Add support for netdev events to monitor
Date: Tue, 28 Mar 2017 10:13:16 -0400
Message-ID: <1490710396-2086-1-git-send-email-vyasevic@redhat.com>
Cc: Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60422 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752580AbdC1OW2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Mar 2017 10:22:28 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 02D6C3DBD4
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 14:13:20 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add MTU_CHANGED and NOTIFY_PEER events that can be viewed with
'moniotr' command.  This gives a little more information for why
a given notification was recevied.  More events can be be added
later.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 include/linux/if_link.h |  7 +++++++
 ip/ipaddress.c          | 15 +++++++++++++++
 2 files changed, 22 insertions(+)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index b0bdbd6..6b232a1 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -157,6 +157,7 @@ enum {
 	IFLA_GSO_MAX_SIZE,
 	IFLA_PAD,
 	IFLA_XDP,
+	IFLA_EVENT,
 	__IFLA_MAX
 };
 
@@ -890,4 +891,10 @@ enum {
 
 #define IFLA_XDP_MAX (__IFLA_XDP_MAX - 1)
 
+enum {
+	IFLA_EVENT_UNSPEC,
+	IFLA_EVENT_CHANGE_MTU,
+	IFLA_EVENT_NOTIFY_PEERS,
+};
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index b8d9c7d..ac6b182 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -753,6 +753,18 @@ int print_linkinfo_brief(const struct sockaddr_nl *who,
 	return 0;
 }
 
+static const char *netdev_events[] = {"UNKNONWN", "MTU_CHANGE", "NOTIFY_PEERS"};
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
@@ -858,6 +870,9 @@ int print_linkinfo(const struct sockaddr_nl *who,
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
