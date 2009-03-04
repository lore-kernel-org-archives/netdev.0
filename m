From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 7/7] sfc: Improve NIC internal error recovery
Date: Wed, 04 Mar 2009 20:01:57 +0000
Message-ID: <1236196917.3140.34.camel@achroite>
References: <1236196272.3140.15.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:38228 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756461AbZCDUCB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 15:02:01 -0500
In-Reply-To: <1236196272.3140.15.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the error count a per-NIC variable.
Reset this the count after an hour if it has not reached the critical value.
Set the critical value back to 5.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |   23 +++++++++++++++++++----
 1 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 82c10f4..2ae51fd 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -39,11 +39,16 @@
  * @next_buffer_table: First available buffer table id
  * @pci_dev2: The secondary PCI device if present
  * @i2c_data: Operations and state for I2C bit-bashing algorithm
+ * @int_error_count: Number of internal errors seen recently
+ * @int_error_expire: Time at which error count will be expired
  */
 struct falcon_nic_data {
 	unsigned next_buffer_table;
 	struct pci_dev *pci_dev2;
 	struct i2c_algo_bit_data i2c_data;
+
+	unsigned int_error_count;
+	unsigned long int_error_expire;
 };
 
 /**************************************************************************
@@ -119,8 +124,12 @@ MODULE_PARM_DESC(rx_xon_thresh_bytes, "RX fifo XON threshold");
 #define FALCON_EVQ_SIZE 4096
 #define FALCON_EVQ_MASK (FALCON_EVQ_SIZE - 1)
 
-/* Max number of internal errors. After this resets will not be performed */
-#define FALCON_MAX_INT_ERRORS 4
+/* If FALCON_MAX_INT_ERRORS internal errors occur within
+ * FALCON_INT_ERROR_EXPIRE seconds, we consider the NIC broken and
+ * disable it.
+ */
+#define FALCON_INT_ERROR_EXPIRE 3600
+#define FALCON_MAX_INT_ERRORS 5
 
 /* We poll for events every FLUSH_INTERVAL ms, and check FLUSH_POLL_COUNT times
  */
@@ -1374,7 +1383,6 @@ static irqreturn_t falcon_fatal_interrupt(struct efx_nic *efx)
 	efx_oword_t *int_ker = efx->irq_status.addr;
 	efx_oword_t fatal_intr;
 	int error, mem_perr;
-	static int n_int_errors;
 
 	falcon_read(efx, &fatal_intr, FATAL_INTR_REG_KER);
 	error = EFX_OWORD_FIELD(fatal_intr, INT_KER_ERROR);
@@ -1401,7 +1409,14 @@ static irqreturn_t falcon_fatal_interrupt(struct efx_nic *efx)
 		pci_clear_master(nic_data->pci_dev2);
 	falcon_disable_interrupts(efx);
 
-	if (++n_int_errors < FALCON_MAX_INT_ERRORS) {
+	/* Count errors and reset or disable the NIC accordingly */
+	if (nic_data->int_error_count == 0 ||
+	    time_after(jiffies, nic_data->int_error_expire)) {
+		nic_data->int_error_count = 0;
+		nic_data->int_error_expire =
+			jiffies + FALCON_INT_ERROR_EXPIRE * HZ;
+	}
+	if (++nic_data->int_error_count < FALCON_MAX_INT_ERRORS) {
 		EFX_ERR(efx, "SYSTEM ERROR - reset scheduled\n");
 		efx_schedule_reset(efx, RESET_TYPE_INT_ERROR);
 	} else {

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

