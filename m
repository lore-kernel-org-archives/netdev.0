From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 24/26] ocfs2: reduce stack size with KASAN
Date: Thu,  2 Mar 2017 17:38:32 +0100
Message-ID: <20170302163834.2273519-25-arnd@arndb.de>
References: <20170302163834.2273519-1-arnd@arndb.de>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-media@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        kernel-build-reports@lists.linaro.org,
        "David S . Miller" <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>, Joe Perches <joe@perches.com>
To: kasan-dev@googlegroups.com
Return-path: <linux-media-owner@vger.kernel.org>
In-Reply-To: <20170302163834.2273519-1-arnd@arndb.de>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The internal logging infrastructure in ocfs2 causes special warning code to be
used with KASAN, which produces rather large stack frames:

fs/ocfs2/super.c: In function 'ocfs2_fill_super':
fs/ocfs2/super.c:1219:1: error: the frame size of 3264 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]

By simply passing the mask by value instead of reference, we can avoid the
problem completely. On 64-bit architectures, this is also more efficient,
while on the less common (at least among ocfs2 users) 32-bit architectures,
I'm guessing that the resulting code is comparable to what it was before.

The current version was introduced by Joe Perches as an optimization, maybe
he can see if my change regresses compared to his.

Cc: Joe Perches <joe@perches.com>
Fixes: 7c2bd2f930ae ("ocfs2: reduce object size of mlog uses")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 fs/ocfs2/cluster/masklog.c | 10 +++++-----
 fs/ocfs2/cluster/masklog.h |  4 ++--
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/ocfs2/cluster/masklog.c b/fs/ocfs2/cluster/masklog.c
index d331c2386b94..9720c5443e4d 100644
--- a/fs/ocfs2/cluster/masklog.c
+++ b/fs/ocfs2/cluster/masklog.c
@@ -64,7 +64,7 @@ static ssize_t mlog_mask_store(u64 mask, const char *buf, size_t count)
 	return count;
 }
 
-void __mlog_printk(const u64 *mask, const char *func, int line,
+void __mlog_printk(const u64 mask, const char *func, int line,
 		   const char *fmt, ...)
 {
 	struct va_format vaf;
@@ -72,14 +72,14 @@ void __mlog_printk(const u64 *mask, const char *func, int line,
 	const char *level;
 	const char *prefix = "";
 
-	if (!__mlog_test_u64(*mask, mlog_and_bits) ||
-	    __mlog_test_u64(*mask, mlog_not_bits))
+	if (!__mlog_test_u64(mask, mlog_and_bits) ||
+	    __mlog_test_u64(mask, mlog_not_bits))
 		return;
 
-	if (*mask & ML_ERROR) {
+	if (mask & ML_ERROR) {
 		level = KERN_ERR;
 		prefix = "ERROR: ";
-	} else if (*mask & ML_NOTICE) {
+	} else if (mask & ML_NOTICE) {
 		level = KERN_NOTICE;
 	} else {
 		level = KERN_INFO;
diff --git a/fs/ocfs2/cluster/masklog.h b/fs/ocfs2/cluster/masklog.h
index 308ea0eb35fd..0d0f4bf2c3d8 100644
--- a/fs/ocfs2/cluster/masklog.h
+++ b/fs/ocfs2/cluster/masklog.h
@@ -163,7 +163,7 @@ extern struct mlog_bits mlog_and_bits, mlog_not_bits;
 #endif
 
 __printf(4, 5)
-void __mlog_printk(const u64 *m, const char *func, int line,
+void __mlog_printk(const u64 m, const char *func, int line,
 		   const char *fmt, ...);
 
 /*
@@ -174,7 +174,7 @@ void __mlog_printk(const u64 *m, const char *func, int line,
 do {									\
 	u64 _m = MLOG_MASK_PREFIX | (mask);				\
 	if (_m & ML_ALLOWED_BITS)					\
-		__mlog_printk(&_m, __func__, __LINE__, fmt,		\
+		__mlog_printk(_m, __func__, __LINE__, fmt,		\
 			      ##__VA_ARGS__);				\
 } while (0)
 
-- 
2.9.0
