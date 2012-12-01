From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 06/13] sfc: Remove confusing MMIO functions
Date: Sat, 1 Dec 2012 04:42:29 +0000
Message-ID: <1354336949.2640.45.camel@bwh-desktop.uk.solarflarecom.com>
References: <1354336821.2640.39.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:26151 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751928Ab2LAEmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 23:42:32 -0500
In-Reply-To: <1354336821.2640.39.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

efx_writed_table() uses a step of 16 bytes but efx_readd_table() uses
a step of 4 bytes.  Why are they different?

Firstly, register access is asymmetric:

- The EVQ_RPTR table and RX_INDIRECTION_TBL can (or must?) be written
  as dwords even though they have a step size of 16 bytes, unlike
  most other CSRs.
- In general, a read of any width is valid for registers, so long as
  it does not cross register boundaries.  There is also no latching
  behaviour in the BIU, contrary to rumour.

We write to the EVQ_RPTR table with efx_writed_table() but never read
it back as it's write-only.  We write to the RX_INDIRECTION_TBL with
efx_writed_table(), but only read it back for the register dump, where
we use efx_reado_table() as for any other table with step size of 16.

We read MC_TREG_SMEM with efx_readd_table() for the register dump, but
normally read and write it with efx_readd() and efx_writed() using
offsets calculated in bytes.

Since these functions are trivial and have few callers, it's clearer
to open-code them at the call sites.  While we're at it, update the
comments on the BIU behaviour again.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/io.h          |   43 ++++++++++---------------------
 drivers/net/ethernet/sfc/nic.c         |   19 +++++++++----
 drivers/net/ethernet/sfc/siena_sriov.c |    2 +-
 3 files changed, 28 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/sfc/io.h b/drivers/net/ethernet/sfc/io.h
index 751d1ec..96759ae 100644
--- a/drivers/net/ethernet/sfc/io.h
+++ b/drivers/net/ethernet/sfc/io.h
@@ -22,22 +22,21 @@
  *
  * Notes on locking strategy:
  *
- * Most CSRs are 128-bit (oword) and therefore cannot be read or
- * written atomically.  Access from the host is buffered by the Bus
- * Interface Unit (BIU).  Whenever the host reads from the lowest
- * address of such a register, or from the address of a different such
- * register, the BIU latches the register's value.  Subsequent reads
- * from higher addresses of the same register will read the latched
- * value.  Whenever the host writes part of such a register, the BIU
- * collects the written value and does not write to the underlying
- * register until all 4 dwords have been written.  A similar buffering
- * scheme applies to host access to the NIC's 64-bit SRAM.
+ * Many CSRs are very wide and cannot be read or written atomically.
+ * Writes from the host are buffered by the Bus Interface Unit (BIU)
+ * up to 128 bits.  Whenever the host writes part of such a register,
+ * the BIU collects the written value and does not write to the
+ * underlying register until all 4 dwords have been written.  A
+ * similar buffering scheme applies to host access to the NIC's 64-bit
+ * SRAM.
  *
- * Access to different CSRs and 64-bit SRAM words must be serialised,
- * since interleaved access can result in lost writes or lost
- * information from read-to-clear fields.  We use efx_nic::biu_lock
- * for this.  (We could use separate locks for read and write, but
- * this is not normally a performance bottleneck.)
+ * Writes to different CSRs and 64-bit SRAM words must be serialised,
+ * since interleaved access can result in lost writes.  We use
+ * efx_nic::biu_lock for this.
+ *
+ * We also serialise reads from 128-bit CSRs and SRAM with the same
+ * spinlock.  This may not be necessary, but it doesn't really matter
+ * as there are no such reads on the fast path.
  *
  * The DMA descriptor pointers (RX_DESC_UPD and TX_DESC_UPD) are
  * 128-bit but are special-cased in the BIU to avoid the need for
@@ -204,20 +203,6 @@ static inline void efx_reado_table(struct efx_nic *efx, efx_oword_t *value,
 	efx_reado(efx, value, reg + index * sizeof(efx_oword_t));
 }
 
-/* Write a 32-bit CSR forming part of a table, or 32-bit SRAM */
-static inline void efx_writed_table(struct efx_nic *efx, efx_dword_t *value,
-				       unsigned int reg, unsigned int index)
-{
-	efx_writed(efx, value, reg + index * sizeof(efx_oword_t));
-}
-
-/* Read a 32-bit CSR forming part of a table, or 32-bit SRAM */
-static inline void efx_readd_table(struct efx_nic *efx, efx_dword_t *value,
-				   unsigned int reg, unsigned int index)
-{
-	efx_readd(efx, value, reg + index * sizeof(efx_dword_t));
-}
-
 /* Page-mapped register block size */
 #define EFX_PAGE_BLOCK_SIZE 0x2000
 
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index e10b7ec..368659d 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -765,8 +765,13 @@ void efx_nic_eventq_read_ack(struct efx_channel *channel)
 
 	EFX_POPULATE_DWORD_1(reg, FRF_AZ_EVQ_RPTR,
 			     channel->eventq_read_ptr & channel->eventq_mask);
-	efx_writed_table(efx, &reg, efx->type->evq_rptr_tbl_base,
-			 channel->channel);
+
+	/* For Falcon A1, EVQ_RPTR_KER is documented as having a step size
+	 * of 4 bytes, but it is really 16 bytes just like later revisions.
+	 */
+	efx_writed(efx, &reg,
+		   efx->type->evq_rptr_tbl_base +
+		   FR_BZ_EVQ_RPTR_STEP * channel->channel);
 }
 
 /* Use HW to insert a SW defined event */
@@ -1564,7 +1569,9 @@ void efx_nic_push_rx_indir_table(struct efx_nic *efx)
 	for (i = 0; i < FR_BZ_RX_INDIRECTION_TBL_ROWS; i++) {
 		EFX_POPULATE_DWORD_1(dword, FRF_BZ_IT_QUEUE,
 				     efx->rx_indir_table[i]);
-		efx_writed_table(efx, &dword, FR_BZ_RX_INDIRECTION_TBL, i);
+		efx_writed(efx, &dword,
+			   FR_BZ_RX_INDIRECTION_TBL +
+			   FR_BZ_RX_INDIRECTION_TBL_STEP * i);
 	}
 }
 
@@ -2028,15 +2035,15 @@ void efx_nic_get_regs(struct efx_nic *efx, void *buf)
 
 		for (i = 0; i < table->rows; i++) {
 			switch (table->step) {
-			case 4: /* 32-bit register or SRAM */
-				efx_readd_table(efx, buf, table->offset, i);
+			case 4: /* 32-bit SRAM */
+				efx_readd(efx, buf, table->offset + 4 * i);
 				break;
 			case 8: /* 64-bit SRAM */
 				efx_sram_readq(efx,
 					       efx->membase + table->offset,
 					       buf, i);
 				break;
-			case 16: /* 128-bit register */
+			case 16: /* 128-bit-readable register */
 				efx_reado_table(efx, buf, table->offset, i);
 				break;
 			case 32: /* 128-bit register, interleaved */
diff --git a/drivers/net/ethernet/sfc/siena_sriov.c b/drivers/net/ethernet/sfc/siena_sriov.c
index 6e62a018..90f8d16 100644
--- a/drivers/net/ethernet/sfc/siena_sriov.c
+++ b/drivers/net/ethernet/sfc/siena_sriov.c
@@ -993,7 +993,7 @@ static void efx_sriov_reset_vf(struct efx_vf *vf, struct efx_buffer *buffer)
 			     FRF_AZ_EVQ_BUF_BASE_ID, buftbl);
 	efx_writeo_table(efx, &reg, FR_BZ_EVQ_PTR_TBL, abs_evq);
 	EFX_POPULATE_DWORD_1(ptr, FRF_AZ_EVQ_RPTR, 0);
-	efx_writed_table(efx, &ptr, FR_BZ_EVQ_RPTR, abs_evq);
+	efx_writed(efx, &ptr, FR_BZ_EVQ_RPTR + FR_BZ_EVQ_RPTR_STEP * abs_evq);
 
 	mutex_unlock(&vf->status_lock);
 }
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
