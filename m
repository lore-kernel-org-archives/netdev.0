From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 v2 03/21] iplink: bridge: export read-only timers
Date: Tue,  9 Feb 2016 00:14:21 +0100
Message-ID: <1454973279-9170-4-git-send-email-razor@blackwall.org>
References: <1454973279-9170-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:36353 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932478AbcBHXOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 18:14:47 -0500
Received: by mail-wm0-f46.google.com with SMTP id p63so135606284wmp.1
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 15:14:46 -0800 (PST)
In-Reply-To: <1454973279-9170-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Netlink already provides hello_timer, tcn_timer, topology_change_timer
and gc_timer, so let's make them visible.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v2: export timers in seconds.milliseconds format as per Stephen's comment

 include/utils.h    | 18 ++++++++++++++++++
 ip/iplink_bridge.c | 34 ++++++++++++++++++++++++++++++++++
 2 files changed, 52 insertions(+)

diff --git a/include/utils.h b/include/utils.h
index 7310f4e0e5db..c43427c35a6c 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -175,6 +175,24 @@ static inline __u32 nl_mgrp(__u32 group)
 	return group ? (1 << (group - 1)) : 0;
 }
 
+/* courtesy of bridge-utils */
+static inline unsigned long __tv_to_jiffies(const struct timeval *tv)
+{
+	unsigned long long jif;
+
+	jif = 1000000ULL * tv->tv_sec + tv->tv_usec;
+
+	return jif/10000;
+}
+
+static inline void __jiffies_to_tv(struct timeval *tv, unsigned long jiffies)
+{
+	unsigned long long tvusec;
+
+	tvusec = 10000ULL*jiffies;
+	tv->tv_sec = tvusec/1000000;
+	tv->tv_usec = tvusec - 1000000 * tv->tv_sec;
+}
 
 int print_timestamp(FILE *fp);
 void print_nlmsg_timestamp(FILE *fp, const struct nlmsghdr *n);
diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index 33ffa6c27f03..cd1655751417 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -197,6 +197,40 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_BR_TOPOLOGY_CHANGE_DETECTED])
 		fprintf(f, "topology_change_detected %u ",
 			rta_getattr_u8(tb[IFLA_BR_TOPOLOGY_CHANGE_DETECTED]));
+
+	if (tb[IFLA_BR_HELLO_TIMER]) {
+		struct timeval tv;
+
+		__jiffies_to_tv(&tv, rta_getattr_u64(tb[IFLA_BR_HELLO_TIMER]));
+		fprintf(f, "hello_timer %4i.%.2i ", (int)tv.tv_sec,
+			(int)tv.tv_usec/10000);
+	}
+
+	if (tb[IFLA_BR_TCN_TIMER]) {
+		struct timeval tv;
+
+		__jiffies_to_tv(&tv, rta_getattr_u64(tb[IFLA_BR_TCN_TIMER]));
+		fprintf(f, "tcn_timer %4i.%.2i ", (int)tv.tv_sec,
+			(int)tv.tv_usec/10000);
+	}
+
+	if (tb[IFLA_BR_TOPOLOGY_CHANGE_TIMER]) {
+		unsigned long jiffies;
+		struct timeval tv;
+
+		jiffies = rta_getattr_u64(tb[IFLA_BR_TOPOLOGY_CHANGE_TIMER]);
+		__jiffies_to_tv(&tv, jiffies);
+		fprintf(f, "topology_change_timer %4i.%.2i ", (int)tv.tv_sec,
+			(int)tv.tv_usec/10000);
+	}
+
+	if (tb[IFLA_BR_GC_TIMER]) {
+		struct timeval tv;
+
+		__jiffies_to_tv(&tv, rta_getattr_u64(tb[IFLA_BR_GC_TIMER]));
+		fprintf(f, "gc_timer %4i.%.2i ", (int)tv.tv_sec,
+			(int)tv.tv_usec/10000);
+	}
 }
 
 static void bridge_print_help(struct link_util *lu, int argc, char **argv,
-- 
2.4.3
