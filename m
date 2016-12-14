From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH 4/3] random: use siphash24 instead of md5 for get_random_int/long
Date: Wed, 14 Dec 2016 04:10:37 +0100
Message-ID: <20161214031037.25498-1-Jason@zx2c4.com>
References: <20161214001656.19388-1-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
To: Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        LKML <linux-kernel@vger.kernel.org>,
        George Spelvin <linux@horizon.com>,
        Scott Bauer <sbauer@eng.utah.edu>,
        Andi Kleen <ak@linux.intel.com>,
        Andy Lutomirski <luto@amacapital.net>,
        Greg KH <gregkh@linuxfoundation.org>,
        Eric Biggers <ebiggers3@gmail.com>,
        linux-crypto@vger.kernel.org, Ted Tso <tytso@mit.edu>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20161214001656.19388-1-Jason@zx2c4.com>
Sender: linux-crypto-owner@vger.kernel.org
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
---
 drivers/char/random.c | 50 +++++++++++++++++++++++++++++++-------------------
 1 file changed, 31 insertions(+), 19 deletions(-)

diff --git a/drivers/char/random.c b/drivers/char/random.c
index d6876d506220..25f96f074da5 100644
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
+static u8 random_int_secret[SIPHASH24_KEY_LEN];
 
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
@@ -2061,19 +2061,25 @@ static DEFINE_PER_CPU(__u32 [MD5_DIGEST_WORDS], get_random_int_hash)
  */
 unsigned int get_random_int(void)
 {
-	__u32 *hash;
+	uint64_t *chaining;
 	unsigned int ret;
+	struct {
+		uint64_t chaining;
+		unsigned long ts;
+		unsigned long entropy;
+		pid_t pid;
+	} __packed combined;
 
 	if (arch_get_random_int(&ret))
 		return ret;
 
-	hash = get_cpu_var(get_random_int_hash);
-
-	hash[0] += current->pid + jiffies + random_get_entropy();
-	md5_transform(hash, random_int_secret);
-	ret = hash[0];
-	put_cpu_var(get_random_int_hash);
-
+	chaining = &get_cpu_var(get_random_int_chaining);
+	combined.chaining = *chaining;
+	combined.ts = jiffies;
+	combined.entropy = random_get_entropy();
+	combined.pid = current->pid;
+	ret = *chaining = siphash24((u8 *)&combined, sizeof(combined), random_int_secret);
+	put_cpu_var(chaining);
 	return ret;
 }
 EXPORT_SYMBOL(get_random_int);
@@ -2083,19 +2089,25 @@ EXPORT_SYMBOL(get_random_int);
  */
 unsigned long get_random_long(void)
 {
-	__u32 *hash;
+	uint64_t *chaining;
 	unsigned long ret;
+	struct {
+		uint64_t chaining;
+		unsigned long ts;
+		unsigned long entropy;
+		pid_t pid;
+	} __packed combined;
 
 	if (arch_get_random_long(&ret))
 		return ret;
 
-	hash = get_cpu_var(get_random_int_hash);
-
-	hash[0] += current->pid + jiffies + random_get_entropy();
-	md5_transform(hash, random_int_secret);
-	ret = *(unsigned long *)hash;
-	put_cpu_var(get_random_int_hash);
-
+	chaining = &get_cpu_var(get_random_int_chaining);
+	combined.chaining = *chaining;
+	combined.ts = jiffies;
+	combined.entropy = random_get_entropy();
+	combined.pid = current->pid;
+	ret = *chaining = siphash24((u8 *)&combined, sizeof(combined), random_int_secret);
+	put_cpu_var(chaining);
 	return ret;
 }
 EXPORT_SYMBOL(get_random_long);
-- 
2.11.0
