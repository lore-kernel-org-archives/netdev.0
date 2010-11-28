From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: [PATCH 4/5] firewire: net: invalidate ARP entries for removed nodes.
Date: Sun, 28 Nov 2010 03:15:35 +0200
Message-ID: <1290906936-14472-5-git-send-email-maximlevitsky@gmail.com>
References: <1290906936-14472-1-git-send-email-maximlevitsky@gmail.com>
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>, netdev@vger.kernel.org,
	Maxim Levitsky <maximlevitsky@gmail.com>
To: linux1394-devel <linux1394-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:55574 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753510Ab0K1BPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Nov 2010 20:15:53 -0500
Received: by mail-bw0-f46.google.com with SMTP id 15so2883308bwz.19
        for <netdev@vger.kernel.org>; Sat, 27 Nov 2010 17:15:52 -0800 (PST)
In-Reply-To: <1290906936-14472-1-git-send-email-maximlevitsky@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows to be able to connect to nodes that disappered
from the bus and after some time appeared again.

Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>
---
 drivers/firewire/net.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index 1a467a9..d422519 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -189,6 +189,7 @@ struct fwnet_peer {
 	struct fwnet_device *dev;
 	u64 guid;
 	u64 fifo;
+	__be32 ip;
 
 	/* guarded by dev->lock */
 	struct list_head pd_list; /* received partial datagrams */
@@ -568,6 +569,8 @@ static int fwnet_finish_incoming_packet(struct net_device *net,
 				peer->speed = sspd;
 			if (peer->max_payload > max_payload)
 				peer->max_payload = max_payload;
+
+			peer->ip = arp1394->sip;
 		}
 		spin_unlock_irqrestore(&dev->lock, flags);
 
@@ -1443,6 +1446,7 @@ static int fwnet_add_peer(struct fwnet_device *dev,
 	peer->dev = dev;
 	peer->guid = (u64)device->config_rom[3] << 32 | device->config_rom[4];
 	peer->fifo = FWNET_NO_FIFO_ADDR;
+	peer->ip = 0;
 	INIT_LIST_HEAD(&peer->pd_list);
 	peer->pdg_size = 0;
 	peer->datagram_label = 0;
@@ -1558,6 +1562,9 @@ static int fwnet_remove(struct device *_dev)
 
 	mutex_lock(&fwnet_device_mutex);
 
+	if (dev->netdev && peer->ip)
+		arp_invalidate(dev->netdev, peer->ip);
+
 	fwnet_remove_peer(peer);
 
 	if (list_empty(&dev->peer_list)) {
-- 
1.7.1

