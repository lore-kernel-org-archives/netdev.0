From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH] drivers: net: xgene: fix: ifconfig up/down crash
Date: Mon, 23 Nov 2015 12:04:52 -0800
Message-ID: <1448309092-21550-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, kdinh@apm.com,
	patches@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34857 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753377AbbKWUDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 15:03:39 -0500
Received: by pacej9 with SMTP id ej9so200910013pac.2
        for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 12:03:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixing kernel crash when doing ifconfig down and up in a loop,

[ 124.028237] Call trace:
[ 124.030670] [<ffffffc000367ce0>] memcpy+0x20/0x180
[ 124.035436] [<ffffffc00053c250>] skb_clone+0x3c/0xa8
[ 124.040374] [<ffffffc00053ffa4>] __skb_tstamp_tx+0xc0/0x118
[ 124.045918] [<ffffffc00054000c>] skb_tstamp_tx+0x10/0x1c
[ 124.051203] [<ffffffc00049bc84>] xgene_enet_start_xmit+0x2e4/0x33c
[ 124.057352] [<ffffffc00054fc20>] dev_hard_start_xmit+0x2e8/0x400
[ 124.063327] [<ffffffc00056cb14>] sch_direct_xmit+0x90/0x1d4
[ 124.068870] [<ffffffc000550100>] __dev_queue_xmit+0x28c/0x498
[ 124.074585] [<ffffffc00055031c>] dev_queue_xmit_sk+0x10/0x1c
[ 124.080216] [<ffffffc0005c3f14>] ip_finish_output2+0x3d0/0x438
[ 124.086017] [<ffffffc0005c5794>] ip_finish_output+0x198/0x1ac
[ 124.091732] [<ffffffc0005c61d4>] ip_output+0xec/0x164
[ 124.096755] [<ffffffc0005c5910>] ip_local_out_sk+0x38/0x48
[ 124.102211] [<ffffffc0005c5d84>] ip_queue_xmit+0x288/0x330
[ 124.107668] [<ffffffc0005da8bc>] tcp_transmit_skb+0x908/0x964
[ 124.113383] [<ffffffc0005dc0d4>] tcp_send_ack+0x128/0x138
[ 124.118753] [<ffffffc0005d1580>] __tcp_ack_snd_check+0x5c/0x94
[ 124.124555] [<ffffffc0005d7a0c>] tcp_rcv_established+0x554/0x68c
[ 124.130530] [<ffffffc0005df0d4>] tcp_v4_do_rcv+0xa4/0x37c
[ 124.135900] [<ffffffc000539430>] release_sock+0xb4/0x150
[ 124.141184] [<ffffffc0005cdf88>] tcp_recvmsg+0x448/0x9e0
[ 124.146468] [<ffffffc0005f2f3c>] inet_recvmsg+0xa0/0xc0
[ 124.151666] [<ffffffc000533660>] sock_recvmsg+0x10/0x1c
[ 124.156863] [<ffffffc0005370d4>] SyS_recvfrom+0xa4/0xf8
[ 124.162061] Code: f2400c84 540001c0 cb040042 36000064 (38401423)
[ 124.168133] ---[ end trace 7ab2550372e8a65b ]---

The fix was to reorder napi_enable, napi_disable, request_irq and
free_irq calls, move register_netdev after dma_coerce_mask_and_coherent.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Khuong Dinh <kdinh@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 29 +++++++++++++-----------
 1 file changed, 16 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 991412c..1adfe70 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -688,10 +688,10 @@ static int xgene_enet_open(struct net_device *ndev)
 	mac_ops->tx_enable(pdata);
 	mac_ops->rx_enable(pdata);
 
+	xgene_enet_napi_enable(pdata);
 	ret = xgene_enet_register_irq(ndev);
 	if (ret)
 		return ret;
-	xgene_enet_napi_enable(pdata);
 
 	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII)
 		phy_start(pdata->phy_dev);
@@ -715,13 +715,13 @@ static int xgene_enet_close(struct net_device *ndev)
 	else
 		cancel_delayed_work_sync(&pdata->link_work);
 
-	xgene_enet_napi_disable(pdata);
-	xgene_enet_free_irq(ndev);
-	xgene_enet_process_ring(pdata->rx_ring, -1);
-
 	mac_ops->tx_disable(pdata);
 	mac_ops->rx_disable(pdata);
 
+	xgene_enet_free_irq(ndev);
+	xgene_enet_napi_disable(pdata);
+	xgene_enet_process_ring(pdata->rx_ring, -1);
+
 	return 0;
 }
 
@@ -1474,15 +1474,15 @@ static int xgene_enet_probe(struct platform_device *pdev)
 	}
 	ndev->hw_features = ndev->features;
 
-	ret = register_netdev(ndev);
+	ret = dma_coerce_mask_and_coherent(dev, DMA_BIT_MASK(64));
 	if (ret) {
-		netdev_err(ndev, "Failed to register netdev\n");
+		netdev_err(ndev, "No usable DMA configuration\n");
 		goto err;
 	}
 
-	ret = dma_coerce_mask_and_coherent(dev, DMA_BIT_MASK(64));
+	ret = register_netdev(ndev);
 	if (ret) {
-		netdev_err(ndev, "No usable DMA configuration\n");
+		netdev_err(ndev, "Failed to register netdev\n");
 		goto err;
 	}
 
@@ -1490,14 +1490,17 @@ static int xgene_enet_probe(struct platform_device *pdev)
 	if (ret)
 		goto err;
 
-	xgene_enet_napi_add(pdata);
 	mac_ops = pdata->mac_ops;
-	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII)
+	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII) {
 		ret = xgene_enet_mdio_config(pdata);
-	else
+		if (ret)
+			goto err;
+	} else {
 		INIT_DELAYED_WORK(&pdata->link_work, mac_ops->link_state);
+	}
 
-	return ret;
+	xgene_enet_napi_add(pdata);
+	return 0;
 err:
 	unregister_netdev(ndev);
 	free_netdev(ndev);
-- 
1.9.1
