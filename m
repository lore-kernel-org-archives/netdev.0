From: Matthew Leach <matthew.leach@arm.com>
Subject: [PATCH 14/14] net: smc91x: dont't use SMC_outw for fixing up halfword-aligned data
Date: Fri, 11 Oct 2013 14:52:20 +0100
Message-ID: <1381499540-28794-15-git-send-email-matthew.leach@arm.com>
References: <1381499540-28794-1-git-send-email-matthew.leach@arm.com>
Cc: ankit.jindal@linaro.org, steve.mcintyre@linaro.org,
	tushar.jagad@linaro.org, will.deacon@arm.com,
	catalin.marinas@arm.com, <netdev@vger.kernel.org>,
	Nicolas Pitre <nico@fluxnic.net>,
	"David S. Miller" <davem@davemloft.net>
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:52444 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751751Ab3JKNxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 09:53:39 -0400
In-Reply-To: <1381499540-28794-1-git-send-email-matthew.leach@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Will Deacon <will.deacon@arm.com>

SMC_outw invokes an endian-aware I/O accessor, which may change the data
endianness before writing to the device. This is not suitable for data
transfers where the memory buffer is simply a string of bytes that does
not require any byte-swapping.

This patches fixes the smc91x SMC_PUSH_DATA macro so that it uses the
string I/O accessor for outputting the leading or trailing halfwords on
halfword-aligned buffers.

Cc: <netdev@vger.kernel.org>
Cc: Nicolas Pitre <nico@fluxnic.net>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Will Deacon <will.deacon@arm.com>
---
 drivers/net/ethernet/smsc/smc91x.h |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc91x.h b/drivers/net/ethernet/smsc/smc91x.h
index 5730fe2..98eedb9 100644
--- a/drivers/net/ethernet/smsc/smc91x.h
+++ b/drivers/net/ethernet/smsc/smc91x.h
@@ -1124,8 +1124,7 @@ static const char * chip_ids[ 16 ] =  {
 			void __iomem *__ioaddr = ioaddr;		\
 			if (__len >= 2 && (unsigned long)__ptr & 2) {	\
 				__len -= 2;				\
-				SMC_outw(*(u16 *)__ptr, ioaddr,		\
-					DATA_REG(lp));		\
+				SMC_outsw(ioaddr, DATA_REG(lp), __ptr, 1); \
 				__ptr += 2;				\
 			}						\
 			if (SMC_CAN_USE_DATACS && lp->datacs)		\
@@ -1133,8 +1132,7 @@ static const char * chip_ids[ 16 ] =  {
 			SMC_outsl(__ioaddr, DATA_REG(lp), __ptr, __len>>2); \
 			if (__len & 2) {				\
 				__ptr += (__len & ~3);			\
-				SMC_outw(*((u16 *)__ptr), ioaddr,	\
-					 DATA_REG(lp));		\
+				SMC_outsw(ioaddr, DATA_REG(lp), __ptr, 1); \
 			}						\
 		} else if (SMC_16BIT(lp))				\
 			SMC_outsw(ioaddr, DATA_REG(lp), p, (l) >> 1);	\
-- 
1.7.9.5
