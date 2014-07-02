From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next v2 3/3 RFC] pktgen: Allow sending TCP packets
Date: Wed, 2 Jul 2014 20:54:15 +0100
Message-ID: <1404330855-24546-4-git-send-email-zoltan.kiss@citrix.com>
References: <1404330855-24546-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>, Joe Perches <joe@perches.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	Mathias Krause <minipli@googlemail.com>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404330855-24546-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a prototype patch to enable sending TCP packets with pktgen. The
original motivation is to test TCP GSO with xen-netback/netfront, but I'm not
sure about how the checksum should be set up, and also someone should verify the
GSO settings I'm using.

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Thomas Graf <tgraf@suug.ch>
Cc: Joe Perches <joe@perches.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: xen-devel@lists.xenproject.org
---
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index d7206ea..13aad46 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -203,6 +203,7 @@
 #define F_NODE          (1<<15)	/* Node memory alloc*/
 #define F_UDPCSUM       (1<<16)	/* Include UDP checksum */
 #define F_PATTERN       (1<<17)	/* Fill the payload with a pattern */
+#define F_TCP           (1<<18)	/* Send TCP packet instead of UDP */
 
 /* Thread control flag bits */
 #define T_STOP        (1<<0)	/* Stop run */
@@ -1343,6 +1344,12 @@ static ssize_t pktgen_if_write(struct file *file,
 		else if (strcmp(f, "!PATTERN") == 0)
 			pkt_dev->flags &= ~F_PATTERN;
 
+		else if (strcmp(f, "TCP") == 0)
+			pkt_dev->flags |= F_TCP;
+
+		else if (strcmp(f, "!TCP") == 0)
+			pkt_dev->flags &= ~F_TCP;
+
 		else {
 			sprintf(pg_result,
 				"Flag -:%s:- unknown\nAvailable flags, (prepend ! to un-set flag):\n%s",
@@ -2952,6 +2959,7 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 	struct sk_buff *skb = NULL;
 	__u8 *eth;
 	struct udphdr *udph;
+	struct tcphdr *tcph;
 	int datalen, iplen;
 	struct iphdr *iph;
 	__be16 protocol = htons(ETH_P_IP);
@@ -3013,29 +3021,39 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 	iph = (struct iphdr *) skb_put(skb, sizeof(struct iphdr));
 
 	skb_set_transport_header(skb, skb->len);
-	udph = (struct udphdr *) skb_put(skb, sizeof(struct udphdr));
+
+	if (pkt_dev->flags & F_TCP) {
+		datalen = pkt_dev->cur_pkt_size - ETH_HLEN - 20 -
+			  sizeof(struct tcphdr) - pkt_dev->pkt_overhead;
+		tcph = (struct tcphdr *)skb_put(skb, sizeof(struct tcphdr));
+		tcph->source = htons(pkt_dev->cur_udp_src);
+		tcph->dest = htons(pkt_dev->cur_udp_dst);
+		tcph->check = 0;
+	} else {
+		datalen = pkt_dev->cur_pkt_size - ETH_HLEN - 20 -
+			  sizeof(struct udphdr) - pkt_dev->pkt_overhead;
+		udph = (struct udphdr *)skb_put(skb, sizeof(struct udphdr));
+		udph->source = htons(pkt_dev->cur_udp_src);
+		udph->dest = htons(pkt_dev->cur_udp_dst);
+		udph->len = htons(datalen + sizeof(struct udphdr));	/* DATA + udphdr */
+		udph->check = 0;
+	}
+
 	skb_set_queue_mapping(skb, queue_map);
 	skb->priority = pkt_dev->skb_priority;
 
 	memcpy(eth, pkt_dev->hh, 12);
 	*(__be16 *) & eth[12] = protocol;
 
-	/* Eth + IPh + UDPh + mpls */
-	datalen = pkt_dev->cur_pkt_size - 14 - 20 - 8 -
-		  pkt_dev->pkt_overhead;
 	if (datalen < 0 || datalen < sizeof(struct pktgen_hdr))
 		datalen = sizeof(struct pktgen_hdr);
 
-	udph->source = htons(pkt_dev->cur_udp_src);
-	udph->dest = htons(pkt_dev->cur_udp_dst);
-	udph->len = htons(datalen + 8);	/* DATA + udphdr */
-	udph->check = 0;
 
 	iph->ihl = 5;
 	iph->version = 4;
 	iph->ttl = 32;
 	iph->tos = pkt_dev->tos;
-	iph->protocol = IPPROTO_UDP;	/* UDP */
+	iph->protocol = pkt_dev->flags & F_TCP ? IPPROTO_TCP : IPPROTO_UDP;
 	iph->saddr = pkt_dev->cur_saddr;
 	iph->daddr = pkt_dev->cur_daddr;
 	iph->id = htons(pkt_dev->ip_id);
@@ -3050,7 +3068,9 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 
 	if (!(pkt_dev->flags & F_UDPCSUM)) {
 		skb->ip_summed = CHECKSUM_NONE;
-	} else if (odev->features & NETIF_F_V4_CSUM) {
+	} else if (pkt_dev->flags & F_TCP)
+		skb_checksum_setup(skb, true);
+	else if (odev->features & NETIF_F_V4_CSUM) {
 		skb->ip_summed = CHECKSUM_PARTIAL;
 		skb->csum = 0;
 		udp4_hwcsum(skb, udph->source, udph->dest);
@@ -3067,6 +3087,18 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 
 	pktgen_finalize_skb(pkt_dev, skb, datalen);
 
+	if (odev->mtu < skb->len) {
+		skb_shinfo(skb)->gso_size = odev->mtu - ETH_HLEN - 20 -
+					    pkt_dev->pkt_overhead;
+		if (pkt_dev->flags & F_TCP) {
+			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
+			skb_shinfo(skb)->gso_size -= sizeof(struct tcphdr);
+		} else {
+			skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
+			skb_shinfo(skb)->gso_size -= sizeof(struct udphdr);
+		}
+	}
+
 #ifdef CONFIG_XFRM
 	if (!process_ipsec(pkt_dev, skb, protocol))
 		return NULL;
