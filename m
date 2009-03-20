From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 4/5] sfc: Optimise falcon_writel_page_locked() for page > 0
Date: Fri, 20 Mar 2009 23:27:13 +0000
Message-ID: <1237591633.3217.12.camel@achroite>
References: <1237591540.3217.6.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:36631 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763026AbZCTX1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 19:27:16 -0400
In-Reply-To: <1237591540.3217.6.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bug this function works around only applies to the first set of
page-mapped registers; other pages can be written without locking.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon_io.h |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/sfc/falcon_io.h b/drivers/net/sfc/falcon_io.h
index c16da31..8883092 100644
--- a/drivers/net/sfc/falcon_io.h
+++ b/drivers/net/sfc/falcon_io.h
@@ -238,18 +238,21 @@ static inline void falcon_writel_page(struct efx_nic *efx, efx_dword_t *value,
 /* Write dword to Falcon page-mapped register with an extra lock.
  *
  * As for falcon_writel_page(), but for a register that suffers from
- * SFC bug 3181. Take out a lock so the BIU collector cannot be
- * confused. */
+ * SFC bug 3181.  If writing to page 0, take out a lock so the BIU
+ * collector cannot be confused.
+ */
 static inline void falcon_writel_page_locked(struct efx_nic *efx,
 					     efx_dword_t *value,
 					     unsigned int reg,
 					     unsigned int page)
 {
-	unsigned long flags;
+	unsigned long flags = 0;
 
-	spin_lock_irqsave(&efx->biu_lock, flags);
+	if (page == 0)
+		spin_lock_irqsave(&efx->biu_lock, flags);
 	falcon_writel(efx, value, FALCON_PAGED_REG(page, reg));
-	spin_unlock_irqrestore(&efx->biu_lock, flags);
+	if (page == 0)
+		spin_unlock_irqrestore(&efx->biu_lock, flags);
 }
 
 #endif /* EFX_FALCON_IO_H */

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

