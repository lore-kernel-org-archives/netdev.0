From: Anatolij Gustschin <agust@denx.de>
Subject: [PATCH 02/11] fs_enet: Add FEC TX Alignment workaround for MPC5121
Date: Tue, 19 Jan 2010 21:24:04 +0100
Message-ID: <1263932653-3634-3-git-send-email-agust@denx.de>
References: <1263932653-3634-1-git-send-email-agust@denx.de>
Cc: dzu@denx.de, wd@denx.de, John Rigby <jcrigby@gmail.com>,
	John Rigby <jrigby@freescale.com>,
	Piotr Ziecik <kosmo@semihalf.com>,
	Anatolij Gustschin <agust@denx.de>, <netdev@vger.kernel.org>,
	Grant Likely <grant.likely@secretlab.ca>
To: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:55527 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753938Ab0ASUYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 15:24:21 -0500
In-Reply-To: <1263932653-3634-1-git-send-email-agust@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Rigby <jcrigby@gmail.com>

The FEC on 5121 has problems with misaligned tx buffers.
The RM says any alignment is ok but empirical results
show that packet buffers ending in 0x1E will sometimes
hang the FEC.  Other bad alignment does not hang but will
cause silent TX failures resulting in about a 1% packet
loss as tested by ping -f from a remote host.

This patch is a work around that copies every tx packet
to an aligned skb before sending.

Signed-off-by: John Rigby <jrigby@freescale.com>
Signed-off-by: Piotr Ziecik <kosmo@semihalf.com>
Signed-off-by: Wolfgang Denk <wd@denx.de>
Signed-off-by: Anatolij Gustschin <agust@denx.de>
Cc: <netdev@vger.kernel.org>
Cc: Grant Likely <grant.likely@secretlab.ca>
Cc: John Rigby <jcrigby@gmail.com>
---
 drivers/net/fs_enet/fs_enet-main.c |   39 ++++++++++++++++++++++++++++++++++++
 1 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index 909b78d..a391219 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -587,6 +587,33 @@ void fs_cleanup_bds(struct net_device *dev)
 
 /**********************************************************************************/
 
+static struct sk_buff *tx_skb_align_workaround(struct net_device *dev,
+					       struct sk_buff *skb)
+{
+	struct sk_buff *new_skb;
+
+	/* Alloc new skb */
+	new_skb = dev_alloc_skb(ENET_RX_FRSIZE + 32);
+	if (!new_skb) {
+		printk(KERN_WARNING DRV_MODULE_NAME
+				": %s Memory squeeze, dropping tx packet.\n",
+								dev->name);
+		return NULL;
+	}
+
+	/* Make sure new skb is properly aligned */
+	skb_align(new_skb, 32);
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
+
 static int fs_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
@@ -595,6 +622,18 @@ static int fs_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	u16 sc;
 	unsigned long flags;
 
+	if (fep->fec.fec_id == FS_ENET_MPC5121_FEC) {
+		skb = tx_skb_align_workaround(dev, skb);
+		if (!skb) {
+			/*
+			 * We have lost packet due to memory allocation error
+			 * in tx_skb_align_workaround(). Hopefully original skb
+			 * is still valid, so try transmit it later.
+			 */
+			return NETDEV_TX_BUSY;
+		}
+	}
+
 	spin_lock_irqsave(&fep->tx_lock, flags);
 
 	/*
-- 
1.5.6.3

