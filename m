From: Wolfgang Denk <wd@denx.de>
Subject: [PATCH 03/12] fs_enet: Add FEC TX Alignment workaround for MPC5121.
Date: Wed,  6 May 2009 22:15:10 +0200
Message-ID: <1241640919-4650-4-git-send-email-wd@denx.de>
References: <1241640919-4650-1-git-send-email-wd@denx.de>
Cc: John Rigby <jrigby@freescale.com>,
	Piotr Ziecik <kosmo@semihalf.com>, Wolfgang Denk <wd@denx.de>,
	<netdev@vger.kernel.org>, Grant Likely <grant.likely@secretlab.ca>,
	John Rigby <jcrigby@gmail.com>
To: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:33141 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756092AbZEFUPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 16:15:24 -0400
In-Reply-To: <1241640919-4650-1-git-send-email-wd@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Rigby <jrigby@freescale.com>

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
Cc: <netdev@vger.kernel.org>
Cc: Grant Likely <grant.likely@secretlab.ca>
Cc: John Rigby <jcrigby@gmail.com>
---
 drivers/net/fs_enet/Kconfig        |    3 ++
 drivers/net/fs_enet/fs_enet-main.c |   41 ++++++++++++++++++++++++++++++++++++
 drivers/net/fs_enet/mac-fec.c      |    2 +-
 3 files changed, 45 insertions(+), 1 deletions(-)

diff --git a/drivers/net/fs_enet/Kconfig b/drivers/net/fs_enet/Kconfig
index fc073b5..79afd07 100644
--- a/drivers/net/fs_enet/Kconfig
+++ b/drivers/net/fs_enet/Kconfig
@@ -8,6 +8,9 @@ config FS_ENET_MPC5121_FEC
 	def_bool y if (FS_ENET && PPC_MPC512x)
 	select FS_ENET_HAS_FEC
 
+config FS_ENET_FEC_TX_ALIGN_WORKAROUND
+	def_bool y if FS_ENET_MPC5121_FEC
+
 config FS_ENET_HAS_SCC
 	bool "Chip has an SCC usable for ethernet"
 	depends on FS_ENET && (CPM1 || CPM2)
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index 4170d33..c83ffc3 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -594,6 +594,37 @@ void fs_cleanup_bds(struct net_device *dev)
 
 /**********************************************************************************/
 
+#ifdef CONFIG_FS_ENET_FEC_TX_ALIGN_WORKAROUND
+static struct sk_buff *tx_skb_align_workaround(struct net_device *dev,
+							struct sk_buff *skb)
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
+#else
+#define tx_skb_align_workaround(dev, skb) (skb)
+#endif
+
 static int fs_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
@@ -602,6 +633,16 @@ static int fs_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	u16 sc;
 	unsigned long flags;
 
+	skb = tx_skb_align_workaround(dev, skb);
+	if (!skb) {
+		/*
+		 * We have lost packet due to memory allocation error in
+		 * tx_skb_align_workaround(). Hopefully original skb is still
+		 * valid, so try transmit it later.
+		 */
+		return NETDEV_TX_BUSY;
+	}
+
 	spin_lock_irqsave(&fep->tx_lock, flags);
 
 	/*
diff --git a/drivers/net/fs_enet/mac-fec.c b/drivers/net/fs_enet/mac-fec.c
index b069088..3e86498 100644
--- a/drivers/net/fs_enet/mac-fec.c
+++ b/drivers/net/fs_enet/mac-fec.c
@@ -311,7 +311,7 @@ static void restart(struct net_device *dev)
 	 * Enable big endian.
 	 */
 #ifndef CONFIG_FS_ENET_MPC5121_FEC
-	/* Don't care about SDMA FC. */
+	/* Don't care about SDMA Function Code. */
 	FW(fecp, fun_code, 0x78000000);
 #else
 	FS(fecp, dma_control, 0xC0000000);
-- 
1.6.0.6

