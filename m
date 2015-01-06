From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 1/2] libnetlink: add parse_rtattr_one_nested helper
Date: Tue,  6 Jan 2015 17:23:45 +0100
Message-ID: <1420561426-3118-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, thaller@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:58078 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753148AbbAFQ3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 11:29:01 -0500
Received: by mail-we0-f170.google.com with SMTP id w61so9906835wes.1
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 08:29:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sometimes, it is more convenient to get only one specific nested attribute by
type. For example for IFLA_AF_SPEC where type is address family (AF_INET6).
So add this helper for this purpose.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/libnetlink.h |  4 ++++
 lib/libnetlink.c     | 12 ++++++++++++
 2 files changed, 16 insertions(+)

diff --git a/include/libnetlink.h b/include/libnetlink.h
index fe7d5d3..f0faf2d 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -80,11 +80,15 @@ extern int parse_rtattr(struct rtattr *tb[], int max, struct rtattr *rta, int le
 extern int parse_rtattr_flags(struct rtattr *tb[], int max, struct rtattr *rta,
 			      int len, unsigned short flags);
 extern int parse_rtattr_byindex(struct rtattr *tb[], int max, struct rtattr *rta, int len);
+extern struct rtattr *parse_rtattr_one(int type, struct rtattr *rta, int len);
 extern int __parse_rtattr_nested_compat(struct rtattr *tb[], int max, struct rtattr *rta, int len);
 
 #define parse_rtattr_nested(tb, max, rta) \
 	(parse_rtattr((tb), (max), RTA_DATA(rta), RTA_PAYLOAD(rta)))
 
+#define parse_rtattr_one_nested(type, rta) \
+	(parse_rtattr_one(type, RTA_DATA(rta), RTA_PAYLOAD(rta)))
+
 #define parse_rtattr_nested_compat(tb, max, rta, data, len) \
 	({ data = RTA_PAYLOAD(rta) >= len ? RTA_DATA(rta) : NULL;	\
 		__parse_rtattr_nested_compat(tb, max, rta, len); })
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 8d504a9..8e70263 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -701,6 +701,18 @@ int parse_rtattr_byindex(struct rtattr *tb[], int max, struct rtattr *rta, int l
 	return i;
 }
 
+struct rtattr *parse_rtattr_one(int type, struct rtattr *rta, int len)
+{
+	while (RTA_OK(rta, len)) {
+		if (rta->rta_type == type)
+			return rta;
+		rta = RTA_NEXT(rta, len);
+	}
+	if (len)
+		fprintf(stderr, "!!!Deficit %d, rta_len=%d\n", len, rta->rta_len);
+	return NULL;
+}
+
 int __parse_rtattr_nested_compat(struct rtattr *tb[], int max, struct rtattr *rta,
 			         int len)
 {
-- 
1.9.3
