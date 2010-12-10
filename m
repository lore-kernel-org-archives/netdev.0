From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 05/10] sfc: Add compile-time checks for
 correctness of paged register writes
Date: Fri, 10 Dec 2010 17:38:37 +0000
Message-ID: <1292002717.11673.19.camel@bwh-desktop>
References: <1292002527.11673.14.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:26932 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197Ab0LJRil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 12:38:41 -0500
In-Reply-To: <1292002527.11673.14.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/io.h |   31 +++++++++++++++++++++++--------
 1 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/drivers/net/sfc/io.h b/drivers/net/sfc/io.h
index 896b31e..7f3adf2 100644
--- a/drivers/net/sfc/io.h
+++ b/drivers/net/sfc/io.h
@@ -226,29 +226,40 @@ static inline void efx_readd_table(struct efx_nic *efx, efx_dword_t *value,
 	((page) * EFX_PAGE_BLOCK_SIZE + (reg))
 
 /* Write the whole of RX_DESC_UPD or TX_DESC_UPD */
-static inline void efx_writeo_page(struct efx_nic *efx, efx_oword_t *value,
-				   unsigned int reg, unsigned int page)
+static inline void _efx_writeo_page(struct efx_nic *efx, efx_oword_t *value,
+				    unsigned int reg, unsigned int page)
 {
 	efx_writeo(efx, value, EFX_PAGED_REG(page, reg));
 }
+#define efx_writeo_page(efx, value, reg, page)				\
+	_efx_writeo_page(efx, value,					\
+			 reg +						\
+			 BUILD_BUG_ON_ZERO((reg) != 0x830 && (reg) != 0xa10), \
+			 page)
 
 /* Write a page-mapped 32-bit CSR (EVQ_RPTR or the high bits of
  * RX_DESC_UPD or TX_DESC_UPD)
  */
-static inline void efx_writed_page(struct efx_nic *efx, efx_dword_t *value,
-				   unsigned int reg, unsigned int page)
+static inline void _efx_writed_page(struct efx_nic *efx, efx_dword_t *value,
+				    unsigned int reg, unsigned int page)
 {
 	efx_writed(efx, value, EFX_PAGED_REG(page, reg));
 }
+#define efx_writed_page(efx, value, reg, page)				\
+	_efx_writed_page(efx, value,					\
+			 reg +						\
+			 BUILD_BUG_ON_ZERO((reg) != 0x400 && (reg) != 0x83c \
+					   && (reg) != 0xa1c),		\
+			 page)
 
 /* Write TIMER_COMMAND.  This is a page-mapped 32-bit CSR, but a bug
  * in the BIU means that writes to TIMER_COMMAND[0] invalidate the
  * collector register.
  */
-static inline void efx_writed_page_locked(struct efx_nic *efx,
-					  efx_dword_t *value,
-					  unsigned int reg,
-					  unsigned int page)
+static inline void _efx_writed_page_locked(struct efx_nic *efx,
+					   efx_dword_t *value,
+					   unsigned int reg,
+					   unsigned int page)
 {
 	unsigned long flags __attribute__ ((unused));
 
@@ -260,5 +271,9 @@ static inline void efx_writed_page_locked(struct efx_nic *efx,
 		efx_writed(efx, value, EFX_PAGED_REG(page, reg));
 	}
 }
+#define efx_writed_page_locked(efx, value, reg, page)			\
+	_efx_writed_page_locked(efx, value,				\
+				reg + BUILD_BUG_ON_ZERO((reg) != 0x420), \
+				page)
 
 #endif /* EFX_IO_H */
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

