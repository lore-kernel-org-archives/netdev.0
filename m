From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] pktgen: speedup fragmented skbs
Date: Tue, 25 Jan 2011 18:13:55 +0100
Message-ID: <1295975635.3588.337.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54852 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753023Ab1AYROA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jan 2011 12:14:00 -0500
Received: by wyb28 with SMTP id 28so5584wyb.19
        for <netdev@vger.kernel.org>; Tue, 25 Jan 2011 09:13:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We spend lot of time clearing pages in pktgen.
(Or not clearing them on ipv6 and leaking kernel memory)

Since we dont modify them, we can use one zeroed page, and get
references on it. This page can use NUMA affinity as well.

Define pktgen_finalize_skb() helper, used both in ipv4 and ipv6

Results using skbs with one frag :

Before patch :

Result: OK: 608980458(c608978520+d1938) nsec, 1000000000
(100byte,1frags)
  1642088pps 1313Mb/sec (1313670400bps) errors: 0

After patch :

Result: OK: 345285014(c345283891+d1123) nsec, 1000000000
(100byte,1frags)
  2896158pps 2316Mb/sec (2316926400bps) errors: 0

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/pktgen.c |  234 +++++++++++++++++---------------------------
 1 files changed, 93 insertions(+), 141 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index a9e7fc4..17c4e16 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -251,6 +251,7 @@ struct pktgen_dev {
 	int max_pkt_size;	/* = ETH_ZLEN; */
 	int pkt_overhead;	/* overhead for MPLS, VLANs, IPSEC etc */
 	int nfrags;
+	struct page *page;
 	u64 delay;		/* nano-seconds */
 
 	__u64 count;		/* Default No packets to send */
@@ -1134,6 +1135,10 @@ static ssize_t pktgen_if_write(struct file *file,
 		if (node_possible(value)) {
 			pkt_dev->node = value;
 			sprintf(pg_result, "OK: node=%d", pkt_dev->node);
+			if (pkt_dev->page) {
+				put_page(pkt_dev->page);
+				pkt_dev->page = 0;
+			}
 		}
 		else
 			sprintf(pg_result, "ERROR: node not possible");
@@ -2605,6 +2610,90 @@ static inline __be16 build_tci(unsigned int id, unsigned int cfi,
 	return htons(id | (cfi << 12) | (prio << 13));
 }
 
+static void pktgen_finalize_skb(struct pktgen_dev *pkt_dev, struct sk_buff *skb,
+				int datalen)
+{
+	struct timeval timestamp;
+	struct pktgen_hdr *pgh;
+
+	pgh = (struct pktgen_hdr *)skb_put(skb, sizeof(*pgh));
+	datalen -= sizeof(*pgh);
+
+	if (pkt_dev->nfrags <= 0) {
+		pgh = (struct pktgen_hdr *)skb_put(skb, datalen);
+		memset(pgh + 1, 0, datalen);
+	} else {
+		int frags = pkt_dev->nfrags;
+		int i, len;
+
+
+		if (frags > MAX_SKB_FRAGS)
+			frags = MAX_SKB_FRAGS;
+		len = datalen - frags * PAGE_SIZE;
+		if (len > 0) {
+			memset(skb_put(skb, len), 0, len);
+			datalen = frags * PAGE_SIZE;
+		}
+
+		i = 0;
+		while (datalen > 0) {
+			if (unlikely(!pkt_dev->page)) {
+				int node = numa_node_id();
+
+				if (pkt_dev->node >= 0 && (pkt_dev->flags & F_NODE))
+					node = pkt_dev->node;
+				pkt_dev->page = alloc_pages_node(node, GFP_KERNEL | __GFP_ZERO, 0);
+				if (!pkt_dev->page)
+					break;
+			}
+			skb_shinfo(skb)->frags[i].page = pkt_dev->page;
+			get_page(pkt_dev->page);
+			skb_shinfo(skb)->frags[i].page_offset = 0;
+			skb_shinfo(skb)->frags[i].size =
+			    (datalen < PAGE_SIZE ? datalen : PAGE_SIZE);
+			datalen -= skb_shinfo(skb)->frags[i].size;
+			skb->len += skb_shinfo(skb)->frags[i].size;
+			skb->data_len += skb_shinfo(skb)->frags[i].size;
+			i++;
+			skb_shinfo(skb)->nr_frags = i;
+		}
+
+		while (i < frags) {
+			int rem;
+
+			if (i == 0)
+				break;
+
+			rem = skb_shinfo(skb)->frags[i - 1].size / 2;
+			if (rem == 0)
+				break;
+
+			skb_shinfo(skb)->frags[i - 1].size -= rem;
+
+			skb_shinfo(skb)->frags[i] =
+			    skb_shinfo(skb)->frags[i - 1];
+			get_page(skb_shinfo(skb)->frags[i].page);
+			skb_shinfo(skb)->frags[i].page =
+			    skb_shinfo(skb)->frags[i - 1].page;
+			skb_shinfo(skb)->frags[i].page_offset +=
+			    skb_shinfo(skb)->frags[i - 1].size;
+			skb_shinfo(skb)->frags[i].size = rem;
+			i++;
+			skb_shinfo(skb)->nr_frags = i;
+		}
+	}
+
+	/* Stamp the time, and sequence number,
+	 * convert them to network byte order
+	 */
+	pgh->pgh_magic = htonl(PKTGEN_MAGIC);
+	pgh->seq_num = htonl(pkt_dev->seq_num);
+
+	do_gettimeofday(&timestamp);
+	pgh->tv_sec = htonl(timestamp.tv_sec);
+	pgh->tv_usec = htonl(timestamp.tv_usec);
+}
+
 static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 					struct pktgen_dev *pkt_dev)
 {
@@ -2613,7 +2702,6 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 	struct udphdr *udph;
 	int datalen, iplen;
 	struct iphdr *iph;
-	struct pktgen_hdr *pgh = NULL;
 	__be16 protocol = htons(ETH_P_IP);
 	__be32 *mpls;
 	__be16 *vlan_tci = NULL;                 /* Encapsulates priority and VLAN ID */
@@ -2729,76 +2817,7 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 			   pkt_dev->pkt_overhead);
 	skb->dev = odev;
 	skb->pkt_type = PACKET_HOST;
-
-	if (pkt_dev->nfrags <= 0) {
-		pgh = (struct pktgen_hdr *)skb_put(skb, datalen);
-		memset(pgh + 1, 0, datalen - sizeof(struct pktgen_hdr));
-	} else {
-		int frags = pkt_dev->nfrags;
-		int i, len;
-
-		pgh = (struct pktgen_hdr *)(((char *)(udph)) + 8);
-
-		if (frags > MAX_SKB_FRAGS)
-			frags = MAX_SKB_FRAGS;
-		if (datalen > frags * PAGE_SIZE) {
-			len = datalen - frags * PAGE_SIZE;
-			memset(skb_put(skb, len), 0, len);
-			datalen = frags * PAGE_SIZE;
-		}
-
-		i = 0;
-		while (datalen > 0) {
-			struct page *page = alloc_pages(GFP_KERNEL | __GFP_ZERO, 0);
-			skb_shinfo(skb)->frags[i].page = page;
-			skb_shinfo(skb)->frags[i].page_offset = 0;
-			skb_shinfo(skb)->frags[i].size =
-			    (datalen < PAGE_SIZE ? datalen : PAGE_SIZE);
-			datalen -= skb_shinfo(skb)->frags[i].size;
-			skb->len += skb_shinfo(skb)->frags[i].size;
-			skb->data_len += skb_shinfo(skb)->frags[i].size;
-			i++;
-			skb_shinfo(skb)->nr_frags = i;
-		}
-
-		while (i < frags) {
-			int rem;
-
-			if (i == 0)
-				break;
-
-			rem = skb_shinfo(skb)->frags[i - 1].size / 2;
-			if (rem == 0)
-				break;
-
-			skb_shinfo(skb)->frags[i - 1].size -= rem;
-
-			skb_shinfo(skb)->frags[i] =
-			    skb_shinfo(skb)->frags[i - 1];
-			get_page(skb_shinfo(skb)->frags[i].page);
-			skb_shinfo(skb)->frags[i].page =
-			    skb_shinfo(skb)->frags[i - 1].page;
-			skb_shinfo(skb)->frags[i].page_offset +=
-			    skb_shinfo(skb)->frags[i - 1].size;
-			skb_shinfo(skb)->frags[i].size = rem;
-			i++;
-			skb_shinfo(skb)->nr_frags = i;
-		}
-	}
-
-	/* Stamp the time, and sequence number,
-	 * convert them to network byte order
-	 */
-	if (pgh) {
-		struct timeval timestamp;
-
-		pgh->pgh_magic = htonl(PKTGEN_MAGIC);
-		pgh->seq_num = htonl(pkt_dev->seq_num);
-
-		do_gettimeofday(&timestamp);
-		pgh->tv_sec = htonl(timestamp.tv_sec);
-		pgh->tv_usec = htonl(timestamp.tv_usec);
-	}
+	pktgen_finalize_skb(pkt_dev, skb, datalen);
 
 #ifdef CONFIG_XFRM
 	if (!process_ipsec(pkt_dev, skb, protocol))
@@ -2980,7 +2999,6 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 	struct udphdr *udph;
 	int datalen;
 	struct ipv6hdr *iph;
-	struct pktgen_hdr *pgh = NULL;
 	__be16 protocol = htons(ETH_P_IPV6);
 	__be32 *mpls;
 	__be16 *vlan_tci = NULL;                 /* Encapsulates priority and VLAN ID */
@@ -3083,75 +3101,7 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 	skb->dev = odev;
 	skb->pkt_type = PACKET_HOST;
 
-	if (pkt_dev->nfrags <= 0)
-		pgh = (struct pktgen_hdr *)skb_put(skb, datalen);
-	else {
-		int frags = pkt_dev->nfrags;
-		int i;
-
-		pgh = (struct pktgen_hdr *)(((char *)(udph)) + 8);
-
-		if (frags > MAX_SKB_FRAGS)
-			frags = MAX_SKB_FRAGS;
-		if (datalen > frags * PAGE_SIZE) {
-			skb_put(skb, datalen - frags * PAGE_SIZE);
-			datalen = frags * PAGE_SIZE;
-		}
-
-		i = 0;
-		while (datalen > 0) {
-			struct page *page = alloc_pages(GFP_KERNEL, 0);
-			skb_shinfo(skb)->frags[i].page = page;
-			skb_shinfo(skb)->frags[i].page_offset = 0;
-			skb_shinfo(skb)->frags[i].size =
-			    (datalen < PAGE_SIZE ? datalen : PAGE_SIZE);
-			datalen -= skb_shinfo(skb)->frags[i].size;
-			skb->len += skb_shinfo(skb)->frags[i].size;
-			skb->data_len += skb_shinfo(skb)->frags[i].size;
-			i++;
-			skb_shinfo(skb)->nr_frags = i;
-		}
-
-		while (i < frags) {
-			int rem;
-
-			if (i == 0)
-				break;
-
-			rem = skb_shinfo(skb)->frags[i - 1].size / 2;
-			if (rem == 0)
-				break;
-
-			skb_shinfo(skb)->frags[i - 1].size -= rem;
-
-			skb_shinfo(skb)->frags[i] =
-			    skb_shinfo(skb)->frags[i - 1];
-			get_page(skb_shinfo(skb)->frags[i].page);
-			skb_shinfo(skb)->frags[i].page =
-			    skb_shinfo(skb)->frags[i - 1].page;
-			skb_shinfo(skb)->frags[i].page_offset +=
-			    skb_shinfo(skb)->frags[i - 1].size;
-			skb_shinfo(skb)->frags[i].size = rem;
-			i++;
-			skb_shinfo(skb)->nr_frags = i;
-		}
-	}
-
-	/* Stamp the time, and sequence number,
-	 * convert them to network byte order
-	 * should we update cloned packets too ?
-	 */
-	if (pgh) {
-		struct timeval timestamp;
-
-		pgh->pgh_magic = htonl(PKTGEN_MAGIC);
-		pgh->seq_num = htonl(pkt_dev->seq_num);
-
-		do_gettimeofday(&timestamp);
-		pgh->tv_sec = htonl(timestamp.tv_sec);
-		pgh->tv_usec = htonl(timestamp.tv_usec);
-	}
-	/* pkt_dev->seq_num++; FF: you really mean this? */
+	pktgen_finalize_skb(pkt_dev, skb, datalen);
 
 	return skb;
 }
@@ -3884,6 +3834,8 @@ static int pktgen_remove_device(struct pktgen_thread *t,
 	free_SAs(pkt_dev);
 #endif
 	vfree(pkt_dev->flows);
+	if (pkt_dev->page)
+		put_page(pkt_dev->page);
 	kfree(pkt_dev);
 	return 0;
 }


