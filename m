From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next] qed: Fix address macros
Date: Tue, 23 Aug 2016 07:19:50 +0300
Message-ID: <1471925990-30782-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:16899 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752673AbcHWET5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 00:19:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Last FW submission reverted various macros into an older form,
where they generate compilation warnings on some architectures.

Bring back the newer macros instead.

Fixes: 05fafbfb3d77 ("qed: utilize FW 8.10.10.0")
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
Hi Dave,

Please apply this to 'net-next'.

Thanks,
Yuval
---
 include/linux/qed/common_hsi.h | 22 ++++++++--------------
 1 file changed, 8 insertions(+), 14 deletions(-)

diff --git a/include/linux/qed/common_hsi.h b/include/linux/qed/common_hsi.h
index d306e0b..ae92aba 100644
--- a/include/linux/qed/common_hsi.h
+++ b/include/linux/qed/common_hsi.h
@@ -13,23 +13,17 @@
 #include <linux/slab.h>
 
 /* dma_addr_t manip */
-#define DMA_LO(x)               ((u32)(((dma_addr_t)(x)) & 0xffffffff))
-#define DMA_HI(x)               ((u32)(((dma_addr_t)(x)) >> 32))
-
-#define DMA_LO_LE(x)            cpu_to_le32(DMA_LO(x))
-#define DMA_HI_LE(x)            cpu_to_le32(DMA_HI(x))
-
-/* It's assumed that whoever includes this has previously included an hsi
- * file defining the regpair.
- */
-#define DMA_REGPAIR_LE(x, val)  (x).hi	= DMA_HI_LE((val)); \
-	(x).lo				= DMA_LO_LE((val))
+#define DMA_LO_LE(x)		cpu_to_le32(lower_32_bits(x))
+#define DMA_HI_LE(x)		cpu_to_le32(upper_32_bits(x))
+#define DMA_REGPAIR_LE(x, val)	do { \
+					(x).hi = DMA_HI_LE((val)); \
+					(x).lo = DMA_LO_LE((val)); \
+				} while (0)
 
 #define HILO_GEN(hi, lo, type)  ((((type)(hi)) << 32) + (lo))
-#define HILO_DMA(hi, lo)        HILO_GEN(hi, lo, dma_addr_t)
-#define HILO_64(hi, lo)         HILO_GEN(hi, lo, u64)
-#define HILO_DMA_REGPAIR(regpair)       (HILO_DMA(regpair.hi, regpair.lo))
+#define HILO_64(hi, lo) HILO_GEN((le32_to_cpu(hi)), (le32_to_cpu(lo)), u64)
 #define HILO_64_REGPAIR(regpair)        (HILO_64(regpair.hi, regpair.lo))
+#define HILO_DMA_REGPAIR(regpair)	((dma_addr_t)HILO_64_REGPAIR(regpair))
 
 #ifndef __COMMON_HSI__
 #define __COMMON_HSI__
-- 
1.9.3
