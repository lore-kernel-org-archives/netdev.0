From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 12/32] sfc: Add and use MCDI_SET_QWORD() and
 MCDI_SET_ARRAY_QWORD()
Date: Thu, 22 Aug 2013 13:50:07 +0100
Message-ID: <1377175807.1703.17.camel@bwh-desktop.uk.level5networks.com>
References: <1377175392.1703.5.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:13879 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753592Ab3HVMuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 08:50:10 -0400
In-Reply-To: <1377175392.1703.5.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to keep open-coding the assignment of high and low dwords.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.h        | 23 ++++++++++++++++++++---
 drivers/net/ethernet/sfc/mcdi_mon.c    |  6 ++----
 drivers/net/ethernet/sfc/ptp.c         | 13 ++++---------
 drivers/net/ethernet/sfc/siena_sriov.c | 21 ++++++++-------------
 4 files changed, 34 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index 28657a1..899f094 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -88,9 +88,9 @@ extern void efx_mcdi_process_event(struct efx_channel *channel,
 extern void efx_mcdi_sensor_event(struct efx_nic *efx, efx_qword_t *ev);
 
 /* We expect that 16- and 32-bit fields in MCDI requests and responses
- * are appropriately aligned.  Also, on Siena we must copy to the MC
- * shared memory strictly 32 bits at a time, so add any necessary
- * padding.
+ * are appropriately aligned, but 64-bit fields are only
+ * 32-bit-aligned.  Also, on Siena we must copy to the MC shared
+ * memory strictly 32 bits at a time, so add any necessary padding.
  */
 #define MCDI_DECLARE_BUF(_name, _len)					\
 	efx_dword_t _name[DIV_ROUND_UP(_len, 4)]
@@ -107,6 +107,13 @@ extern void efx_mcdi_sensor_event(struct efx_nic *efx, efx_qword_t *ev);
 	EFX_POPULATE_DWORD_1(*_MCDI_DWORD(_buf, _field), EFX_DWORD_0, _value)
 #define MCDI_DWORD(_buf, _field)					\
 	EFX_DWORD_FIELD(*_MCDI_DWORD(_buf, _field), EFX_DWORD_0)
+#define MCDI_SET_QWORD(_buf, _field, _value)				\
+	do {								\
+		EFX_POPULATE_DWORD_1(_MCDI_DWORD(_buf, _field)[0],	\
+				     EFX_DWORD_0, (u32)(_value));	\
+		EFX_POPULATE_DWORD_1(_MCDI_DWORD(_buf, _field)[1],	\
+				     EFX_DWORD_0, (u64)(_value) >> 32);	\
+	} while (0)
 #define MCDI_QWORD(_buf, _field)					\
 	(EFX_DWORD_FIELD(_MCDI_DWORD(_buf, _field)[0], EFX_DWORD_0) |	\
 	(u64)EFX_DWORD_FIELD(_MCDI_DWORD(_buf, _field)[1], EFX_DWORD_0) << 32)
@@ -140,6 +147,16 @@ extern void efx_mcdi_sensor_event(struct efx_nic *efx, efx_qword_t *ev);
 			    EFX_DWORD_0, _value)
 #define MCDI_ARRAY_DWORD(_buf, _field, _index)				\
 	EFX_DWORD_FIELD(*_MCDI_ARRAY_DWORD(_buf, _field, _index), EFX_DWORD_0)
+#define _MCDI_ARRAY_QWORD(_buf, _field, _index)				\
+	(BUILD_BUG_ON_ZERO(MC_CMD_ ## _field ## _LEN != 8) +		\
+	 (efx_dword_t *)_MCDI_ARRAY_PTR(_buf, _field, _index, 4))
+#define MCDI_SET_ARRAY_QWORD(_buf, _field, _index, _value)		\
+	do {								\
+		EFX_SET_DWORD_FIELD(_MCDI_ARRAY_QWORD(_buf, _field, _index)[0],\
+				    EFX_DWORD_0, (u32)(_value));	\
+		EFX_SET_DWORD_FIELD(_MCDI_ARRAY_QWORD(_buf, _field, _index)[1],\
+				    EFX_DWORD_0, (u64)(_value) >> 32);	\
+	} while (0)
 #define MCDI_ARRAY_FIELD(_buf, _field1, _type, _index, _field2)		\
 	MCDI_FIELD(MCDI_ARRAY_STRUCT_PTR(_buf, _field1, _index),	\
 		   _type ## _TYPEDEF, _field2)
diff --git a/drivers/net/ethernet/sfc/mcdi_mon.c b/drivers/net/ethernet/sfc/mcdi_mon.c
index 4e8a138..3179b2b 100644
--- a/drivers/net/ethernet/sfc/mcdi_mon.c
+++ b/drivers/net/ethernet/sfc/mcdi_mon.c
@@ -95,10 +95,8 @@ static int efx_mcdi_mon_update(struct efx_nic *efx)
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_READ_SENSORS_IN_LEN);
 	int rc;
 
-	MCDI_SET_DWORD(inbuf, READ_SENSORS_IN_DMA_ADDR_LO,
-		       hwmon->dma_buf.dma_addr & 0xffffffff);
-	MCDI_SET_DWORD(inbuf, READ_SENSORS_IN_DMA_ADDR_HI,
-		       (u64)hwmon->dma_buf.dma_addr >> 32);
+	MCDI_SET_QWORD(inbuf, READ_SENSORS_IN_DMA_ADDR,
+		       hwmon->dma_buf.dma_addr);
 
 	rc = efx_mcdi_rpc(efx, MC_CMD_READ_SENSORS,
 			  inbuf, sizeof(inbuf), NULL, 0, NULL);
diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 5612021..d96bfc4 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -533,10 +533,8 @@ static int efx_ptp_synchronize(struct efx_nic *efx, unsigned int num_readings)
 	MCDI_SET_DWORD(synch_buf, PTP_IN_OP, MC_CMD_PTP_OP_SYNCHRONIZE);
 	MCDI_SET_DWORD(synch_buf, PTP_IN_SYNCHRONIZE_NUMTIMESETS,
 		       num_readings);
-	MCDI_SET_DWORD(synch_buf, PTP_IN_SYNCHRONIZE_START_ADDR_LO,
-		       (u32)ptp->start.dma_addr);
-	MCDI_SET_DWORD(synch_buf, PTP_IN_SYNCHRONIZE_START_ADDR_HI,
-		       (u32)((u64)ptp->start.dma_addr >> 32));
+	MCDI_SET_QWORD(synch_buf, PTP_IN_SYNCHRONIZE_START_ADDR,
+		       ptp->start.dma_addr);
 
 	/* Clear flag that signals MC ready */
 	ACCESS_ONCE(*start) = 0;
@@ -1378,9 +1376,7 @@ static int efx_phc_adjfreq(struct ptp_clock_info *ptp, s32 delta)
 			 (PPB_EXTRA_BITS + MAX_PPB_BITS));
 
 	MCDI_SET_DWORD(inadj, PTP_IN_OP, MC_CMD_PTP_OP_ADJUST);
-	MCDI_SET_DWORD(inadj, PTP_IN_ADJUST_FREQ_LO, (u32)adjustment_ns);
-	MCDI_SET_DWORD(inadj, PTP_IN_ADJUST_FREQ_HI,
-		       (u32)(adjustment_ns >> 32));
+	MCDI_SET_QWORD(inadj, PTP_IN_ADJUST_FREQ, adjustment_ns);
 	MCDI_SET_DWORD(inadj, PTP_IN_ADJUST_SECONDS, 0);
 	MCDI_SET_DWORD(inadj, PTP_IN_ADJUST_NANOSECONDS, 0);
 	rc = efx_mcdi_rpc(efx, MC_CMD_PTP, inadj, sizeof(inadj),
@@ -1402,8 +1398,7 @@ static int efx_phc_adjtime(struct ptp_clock_info *ptp, s64 delta)
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_PTP_IN_ADJUST_LEN);
 
 	MCDI_SET_DWORD(inbuf, PTP_IN_OP, MC_CMD_PTP_OP_ADJUST);
-	MCDI_SET_DWORD(inbuf, PTP_IN_ADJUST_FREQ_LO, 0);
-	MCDI_SET_DWORD(inbuf, PTP_IN_ADJUST_FREQ_HI, 0);
+	MCDI_SET_QWORD(inbuf, PTP_IN_ADJUST_FREQ, 0);
 	MCDI_SET_DWORD(inbuf, PTP_IN_ADJUST_SECONDS, (u32)delta_ts.tv_sec);
 	MCDI_SET_DWORD(inbuf, PTP_IN_ADJUST_NANOSECONDS, (u32)delta_ts.tv_nsec);
 	return efx_mcdi_rpc(efx, MC_CMD_PTP, inbuf, sizeof(inbuf),
diff --git a/drivers/net/ethernet/sfc/siena_sriov.c b/drivers/net/ethernet/sfc/siena_sriov.c
index 198044f..2587d30 100644
--- a/drivers/net/ethernet/sfc/siena_sriov.c
+++ b/drivers/net/ethernet/sfc/siena_sriov.c
@@ -243,7 +243,8 @@ static int efx_sriov_memcpy(struct efx_nic *efx, struct efx_memcpy_req *req,
 	MCDI_DECLARE_BUF(inbuf, MCDI_CTL_SDU_LEN_MAX_V1);
 	MCDI_DECLARE_STRUCT_PTR(record);
 	unsigned int index, used;
-	u32 from_rid, from_hi, from_lo;
+	u64 from_addr;
+	u32 from_rid;
 	int rc;
 
 	mb();	/* Finish writing source/reading dest before DMA starts */
@@ -258,14 +259,11 @@ static int efx_sriov_memcpy(struct efx_nic *efx, struct efx_memcpy_req *req,
 			       count);
 		MCDI_SET_DWORD(record, MEMCPY_RECORD_TYPEDEF_TO_RID,
 			       req->to_rid);
-		MCDI_SET_DWORD(record, MEMCPY_RECORD_TYPEDEF_TO_ADDR_LO,
-			       (u32)req->to_addr);
-		MCDI_SET_DWORD(record, MEMCPY_RECORD_TYPEDEF_TO_ADDR_HI,
-			       (u32)(req->to_addr >> 32));
+		MCDI_SET_QWORD(record, MEMCPY_RECORD_TYPEDEF_TO_ADDR,
+			       req->to_addr);
 		if (req->from_buf == NULL) {
 			from_rid = req->from_rid;
-			from_lo = (u32)req->from_addr;
-			from_hi = (u32)(req->from_addr >> 32);
+			from_addr = req->from_addr;
 		} else {
 			if (WARN_ON(used + req->length >
 				    MCDI_CTL_SDU_LEN_MAX_V1)) {
@@ -274,18 +272,15 @@ static int efx_sriov_memcpy(struct efx_nic *efx, struct efx_memcpy_req *req,
 			}
 
 			from_rid = MC_CMD_MEMCPY_RECORD_TYPEDEF_RID_INLINE;
-			from_lo = used;
-			from_hi = 0;
+			from_addr = used;
 			memcpy(_MCDI_PTR(inbuf, used), req->from_buf,
 			       req->length);
 			used += req->length;
 		}
 
 		MCDI_SET_DWORD(record, MEMCPY_RECORD_TYPEDEF_FROM_RID, from_rid);
-		MCDI_SET_DWORD(record, MEMCPY_RECORD_TYPEDEF_FROM_ADDR_LO,
-			       from_lo);
-		MCDI_SET_DWORD(record, MEMCPY_RECORD_TYPEDEF_FROM_ADDR_HI,
-			       from_hi);
+		MCDI_SET_QWORD(record, MEMCPY_RECORD_TYPEDEF_FROM_ADDR,
+			       from_addr);
 		MCDI_SET_DWORD(record, MEMCPY_RECORD_TYPEDEF_LENGTH,
 			       req->length);
 


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
