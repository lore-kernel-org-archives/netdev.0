From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next 3/3 RFC] pktgen: Allow sending TCP packets
Date: Wed, 25 Jun 2014 21:42:52 +0100
Message-ID: <1403728972-29548-4-git-send-email-zoltan.kiss@citrix.com>
References: <1403728972-29548-1-git-send-email-zoltan.kiss@citrix.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:56811 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755949AbaFYUnY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2014 16:43:24 -0400
In-Reply-To: <1403728972-29548-1-git-send-email-zoltan.kiss@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
 net/core/pktgen.c |   52 ++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 42 insertions(+), 10 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index b8090a0..bc9c0a4 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -202,6 +202,7 @@
 #define F_NODE          (1<<15)	/* Node memory alloc*/
 #define F_UDPCSUM       (1<<16)	/* Include UDP checksum */
 #define F_PATTERN       (1<<17)	/* Fill the payload with a pattern */
+#define F_TCP           (1<<18)	/* Send TCP packet instead of UDP */
 
 /* Thread control flag bits */
 #define T_STOP        (1<<0)	/* Stop run */
@@ -1341,6 +1342,12 @@ static ssize_t pktgen_if_write(struct file *file,
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
@@ -2951,6 +2958,7 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 	struct sk_buff *skb = NULL;
 	__u8 *eth;
 	struct udphdr *udph;
+	struct tcphdr *tcph;
 	int datalen, iplen;
 	struct iphdr *iph;
 	__be16 protocol = htons(ETH_P_IP);
@@ -3012,29 +3020,39 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 	iph = (struct iphdr *) skb_put(skb, sizeof(struct iphdr));
 
 	skb_set_transport_header(skb, skb->len);
-	udph = (struct udphdr *) skb_put(skb, sizeof(struct udphdr));
+
+	if (pkt_dev->flags & F_TCP) {
+		datalen = pkt_dev->cur_pkt_size - ETH_HLEN - 20 -
+			  sizeof(struct tcphdr) - pkt_dev->pkt_overhead;
+		tcph = (struct tcphdr *) skb_put(skb, sizeof(struct tcphdr));
+		tcph->source = htons(pkt_dev->cur_udp_src);
+		tcph->dest = htons(pkt_dev->cur_udp_dst);
+		tcph->check = 0;
+	} else {
+		datalen = pkt_dev->cur_pkt_size - ETH_HLEN - 20 -
+			  sizeof(struct udphdr) - pkt_dev->pkt_overhead;
+		udph = (struct udphdr *) skb_put(skb, sizeof(struct udphdr));
+		udph->source = htons(pkt_dev->cur_udp_src);
+		udph->dest = htons(pkt_dev->cur_udp_dst);
+		udph->len = htons(datalen + sizeof(struct udphdr));	/* DATA + udphdr */
+		udph->check = 0;
+
+	}
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
@@ -3049,7 +3067,9 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 
 	if (!(pkt_dev->flags & F_UDPCSUM)) {
 		skb->ip_summed = CHECKSUM_NONE;
-	} else if (odev->features & NETIF_F_V4_CSUM) {
+	} else if (pkt_dev->flags & F_TCP)
+		skb_checksum_setup(skb, true);
+	else if (odev->features & NETIF_F_V4_CSUM) {
 		skb->ip_summed = CHECKSUM_PARTIAL;
 		skb->csum = 0;
 		udp4_hwcsum(skb, udph->source, udph->dest);
@@ -3066,6 +3086,18 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 
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
