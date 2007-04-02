From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH linux1394-2.6.git 10/15] ieee1394: eth1394: don't use
	alloc_etherdev
Date: Mon, 2 Apr 2007 02:20:37 +0200 (CEST)
Message-ID: <tkrat.0a8d07dc26569210@s5r6.in-berlin.de>
References: <tkrat.7cdc7f6a1e6d9f28@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux1394-devel@lists.sourceforge.net
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <tkrat.7cdc7f6a1e6d9f28@s5r6.in-berlin.de>
Content-Disposition: INLINE
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux1394-devel-bounces@lists.sourceforge.net
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
---
 drivers/ieee1394/eth1394.c |   20 +++++---------------
 1 file changed, 5 insertions(+), 15 deletions(-)

Index: linux/drivers/ieee1394/eth1394.c
===================================================================
--- linux.orig/drivers/ieee1394/eth1394.c
+++ linux/drivers/ieee1394/eth1394.c
@@ -50,7 +50,6 @@
 
 #include <linux/netdevice.h>
 #include <linux/inetdevice.h>
-#include <linux/etherdevice.h>
 #include <linux/if_arp.h>
 #include <linux/if_ether.h>
 #include <linux/ip.h>
@@ -498,10 +497,8 @@ static void ether1394_reset_priv(struct 
 	spin_unlock_irqrestore(&priv->lock, flags);
 }
 
-/* This function is called right before register_netdev */
 static void ether1394_init_dev(struct net_device *dev)
 {
-	/* Our functions */
 	dev->open		= ether1394_open;
 	dev->stop		= ether1394_stop;
 	dev->hard_start_xmit	= ether1394_tx;
@@ -514,10 +511,9 @@ static void ether1394_init_dev(struct ne
 	dev->hard_header_cache	= ether1394_header_cache;
 	dev->header_cache_update= ether1394_header_cache_update;
 	dev->hard_header_parse	= ether1394_header_parse;
-	dev->set_mac_address	= NULL;
+
 	SET_ETHTOOL_OPS(dev, &ethtool_ops);
 
-	/* Some constants */
 	dev->watchdog_timeo	= ETHER1394_TIMEOUT;
 	dev->flags		= IFF_BROADCAST | IFF_MULTICAST;
 	dev->features		= NETIF_F_HIGHDMA;
@@ -525,7 +521,8 @@ static void ether1394_init_dev(struct ne
 	dev->hard_header_len 	= ETH1394_HLEN;
 	dev->type		= ARPHRD_IEEE1394;
 
-	ether1394_reset_priv(dev, 1);
+	/* FIXME: This value was copied from ether_setup(). Is it too much? */
+	dev->tx_queue_len	= 1000;
 }
 
 /*
@@ -555,11 +552,7 @@ static void ether1394_add_host(struct hp
 		return;
 	}
 
-	/* We should really have our own alloc_hpsbdev() function in
-	 * net_init.c instead of calling the one for ethernet then hijacking
-	 * it for ourselves.  That way we'd be a real networking device. */
-	dev = alloc_etherdev(sizeof (struct eth1394_priv));
-
+	dev = alloc_netdev(sizeof(*priv), "eth%d", ether1394_init_dev);
 	if (dev == NULL) {
 		ETH1394_PRINT_G(KERN_ERR, "Out of memory\n");
 		goto out;
@@ -572,21 +565,18 @@ static void ether1394_add_host(struct hp
 #endif
 
 	priv = netdev_priv(dev);
-
 	INIT_LIST_HEAD(&priv->ip_node_list);
-
 	spin_lock_init(&priv->lock);
 	priv->host = host;
 	priv->local_fifo = fifo_addr;
 
 	hi = hpsb_create_hostinfo(&eth1394_highlevel, host, sizeof(*hi));
-
 	if (hi == NULL) {
 		ETH1394_PRINT_G(KERN_ERR, "Out of memory\n");
 		goto out;
 	}
 
-	ether1394_init_dev(dev);
+	ether1394_reset_priv(dev, 1);
 
 	if (register_netdev(dev)) {
 		ETH1394_PRINT_G(KERN_ERR, "Cannot register the driver\n");

-- 
Stefan Richter
-=====-=-=== -=-- ---=-
http://arcgraph.de/sr/


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
