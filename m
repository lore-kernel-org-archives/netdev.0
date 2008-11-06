From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes for 2.6.28-rc
Date: Thu, 6 Nov 2008 01:50:03 -0500
Message-ID: <20081106065003.GA19105@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:50127 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751367AbYKFGuF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2008 01:50:05 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull from 'davem-fixes' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-fixes

to receive the following updates:

 drivers/net/3c509.c          |    6 +++---
 drivers/net/mlx4/en_netdev.c |    2 +-
 drivers/net/sfc/ethtool.c    |    4 ++--
 drivers/net/tun.c            |    4 ++--
 drivers/net/usb/hso.c        |   12 +++++++-----
 drivers/net/virtio_net.c     |    2 +-
 6 files changed, 16 insertions(+), 14 deletions(-)

Al Viro (1):
      el3_common_init() should be __devinit, not __init

Ben Hutchings (1):
      sfc: Correct address of gPXE boot configuration in EEPROM

Jonathan McDowell (1):
      [netdrvr] usb/hso: Cleanup rfkill error handling

Mark McLoughlin (2):
      virtio_net: don't set NETIF_F_FRAGLIST
      tun: don't set NETIF_F_FRAGLIST

Paulius Zaleckas (1):
      hso: rfkill type should be WWAN

Yevgeny Petrilin (1):
      mlx4_en: Start port error flow bug fix

diff --git a/drivers/net/3c509.c b/drivers/net/3c509.c
index 3a7bc52..c7a4f3b 100644
--- a/drivers/net/3c509.c
+++ b/drivers/net/3c509.c
@@ -94,7 +94,7 @@
 #include <asm/io.h>
 #include <asm/irq.h>
 
-static char version[] __initdata = DRV_NAME ".c:" DRV_VERSION " " DRV_RELDATE " becker@scyld.com\n";
+static char version[] __devinitdata = DRV_NAME ".c:" DRV_VERSION " " DRV_RELDATE " becker@scyld.com\n";
 
 #ifdef EL3_DEBUG
 static int el3_debug = EL3_DEBUG;
@@ -186,7 +186,7 @@ static int max_interrupt_work = 10;
 static int nopnp;
 #endif
 
-static int __init el3_common_init(struct net_device *dev);
+static int __devinit el3_common_init(struct net_device *dev);
 static void el3_common_remove(struct net_device *dev);
 static ushort id_read_eeprom(int index);
 static ushort read_eeprom(int ioaddr, int index);
@@ -537,7 +537,7 @@ static struct mca_driver el3_mca_driver = {
 static int mca_registered;
 #endif /* CONFIG_MCA */
 
-static int __init el3_common_init(struct net_device *dev)
+static int __devinit el3_common_init(struct net_device *dev)
 {
 	struct el3_private *lp = netdev_priv(dev);
 	int err;
diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index a339afb..a3f7324 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -706,7 +706,7 @@ tx_err:
 	mlx4_en_release_rss_steer(priv);
 rx_err:
 	for (i = 0; i < priv->rx_ring_num; i++)
-		mlx4_en_deactivate_rx_ring(priv, &priv->rx_ring[rx_index]);
+		mlx4_en_deactivate_rx_ring(priv, &priv->rx_ring[i]);
 cq_err:
 	while (rx_index--)
 		mlx4_en_deactivate_cq(priv, &priv->rx_cq[rx_index]);
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index fa98af5..cd0d087 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -174,8 +174,8 @@ static struct efx_ethtool_stat efx_ethtool_stats[] = {
 
 /* EEPROM range with gPXE configuration */
 #define EFX_ETHTOOL_EEPROM_MAGIC 0xEFAB
-#define EFX_ETHTOOL_EEPROM_MIN 0x100U
-#define EFX_ETHTOOL_EEPROM_MAX 0x400U
+#define EFX_ETHTOOL_EEPROM_MIN 0x800U
+#define EFX_ETHTOOL_EEPROM_MAX 0x1800U
 
 /**************************************************************************
  *
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 6daea0c..86433ea 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -844,11 +844,11 @@ static int set_offload(struct net_device *dev, unsigned long arg)
 
 	old_features = dev->features;
 	/* Unset features, set them as we chew on the arg. */
-	features = (old_features & ~(NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST
+	features = (old_features & ~(NETIF_F_HW_CSUM|NETIF_F_SG
 				    |NETIF_F_TSO_ECN|NETIF_F_TSO|NETIF_F_TSO6));
 
 	if (arg & TUN_F_CSUM) {
-		features |= NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST;
+		features |= NETIF_F_HW_CSUM|NETIF_F_SG;
 		arg &= ~TUN_F_CSUM;
 
 		if (arg & (TUN_F_TSO4|TUN_F_TSO6)) {
diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 1164c52..8e90891 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -2184,19 +2184,20 @@ static void hso_create_rfkill(struct hso_device *hso_dev,
 			     struct usb_interface *interface)
 {
 	struct hso_net *hso_net = dev2net(hso_dev);
-	struct device *dev = hso_dev->dev;
+	struct device *dev = &hso_net->net->dev;
 	char *rfkn;
 
 	hso_net->rfkill = rfkill_allocate(&interface_to_usbdev(interface)->dev,
-				 RFKILL_TYPE_WLAN);
+				 RFKILL_TYPE_WWAN);
 	if (!hso_net->rfkill) {
-		dev_err(dev, "%s - Out of memory", __func__);
+		dev_err(dev, "%s - Out of memory\n", __func__);
 		return;
 	}
 	rfkn = kzalloc(20, GFP_KERNEL);
 	if (!rfkn) {
 		rfkill_free(hso_net->rfkill);
-		dev_err(dev, "%s - Out of memory", __func__);
+		hso_net->rfkill = NULL;
+		dev_err(dev, "%s - Out of memory\n", __func__);
 		return;
 	}
 	snprintf(rfkn, 20, "hso-%d",
@@ -2209,7 +2210,8 @@ static void hso_create_rfkill(struct hso_device *hso_dev,
 		kfree(rfkn);
 		hso_net->rfkill->name = NULL;
 		rfkill_free(hso_net->rfkill);
-		dev_err(dev, "%s - Failed to register rfkill", __func__);
+		hso_net->rfkill = NULL;
+		dev_err(dev, "%s - Failed to register rfkill\n", __func__);
 		return;
 	}
 }
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 0196a0d..9d4fdad 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -505,7 +505,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 	/* Do we support "hardware" checksums? */
 	if (csum && virtio_has_feature(vdev, VIRTIO_NET_F_CSUM)) {
 		/* This opens up the world of extra features. */
-		dev->features |= NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST;
+		dev->features |= NETIF_F_HW_CSUM|NETIF_F_SG;
 		if (gso && virtio_has_feature(vdev, VIRTIO_NET_F_GSO)) {
 			dev->features |= NETIF_F_TSO | NETIF_F_UFO
 				| NETIF_F_TSO_ECN | NETIF_F_TSO6;
