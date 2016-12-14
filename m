From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH v3 3/3] random: use siphash24 instead of md5 for get_random_int/long
Date: Wed, 14 Dec 2016 19:46:05 +0100
Message-ID: <20161214184605.24006-3-Jason@zx2c4.com>
References: <20161214035927.30004-1-Jason@zx2c4.com>
 <20161214184605.24006-1-Jason@zx2c4.com>
Reply-To: kernel-hardening@lists.openwall.com
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
	Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
	Ted Tso <tytso@mit.edu>
To: Netdev <netdev@vger.kernel.org>,
	kernel-hardening@lists.openwall.com,
	LKML <linux-kernel@vger.kernel.org>,
	linux-crypto@vger.kernel.org
Return-path: <kernel-hardening-return-5526-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161214184605.24006-1-Jason@zx2c4.com>
List-Id: netdev.vger.kernel.org

This duplicates the current algorithm for get_random_int/long, but uses
siphash24 instead. This comes with several benefits. It's certainly
faster and more cryptographically secure than MD5. This patch also
hashes the pid, entropy, and timestamp as fixed width fields, in order
to increase diffusion.

The previous md5 algorithm used a per-cpu md5 state, which caused
successive calls to the function to chain upon each other. While it's
not entirely clear that this kind of chaining is absolutely necessary
when using a secure PRF like siphash24, it can't hurt, and the timing of
the call chain does add a degree of natural entropy. So, in keeping with
this design, instead of the massive per-cpu 64-byte md5 state, there is
instead a per-cpu previously returned value for chaining.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Cc: Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
Cc: Ted Tso <tytso@mit.edu>
---
Changes from v2->v3:

  - Structs are no longer packed, to mitigate slow byte-by-byte assignment.

 drivers/char/random.c | 52 ++++++++++++++++++++++++++++++++-------------------
 1 file changed, 33 insertions(+), 19 deletions(-)

diff --git a/drivers/char/random.c b/drivers/char/random.c
index d6876d506220..b1c2e3b26430 100644
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -262,6 +262,7 @@
 #include <linux/syscalls.h>
 #include <linux/completion.h>
 #include <linux/uuid.h>
+#include <linux/siphash.h>
 #include <crypto/chacha20.h>
 
 #include <asm/processor.h>
@@ -2042,7 +2043,7 @@ struct ctl_table random_table[] = {
 };
 #endif 	/* CONFIG_SYSCTL */
 
-static u32 random_int_secret[MD5_MESSAGE_BYTES / 4] ____cacheline_aligned;
+static u8 random_int_secret[SIPHASH24_KEY_LEN] __aligned(SIPHASH24_ALIGNMENT);
 
 int random_int_secret_init(void)
 {
@@ -2050,8 +2051,7 @@ int random_int_secret_init(void)
 	return 0;
 }
 
-static DEFINE_PER_CPU(__u32 [MD5_DIGEST_WORDS], get_random_int_hash)
-		__aligned(sizeof(unsigned long));
+static DEFINE_PER_CPU(u64, get_random_int_chaining);
 
 /*
  * Get a random word for internal kernel use only. Similar to urandom but
@@ -2061,19 +2061,26 @@ static DEFINE_PER_CPU(__u32 [MD5_DIGEST_WORDS], get_random_int_hash)
  */
 unsigned int get_random_int(void)
 {
-	__u32 *hash;
 	unsigned int ret;
+	struct {
+		u64 chaining;
+		unsigned long ts;
+		unsigned long entropy;
+		pid_t pid;
+		char end[];
+	} __aligned(SIPHASH24_ALIGNMENT) combined;
+	u64 *chaining;
 
 	if (arch_get_random_int(&ret))
 		return ret;
 
-	hash = get_cpu_var(get_random_int_hash);
-
-	hash[0] += current->pid + jiffies + random_get_entropy();
-	md5_transform(hash, random_int_secret);
-	ret = hash[0];
-	put_cpu_var(get_random_int_hash);
-
+	chaining = get_cpu_ptr(&get_random_int_chaining);
+	combined.chaining = *chaining;
+	combined.ts = jiffies;
+	combined.entropy = random_get_entropy();
+	combined.pid = current->pid;
+	ret = *chaining = siphash24((u8 *)&combined, offsetof(typeof(combined), end), random_int_secret);
+	put_cpu_ptr(chaining);
 	return ret;
 }
 EXPORT_SYMBOL(get_random_int);
@@ -2083,19 +2090,26 @@ EXPORT_SYMBOL(get_random_int);
  */
 unsigned long get_random_long(void)
 {
-	__u32 *hash;
 	unsigned long ret;
+	struct {
+		u64 chaining;
+		unsigned long ts;
+		unsigned long entropy;
+		pid_t pid;
+		char end[];
+	} __aligned(SIPHASH24_ALIGNMENT) combined;
+	u64 *chaining;
 
 	if (arch_get_random_long(&ret))
 		return ret;
 
-	hash = get_cpu_var(get_random_int_hash);
-
-	hash[0] += current->pid + jiffies + random_get_entropy();
-	md5_transform(hash, random_int_secret);
-	ret = *(unsigned long *)hash;
-	put_cpu_var(get_random_int_hash);
-
+	chaining = get_cpu_ptr(&get_random_int_chaining);
+	combined.chaining = *chaining;
+	combined.ts = jiffies;
+	combined.entropy = random_get_entropy();
+	combined.pid = current->pid;
+	ret = *chaining = siphash24((u8 *)&combined, offsetof(typeof(combined), end), random_int_secret);
+	put_cpu_ptr(chaining);
 	return ret;
 }
 EXPORT_SYMBOL(get_random_long);
-- 
2.11.0
