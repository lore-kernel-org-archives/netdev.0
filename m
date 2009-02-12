From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 24/41]bnx2x: Manual setting for MRRS
Date: Thu, 12 Feb 2009 20:37:19 +0200
Message-ID: <1234463839.1863.156.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2663 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758533AbZBLShp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:37:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 24/41]bnx2x: Manual setting for MRRS
Allows better debug capabilities if the user wants to force an MRRS value

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    1 +
 drivers/net/bnx2x_init.h |    7 ++++++-
 drivers/net/bnx2x_main.c |    6 ++++++
 3 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 9834a86..891a58e 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -864,6 +864,7 @@ struct bnx2x {
 
 	int			pm_cap;
 	int			pcie_cap;
+	int			mrrs;
 
 	struct delayed_work	sp_task;
 	struct work_struct	reset_task;
diff --git a/drivers/net/bnx2x_init.h b/drivers/net/bnx2x_init.h
index a6c0b3a..961db49 100644
--- a/drivers/net/bnx2x_init.h
+++ b/drivers/net/bnx2x_init.h
@@ -572,7 +572,12 @@ static void bnx2x_init_pxp(struct bnx2x *bp)
 			     bp->pcie_cap + PCI_EXP_DEVCTL, &devctl);
 	DP(NETIF_MSG_HW, "read 0x%x from devctl\n", devctl);
 	w_order = ((devctl & PCI_EXP_DEVCTL_PAYLOAD) >> 5);
-	r_order = ((devctl & PCI_EXP_DEVCTL_READRQ) >> 12);
+	if (bp->mrrs == -1)
+		r_order = ((devctl & PCI_EXP_DEVCTL_READRQ) >> 12);
+	else {
+		DP(NETIF_MSG_HW, "force read order to %d\n", bp->mrrs);
+		r_order = bp->mrrs;
+	}
 
 	if (r_order > MAX_RD_ORD) {
 		DP(NETIF_MSG_HW, "read order of %d  order adjusted to %d\n",
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 60a4e94..2e4d64d 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -88,6 +88,11 @@ module_param(int_mode, int, 0);
 MODULE_PARM_DESC(int_mode, " Force interrupt mode (1 INT#x; 2 MSI)");
 
 module_param(poll, int, 0);
+
+static int mrrs = -1;
+module_param(mrrs, int, 0);
+MODULE_PARM_DESC(mrrs, " Force Max Read Req Size (0..3) (for debug)");
+
 module_param(debug, int, 0);
 MODULE_PARM_DESC(disable_tpa, "disable the TPA (LRO) feature");
 MODULE_PARM_DESC(poll, "use polling (for debug)");
@@ -8160,6 +8165,7 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 		bp->dev->features |= NETIF_F_LRO;
 	}
 
+	bp->mrrs = mrrs;
 
 	bp->tx_ring_size = MAX_TX_AVAIL;
 	bp->rx_ring_size = MAX_RX_AVAIL;
-- 
1.5.4.3




