From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 03/26] typecheck.h: avoid local variables in typecheck() macro
Date: Thu,  2 Mar 2017 17:38:11 +0100
Message-ID: <20170302163834.2273519-4-arnd@arndb.de>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170302163834.2273519-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With KASAN enabled, the typecheck macro leads to some serious stack memory,
as seen in the rt2xxx drivers:

drivers/net/wireless/ralink/rt2x00/rt2800lib.c: In function 'rt2800_init_registers':
drivers/net/wireless/ralink/rt2x00/rt2800lib.c:5068:1: error: the frame size of 23768 bytes is larger than 1024 bytes [-Werror=frame-larger-than=]
drivers/net/wireless/ralink/rt2x00/rt2800lib.c: In function 'rt2800_config_txpower_rt3593.isra.1':
drivers/net/wireless/ralink/rt2x00/rt2800lib.c:4126:1: error: the frame size of 14184 bytes is larger than 1024 bytes [-Werror=frame-larger-than=]
drivers/net/wireless/ralink/rt2x00/rt2800lib.c: In function 'rt2800_config_channel_rf3053.isra.5':
drivers/net/wireless/ralink/rt2x00/rt2800lib.c:2585:1: error: the frame size of 7632 bytes is larger than 1024 bytes [-Werror=frame-larger-than=]

If we express the macro in a way that avoids the local variables, this goes
away and the stacks are comparable to building without KASAN.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 include/linux/typecheck.h | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/include/linux/typecheck.h b/include/linux/typecheck.h
index eb5b74a575be..adb1579fa5f0 100644
--- a/include/linux/typecheck.h
+++ b/include/linux/typecheck.h
@@ -5,12 +5,7 @@
  * Check at compile time that something is of a particular type.
  * Always evaluates to 1 so you may use it easily in comparisons.
  */
-#define typecheck(type,x) \
-({	type __dummy; \
-	typeof(x) __dummy2; \
-	(void)(&__dummy == &__dummy2); \
-	1; \
-})
+#define typecheck(type,x) ({(void)((typeof(type) *)NULL == (typeof(x) *)NULL); 1;})
 
 /*
  * Check at compile time that 'function' is a certain type, or is a pointer
-- 
2.9.0
