From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 6/6] bnx2x: set VF DMAE when first function has 0
 supported VFs
Date: Mon, 19 Aug 2013 09:12:01 +0300
Message-ID: <1376892721-10410-7-git-send-email-yuvalmin@broadcom.com>
References: <1376892721-10410-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1732 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750989Ab3HSGMX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Aug 2013 02:12:23 -0400
In-Reply-To: <1376892721-10410-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

There are possible HW configurations in which PFs will have SR-IOV capability
but will have Max VFs set to 0 - this happens when there are Multi-Function
devices where the VFs are allocated to only some of the PFs.

DMAE is configured to support VFs only if the configuring PF has supported VFs.
In case the first PF to be loaded will be one without supported VFs, it will
not configure DMAE to the VF-supporting mode. When VFs of other PFs will be
loaded later on, they will not be able to communicate with their PF.

This changes the requirement for configuring DMAE for VF-supporting mode;
If the device has SR-IOV capabilities there must be some PF that has
max supported VFs > 0, thus it will configure the DMAE for supporting VFs.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index d414b49..ad83f4b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -1747,11 +1747,8 @@ void bnx2x_iov_init_dq(struct bnx2x *bp)
 
 void bnx2x_iov_init_dmae(struct bnx2x *bp)
 {
-	DP(BNX2X_MSG_IOV, "SRIOV is %s\n", IS_SRIOV(bp) ? "ON" : "OFF");
-	if (!IS_SRIOV(bp))
-		return;
-
-	REG_WR(bp, DMAE_REG_BACKWARD_COMP_EN, 0);
+	if (pci_find_ext_capability(bp->pdev, PCI_EXT_CAP_ID_SRIOV))
+		REG_WR(bp, DMAE_REG_BACKWARD_COMP_EN, 0);
 }
 
 static int bnx2x_vf_bus(struct bnx2x *bp, int vfid)
-- 
1.8.1.227.g44fe835
