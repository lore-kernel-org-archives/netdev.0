From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6] sfc: Always map MCDI shared memory as uncacheable
Date: Thu, 12 May 2011 17:09:21 +0100
Message-ID: <1305216561.5214.14.camel@bwh-desktop>
References: <1305216428.5214.13.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:13747 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757350Ab1ELQJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 12:09:24 -0400
In-Reply-To: <1305216428.5214.13.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We enabled write-combining for memory-mapped registers in commit
65f0b417dee94f779ce9b77102b7d73c93723b39, but inhibited it for the
MCDI shared memory where this is not supported.  However,
write-combining mappings also allow read-reordering, which may also
be a problem.

I found that when an SFC9000-family controller is connected to an
Intel 3000 chipset, and write-combining is enabled, the controller
stops responding to PCIe read requests during driver initialisation
while the driver is polling for completion of an MCDI command.  This
results in an NMI and system hang.  Adding read memory barriers
between all reads to the shared memory area appears to reduce but not
eliminate the probability of this.

We have not yet established whether this is a bug in our BIU or in the
PCIe bridge.  For now, work around by mapping the shared memory area
separately.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mcdi.c  |   49 ++++++++++++++++++++++++++++------------------
 drivers/net/sfc/nic.h   |    2 +
 drivers/net/sfc/siena.c |   25 ++++++++++++++++++++---
 3 files changed, 53 insertions(+), 23 deletions(-)

diff --git a/drivers/net/sfc/mcdi.c b/drivers/net/sfc/mcdi.c
index d984790..3dd45ed 100644
--- a/drivers/net/sfc/mcdi.c
+++ b/drivers/net/sfc/mcdi.c
@@ -50,6 +50,20 @@ static inline struct efx_mcdi_iface *efx_mcdi(struct efx_nic *efx)
 	return &nic_data->mcdi;
 }
 
+static inline void
+efx_mcdi_readd(struct efx_nic *efx, efx_dword_t *value, unsigned reg)
+{
+	struct siena_nic_data *nic_data = efx->nic_data;
+	value->u32[0] = (__force __le32)__raw_readl(nic_data->mcdi_smem + reg);
+}
+
+static inline void
+efx_mcdi_writed(struct efx_nic *efx, const efx_dword_t *value, unsigned reg)
+{
+	struct siena_nic_data *nic_data = efx->nic_data;
+	__raw_writel((__force u32)value->u32[0], nic_data->mcdi_smem + reg);
+}
+
 void efx_mcdi_init(struct efx_nic *efx)
 {
 	struct efx_mcdi_iface *mcdi;
@@ -70,8 +84,8 @@ static void efx_mcdi_copyin(struct efx_nic *efx, unsigned cmd,
 			    const u8 *inbuf, size_t inlen)
 {
 	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
-	unsigned pdu = FR_CZ_MC_TREG_SMEM + MCDI_PDU(efx);
-	unsigned doorbell = FR_CZ_MC_TREG_SMEM + MCDI_DOORBELL(efx);
+	unsigned pdu = MCDI_PDU(efx);
+	unsigned doorbell = MCDI_DOORBELL(efx);
 	unsigned int i;
 	efx_dword_t hdr;
 	u32 xflags, seqno;
@@ -92,30 +106,28 @@ static void efx_mcdi_copyin(struct efx_nic *efx, unsigned cmd,
 			     MCDI_HEADER_SEQ, seqno,
 			     MCDI_HEADER_XFLAGS, xflags);
 
-	efx_writed(efx, &hdr, pdu);
+	efx_mcdi_writed(efx, &hdr, pdu);
 
-	for (i = 0; i < inlen; i += 4) {
-		_efx_writed(efx, *((__le32 *)(inbuf + i)), pdu + 4 + i);
-		/* use wmb() within loop to inhibit write combining */
-		wmb();
-	}
+	for (i = 0; i < inlen; i += 4)
+		efx_mcdi_writed(efx, (const efx_dword_t *)(inbuf + i),
+				pdu + 4 + i);
 
 	/* ring the doorbell with a distinctive value */
-	_efx_writed(efx, (__force __le32) 0x45789abc, doorbell);
-	wmb();
+	EFX_POPULATE_DWORD_1(hdr, EFX_DWORD_0, 0x45789abc);
+	efx_mcdi_writed(efx, &hdr, doorbell);
 }
 
 static void efx_mcdi_copyout(struct efx_nic *efx, u8 *outbuf, size_t outlen)
 {
 	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
-	unsigned int pdu = FR_CZ_MC_TREG_SMEM + MCDI_PDU(efx);
+	unsigned int pdu = MCDI_PDU(efx);
 	int i;
 
 	BUG_ON(atomic_read(&mcdi->state) == MCDI_STATE_QUIESCENT);
 	BUG_ON(outlen & 3 || outlen >= 0x100);
 
 	for (i = 0; i < outlen; i += 4)
-		*((__le32 *)(outbuf + i)) = _efx_readd(efx, pdu + 4 + i);
+		efx_mcdi_readd(efx, (efx_dword_t *)(outbuf + i), pdu + 4 + i);
 }
 
 static int efx_mcdi_poll(struct efx_nic *efx)
@@ -123,7 +135,7 @@ static int efx_mcdi_poll(struct efx_nic *efx)
 	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
 	unsigned int time, finish;
 	unsigned int respseq, respcmd, error;
-	unsigned int pdu = FR_CZ_MC_TREG_SMEM + MCDI_PDU(efx);
+	unsigned int pdu = MCDI_PDU(efx);
 	unsigned int rc, spins;
 	efx_dword_t reg;
 
@@ -149,8 +161,7 @@ static int efx_mcdi_poll(struct efx_nic *efx)
 
 		time = get_seconds();
 
-		rmb();
-		efx_readd(efx, &reg, pdu);
+		efx_mcdi_readd(efx, &reg, pdu);
 
 		/* All 1's indicates that shared memory is in reset (and is
 		 * not a valid header). Wait for it to come out reset before
@@ -177,7 +188,7 @@ static int efx_mcdi_poll(struct efx_nic *efx)
 			  respseq, mcdi->seqno);
 		rc = EIO;
 	} else if (error) {
-		efx_readd(efx, &reg, pdu + 4);
+		efx_mcdi_readd(efx, &reg, pdu + 4);
 		switch (EFX_DWORD_FIELD(reg, EFX_DWORD_0)) {
 #define TRANSLATE_ERROR(name)					\
 		case MC_CMD_ERR_ ## name:			\
@@ -211,21 +222,21 @@ out:
 /* Test and clear MC-rebooted flag for this port/function */
 int efx_mcdi_poll_reboot(struct efx_nic *efx)
 {
-	unsigned int addr = FR_CZ_MC_TREG_SMEM + MCDI_REBOOT_FLAG(efx);
+	unsigned int addr = MCDI_REBOOT_FLAG(efx);
 	efx_dword_t reg;
 	uint32_t value;
 
 	if (efx_nic_rev(efx) < EFX_REV_SIENA_A0)
 		return false;
 
-	efx_readd(efx, &reg, addr);
+	efx_mcdi_readd(efx, &reg, addr);
 	value = EFX_DWORD_FIELD(reg, EFX_DWORD_0);
 
 	if (value == 0)
 		return 0;
 
 	EFX_ZERO_DWORD(reg);
-	efx_writed(efx, &reg, addr);
+	efx_mcdi_writed(efx, &reg, addr);
 
 	if (value == MC_STATUS_DWORD_ASSERT)
 		return -EINTR;
diff --git a/drivers/net/sfc/nic.h b/drivers/net/sfc/nic.h
index a42db6e..d91701a 100644
--- a/drivers/net/sfc/nic.h
+++ b/drivers/net/sfc/nic.h
@@ -143,10 +143,12 @@ static inline struct falcon_board *falcon_board(struct efx_nic *efx)
 /**
  * struct siena_nic_data - Siena NIC state
  * @mcdi: Management-Controller-to-Driver Interface
+ * @mcdi_smem: MCDI shared memory mapping. The mapping is always uncacheable.
  * @wol_filter_id: Wake-on-LAN packet filter id
  */
 struct siena_nic_data {
 	struct efx_mcdi_iface mcdi;
+	void __iomem *mcdi_smem;
 	int wol_filter_id;
 };
 
diff --git a/drivers/net/sfc/siena.c b/drivers/net/sfc/siena.c
index e4dd898..837869b 100644
--- a/drivers/net/sfc/siena.c
+++ b/drivers/net/sfc/siena.c
@@ -220,12 +220,26 @@ static int siena_probe_nic(struct efx_nic *efx)
 	efx_reado(efx, &reg, FR_AZ_CS_DEBUG);
 	efx->net_dev->dev_id = EFX_OWORD_FIELD(reg, FRF_CZ_CS_PORT_NUM) - 1;
 
+	/* Initialise MCDI */
+	nic_data->mcdi_smem = ioremap_nocache(efx->membase_phys +
+					      FR_CZ_MC_TREG_SMEM,
+					      FR_CZ_MC_TREG_SMEM_STEP *
+					      FR_CZ_MC_TREG_SMEM_ROWS);
+	if (!nic_data->mcdi_smem) {
+		netif_err(efx, probe, efx->net_dev,
+			  "could not map MCDI at %llx+%x\n",
+			  (unsigned long long)efx->membase_phys +
+			  FR_CZ_MC_TREG_SMEM,
+			  FR_CZ_MC_TREG_SMEM_STEP * FR_CZ_MC_TREG_SMEM_ROWS);
+		rc = -ENOMEM;
+		goto fail1;
+	}
 	efx_mcdi_init(efx);
 
 	/* Recover from a failed assertion before probing */
 	rc = efx_mcdi_handle_assertion(efx);
 	if (rc)
-		goto fail1;
+		goto fail2;
 
 	/* Let the BMC know that the driver is now in charge of link and
 	 * filter settings. We must do this before we reset the NIC */
@@ -280,6 +294,7 @@ fail4:
 fail3:
 	efx_mcdi_drv_attach(efx, false, NULL);
 fail2:
+	iounmap(nic_data->mcdi_smem);
 fail1:
 	kfree(efx->nic_data);
 	return rc;
@@ -359,6 +374,8 @@ static int siena_init_nic(struct efx_nic *efx)
 
 static void siena_remove_nic(struct efx_nic *efx)
 {
+	struct siena_nic_data *nic_data = efx->nic_data;
+
 	efx_nic_free_buffer(efx, &efx->irq_status);
 
 	siena_reset_hw(efx, RESET_TYPE_ALL);
@@ -368,7 +385,8 @@ static void siena_remove_nic(struct efx_nic *efx)
 		efx_mcdi_drv_attach(efx, false, NULL);
 
 	/* Tear down the private nic state */
-	kfree(efx->nic_data);
+	iounmap(nic_data->mcdi_smem);
+	kfree(nic_data);
 	efx->nic_data = NULL;
 }
 
@@ -606,8 +624,7 @@ struct efx_nic_type siena_a0_nic_type = {
 	.default_mac_ops = &efx_mcdi_mac_operations,
 
 	.revision = EFX_REV_SIENA_A0,
-	.mem_map_size = (FR_CZ_MC_TREG_SMEM +
-			 FR_CZ_MC_TREG_SMEM_STEP * FR_CZ_MC_TREG_SMEM_ROWS),
+	.mem_map_size = FR_CZ_MC_TREG_SMEM, /* MC_TREG_SMEM mapped separately */
 	.txd_ptr_tbl_base = FR_BZ_TX_DESC_PTR_TBL,
 	.rxd_ptr_tbl_base = FR_BZ_RX_DESC_PTR_TBL,
 	.buf_tbl_base = FR_BZ_BUF_FULL_TBL,
-- 
1.7.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

