From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH v7 3/6] random: use SipHash in place of MD5
Date: Thu, 22 Dec 2016 00:02:13 +0100
Message-ID: <20161221230216.25341-4-Jason@zx2c4.com>
References: <20161216030328.11602-1-Jason@zx2c4.com>
 <20161221230216.25341-1-Jason@zx2c4.com>
Reply-To: kernel-hardening@lists.openwall.com
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: Netdev <netdev@vger.kernel.org>,
	kernel-hardening@lists.openwall.com,
	LKML <linux-kernel@vger.kernel.org>,
	linux-crypto@vger.kernel.org,
	David Laight <David.Laight@aculab.com>,
	Ted Tso <tytso@mit.edu>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	edumazet@google.com,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Biggers <ebiggers3@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	ak@linux.intel.com,
	davem@davemloft.net,
	luto@amacapital.net,
	Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
Return-path: <kernel-hardening-return-5750-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161221230216.25341-1-Jason@zx2c4.com>
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
 drivers/char/random.c  | 84 +++++++++++++++++++++++++++++---------------------
 include/linux/random.h |  1 -
 init/main.c            |  1 -
 3 files changed, 49 insertions(+), 37 deletions(-)

diff --git a/drivers/char/random.c b/drivers/char/random.c
index d6876d506220..ea9858d9d8b4 100644
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -262,6 +262,7 @@
 #include <linux/syscalls.h>
 #include <linux/completion.h>
 #include <linux/uuid.h>
+#include <linux/siphash.h>
 #include <crypto/chacha20.h>
 
 #include <asm/processor.h>
@@ -2042,17 +2043,31 @@ struct ctl_table random_table[] = {
 };
 #endif 	/* CONFIG_SYSCTL */
 
-static u32 random_int_secret[MD5_MESSAGE_BYTES / 4] ____cacheline_aligned;
 
-int random_int_secret_init(void)
+struct random_int_secret {
+	siphash_key_t secret;
+	u64 chaining;
+	unsigned long birthdate;
+	bool initialized;
+};
+static DEFINE_PER_CPU(struct random_int_secret, random_int_secret);
+
+enum {
+	SECRET_ROTATION_TIME = HZ * 60 * 5
+};
+
+static struct random_int_secret *get_random_int_secret(void)
 {
-	get_random_bytes(random_int_secret, sizeof(random_int_secret));
-	return 0;
+	struct random_int_secret *secret = &get_cpu_var(random_int_secret);
+	if (unlikely(!secret->initialized ||
+		     !time_is_after_jiffies(secret->birthdate + SECRET_ROTATION_TIME))) {
+		secret->initialized = true;
+		secret->birthdate = jiffies;
+		get_random_bytes(secret->secret, sizeof(secret->secret));
+	}
+	return secret;
 }
 
-static DEFINE_PER_CPU(__u32 [MD5_DIGEST_WORDS], get_random_int_hash)
-		__aligned(sizeof(unsigned long));
-
 /*
  * Get a random word for internal kernel use only. Similar to urandom but
  * with the goal of minimal entropy pool depletion. As a result, the random
@@ -2061,20 +2076,20 @@ static DEFINE_PER_CPU(__u32 [MD5_DIGEST_WORDS], get_random_int_hash)
  */
 unsigned int get_random_int(void)
 {
-	__u32 *hash;
-	unsigned int ret;
-
-	if (arch_get_random_int(&ret))
-		return ret;
-
-	hash = get_cpu_var(get_random_int_hash);
-
-	hash[0] += current->pid + jiffies + random_get_entropy();
-	md5_transform(hash, random_int_secret);
-	ret = hash[0];
-	put_cpu_var(get_random_int_hash);
-
-	return ret;
+	unsigned int arch_result;
+	u64 result;
+	struct random_int_secret *secret;
+
+	if (arch_get_random_int(&arch_result))
+		return arch_result;
+
+	secret = get_random_int_secret();
+	result = siphash_3u64(secret->chaining, jiffies,
+			      (u64)random_get_entropy() + current->pid,
+			      secret->secret);
+	secret->chaining += result;
+	put_cpu_var(secret);
+	return result;
 }
 EXPORT_SYMBOL(get_random_int);
 
@@ -2083,20 +2098,19 @@ EXPORT_SYMBOL(get_random_int);
  */
 unsigned long get_random_long(void)
 {
-	__u32 *hash;
-	unsigned long ret;
-
-	if (arch_get_random_long(&ret))
-		return ret;
-
-	hash = get_cpu_var(get_random_int_hash);
-
-	hash[0] += current->pid + jiffies + random_get_entropy();
-	md5_transform(hash, random_int_secret);
-	ret = *(unsigned long *)hash;
-	put_cpu_var(get_random_int_hash);
-
-	return ret;
+	unsigned long arch_result;
+	u64 result;
+	struct random_int_secret *secret;
+
+	if (arch_get_random_long(&arch_result))
+		return arch_result;
+
+	secret = get_random_int_secret();
+	result = siphash_3u64(secret->chaining, jiffies, random_get_entropy() +
+			      current->pid, secret->secret);
+	secret->chaining += result;
+	put_cpu_var(secret);
+	return result;
 }
 EXPORT_SYMBOL(get_random_long);
 
diff --git a/include/linux/random.h b/include/linux/random.h
index 7bd2403e4fef..16ab429735a7 100644
--- a/include/linux/random.h
+++ b/include/linux/random.h
@@ -37,7 +37,6 @@ extern void get_random_bytes(void *buf, int nbytes);
 extern int add_random_ready_callback(struct random_ready_callback *rdy);
 extern void del_random_ready_callback(struct random_ready_callback *rdy);
 extern void get_random_bytes_arch(void *buf, int nbytes);
-extern int random_int_secret_init(void);
 
 #ifndef MODULE
 extern const struct file_operations random_fops, urandom_fops;
diff --git a/init/main.c b/init/main.c
index 23c275cca73a..a3af9296cafd 100644
--- a/init/main.c
+++ b/init/main.c
@@ -879,7 +879,6 @@ static void __init do_basic_setup(void)
 	do_ctors();
 	usermodehelper_enable();
 	do_initcalls();
-	random_int_secret_init();
 }
 
 static void __init do_pre_smp_initcalls(void)
-- 
2.11.0
