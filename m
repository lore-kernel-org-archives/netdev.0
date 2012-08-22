From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 3/3] sfc: Use __raw_writeo() to perform TX descriptor push
 where possible
Date: Wed, 22 Aug 2012 02:26:44 +0100
Message-ID: <1345598804.2659.78.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345598275.2659.71.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<x86@kernel.org>
To: David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:13319 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754737Ab2HVB0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 21:26:47 -0400
In-Reply-To: <1345598275.2659.71.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the new __raw_writeo() function for TX descriptor push where
available.  This means we now use only a single PCIe transaction
on x86_64 (vs 2 before), reducing TX latency slightly.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
David,

Assuming the previous 2 patches are accepted for x86, I expect you'll
still want to take this into the net-next tree.  So perhaps they should
go onto a separate branch that you can pull?

Ben.

 drivers/net/ethernet/sfc/bitfield.h |    3 +++
 drivers/net/ethernet/sfc/io.h       |   18 ++++++++++++++++--
 2 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/bitfield.h b/drivers/net/ethernet/sfc/bitfield.h
index b26a954..5feeba2 100644
--- a/drivers/net/ethernet/sfc/bitfield.h
+++ b/drivers/net/ethernet/sfc/bitfield.h
@@ -83,6 +83,9 @@ typedef union efx_qword {
 
 /* An octword (eight-word, i.e. 16 byte) datatype - little-endian in HW */
 typedef union efx_oword {
+#ifdef HAVE_INT128
+	__le128 u128;
+#endif
 	__le64 u64[2];
 	efx_qword_t qword[2];
 	__le32 u32[4];
diff --git a/drivers/net/ethernet/sfc/io.h b/drivers/net/ethernet/sfc/io.h
index 751d1ec..fbcdc6d 100644
--- a/drivers/net/ethernet/sfc/io.h
+++ b/drivers/net/ethernet/sfc/io.h
@@ -57,10 +57,22 @@
  *   current state.
  */
 
-#if BITS_PER_LONG == 64
+#if defined(writeo)
+#define EFX_USE_OWORD_IO 1
+#endif
+
+#if defined(readq) && defined(writeq)
 #define EFX_USE_QWORD_IO 1
 #endif
 
+#ifdef EFX_USE_OWORD_IO
+static inline void _efx_writeo(struct efx_nic *efx, __le128 value,
+			       unsigned int reg)
+{
+	__raw_writeo((__force u128)value, efx->membase + reg);
+}
+#endif
+
 #ifdef EFX_USE_QWORD_IO
 static inline void _efx_writeq(struct efx_nic *efx, __le64 value,
 				  unsigned int reg)
@@ -235,7 +247,9 @@ static inline void _efx_writeo_page(struct efx_nic *efx, efx_oword_t *value,
 		   "writing register %x with " EFX_OWORD_FMT "\n", reg,
 		   EFX_OWORD_VAL(*value));
 
-#ifdef EFX_USE_QWORD_IO
+#if defined(EFX_USE_OWORD_IO)
+	_efx_writeo(efx, value->u128, reg);
+#elif defined(EFX_USE_QWORD_IO)
 	_efx_writeq(efx, value->u64[0], reg + 0);
 	_efx_writeq(efx, value->u64[1], reg + 8);
 #else
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
