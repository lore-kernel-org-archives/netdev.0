From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v2 iproute2] lib: Dump ext-ack string by default
Date: Tue,  8 Aug 2017 07:30:14 -0700
Message-ID: <1502202614-389-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:37207 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751880AbdHHOaX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 10:30:23 -0400
Received: by mail-pf0-f194.google.com with SMTP id p13so3210075pfd.4
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 07:30:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In time, errfn can be implemented for link, route, etc commands to
give a much more detailed response (e.g., point to the attribute
that failed). Doing so is much more complicated to process the
message and convert attribute ids to names.

In any case the error string returned by the kernel should be dumped
to the user, so make that happen now.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
v2
- check that errmsg is non-null

 lib/libnetlink.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 145de2cb0ccf..063f5cd6c7b1 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -61,7 +61,6 @@ static int err_attr_cb(const struct nlattr *attr, void *data)
 	return MNL_CB_OK;
 }
 
-
 /* dump netlink extended ack error message */
 static int nl_dump_ext_err(const struct nlmsghdr *nlh, nl_ext_ack_fn_t errfn)
 {
@@ -72,9 +71,6 @@ static int nl_dump_ext_err(const struct nlmsghdr *nlh, nl_ext_ack_fn_t errfn)
 	const char *errmsg = NULL;
 	uint32_t off = 0;
 
-	if (!errfn)
-		return 0;
-
 	/* no TLVs, nothing to do here */
 	if (!(nlh->nlmsg_flags & NLM_F_ACK_TLVS))
 		return 0;
@@ -99,7 +95,16 @@ static int nl_dump_ext_err(const struct nlmsghdr *nlh, nl_ext_ack_fn_t errfn)
 			err_nlh = &err->msg;
 	}
 
-	return errfn(errmsg, off, err_nlh);
+	if (errfn)
+		return errfn(errmsg, off, err_nlh);
+
+	if (errmsg) {
+		fprintf(stderr, "Error: %s\n", errmsg);
+
+		return 1;
+	}
+
+	return 0;
 }
 #else
 #warning "libmnl required for error support"
-- 
2.1.4
