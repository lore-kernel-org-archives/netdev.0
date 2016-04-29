From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 1/3] drivers: net: xgene: Get channel number from device binding
Date: Fri, 29 Apr 2016 11:10:13 -0700
Message-ID: <1461953415-9741-2-git-send-email-isubramanian@apm.com>
References: <1461953415-9741-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36378 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752554AbcD2SJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 14:09:54 -0400
Received: by mail-pa0-f44.google.com with SMTP id bt5so48189437pac.3
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 11:09:54 -0700 (PDT)
In-Reply-To: <1461953415-9741-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch gets ethernet to CPU channel (prefetch buffer number) from
the newly added 'channel' property, thus decoupling Linux driver from
resource management.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 8d4c1ad..409152b 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -973,6 +973,17 @@ static enum xgene_ring_owner xgene_derive_ring_owner(struct xgene_enet_pdata *p)
 	return owner;
 }
 
+static u8 xgene_start_cpu_bufnum(struct xgene_enet_pdata *pdata)
+{
+	struct device *dev = &pdata->pdev->dev;
+	u32 cpu_bufnum;
+	int ret;
+
+	ret = device_property_read_u32(dev, "channel", &cpu_bufnum);
+
+	return (!ret) ? cpu_bufnum : pdata->cpu_bufnum;
+}
+
 static int xgene_enet_create_desc_rings(struct net_device *ndev)
 {
 	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
@@ -981,13 +992,15 @@ static int xgene_enet_create_desc_rings(struct net_device *ndev)
 	struct xgene_enet_desc_ring *buf_pool = NULL;
 	enum xgene_ring_owner owner;
 	dma_addr_t dma_exp_bufs;
-	u8 cpu_bufnum = pdata->cpu_bufnum;
+	u8 cpu_bufnum;
 	u8 eth_bufnum = pdata->eth_bufnum;
 	u8 bp_bufnum = pdata->bp_bufnum;
 	u16 ring_num = pdata->ring_num;
 	u16 ring_id;
 	int i, ret, size;
 
+	cpu_bufnum = xgene_start_cpu_bufnum(pdata);
+
 	for (i = 0; i < pdata->rxq_cnt; i++) {
 		/* allocate rx descriptor ring */
 		owner = xgene_derive_ring_owner(pdata);
-- 
1.9.1
