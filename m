From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCHv3 wl-drv-next 2/2] mt7601u: use linux/bitfield.h
Date: Fri,  1 Jul 2016 22:26:49 +0100
Message-ID: <1467408409-24224-3-git-send-email-jakub.kicinski@netronome.com>
References: <1467408409-24224-1-git-send-email-jakub.kicinski@netronome.com>
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org, nbd@nbd.name,
	linux-kernel@vger.kernel.org,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: kvalo@codeaurora.org, linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467408409-24224-1-git-send-email-jakub.kicinski@netronome.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the newly added linux/bitfield.h.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/wireless/mediatek/mt7601u/dma.h     |  2 -
 drivers/net/wireless/mediatek/mt7601u/mt7601u.h |  5 +-
 drivers/net/wireless/mediatek/mt7601u/util.h    | 77 -------------------------
 3 files changed, 4 insertions(+), 80 deletions(-)
 delete mode 100644 drivers/net/wireless/mediatek/mt7601u/util.h

diff --git a/drivers/net/wireless/mediatek/mt7601u/dma.h b/drivers/net/wireless/mediatek/mt7601u/dma.h
index 978e8a90b87f..166ac71905d2 100644
--- a/drivers/net/wireless/mediatek/mt7601u/dma.h
+++ b/drivers/net/wireless/mediatek/mt7601u/dma.h
@@ -18,8 +18,6 @@
 #include <asm/unaligned.h>
 #include <linux/skbuff.h>
 
-#include "util.h"
-
 #define MT_DMA_HDR_LEN			4
 #define MT_RX_INFO_LEN			4
 #define MT_FCE_INFO_LEN			4
diff --git a/drivers/net/wireless/mediatek/mt7601u/mt7601u.h b/drivers/net/wireless/mediatek/mt7601u/mt7601u.h
index 428bd2f10b7b..5ef62e02ce66 100644
--- a/drivers/net/wireless/mediatek/mt7601u/mt7601u.h
+++ b/drivers/net/wireless/mediatek/mt7601u/mt7601u.h
@@ -15,6 +15,7 @@
 #ifndef MT7601U_H
 #define MT7601U_H
 
+#include <linux/bitfield.h>
 #include <linux/kernel.h>
 #include <linux/device.h>
 #include <linux/mutex.h>
@@ -24,7 +25,6 @@
 #include <linux/debugfs.h>
 
 #include "regs.h"
-#include "util.h"
 
 #define MT_CALIBRATE_INTERVAL		(4 * HZ)
 
@@ -282,6 +282,9 @@ struct mt7601u_rxwi;
 
 extern const struct ieee80211_ops mt7601u_ops;
 
+#define MT76_SET	FIELD_PUT
+#define MT76_GET	FIELD_GET
+
 void mt7601u_init_debugfs(struct mt7601u_dev *dev);
 
 u32 mt7601u_rr(struct mt7601u_dev *dev, u32 offset);
diff --git a/drivers/net/wireless/mediatek/mt7601u/util.h b/drivers/net/wireless/mediatek/mt7601u/util.h
deleted file mode 100644
index b89140bf1210..000000000000
--- a/drivers/net/wireless/mediatek/mt7601u/util.h
+++ /dev/null
@@ -1,77 +0,0 @@
-/*
- * Copyright (C) 2014 Felix Fietkau <nbd@openwrt.org>
- * Copyright (C) 2004 - 2009 Ivo van Doorn <IvDoorn@gmail.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2
- * as published by the Free Software Foundation
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- */
-
-#ifndef __MT76_UTIL_H
-#define __MT76_UTIL_H
-
-/*
- * Power of two check, this will check
- * if the mask that has been given contains and contiguous set of bits.
- * Note that we cannot use the is_power_of_2() function since this
- * check must be done at compile-time.
- */
-#define is_power_of_two(x)	( !((x) & ((x)-1)) )
-#define low_bit_mask(x)		( ((x)-1) & ~(x) )
-#define is_valid_mask(x)	is_power_of_two(1LU + (x) + low_bit_mask(x))
-
-/*
- * Macros to find first set bit in a variable.
- * These macros behave the same as the __ffs() functions but
- * the most important difference that this is done during
- * compile-time rather then run-time.
- */
-#define compile_ffs2(__x) \
-	__builtin_choose_expr(((__x) & 0x1), 0, 1)
-
-#define compile_ffs4(__x) \
-	__builtin_choose_expr(((__x) & 0x3), \
-			      (compile_ffs2((__x))), \
-			      (compile_ffs2((__x) >> 2) + 2))
-
-#define compile_ffs8(__x) \
-	__builtin_choose_expr(((__x) & 0xf), \
-			      (compile_ffs4((__x))), \
-			      (compile_ffs4((__x) >> 4) + 4))
-
-#define compile_ffs16(__x) \
-	__builtin_choose_expr(((__x) & 0xff), \
-			      (compile_ffs8((__x))), \
-			      (compile_ffs8((__x) >> 8) + 8))
-
-#define compile_ffs32(__x) \
-	__builtin_choose_expr(((__x) & 0xffff), \
-			      (compile_ffs16((__x))), \
-			      (compile_ffs16((__x) >> 16) + 16))
-
-/*
- * This macro will check the requirements for the FIELD{8,16,32} macros
- * The mask should be a constant non-zero contiguous set of bits which
- * does not exceed the given typelimit.
- */
-#define FIELD_CHECK(__mask) \
-	BUILD_BUG_ON(!(__mask) || !is_valid_mask(__mask))
-
-#define MT76_SET(_mask, _val)						\
-	({								\
-		FIELD_CHECK(_mask);					\
-		(((u32) (_val)) << compile_ffs32(_mask)) & _mask;	\
-	})
-
-#define MT76_GET(_mask, _val)						\
-	({								\
-		FIELD_CHECK(_mask);					\
-		(u32) (((_val) & _mask) >> compile_ffs32(_mask));	\
-	})
-
-#endif
-- 
1.9.1
