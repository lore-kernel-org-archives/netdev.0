From: Anatolij Gustschin <agust@denx.de>
Subject: [net-next-2.6 PATCH v2 3/3] fs_enet: add FEC TX buffer alignment workaround for MPC5121
Date: Wed, 17 Feb 2010 15:55:30 +0100
Message-ID: <1266418530-2727-4-git-send-email-agust@denx.de>
References: <1266418530-2727-1-git-send-email-agust@denx.de>
 <1266418530-2727-2-git-send-email-agust@denx.de>
 <1266418530-2727-3-git-send-email-agust@denx.de>
Cc: linuxppc-dev@ozlabs.org, "David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@secretlab.ca>,
	Detlev Zundel <dzu@denx.de>, Wolfgang Denk <wd@denx.de>,
	John Rigby <jcrigby@gmail.com>,
	Anatolij Gustschin <agust@denx.de>,
	Piotr Ziecik <kosmo@semihalf.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:44930 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757108Ab0BQO5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 09:57:19 -0500
In-Reply-To: <1266418530-2727-3-git-send-email-agust@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MPC5121 FEC requeries 4-byte alignmnent for TX data buffers.
This patch is a work around that copies misaligned tx packets
to an aligned skb before sending.

Signed-off-by: John Rigby <jcrigby@gmail.com>
Signed-off-by: Piotr Ziecik <kosmo@semihalf.com>
Signed-off-by: Wolfgang Denk <wd@denx.de>
Signed-off-by: Anatolij Gustschin <agust@denx.de>
---
 drivers/net/fs_enet/fs_enet-main.c |   44 ++++++++++++++++++++++++++++++++++++
 1 files changed, 44 insertions(+), 0 deletions(-)

diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index 4297021..166a89d 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -580,6 +580,37 @@ void fs_cleanup_bds(struct net_device *dev)
 
 /**********************************************************************************/
 
+#ifdef CONFIG_FS_ENET_MPC5121_FEC
+/*
+ * MPC5121 FEC requeries 4-byte alignment for TX data buffer!
+ */
+static struct sk_buff *tx_skb_align_workaround(struct net_device *dev,
+					       struct sk_buff *skb)
+{
+	struct sk_buff *new_skb;
+	struct fs_enet_private *fep = netdev_priv(dev);
+
+	/* Alloc new skb */
+	new_skb = dev_alloc_skb(ENET_RX_FRSIZE + 4);
+	if (!new_skb) {
+		dev_warn(fep->dev, "Memory squeeze, dropping tx packet.\n");
+		return NULL;
+	}
+
+	/* Make sure new skb is properly aligned */
+	skb_align(new_skb, 4);
+
+	/* Copy data to new skb ... */
+	skb_copy_from_linear_data(skb, new_skb->data, skb->len);
+	skb_put(new_skb, skb->len);
+
+	/* ... and free an old one */
+	dev_kfree_skb_any(skb);
+
+	return new_skb;
+}
+#endif
+
 static int fs_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
@@ -588,6 +619,19 @@ static int fs_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	u16 sc;
 	unsigned long flags;
 
+#ifdef CONFIG_FS_ENET_MPC5121_FEC
+	if (((unsigned long)skb->data) & 0x3) {
+		skb = tx_skb_align_workaround(dev, skb);
+		if (!skb) {
+			/*
+			 * We have lost packet due to memory allocation error
+			 * in tx_skb_align_workaround(). Hopefully original
+			 * skb is still valid, so try transmit it later.
+			 */
+			return NETDEV_TX_BUSY;
+		}
+	}
+#endif
 	spin_lock_irqsave(&fep->tx_lock, flags);
 
 	/*
-- 
1.6.3.3

