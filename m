From: Anatolij Gustschin <agust@denx.de>
Subject: [net-next-2.6 PATCH 3/3] fs_enet: Add FEC TX Alignment workaround for MPC5121
Date: Thu, 21 Jan 2010 03:13:19 +0100
Message-ID: <1264039999-25731-4-git-send-email-agust@denx.de>
References: <1264039999-25731-1-git-send-email-agust@denx.de>
Cc: dzu@denx.de, wd@denx.de, Anatolij Gustschin <agust@denx.de>,
	John Rigby <jcrigby@gmail.com>,
	Piotr Ziecik <kosmo@semihalf.com>, <linuxppc-dev@ozlabs.org>,
	Grant Likely <grant.likely@secretlab.ca>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:56754 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753405Ab0AUCNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 21:13:22 -0500
In-Reply-To: <1264039999-25731-1-git-send-email-agust@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The FEC on 5121 has problems with misaligned tx buffers.
The RM says any alignment is ok but empirical results
show that packet buffers ending in 0x1E will sometimes
hang the FEC.  Other bad alignment does not hang but will
cause silent TX failures resulting in about a 1% packet
loss as tested by ping -f from a remote host.

This patch is a work around that copies every tx packet
to an aligned skb before sending.

Signed-off-by: John Rigby <jcrigby@gmail.com>
Signed-off-by: Piotr Ziecik <kosmo@semihalf.com>
Signed-off-by: Wolfgang Denk <wd@denx.de>
Signed-off-by: Anatolij Gustschin <agust@denx.de>
Cc: <linuxppc-dev@ozlabs.org>
Cc: Grant Likely <grant.likely@secretlab.ca>
---
Changes since previous submited version:

- don't use printk any more and use dev_warn().

 drivers/net/fs_enet/fs_enet-main.c |   38 ++++++++++++++++++++++++++++++++++++
 1 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index 6bce5c8..7f0bd5d 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -580,6 +580,32 @@ void fs_cleanup_bds(struct net_device *dev)
 
 /**********************************************************************************/
 
+static struct sk_buff *tx_skb_align_workaround(struct net_device *dev,
+					       struct sk_buff *skb)
+{
+	struct sk_buff *new_skb;
+	struct fs_enet_private *fep = netdev_priv(dev);
+
+	/* Alloc new skb */
+	new_skb = dev_alloc_skb(ENET_RX_FRSIZE + 32);
+	if (!new_skb) {
+		dev_warn(fep->dev, "Memory squeeze, dropping tx packet.\n");
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
@@ -588,6 +614,18 @@ static int fs_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
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

