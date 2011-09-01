From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 1/2] Revert "sfc: Use write-combining to reduce TX
 latency" and follow-ups
Date: Thu, 01 Sep 2011 23:09:29 +0100
Message-ID: <1314914969.2733.15.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:54714 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932190Ab1IAWJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 18:09:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commits 65f0b417dee94f779ce9b77102b7d73c93723b39,
d88d6b05fee3cc78e5b0273eb58c31201dcc6b76,
fcfa060468a4edcf776f0c1211d826d5de1668c1,
747df2258b1b9a2e25929ef496262c339c380009 and
867955f5682f7157fdafe8670804b9f8ea077bc7.

Depending on the processor model, write-combining may result in
reordering that the NIC will not tolerate.  This typically results
in a DMA error event and reset by the driver, logged as:

sfc 0000:0e:00.0: eth2: TX DMA Q reports TX_EV_PKT_ERR.
sfc 0000:0e:00.0: eth2: resetting (ALL)

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
Please queue this for 3.0.y as well.

Ben.

 drivers/net/sfc/efx.c         |   18 +--------------
 drivers/net/sfc/io.h          |   15 +++---------
 drivers/net/sfc/mcdi.c        |   46 +++++++++++++++-------------------------
 drivers/net/sfc/nic.c         |    7 ------
 drivers/net/sfc/nic.h         |    2 -
 drivers/net/sfc/siena.c       |   25 +++------------------
 drivers/net/sfc/workarounds.h |    2 -
 7 files changed, 27 insertions(+), 88 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index faca764..b59abc7 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1050,7 +1050,6 @@ static int efx_init_io(struct efx_nic *efx)
 {
 	struct pci_dev *pci_dev = efx->pci_dev;
 	dma_addr_t dma_mask = efx->type->max_dma_mask;
-	bool use_wc;
 	int rc;
 
 	netif_dbg(efx, probe, efx->net_dev, "initialising I/O\n");
@@ -1101,21 +1100,8 @@ static int efx_init_io(struct efx_nic *efx)
 		rc = -EIO;
 		goto fail3;
 	}
-
-	/* bug22643: If SR-IOV is enabled then tx push over a write combined
-	 * mapping is unsafe. We need to disable write combining in this case.
-	 * MSI is unsupported when SR-IOV is enabled, and the firmware will
-	 * have removed the MSI capability. So write combining is safe if
-	 * there is an MSI capability.
-	 */
-	use_wc = (!EFX_WORKAROUND_22643(efx) ||
-		  pci_find_capability(pci_dev, PCI_CAP_ID_MSI));
-	if (use_wc)
-		efx->membase = ioremap_wc(efx->membase_phys,
-					  efx->type->mem_map_size);
-	else
-		efx->membase = ioremap_nocache(efx->membase_phys,
-					       efx->type->mem_map_size);
+	efx->membase = ioremap_nocache(efx->membase_phys,
+				       efx->type->mem_map_size);
 	if (!efx->membase) {
 		netif_err(efx, probe, efx->net_dev,
 			  "could not map memory BAR at %llx+%x\n",
diff --git a/drivers/net/sfc/io.h b/drivers/net/sfc/io.h
index cc97880..dc45110 100644
--- a/drivers/net/sfc/io.h
+++ b/drivers/net/sfc/io.h
@@ -48,9 +48,9 @@
  *   replacing the low 96 bits with zero does not affect functionality.
  * - If the host writes to the last dword address of such a register
  *   (i.e. the high 32 bits) the underlying register will always be
- *   written.  If the collector and the current write together do not
- *   provide values for all 128 bits of the register, the low 96 bits
- *   will be written as zero.
+ *   written.  If the collector does not hold values for the low 96
+ *   bits of the register, they will be written as zero.  Writing to
+ *   the last qword does not have this effect and must not be done.
  * - If the host writes to the address of any other part of such a
  *   register while the collector already holds values for some other
  *   register, the write is discarded and the collector maintains its
@@ -103,7 +103,6 @@ static inline void efx_writeo(struct efx_nic *efx, efx_oword_t *value,
 	_efx_writed(efx, value->u32[2], reg + 8);
 	_efx_writed(efx, value->u32[3], reg + 12);
 #endif
-	wmb();
 	mmiowb();
 	spin_unlock_irqrestore(&efx->biu_lock, flags);
 }
@@ -126,7 +125,6 @@ static inline void efx_sram_writeq(struct efx_nic *efx, void __iomem *membase,
 	__raw_writel((__force u32)value->u32[0], membase + addr);
 	__raw_writel((__force u32)value->u32[1], membase + addr + 4);
 #endif
-	wmb();
 	mmiowb();
 	spin_unlock_irqrestore(&efx->biu_lock, flags);
 }
@@ -141,7 +139,6 @@ static inline void efx_writed(struct efx_nic *efx, efx_dword_t *value,
 
 	/* No lock required */
 	_efx_writed(efx, value->u32[0], reg);
-	wmb();
 }
 
 /* Read a 128-bit CSR, locking as appropriate. */
@@ -152,7 +149,6 @@ static inline void efx_reado(struct efx_nic *efx, efx_oword_t *value,
 
 	spin_lock_irqsave(&efx->biu_lock, flags);
 	value->u32[0] = _efx_readd(efx, reg + 0);
-	rmb();
 	value->u32[1] = _efx_readd(efx, reg + 4);
 	value->u32[2] = _efx_readd(efx, reg + 8);
 	value->u32[3] = _efx_readd(efx, reg + 12);
@@ -175,7 +171,6 @@ static inline void efx_sram_readq(struct efx_nic *efx, void __iomem *membase,
 	value->u64[0] = (__force __le64)__raw_readq(membase + addr);
 #else
 	value->u32[0] = (__force __le32)__raw_readl(membase + addr);
-	rmb();
 	value->u32[1] = (__force __le32)__raw_readl(membase + addr + 4);
 #endif
 	spin_unlock_irqrestore(&efx->biu_lock, flags);
@@ -242,14 +237,12 @@ static inline void _efx_writeo_page(struct efx_nic *efx, efx_oword_t *value,
 
 #ifdef EFX_USE_QWORD_IO
 	_efx_writeq(efx, value->u64[0], reg + 0);
-	_efx_writeq(efx, value->u64[1], reg + 8);
 #else
 	_efx_writed(efx, value->u32[0], reg + 0);
 	_efx_writed(efx, value->u32[1], reg + 4);
+#endif
 	_efx_writed(efx, value->u32[2], reg + 8);
 	_efx_writed(efx, value->u32[3], reg + 12);
-#endif
-	wmb();
 }
 #define efx_writeo_page(efx, value, reg, page)				\
 	_efx_writeo_page(efx, value,					\
diff --git a/drivers/net/sfc/mcdi.c b/drivers/net/sfc/mcdi.c
index 3dd45ed..81a4253 100644
--- a/drivers/net/sfc/mcdi.c
+++ b/drivers/net/sfc/mcdi.c
@@ -50,20 +50,6 @@ static inline struct efx_mcdi_iface *efx_mcdi(struct efx_nic *efx)
 	return &nic_data->mcdi;
 }
 
-static inline void
-efx_mcdi_readd(struct efx_nic *efx, efx_dword_t *value, unsigned reg)
-{
-	struct siena_nic_data *nic_data = efx->nic_data;
-	value->u32[0] = (__force __le32)__raw_readl(nic_data->mcdi_smem + reg);
-}
-
-static inline void
-efx_mcdi_writed(struct efx_nic *efx, const efx_dword_t *value, unsigned reg)
-{
-	struct siena_nic_data *nic_data = efx->nic_data;
-	__raw_writel((__force u32)value->u32[0], nic_data->mcdi_smem + reg);
-}
-
 void efx_mcdi_init(struct efx_nic *efx)
 {
 	struct efx_mcdi_iface *mcdi;
@@ -84,8 +70,8 @@ static void efx_mcdi_copyin(struct efx_nic *efx, unsigned cmd,
 			    const u8 *inbuf, size_t inlen)
 {
 	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
-	unsigned pdu = MCDI_PDU(efx);
-	unsigned doorbell = MCDI_DOORBELL(efx);
+	unsigned pdu = FR_CZ_MC_TREG_SMEM + MCDI_PDU(efx);
+	unsigned doorbell = FR_CZ_MC_TREG_SMEM + MCDI_DOORBELL(efx);
 	unsigned int i;
 	efx_dword_t hdr;
 	u32 xflags, seqno;
@@ -106,28 +92,29 @@ static void efx_mcdi_copyin(struct efx_nic *efx, unsigned cmd,
 			     MCDI_HEADER_SEQ, seqno,
 			     MCDI_HEADER_XFLAGS, xflags);
 
-	efx_mcdi_writed(efx, &hdr, pdu);
+	efx_writed(efx, &hdr, pdu);
 
 	for (i = 0; i < inlen; i += 4)
-		efx_mcdi_writed(efx, (const efx_dword_t *)(inbuf + i),
-				pdu + 4 + i);
+		_efx_writed(efx, *((__le32 *)(inbuf + i)), pdu + 4 + i);
+
+	/* Ensure the payload is written out before the header */
+	wmb();
 
 	/* ring the doorbell with a distinctive value */
-	EFX_POPULATE_DWORD_1(hdr, EFX_DWORD_0, 0x45789abc);
-	efx_mcdi_writed(efx, &hdr, doorbell);
+	_efx_writed(efx, (__force __le32) 0x45789abc, doorbell);
 }
 
 static void efx_mcdi_copyout(struct efx_nic *efx, u8 *outbuf, size_t outlen)
 {
 	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
-	unsigned int pdu = MCDI_PDU(efx);
+	unsigned int pdu = FR_CZ_MC_TREG_SMEM + MCDI_PDU(efx);
 	int i;
 
 	BUG_ON(atomic_read(&mcdi->state) == MCDI_STATE_QUIESCENT);
 	BUG_ON(outlen & 3 || outlen >= 0x100);
 
 	for (i = 0; i < outlen; i += 4)
-		efx_mcdi_readd(efx, (efx_dword_t *)(outbuf + i), pdu + 4 + i);
+		*((__le32 *)(outbuf + i)) = _efx_readd(efx, pdu + 4 + i);
 }
 
 static int efx_mcdi_poll(struct efx_nic *efx)
@@ -135,7 +122,7 @@ static int efx_mcdi_poll(struct efx_nic *efx)
 	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
 	unsigned int time, finish;
 	unsigned int respseq, respcmd, error;
-	unsigned int pdu = MCDI_PDU(efx);
+	unsigned int pdu = FR_CZ_MC_TREG_SMEM + MCDI_PDU(efx);
 	unsigned int rc, spins;
 	efx_dword_t reg;
 
@@ -161,7 +148,8 @@ static int efx_mcdi_poll(struct efx_nic *efx)
 
 		time = get_seconds();
 
-		efx_mcdi_readd(efx, &reg, pdu);
+		rmb();
+		efx_readd(efx, &reg, pdu);
 
 		/* All 1's indicates that shared memory is in reset (and is
 		 * not a valid header). Wait for it to come out reset before
@@ -188,7 +176,7 @@ static int efx_mcdi_poll(struct efx_nic *efx)
 			  respseq, mcdi->seqno);
 		rc = EIO;
 	} else if (error) {
-		efx_mcdi_readd(efx, &reg, pdu + 4);
+		efx_readd(efx, &reg, pdu + 4);
 		switch (EFX_DWORD_FIELD(reg, EFX_DWORD_0)) {
 #define TRANSLATE_ERROR(name)					\
 		case MC_CMD_ERR_ ## name:			\
@@ -222,21 +210,21 @@ out:
 /* Test and clear MC-rebooted flag for this port/function */
 int efx_mcdi_poll_reboot(struct efx_nic *efx)
 {
-	unsigned int addr = MCDI_REBOOT_FLAG(efx);
+	unsigned int addr = FR_CZ_MC_TREG_SMEM + MCDI_REBOOT_FLAG(efx);
 	efx_dword_t reg;
 	uint32_t value;
 
 	if (efx_nic_rev(efx) < EFX_REV_SIENA_A0)
 		return false;
 
-	efx_mcdi_readd(efx, &reg, addr);
+	efx_readd(efx, &reg, addr);
 	value = EFX_DWORD_FIELD(reg, EFX_DWORD_0);
 
 	if (value == 0)
 		return 0;
 
 	EFX_ZERO_DWORD(reg);
-	efx_mcdi_writed(efx, &reg, addr);
+	efx_writed(efx, &reg, addr);
 
 	if (value == MC_STATUS_DWORD_ASSERT)
 		return -EINTR;
diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index bafa23a..3edfbaf 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -1936,13 +1936,6 @@ void efx_nic_get_regs(struct efx_nic *efx, void *buf)
 
 		size = min_t(size_t, table->step, 16);
 
-		if (table->offset >= efx->type->mem_map_size) {
-			/* No longer mapped; return dummy data */
-			memcpy(buf, "\xde\xc0\xad\xde", 4);
-			buf += table->rows * size;
-			continue;
-		}
-
 		for (i = 0; i < table->rows; i++) {
 			switch (table->step) {
 			case 4: /* 32-bit register or SRAM */
diff --git a/drivers/net/sfc/nic.h b/drivers/net/sfc/nic.h
index 4bd1f28..7443f99 100644
--- a/drivers/net/sfc/nic.h
+++ b/drivers/net/sfc/nic.h
@@ -143,12 +143,10 @@ static inline struct falcon_board *falcon_board(struct efx_nic *efx)
 /**
  * struct siena_nic_data - Siena NIC state
  * @mcdi: Management-Controller-to-Driver Interface
- * @mcdi_smem: MCDI shared memory mapping. The mapping is always uncacheable.
  * @wol_filter_id: Wake-on-LAN packet filter id
  */
 struct siena_nic_data {
 	struct efx_mcdi_iface mcdi;
-	void __iomem *mcdi_smem;
 	int wol_filter_id;
 };
 
diff --git a/drivers/net/sfc/siena.c b/drivers/net/sfc/siena.c
index 5735e84..2c3bd93 100644
--- a/drivers/net/sfc/siena.c
+++ b/drivers/net/sfc/siena.c
@@ -250,26 +250,12 @@ static int siena_probe_nic(struct efx_nic *efx)
 	efx_reado(efx, &reg, FR_AZ_CS_DEBUG);
 	efx->net_dev->dev_id = EFX_OWORD_FIELD(reg, FRF_CZ_CS_PORT_NUM) - 1;
 
-	/* Initialise MCDI */
-	nic_data->mcdi_smem = ioremap_nocache(efx->membase_phys +
-					      FR_CZ_MC_TREG_SMEM,
-					      FR_CZ_MC_TREG_SMEM_STEP *
-					      FR_CZ_MC_TREG_SMEM_ROWS);
-	if (!nic_data->mcdi_smem) {
-		netif_err(efx, probe, efx->net_dev,
-			  "could not map MCDI at %llx+%x\n",
-			  (unsigned long long)efx->membase_phys +
-			  FR_CZ_MC_TREG_SMEM,
-			  FR_CZ_MC_TREG_SMEM_STEP * FR_CZ_MC_TREG_SMEM_ROWS);
-		rc = -ENOMEM;
-		goto fail1;
-	}
 	efx_mcdi_init(efx);
 
 	/* Recover from a failed assertion before probing */
 	rc = efx_mcdi_handle_assertion(efx);
 	if (rc)
-		goto fail2;
+		goto fail1;
 
 	/* Let the BMC know that the driver is now in charge of link and
 	 * filter settings. We must do this before we reset the NIC */
@@ -324,7 +310,6 @@ fail4:
 fail3:
 	efx_mcdi_drv_attach(efx, false, NULL);
 fail2:
-	iounmap(nic_data->mcdi_smem);
 fail1:
 	kfree(efx->nic_data);
 	return rc;
@@ -404,8 +389,6 @@ static int siena_init_nic(struct efx_nic *efx)
 
 static void siena_remove_nic(struct efx_nic *efx)
 {
-	struct siena_nic_data *nic_data = efx->nic_data;
-
 	efx_nic_free_buffer(efx, &efx->irq_status);
 
 	siena_reset_hw(efx, RESET_TYPE_ALL);
@@ -415,8 +398,7 @@ static void siena_remove_nic(struct efx_nic *efx)
 		efx_mcdi_drv_attach(efx, false, NULL);
 
 	/* Tear down the private nic state */
-	iounmap(nic_data->mcdi_smem);
-	kfree(nic_data);
+	kfree(efx->nic_data);
 	efx->nic_data = NULL;
 }
 
@@ -656,7 +638,8 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.default_mac_ops = &efx_mcdi_mac_operations,
 
 	.revision = EFX_REV_SIENA_A0,
-	.mem_map_size = FR_CZ_MC_TREG_SMEM, /* MC_TREG_SMEM mapped separately */
+	.mem_map_size = (FR_CZ_MC_TREG_SMEM +
+			 FR_CZ_MC_TREG_SMEM_STEP * FR_CZ_MC_TREG_SMEM_ROWS),
 	.txd_ptr_tbl_base = FR_BZ_TX_DESC_PTR_TBL,
 	.rxd_ptr_tbl_base = FR_BZ_RX_DESC_PTR_TBL,
 	.buf_tbl_base = FR_BZ_BUF_FULL_TBL,
diff --git a/drivers/net/sfc/workarounds.h b/drivers/net/sfc/workarounds.h
index 99ff114..e4dd3a7 100644
--- a/drivers/net/sfc/workarounds.h
+++ b/drivers/net/sfc/workarounds.h
@@ -38,8 +38,6 @@
 #define EFX_WORKAROUND_15783 EFX_WORKAROUND_ALWAYS
 /* Legacy interrupt storm when interrupt fifo fills */
 #define EFX_WORKAROUND_17213 EFX_WORKAROUND_SIENA
-/* Write combining and sriov=enabled are incompatible */
-#define EFX_WORKAROUND_22643 EFX_WORKAROUND_SIENA
 
 /* Spurious parity errors in TSORT buffers */
 #define EFX_WORKAROUND_5129 EFX_WORKAROUND_FALCON_A
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
