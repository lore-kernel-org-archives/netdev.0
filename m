From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 2/20] [PATCH] [XFRM] IPV6: Support Mobile IPv6 extension headers sorting.
Date: Sat, 29 Jul 2006 18:38:16 +0900
Message-ID: <1154165896150-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:36483 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1422709AbWG2JiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:38:17 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Support Mobile IPv6 extension headers sorting for two transformation policies.
Mobile IPv6 extension headers should be placed after IPsec
transport mode, but before transport AH when outbound.
---
 net/ipv6/xfrm6_state.c |   28 ++++++++++++++++++++++++++--
 1 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index 1a5cc65..8d431ab 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -178,7 +178,19 @@ __xfrm6_state_sort(struct xfrm_state **d
 	if (j == n)
 		goto end;
 
-	/* XXX: Rule 2: select MIPv6 RO or inbound trigger */
+	/* Rule 2: select MIPv6 RO or inbound trigger */
+#ifdef CONFIG_IPV6_MIP6
+	for (i = 0; i < n; i++) {
+		if (src[i] &&
+		    (src[i]->props.mode == XFRM_MODE_ROUTEOPTIMIZATION ||
+		     src[i]->props.mode == XFRM_MODE_IN_TRIGGER)) {
+			dst[j++] = src[i];
+			src[i] = NULL;
+		}
+	}
+	if (j == n)
+		goto end;
+#endif
 
 	/* Rule 3: select IPsec transport AH */
 	for (i = 0; i < n; i++) {
@@ -231,7 +243,19 @@ __xfrm6_tmpl_sort(struct xfrm_tmpl **dst
 	if (j == n)
 		goto end;
 
-	/* XXX: Rule 2: select MIPv6 RO or inbound trigger */
+	/* Rule 2: select MIPv6 RO or inbound trigger */
+#ifdef CONFIG_IPV6_MIP6
+	for (i = 0; i < n; i++) {
+		if (src[i] &&
+		    (src[i]->mode == XFRM_MODE_ROUTEOPTIMIZATION ||
+		     src[i]->mode == XFRM_MODE_IN_TRIGGER)) {
+			dst[j++] = src[i];
+			src[i] = NULL;
+		}
+	}
+	if (j == n)
+		goto end;
+#endif
 
 	/* Rule 3: select IPsec tunnel */
 	for (i = 0; i < n; i++) {
-- 
1.4.1

