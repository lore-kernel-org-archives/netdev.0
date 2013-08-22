From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 07/32] sfc: Rationalise MCDI buffer accessors
Date: Thu, 22 Aug 2013 13:47:19 +0100
Message-ID: <1377175639.1703.12.camel@bwh-desktop.uk.level5networks.com>
References: <1377175392.1703.5.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:13609 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752372Ab3HVMrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 08:47:22 -0400
In-Reply-To: <1377175392.1703.5.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add _MCDI_DWORD() which yields an lvalue for the given dword field
and change MCDI_DWORD(), MCDI_SET_DWORD() and MCDI_QWORD() to use it.

Fold the rather trivial MCDI_PTR2() into MCDI_PTR() and _MCDI_DWORD().

Remove MCDI_SET_DWORD2() and MCDI_QWORD2().  MCDI_DWORD2() should also
go, but it still has one user which we'll get rid of later.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.h | 46 ++++++++++++++++++-----------------------
 1 file changed, 20 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index c881118..03fb6c0 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -87,34 +87,25 @@ extern void efx_mcdi_sensor_event(struct efx_nic *efx, efx_qword_t *ev);
 
 #define MCDI_DECLARE_BUF(_name, _len)					\
 	u8 _name[ALIGN(_len, 4)]
+#define MCDI_PTR(_buf, _field)						\
+	((u8 *)(_buf) + MC_CMD_ ## _field ## _OFST)
+#define _MCDI_DWORD(_buf, _field)					\
+	((efx_dword_t *)MCDI_PTR(_buf, _field))
+
+#define MCDI_DWORD2(_buf, _ofst)                                       \
+	EFX_DWORD_FIELD(*(efx_dword_t *)((u8 *)(_buf) + (_ofst)), EFX_DWORD_0)
+
+#define MCDI_SET_DWORD(_buf, _field, _value)				\
+	EFX_POPULATE_DWORD_1(*_MCDI_DWORD(_buf, _field), EFX_DWORD_0, _value)
+#define MCDI_DWORD(_buf, _field)					\
+	EFX_DWORD_FIELD(*_MCDI_DWORD(_buf, _field), EFX_DWORD_0)
+#define MCDI_QWORD(_buf, _field)					\
+	(EFX_DWORD_FIELD(_MCDI_DWORD(_buf, _field)[0], EFX_DWORD_0) |	\
+	(u64)EFX_DWORD_FIELD(_MCDI_DWORD(_buf, _field)[1], EFX_DWORD_0) << 32)
 
-#define MCDI_PTR2(_buf, _ofst)						\
-	(((u8 *)_buf) + _ofst)
-#define MCDI_SET_DWORD2(_buf, _ofst, _value)				\
-	EFX_POPULATE_DWORD_1(*((efx_dword_t *)MCDI_PTR2(_buf, _ofst)),	\
-			     EFX_DWORD_0, _value)
-#define MCDI_DWORD2(_buf, _ofst)					\
-	EFX_DWORD_FIELD(*((efx_dword_t *)MCDI_PTR2(_buf, _ofst)),	\
-			EFX_DWORD_0)
-#define MCDI_QWORD2(_buf, _ofst)					\
-	EFX_QWORD_FIELD64(*((efx_qword_t *)MCDI_PTR2(_buf, _ofst)),	\
-			  EFX_QWORD_0)
-
-#define MCDI_PTR(_buf, _ofst)						\
-	MCDI_PTR2(_buf, MC_CMD_ ## _ofst ## _OFST)
 #define MCDI_ARRAY_PTR(_buf, _field, _type, _index)			\
-	MCDI_PTR2(_buf,							\
-		  MC_CMD_ ## _field ## _OFST +				\
-		  (_index) * MC_CMD_ ## _type ## _TYPEDEF_LEN)
-#define MCDI_SET_DWORD(_buf, _ofst, _value)				\
-	MCDI_SET_DWORD2(_buf, MC_CMD_ ## _ofst ## _OFST, _value)
-#define MCDI_DWORD(_buf, _ofst)						\
-	MCDI_DWORD2(_buf, MC_CMD_ ## _ofst ## _OFST)
-#define MCDI_QWORD(_buf, _ofst)						\
-	MCDI_QWORD2(_buf, MC_CMD_ ## _ofst ## _OFST)
-
-#define MCDI_EVENT_FIELD(_ev, _field)			\
-	EFX_QWORD_FIELD(_ev, MCDI_EVENT_ ## _field)
+	(MCDI_PTR(_buf, _field) +					\
+	 (_index) * MC_CMD_ ## _type ## _TYPEDEF_LEN)
 #define MCDI_ARRAY_FIELD(_buf, _field1, _type, _index, _field2)		\
 	EFX_EXTRACT_DWORD(						\
 		*((efx_dword_t *)					\
@@ -124,6 +115,9 @@ extern void efx_mcdi_sensor_event(struct efx_nic *efx, efx_qword_t *ev);
 		(MC_CMD_ ## _type ## _TYPEDEF_ ## _field2 ## _LBN & 0x1f) + \
 		MC_CMD_ ## _type ## _TYPEDEF_ ## _field2 ## _WIDTH - 1)
 
+#define MCDI_EVENT_FIELD(_ev, _field)			\
+	EFX_QWORD_FIELD(_ev, MCDI_EVENT_ ## _field)
+
 extern void efx_mcdi_print_fwver(struct efx_nic *efx, char *buf, size_t len);
 extern int efx_mcdi_drv_attach(struct efx_nic *efx, bool driver_operating,
 			       bool *was_attached_out);


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
