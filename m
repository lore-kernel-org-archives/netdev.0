From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] net: mac8390 - Sort out memory/MMIO accesses and casts
Date: Wed,  2 Jun 2010 19:36:20 +0200
Message-ID: <1275500180-32640-1-git-send-email-geert@linux-m68k.org>
Cc: netdev@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from gerard.telenet-ops.be ([195.130.132.48]:50882 "EHLO
	gerard.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757999Ab0FBRl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 13:41:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 5c7fffd0e3b57cb63f50bbd710868f012d67654f ("drivers/net/mac8390.c: Remove
useless memcpy casting") removed too many casts, introducing the following
warnings:

| drivers/net/mac8390.c:248: warning: passing argument 1 of '__builtin_memcpy' makes pointer from integer without a cast
| drivers/net/mac8390.c:253: warning: passing argument 1 of 'word_memcpy_tocard' makes pointer from integer without a cast
| drivers/net/mac8390.c:255: warning: passing argument 2 of 'word_memcpy_fromcard' makes pointer from integer without a cast

Instead of just readding the casts,
  - move all casts inside word_memcpy_{to,from}card(),
  - replace an incorrect memcpy() by memcpy_toio(),
  - add memcmp_withio() as a wrapper around memcmp(),
  - replace an incorrect memcpy_toio() by memcpy_fromio().

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
Tested-by: Finn Thain <fthain@telegraphics.com.au>
---
 drivers/net/mac8390.c |   44 ++++++++++++++++++++++----------------------
 1 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/drivers/net/mac8390.c b/drivers/net/mac8390.c
index 1136c9a..c7476a4 100644
--- a/drivers/net/mac8390.c
+++ b/drivers/net/mac8390.c
@@ -157,6 +157,8 @@ static void dayna_block_output(struct net_device *dev, int count,
 #define memcpy_fromio(a, b, c)	memcpy((a), (void *)(b), (c))
 #define memcpy_toio(a, b, c)	memcpy((void *)(a), (b), (c))
 
+#define memcmp_withio(a, b, c)	memcmp((a), (void *)(b), (c))
+
 /* Slow Sane (16-bit chunk memory read/write) Cabletron uses this */
 static void slow_sane_get_8390_hdr(struct net_device *dev,
 				   struct e8390_pkt_hdr *hdr, int ring_page);
@@ -164,8 +166,8 @@ static void slow_sane_block_input(struct net_device *dev, int count,
 				  struct sk_buff *skb, int ring_offset);
 static void slow_sane_block_output(struct net_device *dev, int count,
 				   const unsigned char *buf, int start_page);
-static void word_memcpy_tocard(void *tp, const void *fp, int count);
-static void word_memcpy_fromcard(void *tp, const void *fp, int count);
+static void word_memcpy_tocard(unsigned long tp, const void *fp, int count);
+static void word_memcpy_fromcard(void *tp, unsigned long fp, int count);
 
 static enum mac8390_type __init mac8390_ident(struct nubus_dev *dev)
 {
@@ -245,9 +247,9 @@ static enum mac8390_access __init mac8390_testio(volatile unsigned long membase)
 	unsigned long outdata = 0xA5A0B5B0;
 	unsigned long indata =  0x00000000;
 	/* Try writing 32 bits */
-	memcpy(membase, &outdata, 4);
+	memcpy_toio(membase, &outdata, 4);
 	/* Now compare them */
-	if (memcmp((char *)&outdata, (char *)membase, 4) == 0)
+	if (memcmp_withio(&outdata, membase, 4) == 0)
 		return ACCESS_32;
 	/* Write 16 bit output */
 	word_memcpy_tocard(membase, &outdata, 4);
@@ -731,7 +733,7 @@ static void sane_get_8390_hdr(struct net_device *dev,
 			      struct e8390_pkt_hdr *hdr, int ring_page)
 {
 	unsigned long hdr_start = (ring_page - WD_START_PG)<<8;
-	memcpy_fromio((void *)hdr, (char *)dev->mem_start + hdr_start, 4);
+	memcpy_fromio(hdr, dev->mem_start + hdr_start, 4);
 	/* Fix endianness */
 	hdr->count = swab16(hdr->count);
 }
@@ -745,14 +747,13 @@ static void sane_block_input(struct net_device *dev, int count,
 	if (xfer_start + count > ei_status.rmem_end) {
 		/* We must wrap the input move. */
 		int semi_count = ei_status.rmem_end - xfer_start;
-		memcpy_fromio(skb->data, (char *)dev->mem_start + xfer_base,
+		memcpy_fromio(skb->data, dev->mem_start + xfer_base,
 			      semi_count);
 		count -= semi_count;
-		memcpy_toio(skb->data + semi_count,
-			    (char *)ei_status.rmem_start, count);
-	} else {
-		memcpy_fromio(skb->data, (char *)dev->mem_start + xfer_base,
+		memcpy_fromio(skb->data + semi_count, ei_status.rmem_start,
 			      count);
+	} else {
+		memcpy_fromio(skb->data, dev->mem_start + xfer_base, count);
 	}
 }
 
@@ -761,7 +762,7 @@ static void sane_block_output(struct net_device *dev, int count,
 {
 	long shmem = (start_page - WD_START_PG)<<8;
 
-	memcpy_toio((char *)dev->mem_start + shmem, buf, count);
+	memcpy_toio(dev->mem_start + shmem, buf, count);
 }
 
 /* dayna block input/output */
@@ -812,7 +813,7 @@ static void slow_sane_get_8390_hdr(struct net_device *dev,
 				   int ring_page)
 {
 	unsigned long hdr_start = (ring_page - WD_START_PG)<<8;
-	word_memcpy_fromcard(hdr, (char *)dev->mem_start + hdr_start, 4);
+	word_memcpy_fromcard(hdr, dev->mem_start + hdr_start, 4);
 	/* Register endianism - fix here rather than 8390.c */
 	hdr->count = (hdr->count&0xFF)<<8|(hdr->count>>8);
 }
@@ -826,15 +827,14 @@ static void slow_sane_block_input(struct net_device *dev, int count,
 	if (xfer_start + count > ei_status.rmem_end) {
 		/* We must wrap the input move. */
 		int semi_count = ei_status.rmem_end - xfer_start;
-		word_memcpy_fromcard(skb->data,
-				     (char *)dev->mem_start + xfer_base,
+		word_memcpy_fromcard(skb->data, dev->mem_start + xfer_base,
 				     semi_count);
 		count -= semi_count;
 		word_memcpy_fromcard(skb->data + semi_count,
-				     (char *)ei_status.rmem_start, count);
+				     ei_status.rmem_start, count);
 	} else {
-		word_memcpy_fromcard(skb->data,
-				     (char *)dev->mem_start + xfer_base, count);
+		word_memcpy_fromcard(skb->data, dev->mem_start + xfer_base,
+				     count);
 	}
 }
 
@@ -843,12 +843,12 @@ static void slow_sane_block_output(struct net_device *dev, int count,
 {
 	long shmem = (start_page - WD_START_PG)<<8;
 
-	word_memcpy_tocard((char *)dev->mem_start + shmem, buf, count);
+	word_memcpy_tocard(dev->mem_start + shmem, buf, count);
 }
 
-static void word_memcpy_tocard(void *tp, const void *fp, int count)
+static void word_memcpy_tocard(unsigned long tp, const void *fp, int count)
 {
-	volatile unsigned short *to = tp;
+	volatile unsigned short *to = (void *)tp;
 	const unsigned short *from = fp;
 
 	count++;
@@ -858,10 +858,10 @@ static void word_memcpy_tocard(void *tp, const void *fp, int count)
 		*to++ = *from++;
 }
 
-static void word_memcpy_fromcard(void *tp, const void *fp, int count)
+static void word_memcpy_fromcard(void *tp, unsigned long fp, int count)
 {
 	unsigned short *to = tp;
-	const volatile unsigned short *from = fp;
+	const volatile unsigned short *from = (const void *)fp;
 
 	count++;
 	count /= 2;
-- 
1.7.0.4

