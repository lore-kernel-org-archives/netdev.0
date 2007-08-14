From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH 1/2] IPROUTE2: RTNETLINK nested attributes
Date: Tue, 14 Aug 2007 11:21:19 -0700
Message-ID: <20070814182119.3800.6371.stgit@localhost.localdomain>
References: <20070814182111.3800.38619.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:5847 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764240AbXHNSVV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 14:21:21 -0400
In-Reply-To: <20070814182111.3800.38619.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

This adds capability for iproute2 to send nested attributes to the
kernel, while maintaining backwards compatibility.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---

 include/libnetlink.h |    9 +++++++++
 lib/libnetlink.c     |   46 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 55 insertions(+), 0 deletions(-)

diff --git a/include/libnetlink.h b/include/libnetlink.h
index 49e248e..b67c5a5 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -39,15 +39,24 @@ extern int rtnl_send(struct rtnl_handle *rth, const char *buf, int);
 extern int addattr32(struct nlmsghdr *n, int maxlen, int type, __u32 data);
 extern int addattr_l(struct nlmsghdr *n, int maxlen, int type, const void *data, int alen);
 extern int addraw_l(struct nlmsghdr *n, int maxlen, const void *data, int len);
+extern struct rtattr *addattr_nest(struct nlmsghdr *n, int maxlen, int type);
+extern int addattr_nest_end(struct nlmsghdr *n, struct rtattr *nest);
+extern struct rtattr *addattr_nest_compat(struct nlmsghdr *n, int maxlen, int type, const void *data, int len);
+extern int addattr_nest_compat_end(struct nlmsghdr *n, struct rtattr *nest);
 extern int rta_addattr32(struct rtattr *rta, int maxlen, int type, __u32 data);
 extern int rta_addattr_l(struct rtattr *rta, int maxlen, int type, const void *data, int alen);
 
 extern int parse_rtattr(struct rtattr *tb[], int max, struct rtattr *rta, int len);
 extern int parse_rtattr_byindex(struct rtattr *tb[], int max, struct rtattr *rta, int len);
+extern int __parse_rtattr_nested_compat(struct rtattr *tb[], int max, struct rtattr *rta, int len);
 
 #define parse_rtattr_nested(tb, max, rta) \
 	(parse_rtattr((tb), (max), RTA_DATA(rta), RTA_PAYLOAD(rta)))
 
+#define parse_rtattr_nested_compat(tb, max, rta, data, len) \
+({	data = RTA_PAYLOAD(rta) >= len ? RTA_DATA(rta) : NULL; \
+	__parse_rtattr_nested_compat(tb, max, rta, len); })
+
 extern int rtnl_listen(struct rtnl_handle *, rtnl_filter_t handler,
 		       void *jarg);
 extern int rtnl_from_file(FILE *, rtnl_filter_t handler,
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 555dd5c..12883fe 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -527,6 +527,39 @@ int addraw_l(struct nlmsghdr *n, int maxlen, const void *data, int len)
 	return 0;
 }
 
+struct rtattr *addattr_nest(struct nlmsghdr *n, int maxlen, int type)
+{
+	struct rtattr *nest = NLMSG_TAIL(n);
+
+	addattr_l(n, maxlen, type, NULL, 0);
+	return nest;
+}
+
+int addattr_nest_end(struct nlmsghdr *n, struct rtattr *nest)
+{
+	nest->rta_len = (void *)NLMSG_TAIL(n) - (void *)nest;
+	return n->nlmsg_len;
+}
+
+struct rtattr *addattr_nest_compat(struct nlmsghdr *n, int maxlen, int type,
+				   const void *data, int len)
+{
+	struct rtattr *start = NLMSG_TAIL(n);
+
+	addattr_l(n, maxlen, type, data, len);
+	addattr_nest(n, maxlen, type);
+	return start;
+}
+
+int addattr_nest_compat_end(struct nlmsghdr *n, struct rtattr *start)
+{
+	struct rtattr *nest = (void *)start + NLMSG_ALIGN(start->rta_len);
+
+	start->rta_len = (void *)NLMSG_TAIL(n) - (void *)start;
+	addattr_nest_end(n, nest);
+	return n->nlmsg_len;
+}
+
 int rta_addattr32(struct rtattr *rta, int maxlen, int type, __u32 data)
 {
 	int len = RTA_LENGTH(4);
@@ -589,3 +622,16 @@ int parse_rtattr_byindex(struct rtattr *tb[], int max, struct rtattr *rta, int l
 		fprintf(stderr, "!!!Deficit %d, rta_len=%d\n", len, rta->rta_len);
 	return i;
 }
+
+int __parse_rtattr_nested_compat(struct rtattr *tb[], int max, struct rtattr *rta,
+			         int len)
+{
+	if (RTA_PAYLOAD(rta) < len)
+		return -1;
+	if (RTA_PAYLOAD(rta) >= RTA_ALIGN(len) + sizeof(struct rtattr)) {
+		rta = RTA_DATA(rta) + RTA_ALIGN(len);
+		return parse_rtattr_nested(tb, max, rta);
+	}
+	memset(tb, 0, sizeof(struct rtattr *) * max);
+	return 0;
+}
