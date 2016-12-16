From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH v6 3/5] random: use SipHash in place of MD5
Date: Fri, 16 Dec 2016 04:03:26 +0100
Message-ID: <20161216030328.11602-4-Jason@zx2c4.com>
References: <20161215203003.31989-1-Jason@zx2c4.com>
 <20161216030328.11602-1-Jason@zx2c4.com>
Reply-To: kernel-hardening@lists.openwall.com
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
	Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
To: Netdev <netdev@vger.kernel.org>,
	kernel-hardening@lists.openwall.com,
	LKML <linux-kernel@vger.kernel.org>,
	linux-crypto@vger.kernel.org,
	David Laight <David.Laight@aculab.com>,
	Ted Tso <tytso@mit.edu>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Biggers <ebiggers3@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	George Spelvin <linux@sciencehorizons.net>,
	Vegard Nossum <vegard.nossum@gmail.com>,
	ak@linux.intel.com,
	davem@davemloft.net,
	luto@amacapital.net
Return-path: <kernel-hardening-return-5622-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161216030328.11602-1-Jason@zx2c4.com>
List-Id: netdev.vger.kernel.org

This duplicates the current algorithm for get_random_int/long, but uses
siphash instead. This comes with several benefits. It's certainly
faster and more cryptographically secure than MD5. This patch also
separates hashed fields into three values instead of one, in order to
increase diffusion.

The previous MD5 algorithm used a per-cpu MD5 state, which caused
successive calls to the function to chain upon each other. While it's
not entirely clear that this kind of chaining is absolutely necessary
when using a secure PRF like siphash, it can't hurt, and the timing of
the call chain does add a degree of natural entropy. So, in keeping with
this design, instead of the massive per-cpu 64-byte MD5 state, there is
instead a per-cpu previously returned value for chaining.

The speed benefits are substantial:

                | siphash | md5    | speedup |
		------------------------------
get_random_long | 137130  | 415983 | 3.03x   |
get_random_int  | 86384   | 343323 | 3.97x   |

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Cc: Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
Cc: Ted Tso <tytso@mit.edu>
---
 drivers/char/random.c | 32 +++++++++++++-------------------
 1 file changed, 13 insertions(+), 19 deletions(-)

diff --git a/drivers/char/random.c b/drivers/char/random.c
index d6876d506220..a51f0ff43f00 100644
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
+static siphash_key_t random_int_secret;
 
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
@@ -2061,19 +2061,16 @@ static DEFINE_PER_CPU(__u32 [MD5_DIGEST_WORDS], get_random_int_hash)
  */
 unsigned int get_random_int(void)
 {
-	__u32 *hash;
 	unsigned int ret;
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
+	chaining = &get_cpu_var(get_random_int_chaining);
+	ret = *chaining = siphash_3u64(*chaining, jiffies, random_get_entropy() +
+				       current->pid, random_int_secret);
+	put_cpu_var(get_random_int_chaining);
 	return ret;
 }
 EXPORT_SYMBOL(get_random_int);
@@ -2083,19 +2080,16 @@ EXPORT_SYMBOL(get_random_int);
  */
 unsigned long get_random_long(void)
 {
-	__u32 *hash;
 	unsigned long ret;
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
+	chaining = &get_cpu_var(get_random_int_chaining);
+	ret = *chaining = siphash_3u64(*chaining, jiffies, random_get_entropy() +
+				       current->pid, random_int_secret);
+	put_cpu_var(get_random_int_chaining);
 	return ret;
 }
 EXPORT_SYMBOL(get_random_long);
-- 
2.11.0
