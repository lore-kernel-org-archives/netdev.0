From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6] sfc: Use write-combining to reduce TX latency
Date: Mon, 07 Mar 2011 23:25:00 +0000
Message-ID: <1299540300.2522.47.camel@bwh-desktop>
References: <1299540194.2522.46.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:3538 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755982Ab1CGXZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 18:25:03 -0500
In-Reply-To: <1299540194.2522.46.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on work by Neil Turton <nturton@solarflare.com> and
Kieran Mansley <kmansley@solarflare.com>.

The BIU has now been verified to handle 3- and 4-dword writes within a
single 128-bit register correctly.  This means we can enable write-
combining and only insert write barriers between writes to distinct
registers.

This has been observed to save about 0.5 us when pushing a TX
descriptor to an empty TX queue.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c  |    4 ++--
 drivers/net/sfc/io.h   |   13 +++++++++----
 drivers/net/sfc/mcdi.c |    9 +++++----
 3 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index d563049..b8bd936 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1104,8 +1104,8 @@ static int efx_init_io(struct efx_nic *efx)
 		rc = -EIO;
 		goto fail3;
 	}
-	efx->membase = ioremap_nocache(efx->membase_phys,
-				       efx->type->mem_map_size);
+	efx->membase = ioremap_wc(efx->membase_phys,
+				  efx->type->mem_map_size);
 	if (!efx->membase) {
 		netif_err(efx, probe, efx->net_dev,
 			  "could not map memory BAR at %llx+%x\n",
diff --git a/drivers/net/sfc/io.h b/drivers/net/sfc/io.h
index dc45110..d9d8c2e 100644
--- a/drivers/net/sfc/io.h
+++ b/drivers/net/sfc/io.h
@@ -48,9 +48,9 @@
  *   replacing the low 96 bits with zero does not affect functionality.
  * - If the host writes to the last dword address of such a register
  *   (i.e. the high 32 bits) the underlying register will always be
- *   written.  If the collector does not hold values for the low 96
- *   bits of the register, they will be written as zero.  Writing to
- *   the last qword does not have this effect and must not be done.
+ *   written.  If the collector and the current write together do not
+ *   provide values for all 128 bits of the register, the low 96 bits
+ *   will be written as zero.
  * - If the host writes to the address of any other part of such a
  *   register while the collector already holds values for some other
  *   register, the write is discarded and the collector maintains its
@@ -103,6 +103,7 @@ static inline void efx_writeo(struct efx_nic *efx, efx_oword_t *value,
 	_efx_writed(efx, value->u32[2], reg + 8);
 	_efx_writed(efx, value->u32[3], reg + 12);
 #endif
+	wmb();
 	mmiowb();
 	spin_unlock_irqrestore(&efx->biu_lock, flags);
 }
@@ -125,6 +126,7 @@ static inline void efx_sram_writeq(struct efx_nic *efx, void __iomem *membase,
 	__raw_writel((__force u32)value->u32[0], membase + addr);
 	__raw_writel((__force u32)value->u32[1], membase + addr + 4);
 #endif
+	wmb();
 	mmiowb();
 	spin_unlock_irqrestore(&efx->biu_lock, flags);
 }
@@ -139,6 +141,7 @@ static inline void efx_writed(struct efx_nic *efx, efx_dword_t *value,
 
 	/* No lock required */
 	_efx_writed(efx, value->u32[0], reg);
+	wmb();
 }
 
 /* Read a 128-bit CSR, locking as appropriate. */
@@ -237,12 +240,14 @@ static inline void _efx_writeo_page(struct efx_nic *efx, efx_oword_t *value,
 
 #ifdef EFX_USE_QWORD_IO
 	_efx_writeq(efx, value->u64[0], reg + 0);
+	_efx_writeq(efx, value->u64[1], reg + 8);
 #else
 	_efx_writed(efx, value->u32[0], reg + 0);
 	_efx_writed(efx, value->u32[1], reg + 4);
-#endif
 	_efx_writed(efx, value->u32[2], reg + 8);
 	_efx_writed(efx, value->u32[3], reg + 12);
+#endif
+	wmb();
 }
 #define efx_writeo_page(efx, value, reg, page)				\
 	_efx_writeo_page(efx, value,					\
diff --git a/drivers/net/sfc/mcdi.c b/drivers/net/sfc/mcdi.c
index 8bba895..5e118f0 100644
--- a/drivers/net/sfc/mcdi.c
+++ b/drivers/net/sfc/mcdi.c
@@ -94,14 +94,15 @@ static void efx_mcdi_copyin(struct efx_nic *efx, unsigned cmd,
 
 	efx_writed(efx, &hdr, pdu);
 
-	for (i = 0; i < inlen; i += 4)
+	for (i = 0; i < inlen; i += 4) {
 		_efx_writed(efx, *((__le32 *)(inbuf + i)), pdu + 4 + i);
-
-	/* Ensure the payload is written out before the header */
-	wmb();
+		/* use wmb() within loop to inhibit write combining */
+		wmb();
+	}
 
 	/* ring the doorbell with a distinctive value */
 	_efx_writed(efx, (__force __le32) 0x45789abc, doorbell);
+	wmb();
 }
 
 static void efx_mcdi_copyout(struct efx_nic *efx, u8 *outbuf, size_t outlen)
-- 
1.7.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

