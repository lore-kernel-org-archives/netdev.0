From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 06/10] sfc: Remove locking from implementation
 of efx_writeo_paged()
Date: Fri, 10 Dec 2010 17:38:47 +0000
Message-ID: <1292002727.11673.20.camel@bwh-desktop>
References: <1292002527.11673.14.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:26955 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754150Ab0LJRiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 12:38:50 -0500
In-Reply-To: <1292002527.11673.14.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is not necessary to serialise writes to the paged 128-bit
registers.  However, if we don't then we must always write the last
dword separately, not as part of a qword write.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/io.h |   15 ++++++++++++++-
 1 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/io.h b/drivers/net/sfc/io.h
index 7f3adf2..6da4ae2 100644
--- a/drivers/net/sfc/io.h
+++ b/drivers/net/sfc/io.h
@@ -229,7 +229,20 @@ static inline void efx_readd_table(struct efx_nic *efx, efx_dword_t *value,
 static inline void _efx_writeo_page(struct efx_nic *efx, efx_oword_t *value,
 				    unsigned int reg, unsigned int page)
 {
-	efx_writeo(efx, value, EFX_PAGED_REG(page, reg));
+	reg = EFX_PAGED_REG(page, reg);
+
+	netif_vdbg(efx, hw, efx->net_dev,
+		   "writing register %x with " EFX_OWORD_FMT "\n", reg,
+		   EFX_OWORD_VAL(*value));
+
+#ifdef EFX_USE_QWORD_IO
+	_efx_writeq(efx, value->u64[0], reg + 0);
+#else
+	_efx_writed(efx, value->u32[0], reg + 0);
+	_efx_writed(efx, value->u32[1], reg + 4);
+#endif
+	_efx_writed(efx, value->u32[2], reg + 8);
+	_efx_writed(efx, value->u32[3], reg + 12);
 }
 #define efx_writeo_page(efx, value, reg, page)				\
 	_efx_writeo_page(efx, value,					\
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

