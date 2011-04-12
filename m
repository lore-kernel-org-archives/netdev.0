From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6 3/3] sfc: Use rmb() to ensure reads occur in order
Date: Wed, 13 Apr 2011 00:50:34 +0100
Message-ID: <1302652234.2880.31.camel@bwh-desktop>
References: <1302652065.2880.28.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:12641 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932095Ab1DLXuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 19:50:37 -0400
In-Reply-To: <1302652065.2880.28.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Turton <nturton@solarflare.com>

Enabling write-combining may also enable read reordering.  The BIU is
only guaranteed to read from a 128-bit CSR or 64-bit SRAM word when
the host reads from its lowest address; otherwise the BIU may use the
latched value.  Therefore we need to reinstate the read memory
barriers after the first read operation for each CSR or SRAM word.

Signed-off-by; Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/io.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/io.h b/drivers/net/sfc/io.h
index d9d8c2e..cc97880 100644
--- a/drivers/net/sfc/io.h
+++ b/drivers/net/sfc/io.h
@@ -152,6 +152,7 @@ static inline void efx_reado(struct efx_nic *efx, efx_oword_t *value,
 
 	spin_lock_irqsave(&efx->biu_lock, flags);
 	value->u32[0] = _efx_readd(efx, reg + 0);
+	rmb();
 	value->u32[1] = _efx_readd(efx, reg + 4);
 	value->u32[2] = _efx_readd(efx, reg + 8);
 	value->u32[3] = _efx_readd(efx, reg + 12);
@@ -174,6 +175,7 @@ static inline void efx_sram_readq(struct efx_nic *efx, void __iomem *membase,
 	value->u64[0] = (__force __le64)__raw_readq(membase + addr);
 #else
 	value->u32[0] = (__force __le32)__raw_readl(membase + addr);
+	rmb();
 	value->u32[1] = (__force __le32)__raw_readl(membase + addr + 4);
 #endif
 	spin_unlock_irqrestore(&efx->biu_lock, flags);
-- 
1.7.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

