From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 08/12] ixgbe: do not clear FCoE DDP error status for received ABTS
Date: Wed, 27 Apr 2011 02:34:47 -0700
Message-ID: <1303896891-16006-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1303896891-16006-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Yi Zou <yi.zou@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:38651 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755991Ab1D0Je7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2011 05:34:59 -0400
In-Reply-To: <1303896891-16006-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

The ddp->err is initialized to be 1 to make sure outstanding DDP context is
guaranteed to be invalidated when HW is not auto-invalidating it. However,
in case of receiving ABTS response for a DDPed I/O, the ddp->err was cleared,
bypassing the invalidating of the DDP context from upper protocol stack when
ixgbe_fcoe_ddp_put() is called. This bug is fixed here by updating the error
only when FCP_RSP is received.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_fcoe.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index dba7d77..0592072 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -416,8 +416,7 @@ int ixgbe_fcoe_ddp(struct ixgbe_adapter *adapter,
 	if (!ddp->udl)
 		goto ddp_out;
 
-	ddp->err = (fcerr | fceofe);
-	if (ddp->err)
+	if (fcerr | fceofe)
 		goto ddp_out;
 
 	fcstat = (sterr & IXGBE_RXDADV_STAT_FCSTAT);
@@ -428,6 +427,7 @@ int ixgbe_fcoe_ddp(struct ixgbe_adapter *adapter,
 		if (fcstat == IXGBE_RXDADV_STAT_FCSTAT_FCPRSP) {
 			pci_unmap_sg(adapter->pdev, ddp->sgl,
 				     ddp->sgc, DMA_FROM_DEVICE);
+			ddp->err = (fcerr | fceofe);
 			ddp->sgl = NULL;
 			ddp->sgc = 0;
 		}
-- 
1.7.4.4

