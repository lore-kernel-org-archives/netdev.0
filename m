From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 43/44] [XFRM] IPV6: Add sort functions to combine templates/states for IPsec.
Date: Thu, 24 Aug 2006 00:02:44 +0900
Message-ID: <11563453681815-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org> <1156345366288-git-send-email-yoshfuji@linux-ipv6.org> <1156345366857-git-send-email-yoshfuji@linux-ipv6.org> <11563453663761-git-send-email-yoshfuji@linux-ipv6.org> <11563453662321-git-send-email-yoshfuji@linux-ipv6.org>
  <11563453661892-git-send-email-yoshfuji@linux-ipv6.org> <11563453661207-git-send-email-yoshfuji@linux-ipv6.org> <11563453663743-git-send-email-yoshfuji@linux-ipv6.org> <1156345366676-git-send-email-yoshfuji@linux-ipv6.org> <11563453662840-git-send-email-yoshfuji@linux-ipv6.org> <11563453662913-git-send-email-yoshfuji@linux-ipv6.org> <11563453663400-git-send-email-yoshfuji@linux-ipv6.org> <1156345366549-git-send-email-yoshfuji@linux-ipv6.org> <11563453662956-git-send-email-yoshfuji@linux-ipv6.org> <11563453661764-git-send-email-yoshfuji@linux-ipv6.org> <11563453663275-git-send-email-yoshfuji@linux-ipv6.org> <11563453671174-git-send-email-yoshfuji@linux-ipv6.org> <11563453674049-git-send-email-yoshfuji@linux-ipv6.org> <11563453673517-git-send-email-yoshfuji@linux-ipv6.org> <11563453674137-git-send-email-yoshfuji@linux-ipv6.org> <11563453671944-git-send-email-yoshfuji@linux-ipv6.org> <11
 563453671187-git-send-email-yoshfuji@linux-ipv6.org> <11563453672959-git-send-email-yoshfuji@linux-ipv6.org> <1156345367208-git-send-email-yoshfuji@linux-ipv6.org> <11563453673786-git-send-email-yoshfuji@linux-ipv6.org> <11563453672531-git-send-email-yoshfuji@linux-ipv6.org> <11563453674194-git-send-email-yoshfuji@linux-ipv6.org> <11563453671463-git-send-email-yoshfuji@linux-ipv6.org> <11563453672872-git-send-email-yoshfuji@linux-ipv6.org> <11563453671273-git-send-email-yoshfuji@linux-ipv6.org> <11563453674024-git-send-email-yoshfuji@linux-ipv6.org> <11563453673854-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:12169 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964956AbWHWPCw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:52 -0400
To: davem@davemloft.net
In-Reply-To: <11563453673854-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Add sort functions to combine templates/states for IPsec.
Think of outbound transformation order we should be careful with transport AH
which must be the last of all transport ones.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/xfrm6_state.c |   97 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 97 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index 9c95b9d..e0b8f3c 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -156,12 +156,109 @@ __xfrm6_find_acq(u8 mode, u32 reqid, u8 
 	return x0;
 }
 
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
+
 static struct xfrm_state_afinfo xfrm6_state_afinfo = {
 	.family			= AF_INET6,
 	.init_tempsel		= __xfrm6_init_tempsel,
 	.state_lookup		= __xfrm6_state_lookup,
 	.state_lookup_byaddr	= __xfrm6_state_lookup_byaddr,
 	.find_acq		= __xfrm6_find_acq,
+	.tmpl_sort		= __xfrm6_tmpl_sort,
+	.state_sort		= __xfrm6_state_sort,
 };
 
 void __init xfrm6_state_init(void)
-- 
1.4.0

