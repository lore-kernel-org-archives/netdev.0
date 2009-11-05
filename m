From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH 3/6] Staging: octeon-ethernet: Assign proper MAC addresses.
Date: Thu, 05 Nov 2009 16:25:59 +0100
Message-ID: <20091105152702.201728770@linux-mips.org>
References: <20091105152555.227009519@linux-mips.org>
Cc: David Daney <ddaney@caviumnetworks.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org,
	linux-mips@linux-mips.org, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757916AbZKERzo@vger.kernel.org>
Content-Disposition: inline; filename=0004.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <ddaney@caviumnetworks.com>

Allocate MAC addresses using the same method as the bootloader.  This
avoids changing the MAC between bootloader and kernel operation as
well as avoiding duplicates and use of addresses outside of the
assigned range.

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>
Cc: devel@driverdev.osuosl.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mips@linux-mips.org
Cc: netdev@vger.kernel.org
Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 drivers/staging/octeon/ethernet.c |   53 +++++++++++++++++++++++++++++---------
 1 file changed, 41 insertions(+), 12 deletions(-)

Index: upstream-linus/drivers/staging/octeon/ethernet.c
===================================================================
--- upstream-linus.orig/drivers/staging/octeon/ethernet.c
+++ upstream-linus/drivers/staging/octeon/ethernet.c
@@ -111,6 +111,16 @@ MODULE_PARM_DESC(disable_core_queueing, 
 	"\tallows packets to be sent without lock contention in the packet\n"
 	"\tscheduler resulting in some cases in improved throughput.\n");
 
+
+/*
+ * The offset from mac_addr_base that should be used for the next port
+ * that is configured.  By convention, if any mgmt ports exist on the
+ * chip, they get the first mac addresses, The ports controlled by
+ * this driver are numbered sequencially following any mgmt addresses
+ * that may exist.
+ */
+static unsigned int cvm_oct_mac_addr_offset;
+
 /**
  * Periodic timer to check auto negotiation
  */
@@ -474,16 +484,30 @@ static int cvm_oct_common_set_mac_addres
  */
 int cvm_oct_common_init(struct net_device *dev)
 {
-	static int count;
-	char mac[8] = { 0x00, 0x00,
-		octeon_bootinfo->mac_addr_base[0],
-		octeon_bootinfo->mac_addr_base[1],
-		octeon_bootinfo->mac_addr_base[2],
-		octeon_bootinfo->mac_addr_base[3],
-		octeon_bootinfo->mac_addr_base[4],
-		octeon_bootinfo->mac_addr_base[5] + count
-	};
 	struct octeon_ethernet *priv = netdev_priv(dev);
+	struct sockaddr sa;
+	u64 mac = ((u64)(octeon_bootinfo->mac_addr_base[0] & 0xff) << 40) |
+		((u64)(octeon_bootinfo->mac_addr_base[1] & 0xff) << 32) |
+		((u64)(octeon_bootinfo->mac_addr_base[2] & 0xff) << 24) |
+		((u64)(octeon_bootinfo->mac_addr_base[3] & 0xff) << 16) |
+		((u64)(octeon_bootinfo->mac_addr_base[4] & 0xff) << 8) |
+		(u64)(octeon_bootinfo->mac_addr_base[5] & 0xff);
+
+	mac += cvm_oct_mac_addr_offset;
+	sa.sa_data[0] = (mac >> 40) & 0xff;
+	sa.sa_data[1] = (mac >> 32) & 0xff;
+	sa.sa_data[2] = (mac >> 24) & 0xff;
+	sa.sa_data[3] = (mac >> 16) & 0xff;
+	sa.sa_data[4] = (mac >> 8) & 0xff;
+	sa.sa_data[5] = mac & 0xff;
+
+	if (cvm_oct_mac_addr_offset >= octeon_bootinfo->mac_addr_count)
+		printk(KERN_DEBUG "%s: Using MAC outside of the assigned range:"
+			" %02x:%02x:%02x:%02x:%02x:%02x\n", dev->name,
+			sa.sa_data[0] & 0xff, sa.sa_data[1] & 0xff,
+			sa.sa_data[2] & 0xff, sa.sa_data[3] & 0xff,
+			sa.sa_data[4] & 0xff, sa.sa_data[5] & 0xff);
+	cvm_oct_mac_addr_offset++;
 
 	/*
 	 * Force the interface to use the POW send if always_use_pow
@@ -496,14 +520,12 @@ int cvm_oct_common_init(struct net_devic
 	if (priv->queue != -1 && USE_HW_TCPUDP_CHECKSUM)
 		dev->features |= NETIF_F_IP_CSUM;
 
-	count++;
-
 	/* We do our own locking, Linux doesn't need to */
 	dev->features |= NETIF_F_LLTX;
 	SET_ETHTOOL_OPS(dev, &cvm_oct_ethtool_ops);
 
 	cvm_oct_mdio_setup_device(dev);
-	dev->netdev_ops->ndo_set_mac_address(dev, mac);
+	dev->netdev_ops->ndo_set_mac_address(dev, &sa);
 	dev->netdev_ops->ndo_change_mtu(dev, dev->mtu);
 
 	/*
@@ -620,6 +642,13 @@ static int __init cvm_oct_init_module(vo
 
 	pr_notice("cavium-ethernet %s\n", OCTEON_ETHERNET_VERSION);
 
+	if (OCTEON_IS_MODEL(OCTEON_CN52XX))
+		cvm_oct_mac_addr_offset = 2; /* First two are the mgmt ports. */
+	else if (OCTEON_IS_MODEL(OCTEON_CN56XX))
+		cvm_oct_mac_addr_offset = 1; /* First one is the mgmt port. */
+	else
+		cvm_oct_mac_addr_offset = 0;
+
 	cvm_oct_proc_initialize();
 	cvm_oct_rx_initialize();
 	cvm_oct_configure_common_hw();
