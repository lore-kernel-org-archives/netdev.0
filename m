From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 1/7] color: introduce color helpers and COLOR_CLEAR
Date: Tue, 22 Mar 2016 19:35:13 +0100
Message-ID: <1458671719-14361-2-git-send-email-phil@nwl.cc>
References: <1458671719-14361-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:53853 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751364AbcCVSgQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2016 14:36:16 -0400
In-Reply-To: <1458671719-14361-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds two helper functions which map a given data field to a color,
so color_fprintf() statements don't have to be duplicated with only a
different color value depending on that data field's value. In order for
this to work in a generic way, COLOR_CLEAR has been added to serve as a
fallback default of uncolored output.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 include/color.h |  5 ++++-
 ip/ipaddress.c  | 47 +++++++++++++----------------------------------
 lib/color.c     | 30 +++++++++++++++++++++++++++++-
 3 files changed, 46 insertions(+), 36 deletions(-)

diff --git a/include/color.h b/include/color.h
index b85003aed19f8..c1c29831159af 100644
--- a/include/color.h
+++ b/include/color.h
@@ -7,10 +7,13 @@ enum color_attr {
 	COLOR_INET,
 	COLOR_INET6,
 	COLOR_OPERSTATE_UP,
-	COLOR_OPERSTATE_DOWN
+	COLOR_OPERSTATE_DOWN,
+	COLOR_CLEAR
 };
 
 void enable_color(void);
 int color_fprintf(FILE *fp, enum color_attr attr, const char *fmt, ...);
+enum color_attr ifa_family_color(__u8 ifa_family);
+enum color_attr oper_state_color(__u8 state);
 
 #endif
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index f8c5029400949..7aab8e781eae8 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -135,25 +135,15 @@ static const char *oper_states[] = {
 
 static void print_operstate(FILE *f, __u8 state)
 {
-	if (state >= ARRAY_SIZE(oper_states))
+	if (state >= ARRAY_SIZE(oper_states)) {
 		fprintf(f, "state %#x ", state);
-	else {
-		if (brief) {
-			if (strcmp(oper_states[state], "UP") == 0)
-				color_fprintf(f, COLOR_OPERSTATE_UP, "%-14s ", oper_states[state]);
-			else if (strcmp(oper_states[state], "DOWN") == 0)
-				color_fprintf(f, COLOR_OPERSTATE_DOWN, "%-14s ", oper_states[state]);
-			else
-				fprintf(f, "%-14s ", oper_states[state]);
-		} else {
-			fprintf(f, "state ");
-			if (strcmp(oper_states[state], "UP") == 0)
-				color_fprintf(f, COLOR_OPERSTATE_UP, "%s ", oper_states[state]);
-			else if (strcmp(oper_states[state], "DOWN") == 0)
-				color_fprintf(f, COLOR_OPERSTATE_DOWN, "%s ", oper_states[state]);
-			else
-				fprintf(f, "%s ", oper_states[state]);
-		}
+	} else if (brief) {
+		color_fprintf(f, oper_state_color(state),
+		              "%-14s ", oper_states[state]);
+	} else {
+		fprintf(f, "state ");
+		color_fprintf(f, oper_state_color(state),
+		              "%s ", oper_states[state]);
 	}
 }
 
@@ -1067,22 +1057,11 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 	}
 
 	if (rta_tb[IFA_LOCAL]) {
-		if (ifa->ifa_family == AF_INET)
-			color_fprintf(fp, COLOR_INET, "%s", format_host(ifa->ifa_family,
-						RTA_PAYLOAD(rta_tb[IFA_LOCAL]),
-						RTA_DATA(rta_tb[IFA_LOCAL]),
-						abuf, sizeof(abuf)));
-		else if (ifa->ifa_family == AF_INET6)
-			color_fprintf(fp, COLOR_INET6, "%s", format_host(ifa->ifa_family,
-						RTA_PAYLOAD(rta_tb[IFA_LOCAL]),
-						RTA_DATA(rta_tb[IFA_LOCAL]),
-						abuf, sizeof(abuf)));
-		else
-			fprintf(fp, "%s", format_host(ifa->ifa_family,
-						RTA_PAYLOAD(rta_tb[IFA_LOCAL]),
-						RTA_DATA(rta_tb[IFA_LOCAL]),
-						abuf, sizeof(abuf)));
-
+		color_fprintf(fp, ifa_family_color(ifa->ifa_family), "%s",
+		              format_host(ifa->ifa_family,
+		                          RTA_PAYLOAD(rta_tb[IFA_LOCAL]),
+		                          RTA_DATA(rta_tb[IFA_LOCAL]),
+		                          abuf, sizeof(abuf)));
 		if (rta_tb[IFA_ADDRESS] == NULL ||
 		    memcmp(RTA_DATA(rta_tb[IFA_ADDRESS]), RTA_DATA(rta_tb[IFA_LOCAL]),
 			   ifa->ifa_family == AF_INET ? 4 : 16) == 0) {
diff --git a/lib/color.c b/lib/color.c
index 8c9a48ba702bf..95596be236a05 100644
--- a/lib/color.c
+++ b/lib/color.c
@@ -1,5 +1,8 @@
 #include <stdio.h>
 #include <stdarg.h>
+#include <sys/socket.h>
+#include <sys/types.h>
+#include <linux/if.h>
 
 #include "color.h"
 
@@ -32,7 +35,8 @@ static enum color attr_colors[] = {
 	C_MAGENTA,
 	C_BLUE,
 	C_GREEN,
-	C_RED
+	C_RED,
+	C_CLEAR
 };
 
 static int color_is_enabled;
@@ -62,3 +66,27 @@ end:
 	va_end(args);
 	return ret;
 }
+
+enum color_attr ifa_family_color(__u8 ifa_family)
+{
+	switch (ifa_family) {
+	case AF_INET:
+		return COLOR_INET;
+	case AF_INET6:
+		return COLOR_INET6;
+	default:
+		return COLOR_CLEAR;
+	}
+}
+
+enum color_attr oper_state_color(__u8 state)
+{
+	switch (state) {
+	case IF_OPER_UP:
+		return COLOR_OPERSTATE_UP;
+	case IF_OPER_DOWN:
+		return COLOR_OPERSTATE_DOWN;
+	default:
+		return COLOR_CLEAR;
+	}
+}
-- 
2.7.2
