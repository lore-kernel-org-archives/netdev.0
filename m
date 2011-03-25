From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH] myri10ge: small rx_done refactoring
Date: Fri, 25 Mar 2011 12:21:51 +0100
Message-ID: <20110325112123.GA6218@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Gallatin <gallatin@myri.com>, Brice Goglin <brice@myri.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Howells <dhowells@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38272 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752317Ab1CYLWW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Mar 2011 07:22:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid theoretical race condition regarding accessing dev->features
NETIF_F_LRO flag, which is illustrated below.

CPU1					CPU2

myri10ge_clean_rx_done():		myri10ge_set_flags():
					or
					myri10ge_set_rx_csum():

if (dev->features & NETIF_F_LRO)
        setup lro
					dev->features |= NETIF_F_LRO
					or
					dev->features &= ~NETIF_F_LRO;
if (dev->features & NETIF_F_LRO)
        flush lro

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

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
Thanks to Stephen, David and Ben for pointing missing ACCESS_ONCE() issue
and teach me multi-thread programming.

 drivers/net/myri10ge/myri10ge.c |   37 +++++++++++++++++++++++--------------
 1 files changed, 23 insertions(+), 14 deletions(-)

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index a7f2eed..4023363 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1312,17 +1312,26 @@ myri10ge_unmap_rx_page(struct pci_dev *pdev,
 				 * page into an skb */
 
 static inline int
-myri10ge_rx_done(struct myri10ge_slice_state *ss, struct myri10ge_rx_buf *rx,
-		 int bytes, int len, __wsum csum)
+myri10ge_rx_done(struct myri10ge_slice_state *ss, int len, __wsum csum,
+		 int lro_enabled)
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
+		rx = &ss->rx_big;
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
@@ -1463,7 +1472,7 @@ myri10ge_clean_rx_done(struct myri10ge_slice_state *ss, int budget)
 {
 	struct myri10ge_rx_done *rx_done = &ss->rx_done;
 	struct myri10ge_priv *mgp = ss->mgp;
-	struct net_device *netdev = mgp->dev;
+
 	unsigned long rx_bytes = 0;
 	unsigned long rx_packets = 0;
 	unsigned long rx_ok;
@@ -1474,18 +1483,18 @@ myri10ge_clean_rx_done(struct myri10ge_slice_state *ss, int budget)
 	u16 length;
 	__wsum checksum;
 
+	/*
+	 * Prevent compiler from generating more than one ->features memory
+	 * access to avoid theoretical race condition with functions that
+	 * change NETIF_F_LRO flag at runtime.
+	 */
+	bool lro_enabled = ACCESS_ONCE(mgp->dev->features) & NETIF_F_LRO;
+
 	while (rx_done->entry[idx].length != 0 && work_done < budget) {
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
@@ -1497,7 +1506,7 @@ myri10ge_clean_rx_done(struct myri10ge_slice_state *ss, int budget)
 	ss->stats.rx_packets += rx_packets;
 	ss->stats.rx_bytes += rx_bytes;
 
-	if (netdev->features & NETIF_F_LRO)
+	if (lro_enabled)
 		lro_flush_all(&rx_done->lro_mgr);
 
 	/* restock receive rings if needed */
-- 
1.7.1

