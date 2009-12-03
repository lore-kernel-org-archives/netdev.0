From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 15/18] Bluetooth: Enable auto sleep mode for btmrvl driver
Date: Thu,  3 Dec 2009 19:45:52 +0100
Message-ID: <32fd63981ed453bd882f22e3e9b0ccbc11fb47e5.1259865280.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
 <b3cf652afb5404685e3d7ed6780a8d1fa10e21da.1259865280.git.marcel@holtmann.org>
 <5990108cfcd3eb2d365c9ea6f82318be80c4e9d3.1259865280.git.marcel@holtmann.org>
 <329ab1b3e6ceac3f77ab400206a97cc402624259.1259865280.git.marcel@holtmann.org>
 <fed4c2508b7419d0a55958fead6151b32def1683.1259865280.git.marcel@holtmann.org>
 <2da31939a42f7a676a0bc5155d6a0a39ed8451f2.1259865280.git.marcel@holtmann.org>
 <7e21addcd0ad87696c17409399e56e874931da57.1259865280.git.marcel@holtmann.org>
 <76bca88012e1d27de794f32cc551d6314d38b6d9.1259865280.git.marcel@holtmann.org>
 <c78ae283145d3a8799b2fb01650166a66af3bff8.1259865280.git.marcel@holtmann.org>
 <cde9f807f003676862178a6f28b52c7d431511ed.1259865280.git.marcel@holtmann.org>
 <0565c1c24af94130b891f989fa608faddfadc52c.1259865280.git.marcel@holtmann.org>
 <889a3ca466018ab68363c3168993793bc2d984f1.1259865280.git.marcel@holtmann.org>
 <9f121a5a80b4417c6db5a35e26d2e79c29c3fc0d.1259865280.git.marcel@holtmann.org>
 <4ec10d9720ef78cd81d8bcc30a3238665744569f.1259865280.git.marcel@holtmann.org>
 <2ab25cdd7b54473dd42dcffc9872737de2517466.1259865280.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:37656 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756526AbZLCSqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 13:46:03 -0500
In-Reply-To: <2ab25cdd7b54473dd42dcffc9872737de2517466.1259865280.git.marcel@holtmann.org>
In-Reply-To: <cover.1259865279.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amitkumar Karwar <akarwar@marvell.com>

The auto sleep mode for btmrvl driver is not enabled by default.
This patch enables auto sleep mode when card is probed.

Signed-off-by: Amitkumar Karwar <akarwar@marvell.com>
Signed-off-by: Bing Zhao <bzhao@marvell.com>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/btmrvl_drv.h  |    1 +
 drivers/bluetooth/btmrvl_main.c |   55 +++++++++++++++++++++++---------------
 drivers/bluetooth/btmrvl_sdio.c |    2 +
 3 files changed, 36 insertions(+), 22 deletions(-)

diff --git a/drivers/bluetooth/btmrvl_drv.h b/drivers/bluetooth/btmrvl_drv.h
index 411c7a7..523d197 100644
--- a/drivers/bluetooth/btmrvl_drv.h
+++ b/drivers/bluetooth/btmrvl_drv.h
@@ -131,6 +131,7 @@ void btmrvl_check_evtpkt(struct btmrvl_private *priv, struct sk_buff *skb);
 int btmrvl_process_event(struct btmrvl_private *priv, struct sk_buff *skb);
 
 int btmrvl_send_module_cfg_cmd(struct btmrvl_private *priv, int subcmd);
+int btmrvl_enable_ps(struct btmrvl_private *priv);
 int btmrvl_prepare_command(struct btmrvl_private *priv);
 
 #ifdef CONFIG_DEBUG_FS
diff --git a/drivers/bluetooth/btmrvl_main.c b/drivers/bluetooth/btmrvl_main.c
index e605563..f97771c 100644
--- a/drivers/bluetooth/btmrvl_main.c
+++ b/drivers/bluetooth/btmrvl_main.c
@@ -189,6 +189,38 @@ int btmrvl_send_module_cfg_cmd(struct btmrvl_private *priv, int subcmd)
 }
 EXPORT_SYMBOL_GPL(btmrvl_send_module_cfg_cmd);
 
+int btmrvl_enable_ps(struct btmrvl_private *priv)
+{
+	struct sk_buff *skb;
+	struct btmrvl_cmd *cmd;
+
+	skb = bt_skb_alloc(sizeof(*cmd), GFP_ATOMIC);
+	if (skb == NULL) {
+		BT_ERR("No free skb");
+		return -ENOMEM;
+	}
+
+	cmd = (struct btmrvl_cmd *) skb_put(skb, sizeof(*cmd));
+	cmd->ocf_ogf = cpu_to_le16(hci_opcode_pack(OGF,
+					BT_CMD_AUTO_SLEEP_MODE));
+	cmd->length = 1;
+
+	if (priv->btmrvl_dev.psmode)
+		cmd->data[0] = BT_PS_ENABLE;
+	else
+		cmd->data[0] = BT_PS_DISABLE;
+
+	bt_cb(skb)->pkt_type = MRVL_VENDOR_PKT;
+
+	skb->dev = (void *) priv->btmrvl_dev.hcidev;
+	skb_queue_head(&priv->adapter->tx_queue, skb);
+
+	BT_DBG("Queue PSMODE Command:%d", cmd->data[0]);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(btmrvl_enable_ps);
+
 static int btmrvl_enable_hs(struct btmrvl_private *priv)
 {
 	struct sk_buff *skb;
@@ -258,28 +290,7 @@ int btmrvl_prepare_command(struct btmrvl_private *priv)
 
 	if (priv->btmrvl_dev.pscmd) {
 		priv->btmrvl_dev.pscmd = 0;
-
-		skb = bt_skb_alloc(sizeof(*cmd), GFP_ATOMIC);
-		if (skb == NULL) {
-			BT_ERR("No free skb");
-			return -ENOMEM;
-		}
-
-		cmd = (struct btmrvl_cmd *) skb_put(skb, sizeof(*cmd));
-		cmd->ocf_ogf = cpu_to_le16(hci_opcode_pack(OGF, BT_CMD_AUTO_SLEEP_MODE));
-		cmd->length = 1;
-
-		if (priv->btmrvl_dev.psmode)
-			cmd->data[0] = BT_PS_ENABLE;
-		else
-			cmd->data[0] = BT_PS_DISABLE;
-
-		bt_cb(skb)->pkt_type = MRVL_VENDOR_PKT;
-
-		skb->dev = (void *) priv->btmrvl_dev.hcidev;
-		skb_queue_head(&priv->adapter->tx_queue, skb);
-
-		BT_DBG("Queue PSMODE Command:%d", cmd->data[0]);
+		btmrvl_enable_ps(priv);
 	}
 
 	if (priv->btmrvl_dev.hscmd) {
diff --git a/drivers/bluetooth/btmrvl_sdio.c b/drivers/bluetooth/btmrvl_sdio.c
index 5b33b85..d6aaf51 100644
--- a/drivers/bluetooth/btmrvl_sdio.c
+++ b/drivers/bluetooth/btmrvl_sdio.c
@@ -930,6 +930,8 @@ static int btmrvl_sdio_probe(struct sdio_func *func,
 	priv->hw_wakeup_firmware = btmrvl_sdio_wakeup_fw;
 
 	btmrvl_send_module_cfg_cmd(priv, MODULE_BRINGUP_REQ);
+	priv->btmrvl_dev.psmode = 1;
+	btmrvl_enable_ps(priv);
 
 	return 0;
 
-- 
1.6.5.2

