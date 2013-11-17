From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 3/4] bnx2x: prevent CFC attention
Date: Sun, 17 Nov 2013 08:59:28 +0200
Message-ID: <1384671569-30105-4-git-send-email-yuvalmin@broadcom.com>
References: <1384671569-30105-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, dmitry@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4193 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751234Ab3KQG7o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Nov 2013 01:59:44 -0500
In-Reply-To: <1384671569-30105-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

During VF load, prior to sending messages on HW channel to PF the VF
checks its bulletin board to see whether the PF indicated it has closed;
If a closed PF is encountered, the VF skips sending the message.

Due to incorrect return values, there's a possible scenario in which the VF
finishes loading "successfully", while the PF hasn't actually fully configured
FW/HW for the VFs supposed configuration.
Once VF tries to send Tx packets, HW will raise an attention (and FW possibly
will start treat the VF as malicious).

The patch fails the loading process in such a scenario.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index 28757df..c421009 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -128,7 +128,7 @@ static int bnx2x_send_msg2pf(struct bnx2x *bp, u8 *done, dma_addr_t msg_mapping)
 	if (bp->old_bulletin.valid_bitmap & 1 << CHANNEL_DOWN) {
 		DP(BNX2X_MSG_IOV, "detecting channel down. Aborting message\n");
 		*done = PFVF_STATUS_SUCCESS;
-		return 0;
+		return -EINVAL;
 	}
 
 	/* Write message address */
-- 
1.8.1.227.g44fe835
