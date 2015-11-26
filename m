From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH RFC] libnetlink: introduce DECLARE_NLREQ
Date: Thu, 26 Nov 2015 14:26:05 +0100
Message-ID: <1448544365-23153-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:51623 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751106AbbKZN0S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Nov 2015 08:26:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This macro aims to simplify most netlink users' pattern to prepare a
request, which is to create an unnamed struct and initialize it:

| struct {
|	struct nlmsghdr n;
|	struct whatever foo;
|	char buf[arbitrary number];
| } req;
|
| memset(&req, 0, sizeof(req));
| req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct whatever));
| req.n.nlmsg_flags = NLM_F_REQUEST;

Having this patch applied, the above can be replaced by a static
initializer like so:

| DECLARE_NLREQ(req, n, struct whatever foo, arbitrary number);

There is an added benefit, as well: Due to explicit alignment, the
requested tailroom is really as big as requested no matter what size
struct whatever really is.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
This patch is RFC because I want to wait for peer review and upstream
acceptance before sending in the big refactoring patch itself.
---
 include/libnetlink.h | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/libnetlink.h b/include/libnetlink.h
index 2280c39c670a4..7e12a7b12b55d 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -196,5 +196,16 @@ int rtnl_from_file(FILE *, rtnl_listen_filter_t handler,
  * messages from dump file */
 #define NLMSG_TSTAMP	15
 
+/* declare a netlink request with initial payload */
+#define DECLARE_NLREQ(name, hdrname, payload, tailroom)                       \
+	struct {                                                              \
+		struct nlmsghdr hdrname;                                      \
+		payload;                                                      \
+		char __b[tailroom] __attribute__((aligned(NLMSG_ALIGNTO)));   \
+	} name = { .hdrname = {                                               \
+		.nlmsg_len = (unsigned long)&name.__b - (unsigned long)&name, \
+		.nlmsg_flags = NLM_F_REQUEST,                                 \
+	}}
+
 #endif /* __LIBNETLINK_H__ */
 
-- 
2.5.0
