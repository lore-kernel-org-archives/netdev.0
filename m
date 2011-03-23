From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [RFC] myri10ge: small rx_done refactoring
Date: Wed, 23 Mar 2011 13:52:04 +0100
Message-ID: <20110323124939.GA7834@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Gallatin <gallatin@myri.com>, Brice Goglin <brice@myri.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58463 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932649Ab1CWMw2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2011 08:52:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

myri10ge: small rx_done refactoring

Add lro_enable variable to read NETIF_F_LRO flag only once per napi poll
call. This should fix theoretical race condition with
myri10ge_set_rx_csum() and myri10ge_set_flags() where flag NETIF_F_LRO
can be changed.

On the way reduce myri10ge_rx_done() number of arguments and calls by
moving mgp->small_bytes check into that function. That reduce code size

from:
   text	   data	    bss	    dec	    hex	filename
  36644	    248	    100	  36992	   9080	drivers/net/myri10ge/myri10ge.o

to:
   text	   data	    bss	    dec	    hex	filename
  36037	    247	    100	  36384	   8e20	drivers/net/myri10ge/myri10ge.o

on my i686 system, what should also make myri10ge_clean_rx_done()
being faster.

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 24386a8..2e71240 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1312,17 +1312,26 @@ myri10ge_unmap_rx_page(struct pci_dev *pdev,
 				 * page into an skb */
 
 static inline int
-myri10ge_rx_done(struct myri10ge_slice_state *ss, struct myri10ge_rx_buf *rx,
-		 int bytes, int len, __wsum csum)
+myri10ge_rx_done(struct myri10ge_slice_state *ss, int len, __wsum csum,
+		 bool lro_enabled)
 {
 	struct myri10ge_priv *mgp = ss->mgp;
 	struct sk_buff *skb;
 	struct skb_frag_struct rx_frags[MYRI10GE_MAX_FRAGS_PER_FRAME];
-	int i, idx, hlen, remainder;
+	struct myri10ge_rx_buf *rx;
+	int i, idx, hlen, remainder, bytes;
 	struct pci_dev *pdev = mgp->pdev;
 	struct net_device *dev = mgp->dev;
 	u8 *va;
 
+	if (len <= mgp->small_bytes) {
+		rx = &ss->rx_small;
+		bytes = mgp->small_bytes;
+	} else {
+		rx = &ss->rx_big,
+		bytes = mgp->big_bytes;
+	}
+
 	len += MXGEFW_PAD;
 	idx = rx->cnt & rx->mask;
 	va = page_address(rx->info[idx].page) + rx->info[idx].page_offset;
@@ -1341,7 +1350,7 @@ myri10ge_rx_done(struct myri10ge_slice_state *ss, struct myri10ge_rx_buf *rx,
 		remainder -= MYRI10GE_ALLOC_SIZE;
 	}
 
-	if (dev->features & NETIF_F_LRO) {
+	if (lro_enabled) {
 		rx_frags[0].page_offset += MXGEFW_PAD;
 		rx_frags[0].size -= MXGEFW_PAD;
 		len -= MXGEFW_PAD;
@@ -1464,6 +1473,7 @@ myri10ge_clean_rx_done(struct myri10ge_slice_state *ss, int budget)
 	struct myri10ge_rx_done *rx_done = &ss->rx_done;
 	struct myri10ge_priv *mgp = ss->mgp;
 	struct net_device *netdev = mgp->dev;
+	bool lro_enabled = (netdev->features & NETIF_F_LRO) ? true : false;
 	unsigned long rx_bytes = 0;
 	unsigned long rx_packets = 0;
 	unsigned long rx_ok;
@@ -1478,14 +1488,7 @@ myri10ge_clean_rx_done(struct myri10ge_slice_state *ss, int budget)
 		length = ntohs(rx_done->entry[idx].length);
 		rx_done->entry[idx].length = 0;
 		checksum = csum_unfold(rx_done->entry[idx].checksum);
-		if (length <= mgp->small_bytes)
-			rx_ok = myri10ge_rx_done(ss, &ss->rx_small,
-						 mgp->small_bytes,
-						 length, checksum);
-		else
-			rx_ok = myri10ge_rx_done(ss, &ss->rx_big,
-						 mgp->big_bytes,
-						 length, checksum);
+		rx_ok = myri10ge_rx_done(ss, length, checksum, lro_enabled);
 		rx_packets += rx_ok;
 		rx_bytes += rx_ok * (unsigned long)length;
 		cnt++;
@@ -1497,7 +1500,7 @@ myri10ge_clean_rx_done(struct myri10ge_slice_state *ss, int budget)
 	ss->stats.rx_packets += rx_packets;
 	ss->stats.rx_bytes += rx_bytes;
 
-	if (netdev->features & NETIF_F_LRO)
+	if (lro_enabled)
 		lro_flush_all(&rx_done->lro_mgr);
 
 	/* restock receive rings if needed */
