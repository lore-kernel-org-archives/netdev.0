From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC PATCH 3/6] firewire net: Export fwnet_peerinfo structure for
 ieee1394-specific peer information in ARP/NDP.
Date: Sat, 12 Jan 2013 23:21:22 +0900
Message-ID: <50F17162.4060005@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	yoshfuji@linux-ipv6.org
To: Stephan Gatzka <stephan.gatzka@gmail.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:36681 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753005Ab3ALOVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 09:21:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peer information consists of max_rec, spd and unicast_FIFO and
the wire format is shared between IPv4 (RFC2734) and IPv6 (RFC3146).

CC: Stephan Gatzka <stephan.gatzka@gmail.com>
CC: Stefan Richter <stefanr@s5r6.in-berlin.de>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/firewire/net.c |   24 ++++++++++++------------
 include/net/firewire.h |   11 +++++++++++
 2 files changed, 23 insertions(+), 12 deletions(-)
 create mode 100644 include/net/firewire.h

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index e7a711f5..bd2d0de 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -28,6 +28,7 @@
 
 #include <asm/unaligned.h>
 #include <net/arp.h>
+#include <net/firewire.h>
 
 /* rx limits */
 #define FWNET_MAX_FRAGMENTS		30 /* arbitrary, > TX queue depth */
@@ -68,10 +69,8 @@ struct rfc2734_arp {
 	/* Above is exactly the same format as struct arphdr */
 
 	__be64 s_uniq_id;	/* Sender's 64bit EUI			*/
-	u8 max_rec;		/* Sender's max packet size		*/
-	u8 sspd;		/* Sender's max speed			*/
-	__be16 fifo_hi;		/* hi 16bits of sender's FIFO addr	*/
-	__be32 fifo_lo;		/* lo 32bits of sender's FIFO addr	*/
+	struct fwnet_peerinfo info;
+
 	__be32 sip;		/* Sender's IP Address			*/
 	__be32 tip;		/* IP Address of requested hw addr	*/
 } __packed;
@@ -547,17 +546,18 @@ static int fwnet_finish_incoming_packet(struct net_device *net,
 		arp1394   = (struct rfc2734_arp *)skb->data;
 		arp       = (struct arphdr *)skb->data;
 		arp_ptr   = (unsigned char *)(arp + 1);
+
 		peer_guid = get_unaligned_be64(&arp1394->s_uniq_id);
-		fifo_addr = (u64)get_unaligned_be16(&arp1394->fifo_hi) << 32
-				| get_unaligned_be32(&arp1394->fifo_lo);
+		fifo_addr = (u64)get_unaligned_be16(&arp1394->info.fifo_hi) << 32
+				| get_unaligned_be32(&arp1394->info.fifo_lo);
 
-		sspd = arp1394->sspd;
+		sspd = arp1394->info.sspd;
 		/* Sanity check.  OS X 10.3 PPC reportedly sends 131. */
 		if (sspd > SCODE_3200) {
 			dev_notice(&net->dev, "sspd %x out of range\n", sspd);
 			sspd = SCODE_3200;
 		}
-		max_payload = fwnet_max_payload(arp1394->max_rec, sspd);
+		max_payload = fwnet_max_payload(arp1394->info.max_rec, sspd);
 
 		spin_lock_irqsave(&dev->lock, flags);
 		peer = fwnet_peer_find_by_guid(dev, peer_guid);
@@ -1348,13 +1348,13 @@ static netdev_tx_t fwnet_tx(struct sk_buff *skb, struct net_device *net)
 		ipaddr = get_unaligned((__be32 *)(arp_ptr + FWNET_ALEN));
 
 		arp1394->hw_addr_len    = RFC2734_HW_ADDR_LEN;
-		arp1394->max_rec        = dev->card->max_receive;
-		arp1394->sspd		= dev->card->link_speed;
+		arp1394->info.max_rec	= dev->card->max_receive;
+		arp1394->info.sspd	= dev->card->link_speed;
 
 		put_unaligned_be16(dev->local_fifo >> 32,
-				   &arp1394->fifo_hi);
+				   &arp1394->info.fifo_hi);
 		put_unaligned_be32(dev->local_fifo & 0xffffffff,
-				   &arp1394->fifo_lo);
+				   &arp1394->info.fifo_lo);
 		put_unaligned(ipaddr, &arp1394->sip);
 	}
 
diff --git a/include/net/firewire.h b/include/net/firewire.h
new file mode 100644
index 0000000..5e12b52
--- /dev/null
+++ b/include/net/firewire.h
@@ -0,0 +1,11 @@
+#ifndef _NET_FIREWIRE_H
+#define _NET_FIREWIRE_H
+
+struct fwnet_peerinfo {
+	u8 max_rec;		/* Sender's max packet size		*/
+	u8 sspd;		/* Sender's max speed			*/
+	__be16 fifo_hi;		/* hi 16bits of sender's FIFO addr	*/
+	__be32 fifo_lo;		/* lo 32bits of sender's FIFO addr	*/
+} __packed;
+
+#endif
-- 
1.7.9.5
