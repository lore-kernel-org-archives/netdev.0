From: jamal <hadi@cyberus.ca>
Subject: [PKTGEN] Centralize packet overhead tracking
Date: Sat, 09 Jun 2007 10:15:26 -0400
Message-ID: <1181398526.4077.13.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Lhqor1U/oY5y9ph3jSHl"
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:18205 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773AbXFIOPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2007 10:15:30 -0400
Received: by py-out-1112.google.com with SMTP id a29so1751361pyi
        for <netdev@vger.kernel.org>; Sat, 09 Jun 2007 07:15:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Lhqor1U/oY5y9ph3jSHl
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

1 of 4.

cheers,
jamal


--=-Lhqor1U/oY5y9ph3jSHl
Content-Disposition: attachment; filename=pg-ovh1
Content-Type: text/plain; name=pg-ovh1; charset=us-ascii
Content-Transfer-Encoding: 7bit

commit f7da845f37e3cd47be46697491210c126b37c8fc
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Sat Jun 9 09:11:16 2007 -0400

    [PKTGEN] Centralize packet overhead tracking
    Track the extra packet overhead for VLAN tags, MPLS, IPSEC etc
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 9cd3a1c..1352316 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -228,6 +228,7 @@ struct pktgen_dev {
 
 	int min_pkt_size;	/* = ETH_ZLEN; */
 	int max_pkt_size;	/* = ETH_ZLEN; */
+	int pkt_overhead;	/* overhead for MPLS, VLANs, IPSEC etc */
 	int nfrags;
 	__u32 delay_us;		/* Default delay */
 	__u32 delay_ns;
@@ -2075,6 +2076,13 @@ static void spin(struct pktgen_dev *pkt_dev, __u64 spin_until_us)
 	pkt_dev->idle_acc += now - start;
 }
 
+static inline void set_pkt_overhead(struct pktgen_dev *pkt_dev)
+{
+	pkt_dev->pkt_overhead += pkt_dev->nr_labels*sizeof(u32);
+	pkt_dev->pkt_overhead += VLAN_TAG_SIZE(pkt_dev);
+	pkt_dev->pkt_overhead += SVLAN_TAG_SIZE(pkt_dev);
+}
+
 /* Increment/randomize headers according to flags and current values
  * for IP src/dest, UDP src/dst port, MAC-Addr src/dst
  */
@@ -2323,9 +2331,7 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 
 	datalen = (odev->hard_header_len + 16) & ~0xf;
 	skb = alloc_skb(pkt_dev->cur_pkt_size + 64 + datalen +
-			pkt_dev->nr_labels*sizeof(u32) +
-			VLAN_TAG_SIZE(pkt_dev) + SVLAN_TAG_SIZE(pkt_dev),
-			GFP_ATOMIC);
+			pkt_dev->pkt_overhead, GFP_ATOMIC);
 	if (!skb) {
 		sprintf(pkt_dev->result, "No memory");
 		return NULL;
@@ -2368,7 +2374,7 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 
 	/* Eth + IPh + UDPh + mpls */
 	datalen = pkt_dev->cur_pkt_size - 14 - 20 - 8 -
-		  pkt_dev->nr_labels*sizeof(u32) - VLAN_TAG_SIZE(pkt_dev) - SVLAN_TAG_SIZE(pkt_dev);
+		  pkt_dev->pkt_overhead;
 	if (datalen < sizeof(struct pktgen_hdr))
 		datalen = sizeof(struct pktgen_hdr);
 
@@ -2391,8 +2397,7 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 	iph->check = ip_fast_csum((void *)iph, iph->ihl);
 	skb->protocol = protocol;
 	skb->mac_header = (skb->network_header - ETH_HLEN -
-			   pkt_dev->nr_labels * sizeof(u32) -
-			   VLAN_TAG_SIZE(pkt_dev) - SVLAN_TAG_SIZE(pkt_dev));
+			   pkt_dev->pkt_overhead);
 	skb->dev = odev;
 	skb->pkt_type = PACKET_HOST;
 
@@ -2662,9 +2667,7 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 	mod_cur_headers(pkt_dev);
 
 	skb = alloc_skb(pkt_dev->cur_pkt_size + 64 + 16 +
-			pkt_dev->nr_labels*sizeof(u32) +
-			VLAN_TAG_SIZE(pkt_dev) + SVLAN_TAG_SIZE(pkt_dev),
-			GFP_ATOMIC);
+			pkt_dev->pkt_overhead, GFP_ATOMIC);
 	if (!skb) {
 		sprintf(pkt_dev->result, "No memory");
 		return NULL;
@@ -2708,7 +2711,7 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 	/* Eth + IPh + UDPh + mpls */
 	datalen = pkt_dev->cur_pkt_size - 14 -
 		  sizeof(struct ipv6hdr) - sizeof(struct udphdr) -
-		  pkt_dev->nr_labels*sizeof(u32) - VLAN_TAG_SIZE(pkt_dev) - SVLAN_TAG_SIZE(pkt_dev);
+		  pkt_dev->pkt_overhead;
 
 	if (datalen < sizeof(struct pktgen_hdr)) {
 		datalen = sizeof(struct pktgen_hdr);
@@ -2738,8 +2741,7 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 	ipv6_addr_copy(&iph->saddr, &pkt_dev->cur_in6_saddr);
 
 	skb->mac_header = (skb->network_header - ETH_HLEN -
-			   pkt_dev->nr_labels * sizeof(u32) -
-			   VLAN_TAG_SIZE(pkt_dev) - SVLAN_TAG_SIZE(pkt_dev));
+			   pkt_dev->pkt_overhead);
 	skb->protocol = protocol;
 	skb->dev = odev;
 	skb->pkt_type = PACKET_HOST;
@@ -2857,6 +2859,7 @@ static void pktgen_run(struct pktgen_thread *t)
 			pkt_dev->started_at = getCurUs();
 			pkt_dev->next_tx_us = getCurUs();	/* Transmit immediately */
 			pkt_dev->next_tx_ns = 0;
+			set_pkt_overhead(pkt_dev);
 
 			strcpy(pkt_dev->result, "Starting");
 			started++;

--=-Lhqor1U/oY5y9ph3jSHl--

