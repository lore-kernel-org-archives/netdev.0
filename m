From: Finn Thain <fthain@telegraphics.com.au>
Subject: [PATCH net v2 3/9] net/mac89x0: Fix and modernize log messages
Date: Thu,  5 Oct 2017 21:11:05 -0400 (EDT)
Message-ID: <e9fb341944d187cabf1ccef78cfdc9de64e3f158.1507211120.git.fthain@telegraphics.com.au>
References: <cover.1507211120.git.fthain@telegraphics.com.au>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1507211120.git.fthain@telegraphics.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix misplaced newlines in conditional log messages.
Add missing printk severity levels.
Log the MAC address after the interface gets a meaningful name.
Drop deprecated "out of memory" message as per checkpatch advice.

Signed-off-by: Finn Thain <fthain@telegraphics.com.au>
---
 drivers/net/ethernet/cirrus/mac89x0.c | 26 ++++++++++++--------------
 1 file changed, 12 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/cirrus/mac89x0.c b/drivers/net/ethernet/cirrus/mac89x0.c
index 4fd72c1a69f5..fa4b6968afd5 100644
--- a/drivers/net/ethernet/cirrus/mac89x0.c
+++ b/drivers/net/ethernet/cirrus/mac89x0.c
@@ -56,6 +56,8 @@
   local_irq_{dis,en}able()
 */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 static const char version[] =
 "cs89x0.c:v1.02 11/26/96 Russell Nelson <nelson@crynwr.com>\n";
 
@@ -248,16 +250,14 @@ struct net_device * __init mac89x0_probe(int unit)
 	if (net_debug && version_printed++ == 0)
 		printk(version);
 
-	printk(KERN_INFO "%s: cs89%c0%s rev %c found at %#8lx",
-	       dev->name,
-	       lp->chip_type==CS8900?'0':'2',
-	       lp->chip_type==CS8920M?"M":"",
-	       lp->chip_revision,
-	       dev->base_addr);
+	pr_info("CS89%c0%s rev %c found at %#8lx\n",
+	        lp->chip_type == CS8900 ? '0' : '2',
+	        lp->chip_type == CS8920M ? "M" : "",
+	        lp->chip_revision, dev->base_addr);
 
 	/* Try to read the MAC address */
 	if ((readreg(dev, PP_SelfST) & (EEPROM_PRESENT | EEPROM_OK)) == 0) {
-		printk("\nmac89x0: No EEPROM, giving up now.\n");
+		pr_info("No EEPROM, giving up now\n");
 		goto out1;
         } else {
                 for (i = 0; i < ETH_ALEN; i += 2) {
@@ -270,15 +270,14 @@ struct net_device * __init mac89x0_probe(int unit)
 
 	dev->irq = SLOT2IRQ(slot);
 
-	/* print the IRQ and ethernet address. */
-
-	printk(" IRQ %d ADDR %pM\n", dev->irq, dev->dev_addr);
-
 	dev->netdev_ops		= &mac89x0_netdev_ops;
 
 	err = register_netdev(dev);
 	if (err)
 		goto out1;
+
+	netdev_info(dev, "MAC %pM, IRQ %d\n", dev->dev_addr, dev->irq);
+
 	return NULL;
 out1:
 	nubus_writew(0, dev->base_addr + ADD_PORT);
@@ -473,7 +472,6 @@ net_rx(struct net_device *dev)
 	/* Malloc up new buffer. */
 	skb = alloc_skb(length, GFP_ATOMIC);
 	if (skb == NULL) {
-		printk("%s: Memory squeeze, dropping packet.\n", dev->name);
 		dev->stats.rx_dropped++;
 		return;
 	}
@@ -561,7 +559,7 @@ static int set_mac_address(struct net_device *dev, void *addr)
 		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, saddr->sa_data, ETH_ALEN);
-	printk("%s: Setting MAC address to %pM\n", dev->name, dev->dev_addr);
+	netdev_info(dev, "Setting MAC address to %pM\n", dev->dev_addr);
 
 	/* set the Ethernet address */
 	for (i=0; i < ETH_ALEN/2; i++)
@@ -585,7 +583,7 @@ init_module(void)
 	net_debug = debug;
         dev_cs89x0 = mac89x0_probe(-1);
 	if (IS_ERR(dev_cs89x0)) {
-                printk(KERN_WARNING "mac89x0.c: No card found\n");
+		pr_warn("No card found\n");
 		return PTR_ERR(dev_cs89x0);
 	}
 	return 0;
-- 
2.13.5
