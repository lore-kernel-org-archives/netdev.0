From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/4] vsprintf: Recursive vsnprintf: Add "%pV", struct va_format
Date: Sun, 27 Jun 2010 04:02:33 -0700
Message-ID: <be77898263d2b7a5134f839ed667d499a00314f2.1277636090.git.joe@perches.com>
References: <cover.1277636090.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1277636090.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add the ability to print a format and va_list from a structure pointer

Allows __dev_printk to be implemented as a single printk while
minimizing string space duplication.

%pV should not be used without some mechanism to verify the
format and argument use ala __attribute__(format (printf(...))).

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/kernel.h |    5 +++++
 lib/vsprintf.c         |    9 +++++++++
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 8317ec4..01dfc05 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -171,6 +171,11 @@ static inline void might_fault(void)
 }
 #endif
 
+struct va_format {
+	const char *fmt;
+	va_list *va;
+};
+
 extern struct atomic_notifier_head panic_notifier_list;
 extern long (*panic_blink)(long time);
 NORET_TYPE void panic(const char * fmt, ...)
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index b8a2f54..4ee19d0 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -980,6 +980,11 @@ char *uuid_string(char *buf, char *end, const u8 *addr,
  *             [0][1][2][3]-[4][5]-[6][7]-[8][9]-[10][11][12][13][14][15]
  *           little endian output byte order is:
  *             [3][2][1][0]-[5][4]-[7][6]-[8][9]-[10][11][12][13][14][15]
+ * - 'V' For a struct va_format which contains a format string * and va_list *,
+ *       call vsnprintf(->format, *->va_list).
+ *       Implements a "recursive vsnprintf".
+ *       Do not use this feature without some mechanism to verify the
+ *       correctness of the format string and va_list arguments.
  *
  * Note: The difference between 'S' and 'F' is that on ia64 and ppc64
  * function pointers are really function descriptors, which contain a
@@ -1025,6 +1030,10 @@ char *pointer(const char *fmt, char *buf, char *end, void *ptr,
 		break;
 	case 'U':
 		return uuid_string(buf, end, ptr, spec, fmt);
+	case 'V':
+		return buf + vsnprintf(buf, end - buf,
+				       ((struct va_format *)ptr)->fmt,
+				       *(((struct va_format *)ptr)->va));
 	}
 	spec.flags |= SMALL;
 	if (spec.field_width == -1) {
-- 
1.7.1.337.g6068.dirty
