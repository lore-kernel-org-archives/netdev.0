From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 03/10] sfc: Expand/correct comments on
 collector behaviour and function usage
Date: Fri, 10 Dec 2010 17:38:25 +0000
Message-ID: <1292002705.11673.17.camel@bwh-desktop>
References: <1292002527.11673.14.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:26884 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753552Ab0LJRi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 12:38:28 -0500
In-Reply-To: <1292002527.11673.14.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Document exactly which registers and functions have special behaviour,
and why races on writes to descriptor pointers are safe.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/io.h |   98 +++++++++++++++++++++++++-------------------------
 1 files changed, 49 insertions(+), 49 deletions(-)

diff --git a/drivers/net/sfc/io.h b/drivers/net/sfc/io.h
index 85a99fe..0764e84 100644
--- a/drivers/net/sfc/io.h
+++ b/drivers/net/sfc/io.h
@@ -22,28 +22,39 @@
  *
  * Notes on locking strategy:
  *
- * Most NIC registers require 16-byte (or 8-byte, for SRAM) atomic writes
- * which necessitates locking.
- * Under normal operation few writes to NIC registers are made and these
- * registers (EVQ_RPTR_REG, RX_DESC_UPD_REG and TX_DESC_UPD_REG) are special
- * cased to allow 4-byte (hence lockless) accesses.
+ * Most CSRs are 128-bit (oword) and therefore cannot be read or
+ * written atomically.  Access from the host is buffered by the Bus
+ * Interface Unit (BIU).  Whenever the host reads from the lowest
+ * address of such a register, or from the address of a different such
+ * register, the BIU latches the register's value.  Subsequent reads
+ * from higher addresses of the same register will read the latched
+ * value.  Whenever the host writes part of such a register, the BIU
+ * collects the written value and does not write to the underlying
+ * register until all 4 dwords have been written.  A similar buffering
+ * scheme applies to host access to the NIC's 64-bit SRAM.
  *
- * It *is* safe to write to these 4-byte registers in the middle of an
- * access to an 8-byte or 16-byte register.  We therefore use a
- * spinlock to protect accesses to the larger registers, but no locks
- * for the 4-byte registers.
+ * Access to different CSRs and 64-bit SRAM words must be serialised,
+ * since interleaved access can result in lost writes or lost
+ * information from read-to-clear fields.  We use efx_nic::biu_lock
+ * for this.  (We could use separate locks for read and write, but
+ * this is not normally a performance bottleneck.)
  *
- * A write barrier is needed to ensure that DW3 is written after DW0/1/2
- * due to the way the 16byte registers are "collected" in the BIU.
+ * The DMA descriptor pointers (RX_DESC_UPD and TX_DESC_UPD) are
+ * 128-bit but are special-cased in the BIU to avoid the need for
+ * locking in the host:
  *
- * We also lock when carrying out reads, to ensure consistency of the
- * data (made possible since the BIU reads all 128 bits into a cache).
- * Reads are very rare, so this isn't a significant performance
- * impact.  (Most data transferred from NIC to host is DMAed directly
- * into host memory).
- *
- * I/O BAR access uses locks for both reads and writes (but is only provided
- * for testing purposes).
+ * - They are write-only.
+ * - The semantics of writing to these registers are such that
+ *   replacing the low 96 bits with zero does not affect functionality.
+ * - If the host writes to the last dword address of such a register
+ *   (i.e. the high 32 bits) the underlying register will always be
+ *   written.  If the collector does not hold values for the low 96
+ *   bits of the register, they will be written as zero.  Writing to
+ *   the last qword does not have this effect and must not be done.
+ * - If the host writes to the address of any other part of such a
+ *   register while the collector already holds values for some other
+ *   register, the write is discarded and the collector maintains its
+ *   current state.
  */
 
 #if BITS_PER_LONG == 64
@@ -72,7 +83,7 @@ static inline __le32 _efx_readd(struct efx_nic *efx, unsigned int reg)
 	return (__force __le32)__raw_readl(efx->membase + reg);
 }
 
-/* Writes to a normal 16-byte Efx register, locking as appropriate. */
+/* Write a normal 128-bit CSR, locking as appropriate. */
 static inline void efx_writeo(struct efx_nic *efx, efx_oword_t *value,
 			      unsigned int reg)
 {
@@ -98,8 +109,7 @@ static inline void efx_writeo(struct efx_nic *efx, efx_oword_t *value,
 	spin_unlock_irqrestore(&efx->biu_lock, flags);
 }
 
-/* Write an 8-byte NIC SRAM entry through the supplied mapping,
- * locking as appropriate. */
+/* Write 64-bit SRAM through the supplied mapping, locking as appropriate. */
 static inline void efx_sram_writeq(struct efx_nic *efx, void __iomem *membase,
 				   efx_qword_t *value, unsigned int index)
 {
@@ -122,29 +132,19 @@ static inline void efx_sram_writeq(struct efx_nic *efx, void __iomem *membase,
 	spin_unlock_irqrestore(&efx->biu_lock, flags);
 }
 
-/* Write dword to NIC register that allows partial writes
- *
- * Some registers (EVQ_RPTR_REG, RX_DESC_UPD_REG and
- * TX_DESC_UPD_REG) can be written to as a single dword.  This allows
- * for lockless writes.
- */
+/* Write a 32-bit CSR or the last dword of a special 128-bit CSR */
 static inline void efx_writed(struct efx_nic *efx, efx_dword_t *value,
 			      unsigned int reg)
 {
 	netif_vdbg(efx, hw, efx->net_dev,
-		   "writing partial register %x with "EFX_DWORD_FMT"\n",
+		   "writing register %x with "EFX_DWORD_FMT"\n",
 		   reg, EFX_DWORD_VAL(*value));
 
 	/* No lock required */
 	_efx_writed(efx, value->u32[0], reg);
 }
 
-/* Read from a NIC register
- *
- * This reads an entire 16-byte register in one go, locking as
- * appropriate.  It is essential to read the first dword first, as this
- * prompts the NIC to load the current value into the shadow register.
- */
+/* Read a 128-bit CSR, locking as appropriate. */
 static inline void efx_reado(struct efx_nic *efx, efx_oword_t *value,
 			     unsigned int reg)
 {
@@ -163,8 +163,7 @@ static inline void efx_reado(struct efx_nic *efx, efx_oword_t *value,
 		   EFX_OWORD_VAL(*value));
 }
 
-/* Read an 8-byte SRAM entry through supplied mapping,
- * locking as appropriate. */
+/* Read 64-bit SRAM through the supplied mapping, locking as appropriate. */
 static inline void efx_sram_readq(struct efx_nic *efx, void __iomem *membase,
 				  efx_qword_t *value, unsigned int index)
 {
@@ -186,7 +185,7 @@ static inline void efx_sram_readq(struct efx_nic *efx, void __iomem *membase,
 		   addr, EFX_QWORD_VAL(*value));
 }
 
-/* Read dword from register that allows partial writes (sic) */
+/* Read a 32-bit CSR or SRAM */
 static inline void efx_readd(struct efx_nic *efx, efx_dword_t *value,
 				unsigned int reg)
 {
@@ -196,28 +195,28 @@ static inline void efx_readd(struct efx_nic *efx, efx_dword_t *value,
 		   reg, EFX_DWORD_VAL(*value));
 }
 
-/* Write to a register forming part of a table */
+/* Write a 128-bit CSR forming part of a table */
 static inline void efx_writeo_table(struct efx_nic *efx, efx_oword_t *value,
 				      unsigned int reg, unsigned int index)
 {
 	efx_writeo(efx, value, reg + index * sizeof(efx_oword_t));
 }
 
-/* Read to a register forming part of a table */
+/* Read a 128-bit CSR forming part of a table */
 static inline void efx_reado_table(struct efx_nic *efx, efx_oword_t *value,
 				     unsigned int reg, unsigned int index)
 {
 	efx_reado(efx, value, reg + index * sizeof(efx_oword_t));
 }
 
-/* Write to a dword register forming part of a table */
+/* Write a 32-bit CSR forming part of a table, or 32-bit SRAM */
 static inline void efx_writed_table(struct efx_nic *efx, efx_dword_t *value,
 				       unsigned int reg, unsigned int index)
 {
 	efx_writed(efx, value, reg + index * sizeof(efx_oword_t));
 }
 
-/* Read from a dword register forming part of a table */
+/* Read a 32-bit CSR forming part of a table, or 32-bit SRAM */
 static inline void efx_readd_table(struct efx_nic *efx, efx_dword_t *value,
 				   unsigned int reg, unsigned int index)
 {
@@ -231,25 +230,26 @@ static inline void efx_readd_table(struct efx_nic *efx, efx_dword_t *value,
 #define EFX_PAGED_REG(page, reg) \
 	((page) * EFX_PAGE_BLOCK_SIZE + (reg))
 
-/* As for efx_writeo(), but for a page-mapped register. */
+/* Write the whole of RX_DESC_UPD or TX_DESC_UPD */
 static inline void efx_writeo_page(struct efx_nic *efx, efx_oword_t *value,
 				   unsigned int reg, unsigned int page)
 {
 	efx_writeo(efx, value, EFX_PAGED_REG(page, reg));
 }
 
-/* As for efx_writed(), but for a page-mapped register. */
+/* Write a page-mapped 32-bit CSR (EVQ_RPTR or the high bits of
+ * RX_DESC_UPD or TX_DESC_UPD)
+ */
 static inline void efx_writed_page(struct efx_nic *efx, efx_dword_t *value,
 				   unsigned int reg, unsigned int page)
 {
 	efx_writed(efx, value, EFX_PAGED_REG(page, reg));
 }
 
-/* Write dword to page-mapped register with an extra lock.
- *
- * As for efx_writed_page(), but for a register that suffers from
- * SFC bug 3181. Take out a lock so the BIU collector cannot be
- * confused. */
+/* Write TIMER_COMMAND.  This is a page-mapped 32-bit CSR, but a bug
+ * in the BIU means that writes to TIMER_COMMAND[0] invalidate the
+ * collector register.
+ */
 static inline void efx_writed_page_locked(struct efx_nic *efx,
 					  efx_dword_t *value,
 					  unsigned int reg,
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

