From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: pktgen Multiqueue support [PATCH]
Date: Mon, 27 Aug 2007 16:55:19 +0200
Message-ID: <18130.58839.670389.974331@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:36736 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750784AbXH0OzX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Aug 2007 10:55:23 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Hello,

Below some pktgen support to send into different TX queues.
This can of course be feed into input queues on other machines

Cheers
					--ro



Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>


diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index a0db4d1..18601af 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -186,6 +186,7 @@
 #define F_SVID_RND    (1<<10)	/* Random SVLAN ID */
 #define F_FLOW_SEQ    (1<<11)	/* Sequential flows */
 #define F_IPSEC_ON    (1<<12)	/* ipsec on for flows */
+#define F_QUEUE_MAP_RND (1<<13)	/* queue map Random */
 
 /* Thread control flag bits */
 #define T_TERMINATE   (1<<0)
@@ -328,6 +329,7 @@ struct pktgen_dev {
 	__be32 cur_daddr;
 	__u16 cur_udp_dst;
 	__u16 cur_udp_src;
+	__u16 cur_queue_map;
 	__u32 cur_pkt_size;
 
 	__u8 hh[14];
@@ -355,6 +357,10 @@ struct pktgen_dev {
 	unsigned lflow;		/* Flow length  (config) */
 	unsigned nflows;	/* accumulated flows (stats) */
 	unsigned curfl;		/* current sequenced flow (state)*/
+
+	u16 queue_map_min;
+	u16 queue_map_max;
+
 #ifdef CONFIG_XFRM
 	__u8	ipsmode;		/* IPSEC mode (config) */
 	__u8	ipsproto;		/* IPSEC type (config) */
@@ -611,6 +617,11 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 	seq_printf(seq, "     flows: %u flowlen: %u\n", pkt_dev->cflows,
 		   pkt_dev->lflow);
 
+	seq_printf(seq,
+		   "     queue_map_min: %u  queue_map_max: %u\n",
+		   pkt_dev->queue_map_min,
+		   pkt_dev->queue_map_max);
+
 	if (pkt_dev->flags & F_IPV6) {
 		char b1[128], b2[128], b3[128];
 		fmt_ip6(b1, pkt_dev->in6_saddr.s6_addr);
@@ -707,6 +718,9 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 	if (pkt_dev->flags & F_MPLS_RND)
 		seq_printf(seq,  "MPLS_RND  ");
 
+	if (pkt_dev->flags & F_QUEUE_MAP_RND)
+		seq_printf(seq,  "QUEUE_MAP_RND  ");
+
 	if (pkt_dev->cflows) {
 		if (pkt_dev->flags & F_FLOW_SEQ)
 			seq_printf(seq,  "FLOW_SEQ  "); /*in sequence flows*/
@@ -762,6 +776,8 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 	seq_printf(seq, "     cur_udp_dst: %d  cur_udp_src: %d\n",
 		   pkt_dev->cur_udp_dst, pkt_dev->cur_udp_src);
 
+	seq_printf(seq, "     cur_queue_map: %u\n", pkt_dev->cur_queue_map);
+
 	seq_printf(seq, "     flows: %u\n", pkt_dev->nflows);
 
 	if (pkt_dev->result[0])
@@ -1213,6 +1229,11 @@ static ssize_t pktgen_if_write(struct file *file,
 		else if (strcmp(f, "FLOW_SEQ") == 0)
 			pkt_dev->flags |= F_FLOW_SEQ;
 
+		else if (strcmp(f, "QUEUE_MAP_RND") == 0)
+			pkt_dev->flags |= F_QUEUE_MAP_RND;
+
+		else if (strcmp(f, "!QUEUE_MAP_RND") == 0)
+			pkt_dev->flags &= ~F_QUEUE_MAP_RND;
 #ifdef CONFIG_XFRM
 		else if (strcmp(f, "IPSEC") == 0)
 			pkt_dev->flags |= F_IPSEC_ON;
@@ -1517,6 +1538,28 @@ static ssize_t pktgen_if_write(struct file *file,
 		return count;
 	}
 
+	if (!strcmp(name, "queue_map_min")) {
+		len = num_arg(&user_buffer[i], 5, &value);
+		if (len < 0) {
+			return len;
+		}
+		i += len;
+		pkt_dev->queue_map_min = value;
+		sprintf(pg_result, "OK: queue_map_min=%u", pkt_dev->queue_map_min);
+		return count;
+	}
+
+	if (!strcmp(name, "queue_map_max")) {
+		len = num_arg(&user_buffer[i], 5, &value);
+		if (len < 0) {
+			return len;
+		}
+		i += len;
+		pkt_dev->queue_map_max = value;
+		sprintf(pg_result, "OK: queue_map_max=%u", pkt_dev->queue_map_max);
+		return count;
+	}
+
 	if (!strcmp(name, "mpls")) {
 		unsigned n, offset;
 		len = get_labels(&user_buffer[i], pkt_dev);
@@ -2378,6 +2421,20 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 		pkt_dev->cur_pkt_size = t;
 	}
 
+	if (pkt_dev->queue_map_min < pkt_dev->queue_map_max) {
+		__u16 t;
+		if (pkt_dev->flags & F_QUEUE_MAP_RND) {
+			t = random32() %
+				(pkt_dev->queue_map_max - pkt_dev->queue_map_min + 1)
+				+ pkt_dev->queue_map_min;
+		} else {
+			t = pkt_dev->cur_queue_map + 1;
+			if (t > pkt_dev->queue_map_max)
+				t = pkt_dev->queue_map_min;
+		}
+		pkt_dev->cur_queue_map = t;
+	}
+
 	pkt_dev->flows[flow].count++;
 }
 
@@ -2548,6 +2605,7 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 	skb->network_header = skb->tail;
 	skb->transport_header = skb->network_header + sizeof(struct iphdr);
 	skb_put(skb, sizeof(struct iphdr) + sizeof(struct udphdr));
+	skb->queue_mapping = pkt_dev->cur_queue_map;
 
 	iph = ip_hdr(skb);
 	udph = udp_hdr(skb);
@@ -2889,6 +2947,7 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 	skb->network_header = skb->tail;
 	skb->transport_header = skb->network_header + sizeof(struct ipv6hdr);
 	skb_put(skb, sizeof(struct ipv6hdr) + sizeof(struct udphdr));
+	skb->queue_mapping = pkt_dev->cur_queue_map;
 
 	iph = ipv6_hdr(skb);
 	udph = udp_hdr(skb);
