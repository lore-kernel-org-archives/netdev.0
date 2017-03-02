From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 01/26] compiler: introduce noinline_for_kasan annotation
Date: Thu,  2 Mar 2017 17:38:09 +0100
Message-ID: <20170302163834.2273519-2-arnd@arndb.de>
References: <20170302163834.2273519-1-arnd@arndb.de>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-media@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        kernel-build-reports@lists.linaro.org,
        "David S . Miller" <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>
To: kasan-dev@googlegroups.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:61372 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754117AbdCBRLS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 12:11:18 -0500
In-Reply-To: <20170302163834.2273519-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When CONFIG_KASAN is set, we can run into some code that uses incredible
amounts of kernel stack:

drivers/staging/dgnc/dgnc_neo.c:1056:1: error: the frame size of 11112 bytes is larger than 2048 bytes [-Werror=frame-larger-than=]
drivers/media/i2c/cx25840/cx25840-core.c:4960:1: error: the frame size of 94000 bytes is larger than 2048 bytes [-Werror=frame-larger-than=]
drivers/media/dvb-frontends/stv090x.c:3430:1: error: the frame size of 5312 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]

This happens when a sanitizer uses stack memory each time an inline function
gets called. This introduces a new annotation for those functions to make
them either 'inline' or 'noinline' dependning on the CONFIG_KASAN symbol.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 include/linux/compiler.h | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/linux/compiler.h b/include/linux/compiler.h
index f8110051188f..56b90897a459 100644
--- a/include/linux/compiler.h
+++ b/include/linux/compiler.h
@@ -416,6 +416,17 @@ static __always_inline void __write_once_size(volatile void *p, void *res, int s
  */
 #define noinline_for_stack noinline
 
+/*
+ * CONFIG_KASAN can lead to extreme stack usage with certain patterns when
+ * one function gets inlined many times and each instance requires a stack
+ * ckeck.
+ */
+#ifdef CONFIG_KASAN
+#define noinline_for_kasan noinline __maybe_unused
+#else
+#define noinline_for_kasan inline
+#endif
+
 #ifndef __always_inline
 #define __always_inline inline
 #endif
-- 
2.9.0
