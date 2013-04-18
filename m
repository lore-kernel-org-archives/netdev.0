From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 1/2] bnx2x: Prevent UNDI FW illegal host access
Date: Thu, 18 Apr 2013 11:49:05 +0300
Message-ID: <1366274946-11625-2-git-send-email-yuvalmin@broadcom.com>
References: <1366274946-11625-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3723 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756810Ab3DRJv3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 05:51:29 -0400
In-Reply-To: <1366274946-11625-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

When loading after UNDI (e.g., Boot from SAN) the UNDI does not
gracefully yield its resources; The bnx2x driver handles that release
itself.

During the manipulation required to release those resources, it's possible
for the UNDI to try and write to memory regions which are no longer accessible,
causing the PCI bus to prevent further writes from the chip.

This would in turn cause DMAE timeouts later on in the driver, as the driver
will be unable to use the chip's DMA engines.

This patch prevents the chip from actually writing through the PCI bus
in said scenario, thus allowing the release without the unfortunate by-product.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 0c1d75a..c8ef9f5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9945,6 +9945,10 @@ static int bnx2x_prev_unload_common(struct bnx2x *bp)
 				REG_RD(bp, NIG_REG_NIG_INT_STS_CLR_0);
 			}
 		}
+		if (!CHIP_IS_E1x(bp))
+			/* block FW from writing to host */
+			REG_WR(bp, PGLUE_B_REG_INTERNAL_PFID_ENABLE_MASTER, 0);
+
 		/* wait until BRB is empty */
 		tmp_reg = REG_RD(bp, BRB1_REG_NUM_OF_FULL_BLOCKS);
 		while (timer_count) {
-- 
1.8.1.227.g44fe835
