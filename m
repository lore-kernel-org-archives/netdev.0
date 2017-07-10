From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH 2/2] ioc3-eth: use netdev_pub instead of handrolling alignment
Date: Mon, 10 Jul 2017 05:19:59 +0200
Message-ID: <20170710031959.7496-2-Jason@zx2c4.com>
References: <20150612.142058.1085284048217032168.davem@davemloft.net>
 <20170710031959.7496-1-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:54247 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753076AbdGJDUj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 9 Jul 2017 23:20:39 -0400
In-Reply-To: <20170710031959.7496-1-Jason@zx2c4.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's safer to use the generic library function for this, rather than
reinventing it here with hard-coded alignment values.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
---
 drivers/net/ethernet/sgi/ioc3-eth.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/sgi/ioc3-eth.c b/drivers/net/ethernet/sgi/ioc3-eth.c
index b607936e1b3e..514eca163ea5 100644
--- a/drivers/net/ethernet/sgi/ioc3-eth.c
+++ b/drivers/net/ethernet/sgi/ioc3-eth.c
@@ -86,31 +86,26 @@ struct ioc3_private {
 	int tx_ci;			/* TX consumer index */
 	int tx_pi;			/* TX producer index */
 	int txqlen;
 	u32 emcr, ehar_h, ehar_l;
 	spinlock_t ioc3_lock;
 	struct mii_if_info mii;
 
 	struct pci_dev *pdev;
 
 	/* Members used by autonegotiation  */
 	struct timer_list ioc3_timer;
 };
 
-static inline struct net_device *priv_netdev(struct ioc3_private *dev)
-{
-	return (void *)dev - ((sizeof(struct net_device) + 31) & ~31);
-}
-
 static int ioc3_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static void ioc3_set_multicast_list(struct net_device *dev);
 static int ioc3_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static void ioc3_timeout(struct net_device *dev);
 static inline unsigned int ioc3_hash(const unsigned char *addr);
 static inline void ioc3_stop(struct ioc3_private *ip);
 static void ioc3_init(struct net_device *dev);
 
 static const char ioc3_str[] = "IOC3 Ethernet";
 static const struct ethtool_ops ioc3_ethtool_ops;
 
 /* We use this to acquire receive skb's that we can DMA directly into. */
 
@@ -417,39 +412,39 @@ static void ioc3_get_eaddr_nic(struct ioc3_private *ip)
 		printk("Failed to read MAC address\n");
 		return;
 	}
 
 	/* Read Memory.  */
 	nic_write_byte(ioc3, 0xf0);
 	nic_write_byte(ioc3, 0x00);
 	nic_write_byte(ioc3, 0x00);
 
 	for (i = 13; i >= 0; i--)
 		nic[i] = nic_read_byte(ioc3);
 
 	for (i = 2; i < 8; i++)
-		priv_netdev(ip)->dev_addr[i - 2] = nic[i];
+		netdev_pub(ip)->dev_addr[i - 2] = nic[i];
 }
 
 /*
  * Ok, this is hosed by design.  It's necessary to know what machine the
  * NIC is in in order to know how to read the NIC address.  We also have
  * to know if it's a PCI card or a NIC in on the node board ...
  */
 static void ioc3_get_eaddr(struct ioc3_private *ip)
 {
 	ioc3_get_eaddr_nic(ip);
 
-	printk("Ethernet address is %pM.\n", priv_netdev(ip)->dev_addr);
+	printk("Ethernet address is %pM.\n", netdev_pub(ip)->dev_addr);
 }
 
 static void __ioc3_set_mac_address(struct net_device *dev)
 {
 	struct ioc3_private *ip = netdev_priv(dev);
 	struct ioc3 *ioc3 = ip->regs;
 
 	ioc3_w_emar_h((dev->dev_addr[5] <<  8) | dev->dev_addr[4]);
 	ioc3_w_emar_l((dev->dev_addr[3] << 24) | (dev->dev_addr[2] << 16) |
 	              (dev->dev_addr[1] <<  8) | dev->dev_addr[0]);
 }
 
 static int ioc3_set_mac_address(struct net_device *dev, void *addr)
@@ -780,27 +775,27 @@ static void ioc3_timer(unsigned long data)
 	add_timer(&ip->ioc3_timer);
 }
 
 /*
  * Try to find a PHY.  There is no apparent relation between the MII addresses
  * in the SGI documentation and what we find in reality, so we simply probe
  * for the PHY.  It seems IOC3 PHYs usually live on address 31.  One of my
  * onboard IOC3s has the special oddity that probing doesn't seem to find it
  * yet the interface seems to work fine, so if probing fails we for now will
  * simply default to PHY 31 instead of bailing out.
  */
 static int ioc3_mii_init(struct ioc3_private *ip)
 {
-	struct net_device *dev = priv_netdev(ip);
+	struct net_device *dev = netdev_pub(ip);
 	int i, found = 0, res = 0;
 	int ioc3_phy_workaround = 1;
 	u16 word;
 
 	for (i = 0; i < 32; i++) {
 		word = ioc3_mdio_read(dev, i, MII_PHYSID1);
 
 		if (word != 0xffff && word != 0x0000) {
 			found = 1;
 			break;			/* Found a PHY		*/
 		}
 	}
 
-- 
2.13.2
