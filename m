From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: Re: [PATCH v7 3/6] random: use SipHash in
 place of MD5
Date: Thu, 22 Dec 2016 00:41:25 -0500
Message-ID: <20161222054125.lzxhd6ctovm3wk4p@thunk.org>
References: <20161216030328.11602-1-Jason@zx2c4.com>
 <20161221230216.25341-1-Jason@zx2c4.com>
 <20161221230216.25341-4-Jason@zx2c4.com>
 <CALCETrVttVoZMvCYZcrAqM1c=YQP_nCfdfO1MsrSHjvjTFxH+A@mail.gmail.com>
 <17bd0c70-d2c1-165b-f5b2-252dfca404e8@stressinduktion.org>
 <CAHmME9phg=GuhEUaMxxv_=RexffPDqrOEhmaKffy_ZSt7bfC7g@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	David Laight <David.Laight@aculab.com>,
	Eric Dumazet <edumazet@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Biggers <ebiggers3@gmail.com>,
	Tom Herbert <tom@herbertland.com>, Andi Kleen <ak@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
To: kernel-hardening@lists.openwall.com
Return-path: <kernel-hardening-return-5772-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Content-Disposition: inline
In-Reply-To: <CAHmME9phg=GuhEUaMxxv_=RexffPDqrOEhmaKffy_ZSt7bfC7g@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On Thu, Dec 22, 2016 at 03:49:39AM +0100, Jason A. Donenfeld wrote:
> 
> Funny -- while you guys were sending this back & forth, I was writing
> my reply to Andy which essentially arrives at the same conclusion.
> Given that we're all arriving to the same thing, and that Ted shot in
> this direction long before we all did, I'm leaning toward abandoning
> SipHash for the de-MD5-ification of get_random_int/long, and working
> on polishing Ted's idea into something shiny for this patchset.

here are my numbers comparing siphash (using the first three patches
of the v7 siphash patches) with my batched chacha20 implementation.
The results are taken by running get_random_* 10000 times, and then
dividing the numbers by 10000 to get the average number of cycles for
the call.  I compiled 32-bit and 64-bit kernels, and ran the results
using kvm:

                   siphash                        batched chacha20
         get_random_int  get_random_long   get_random_int   get_random_long   

32-bit    270                  278             114            146
64-bit     75                   75             106            186

> I did have two objections to this. The first was that my SipHash
> construction is faster.

Well, it's faster on everything except 32-bit x86.  :-P

> The second, and the more
> important one, was that batching entropy up like this means that 32
> calls will be really fast, and then the 33rd will be slow, since it
> has to do a whole ChaCha round, because get_random_bytes must be
> called to refill the batch.

... and this will take 2121 cycles on 64-bit x86, and 2315 cycles on a
32-bit x86.  Which on a 2.3 GHz processor, is just under a
microsecond.  As far as being inconsistent on process startup, I very
much doubt a microsecond is really going to be visible to the user.  :-)

The bottom line is that I think we're really "pixel peeping" at this
point --- which is what obsessed digital photographers will do when
debating the quality of a Canon vs Nikon DSLR by blowing up a photo by
a thousand times, and then trying to claim that this is visible to the
human eye.  Or people who obsessing over the frequency response curves
of TH-X00 headphones with Mahogony vs Purpleheart wood, when it's
likely that in a blind head-to-head comparison, most people wouldn't
be able to tell the difference....

I think the main argument for using the batched getrandom approach is
that it, I would argue, simpler than introducing siphash into the
picture.  On 64-bit platforms it is faster and more consistent, so
it's basically that versus complexity of having to adding siphash to
the things that people have to analyze when considering random number
security on Linux.   But it's a close call either way, I think.

	    	     	      	      - Ted

P.S.  My benchmarking code....

diff --git a/drivers/char/random.c b/drivers/char/random.c
index a51f0ff43f00..41860864b775 100644
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -1682,6 +1682,55 @@ static int rand_initialize(void)
 }
 early_initcall(rand_initialize);
 
+static unsigned int get_random_int_new(void);
+static unsigned long get_random_long_new(void);
+
+#define NUM_CYCLES 10000
+#define AVG(finish, start) ((unsigned int)(finish - start + NUM_CYCLES/2) / NUM_CYCLES)
+
+static int rand_benchmark(void)
+{
+	cycles_t start,finish;
+	int i, out;
+
+	pr_crit("random benchmark!!\n");
+	start = get_cycles();
+	for (i = 0; i < NUM_CYCLES; i++) {
+		get_random_int();}
+	finish = get_cycles();
+	pr_err("get_random_int # cycles: %u\n", AVG(finish, start));
+
+	start = get_cycles();
+	for (i = 0; i < NUM_CYCLES; i++) {
+		get_random_int_new();
+	}
+	finish = get_cycles();
+	pr_err("get_random_int_new (batched chacha20) # cycles: %u\n", AVG(finish, start));
+
+	start = get_cycles();
+	for (i = 0; i < NUM_CYCLES; i++) {
+		get_random_long();
+	}
+	finish = get_cycles();
+	pr_err("get_random_long # cycles: %u\n", AVG(finish, start));
+
+	start = get_cycles();
+	for (i = 0; i < NUM_CYCLES; i++) {
+		get_random_long_new();
+	}
+	finish = get_cycles();
+	pr_err("get_random_long_new (batched chacha20) # cycles: %u\n", AVG(finish, start));
+
+	start = get_cycles();
+	for (i = 0; i < NUM_CYCLES; i++) {
+		get_random_bytes(&out, sizeof(out));
+	}
+	finish = get_cycles();
+	pr_err("get_random_bytes # cycles: %u\n", AVG(finish, start));
+	return 0;
+}
+device_initcall(rand_benchmark);
+
 #ifdef CONFIG_BLOCK
 void rand_initialize_disk(struct gendisk *disk)
 {
@@ -2064,8 +2113,10 @@ unsigned int get_random_int(void)
 	unsigned int ret;
 	u64 *chaining;
 
+#if 0	// force slow path
 	if (arch_get_random_int(&ret))
 		return ret;
+#endif
 
 	chaining = &get_cpu_var(get_random_int_chaining);
 	ret = *chaining = siphash_3u64(*chaining, jiffies, random_get_entropy() +
@@ -2083,8 +2134,10 @@ unsigned long get_random_long(void)
 	unsigned long ret;
 	u64 *chaining;
 
+#if 0 // force slow path
 	if (arch_get_random_long(&ret))
 		return ret;
+#endif 
 
 	chaining = &get_cpu_var(get_random_int_chaining);
 	ret = *chaining = siphash_3u64(*chaining, jiffies, random_get_entropy() +
@@ -2094,6 +2147,47 @@ unsigned long get_random_long(void)
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
+	unsigned int ret;
+
+	get_batched_entropy(&ret, sizeof(ret));
+	return ret;
+}
+
+static unsigned long get_random_long_new(void)
+{
+	unsigned long ret;
+
+	get_batched_entropy(&ret, sizeof(ret));
+	return ret;
+}
+
+
 /**
  * randomize_page - Generate a random, page aligned address
  * @start:	The smallest acceptable address the caller will take.
