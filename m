From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 08/32] sfc: Fill out the set of MCDI accessors
Date: Thu, 22 Aug 2013 13:48:32 +0100
Message-ID: <1377175712.1703.13.camel@bwh-desktop.uk.level5networks.com>
References: <1377175392.1703.5.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:13748 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752815Ab3HVMsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 08:48:35 -0400
In-Reply-To: <1377175392.1703.5.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to access arrays of 16-bit words and 32-bit dwords in MCDI
buffers based on the MCDI protocol definitions.

We should also be able to read and write fields within structures,
without specifying an array index each time.  So add MCDI_FIELD()
and make MCDI_ARRAY_FIELD() use it.  Also add MCDI_SET_FIELD().

Split MCDI_ARRAY_PTR() into MCDI_ARRAY_STRUCT_PTR() and
_MCDI_ARRAY_PTR(), which are currently identical but will diverge in
later changes.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.h | 42 +++++++++++++++++++++++++++++++----------
 1 file changed, 32 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index 03fb6c0..969ecc0 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -87,8 +87,10 @@ extern void efx_mcdi_sensor_event(struct efx_nic *efx, efx_qword_t *ev);
 
 #define MCDI_DECLARE_BUF(_name, _len)					\
 	u8 _name[ALIGN(_len, 4)]
+#define _MCDI_PTR(_buf, _offset)					\
+	((u8 *)(_buf) + (_offset))
 #define MCDI_PTR(_buf, _field)						\
-	((u8 *)(_buf) + MC_CMD_ ## _field ## _OFST)
+	_MCDI_PTR(_buf, MC_CMD_ ## _field ## _OFST)
 #define _MCDI_DWORD(_buf, _field)					\
 	((efx_dword_t *)MCDI_PTR(_buf, _field))
 
@@ -102,18 +104,38 @@ extern void efx_mcdi_sensor_event(struct efx_nic *efx, efx_qword_t *ev);
 #define MCDI_QWORD(_buf, _field)					\
 	(EFX_DWORD_FIELD(_MCDI_DWORD(_buf, _field)[0], EFX_DWORD_0) |	\
 	(u64)EFX_DWORD_FIELD(_MCDI_DWORD(_buf, _field)[1], EFX_DWORD_0) << 32)
+#define MCDI_FIELD(_ptr, _type, _field)					\
+	EFX_EXTRACT_DWORD(						\
+		*(efx_dword_t *)					\
+		_MCDI_PTR(_ptr, MC_CMD_ ## _type ## _ ## _field ## _OFST & ~3),\
+		MC_CMD_ ## _type ## _ ## _field ## _LBN & 0x1f,	\
+		(MC_CMD_ ## _type ## _ ## _field ## _LBN & 0x1f) +	\
+		MC_CMD_ ## _type ## _ ## _field ## _WIDTH - 1)
 
-#define MCDI_ARRAY_PTR(_buf, _field, _type, _index)			\
+#define _MCDI_ARRAY_PTR(_buf, _field, _index)				\
 	(MCDI_PTR(_buf, _field) +					\
-	 (_index) * MC_CMD_ ## _type ## _TYPEDEF_LEN)
+	 (_index) * MC_CMD_ ## _field ## _LEN)
+#define MCDI_DECLARE_STRUCT_PTR(_name)					\
+	u8 *_name
+#define MCDI_ARRAY_STRUCT_PTR _MCDI_ARRAY_PTR
+#define MCDI_VAR_ARRAY_LEN(_len, _field)				\
+	min_t(size_t, MC_CMD_ ## _field ## _MAXNUM,			\
+	      ((_len) - MC_CMD_ ## _field ## _OFST) / MC_CMD_ ## _field ## _LEN)
+#define MCDI_ARRAY_WORD(_buf, _field, _index)				\
+	(BUILD_BUG_ON_ZERO(MC_CMD_ ## _field ## _LEN != 2) +		\
+	 le16_to_cpu(*(__force const __le16 *)				\
+		     _MCDI_ARRAY_PTR(_buf, _field, _index)))
+#define _MCDI_ARRAY_DWORD(_buf, _field, _index)				\
+	(BUILD_BUG_ON_ZERO(MC_CMD_ ## _field ## _LEN != 4) +		\
+	 (efx_dword_t *)_MCDI_ARRAY_PTR(_buf, _field, _index))
+#define MCDI_SET_ARRAY_DWORD(_buf, _field, _index, _value)		\
+	EFX_SET_DWORD_FIELD(*_MCDI_ARRAY_DWORD(_buf, _field, _index),	\
+			    EFX_DWORD_0, _value)
+#define MCDI_ARRAY_DWORD(_buf, _field, _index)				\
+	EFX_DWORD_FIELD(*_MCDI_ARRAY_DWORD(_buf, _field, _index), EFX_DWORD_0)
 #define MCDI_ARRAY_FIELD(_buf, _field1, _type, _index, _field2)		\
-	EFX_EXTRACT_DWORD(						\
-		*((efx_dword_t *)					\
-		  (MCDI_ARRAY_PTR(_buf, _field1, _type, _index) +	\
-		   (MC_CMD_ ## _type ## _TYPEDEF_ ## _field2 ## _OFST & ~3))), \
-		MC_CMD_ ## _type ## _TYPEDEF_ ## _field2 ## _LBN & 0x1f, \
-		(MC_CMD_ ## _type ## _TYPEDEF_ ## _field2 ## _LBN & 0x1f) + \
-		MC_CMD_ ## _type ## _TYPEDEF_ ## _field2 ## _WIDTH - 1)
+	MCDI_FIELD(MCDI_ARRAY_STRUCT_PTR(_buf, _field1, _index),	\
+		   _type ## _TYPEDEF, _field2)
 
 #define MCDI_EVENT_FIELD(_ev, _field)			\
 	EFX_QWORD_FIELD(_ev, MCDI_EVENT_ ## _field)


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
