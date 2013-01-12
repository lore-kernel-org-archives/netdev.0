From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC PATCH 4/6] firewire net: Export peerinfo handlers.
Date: Sat, 12 Jan 2013 23:21:30 +0900
Message-ID: <50F1716A.90401@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	yoshfuji@linux-ipv6.org
To: Stephan Gatzka <stephan.gatzka@gmail.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:36686 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753569Ab3ALOVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 09:21:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extract peerinfo related code into separate functions and export them.

CC: Stephan Gatzka <stephan.gatzka@gmail.com>
CC: Stefan Richter <stefanr@s5r6.in-berlin.de>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/firewire/net.c |  106 ++++++++++++++++++++++++++++--------------------
 include/net/firewire.h |   10 +++++
 2 files changed, 73 insertions(+), 43 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index bd2d0de..66c4f1c 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -506,6 +506,50 @@ static unsigned fwnet_max_payload(unsigned max_rec, unsigned speed)
 	return (1 << (max_rec + 1)) - RFC2374_FRAG_HDR_SIZE;
 }
 
+struct fwnet_peer *fwnet_update_peerinfo(struct net_device *net,
+					 __be64 *s_uniq_id,
+					 const struct fwnet_peerinfo *info)
+{
+	struct fwnet_device *dev = netdev_priv(net);
+	u64 peer_guid;
+	u64 fifo_addr;
+	unsigned sspd;
+	u16 max_payload;
+	unsigned long flags;
+	struct fwnet_peer *peer;
+
+	peer_guid = get_unaligned_be64(s_uniq_id);
+	fifo_addr = (u64)get_unaligned_be16(&info->fifo_hi) << 32
+			| get_unaligned_be32(&info->fifo_lo);
+
+	sspd = info->sspd;
+	/* Sanity check.  OS X 10.3 PPC reportedly sends 131. */
+	if (sspd > SCODE_3200) {
+		dev_notice(&net->dev, "sspd %x out of range\n", sspd);
+		sspd = SCODE_3200;
+	}
+	max_payload = fwnet_max_payload(info->max_rec, sspd);
+
+	spin_lock_irqsave(&dev->lock, flags);
+	peer = fwnet_peer_find_by_guid(dev, peer_guid);
+	if (peer) {
+		peer->fifo = fifo_addr;
+
+		if (peer->speed > sspd)
+			peer->speed = sspd;
+		if (peer->max_payload > max_payload)
+			peer->max_payload = max_payload;
+	}
+	spin_unlock_irqrestore(&dev->lock, flags);
+
+	if (!peer)
+		dev_notice(&net->dev,
+			   "no peer for ARP packet from %016llx\n",
+			   (unsigned long long)peer_guid);
+
+	return peer;
+}
+EXPORT_SYMBOL(fwnet_update_peerinfo);
 
 static int fwnet_finish_incoming_packet(struct net_device *net,
 					struct sk_buff *skb, u16 source_node_id,
@@ -536,49 +580,16 @@ static int fwnet_finish_incoming_packet(struct net_device *net,
 		struct rfc2734_arp *arp1394;
 		struct arphdr *arp;
 		unsigned char *arp_ptr;
-		u64 fifo_addr;
-		u64 peer_guid;
-		unsigned sspd;
-		u16 max_payload;
 		struct fwnet_peer *peer;
-		unsigned long flags;
 
 		arp1394   = (struct rfc2734_arp *)skb->data;
 		arp       = (struct arphdr *)skb->data;
 		arp_ptr   = (unsigned char *)(arp + 1);
 
-		peer_guid = get_unaligned_be64(&arp1394->s_uniq_id);
-		fifo_addr = (u64)get_unaligned_be16(&arp1394->info.fifo_hi) << 32
-				| get_unaligned_be32(&arp1394->info.fifo_lo);
-
-		sspd = arp1394->info.sspd;
-		/* Sanity check.  OS X 10.3 PPC reportedly sends 131. */
-		if (sspd > SCODE_3200) {
-			dev_notice(&net->dev, "sspd %x out of range\n", sspd);
-			sspd = SCODE_3200;
-		}
-		max_payload = fwnet_max_payload(arp1394->info.max_rec, sspd);
-
-		spin_lock_irqsave(&dev->lock, flags);
-		peer = fwnet_peer_find_by_guid(dev, peer_guid);
-		if (peer) {
-			peer->fifo = fifo_addr;
-
-			if (peer->speed > sspd)
-				peer->speed = sspd;
-			if (peer->max_payload > max_payload)
-				peer->max_payload = max_payload;
-
-			peer->ip = arp1394->sip;
-		}
-		spin_unlock_irqrestore(&dev->lock, flags);
-
-		if (!peer) {
-			dev_notice(&net->dev,
-				   "no peer for ARP packet from %016llx\n",
-				   (unsigned long long)peer_guid);
+		peer = fwnet_update_peerinfo(net, &arp1394->s_uniq_id, &arp1394->info);
+		if (!peer)
 			goto no_peer;
-		}
+		peer->ip = arp1394->sip;
 
 		/*
 		 * Now that we're done with the 1394 specific stuff, we'll
@@ -1264,6 +1275,19 @@ static int fwnet_stop(struct net_device *net)
 	return 0;
 }
 
+void fwnet_fill_peerinfo(const struct net_device *net, const __be64 *s_uniq_id,
+			 struct fwnet_peerinfo *info)
+{
+	struct fwnet_device *dev = netdev_priv(net);
+
+	info->max_rec	= dev->card->max_receive;
+	info->sspd	= dev->card->link_speed;
+
+	put_unaligned_be16(dev->local_fifo >> 32, &info->fifo_hi);
+	put_unaligned_be32(dev->local_fifo & 0xffffffff, &info->fifo_lo);
+}
+EXPORT_SYMBOL(fwnet_fill_peerinfo);
+
 static netdev_tx_t fwnet_tx(struct sk_buff *skb, struct net_device *net)
 {
 	struct fwnet_header hdr_buf;
@@ -1347,14 +1371,10 @@ static netdev_tx_t fwnet_tx(struct sk_buff *skb, struct net_device *net)
 
 		ipaddr = get_unaligned((__be32 *)(arp_ptr + FWNET_ALEN));
 
-		arp1394->hw_addr_len    = RFC2734_HW_ADDR_LEN;
-		arp1394->info.max_rec	= dev->card->max_receive;
-		arp1394->info.sspd	= dev->card->link_speed;
+		arp1394->hw_addr_len	= RFC2734_HW_ADDR_LEN;
+
+		fwnet_fill_peerinfo(net, NULL, &arp1394->info);
 
-		put_unaligned_be16(dev->local_fifo >> 32,
-				   &arp1394->info.fifo_hi);
-		put_unaligned_be32(dev->local_fifo & 0xffffffff,
-				   &arp1394->info.fifo_lo);
 		put_unaligned(ipaddr, &arp1394->sip);
 	}
 
diff --git a/include/net/firewire.h b/include/net/firewire.h
index 5e12b52..6f746d1 100644
--- a/include/net/firewire.h
+++ b/include/net/firewire.h
@@ -8,4 +8,14 @@ struct fwnet_peerinfo {
 	__be32 fifo_lo;		/* lo 32bits of sender's FIFO addr	*/
 } __packed;
 
+struct fwnet_peer;
+
+extern struct fwnet_peer *fwnet_update_peerinfo(struct net_device *net,
+						__be64 *s_uniq_id,
+						const struct fwnet_peerinfo *info);
+
+extern void fwnet_fill_peerinfo(const struct net_device *net,
+				const __be64 *s_uniq_id,
+				struct fwnet_peerinfo *info);
+
 #endif
-- 
1.7.9.5
