From: Thomas Egerer <thomas.egerer@secunet.com>
Subject: [PATCH iproute2 3/3] xfrm_{state,policy}: Allow to deleteall
 polices/states with marks
Date: Wed, 1 Nov 2017 10:52:54 +0100
Message-ID: <d87947e6-39b4-cd5d-3ad7-b76da4eebd51@secunet.com>
References: <97621e2c-30e3-aba3-ed5a-71241d94ec26@secunet.com>
 <20171031181359.5b868f1a@shemminger-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:59818 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754467AbdKAJyV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 05:54:21 -0400
In-Reply-To: <20171031181359.5b868f1a@shemminger-XPS-13-9360>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using 'ip deleteall' with policies that have marks, fails unless you
eplicitely specify the mark values. This is very uncomfortable when
bulk-deleting policies and states. With this patch all relevant states
and policies are wiped by 'ip deleteall' regardless of their mark
values.

Signed-off-by: Thomas Egerer <thomas.egerer@secunet.com>
---
 ip/xfrm_policy.c | 10 ++++++++++
 ip/xfrm_state.c  | 13 +++++++++++++
 2 files changed, 23 insertions(+)

diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index e2fa771..feea7d6 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -753,6 +753,16 @@ static int xfrm_policy_keep(const struct sockaddr_nl *who,
 	xpid->dir = xpinfo->dir;
 	xpid->index = xpinfo->index;
 
+	if (tb[XFRMA_MARK]) {
+		int r = addattr_l(new_n, xb->size, XFRMA_MARK,
+				  RTA_DATA(tb[XFRMA_MARK]),
+				  RTA_PAYLOAD(tb[XFRMA_MARK]));
+		if (r < 0) {
+			fprintf(stderr, "%s: XFRMA_MARK failed\n", __func__);
+			exit(1);
+		}
+	}
+
 	xb->offset += new_n->nlmsg_len;
 	xb->nlmsg_count++;
 
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 3e20d6e..e193623 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -1081,6 +1081,7 @@ static int xfrm_state_keep(const struct sockaddr_nl *who,
 	int len = n->nlmsg_len;
 	struct nlmsghdr *new_n;
 	struct xfrm_usersa_id *xsid;
+	struct rtattr *tb[XFRMA_MAX+1];
 
 	if (n->nlmsg_type != XFRM_MSG_NEWSA) {
 		fprintf(stderr, "Not a state: %08x %08x %08x\n",
@@ -1117,6 +1118,18 @@ static int xfrm_state_keep(const struct sockaddr_nl *who,
 	addattr_l(new_n, xb->size, XFRMA_SRCADDR, &xsinfo->saddr,
 		  sizeof(xsid->daddr));
 
+	parse_rtattr(tb, XFRMA_MAX, XFRMS_RTA(xsinfo), len);
+
+	if (tb[XFRMA_MARK]) {
+		int r = addattr_l(new_n, xb->size, XFRMA_MARK,
+						  RTA_DATA(tb[XFRMA_MARK]),
+						  RTA_PAYLOAD(tb[XFRMA_MARK]));
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
