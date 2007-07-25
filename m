From: Ralf Baechle <ralf@linux-mips.org>
Subject: [NET] IOC3: Switch hw checksumming to ethtool configurable.
Date: Wed, 25 Jul 2007 12:31:57 +0100
Message-ID: <20070725113157.GA29416@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:39131 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759529AbXGYLcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 07:32:05 -0400
Received: from localhost.localdomain ([127.0.0.1]:42969 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20021436AbXGYLcC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2007 12:32:02 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

---

I've previously sent out this patch a long time ago.  At that time I was
told NETIF_F_IP_CSUM wouldn't make any sense without NETIF_F_SG.  IOC3's
S/G abilities are very limited; it can do upto three segments of which
the first one is upto 104 bytes and part of the packet's TX ring entry,
the second and 3rd ones can be anywhere in the 64-bit PCI address space
but may not cross a 16kB page boundary.  So setting NETIF_F_SG isn't
really an option unless the IOC3 was going to linearize any packet it
can't cope with itself.

So the big question, does NETIF_F_IP_CSUM without NETIF_F_SG make sense?

 drivers/net/Kconfig    |   20 --------------------
 drivers/net/ioc3-eth.c |   48 ++++++++++++++++++++++++++++++++----------------
 2 files changed, 32 insertions(+), 36 deletions(-)

Index: linux-2.6/drivers/net/Kconfig
===================================================================
--- linux-2.6.orig/drivers/net/Kconfig
+++ linux-2.6/drivers/net/Kconfig
@@ -480,26 +480,6 @@ config SGI_IOC3_ETH
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-config SGI_IOC3_ETH_HW_RX_CSUM
-	bool "Receive hardware checksums"
-	depends on SGI_IOC3_ETH && INET
-	default y
-	help
-	  The SGI IOC3 network adapter supports TCP and UDP checksums in
-	  hardware to offload processing of these checksums from the CPU.  At
-	  the moment only acceleration of IPv4 is supported.  This option
-	  enables offloading for checksums on receive.  If unsure, say Y.
-
-config SGI_IOC3_ETH_HW_TX_CSUM
-	bool "Transmit hardware checksums"
-	depends on SGI_IOC3_ETH && INET
-	default y
-	help
-	  The SGI IOC3 network adapter supports TCP and UDP checksums in
-	  hardware to offload processing of these checksums from the CPU.  At
-	  the moment only acceleration of IPv4 is supported.  This option
-	  enables offloading for checksums on transmit.  If unsure, say Y.
-
 config MIPS_SIM_NET
 	tristate "MIPS simulator Network device"
 	depends on MIPS_SIM
Index: linux-2.6/drivers/net/ioc3-eth.c
===================================================================
--- linux-2.6.orig/drivers/net/ioc3-eth.c
+++ linux-2.6/drivers/net/ioc3-eth.c
@@ -5,7 +5,7 @@
  *
  * Driver for SGI's IOC3 based Ethernet cards as found in the PCI card.
  *
- * Copyright (C) 1999, 2000, 2001, 2003 Ralf Baechle
+ * Copyright (C) 1999, 2000, 01, 03, 06 Ralf Baechle
  * Copyright (C) 1995, 1999, 2000, 2001 by Silicon Graphics, Inc.
  *
  * References:
@@ -61,12 +61,7 @@
 #include <asm/pgtable.h>
 #include <asm/uaccess.h>
 #include <asm/sn/types.h>
-#include <asm/sn/sn0/addrs.h>
-#include <asm/sn/sn0/hubni.h>
-#include <asm/sn/sn0/hubio.h>
-#include <asm/sn/klconfig.h>
 #include <asm/sn/ioc3.h>
-#include <asm/sn/sn0/ip27.h>
 #include <asm/pci/bridge.h>
 
 /*
@@ -94,6 +89,9 @@ struct ioc3_private {
 	u32 emcr, ehar_h, ehar_l;
 	spinlock_t ioc3_lock;
 	struct mii_if_info mii;
+	unsigned long flags;
+#define IOC3_FLAG_RX_CHECKSUMS	1
+
 	struct pci_dev *pdev;
 
 	/* Members used by autonegotiation  */
@@ -520,8 +518,6 @@ static struct net_device_stats *ioc3_get
 	return &ip->stats;
 }
 
-#ifdef CONFIG_SGI_IOC3_ETH_HW_RX_CSUM
-
 static void ioc3_tcpudp_checksum(struct sk_buff *skb, uint32_t hwsum, int len)
 {
 	struct ethhdr *eh = eth_hdr(skb);
@@ -589,7 +585,6 @@ static void ioc3_tcpudp_checksum(struct 
 	if (csum == 0xffff)
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 }
-#endif /* CONFIG_SGI_IOC3_ETH_HW_RX_CSUM */
 
 static inline void ioc3_rx(struct ioc3_private *ip)
 {
@@ -624,9 +619,9 @@ static inline void ioc3_rx(struct ioc3_p
 				goto next;
 			}
 
-#ifdef CONFIG_SGI_IOC3_ETH_HW_RX_CSUM
-			ioc3_tcpudp_checksum(skb, w0 & ERXBUF_IPCKSUM_MASK,len);
-#endif
+			if (likely(ip->flags & IOC3_FLAG_RX_CHECKSUMS))
+				ioc3_tcpudp_checksum(skb,
+					w0 & ERXBUF_IPCKSUM_MASK, len);
 
 			netif_rx(skb);
 
@@ -1298,9 +1293,7 @@ static int ioc3_probe(struct pci_dev *pd
 	dev->set_multicast_list	= ioc3_set_multicast_list;
 	dev->set_mac_address	= ioc3_set_mac_address;
 	dev->ethtool_ops	= &ioc3_ethtool_ops;
-#ifdef CONFIG_SGI_IOC3_ETH_HW_TX_CSUM
 	dev->features		= NETIF_F_IP_CSUM;
-#endif
 
 	sw_physid1 = ioc3_mdio_read(dev, ip->mii.phy_id, MII_PHYSID1);
 	sw_physid2 = ioc3_mdio_read(dev, ip->mii.phy_id, MII_PHYSID2);
@@ -1390,7 +1383,6 @@ static int ioc3_start_xmit(struct sk_buf
 	uint32_t w0 = 0;
 	int produce;
 
-#ifdef CONFIG_SGI_IOC3_ETH_HW_TX_CSUM
 	/*
 	 * IOC3 has a fairly simple minded checksumming hardware which simply
 	 * adds up the 1's complement checksum for the entire packet and
@@ -1438,7 +1430,6 @@ static int ioc3_start_xmit(struct sk_buf
 
 		w0 = ETXD_DOCHECKSUM | (csoff << ETXD_CHKOFF_SHIFT);
 	}
-#endif /* CONFIG_SGI_IOC3_ETH_HW_TX_CSUM */
 
 	spin_lock_irq(&ip->ioc3_lock);
 
@@ -1593,12 +1584,37 @@ static u32 ioc3_get_link(struct net_devi
 	return rc;
 }
 
+static u32 ioc3_get_rx_csum(struct net_device *dev)
+{
+	struct ioc3_private *ip = netdev_priv(dev);
+
+	return ip->flags & IOC3_FLAG_RX_CHECKSUMS;
+}
+
+static int ioc3_set_rx_csum(struct net_device *dev, u32 data)
+{
+	struct ioc3_private *ip = netdev_priv(dev);
+
+	spin_lock_bh(&ip->ioc3_lock);
+	if (data)
+		ip->flags |= IOC3_FLAG_RX_CHECKSUMS;
+	else
+		ip->flags &= ~IOC3_FLAG_RX_CHECKSUMS;
+	spin_unlock_bh(&ip->ioc3_lock);
+
+	return 0;
+}
+
 static const struct ethtool_ops ioc3_ethtool_ops = {
 	.get_drvinfo		= ioc3_get_drvinfo,
 	.get_settings		= ioc3_get_settings,
 	.set_settings		= ioc3_set_settings,
 	.nway_reset		= ioc3_nway_reset,
 	.get_link		= ioc3_get_link,
+	.get_rx_csum		= ioc3_get_rx_csum,
+	.set_rx_csum		= ioc3_set_rx_csum,
+	.get_tx_csum		= ethtool_op_get_tx_csum,
+	.set_tx_csum		= ethtool_op_set_tx_csum
 };
 
 static int ioc3_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
