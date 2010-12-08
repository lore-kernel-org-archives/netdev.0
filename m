From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Re: [PATCH 0/5 V2] Firewire networking assorted fixes
Date: Wed, 08 Dec 2010 05:32:57 +0200
Message-ID: <1291779177.32420.8.camel@maxim-laptop>
References: <1290996593-32416-1-git-send-email-maximlevitsky@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-ROtFg9W/HFG66skVfIWX"
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>, netdev@vger.kernel.org
To: linux1394-devel <linux1394-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f45.google.com ([209.85.214.45]:58258 "EHLO
	mail-bw0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754369Ab0LHDdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Dec 2010 22:33:06 -0500
Received: by bwz16 with SMTP id 16so858480bwz.4
        for <netdev@vger.kernel.org>; Tue, 07 Dec 2010 19:33:04 -0800 (PST)
In-Reply-To: <1290996593-32416-1-git-send-email-maximlevitsky@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ROtFg9W/HFG66skVfIWX
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

On Mon, 2010-11-29 at 04:09 +0200, Maxim Levitsky wrote:
> Hi,
> 
> This is updated version of the patches.
> I updated the changelogs, addressed comments on patch #2
> 
> Best regards,
> 	Maxim Levitsky
> 

Today I have achieved the ultimate goal,
full support of firewire networking via NetworkManager.

Currently it is patched with few hacks but much less that I expected.

I also had to patch dhclient as it unfortunately sends raw packets
together with hardware header (ethernet of course...)

I will soon clean up these hacks to turn them into patches and send to
developers.

The kernel side needs only the attached patch.
It adds the link state detection to firewire-net

Just for fun, this is screenshot that proves that NM works:
http://img210.imageshack.us/img210/6019/screenshotdjk.png

Of course, I still need to clean up the patches to NM and dhclient, so
more correctly I am not fully done yet.

Best regards,
	Maxim Levitsky

--=-ROtFg9W/HFG66skVfIWX
Content-Disposition: attachment; filename="0001-firewire-net-add-carrier-detection.patch"
Content-Type: text/x-patch; name="0001-firewire-net-add-carrier-detection.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

>From d42274653bc06583871ec3230f8308236aff92c2 Mon Sep 17 00:00:00 2001
From: Maxim Levitsky <maximlevitsky@gmail.com>
Date: Wed, 8 Dec 2010 04:22:57 +0200
Subject: [PATCH] firewire: net: add carrier detection

To make userland, eg NM work with firewire
we need to be able if cable is plugged or not.

Simple and correct way of doing that is just couning number
of peers.

No peers - no link and vise versa.

Best regards,
	Maxim Levitsky
---
 drivers/firewire/net.c |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index ac563d6..67bad9c 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -178,6 +178,7 @@ struct fwnet_device {
 
 	/* Number of tx datagrams that have been queued but not yet acked */
 	int queued_datagrams;
+	int peer_count;
 
 	struct list_head peer_list;
 	struct fw_card *card;
@@ -1408,6 +1409,10 @@ static int fwnet_change_mtu(struct net_device *net, int new_mtu)
 	return 0;
 }
 
+static const struct ethtool_ops fwnet_ethtool_ops = {
+	.get_link	= ethtool_op_get_link,
+};
+
 static const struct net_device_ops fwnet_netdev_ops = {
 	.ndo_open       = fwnet_open,
 	.ndo_stop	= fwnet_stop,
@@ -1426,6 +1431,8 @@ static void fwnet_init_dev(struct net_device *net)
 	net->hard_header_len	= FWNET_HLEN;
 	net->type		= ARPHRD_IEEE1394;
 	net->tx_queue_len	= FWNET_TX_QUEUE_LEN;
+	net->ethtool_ops	= &fwnet_ethtool_ops;
+
 }
 
 /* caller must hold fwnet_device_mutex */
@@ -1467,6 +1474,7 @@ static int fwnet_add_peer(struct fwnet_device *dev,
 
 	spin_lock_irq(&dev->lock);
 	list_add_tail(&peer->peer_link, &dev->peer_list);
+	dev->peer_count++;
 	spin_unlock_irq(&dev->lock);
 
 	return 0;
@@ -1538,6 +1546,9 @@ static int fwnet_probe(struct device *_dev)
 		unregister_netdev(net);
 		list_del(&dev->dev_link);
 	}
+
+	if (dev->peer_count > 1)
+		netif_carrier_on(net);
  out:
 	if (ret && allocated_netdev)
 		free_netdev(net);
@@ -1553,6 +1564,7 @@ static void fwnet_remove_peer(struct fwnet_peer *peer)
 
 	spin_lock_irq(&peer->dev->lock);
 	list_del(&peer->peer_link);
+	peer->dev->peer_count--;
 	spin_unlock_irq(&peer->dev->lock);
 
 	list_for_each_entry_safe(pd, pd_next, &peer->pd_list, pd_link)
@@ -1575,6 +1587,11 @@ static int fwnet_remove(struct device *_dev)
 
 	fwnet_remove_peer(peer);
 
+	/* If we serve just one node, that means we lost link
+		with outer world */
+	if (dev->peer_count == 1)
+		netif_carrier_off(dev->netdev);
+
 	if (list_empty(&dev->peer_list)) {
 		net = dev->netdev;
 		unregister_netdev(net);
-- 
1.7.1


--=-ROtFg9W/HFG66skVfIWX--

