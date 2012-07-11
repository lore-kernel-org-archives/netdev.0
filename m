From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 01/11] sfc: Implement 128-bit writes for
 efx_writeo_page
Date: Thu, 12 Jul 2012 00:15:18 +0100
Message-ID: <1342048518.2613.60.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342048389.2613.59.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:34154 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751552Ab2GKXPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 19:15:21 -0400
In-Reply-To: <1342048389.2613.59.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for writing a TX descriptor to the NIC in one PCIe
transaction on x86_64 machines.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/bitfield.h |    5 +++
 drivers/net/ethernet/sfc/io.h       |   51 +++++++++++++++++++++++++++++++++++
 2 files changed, 56 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/sfc/bitfield.h b/drivers/net/ethernet/sfc/bitfield.h
index b26a954..8f8af3e 100644
--- a/drivers/net/ethernet/sfc/bitfield.h
+++ b/drivers/net/ethernet/sfc/bitfield.h
@@ -69,6 +69,10 @@
 	((width) == 32 ? ~((u32) 0) :		\
 	 (((((u32) 1) << (width))) - 1))
 
+typedef struct {
+        __le64 b, a;
+} efx_le_128;
+
 /* A doubleword (i.e. 4 byte) datatype - little-endian in HW */
 typedef union efx_dword {
 	__le32 u32[1];
@@ -83,6 +87,7 @@ typedef union efx_qword {
 
 /* An octword (eight-word, i.e. 16 byte) datatype - little-endian in HW */
 typedef union efx_oword {
+	efx_le_128 u128;
 	__le64 u64[2];
 	efx_qword_t qword[2];
 	__le32 u32[4];
diff --git a/drivers/net/ethernet/sfc/io.h b/drivers/net/ethernet/sfc/io.h
index 751d1ec..0868aef 100644
--- a/drivers/net/ethernet/sfc/io.h
+++ b/drivers/net/ethernet/sfc/io.h
@@ -57,10 +57,57 @@
  *   current state.
  */
 
+#ifdef CONFIG_X86_64
+#define EFX_USE_SSE_IO 1
+#endif
+
 #if BITS_PER_LONG == 64
 #define EFX_USE_QWORD_IO 1
 #endif
 
+#ifdef EFX_USE_SSE_IO
+
+static inline void _efx_writeo(struct efx_nic *efx, efx_le_128 value,
+			       unsigned int reg)
+{
+	unsigned long cr0;
+	efx_le_128 xmm_save[1];
+	void __iomem *addr = efx->membase + reg;
+
+	preempt_disable();
+
+	/* Save the xmm0 register to stack */
+	asm volatile(
+		"movq %%cr0,%0          ;\n\t"
+		"clts                   ;\n\t"
+		"movups %%xmm0,(%1)     ;\n\t"
+		: "=&r" (cr0)
+		: "r" (xmm_save)
+		: "memory");
+
+	/* First read the data into register xmm0
+	 * Then write this out to the address that was given
+	 */
+	asm volatile(
+		"movdqu %1,%%xmm0       ;\n\t"
+		"movdqa %%xmm0,%0       ;\n\t"
+		: "=m" (*(unsigned long __force *)addr)
+		: "m" (value)
+		: "memory");
+
+	/* Restore the xmm0 register */
+	asm volatile(
+		"sfence                 ;\n\t"
+		"movups (%1),%%xmm0     ;\n\t"
+		"movq   %0,%%cr0        ;\n\t"
+		:
+		: "r" (cr0), "r" (xmm_save)
+		: "memory");
+
+	preempt_enable();
+}
+#endif /* EFX_USE_SSE_IO */
+
 #ifdef EFX_USE_QWORD_IO
 static inline void _efx_writeq(struct efx_nic *efx, __le64 value,
 				  unsigned int reg)
@@ -235,6 +282,9 @@ static inline void _efx_writeo_page(struct efx_nic *efx, efx_oword_t *value,
 		   "writing register %x with " EFX_OWORD_FMT "\n", reg,
 		   EFX_OWORD_VAL(*value));
 
+#ifdef EFX_USE_SSE_IO
+	_efx_writeo(efx, value->u128, reg + 0);
+#else
 #ifdef EFX_USE_QWORD_IO
 	_efx_writeq(efx, value->u64[0], reg + 0);
 	_efx_writeq(efx, value->u64[1], reg + 8);
@@ -244,6 +294,7 @@ static inline void _efx_writeo_page(struct efx_nic *efx, efx_oword_t *value,
 	_efx_writed(efx, value->u32[2], reg + 8);
 	_efx_writed(efx, value->u32[3], reg + 12);
 #endif
+#endif
 }
 #define efx_writeo_page(efx, value, reg, page)				\
 	_efx_writeo_page(efx, value,					\
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
