From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/16] i40e/i40evf: Factor out L4 header and checksum from L3 bits in TSO path
Date: Thu, 18 Feb 2016 16:31:08 -0800
Message-ID: <1455841881-128892-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455841881-128892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49646 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965452AbcBSAbZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 19:31:25 -0500
In-Reply-To: <1455841881-128892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

This patch makes it so that the L4 header offsets and such can be ignored
when dealing with the L3 checksum and length update.  This is done making
use of two things.

First we can just use the offset from the L4 header to the start of the
packet to determine the L4 offset, and from that we can then make use of
the data offset to determine the full length of the headers.

As far as adjusting the checksum to remove the length we can simply add the
inverse of the length instead of having to recompute the entire
pseudo-header without the length.  In the case of an IPv6 header this
should be significantly cheaper since we can make use of a value we already
needed instead of having to read the source and destination address out of
the packet.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 31 ++++++++++++++++-----------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 31 ++++++++++++++++-----------
 2 files changed, 36 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 5e82589..ce0234e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2269,9 +2269,12 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
 {
 	u64 cd_cmd, cd_tso_len, cd_mss;
 	struct ipv6hdr *ipv6h;
-	struct tcphdr *tcph;
 	struct iphdr *iph;
-	u32 l4len;
+	union {
+		struct tcphdr *tcp;
+		unsigned char *hdr;
+	} l4;
+	u32 paylen, l4_offset;
 	int err;
 
 	if (skb->ip_summed != CHECKSUM_PARTIAL)
@@ -2286,24 +2289,26 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
 
 	iph = skb->encapsulation ? inner_ip_hdr(skb) : ip_hdr(skb);
 	ipv6h = skb->encapsulation ? inner_ipv6_hdr(skb) : ipv6_hdr(skb);
+	l4.hdr = skb->encapsulation ? skb_inner_transport_header(skb) :
+				      skb_transport_header(skb);
 
 	if (iph->version == 4) {
-		tcph = skb->encapsulation ? inner_tcp_hdr(skb) : tcp_hdr(skb);
 		iph->tot_len = 0;
 		iph->check = 0;
-		tcph->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
-						 0, IPPROTO_TCP, 0);
-	} else if (ipv6h->version == 6) {
-		tcph = skb->encapsulation ? inner_tcp_hdr(skb) : tcp_hdr(skb);
+	} else {
 		ipv6h->payload_len = 0;
-		tcph->check = ~csum_ipv6_magic(&ipv6h->saddr, &ipv6h->daddr,
-					       0, IPPROTO_TCP, 0);
 	}
 
-	l4len = skb->encapsulation ? inner_tcp_hdrlen(skb) : tcp_hdrlen(skb);
-	*hdr_len = (skb->encapsulation
-		    ? (skb_inner_transport_header(skb) - skb->data)
-		    : skb_transport_offset(skb)) + l4len;
+	/* determine offset of inner transport header */
+	l4_offset = l4.hdr - skb->data;
+
+	/* remove payload length from inner checksum */
+	paylen = (__force u16)l4.tcp->check;
+	paylen += ntohs(1) * (u16)~(skb->len - l4_offset);
+	l4.tcp->check = ~csum_fold((__force __wsum)paylen);
+
+	/* compute length of segmentation header */
+	*hdr_len = (l4.tcp->doff * 4) + l4_offset;
 
 	/* find the field values */
 	cd_cmd = I40E_TX_CTX_DESC_TSO;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index c5f98cb..881d0ad 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1529,9 +1529,12 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
 {
 	u64 cd_cmd, cd_tso_len, cd_mss;
 	struct ipv6hdr *ipv6h;
-	struct tcphdr *tcph;
 	struct iphdr *iph;
-	u32 l4len;
+	union {
+		struct tcphdr *tcp;
+		unsigned char *hdr;
+	} l4;
+	u32 paylen, l4_offset;
 	int err;
 
 	if (skb->ip_summed != CHECKSUM_PARTIAL)
@@ -1546,24 +1549,26 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
 
 	iph = skb->encapsulation ? inner_ip_hdr(skb) : ip_hdr(skb);
 	ipv6h = skb->encapsulation ? inner_ipv6_hdr(skb) : ipv6_hdr(skb);
+	l4.hdr = skb->encapsulation ? skb_inner_transport_header(skb) :
+				      skb_transport_header(skb);
 
 	if (iph->version == 4) {
-		tcph = skb->encapsulation ? inner_tcp_hdr(skb) : tcp_hdr(skb);
 		iph->tot_len = 0;
 		iph->check = 0;
-		tcph->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
-						 0, IPPROTO_TCP, 0);
-	} else if (ipv6h->version == 6) {
-		tcph = skb->encapsulation ? inner_tcp_hdr(skb) : tcp_hdr(skb);
+	} else {
 		ipv6h->payload_len = 0;
-		tcph->check = ~csum_ipv6_magic(&ipv6h->saddr, &ipv6h->daddr,
-					       0, IPPROTO_TCP, 0);
 	}
 
-	l4len = skb->encapsulation ? inner_tcp_hdrlen(skb) : tcp_hdrlen(skb);
-	*hdr_len = (skb->encapsulation
-		    ? (skb_inner_transport_header(skb) - skb->data)
-		    : skb_transport_offset(skb)) + l4len;
+	/* determine offset of inner transport header */
+	l4_offset = l4.hdr - skb->data;
+
+	/* remove payload length from inner checksum */
+	paylen = (__force u16)l4.tcp->check;
+	paylen += ntohs(1) * (u16)~(skb->len - l4_offset);
+	l4.tcp->check = ~csum_fold((__force __wsum)paylen);
+
+	/* compute length of segmentation header */
+	*hdr_len = (l4.tcp->doff * 4) + l4_offset;
 
 	/* find the field values */
 	cd_cmd = I40E_TX_CTX_DESC_TSO;
-- 
2.5.0
