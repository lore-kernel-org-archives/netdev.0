From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH update 3] firewire: net: add carrier detection
Date: Tue, 14 Dec 2010 00:01:54 +0100
Message-ID: <20101214000154.06ec5153@stein>
References: <1290996593-32416-1-git-send-email-maximlevitsky@gmail.com>
	<1291779177.32420.8.camel@maxim-laptop>
	<20101208040559.20639.qmail@stuge.se>
	<1291809485.5421.0.camel@maxim-laptop>
	<20101212180916.71a57a71@stein>
	<1292195134.3136.296.camel@localhost>
	<20101213014602.6bc2727b@stein>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	linux1394-devel@lists.sourceforge.net, Peter Stuge <peter@stuge.se>
To: Maxim Levitsky <maximlevitsky@gmail.com>
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20101213014602.6bc2727b@stein>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Maxim Levitsky <maximlevitsky@gmail.com>

To make userland, e.g. NetworkManager work with firewire, we need to
detect whether cable is plugged or not.  Simple and correct way of doing
that is just counting number of peers.  No peers - no link and vice
versa.

(Stefan R.:  Combined peer_count inc/dec with tests, added link-down
recognition in fwnet_open, added include.)

Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
---
Update 3: added fwnet_open (ifup) hunk

 drivers/firewire/net.c |   29 +++++++++++++++++++++++++----
 1 file changed, 25 insertions(+), 4 deletions(-)

Index: b/drivers/firewire/net.c
===================================================================
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -9,6 +9,7 @@
 #include <linux/bug.h>
 #include <linux/delay.h>
 #include <linux/device.h>
+#include <linux/ethtool.h>
 #include <linux/firewire.h>
 #include <linux/firewire-constants.h>
 #include <linux/highmem.h>
@@ -179,6 +180,7 @@ struct fwnet_device {
 	/* Number of tx datagrams that have been queued but not yet acked */
 	int queued_datagrams;
 
+	int peer_count;
 	struct list_head peer_list;
 	struct fw_card *card;
 	struct net_device *netdev;
@@ -1234,6 +1236,13 @@ static int fwnet_open(struct net_device 
 	}
 	netif_start_queue(net);
 
+	mutex_lock(&fwnet_device_mutex);
+	if (dev->peer_count > 1)
+		netif_carrier_on(net);
+	else
+		netif_carrier_off(net);
+	mutex_unlock(&fwnet_device_mutex);
+
 	return 0;
 }
 
@@ -1412,6 +1421,10 @@ static const struct net_device_ops fwnet
 	.ndo_change_mtu = fwnet_change_mtu,
 };
 
+static const struct ethtool_ops fwnet_ethtool_ops = {
+	.get_link	= ethtool_op_get_link,
+};
+
 static void fwnet_init_dev(struct net_device *net)
 {
 	net->header_ops		= &fwnet_header_ops;
@@ -1423,6 +1436,7 @@ static void fwnet_init_dev(struct net_de
 	net->hard_header_len	= FWNET_HLEN;
 	net->type		= ARPHRD_IEEE1394;
 	net->tx_queue_len	= FWNET_TX_QUEUE_LEN;
+	net->ethtool_ops	= &fwnet_ethtool_ops;
 }
 
 /* caller must hold fwnet_device_mutex */
@@ -1465,6 +1479,10 @@ static int fwnet_add_peer(struct fwnet_d
 	list_add_tail(&peer->peer_link, &dev->peer_list);
 	spin_unlock_irq(&dev->lock);
 
+	/* serialized by fwnet_device_mutex */
+	if (++dev->peer_count > 1)
+		netif_carrier_on(dev->netdev);
+
 	return 0;
 }
 
@@ -1543,13 +1561,16 @@ static int fwnet_probe(struct device *_d
 	return ret;
 }
 
-static void fwnet_remove_peer(struct fwnet_peer *peer)
+static void fwnet_remove_peer(struct fwnet_peer *peer, struct fwnet_device *dev)
 {
 	struct fwnet_partial_datagram *pd, *pd_next;
 
-	spin_lock_irq(&peer->dev->lock);
+	if (--dev->peer_count == 1)
+		netif_carrier_off(dev->netdev);
+
+	spin_lock_irq(&dev->lock);
 	list_del(&peer->peer_link);
-	spin_unlock_irq(&peer->dev->lock);
+	spin_unlock_irq(&dev->lock);
 
 	list_for_each_entry_safe(pd, pd_next, &peer->pd_list, pd_link)
 		fwnet_pd_delete(pd);
@@ -1566,7 +1587,7 @@ static int fwnet_remove(struct device *_
 
 	mutex_lock(&fwnet_device_mutex);
 
-	fwnet_remove_peer(peer);
+	fwnet_remove_peer(peer, dev);
 
 	if (list_empty(&dev->peer_list)) {
 		net = dev->netdev;


-- 
Stefan Richter
-=====-==-=- ==-- -==-=
http://arcgraph.de/sr/

------------------------------------------------------------------------------
Lotusphere 2011
Register now for Lotusphere 2011 and learn how
to connect the dots, take your collaborative environment
to the next level, and enter the era of Social Business.
http://p.sf.net/sfu/lotusphere-d2d
