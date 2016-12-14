From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH 4/3] random: use siphash24 instead of md5 for
 get_random_int/long
Date: Wed, 14 Dec 2016 11:37:31 -0500
Message-ID: <20161214163731.luj2dzmnihcuhn5p@thunk.org>
References: <20161214001656.19388-1-Jason@zx2c4.com>
 <20161214031037.25498-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
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
        linux-crypto@vger.kernel.org,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161214031037.25498-1-Jason@zx2c4.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 14, 2016 at 04:10:37AM +0100, Jason A. Donenfeld wrote:
> This duplicates the current algorithm for get_random_int/long, but uses
> siphash24 instead. This comes with several benefits. It's certainly
> faster and more cryptographically secure than MD5. This patch also
> hashes the pid, entropy, and timestamp as fixed width fields, in order
> to increase diffusion.
> 
> The previous md5 algorithm used a per-cpu md5 state, which caused
> successive calls to the function to chain upon each other. While it's
> not entirely clear that this kind of chaining is absolutely necessary
> when using a secure PRF like siphash24, it can't hurt, and the timing of
> the call chain does add a degree of natural entropy. So, in keeping with
> this design, instead of the massive per-cpu 64-byte md5 state, there is
> instead a per-cpu previously returned value for chaining.
> 
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
> Cc: Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>

The original reason for get_random_int was because the original
urandom algorithms were too slow.  When we moved to chacha20, which is
must faster, I didn't think to revisit get_random_int() and
get_random_long().

One somewhat undesirable aspect of the current algorithm is that we
never change random_int_secret.  So I've been toying with the
following, which is 4 times faster than md5.  (I haven't tried
benchmarking against siphash yet.)

[    3.606139] random benchmark!!
[    3.606276] get_random_int # cycles: 326578
[    3.606317] get_random_int_new # cycles: 95438
[    3.607423] get_random_bytes # cycles: 2653388

     	       			  	  - Ted

P.S.  It's interesting to note that siphash24 and chacha20 are both
add-rotate-xor based algorithms.

diff --git a/drivers/char/random.c b/drivers/char/random.c
index d6876d506220..be172ea75799 100644
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -1681,6 +1681,38 @@ static int rand_initialize(void)
 }
 early_initcall(rand_initialize);
 
+static unsigned int get_random_int_new(void);
+
+static int rand_benchmark(void)
+{
+	cycles_t start,finish;
+	int i, out;
+
+	pr_crit("random benchmark!!\n");
+	start = get_cycles();
+	for (i = 0; i < 1000; i++) {
+		get_random_int();
+	}
+	finish = get_cycles();
+	pr_err("get_random_int # cycles: %llu\n", finish - start);
+
+	start = get_cycles();
+	for (i = 0; i < 1000; i++) {
+		get_random_int_new();
+	}
+	finish = get_cycles();
+	pr_err("get_random_int_new # cycles: %llu\n", finish - start);
+
+	start = get_cycles();
+	for (i = 0; i < 1000; i++) {
+		get_random_bytes(&out, sizeof(out));
+	}
+	finish = get_cycles();
+	pr_err("get_random_bytes # cycles: %llu\n", finish - start);
+	return 0;
+}
+device_initcall(rand_benchmark);
+
 #ifdef CONFIG_BLOCK
 void rand_initialize_disk(struct gendisk *disk)
 {
@@ -2064,8 +2096,10 @@ unsigned int get_random_int(void)
 	__u32 *hash;
 	unsigned int ret;
 
+#if 0	// force slow path
 	if (arch_get_random_int(&ret))
 		return ret;
+#endif
 
 	hash = get_cpu_var(get_random_int_hash);
 
@@ -2100,6 +2134,38 @@ unsigned long get_random_long(void)
 }
 EXPORT_SYMBOL(get_random_long);
 
+struct random_buf {
+	__u8 buf[CHACHA20_BLOCK_SIZE];
+	int ptr;
+};
+
+static DEFINE_PER_CPU(struct random_buf, batched_entropy);
+
+static void get_batched_entropy(void *buf, int n)
+{
+	struct random_buf *p;
+
+	p = &get_cpu_var(batched_entropy);
+
+	if ((p->ptr == 0) ||
+	    (p->ptr + n >= CHACHA20_BLOCK_SIZE)) {
+		extract_crng(p->buf);
+		p->ptr = 0;
+	}
+	BUG_ON(n > CHACHA20_BLOCK_SIZE);
+	memcpy(buf, p->buf, n);
+	p->ptr += n;
+	put_cpu_var(batched_entropy);
+}
+
+static unsigned int get_random_int_new(void)
+{
+	int	ret;
+
+	get_batched_entropy(&ret, sizeof(ret));
+	return ret;
+}
+
 /**
  * randomize_page - Generate a random, page aligned address
  * @start:	The smallest acceptable address the caller will take.
