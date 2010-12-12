From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH update] firewire: net: add carrier detection
Date: Sun, 12 Dec 2010 18:09:16 +0100
Message-ID: <20101212180916.71a57a71@stein>
References: <1290996593-32416-1-git-send-email-maximlevitsky@gmail.com>
	<1291779177.32420.8.camel@maxim-laptop>
	<20101208040559.20639.qmail@stuge.se>
	<1291809485.5421.0.camel@maxim-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Peter Stuge <peter@stuge.se>,
	<linux1394-devel@lists.sourceforge.net>, netdev@vger.kernel.org
To: Maxim Levitsky <maximlevitsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:56860 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753924Ab0LLRJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Dec 2010 12:09:36 -0500
In-Reply-To: <1291809485.5421.0.camel@maxim-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maxim Levitsky <maximlevitsky@gmail.com>

To make userland, e.g. NetworkManager work with firewire, we need to
detect whether cable is plugged or not.  Simple and correct way of doing
that is just counting number of peers.  No peers - no link and vice
versa.

Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
---
Update:  Moved netif_carrier_on/off calls into lock-protected sections.

 drivers/firewire/net.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

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
@@ -1405,6 +1406,10 @@ static int fwnet_change_mtu(struct net_d
 	return 0;
 }
 
+static const struct ethtool_ops fwnet_ethtool_ops = {
+	.get_link	= ethtool_op_get_link,
+};
+
 static const struct net_device_ops fwnet_netdev_ops = {
 	.ndo_open       = fwnet_open,
 	.ndo_stop	= fwnet_stop,
@@ -1423,6 +1428,7 @@ static void fwnet_init_dev(struct net_de
 	net->hard_header_len	= FWNET_HLEN;
 	net->type		= ARPHRD_IEEE1394;
 	net->tx_queue_len	= FWNET_TX_QUEUE_LEN;
+	net->ethtool_ops	= &fwnet_ethtool_ops;
 }
 
 /* caller must hold fwnet_device_mutex */
@@ -1463,6 +1469,8 @@ static int fwnet_add_peer(struct fwnet_d
 
 	spin_lock_irq(&dev->lock);
 	list_add_tail(&peer->peer_link, &dev->peer_list);
+	if (++dev->peer_count > 1)
+		netif_carrier_on(dev->netdev);
 	spin_unlock_irq(&dev->lock);
 
 	return 0;
@@ -1549,6 +1557,8 @@ static void fwnet_remove_peer(struct fwn
 
 	spin_lock_irq(&peer->dev->lock);
 	list_del(&peer->peer_link);
+	if (--peer->dev->peer_count == 1)
+		netif_carrier_off(peer->dev->netdev);
 	spin_unlock_irq(&peer->dev->lock);
 
 	list_for_each_entry_safe(pd, pd_next, &peer->pd_list, pd_link)


-- 
Stefan Richter
-=====-==-=- ==-- -==--
http://arcgraph.de/sr/
