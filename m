From: Thomas Egerer <thomas.egerer@secunet.com>
Subject: [PATCH iproute2 3/3] xfrm_{state,policy}: Allow to deleteall
 polices/states with marks
Date: Mon, 30 Oct 2017 19:11:46 +0100
Message-ID: <97621e2c-30e3-aba3-ed5a-71241d94ec26@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:58734 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752807AbdJ3SNN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Oct 2017 14:13:13 -0400
Received: from localhost (localhost [127.0.0.1])
        by a.mx.secunet.com (Postfix) with ESMTP id C69D0201D3
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 19:13:12 +0100 (CET)
Received: from a.mx.secunet.com ([127.0.0.1])
        by localhost (a.mx.secunet.com [127.0.0.1]) (amavisd-new, port 10024)
        with ESMTP id jL6bA501nw0i for <netdev@vger.kernel.org>;
        Mon, 30 Oct 2017 19:13:09 +0100 (CET)
Received: from mail-essen-01.secunet.de (mail-essen-01.secunet.de [10.53.40.204])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by a.mx.secunet.com (Postfix) with ESMTPS id 4C744201D1
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 19:13:09 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using 'ip deleteall' with policies that have marks, fails unless you
eplicitely specify the mark values. This is very uncomfortable when
bulk-deleting policies and states. With this patch all relevant states
and policies are wiped by 'ip deleteall' regardless of their mark
values.

Signed-off-by: Thomas Egerer <thomas.egerer@secunet.com>
---
 ip/xfrm_policy.c |  9 +++++++++
 ip/xfrm_state.c  | 12 ++++++++++++
 2 files changed, 21 insertions(+)

diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index e2fa771..d544026 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -753,6 +753,15 @@ static int xfrm_policy_keep(const struct sockaddr_nl *who,
 	xpid->dir = xpinfo->dir;
 	xpid->index = xpinfo->index;
 
+	if (tb[XFRMA_MARK]) {
+		int r = addattr_l(new_n, xb->size, XFRMA_MARK,
+				(void *)RTA_DATA(tb[XFRMA_MARK]), tb[XFRMA_MARK]->rta_len);
+		if (r < 0) {
+			fprintf(stderr, "%s: XFRMA_MARK failed\n", __func__);
+			exit(1);
+		}
+	}
+
 	xb->offset += new_n->nlmsg_len;
 	xb->nlmsg_count++;
 
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 3e20d6e..85d959c 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -1081,6 +1081,7 @@ static int xfrm_state_keep(const struct sockaddr_nl *who,
 	int len = n->nlmsg_len;
 	struct nlmsghdr *new_n;
 	struct xfrm_usersa_id *xsid;
+	struct rtattr *tb[XFRMA_MAX+1];
 
 	if (n->nlmsg_type != XFRM_MSG_NEWSA) {
 		fprintf(stderr, "Not a state: %08x %08x %08x\n",
@@ -1117,6 +1118,17 @@ static int xfrm_state_keep(const struct sockaddr_nl *who,
 	addattr_l(new_n, xb->size, XFRMA_SRCADDR, &xsinfo->saddr,
 		  sizeof(xsid->daddr));
 
+	parse_rtattr(tb, XFRMA_MAX, XFRMS_RTA(xsinfo), len);
+
+	if (tb[XFRMA_MARK]) {
+		int r = addattr_l(new_n, xb->size, XFRMA_MARK,
+				(void *)RTA_DATA(tb[XFRMA_MARK]), tb[XFRMA_MARK]->rta_len);
+		if (r < 0) {
+			fprintf(stderr, "%s: XFRMA_MARK failed\n", __func__);
+			exit(1);
+		}
+	}
+
 	xb->offset += new_n->nlmsg_len;
 	xb->nlmsg_count++;
 
-- 
2.6.4
