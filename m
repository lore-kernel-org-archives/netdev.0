From: James Morris <jmorris@intercode.com.au>
Subject: [PATCH] skb_headlen() cleanup
Date: Mon, 7 Apr 2003 02:34:34 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0304070230370.26415-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kuznet@ms2.inr.ac.ru, Jeff Garzik <jgarzik@pobox.com>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

A few bits of code in the drivers and networking are using:

  skb->len - skb->data_len

which is what skb_headlen() calculates.

The patch below (against recent 2.5 bk) converts these to use 
skb_headlen().

 drivers/net/8139cp.c         |    2 +-
 drivers/net/acenic.c         |    2 +-
 drivers/net/e100/e100_main.c |    4 ++--
 drivers/net/sungem.c         |    2 +-
 drivers/net/sunhme.c         |    2 +-
 drivers/net/tg3.c            |   12 ++++++------
 drivers/net/typhoon.c        |    2 +-
 net/core/datagram.c          |    4 ++--
 net/core/skbuff.c            |   10 +++++-----
 net/ipv4/tcp_output.c        |    2 +-
 net/xfrm/xfrm_algo.c         |    4 ++--
 11 files changed, 23 insertions(+), 23 deletions(-)


- James
-- 
James Morris
<jmorris@intercode.com.au>

diff -urN -X dontdiff bk.pending/drivers/net/8139cp.c bk.w2/drivers/net/8139cp.c
--- bk.pending/drivers/net/8139cp.c	Fri Apr  4 12:30:30 2003
+++ bk.w2/drivers/net/8139cp.c	Mon Apr  7 02:01:10 2003
@@ -826,7 +826,7 @@
 		 * Otherwise we could race with the device.
 		 */
 		first_eor = eor;
-		first_len = skb->len - skb->data_len;
+		first_len = skb_headlen(skb);
 		first_mapping = pci_map_single(cp->pdev, skb->data,
 					       first_len, PCI_DMA_TODEVICE);
 		cp->tx_skb[entry].skb = skb;
diff -urN -X dontdiff bk.pending/drivers/net/acenic.c bk.w2/drivers/net/acenic.c
--- bk.pending/drivers/net/acenic.c	Fri Apr  4 12:30:30 2003
+++ bk.w2/drivers/net/acenic.c	Mon Apr  7 02:04:17 2003
@@ -2829,7 +2829,7 @@
 		int i, len = 0;
 
 		mapping = ace_map_tx_skb(ap, skb, NULL, idx);
-		flagsize = ((skb->len - skb->data_len) << 16);
+		flagsize = (skb_headlen(skb) << 16);
 		if (skb->ip_summed == CHECKSUM_HW)
 			flagsize |= BD_FLG_TCP_UDP_SUM;
 #if ACENIC_DO_VLAN
diff -urN -X dontdiff bk.pending/drivers/net/e100/e100_main.c bk.w2/drivers/net/e100/e100_main.c
--- bk.pending/drivers/net/e100/e100_main.c	Fri Apr  4 12:30:33 2003
+++ bk.w2/drivers/net/e100/e100_main.c	Mon Apr  7 02:00:24 2003
@@ -2199,10 +2199,10 @@
 
 		(tcb->tbd_ptr)->tbd_buf_addr =
 			cpu_to_le32(pci_map_single(bdp->pdev, skb->data,
-						   (skb->len - skb->data_len),
+						   skb_headlen(skb),
 						   PCI_DMA_TODEVICE));
 		(tcb->tbd_ptr)->tbd_buf_cnt =
-			cpu_to_le16(skb->len - skb->data_len);
+			cpu_to_le16(skb_headlen(skb));
 
 		for (i = 0; i < skb_shinfo(skb)->nr_frags;
 		     i++, tbd_arr_ptr++, frag++) {
diff -urN -X dontdiff bk.pending/drivers/net/sungem.c bk.w2/drivers/net/sungem.c
--- bk.pending/drivers/net/sungem.c	Fri Apr  4 12:30:33 2003
+++ bk.w2/drivers/net/sungem.c	Mon Apr  7 02:02:18 2003
@@ -894,7 +894,7 @@
 		/* We must give this initial chunk to the device last.
 		 * Otherwise we could race with the device.
 		 */
-		first_len = skb->len - skb->data_len;
+		first_len = skb_headlen(skb);
 		first_mapping = pci_map_page(gp->pdev, virt_to_page(skb->data),
 					     ((unsigned long) skb->data & ~PAGE_MASK),
 					     first_len, PCI_DMA_TODEVICE);
diff -urN -X dontdiff bk.pending/drivers/net/sunhme.c bk.w2/drivers/net/sunhme.c
--- bk.pending/drivers/net/sunhme.c	Fri Apr  4 12:30:33 2003
+++ bk.w2/drivers/net/sunhme.c	Mon Apr  7 02:02:31 2003
@@ -2319,7 +2319,7 @@
 		/* We must give this initial chunk to the device last.
 		 * Otherwise we could race with the device.
 		 */
-		first_len = skb->len - skb->data_len;
+		first_len = skb_headlen(skb);
 		first_mapping = hme_dma_map(hp, skb->data, first_len, DMA_TODEVICE);
 		entry = NEXT_TX(entry);
 
diff -urN -X dontdiff bk.pending/drivers/net/tg3.c bk.w2/drivers/net/tg3.c
--- bk.pending/drivers/net/tg3.c	Fri Apr  4 12:30:33 2003
+++ bk.w2/drivers/net/tg3.c	Mon Apr  7 02:03:25 2003
@@ -1751,7 +1751,7 @@
 
 		pci_unmap_single(tp->pdev,
 				 pci_unmap_addr(ri, mapping),
-				 (skb->len - skb->data_len),
+				 skb_headlen(skb),
 				 PCI_DMA_TODEVICE);
 
 		ri->skb = NULL;
@@ -2316,7 +2316,7 @@
 		int len;
 
 		if (i == 0)
-			len = skb->len - skb->data_len;
+			len = skb_headlen(skb);
 		else
 			len = skb_shinfo(skb)->frags[i-1].size;
 		pci_unmap_single(tp->pdev,
@@ -2401,7 +2401,7 @@
 	int would_hit_hwbug;
 	unsigned long flags;
 
-	len = (skb->len - skb->data_len);
+	len = skb_headlen(skb);
 
 	/* No BH disabling for tx_lock here.  We are running in BH disabled
 	 * context and TX reclaim runs via tp->poll inside of a software
@@ -2520,7 +2520,7 @@
 		i = 0;
 		while (entry != last_plus_one) {
 			if (i == 0)
-				len = skb->len - skb->data_len;
+				len = skb_headlen(skb);
 			else
 				len = skb_shinfo(skb)->frags[i-1].size;
 
@@ -2593,7 +2593,7 @@
 	u32 len, entry, base_flags, mss;
 	unsigned long flags;
 
-	len = (skb->len - skb->data_len);
+	len = skb_headlen(skb);
 
 	/* No BH disabling for tx_lock here.  We are running in BH disabled
 	 * context and TX reclaim runs via tp->poll inside of a software
@@ -2829,7 +2829,7 @@
 
 		pci_unmap_single(tp->pdev,
 				 pci_unmap_addr(txp, mapping),
-				 (skb->len - skb->data_len),
+				 skb_headlen(skb),
 				 PCI_DMA_TODEVICE);
 		txp->skb = NULL;
 
diff -urN -X dontdiff bk.pending/drivers/net/typhoon.c bk.w2/drivers/net/typhoon.c
--- bk.pending/drivers/net/typhoon.c	Fri Apr  4 12:30:33 2003
+++ bk.w2/drivers/net/typhoon.c	Mon Apr  7 02:04:21 2003
@@ -844,7 +844,7 @@
 	} else {
 		int i, len;
 
-		len = skb->len - skb->data_len;
+		len = skb_headlen(skb);
 		skb_dma = pci_map_single(tp->tx_pdev, skb->data, len,
 				         PCI_DMA_TODEVICE);
 		txd->flags = TYPHOON_FRAG_DESC | TYPHOON_DESC_VALID;
diff -urN -X dontdiff bk.pending/net/core/datagram.c bk.w2/net/core/datagram.c
--- bk.pending/net/core/datagram.c	Fri Apr  4 12:31:09 2003
+++ bk.w2/net/core/datagram.c	Mon Apr  7 02:05:40 2003
@@ -220,7 +220,7 @@
 int skb_copy_datagram_iovec(const struct sk_buff *skb, int offset,
 			    struct iovec *to, int len)
 {
-	int start = skb->len - skb->data_len;
+	int start = skb_headlen(skb);
 	int i, copy = start - offset;
 
 	/* Copy header. */
@@ -295,7 +295,7 @@
 int skb_copy_and_csum_datagram(const struct sk_buff *skb, int offset,
 			       u8 *to, int len, unsigned int *csump)
 {
-	int start = skb->len - skb->data_len;
+	int start = skb_headlen(skb);
 	int pos = 0;
 	int i, copy = start - offset;
 
diff -urN -X dontdiff bk.pending/net/core/skbuff.c bk.w2/net/core/skbuff.c
--- bk.pending/net/core/skbuff.c	Fri Apr  4 12:31:09 2003
+++ bk.w2/net/core/skbuff.c	Mon Apr  7 02:06:02 2003
@@ -932,7 +932,7 @@
 int skb_copy_bits(const struct sk_buff *skb, int offset, void *to, int len)
 {
 	int i, copy;
-	int start = skb->len - skb->data_len;
+	int start = skb_headlen(skb);
 
 	if (offset > (int)skb->len - len)
 		goto fault;
@@ -1009,7 +1009,7 @@
 unsigned int skb_checksum(const struct sk_buff *skb, int offset,
 			  int len, unsigned int csum)
 {
-	int start = skb->len - skb->data_len;
+	int start = skb_headlen(skb);
 	int i, copy = start - offset;
 	int pos = 0;
 
@@ -1085,7 +1085,7 @@
 unsigned int skb_copy_and_csum_bits(const struct sk_buff *skb, int offset,
 				    u8 *to, int len, unsigned int csum)
 {
-	int start = skb->len - skb->data_len;
+	int start = skb_headlen(skb);
 	int i, copy = start - offset;
 	int pos = 0;
 
@@ -1170,9 +1170,9 @@
 	if (skb->ip_summed == CHECKSUM_HW)
 		csstart = skb->h.raw - skb->data;
 	else
-		csstart = skb->len - skb->data_len;
+		csstart = skb_headlen(skb);
 
-	if (csstart > skb->len - skb->data_len)
+	if (csstart > skb_headlen(skb))
 		BUG();
 
 	memcpy(to, skb->data, csstart);
diff -urN -X dontdiff bk.pending/net/ipv4/tcp_output.c bk.w2/net/ipv4/tcp_output.c
--- bk.pending/net/ipv4/tcp_output.c	Fri Apr  4 12:31:10 2003
+++ bk.w2/net/ipv4/tcp_output.c	Mon Apr  7 02:05:29 2003
@@ -354,7 +354,7 @@
 static void skb_split(struct sk_buff *skb, struct sk_buff *skb1, u32 len)
 {
 	int i;
-	int pos = skb->len - skb->data_len;
+	int pos = skb_headlen(skb);
 
 	if (len < pos) {
 		/* Split line is inside header. */
diff -urN -X dontdiff bk.pending/net/xfrm/xfrm_algo.c bk.w2/net/xfrm/xfrm_algo.c
--- bk.pending/net/xfrm/xfrm_algo.c	Fri Apr  4 12:31:11 2003
+++ bk.w2/net/xfrm/xfrm_algo.c	Mon Apr  7 02:05:48 2003
@@ -445,7 +445,7 @@
 void skb_icv_walk(const struct sk_buff *skb, struct crypto_tfm *tfm,
 		  int offset, int len, icv_update_fn_t icv_update)
 {
-	int start = skb->len - skb->data_len;
+	int start = skb_headlen(skb);
 	int i, copy = start - offset;
 	struct scatterlist sg;
 
@@ -521,7 +521,7 @@
 int
 skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
 {
-	int start = skb->len - skb->data_len;
+	int start = skb_headlen(skb);
 	int i, copy = start - offset;
 	int elt = 0;
 
