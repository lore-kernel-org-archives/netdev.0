From: David Ahern <dsahern@gmail.com>
Subject: [PATCH iproute2] libnetlink: Fix extack attribute parsing
Date: Thu, 17 Aug 2017 13:43:00 -0700
Message-ID: <1503002580-21267-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:37807 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753259AbdHQUnJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 16:43:09 -0400
Received: by mail-pg0-f66.google.com with SMTP id 83so11550819pgb.4
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 13:43:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initialize tb in nl_dump_ext_err since not all attributes will be
sent in the messages.

Add error checking on mnl_attr_parse and print messages on the off
chance the ext ack attributes fail to validate.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 lib/libnetlink.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 81a344abff27..874e660be7eb 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -49,13 +49,17 @@ static int err_attr_cb(const struct nlattr *attr, void *data)
 	const struct nlattr **tb = data;
 	uint16_t type;
 
-	if (mnl_attr_type_valid(attr, NLMSGERR_ATTR_MAX) < 0)
+	if (mnl_attr_type_valid(attr, NLMSGERR_ATTR_MAX) < 0) {
+		fprintf(stderr, "Invalid extack attribute\n");
 		return MNL_CB_ERROR;
+	}
 
 	type = mnl_attr_get_type(attr);
-	if (mnl_attr_validate(attr, extack_policy[type]) < 0)
+	if (mnl_attr_validate(attr, extack_policy[type]) < 0) {
+		fprintf(stderr, "extack attribute %d failed validation\n",
+			type);
 		return MNL_CB_ERROR;
-
+	}
 
 	tb[type] = attr;
 	return MNL_CB_OK;
@@ -64,7 +68,7 @@ static int err_attr_cb(const struct nlattr *attr, void *data)
 /* dump netlink extended ack error message */
 static int nl_dump_ext_err(const struct nlmsghdr *nlh, nl_ext_ack_fn_t errfn)
 {
-	struct nlattr *tb[NLMSGERR_ATTR_MAX + 1];
+	struct nlattr *tb[NLMSGERR_ATTR_MAX + 1] = {};
 	const struct nlmsgerr *err = mnl_nlmsg_get_payload(nlh);
 	const struct nlmsghdr *err_nlh = NULL;
 	unsigned int hlen = sizeof(*err);
@@ -79,7 +83,8 @@ static int nl_dump_ext_err(const struct nlmsghdr *nlh, nl_ext_ack_fn_t errfn)
 	if (!(nlh->nlmsg_flags & NLM_F_CAPPED))
 		hlen += mnl_nlmsg_get_payload_len(&err->msg);
 
-	mnl_attr_parse(nlh, hlen, err_attr_cb, tb);
+	if (mnl_attr_parse(nlh, hlen, err_attr_cb, tb) != MNL_CB_OK)
+		return 0;
 
 	if (tb[NLMSGERR_ATTR_MSG])
 		errmsg = mnl_attr_get_str(tb[NLMSGERR_ATTR_MSG]);
-- 
2.1.4
