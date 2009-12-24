From: Daniel Drake <dsd@laptop.org>
Subject: [PATCH] Fix MAC address access in 3c507, ibmlana, pcnet32 and libertas
Date: Thu, 24 Dec 2009 18:11:24 +0000 (GMT)
Message-ID: <20091224181125.162AC9D400D@zog.reactivated.net>
Cc: jpirko@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout03-winn.ispmail.ntl.com ([81.103.221.49]:28424 "EHLO
	mtaout03-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753071AbZLXSL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2009 13:11:29 -0500
Cc: netdev@vger.kernel.org
Cc: pcnet32@verizon.net
Cc: dcbw@redhat.com
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit f001fde5eadd915f4858d22ed70d7040f48767cf changed
net_device.dev_addr from a 32-byte array to a pointer.

I found 4 ethernet drivers which rely on sizeof(dev_addr), which are now
only copying 4 bytes of the address information on 32bit systems.

Fix them to use ETH_ALEN.

Signed-off-by: Daniel Drake <dsd@laptop.org>
---

Fix tested and confirmed on libertas, review of the other 3 drivers
would be appreciated.

 drivers/net/3c507.c                  |    4 ++--
 drivers/net/ibmlana.c                |    3 ++-
 drivers/net/pcnet32.c                |    3 ++-
 drivers/net/wireless/libertas/mesh.c |    4 ++--
 4 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/3c507.c b/drivers/net/3c507.c
index fbc2311..77cf090 100644
--- a/drivers/net/3c507.c
+++ b/drivers/net/3c507.c
@@ -56,6 +56,7 @@ static const char version[] =
 #include <linux/errno.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/if_ether.h>
 #include <linux/skbuff.h>
 #include <linux/slab.h>
 #include <linux/init.h>
@@ -734,8 +735,7 @@ static void init_82586_mem(struct net_device *dev)
 	memcpy_toio(lp->base, init_words + 5, sizeof(init_words) - 10);
 
 	/* Fill in the station address. */
-	memcpy_toio(lp->base+SA_OFFSET, dev->dev_addr,
-		   sizeof(dev->dev_addr));
+	memcpy_toio(lp->base+SA_OFFSET, dev->dev_addr, ETH_ALEN);
 
 	/* The Tx-block list is written as needed.  We just set up the values. */
 	lp->tx_cmd_link = IDLELOOP + 4;
diff --git a/drivers/net/ibmlana.c b/drivers/net/ibmlana.c
index 090a6d3..052c740 100644
--- a/drivers/net/ibmlana.c
+++ b/drivers/net/ibmlana.c
@@ -87,6 +87,7 @@ History:
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/if_ether.h>
 #include <linux/skbuff.h>
 #include <linux/bitops.h>
 
@@ -988,7 +989,7 @@ static int __devinit ibmlana_init_one(struct device *kdev)
 
 	/* copy out MAC address */
 
-	for (z = 0; z < sizeof(dev->dev_addr); z++)
+	for (z = 0; z < ETH_ALEN; z++)
 		dev->dev_addr[z] = inb(dev->base_addr + MACADDRPROM + z);
 
 	/* print config */
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index dcc67a3..e154677 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -45,6 +45,7 @@ static const char *const version =
 #include <linux/crc32.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/if_ether.h>
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
 #include <linux/moduleparam.h>
@@ -1765,7 +1766,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 
 	/* if the ethernet address is not valid, force to 00:00:00:00:00:00 */
 	if (!is_valid_ether_addr(dev->perm_addr))
-		memset(dev->dev_addr, 0, sizeof(dev->dev_addr));
+		memset(dev->dev_addr, 0, ETH_ALEN);
 
 	if (pcnet32_debug & NETIF_MSG_PROBE) {
 		printk(" %pM", dev->dev_addr);
diff --git a/drivers/net/wireless/libertas/mesh.c b/drivers/net/wireless/libertas/mesh.c
index 2f91c9b..92b7a35 100644
--- a/drivers/net/wireless/libertas/mesh.c
+++ b/drivers/net/wireless/libertas/mesh.c
@@ -2,6 +2,7 @@
 #include <linux/delay.h>
 #include <linux/etherdevice.h>
 #include <linux/netdevice.h>
+#include <linux/if_ether.h>
 #include <linux/if_arp.h>
 #include <linux/kthread.h>
 #include <linux/kfifo.h>
@@ -351,8 +352,7 @@ int lbs_add_mesh(struct lbs_private *priv)
 
 	mesh_dev->netdev_ops = &mesh_netdev_ops;
 	mesh_dev->ethtool_ops = &lbs_ethtool_ops;
-	memcpy(mesh_dev->dev_addr, priv->dev->dev_addr,
-			sizeof(priv->dev->dev_addr));
+	memcpy(mesh_dev->dev_addr, priv->dev->dev_addr, ETH_ALEN);
 
 	SET_NETDEV_DEV(priv->mesh_dev, priv->dev->dev.parent);
 
-- 
1.6.2.5

