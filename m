From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC net-next (TAKE 3) 1/6] firewire net: Ignore spd and max_payload
 advertised by ARP.
Date: Mon, 11 Feb 2013 02:46:47 +0900
Message-ID: <5117DD07.6090307@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: stephan.gatzka@gmail.com, davem@davemloft.net,
	stefanr@s5r6.in-berlin.de, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:38849 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754742Ab3BJRqs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 12:46:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stefan Richter <stefanr@s5r6.in-berlin.de> says:
| As far as I can tell, it would be best to ignore max_rec and sspd from ARP
| and NDP but keep using the respective information from firewire-core
| instead (handed over by fwnet_probe()).
|
| Why?  As I noted earlier, RFC 2734:1999 and RFC 3146:2001 were apparently
| written with a too simplistic notion of IEEE 1394 bus topology, resulting
| in max_rec and sspd in ARP-1394 and NDP-1394 to be useless, IMO.
|
| Consider a bus like this:
|
|     A ---- B ==== C
|
| A, B, C are all IP-over-1394 capable nodes.  ---- is an S400 cable hop,
| and ==== is an S800 cable hop.
|
| In case of unicasts or multicasts in which node A is involved as
| transmitter or receiver, as well as in case of broadcasts, the speeds
| S100, S200, S400 work and speed S400 is optimal.
|
| In case of anything else, IOW in case of unicasts or multicasts in which
| only nodes B and C are involved, the speeds S100, S200, S400, S800 work
| and speed S800 is optimal.
|
| Clearly, node A should indicate sspd = S400 in its ARP or NDP packets.
| But which sspd should nodes B and C set there?  Maybe they set S400, which
| would work but would waste half of the available bandwidth in the second
| case.  Or maybe they set S800, which is OK in the second case but would
| prohibit any communication with node A if blindly taken for correct.
|
| On the other hand, firewire-core *always* gives us the correct and optimum
| peer-to-peer speed and asynchronous packet payload, no matter how simple
| or complex the bus topology is and no matter in which temporal order nodes
| join the bus and are discovered.

CC: Stefan Richter <stefanr@s5r6.in-berlin.de>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/firewire/net.c |   16 ----------------
 1 file changed, 16 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index 2b27bff..4382c20 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -539,8 +539,6 @@ static int fwnet_finish_incoming_packet(struct net_device *net,
 		unsigned char *arp_ptr;
 		u64 fifo_addr;
 		u64 peer_guid;
-		unsigned sspd;
-		u16 max_payload;
 		struct fwnet_peer *peer;
 		unsigned long flags;
 
@@ -551,24 +549,10 @@ static int fwnet_finish_incoming_packet(struct net_device *net,
 		fifo_addr = (u64)get_unaligned_be16(&arp1394->fifo_hi) << 32
 				| get_unaligned_be32(&arp1394->fifo_lo);
 
-		sspd = arp1394->sspd;
-		/* Sanity check.  OS X 10.3 PPC reportedly sends 131. */
-		if (sspd > SCODE_3200) {
-			dev_notice(&net->dev, "sspd %x out of range\n", sspd);
-			sspd = SCODE_3200;
-		}
-		max_payload = fwnet_max_payload(arp1394->max_rec, sspd);
-
 		spin_lock_irqsave(&dev->lock, flags);
 		peer = fwnet_peer_find_by_guid(dev, peer_guid);
 		if (peer) {
 			peer->fifo = fifo_addr;
-
-			if (peer->speed > sspd)
-				peer->speed = sspd;
-			if (peer->max_payload > max_payload)
-				peer->max_payload = max_payload;
-
 			peer->ip = arp1394->sip;
 		}
 		spin_unlock_irqrestore(&dev->lock, flags);
-- 
1.7.9.5
