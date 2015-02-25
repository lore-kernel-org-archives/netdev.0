From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net] cxgb4: Fix PCI-E Memory window interface for big-endian systems
Date: Wed, 25 Feb 2015 16:50:04 +0530
Message-ID: <1424863204-12580-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:5718 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751866AbbBYLOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 06:14:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When doing reads and writes to adapter memory via the PCI-E Memory Window
interface, data gets swizzled on 4-byte boundaries on Big-Endian systems
because we need to account for the register read/write interface which
incorporates a swizzle onto the Little-Endian PCI-E Bus.

Based on original work by Casey Leedom <leedom@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c |   54 ++++++++++++++++++++++-----
 2 files changed, 45 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index d6cda17..97842d0 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1103,7 +1103,7 @@ int t4_restart_aneg(struct adapter *adap, unsigned int mbox, unsigned int port);
 #define T4_MEMORY_WRITE	0
 #define T4_MEMORY_READ	1
 int t4_memory_rw(struct adapter *adap, int win, int mtype, u32 addr, u32 len,
-		 __be32 *buf, int dir);
+		 void *buf, int dir);
 static inline int t4_memory_write(struct adapter *adap, int mtype, u32 addr,
 				  u32 len, __be32 *buf)
 {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 4d643b6..853c389 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -449,7 +449,7 @@ int t4_edc_read(struct adapter *adap, int idx, u32 addr, __be32 *data, u64 *ecc)
  *	@mtype: memory type: MEM_EDC0, MEM_EDC1 or MEM_MC
  *	@addr: address within indicated memory type
  *	@len: amount of memory to transfer
- *	@buf: host memory buffer
+ *	@hbuf: host memory buffer
  *	@dir: direction of transfer T4_MEMORY_READ (1) or T4_MEMORY_WRITE (0)
  *
  *	Reads/writes an [almost] arbitrary memory region in the firmware: the
@@ -460,15 +460,17 @@ int t4_edc_read(struct adapter *adap, int idx, u32 addr, __be32 *data, u64 *ecc)
  *	caller's responsibility to perform appropriate byte order conversions.
  */
 int t4_memory_rw(struct adapter *adap, int win, int mtype, u32 addr,
-		 u32 len, __be32 *buf, int dir)
+		 u32 len, void *hbuf, int dir)
 {
 	u32 pos, offset, resid, memoffset;
 	u32 edc_size, mc_size, win_pf, mem_reg, mem_aperture, mem_base;
+	u32 *buf;
 
 	/* Argument sanity checks ...
 	 */
-	if (addr & 0x3)
+	if (addr & 0x3 || (uintptr_t)hbuf & 0x3)
 		return -EINVAL;
+	buf = (u32 *)hbuf;
 
 	/* It's convenient to be able to handle lengths which aren't a
 	 * multiple of 32-bits because we often end up transferring files to
@@ -532,14 +534,45 @@ int t4_memory_rw(struct adapter *adap, int win, int mtype, u32 addr,
 
 	/* Transfer data to/from the adapter as long as there's an integral
 	 * number of 32-bit transfers to complete.
+	 *
+	 * A note on Endianness issues:
+	 *
+	 * The "register" reads and writes below from/to the PCI-E Memory
+	 * Window invoke the standard adapter Big-Endian to PCI-E Link
+	 * Little-Endian "swizzel."  As a result, if we have the following
+	 * data in adapter memory:
+	 *
+	 *     Memory:  ... | b0 | b1 | b2 | b3 | ...
+	 *     Address:      i+0  i+1  i+2  i+3
+	 *
+	 * Then a read of the adapter memory via the PCI-E Memory Window
+	 * will yield:
+	 *
+	 *     x = readl(i)
+	 *         31                  0
+	 *         [ b3 | b2 | b1 | b0 ]
+	 *
+	 * If this value is stored into local memory on a Little-Endian system
+	 * it will show up correctly in local memory as:
+	 *
+	 *     ( ..., b0, b1, b2, b3, ... )
+	 *
+	 * But on a Big-Endian system, the store will show up in memory
+	 * incorrectly swizzled as:
+	 *
+	 *     ( ..., b3, b2, b1, b0, ... )
+	 *
+	 * So we need to account for this in the reads and writes to the
+	 * PCI-E Memory Window below by undoing the register read/write
+	 * swizzels.
 	 */
 	while (len > 0) {
 		if (dir == T4_MEMORY_READ)
-			*buf++ = (__force __be32) t4_read_reg(adap,
-							mem_base + offset);
+			*buf++ = le32_to_cpu((__force __le32)t4_read_reg(adap,
+						mem_base + offset));
 		else
 			t4_write_reg(adap, mem_base + offset,
-				     (__force u32) *buf++);
+				     (__force u32)cpu_to_le32(*buf++));
 		offset += sizeof(__be32);
 		len -= sizeof(__be32);
 
@@ -568,15 +601,16 @@ int t4_memory_rw(struct adapter *adap, int win, int mtype, u32 addr,
 	 */
 	if (resid) {
 		union {
-			__be32 word;
+			u32 word;
 			char byte[4];
 		} last;
 		unsigned char *bp;
 		int i;
 
 		if (dir == T4_MEMORY_READ) {
-			last.word = (__force __be32) t4_read_reg(adap,
-							mem_base + offset);
+			last.word = le32_to_cpu(
+					(__force __le32)t4_read_reg(adap,
+						mem_base + offset));
 			for (bp = (unsigned char *)buf, i = resid; i < 4; i++)
 				bp[i] = last.byte[i];
 		} else {
@@ -584,7 +618,7 @@ int t4_memory_rw(struct adapter *adap, int win, int mtype, u32 addr,
 			for (i = resid; i < 4; i++)
 				last.byte[i] = 0;
 			t4_write_reg(adap, mem_base + offset,
-				     (__force u32) last.word);
+				     (__force u32)cpu_to_le32(last.word));
 		}
 	}
 
-- 
1.7.1
