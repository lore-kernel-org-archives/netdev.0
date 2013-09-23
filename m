From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 5/6] bnx2x: prevent masked MCP parities from
 appearing
Date: Mon, 23 Sep 2013 10:12:54 +0300
Message-ID: <1379920375-10303-6-git-send-email-yuvalmin@broadcom.com>
References: <1379920375-10303-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4116 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752994Ab3IWHNM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Sep 2013 03:13:12 -0400
In-Reply-To: <1379920375-10303-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During flows which mask block attentions (e.g., register dump) all parities
are masked. However, unlike other blocks the MCP's attention is not masked
inside the block but rather the indication to the driver. If another attention
(e.g., link change) will occour while there's an MCP parity, the driver will
ignore the fact that the parity is masked and erroneously report a parity.

This patch forces the driver to read the MCP masking while checking for
parities.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index f403c6b..82b658d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -4703,6 +4703,14 @@ bool bnx2x_chk_parity_attn(struct bnx2x *bp, bool *global, bool print)
 	attn.sig[3] = REG_RD(bp,
 		MISC_REG_AEU_AFTER_INVERT_4_FUNC_0 +
 			     port*4);
+	/* Since MCP attentions can't be disabled inside the block, we need to
+	 * read AEU registers to see whether they're currently disabled
+	 */
+	attn.sig[3] &= ((REG_RD(bp,
+				!port ? MISC_REG_AEU_ENABLE4_FUNC_0_OUT_0
+				      : MISC_REG_AEU_ENABLE4_FUNC_1_OUT_0) &
+			 MISC_AEU_ENABLE_MCP_PRTY_BITS) |
+			~MISC_AEU_ENABLE_MCP_PRTY_BITS);
 
 	if (!CHIP_IS_E1x(bp))
 		attn.sig[4] = REG_RD(bp,
-- 
1.8.1.4
