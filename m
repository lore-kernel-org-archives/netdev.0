From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH update 2] firewire: net: add carrier detection
Date: Mon, 13 Dec 2010 01:46:02 +0100
Message-ID: <20101213014602.6bc2727b@stein>
References: <1290996593-32416-1-git-send-email-maximlevitsky@gmail.com>
	<1291779177.32420.8.camel@maxim-laptop>
	<20101208040559.20639.qmail@stuge.se>
	<1291809485.5421.0.camel@maxim-laptop>
	<20101212180916.71a57a71@stein>
	<1292195134.3136.296.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	Peter Stuge <peter@stuge.se>
To: Ben Hutchings <bhutchings@solarflare.com>, Maxim Levitsky
	<maximlevitsky@gmail.com>
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1292195134.3136.296.camel@localhost>
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

(Stefan R.:  Drop ethtool_ops.get_link)

Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
---
Update 2:  Removed ethtool related hunks; dev->peer_count does not need
to be accessed within the spinlock as I first thought; reduced pointer
reference depth in fwnet_remove_peer.

Maxim, do you observe a remaining need for a get_link implementation?
I can't tell, I use rather minimal userland that doesn't care for link
status.

 drivers/firewire/net.c |   16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

Index: b/drivers/firewire/net.c
===================================================================
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -179,6 +179,7 @@ struct fwnet_device {
 	/* Number of tx datagrams that have been queued but not yet acked */
 	int queued_datagrams;
 
+	int peer_count;
 	struct list_head peer_list;
 	struct fw_card *card;
 	struct net_device *netdev;
@@ -1465,6 +1466,10 @@ static int fwnet_add_peer(struct fwnet_d
 	list_add_tail(&peer->peer_link, &dev->peer_list);
 	spin_unlock_irq(&dev->lock);
 
+	/* dev->peer_count acess is serialized by fwnet_device_mutex. */
+	if (++dev->peer_count > 1)
+		netif_carrier_on(dev->netdev);
+
 	return 0;
 }
 
@@ -1543,13 +1548,16 @@ static int fwnet_probe(struct device *_d
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
@@ -1566,7 +1574,7 @@ static int fwnet_remove(struct device *_
 
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
Oracle to DB2 Conversion Guide: Learn learn about native support for PL/SQL,
new data types, scalar functions, improved concurrency, built-in packages, 
OCI, SQL*Plus, data movement tools, best practices and more.
http://p.sf.net/sfu/oracle-sfdev2dev 
