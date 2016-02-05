From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 1/4] lib: move strtobool to kstrtobool
Date: Fri,  5 Feb 2016 13:12:46 -0800
Message-ID: <1454706769-8729-2-git-send-email-keescook@chromium.org>
References: <1454706769-8729-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>, Joe Perches <joe@perches.com>,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Steve French <sfrench@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>, x86@kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-cifs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454706769-8729-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Create the kstrtobool_from_user helper and moves strtobool logic into
the new kstrtobool (matching all the other kstrto* functions). Provides
an inline wrapper for existing strtobool callers.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
v3:
- drop needless "base" argument, rasmus
---
 include/linux/kernel.h |  2 ++
 include/linux/string.h |  6 +++++-
 lib/kstrtox.c          | 50 ++++++++++++++++++++++++++++++++++++++++++++++++++
 lib/string.c           | 29 -----------------------------
 4 files changed, 57 insertions(+), 30 deletions(-)

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index f31638c6e873..f4fa2b29c38c 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -357,6 +357,7 @@ int __must_check kstrtou16(const char *s, unsigned int base, u16 *res);
 int __must_check kstrtos16(const char *s, unsigned int base, s16 *res);
 int __must_check kstrtou8(const char *s, unsigned int base, u8 *res);
 int __must_check kstrtos8(const char *s, unsigned int base, s8 *res);
+int __must_check kstrtobool(const char *s, bool *res);
 
 int __must_check kstrtoull_from_user(const char __user *s, size_t count, unsigned int base, unsigned long long *res);
 int __must_check kstrtoll_from_user(const char __user *s, size_t count, unsigned int base, long long *res);
@@ -368,6 +369,7 @@ int __must_check kstrtou16_from_user(const char __user *s, size_t count, unsigne
 int __must_check kstrtos16_from_user(const char __user *s, size_t count, unsigned int base, s16 *res);
 int __must_check kstrtou8_from_user(const char __user *s, size_t count, unsigned int base, u8 *res);
 int __must_check kstrtos8_from_user(const char __user *s, size_t count, unsigned int base, s8 *res);
+int __must_check kstrtobool_from_user(const char __user *s, size_t count, bool *res);
 
 static inline int __must_check kstrtou64_from_user(const char __user *s, size_t count, unsigned int base, u64 *res)
 {
diff --git a/include/linux/string.h b/include/linux/string.h
index 9eebc66d957a..2217224684c9 100644
--- a/include/linux/string.h
+++ b/include/linux/string.h
@@ -128,7 +128,11 @@ extern char **argv_split(gfp_t gfp, const char *str, int *argcp);
 extern void argv_free(char **argv);
 
 extern bool sysfs_streq(const char *s1, const char *s2);
-extern int strtobool(const char *s, bool *res);
+extern int kstrtobool(const char *s, bool *res);
+static inline int strtobool(const char *s, bool *res)
+{
+	return kstrtobool(s, res);
+}
 
 #ifdef CONFIG_BINARY_PRINTF
 int vbin_printf(u32 *bin_buf, size_t size, const char *fmt, va_list args);
diff --git a/lib/kstrtox.c b/lib/kstrtox.c
index 94be244e8441..e8ba4a013e82 100644
--- a/lib/kstrtox.c
+++ b/lib/kstrtox.c
@@ -321,6 +321,56 @@ int kstrtos8(const char *s, unsigned int base, s8 *res)
 }
 EXPORT_SYMBOL(kstrtos8);
 
+/**
+ * kstrtobool - convert common user inputs into boolean values
+ * @s: input string
+ * @res: result
+ *
+ * This routine returns 0 iff the first character is one of 'Yy1Nn0'.
+ * Otherwise it will return -EINVAL.  Value pointed to by res is
+ * updated upon finding a match.
+ */
+int kstrtobool(const char *s, bool *res)
+{
+	if (!s)
+		return -EINVAL;
+
+	switch (s[0]) {
+	case 'y':
+	case 'Y':
+	case '1':
+		*res = true;
+		return 0;
+	case 'n':
+	case 'N':
+	case '0':
+		*res = false;
+		return 0;
+	default:
+		break;
+	}
+
+	return -EINVAL;
+}
+EXPORT_SYMBOL(kstrtobool);
+
+/*
+ * Since "base" would be a nonsense argument, this open-codes the
+ * _from_user helper instead of using the helper macro below.
+ */
+int kstrtobool_from_user(const char __user *s, size_t count, bool *res)
+{
+	/* Longest string needed to differentiate, newline, terminator */
+	char buf[4];
+
+	count = min(count, sizeof(buf) - 1);
+	if (copy_from_user(buf, s, count))
+		return -EFAULT;
+	buf[count] = '\0';
+	return kstrtobool(buf, res);
+}
+EXPORT_SYMBOL(kstrtobool_from_user);
+
 #define kstrto_from_user(f, g, type)					\
 int f(const char __user *s, size_t count, unsigned int base, type *res)	\
 {									\
diff --git a/lib/string.c b/lib/string.c
index 0323c0d5629a..1a90db9bc6e1 100644
--- a/lib/string.c
+++ b/lib/string.c
@@ -630,35 +630,6 @@ bool sysfs_streq(const char *s1, const char *s2)
 }
 EXPORT_SYMBOL(sysfs_streq);
 
-/**
- * strtobool - convert common user inputs into boolean values
- * @s: input string
- * @res: result
- *
- * This routine returns 0 iff the first character is one of 'Yy1Nn0'.
- * Otherwise it will return -EINVAL.  Value pointed to by res is
- * updated upon finding a match.
- */
-int strtobool(const char *s, bool *res)
-{
-	switch (s[0]) {
-	case 'y':
-	case 'Y':
-	case '1':
-		*res = true;
-		break;
-	case 'n':
-	case 'N':
-	case '0':
-		*res = false;
-		break;
-	default:
-		return -EINVAL;
-	}
-	return 0;
-}
-EXPORT_SYMBOL(strtobool);
-
 #ifndef __HAVE_ARCH_MEMSET
 /**
  * memset - Fill a region of memory with the given value
-- 
2.6.3
