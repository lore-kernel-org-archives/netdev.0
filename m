From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH net-next 1/2] net: diag: slightly refactor the inet_diag_bc_audit error checks.
Date: Wed, 24 Aug 2016 03:06:10 +0900
Message-ID: <1471975571-26612-1-git-send-email-lorenzo@google.com>
Cc: eric.dumazet@gmail.com, dsa@cumulusnetworks.com,
        davem@davemloft.net, Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:35227 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752859AbcHWSGS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 14:06:18 -0400
Received: by mail-pf0-f179.google.com with SMTP id x72so45976207pfd.2
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 11:06:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This simplifies the code a bit and also allows inet_diag_bc_audit
to send to userspace an error that isn't EINVAL.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 net/ipv4/inet_diag.c | 35 ++++++++++++++++++++++++-----------
 1 file changed, 24 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 38c2c47..a835f94 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -706,10 +706,23 @@ static bool valid_port_comparison(const struct inet_diag_bc_op *op,
 	return true;
 }
 
-static int inet_diag_bc_audit(const void *bytecode, int bytecode_len)
+static bool valid_markcond(const struct inet_diag_bc_op *op, int len,
+			   int *min_len)
 {
-	const void *bc = bytecode;
-	int  len = bytecode_len;
+	*min_len += sizeof(struct inet_diag_markcond);
+	return len >= *min_len;
+}
+
+static int inet_diag_bc_audit(struct nlattr *attr)
+{
+	const void *bytecode, *bc;
+	int bytecode_len, len;
+
+	if (!attr || nla_len(attr) < sizeof(struct inet_diag_bc_op))
+		return -EINVAL;
+
+	bytecode = bc = nla_data(attr);
+	len = bytecode_len = nla_len(attr);
 
 	while (len > 0) {
 		int min_len = sizeof(struct inet_diag_bc_op);
@@ -1020,13 +1033,13 @@ static int inet_diag_rcv_msg_compat(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
 		if (nlmsg_attrlen(nlh, hdrlen)) {
 			struct nlattr *attr;
+			int err;
 
 			attr = nlmsg_find_attr(nlh, hdrlen,
 					       INET_DIAG_REQ_BYTECODE);
-			if (!attr ||
-			    nla_len(attr) < sizeof(struct inet_diag_bc_op) ||
-			    inet_diag_bc_audit(nla_data(attr), nla_len(attr)))
-				return -EINVAL;
+			err = inet_diag_bc_audit(attr);
+			if (err)
+				return err;
 		}
 		{
 			struct netlink_dump_control c = {
@@ -1051,13 +1064,13 @@ static int inet_diag_handler_cmd(struct sk_buff *skb, struct nlmsghdr *h)
 	    h->nlmsg_flags & NLM_F_DUMP) {
 		if (nlmsg_attrlen(h, hdrlen)) {
 			struct nlattr *attr;
+			int err;
 
 			attr = nlmsg_find_attr(h, hdrlen,
 					       INET_DIAG_REQ_BYTECODE);
-			if (!attr ||
-			    nla_len(attr) < sizeof(struct inet_diag_bc_op) ||
-			    inet_diag_bc_audit(nla_data(attr), nla_len(attr)))
-				return -EINVAL;
+			err = inet_diag_bc_audit(attr);
+			if (err)
+				return err;
 		}
 		{
 			struct netlink_dump_control c = {
-- 
2.8.0.rc3.226.g39d4020
