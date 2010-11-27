From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Re: [Q] How to invalidate ARP cache for a network device from
 within kernel
Date: Sat, 27 Nov 2010 03:25:43 +0200
Message-ID: <1290821143.4145.3.camel@maxim-laptop>
References: <1290793099.3716.21.camel@maxim-laptop>
	 <20101127021833.328e8942@stein>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-z+IEiSfnwt9ggXgbEI15"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux1394-devel <linux1394-devel@lists.sourceforge.net>
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:48140 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753366Ab0K0BZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Nov 2010 20:25:49 -0500
Received: by bwz15 with SMTP id 15so2299865bwz.19
        for <netdev@vger.kernel.org>; Fri, 26 Nov 2010 17:25:48 -0800 (PST)
In-Reply-To: <20101127021833.328e8942@stein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-z+IEiSfnwt9ggXgbEI15
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

On Sat, 2010-11-27 at 02:18 +0100, Stefan Richter wrote:
> On Nov 26 Maxim Levitsky wrote:
> > However as soon as bus reset happens, the upper layer ARP cache isn't
> > invalidated, thus all attempts to send packets to remote node now fail,
> > because the additional information (node id and bus address) about
> > remote node is now invalid, but ARP core doesn't send ARP requests
> > because it has the response in the cache.
> 
> When is this a problem?  With nodes which stay on the bus (i.e. are
> present before and after the bus reset)?  Or with nodes which go away
> and come back much later (but before the old ARP cache entry was cleaned
> out)?
Its about later.
A node that disconnects and connects after 5 seconds for example or 20
seconds.
ARP timeout is I think 30 seconds or even more.

Btw I already solved that problem.
Patches attached.

With this and all great patches from you and Clemens, the firewire
networking strongly resembles ethernet in terms of speed and
reliability.
(When I resume from ram my desktop, connection restores after less that
5 seconds).

On laptop I still see few issues on s2ram cycle, I am tackling them now.

Best regards,
	Maxim Levitsky

--=-z+IEiSfnwt9ggXgbEI15
Content-Disposition: attachment; filename="0001-firewire-net-restart-ISO-channel-on-bus-resets.patch"
Content-Type: text/x-patch; name="0001-firewire-net-restart-ISO-channel-on-bus-resets.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

>From e77f71cfed34d35bcec48d7cbcda88d0626c2d09 Mon Sep 17 00:00:00 2001
From: Maxim Levitsky <maximlevitsky@gmail.com>
Date: Sun, 14 Nov 2010 23:24:46 +0200
Subject: [PATCH 1/3] firewire: net: restart ISO channel on bus resets

---
 drivers/firewire/net.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index 1a467a9..007969c 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -1593,10 +1593,15 @@ static void fwnet_update(struct fw_unit *unit)
 {
 	struct fw_device *device = fw_parent_device(unit);
 	struct fwnet_peer *peer = dev_get_drvdata(&unit->device);
+	struct fwnet_device *dev = peer->dev;
 	int generation;
 
 	generation = device->generation;
 
+	fw_iso_context_stop(dev->broadcast_rcv_context);
+	fw_iso_context_start(dev->broadcast_rcv_context, -1, 0,
+			FW_ISO_CONTEXT_MATCH_ALL_TAGS);
+
 	spin_lock_irq(&peer->dev->lock);
 	peer->node_id    = device->node_id;
 	peer->generation = generation;
-- 
1.7.1


--=-z+IEiSfnwt9ggXgbEI15
Content-Disposition: attachment; filename="0002-NET-ARP-allow-to-invalidate-specific-ARP-entries.patch"
Content-Type: text/x-patch; name="0002-NET-ARP-allow-to-invalidate-specific-ARP-entries.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

>From 70bab78da7677767f476290e94ea8fb5903e2e2a Mon Sep 17 00:00:00 2001
From: Maxim Levitsky <maximlevitsky@gmail.com>
Date: Sat, 27 Nov 2010 00:50:45 +0200
Subject: [PATCH 2/3] NET: ARP: allow to invalidate specific ARP entries

IPv4 over firewire needs to be able to remove ARP entries
from cache that belong to nodes that are removed, because
IPv4 over firewire uses ARP packets for private information
about nodes.

This information becames invalid on node removal, thus
as soon as it is connected again, ARP packet should be sent
to it which is not done due to valid cache entry.

CC: netdev@vger.kernel.org
Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>
---
 include/net/arp.h |    1 +
 net/ipv4/arp.c    |   29 ++++++++++++++++++-----------
 2 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/include/net/arp.h b/include/net/arp.h
index f4cf6ce..91f0568 100644
--- a/include/net/arp.h
+++ b/include/net/arp.h
@@ -25,5 +25,6 @@ extern struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
 				  const unsigned char *src_hw,
 				  const unsigned char *target_hw);
 extern void arp_xmit(struct sk_buff *skb);
+int arp_invalidate(struct net_device *dev, __be32 ip);
 
 #endif	/* _ARP_H */
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index d8e540c..35b1272 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1142,6 +1142,23 @@ static int arp_req_get(struct arpreq *r, struct net_device *dev)
 	return err;
 }
 
+int arp_invalidate(struct net_device *dev, __be32 ip)
+{
+	int err = -ENXIO;
+	struct neighbour *neigh = neigh_lookup(&arp_tbl, &ip, dev);
+
+	if (neigh) {
+		if (neigh->nud_state & ~NUD_NOARP)
+			err = neigh_update(neigh, NULL, NUD_FAILED,
+					   NEIGH_UPDATE_F_OVERRIDE|
+					   NEIGH_UPDATE_F_ADMIN);
+		neigh_release(neigh);
+	}
+
+	return err;
+}
+EXPORT_SYMBOL(arp_invalidate);
+
 static int arp_req_delete_public(struct net *net, struct arpreq *r,
 		struct net_device *dev)
 {
@@ -1162,7 +1179,6 @@ static int arp_req_delete(struct net *net, struct arpreq *r,
 {
 	int err;
 	__be32 ip;
-	struct neighbour *neigh;
 
 	if (r->arp_flags & ATF_PUBL)
 		return arp_req_delete_public(net, r, dev);
@@ -1180,16 +1196,7 @@ static int arp_req_delete(struct net *net, struct arpreq *r,
 		if (!dev)
 			return -EINVAL;
 	}
-	err = -ENXIO;
-	neigh = neigh_lookup(&arp_tbl, &ip, dev);
-	if (neigh) {
-		if (neigh->nud_state & ~NUD_NOARP)
-			err = neigh_update(neigh, NULL, NUD_FAILED,
-					   NEIGH_UPDATE_F_OVERRIDE|
-					   NEIGH_UPDATE_F_ADMIN);
-		neigh_release(neigh);
-	}
-	return err;
+	return arp_invalidate(dev, ip);
 }
 
 /*
-- 
1.7.1


--=-z+IEiSfnwt9ggXgbEI15
Content-Disposition: attachment; filename*0=0003-firewire-net-invalidate-ARP-entries-for-removed-node.pat; filename*1=ch
Content-Type: text/x-patch; name="0003-firewire-net-invalidate-ARP-entries-for-removed-node.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

>From f284b2644694797f42df9df94cc6ccbaa17155ca Mon Sep 17 00:00:00 2001
From: Maxim Levitsky <maximlevitsky@gmail.com>
Date: Sat, 27 Nov 2010 00:35:04 +0200
Subject: [PATCH 3/3] firewire: net: invalidate ARP entries for removed nodes.

This allows to be able to connect to nodes that disappered
from the bus and after some time appeared again.

Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>
---
 drivers/firewire/net.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index 007969c..bb7939a 100644
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


--=-z+IEiSfnwt9ggXgbEI15--

