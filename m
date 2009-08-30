From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 19/47] Bluetooth: Fix Marvell driver to use skb_put and hci_opcode_pack
Date: Sun, 30 Aug 2009 01:50:33 -0700
Message-ID: <91d697302b291205171840bfe84c1563e171acb2.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
 <fd0b3ff707dc1f7837079044bd4eca7ed505f70d.1251621661.git.marcel@holtmann.org>
 <981b1414d78a7a42cab48b97d4de54a62d61db88.1251621661.git.marcel@holtmann.org>
 <290ba200815fdecb4d40dc942499c4ea6d0c4624.1251621661.git.marcel@holtmann.org>
 <364f63519d94442ed373ac7da79033c8282df46a.1251621661.git.marcel@holtmann.org>
 <9eba32b86d17ef87131fa0bce43c614904ab5781.1251621661.git.marcel@holtmann.org>
 <edad63886993d18ab800c49f6587a93432ef8b35.1251621661.git.marcel@holtmann.org>
 <132ff4e5fa8dfb71a7d99902f88043113947e972.1251621661.git.marcel@holtmann.org>
 <789221ecc870117b77e354d488d5d29f15410de8.1251621661.git.marcel@holtmann.org>
 <fb784f0508d5aa39a23e72879a8dfb517c6f6e7f.1251621661.git.marcel@holtmann.org>
 <196be0cd018068d545e1d764094c7b07aaf0bcfe.1251621661.git.marcel@holtmann.org>
 <e7a25f9839fd392ec2c96e7e2b3734501d761a24.1251621661.git.marcel@holtmann.org>
 <08b0b0ce8c609b0e2284b134f0614e211374a038.1251621661.git.marcel@holtmann.org>
 <944fe798c6a48336e82bbc0d4e280587325a4d95.1251621661.git.marcel@holtmann.org>
 <542399037d0cb2b2e96dfb8ced35b07dfb1c3706.1251621661.git.marcel@holtmann.org>
 <4271e08d8b799171af18d7864908ec444282efe5.1251621661.git.marcel@holtmann.org>
 <dcf47f3bc798888f9ea40b9f626d669dc62086bf.1251621661.git.marcel@holtmann.org>
 <9666fb356da78a5ec28403197d72e8cd6aa16424.1251621661.git.marcel@holtmann.org>
 <60dee5ccd789ee8a380eee802b6cb24c52123428.1251621661.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53298 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752948AbZH3IwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:52:13 -0400
In-Reply-To: <60dee5ccd789ee8a380eee802b6cb24c52123428.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Marvell driver has some weird quirks on how to construct proper SKBs
with Bluetooth HCI commands. Fix it to use skb_put properly and also
use hci_opcode_pack instead of self-crafted macro.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/btmrvl_main.c |   22 ++++++++--------------
 1 files changed, 8 insertions(+), 14 deletions(-)

diff --git a/drivers/bluetooth/btmrvl_main.c b/drivers/bluetooth/btmrvl_main.c
index 61168ec..f5a3dc5 100644
--- a/drivers/bluetooth/btmrvl_main.c
+++ b/drivers/bluetooth/btmrvl_main.c
@@ -172,14 +172,13 @@ int btmrvl_send_module_cfg_cmd(struct btmrvl_private *priv, int subcmd)
 		goto exit;
 	}
 
-	cmd = (struct btmrvl_cmd *) skb->tail;
-	cmd->ocf_ogf = cpu_to_le16((OGF << 10) | BT_CMD_MODULE_CFG_REQ);
+	cmd = skb_put(skb, sizeof(*cmd));
+	cmd->ocf_ogf = cpu_to_le16(hci_opcode_pack(OGF, BT_CMD_MODULE_CFG_REQ));
 	cmd->length = 1;
 	cmd->data[0] = subcmd;
 
 	bt_cb(skb)->pkt_type = MRVL_VENDOR_PKT;
 
-	skb_put(skb, sizeof(*cmd));
 	skb->dev = (void *) priv->btmrvl_dev.hcidev;
 	skb_queue_head(&priv->adapter->tx_queue, skb);
 
@@ -223,13 +222,12 @@ static int btmrvl_enable_hs(struct btmrvl_private *priv)
 		goto exit;
 	}
 
-	cmd = (struct btmrvl_cmd *) skb->tail;
-	cmd->ocf_ogf = cpu_to_le16((OGF << 10) | BT_CMD_HOST_SLEEP_ENABLE);
+	cmd = skb_put(skb, sizeof(*cmd));
+	cmd->ocf_ogf = cpu_to_le16(hci_opcode_pack(OGF, BT_CMD_HOST_SLEEP_ENABLE));
 	cmd->length = 0;
 
 	bt_cb(skb)->pkt_type = MRVL_VENDOR_PKT;
 
-	skb_put(skb, sizeof(*cmd));
 	skb->dev = (void *) priv->btmrvl_dev.hcidev;
 	skb_queue_head(&priv->adapter->tx_queue, skb);
 
@@ -270,16 +268,14 @@ int btmrvl_prepare_command(struct btmrvl_private *priv)
 			goto exit;
 		}
 
-		cmd = (struct btmrvl_cmd *) skb->tail;
-		cmd->ocf_ogf = cpu_to_le16((OGF << 10) |
-						BT_CMD_HOST_SLEEP_CONFIG);
+		cmd = skb_put(skb, sizeof(*cmd));
+		cmd->ocf_ogf = cpu_to_le16(hci_opcode_pack(OGF, BT_CMD_HOST_SLEEP_CONFIG));
 		cmd->length = 2;
 		cmd->data[0] = (priv->btmrvl_dev.gpio_gap & 0xff00) >> 8;
 		cmd->data[1] = (u8) (priv->btmrvl_dev.gpio_gap & 0x00ff);
 
 		bt_cb(skb)->pkt_type = MRVL_VENDOR_PKT;
 
-		skb_put(skb, sizeof(*cmd));
 		skb->dev = (void *) priv->btmrvl_dev.hcidev;
 		skb_queue_head(&priv->adapter->tx_queue, skb);
 
@@ -297,9 +293,8 @@ int btmrvl_prepare_command(struct btmrvl_private *priv)
 			goto exit;
 		}
 
-		cmd = (struct btmrvl_cmd *) skb->tail;
-		cmd->ocf_ogf = cpu_to_le16((OGF << 10) |
-						BT_CMD_AUTO_SLEEP_MODE);
+		cmd = skb_put(skb, sizeof(*cmd));
+		cmd->ocf_ogf = cpu_to_le16(hci_opcode_pack(OGF, BT_CMD_AUTO_SLEEP_MODE));
 		cmd->length = 1;
 
 		if (priv->btmrvl_dev.psmode)
@@ -309,7 +304,6 @@ int btmrvl_prepare_command(struct btmrvl_private *priv)
 
 		bt_cb(skb)->pkt_type = MRVL_VENDOR_PKT;
 
-		skb_put(skb, sizeof(*cmd));
 		skb->dev = (void *) priv->btmrvl_dev.hcidev;
 		skb_queue_head(&priv->adapter->tx_queue, skb);
 
-- 
1.6.2.5

