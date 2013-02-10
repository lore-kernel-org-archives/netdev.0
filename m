From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [net-next (TAKE 2) 3/4] firewire net, ipv4 arp: Extend hardware address
 and remove driver-level packet inspection.
Date: Sun, 10 Feb 2013 18:02:27 +0900
Message-ID: <51176223.8090305@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: stephan.gatzka@gmail.com, davem@davemloft.net,
	stefanr@s5r6.in-berlin.de, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:54448 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754218Ab3BJJC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 04:02:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Inspection of upper layer protocol is considered harmful, especially
if it is about ARP or other stateful upper layer protocol; driver
cannot (and should not) have full state of them.

IPv4 over Firewire module used to inspect ARP (both in sending path
and in receiving path), and record peer's GUID, max packet size, max
speed and fifo address.  This patch removes such inspection by extending
our "hardware address" definition to include other information as well:
max packet size, max speed anf fifo.  By doing this, The neighbour
module in networking subsystem can cache them.

When a packet is being sent, the IP layer fills our virtual header with
the extended "hardware address", including GUID and fifo.  The driver
can look-up node-id (the real but rather volatile low-level address)
by GUID, and then the module can send the packet to the wire using
parameters provided in the extendedn hardware address.

This approach is realistic because IP over IEEE1394 (RFC2734) and IPv6
oveer IEEE1394 (RFC3146) share same "hardware address" format
in their address resolution protocols.

Here, extended "hardware address" is defined as follows:

union fwnet_hwaddr {
	u8 u[16];
	struct {
		__be64 uniq_id;		/* EUI-64			*/
		u8 max_rec;		/* max packet size		*/
		u8 sspd;		/* max speed			*/
		__be16 fifo_hi;		/* hi 16bits of FIFO addr	*/
		__be32 fifo_lo;		/* lo 32bits of FIFO addr	*/
	} __packed uc;
};

Note that Hardware address is declared as union, so that we can map full
IP address into this, when implementing MCAP (Multicast Cannel Allocation
Protocol) for IPv6, but IP and ARP subsystem do not need to known this
format in detail.

One difference between original ARP (RFC826) and 1394 ARP (RFC2734)
is that 1394 ARP Request/Reply do not contain the target hardware address
field (aka ar$tha).  This difference is handled in the ARP subsystem.

CC: Stephan Gatzka <stephan.gatzka@gmail.com>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/firewire/net.c |  215 ++++++++++++------------------------------------
 include/linux/if_arp.h |   12 ++-
 include/net/firewire.h |   25 ++++++
 net/ipv4/arp.c         |   18 ++--
 4 files changed, 100 insertions(+), 170 deletions(-)
 create mode 100644 include/net/firewire.h

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index a251379..281ef1b 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -28,6 +28,7 @@
 
 #include <asm/unaligned.h>
 #include <net/arp.h>
+#include <net/firewire.h>
 
 /* rx limits */
 #define FWNET_MAX_FRAGMENTS		30 /* arbitrary, > TX queue depth */
@@ -57,33 +58,6 @@
 #define RFC2374_HDR_LASTFRAG	2	/* last fragment	*/
 #define RFC2374_HDR_INTFRAG	3	/* interior fragment	*/
 
-#define RFC2734_HW_ADDR_LEN	16
-
-struct rfc2734_arp {
-	__be16 hw_type;		/* 0x0018	*/
-	__be16 proto_type;	/* 0x0806       */
-	u8 hw_addr_len;		/* 16		*/
-	u8 ip_addr_len;		/* 4		*/
-	__be16 opcode;		/* ARP Opcode	*/
-	/* Above is exactly the same format as struct arphdr */
-
-	__be64 s_uniq_id;	/* Sender's 64bit EUI			*/
-	u8 max_rec;		/* Sender's max packet size		*/
-	u8 sspd;		/* Sender's max speed			*/
-	__be16 fifo_hi;		/* hi 16bits of sender's FIFO addr	*/
-	__be32 fifo_lo;		/* lo 32bits of sender's FIFO addr	*/
-	__be32 sip;		/* Sender's IP Address			*/
-	__be32 tip;		/* IP Address of requested hw addr	*/
-} __packed;
-
-/* This header format is specific to this driver implementation. */
-#define FWNET_ALEN	8
-#define FWNET_HLEN	10
-struct fwnet_header {
-	u8 h_dest[FWNET_ALEN];	/* destination address */
-	__be16 h_proto;		/* packet type ID field */
-} __packed;
-
 static bool fwnet_hwaddr_is_multicast(u8 *ha)
 {
 	return !!(*ha & 1);
@@ -196,18 +170,14 @@ struct fwnet_peer {
 	struct list_head peer_link;
 	struct fwnet_device *dev;
 	u64 guid;
-	u64 fifo;
-	__be32 ip;
 
 	/* guarded by dev->lock */
 	struct list_head pd_list; /* received partial datagrams */
 	unsigned pdg_size;        /* pd_list size */
 
 	u16 datagram_label;       /* outgoing datagram label */
-	u16 max_payload;          /* includes RFC2374_FRAG_HDR_SIZE overhead */
 	int node_id;
 	int generation;
-	unsigned speed;
 };
 
 /* This is our task struct. It's used for the packet complete callback.  */
@@ -227,6 +197,28 @@ struct fwnet_packet_task {
 };
 
 /*
+ * Get fifo address embedded in hwaddr
+ */
+static __u64 fwnet_hwaddr_fifo(union fwnet_hwaddr *ha)
+{
+	return (u64)get_unaligned_be16(&ha->uc.fifo_hi) << 32
+	       | get_unaligned_be32(&ha->uc.fifo_lo);
+}
+
+static __u8 fwnet_fixup_speed(__u8 sspd)
+{
+	if (sspd > SCODE_3200)
+		sspd = SCODE_3200;
+	return sspd;
+}
+
+static unsigned fwnet_max_payload(unsigned max_rec, unsigned speed);
+static __u16 fwnet_hwaddr_maxpayload(union fwnet_hwaddr *ha)
+{
+	return fwnet_max_payload(ha->uc.max_rec, ha->uc.sspd);
+}
+
+/*
  * saddr == NULL means use device source address.
  * daddr == NULL means leave destination address (eg unresolved arp).
  */
@@ -518,7 +510,6 @@ static int fwnet_finish_incoming_packet(struct net_device *net,
 					bool is_broadcast, u16 ether_type)
 {
 	struct fwnet_device *dev;
-	static const __be64 broadcast_hw = cpu_to_be64(~0ULL);
 	int status;
 	__be64 guid;
 
@@ -537,92 +528,13 @@ static int fwnet_finish_incoming_packet(struct net_device *net,
 
 	/*
 	 * Parse the encapsulation header. This actually does the job of
-	 * converting to an ethernet frame header, as well as arp
-	 * conversion if needed. ARP conversion is easier in this
-	 * direction, since we are using ethernet as our backend.
+	 * converting to an ethernet-like pseudo frame header.
 	 */
-	/*
-	 * If this is an ARP packet, convert it. First, we want to make
-	 * use of some of the fields, since they tell us a little bit
-	 * about the sending machine.
-	 */
-	if (ether_type == ETH_P_ARP) {
-		struct rfc2734_arp *arp1394;
-		struct arphdr *arp;
-		unsigned char *arp_ptr;
-		u64 fifo_addr;
-		u64 peer_guid;
-		unsigned sspd;
-		u16 max_payload;
-		struct fwnet_peer *peer;
-		unsigned long flags;
-
-		arp1394   = (struct rfc2734_arp *)skb->data;
-		arp       = (struct arphdr *)skb->data;
-		arp_ptr   = (unsigned char *)(arp + 1);
-		peer_guid = get_unaligned_be64(&arp1394->s_uniq_id);
-		fifo_addr = (u64)get_unaligned_be16(&arp1394->fifo_hi) << 32
-				| get_unaligned_be32(&arp1394->fifo_lo);
-
-		sspd = arp1394->sspd;
-		/* Sanity check.  OS X 10.3 PPC reportedly sends 131. */
-		if (sspd > SCODE_3200) {
-			dev_notice(&net->dev, "sspd %x out of range\n", sspd);
-			sspd = SCODE_3200;
-		}
-		max_payload = fwnet_max_payload(arp1394->max_rec, sspd);
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
-			goto no_peer;
-		}
-
-		/*
-		 * Now that we're done with the 1394 specific stuff, we'll
-		 * need to alter some of the data.  Believe it or not, all
-		 * that needs to be done is sender_IP_address needs to be
-		 * moved, the destination hardware address get stuffed
-		 * in and the hardware address length set to 8.
-		 *
-		 * IMPORTANT: The code below overwrites 1394 specific data
-		 * needed above so keep the munging of the data for the
-		 * higher level IP stack last.
-		 */
-
-		arp->ar_hln = 8;
-		/* skip over sender unique id */
-		arp_ptr += arp->ar_hln;
-		/* move sender IP addr */
-		put_unaligned(arp1394->sip, (u32 *)arp_ptr);
-		/* skip over sender IP addr */
-		arp_ptr += arp->ar_pln;
-
-		if (arp->ar_op == htons(ARPOP_REQUEST))
-			memset(arp_ptr, 0, sizeof(u64));
-		else
-			memcpy(arp_ptr, net->dev_addr, sizeof(u64));
-	}
 
 	/* Now add the ethernet header. */
 	guid = cpu_to_be64(dev->card->guid);
 	if (dev_hard_header(skb, net, ether_type,
-			   is_broadcast ? &broadcast_hw : &guid,
+			   is_broadcast ? net->broadcast : net->dev_addr,
 			   NULL, skb->len) >= 0) {
 		struct fwnet_header *eth;
 		u16 *rawp;
@@ -665,8 +577,7 @@ static int fwnet_finish_incoming_packet(struct net_device *net,
 
 	return 0;
 
- no_peer:
- err:
+err:
 	net->stats.rx_errors++;
 	net->stats.rx_dropped++;
 
@@ -1140,18 +1051,6 @@ static int fwnet_broadcast_start(struct fwnet_device *dev)
 	unsigned long offset;
 	unsigned u;
 
-	if (dev->local_fifo == FWNET_NO_FIFO_ADDR) {
-		dev->handler.length = 4096;
-		dev->handler.address_callback = fwnet_receive_packet;
-		dev->handler.callback_data = dev;
-
-		retval = fw_core_add_address_handler(&dev->handler,
-					&fw_high_memory_region);
-		if (retval < 0)
-			goto failed_initial;
-
-		dev->local_fifo = dev->handler.offset;
-	}
 
 	max_receive = 1U << (dev->card->max_receive + 1);
 	num_packets = (FWNET_ISO_PAGE_COUNT * PAGE_SIZE) / max_receive;
@@ -1234,8 +1133,6 @@ static int fwnet_broadcast_start(struct fwnet_device *dev)
 	dev->broadcast_rcv_context = NULL;
  failed_context_create:
 	fw_core_remove_address_handler(&dev->handler);
- failed_initial:
-	dev->local_fifo = FWNET_NO_FIFO_ADDR;
 
 	return retval;
 }
@@ -1339,42 +1236,23 @@ static netdev_tx_t fwnet_tx(struct sk_buff *skb, struct net_device *net)
 		ptask->dest_node   = IEEE1394_ALL_NODES;
 		ptask->speed       = SCODE_100;
 	} else {
-		__be64 guid = get_unaligned((__be64 *)hdr_buf.h_dest);
+		union fwnet_hwaddr *ha = (union fwnet_hwaddr *)hdr_buf.h_dest;
+		__be64 guid = get_unaligned(&ha->uc.uniq_id);
 		u8 generation;
 
 		peer = fwnet_peer_find_by_guid(dev, be64_to_cpu(guid));
-		if (!peer || peer->fifo == FWNET_NO_FIFO_ADDR)
+		if (!peer)
 			goto fail;
 
 		generation         = peer->generation;
 		dest_node          = peer->node_id;
-		max_payload        = peer->max_payload;
+		max_payload        = fwnet_hwaddr_maxpayload(ha);
 		datagram_label_ptr = &peer->datagram_label;
 
-		ptask->fifo_addr   = peer->fifo;
+		ptask->fifo_addr   = fwnet_hwaddr_fifo(ha);
 		ptask->generation  = generation;
 		ptask->dest_node   = dest_node;
-		ptask->speed       = peer->speed;
-	}
-
-	/* If this is an ARP packet, convert it */
-	if (proto == htons(ETH_P_ARP)) {
-		struct arphdr *arp = (struct arphdr *)skb->data;
-		unsigned char *arp_ptr = (unsigned char *)(arp + 1);
-		struct rfc2734_arp *arp1394 = (struct rfc2734_arp *)skb->data;
-		__be32 ipaddr;
-
-		ipaddr = get_unaligned((__be32 *)(arp_ptr + FWNET_ALEN));
-
-		arp1394->hw_addr_len    = RFC2734_HW_ADDR_LEN;
-		arp1394->max_rec        = dev->card->max_receive;
-		arp1394->sspd		= dev->card->link_speed;
-
-		put_unaligned_be16(dev->local_fifo >> 32,
-				   &arp1394->fifo_hi);
-		put_unaligned_be32(dev->local_fifo & 0xffffffff,
-				   &arp1394->fifo_lo);
-		put_unaligned(ipaddr, &arp1394->sip);
+		ptask->speed       = fwnet_fixup_speed(ha->uc.sspd);
 	}
 
 	ptask->hdr.w0 = 0;
@@ -1491,13 +1369,9 @@ static int fwnet_add_peer(struct fwnet_device *dev,
 
 	peer->dev = dev;
 	peer->guid = (u64)device->config_rom[3] << 32 | device->config_rom[4];
-	peer->fifo = FWNET_NO_FIFO_ADDR;
-	peer->ip = 0;
 	INIT_LIST_HEAD(&peer->pd_list);
 	peer->pdg_size = 0;
 	peer->datagram_label = 0;
-	peer->speed = device->max_speed;
-	peer->max_payload = fwnet_max_payload(device->max_rec, peer->speed);
 
 	peer->generation = device->generation;
 	smp_rmb();
@@ -1522,6 +1396,7 @@ static int fwnet_probe(struct device *_dev)
 	struct fwnet_device *dev;
 	unsigned max_mtu;
 	int ret;
+	union fwnet_hwaddr *ha;
 
 	mutex_lock(&fwnet_device_mutex);
 
@@ -1546,12 +1421,21 @@ static int fwnet_probe(struct device *_dev)
 	dev->broadcast_rcv_context = NULL;
 	dev->broadcast_xmt_max_payload = 0;
 	dev->broadcast_xmt_datagramlabel = 0;
-	dev->local_fifo = FWNET_NO_FIFO_ADDR;
 	dev->queued_datagrams = 0;
 	INIT_LIST_HEAD(&dev->peer_list);
 	dev->card = card;
 	dev->netdev = net;
 
+	dev->handler.length = 4096;
+	dev->handler.address_callback = fwnet_receive_packet;
+	dev->handler.callback_data = dev;
+
+	ret = fw_core_add_address_handler(&dev->handler, &fw_high_memory_region);
+	if (ret < 0)
+		goto out;
+
+	dev->local_fifo = dev->handler.offset;
+
 	/*
 	 * Use the RFC 2734 default 1500 octets or the maximum payload
 	 * as initial MTU
@@ -1561,8 +1445,15 @@ static int fwnet_probe(struct device *_dev)
 	net->mtu = min(1500U, max_mtu);
 
 	/* Set our hardware address while we're at it */
-	put_unaligned_be64(card->guid, net->dev_addr);
-	put_unaligned_be64(~0ULL, net->broadcast);
+	ha = (union fwnet_hwaddr *)net->dev_addr;
+	put_unaligned_be64(card->guid, &ha->uc.uniq_id);
+	ha->uc.max_rec = dev->card->max_receive;
+	ha->uc.sspd = dev->card->link_speed;
+	put_unaligned_be16(dev->local_fifo >> 32, &ha->uc.fifo_hi);
+	put_unaligned_be32(dev->local_fifo & 0xffffffff, &ha->uc.fifo_lo);
+
+	memset(net->broadcast, -1, net->addr_len);
+
 	ret = register_netdev(net);
 	if (ret)
 		goto out;
@@ -1611,8 +1502,6 @@ static int fwnet_remove(struct device *_dev)
 	mutex_lock(&fwnet_device_mutex);
 
 	net = dev->netdev;
-	if (net && peer->ip)
-		arp_invalidate(net, peer->ip);
 
 	fwnet_remove_peer(peer, dev);
 
diff --git a/include/linux/if_arp.h b/include/linux/if_arp.h
index 89b4614..f563907 100644
--- a/include/linux/if_arp.h
+++ b/include/linux/if_arp.h
@@ -33,7 +33,15 @@ static inline struct arphdr *arp_hdr(const struct sk_buff *skb)
 
 static inline int arp_hdr_len(struct net_device *dev)
 {
-	/* ARP header, plus 2 device addresses, plus 2 IP addresses. */
-	return sizeof(struct arphdr) + (dev->addr_len + sizeof(u32)) * 2;
+	switch (dev->type) {
+#if IS_ENABLED(CONFIG_FIREWIRE_NET)
+	case ARPHRD_IEEE1394:
+		/* ARP header, device address and 2 IP addresses */
+		return sizeof(struct arphdr) + dev->addr_len + sizeof(u32) * 2;
+#endif
+	default:
+		/* ARP header, plus 2 device addresses, plus 2 IP addresses. */
+		return sizeof(struct arphdr) + (dev->addr_len + sizeof(u32)) * 2;
+	}
 }
 #endif	/* _LINUX_IF_ARP_H */
diff --git a/include/net/firewire.h b/include/net/firewire.h
new file mode 100644
index 0000000..bec4b60
--- /dev/null
+++ b/include/net/firewire.h
@@ -0,0 +1,25 @@
+#ifndef _NET_FIREWIRE_H
+#define _NET_FIREWIRE_H
+
+/* Pseude L2 address */
+#define FWNET_ALEN	16
+union fwnet_hwaddr {
+	u8 u[FWNET_ALEN];
+	/* "Hardware address" defined in RFC2734/RF3146 */
+	struct {
+		__be64 uniq_id;		/* EUI-64			*/
+		u8 max_rec;		/* max packet size		*/
+		u8 sspd;		/* max speed			*/
+		__be16 fifo_hi;		/* hi 16bits of FIFO addr	*/
+		__be32 fifo_lo;		/* lo 32bits of FIFO addr	*/
+	} __packed uc;
+};
+
+/* Pseudo L2 Header */
+#define FWNET_HLEN	18
+struct fwnet_header {
+	u8 h_dest[FWNET_ALEN];	/* destination address */
+	__be16 h_proto;		/* packet type ID field */
+} __packed;
+
+#endif
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 9547a273..2db3af3 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -654,11 +654,19 @@ struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
 	arp_ptr += dev->addr_len;
 	memcpy(arp_ptr, &src_ip, 4);
 	arp_ptr += 4;
-	if (target_hw != NULL)
-		memcpy(arp_ptr, target_hw, dev->addr_len);
-	else
-		memset(arp_ptr, 0, dev->addr_len);
-	arp_ptr += dev->addr_len;
+
+	switch (dev->type) {
+#if IS_ENABLED(CONFIG_FIREWIRE_NET)
+	case ARPHRD_IEEE1394:
+		break;
+#endif
+	default:
+		if (target_hw != NULL)
+			memcpy(arp_ptr, target_hw, dev->addr_len);
+		else
+			memset(arp_ptr, 0, dev->addr_len);
+		arp_ptr += dev->addr_len;
+	}
 	memcpy(arp_ptr, &dest_ip, 4);
 
 	return skb;
-- 
1.7.9.5
