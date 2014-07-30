From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next v3 4/4 RFC] pktgen: Allow sending IPv4 TCP packets
Date: Wed, 30 Jul 2014 17:20:12 +0100
Message-ID: <1406737212-23351-5-git-send-email-zoltan.kiss@citrix.com>
References: <1406737212-23351-1-git-send-email-zoltan.kiss@citrix.com>
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
In-Reply-To: <1406737212-23351-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a prototype patch to enable sending IPv4 TCP packets with pktgen. The
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
v3:
- mention explicitly that this for IPv4
- memset the TCP header and set up doff
- rework of checksum handling and GSO setting in fill_packet_ipv4
- bail out in pktgen_xmit if the device won't be able to handle GSO

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 0d0aaac..9d93bda 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -162,6 +162,7 @@
 #include <net/checksum.h>
 #include <net/ipv6.h>
 #include <net/udp.h>
+#include <net/tcp.h>
 #include <net/ip6_checksum.h>
 #include <net/addrconf.h>
 #ifdef CONFIG_XFRM
@@ -203,6 +204,7 @@
 #define F_NODE          (1<<15)	/* Node memory alloc*/
 #define F_UDPCSUM       (1<<16)	/* Include UDP checksum */
 #define F_PATTERN       (1<<17)	/* Fill the payload with a pattern */
+#define F_TCP           (1<<18)	/* Send TCP packet instead of UDP */
 
 /* Thread control flag bits */
 #define T_STOP        (1<<0)	/* Stop run */
@@ -664,6 +666,9 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 	if (pkt_dev->flags & F_PATTERN)
 		seq_puts(seq, "PATTERN  ");
 
+	if (pkt_dev->flags & F_TCP)
+		seq_puts(seq, "TCP  ");
+
 	if (pkt_dev->flags & F_MPLS_RND)
 		seq_puts(seq,  "MPLS_RND  ");
 
@@ -1342,6 +1347,12 @@ static ssize_t pktgen_if_write(struct file *file,
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
@@ -2955,7 +2966,8 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 {
 	struct sk_buff *skb = NULL;
 	__u8 *eth;
-	struct udphdr *udph;
+	struct udphdr *udph = NULL;
+	struct tcphdr *tcph;
 	int datalen, iplen;
 	struct iphdr *iph;
 	__be16 protocol = htons(ETH_P_IP);
@@ -3017,29 +3029,40 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 	iph = (struct iphdr *) skb_put(skb, sizeof(struct iphdr));
 
 	skb_set_transport_header(skb, skb->len);
-	udph = (struct udphdr *) skb_put(skb, sizeof(struct udphdr));
+
+	if (pkt_dev->flags & F_TCP) {
+		datalen = pkt_dev->cur_pkt_size - ETH_HLEN - 20 -
+			  sizeof(struct tcphdr) - pkt_dev->pkt_overhead;
+		tcph = (struct tcphdr *)skb_put(skb, sizeof(struct tcphdr));
+		memset(tcph, 0, sizeof(*tcph));
+		tcph->source = htons(pkt_dev->cur_udp_src);
+		tcph->dest = htons(pkt_dev->cur_udp_dst);
+		tcph->doff = sizeof(struct tcphdr) >> 2;
+	} else {
+		datalen = pkt_dev->cur_pkt_size - ETH_HLEN - 20 -
+			  sizeof(struct udphdr) - pkt_dev->pkt_overhead;
+		udph = (struct udphdr *)skb_put(skb, sizeof(struct udphdr));
+		udph->source = htons(pkt_dev->cur_udp_src);
+		udph->dest = htons(pkt_dev->cur_udp_dst);
+		udph->len = htons(datalen + sizeof(struct udphdr));
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
@@ -3055,9 +3078,14 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 	if (!(pkt_dev->flags & F_UDPCSUM)) {
 		skb->ip_summed = CHECKSUM_NONE;
 	} else if (odev->features & NETIF_F_V4_CSUM) {
-		skb->ip_summed = CHECKSUM_PARTIAL;
-		skb->csum = 0;
-		udp4_hwcsum(skb, udph->source, udph->dest);
+		skb_checksum_setup(skb, true);
+	} else if (pkt_dev->flags & F_TCP) {
+		struct inet_sock inet;
+
+		inet.inet_saddr = iph->saddr;
+		inet.inet_daddr = iph->daddr;
+		skb->ip_summed = CHECKSUM_NONE;
+		tcp_v4_send_check((struct sock *)&inet, skb);
 	} else {
 		__wsum csum = udp_csum(skb);
 
@@ -3072,6 +3100,20 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 
 	pktgen_finalize_skb(pkt_dev, skb, datalen);
 
+	if (odev->mtu < skb->len) {
+		int hdrlen = skb_transport_header(skb) - skb_mac_header(skb);
+
+		if (pkt_dev->flags & F_TCP) {
+			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
+			hdrlen += tcp_hdrlen(skb);
+		} else {
+			skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
+			hdrlen += sizeof(struct udphdr);
+		}
+		skb_shinfo(skb)->gso_size = odev->mtu - hdrlen;
+		skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len - hdrlen, skb_shinfo(skb)->gso_size);
+	}
+
 #ifdef CONFIG_XFRM
 	if (!process_ipsec(pkt_dev, skb, protocol))
 		return NULL;
@@ -3559,6 +3601,14 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		pkt_dev->last_pkt_size = pkt_dev->skb->len;
 		pkt_dev->allocated_skbs++;
 		pkt_dev->clone_count = 0;	/* reset counter */
+
+		if (netif_needs_gso(pkt_dev->skb, netif_skb_features(pkt_dev->skb))) {
+			pr_err("Device don't have necessary GSO features! netif_skb_features: %llX summed %u\n",
+				netif_skb_features(pkt_dev->skb),
+				pkt_dev->skb->ip_summed);
+			pkt_dev->sofar++;
+			goto out;
+		}
 	}
 
 	if (pkt_dev->delay && pkt_dev->last_ok)
@@ -3608,7 +3658,7 @@ unlock:
 	HARD_TX_UNLOCK(odev, txq);
 
 	local_bh_enable();
-
+out:
 	/* If pkt_dev->count is zero, then run forever */
 	if ((pkt_dev->count != 0) && (pkt_dev->sofar >= pkt_dev->count)) {
 		pktgen_wait_for_skb(pkt_dev);
