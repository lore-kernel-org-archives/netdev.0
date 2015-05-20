From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 1/4] sfc: add tracing of MCDI commands
Date: Wed, 20 May 2015 16:49:59 +0100
Message-ID: <555CAD27.2000603@solarflare.com>
References: <555CACF5.9060803@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:27418 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932505AbbETPuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 11:50:07 -0400
In-Reply-To: <555CACF5.9060803@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MCDI tracing is conditional on CONFIG_SFC_MCDI_LOGGING, which is enabled
 by default.

Each MCDI command will produce a console line like
    sfc dom:bus:dev:fn ifname: MCDI RPC REQ: xxxxxxxx [yyyyyyyy...]
where xxxxxxxx etc. are the raw MCDI payload in 32-bit hex chunks.
The response will then produce a similar line with "RESP" instead of "REQ",
 and containing the MCDI response payload (if any).

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/Kconfig |  8 ++++
 drivers/net/ethernet/sfc/ef10.c  |  3 ++
 drivers/net/ethernet/sfc/mcdi.c  | 91 ++++++++++++++++++++++++++++++++++++++--
 drivers/net/ethernet/sfc/mcdi.h  |  4 ++
 4 files changed, 102 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/Kconfig b/drivers/net/ethernet/sfc/Kconfig
index 0889212..c4ba42b 100644
--- a/drivers/net/ethernet/sfc/Kconfig
+++ b/drivers/net/ethernet/sfc/Kconfig
@@ -36,3 +36,11 @@ config SFC_SRIOV
 	  This enables support for the SFC9000 I/O Virtualization
 	  features, allowing accelerated network performance in
 	  virtualized environments.
+config SFC_MCDI_LOGGING
+	bool "Solarflare SFC9000/SFC9100-family MCDI logging support"
+	depends on SFC
+	default y
+	---help---
+	  This enables support for tracing of MCDI (Management-Controller-to-
+	  Driver-Interface) commands and responses, allowing debugging of
+	  driver/firmware interaction.
diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 882117a..2e8e5de 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -219,6 +219,9 @@ static int efx_ef10_probe(struct efx_nic *efx)
 		return -ENOMEM;
 	efx->nic_data = nic_data;
 
+	/* we assume later that we can copy from this buffer in dwords */
+	BUILD_BUG_ON(MCDI_CTL_SDU_LEN_MAX_V2 % 4);
+
 	rc = efx_nic_alloc_buffer(efx, &nic_data->mcdi_buf,
 				  8 + MCDI_CTL_SDU_LEN_MAX_V2, GFP_KERNEL);
 	if (rc)
diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index b44ee31..1400ed4 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -58,14 +58,20 @@ int efx_mcdi_init(struct efx_nic *efx)
 {
 	struct efx_mcdi_iface *mcdi;
 	bool already_attached;
-	int rc;
+	int rc = -ENOMEM;
 
 	efx->mcdi = kzalloc(sizeof(*efx->mcdi), GFP_KERNEL);
 	if (!efx->mcdi)
-		return -ENOMEM;
+		goto fail;
 
 	mcdi = efx_mcdi(efx);
 	mcdi->efx = efx;
+#ifdef CONFIG_SFC_MCDI_LOGGING
+	/* consuming code assumes buffer is page-sized */
+	mcdi->logging_buffer = (char *)__get_free_page(GFP_KERNEL);
+	if (!mcdi->logging_buffer)
+		goto fail1;
+#endif
 	init_waitqueue_head(&mcdi->wq);
 	spin_lock_init(&mcdi->iface_lock);
 	mcdi->state = MCDI_STATE_QUIESCENT;
@@ -81,7 +87,7 @@ int efx_mcdi_init(struct efx_nic *efx)
 	/* Recover from a failed assertion before probing */
 	rc = efx_mcdi_handle_assertion(efx);
 	if (rc)
-		return rc;
+		goto fail2;
 
 	/* Let the MC (and BMC, if this is a LOM) know that the driver
 	 * is loaded. We should do this before we reset the NIC.
@@ -90,7 +96,7 @@ int efx_mcdi_init(struct efx_nic *efx)
 	if (rc) {
 		netif_err(efx, probe, efx->net_dev,
 			  "Unable to register driver with MCPU\n");
-		return rc;
+		goto fail2;
 	}
 	if (already_attached)
 		/* Not a fatal error */
@@ -102,6 +108,15 @@ int efx_mcdi_init(struct efx_nic *efx)
 		efx->primary = efx;
 
 	return 0;
+fail2:
+#ifdef CONFIG_SFC_MCDI_LOGGING
+	free_page((unsigned long)mcdi->logging_buffer);
+fail1:
+#endif
+	kfree(efx->mcdi);
+	efx->mcdi = NULL;
+fail:
+	return rc;
 }
 
 void efx_mcdi_fini(struct efx_nic *efx)
@@ -114,6 +129,10 @@ void efx_mcdi_fini(struct efx_nic *efx)
 	/* Relinquish the device (back to the BMC, if this is a LOM) */
 	efx_mcdi_drv_attach(efx, false, NULL);
 
+#ifdef CONFIG_SFC_MCDI_LOGGING
+	free_page((unsigned long)efx->mcdi->iface.logging_buffer);
+#endif
+
 	kfree(efx->mcdi);
 }
 
@@ -121,6 +140,9 @@ static void efx_mcdi_send_request(struct efx_nic *efx, unsigned cmd,
 				  const efx_dword_t *inbuf, size_t inlen)
 {
 	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
+#ifdef CONFIG_SFC_MCDI_LOGGING
+	char *buf = mcdi->logging_buffer; /* page-sized */
+#endif
 	efx_dword_t hdr[2];
 	size_t hdr_len;
 	u32 xflags, seqno;
@@ -165,6 +187,31 @@ static void efx_mcdi_send_request(struct efx_nic *efx, unsigned cmd,
 		hdr_len = 8;
 	}
 
+#ifdef CONFIG_SFC_MCDI_LOGGING
+	if (!WARN_ON_ONCE(!buf)) {
+		int bytes = 0;
+		int i;
+		/* Lengths should always be a whole number of dwords, so scream
+		 * if they're not.
+		 */
+		WARN_ON_ONCE(hdr_len % 4);
+		WARN_ON_ONCE(inlen % 4);
+
+		/* We own the logging buffer, as only one MCDI can be in
+		 * progress on a NIC at any one time.  So no need for locking.
+		 */
+		for (i = 0; i < hdr_len / 4 && bytes < PAGE_SIZE; i++)
+			bytes += snprintf(buf + bytes, PAGE_SIZE - bytes,
+					  " %08x", le32_to_cpu(hdr[i].u32[0]));
+
+		for (i = 0; i < inlen / 4 && bytes < PAGE_SIZE; i++)
+			bytes += snprintf(buf + bytes, PAGE_SIZE - bytes,
+					  " %08x", le32_to_cpu(inbuf[i].u32[0]));
+
+		netif_info(efx, hw, efx->net_dev, "MCDI RPC REQ:%s\n", buf);
+	}
+#endif
+
 	efx->type->mcdi_request(efx, hdr, hdr_len, inbuf, inlen);
 
 	mcdi->new_epoch = false;
@@ -206,6 +253,9 @@ static void efx_mcdi_read_response_header(struct efx_nic *efx)
 {
 	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
 	unsigned int respseq, respcmd, error;
+#ifdef CONFIG_SFC_MCDI_LOGGING
+	char *buf = mcdi->logging_buffer; /* page-sized */
+#endif
 	efx_dword_t hdr;
 
 	efx->type->mcdi_read_response(efx, &hdr, 0, 4);
@@ -223,6 +273,39 @@ static void efx_mcdi_read_response_header(struct efx_nic *efx)
 			EFX_DWORD_FIELD(hdr, MC_CMD_V2_EXTN_IN_ACTUAL_LEN);
 	}
 
+#ifdef CONFIG_SFC_MCDI_LOGGING
+	if (!WARN_ON_ONCE(!buf)) {
+		size_t hdr_len, data_len;
+		int bytes = 0;
+		int i;
+
+		WARN_ON_ONCE(mcdi->resp_hdr_len % 4);
+		hdr_len = mcdi->resp_hdr_len / 4;
+		/* MCDI_DECLARE_BUF ensures that underlying buffer is padded
+		 * to dword size, and the MCDI buffer is always dword size
+		 */
+		data_len = DIV_ROUND_UP(mcdi->resp_data_len, 4);
+
+		/* We own the logging buffer, as only one MCDI can be in
+		 * progress on a NIC at any one time.  So no need for locking.
+		 */
+		for (i = 0; i < hdr_len && bytes < PAGE_SIZE; i++) {
+			efx->type->mcdi_read_response(efx, &hdr, (i * 4), 4);
+			bytes += snprintf(buf + bytes, PAGE_SIZE - bytes,
+					  " %08x", le32_to_cpu(hdr.u32[0]));
+		}
+
+		for (i = 0; i < data_len && bytes < PAGE_SIZE; i++) {
+			efx->type->mcdi_read_response(efx, &hdr,
+					mcdi->resp_hdr_len + (i * 4), 4);
+			bytes += snprintf(buf + bytes, PAGE_SIZE - bytes,
+					  " %08x", le32_to_cpu(hdr.u32[0]));
+		}
+
+		netif_info(efx, hw, efx->net_dev, "MCDI RPC RESP:%s\n", buf);
+	}
+#endif
+
 	if (error && mcdi->resp_data_len == 0) {
 		netif_err(efx, hw, efx->net_dev, "MC rebooted\n");
 		mcdi->resprc = -EIO;
diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index 5df1e98..2f6f032 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -58,6 +58,7 @@ enum efx_mcdi_mode {
  *	enabled
  * @async_list: Queue of asynchronous requests
  * @async_timer: Timer for asynchronous request timeout
+ * @logging_buffer: buffer that may be used to build MCDI tracing messages
  */
 struct efx_mcdi_iface {
 	struct efx_nic *efx;
@@ -74,6 +75,9 @@ struct efx_mcdi_iface {
 	spinlock_t async_lock;
 	struct list_head async_list;
 	struct timer_list async_timer;
+#ifdef CONFIG_SFC_MCDI_LOGGING
+	char *logging_buffer;
+#endif
 };
 
 struct efx_mcdi_mon {
