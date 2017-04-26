From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 1/9] drivers: net: xgene: Protect indirect MAC access
Date: Wed, 26 Apr 2017 16:38:47 -0700
Message-ID: <1493249935-30759-2-git-send-email-isubramanian@apm.com>
References: <1493249935-30759-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        Quan Nguyen <qnguyen@apm.com>,
        Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35095 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032757AbdDZXgf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 19:36:35 -0400
Received: by mail-pf0-f181.google.com with SMTP id v14so8272499pfd.2
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 16:36:35 -0700 (PDT)
In-Reply-To: <1493249935-30759-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quan Nguyen <qnguyen@apm.com>

This patch adds lock to protect indirect mac access sequence.

Signed-off-by: Quan Nguyen <qnguyen@apm.com>
Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c    | 2 ++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  | 1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h  | 1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c | 7 ++++++-
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c | 2 ++
 5 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 2a835e0..3697ba7 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -365,9 +365,11 @@ static void xgene_enet_rd_mcx_mac(struct xgene_enet_pdata *pdata,
 	cmd = pdata->mcx_mac_addr + MAC_COMMAND_REG_OFFSET;
 	cmd_done = pdata->mcx_mac_addr + MAC_COMMAND_DONE_REG_OFFSET;
 
+	spin_lock(&pdata->mac_lock);
 	if (!xgene_enet_rd_indirect(addr, rd, cmd, cmd_done, rd_addr, rd_data))
 		netdev_err(pdata->ndev, "MCX mac read failed, addr: %04x\n",
 			   rd_addr);
+	spin_unlock(&pdata->mac_lock);
 }
 
 static void xgene_gmac_set_mac_addr(struct xgene_enet_pdata *pdata)
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 5f37ed3..9a28ac3 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -2055,6 +2055,7 @@ static int xgene_enet_probe(struct platform_device *pdev)
 		goto err;
 
 	xgene_enet_setup_ops(pdata);
+	spin_lock_init(&pdata->mac_lock);
 
 	if (pdata->phy_mode == PHY_INTERFACE_MODE_XGMII) {
 		ndev->features |= NETIF_F_TSO | NETIF_F_RXCSUM;
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index 0d4be24..827b33d 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -221,6 +221,7 @@ struct xgene_enet_pdata {
 	struct xgene_enet_cle cle;
 	struct rtnl_link_stats64 stats;
 	const struct xgene_mac_ops *mac_ops;
+	spinlock_t mac_lock; /* mac lock */
 	const struct xgene_port_ops *port_ops;
 	struct xgene_ring_ops *ring_ops;
 	const struct xgene_cle_ops *cle_ops;
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
index a8e063b..4dd41f5 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
@@ -130,6 +130,7 @@ static u32 xgene_enet_rd_indirect(struct xgene_indirect_ctl *ctl, u32 rd_addr)
 
 static u32 xgene_enet_rd_mac(struct xgene_enet_pdata *p, u32 rd_addr)
 {
+	u32 val;
 	struct xgene_indirect_ctl ctl = {
 		.addr = p->mcx_mac_addr + MAC_ADDR_REG_OFFSET,
 		.ctl = p->mcx_mac_addr + MAC_READ_REG_OFFSET,
@@ -137,7 +138,11 @@ static u32 xgene_enet_rd_mac(struct xgene_enet_pdata *p, u32 rd_addr)
 		.cmd_done = p->mcx_mac_addr + MAC_COMMAND_DONE_REG_OFFSET
 	};
 
-	return xgene_enet_rd_indirect(&ctl, rd_addr);
+	spin_lock(&p->mac_lock);
+	val = xgene_enet_rd_indirect(&ctl, rd_addr);
+	spin_unlock(&p->mac_lock);
+
+	return val;
 }
 
 static int xgene_enet_ecc_init(struct xgene_enet_pdata *p)
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
index 423240c..9a2d0ca 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
@@ -158,9 +158,11 @@ static void xgene_enet_rd_mac(struct xgene_enet_pdata *pdata,
 	cmd = pdata->mcx_mac_addr + MAC_COMMAND_REG_OFFSET;
 	cmd_done = pdata->mcx_mac_addr + MAC_COMMAND_DONE_REG_OFFSET;
 
+	spin_lock(&pdata->mac_lock);
 	if (!xgene_enet_rd_indirect(addr, rd, cmd, cmd_done, rd_addr, rd_data))
 		netdev_err(pdata->ndev, "MCX mac read failed, addr: %04x\n",
 			   rd_addr);
+	spin_unlock(&pdata->mac_lock);
 }
 
 static bool xgene_enet_rd_pcs(struct xgene_enet_pdata *pdata,
-- 
1.9.1
