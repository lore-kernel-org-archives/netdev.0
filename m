From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 44/44] [XFRM] IPV6: Support Mobile IPv6 extension headers sorting.
Date: Thu, 24 Aug 2006 00:02:45 +0900
Message-ID: <11563453682841-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org> <1156345366288-git-send-email-yoshfuji@linux-ipv6.org> <1156345366857-git-send-email-yoshfuji@linux-ipv6.org> <11563453663761-git-send-email-yoshfuji@linux-ipv6.org> <11563453662321-git-send-email-yoshfuji@linux-ipv6.org>
  <11563453661892-git-send-email-yoshfuji@linux-ipv6.org> <11563453661207-git-send-email-yoshfuji@linux-ipv6.org> <11563453663743-git-send-email-yoshfuji@linux-ipv6.org> <1156345366676-git-send-email-yoshfuji@linux-ipv6.org> <11563453662840-git-send-email-yoshfuji@linux-ipv6.org> <11563453662913-git-send-email-yoshfuji@linux-ipv6.org> <11563453663400-git-send-email-yoshfuji@linux-ipv6.org> <1156345366549-git-send-email-yoshfuji@linux-ipv6.org> <11563453662956-git-send-email-yoshfuji@linux-ipv6.org> <11563453661764-git-send-email-yoshfuji@linux-ipv6.org> <11563453663275-git-send-email-yoshfuji@linux-ipv6.org> <11563453671174-git-send-email-yoshfuji@linux-ipv6.org> <11563453674049-git-send-email-yoshfuji@linux-ipv6.org> <11563453673517-git-send-email-yoshfuji@linux-ipv6.org> <11563453674137-git-send-email-yoshfuji@linux-ipv6.org> <11563453671944-git-send-email-yoshfuji@linux-ipv6.org> <11
 563453671187-git-send-email-yoshfuji@linux-ipv6.org> <11563453672959-git-send-email-yoshfuji@linux-ipv6.org> <1156345367208-git-send-email-yoshfuji@linux-ipv6.org> <11563453673786-git-send-email-yoshfuji@linux-ipv6.org> <11563453672531-git-send-email-yoshfuji@linux-ipv6.org> <11563453674194-git-send-email-yoshfuji@linux-ipv6.org> <11563453671463-git-send-email-yoshfuji@linux-ipv6.org> <11563453672872-git-send-email-yoshfuji@linux-ipv6.org> <11563453671273-git-send-email-yoshfuji@linux-ipv6.org> <11563453674024-git-send-email-yoshfuji@linux-ipv6.org> <11563453673854-git-send-email-yoshfuji@linux-ipv6.org> <11563453681815-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:12425 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964962AbWHWPCw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:52 -0400
To: davem@davemloft.net
In-Reply-To: <11563453681815-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Support Mobile IPv6 extension headers sorting for two transformation policies.
Mobile IPv6 extension headers should be placed after IPsec
transport mode, but before transport AH when outbound.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/xfrm6_state.c |   28 ++++++++++++++++++++++++++--
 1 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index e0b8f3c..6269584 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -173,7 +173,19 @@ __xfrm6_state_sort(struct xfrm_state **d
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
@@ -226,7 +238,19 @@ __xfrm6_tmpl_sort(struct xfrm_tmpl **dst
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
1.4.0

