From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/3] libnetlink: introduce rta_nest and u8,u16,u64 helpers for nesting within rtattr
Date: Thu, 15 Oct 2015 13:13:38 +0200
Message-ID: <da2d3d3f6b5241e383ca88a00cff2e0e21e796c4.1444907416.git.tgraf@suug.ch>
References: <cover.1444907416.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	jbenc@redhat.com, mengke.liu@intel.com, tom@herbertland.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:45931 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750946AbbJOLNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 07:13:47 -0400
In-Reply-To: <cover.1444907416.git.tgraf@suug.ch>
In-Reply-To: <cover.1444907416.git.tgraf@suug.ch>
References: <cover.1444907416.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch introduces two new api's rta_nest and rta_nest_end to
nest attributes inside a rta attribute represented by 'struct rtattr'
as required to construct a nexthop. Also adds rta_addattr* variants
for u8, u16 and u64 as needed to support encapsulation.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/libnetlink.h | 10 ++++++++++
 lib/libnetlink.c     | 31 +++++++++++++++++++++++++++++++
 2 files changed, 41 insertions(+)

diff --git a/include/libnetlink.h b/include/libnetlink.h
index 0503dea..407440d 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -86,7 +86,10 @@ int addattr_nest_end(struct nlmsghdr *n, struct rtattr *nest);
 struct rtattr *addattr_nest_compat(struct nlmsghdr *n, int maxlen, int type,
 				   const void *data, int len);
 int addattr_nest_compat_end(struct nlmsghdr *n, struct rtattr *nest);
+int rta_addattr8(struct rtattr *rta, int maxlen, int type, __u8 data);
+int rta_addattr16(struct rtattr *rta, int maxlen, int type, __u16 data);
 int rta_addattr32(struct rtattr *rta, int maxlen, int type, __u32 data);
+int rta_addattr64(struct rtattr *rta, int maxlen, int type, __u64 data);
 int rta_addattr_l(struct rtattr *rta, int maxlen, int type,
 		  const void *data, int alen);
 
@@ -98,6 +101,13 @@ int parse_rtattr_byindex(struct rtattr *tb[], int max,
 struct rtattr *parse_rtattr_one(int type, struct rtattr *rta, int len);
 int __parse_rtattr_nested_compat(struct rtattr *tb[], int max, struct rtattr *rta, int len);
 
+struct rtattr *rta_nest(struct rtattr *rta, int maxlen, int type);
+int rta_nest_end(struct rtattr *rta, struct rtattr *nest);
+
+#define RTA_TAIL(rta) \
+		((struct rtattr *) (((void *) (rta)) + \
+				    RTA_ALIGN((rta)->rta_len)))
+
 #define parse_rtattr_nested(tb, max, rta) \
 	(parse_rtattr((tb), (max), RTA_DATA(rta), RTA_PAYLOAD(rta)))
 
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 46cac34..8430033 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -721,6 +721,37 @@ int rta_addattr_l(struct rtattr *rta, int maxlen, int type,
 	return 0;
 }
 
+int rta_addattr8(struct rtattr *rta, int maxlen, int type, __u8 data)
+{
+	return rta_addattr_l(rta, maxlen, type, &data, sizeof(__u8));
+}
+
+int rta_addattr16(struct rtattr *rta, int maxlen, int type, __u16 data)
+{
+	return rta_addattr_l(rta, maxlen, type, &data, sizeof(__u16));
+}
+
+int rta_addattr64(struct rtattr *rta, int maxlen, int type, __u64 data)
+{
+	return rta_addattr_l(rta, maxlen, type, &data, sizeof(__u64));
+}
+
+struct rtattr *rta_nest(struct rtattr *rta, int maxlen, int type)
+{
+	struct rtattr *nest = RTA_TAIL(rta);
+
+	rta_addattr_l(rta, maxlen, type, NULL, 0);
+
+	return nest;
+}
+
+int rta_nest_end(struct rtattr *rta, struct rtattr *nest)
+{
+	nest->rta_len = (void *)RTA_TAIL(rta) - (void *)nest;
+
+	return rta->rta_len;
+}
+
 int parse_rtattr(struct rtattr *tb[], int max, struct rtattr *rta, int len)
 {
 	return parse_rtattr_flags(tb, max, rta, len, 0);
-- 
2.4.3
