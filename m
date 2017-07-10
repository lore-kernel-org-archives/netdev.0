From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH] ioc3-eth: store pointer to net_device for priviate area
Date: Mon, 10 Jul 2017 14:00:32 +0200
Message-ID: <20170710120032.11173-1-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: ralf@linux-mips.org, linux-mips@linux-mips.org,
        netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:57013 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753497AbdGJMAh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Jul 2017 08:00:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Computing the alignment manually for going from priv to pub is probably
not such a good idea, and in general the assumption that going from priv
to pub is possible trivially could change, so rather than relying on
that, we change things to just store a pointer to pub. This was sugested
by DaveM in [1].

[1] http://www.spinics.net/lists/netdev/msg443992.html

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
---
Ralf - I don't have the platform to test this out, so you might want to
briefly put it through the paces before giving it your sign-off.

 drivers/net/ethernet/sgi/ioc3-eth.c | 14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/sgi/ioc3-eth.c b/drivers/net/ethernet/sgi/ioc3-eth.c
index b607936e1b3e..9c0488e0f08e 100644
--- a/drivers/net/ethernet/sgi/ioc3-eth.c
+++ b/drivers/net/ethernet/sgi/ioc3-eth.c
@@ -90,17 +90,13 @@ struct ioc3_private {
 	spinlock_t ioc3_lock;
 	struct mii_if_info mii;
 
+	struct net_device *dev;
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
@@ -427,7 +423,7 @@ static void ioc3_get_eaddr_nic(struct ioc3_private *ip)
 		nic[i] = nic_read_byte(ioc3);
 
 	for (i = 2; i < 8; i++)
-		priv_netdev(ip)->dev_addr[i - 2] = nic[i];
+		ip->dev->dev_addr[i - 2] = nic[i];
 }
 
 /*
@@ -439,7 +435,7 @@ static void ioc3_get_eaddr(struct ioc3_private *ip)
 {
 	ioc3_get_eaddr_nic(ip);
 
-	printk("Ethernet address is %pM.\n", priv_netdev(ip)->dev_addr);
+	printk("Ethernet address is %pM.\n", ip->dev->dev_addr);
 }
 
 static void __ioc3_set_mac_address(struct net_device *dev)
@@ -790,13 +786,12 @@ static void ioc3_timer(unsigned long data)
  */
 static int ioc3_mii_init(struct ioc3_private *ip)
 {
-	struct net_device *dev = priv_netdev(ip);
 	int i, found = 0, res = 0;
 	int ioc3_phy_workaround = 1;
 	u16 word;
 
 	for (i = 0; i < 32; i++) {
-		word = ioc3_mdio_read(dev, i, MII_PHYSID1);
+		word = ioc3_mdio_read(ip->dev, i, MII_PHYSID1);
 
 		if (word != 0xffff && word != 0x0000) {
 			found = 1;
@@ -1276,6 +1271,7 @@ static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	ip = netdev_priv(dev);
+	ip->dev = dev;
 
 	dev->irq = pdev->irq;
 
-- 
2.13.2
