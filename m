From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH 2.6.17-rc6-mm2] eth1394: replace __constant_htons by htons
Date: Sat, 10 Jun 2006 23:44:45 +0200 (CEST)
Message-ID: <tkrat.6dee876f8681acaa@s5r6.in-berlin.de>
References: <20060519132539.GC17751@mipter.zuzino.mipt.ru>
	<44782474.9050304@s5r6.in-berlin.de>
	<20060527094019.4d451093@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
To: linux1394-devel@lists.sourceforge.net
In-Reply-To: <20060527094019.4d451093@localhost.localdomain>
Content-Disposition: INLINE
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux1394-devel-bounces@lists.sourceforge.net
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

...and __constant_ntohs, __constant_ntohl, __constant_cpu_to_be32 too
where possible.  Htons and friends are resolved to constants in these
places anyway.  Also fix an endianess glitch in a log message, spotted
by Alexey Dobriyan.

Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
---
 drivers/ieee1394/eth1394.c |   23 +++++++++++------------
 1 files changed, 11 insertions(+), 12 deletions(-)

Index: linux-2.6.17-rc6-mm2/drivers/ieee1394/eth1394.c
===================================================================
--- linux-2.6.17-rc6-mm2.orig/drivers/ieee1394/eth1394.c	2006-06-10 21:18:28.000000000 +0200
+++ linux-2.6.17-rc6-mm2/drivers/ieee1394/eth1394.c	2006-06-10 21:33:59.000000000 +0200
@@ -770,7 +770,7 @@ static int ether1394_rebuild_header(stru
 	default:
 		ETH1394_PRINT(KERN_DEBUG, dev->name,
 			      "unable to resolve type %04x addresses.\n",
-			      eth->h_proto);
+			      ntohs(eth->h_proto));
 		break;
 	}
 
@@ -792,9 +792,8 @@ static int ether1394_header_cache(struct
 						      (16 - ETH1394_HLEN));
 	struct net_device *dev = neigh->dev;
 
-	if (type == __constant_htons(ETH_P_802_3)) {
+	if (type == htons(ETH_P_802_3))
 		return -1;
-	}
 
 	eth->h_proto = type;
 	memcpy(eth->h_dest, neigh->ha, dev->addr_len);
@@ -883,7 +882,7 @@ static inline u16 ether1394_parse_encap(
 	/* If this is an ARP packet, convert it. First, we want to make
 	 * use of some of the fields, since they tell us a little bit
 	 * about the sending machine.  */
-	if (ether_type == __constant_htons (ETH_P_ARP)) {
+	if (ether_type == htons(ETH_P_ARP)) {
 		struct eth1394_arp *arp1394 = (struct eth1394_arp*)skb->data;
 		struct arphdr *arp = (struct arphdr *)skb->data;
 		unsigned char *arp_ptr = (unsigned char *)(arp + 1);
@@ -939,8 +938,8 @@ static inline u16 ether1394_parse_encap(
 	}
 
 	/* Now add the ethernet header. */
-	if (dev->hard_header (skb, dev, __constant_ntohs (ether_type),
-			      &dest_hw, NULL, skb->len) >= 0)
+	if (dev->hard_header(skb, dev, ntohs(ether_type), &dest_hw, NULL,
+			     skb->len) >= 0)
 		ret = ether1394_type_trans(skb, dev);
 
 	return ret;
@@ -1509,8 +1508,8 @@ static inline void ether1394_prep_gasp_p
 	p->data = ((quadlet_t*)skb->data) - 2;
 	p->data[0] = cpu_to_be32((priv->host->node_id << 16) |
 				 ETHER1394_GASP_SPECIFIER_ID_HI);
-	p->data[1] = __constant_cpu_to_be32((ETHER1394_GASP_SPECIFIER_ID_LO << 24) |
-					    ETHER1394_GASP_VERSION);
+	p->data[1] = cpu_to_be32((ETHER1394_GASP_SPECIFIER_ID_LO << 24) |
+				 ETHER1394_GASP_VERSION);
 
 	/* Setting the node id to ALL_NODES (not LOCAL_BUS | ALL_NODES)
 	 * prevents hpsb_send_packet() from setting the speed to an arbitrary
@@ -1665,9 +1664,9 @@ static int ether1394_tx (struct sk_buff 
 	/* Set the transmission type for the packet.  ARP packets and IP
 	 * broadcast packets are sent via GASP. */
 	if (memcmp(eth->h_dest, dev->broadcast, ETH1394_ALEN) == 0 ||
-	    proto == __constant_htons(ETH_P_ARP) ||
-	    (proto == __constant_htons(ETH_P_IP) &&
-	     IN_MULTICAST(__constant_ntohl(skb->nh.iph->daddr)))) {
+	    proto == htons(ETH_P_ARP) ||
+	    (proto == htons(ETH_P_IP) &&
+	     IN_MULTICAST(ntohl(skb->nh.iph->daddr)))) {
 		tx_type = ETH1394_GASP;
 		dest_node = LOCAL_BUS | ALL_NODES;
 		max_payload = priv->bc_maxpayload - ETHER1394_GASP_OVERHEAD;
@@ -1699,7 +1698,7 @@ static int ether1394_tx (struct sk_buff 
 	}
 
 	/* If this is an ARP packet, convert it */
-	if (proto == __constant_htons (ETH_P_ARP))
+	if (proto == htons(ETH_P_ARP))
 		ether1394_arp_to_1394arp (skb, dev);
 
 	ptask->hdr.words.word1 = 0;
