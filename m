From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 23/23] [PATCH] [XFRM] IPV6: Add sort functions to combine templates/states for IPsec.
Date: Sat, 29 Jul 2006 18:30:58 +0900
Message-ID: <1154165458989-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:34435 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1422704AbWG2Ja7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:30:59 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add sort functions to combine templates/states for IPsec.
Think of outbound transformation order we should be careful with transport AH
which must be the last of all transport ones.
---
 net/ipv6/xfrm6_state.c |  101 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 101 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index d141030..1a5cc65 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -160,6 +160,103 @@ #endif
 	return x0;
 }
 
+#ifdef CONFIG_XFRM_SUB_POLICY
+static int
+__xfrm6_state_sort(struct xfrm_state **dst, struct xfrm_state **src, int n)
+{
+	int i;
+	int j = 0;
+
+	/* Rule 1: select IPsec transport except AH */
+	for (i = 0; i < n; i++) {
+		if (src[i]->props.mode == XFRM_MODE_TRANSPORT &&
+		    src[i]->id.proto != IPPROTO_AH) {
+			dst[j++] = src[i];
+			src[i] = NULL;
+		}
+	}
+	if (j == n)
+		goto end;
+
+	/* XXX: Rule 2: select MIPv6 RO or inbound trigger */
+
+	/* Rule 3: select IPsec transport AH */
+	for (i = 0; i < n; i++) {
+		if (src[i] &&
+		    src[i]->props.mode == XFRM_MODE_TRANSPORT &&
+		    src[i]->id.proto == IPPROTO_AH) {
+			dst[j++] = src[i];
+			src[i] = NULL;
+		}
+	}
+	if (j == n)
+		goto end;
+
+	/* Rule 4: select IPsec tunnel */
+	for (i = 0; i < n; i++) {
+		if (src[i] &&
+		    src[i]->props.mode == XFRM_MODE_TUNNEL) {
+			dst[j++] = src[i];
+			src[i] = NULL;
+		}
+	}
+	if (likely(j == n))
+		goto end;
+
+	/* Final rule */
+	for (i = 0; i < n; i++) {
+		if (src[i]) {
+			dst[j++] = src[i];
+			src[i] = NULL;
+		}
+	}
+
+ end:
+	return 0;
+}
+
+static int
+__xfrm6_tmpl_sort(struct xfrm_tmpl **dst, struct xfrm_tmpl **src, int n)
+{
+	int i;
+	int j = 0;
+
+	/* Rule 1: select IPsec transport */
+	for (i = 0; i < n; i++) {
+		if (src[i]->mode == XFRM_MODE_TRANSPORT) {
+			dst[j++] = src[i];
+			src[i] = NULL;
+		}
+	}
+	if (j == n)
+		goto end;
+
+	/* XXX: Rule 2: select MIPv6 RO or inbound trigger */
+
+	/* Rule 3: select IPsec tunnel */
+	for (i = 0; i < n; i++) {
+		if (src[i] &&
+		    src[i]->mode == XFRM_MODE_TUNNEL) {
+			dst[j++] = src[i];
+			src[i] = NULL;
+		}
+	}
+	if (likely(j == n))
+		goto end;
+
+	/* Final rule */
+	for (i = 0; i < n; i++) {
+		if (src[i]) {
+			dst[j++] = src[i];
+			src[i] = NULL;
+		}
+	}
+
+ end:
+	return 0;
+}
+#endif
+
 static struct xfrm_state_afinfo xfrm6_state_afinfo = {
 	.family			= AF_INET6,
 	.lock			= RW_LOCK_UNLOCKED,
@@ -169,6 +266,10 @@ #ifdef CONFIG_XFRM_ADVANCED
 	.state_lookup_byaddr	= __xfrm6_state_lookup_byaddr,
 #endif
 	.find_acq		= __xfrm6_find_acq,
+#ifdef CONFIG_XFRM_SUB_POLICY
+	.tmpl_sort		= __xfrm6_tmpl_sort,
+	.state_sort		= __xfrm6_state_sort,
+#endif
 };
 
 void __init xfrm6_state_init(void)
-- 
1.4.1

