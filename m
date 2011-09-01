From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 2/2] sfc: Use 64-bit writes for TX push where possible
Date: Thu, 01 Sep 2011 23:09:59 +0100
Message-ID: <1314915000.2733.16.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:54772 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932190Ab1IAWKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 18:10:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was originally done as part of commit
65f0b417dee94f779ce9b77102b7d73c93723b39 ("sfc: Use write-combining to
reduce TX latency"), but that had to be reverted.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/io.h |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sfc/io.h b/drivers/net/sfc/io.h
index dc45110..751d1ec 100644
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
@@ -237,12 +237,13 @@ static inline void _efx_writeo_page(struct efx_nic *efx, efx_oword_t *value,
 
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
 }
 #define efx_writeo_page(efx, value, reg, page)				\
 	_efx_writeo_page(efx, value,					\
-- 
1.7.4.4


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
