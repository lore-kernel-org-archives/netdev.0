From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v2] jhash: Deinline jhash, jhash2 and __jhash_nwords
Date: Thu, 16 Jul 2015 08:43:25 -0700
Message-ID: <CALx6S367jArRC3eKSKsv7gFrgPxyDHWdtvfeO1SmQR91eYxwSw@mail.gmail.com>
References: <1437050416-13295-1-git-send-email-dvlasenk@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Denys Vlasenko <dvlasenk@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437050416-13295-1-git-send-email-dvlasenk@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 16, 2015 at 5:40 AM, Denys Vlasenko <dvlasenk@redhat.com> wrote:
> This patch deinlines jhash, jhash2 and __jhash_nwords.
>
> It also removes rhashtable_jhash2(key, length, seed)
> because it was merely calling jhash2(key, length, seed).
>
> With this .config: http://busybox.net/~vda/kernel_config,
> after deinlining these functions have sizes and callsite counts
> as follows:
>
> __jhash_nwords: 72 bytes, 75 calls
> jhash: 297 bytes, 111 calls
> jhash2: 205 bytes, 136 calls
>
jhash is used in several places in the critical data path. Does the
decrease in text size justify performance impact of not inlining it?

Tom

> Total size decrease is about 38,000 bytes:
>
>     text     data      bss       dec     hex filename
> 90663567 17221960 36659200 144544727 89d93d7 vmlinux5
> 90625577 17221864 36659200 144506641 89cff11 vmlinux.after
>
> Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
> CC: Thomas Graf <tgraf@suug.ch>
> CC: Alexander Duyck <alexander.h.duyck@redhat.com>
> CC: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
> CC: Herbert Xu <herbert@gondor.apana.org.au>
> CC: netdev@vger.kernel.org
> CC: linux-kernel@vger.kernel.org
> ---
> Changes in v2: created a new source file, jhash.c
>
>  include/linux/jhash.h | 123 +----------------------------------------
>  lib/Makefile          |   2 +-
>  lib/jhash.c           | 149 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  lib/rhashtable.c      |  13 +++--
>  4 files changed, 160 insertions(+), 127 deletions(-)
>  create mode 100644 lib/jhash.c
>
> diff --git a/include/linux/jhash.h b/include/linux/jhash.h
> index 348c6f4..0b3f55d 100644
> --- a/include/linux/jhash.h
> +++ b/include/linux/jhash.h
> @@ -31,131 +31,14 @@
>  /* Mask the hash value, i.e (value & jhash_mask(n)) instead of (value % n) */
>  #define jhash_mask(n)   (jhash_size(n)-1)
>
> -/* __jhash_mix -- mix 3 32-bit values reversibly. */
> -#define __jhash_mix(a, b, c)                   \
> -{                                              \
> -       a -= c;  a ^= rol32(c, 4);  c += b;     \
> -       b -= a;  b ^= rol32(a, 6);  a += c;     \
> -       c -= b;  c ^= rol32(b, 8);  b += a;     \
> -       a -= c;  a ^= rol32(c, 16); c += b;     \
> -       b -= a;  b ^= rol32(a, 19); a += c;     \
> -       c -= b;  c ^= rol32(b, 4);  b += a;     \
> -}
> -
> -/* __jhash_final - final mixing of 3 32-bit values (a,b,c) into c */
> -#define __jhash_final(a, b, c)                 \
> -{                                              \
> -       c ^= b; c -= rol32(b, 14);              \
> -       a ^= c; a -= rol32(c, 11);              \
> -       b ^= a; b -= rol32(a, 25);              \
> -       c ^= b; c -= rol32(b, 16);              \
> -       a ^= c; a -= rol32(c, 4);               \
> -       b ^= a; b -= rol32(a, 14);              \
> -       c ^= b; c -= rol32(b, 24);              \
> -}
> -
>  /* An arbitrary initial parameter */
>  #define JHASH_INITVAL          0xdeadbeef
>
> -/* jhash - hash an arbitrary key
> - * @k: sequence of bytes as key
> - * @length: the length of the key
> - * @initval: the previous hash, or an arbitray value
> - *
> - * The generic version, hashes an arbitrary sequence of bytes.
> - * No alignment or length assumptions are made about the input key.
> - *
> - * Returns the hash value of the key. The result depends on endianness.
> - */
> -static inline u32 jhash(const void *key, u32 length, u32 initval)
> -{
> -       u32 a, b, c;
> -       const u8 *k = key;
> -
> -       /* Set up the internal state */
> -       a = b = c = JHASH_INITVAL + length + initval;
> -
> -       /* All but the last block: affect some 32 bits of (a,b,c) */
> -       while (length > 12) {
> -               a += __get_unaligned_cpu32(k);
> -               b += __get_unaligned_cpu32(k + 4);
> -               c += __get_unaligned_cpu32(k + 8);
> -               __jhash_mix(a, b, c);
> -               length -= 12;
> -               k += 12;
> -       }
> -       /* Last block: affect all 32 bits of (c) */
> -       /* All the case statements fall through */
> -       switch (length) {
> -       case 12: c += (u32)k[11]<<24;
> -       case 11: c += (u32)k[10]<<16;
> -       case 10: c += (u32)k[9]<<8;
> -       case 9:  c += k[8];
> -       case 8:  b += (u32)k[7]<<24;
> -       case 7:  b += (u32)k[6]<<16;
> -       case 6:  b += (u32)k[5]<<8;
> -       case 5:  b += k[4];
> -       case 4:  a += (u32)k[3]<<24;
> -       case 3:  a += (u32)k[2]<<16;
> -       case 2:  a += (u32)k[1]<<8;
> -       case 1:  a += k[0];
> -                __jhash_final(a, b, c);
> -       case 0: /* Nothing left to add */
> -               break;
> -       }
> -
> -       return c;
> -}
> -
> -/* jhash2 - hash an array of u32's
> - * @k: the key which must be an array of u32's
> - * @length: the number of u32's in the key
> - * @initval: the previous hash, or an arbitray value
> - *
> - * Returns the hash value of the key.
> - */
> -static inline u32 jhash2(const u32 *k, u32 length, u32 initval)
> -{
> -       u32 a, b, c;
> -
> -       /* Set up the internal state */
> -       a = b = c = JHASH_INITVAL + (length<<2) + initval;
> -
> -       /* Handle most of the key */
> -       while (length > 3) {
> -               a += k[0];
> -               b += k[1];
> -               c += k[2];
> -               __jhash_mix(a, b, c);
> -               length -= 3;
> -               k += 3;
> -       }
> -
> -       /* Handle the last 3 u32's: all the case statements fall through */
> -       switch (length) {
> -       case 3: c += k[2];
> -       case 2: b += k[1];
> -       case 1: a += k[0];
> -               __jhash_final(a, b, c);
> -       case 0: /* Nothing left to add */
> -               break;
> -       }
> -
> -       return c;
> -}
> -
> +u32 jhash(const void *key, u32 length, u32 initval);
> +u32 jhash2(const u32 *k, u32 length, u32 initval);
>
>  /* __jhash_nwords - hash exactly 3, 2 or 1 word(s) */
> -static inline u32 __jhash_nwords(u32 a, u32 b, u32 c, u32 initval)
> -{
> -       a += initval;
> -       b += initval;
> -       c += initval;
> -
> -       __jhash_final(a, b, c);
> -
> -       return c;
> -}
> +u32 __jhash_nwords(u32 a, u32 b, u32 c, u32 initval);
>
>  static inline u32 jhash_3words(u32 a, u32 b, u32 c, u32 initval)
>  {
> diff --git a/lib/Makefile b/lib/Makefile
> index 6897b52..978be53 100644
> --- a/lib/Makefile
> +++ b/lib/Makefile
> @@ -26,7 +26,7 @@ obj-y += bcd.o div64.o sort.o parser.o halfmd4.o debug_locks.o random32.o \
>          bust_spinlocks.o kasprintf.o bitmap.o scatterlist.o \
>          gcd.o lcm.o list_sort.o uuid.o flex_array.o iov_iter.o clz_ctz.o \
>          bsearch.o find_bit.o llist.o memweight.o kfifo.o \
> -        percpu-refcount.o percpu_ida.o rhashtable.o reciprocal_div.o
> +        percpu-refcount.o percpu_ida.o jhash.o rhashtable.o reciprocal_div.o
>  obj-y += string_helpers.o
>  obj-$(CONFIG_TEST_STRING_HELPERS) += test-string_helpers.o
>  obj-y += hexdump.o
> diff --git a/lib/jhash.c b/lib/jhash.c
> new file mode 100644
> index 0000000..cf3c277
> --- /dev/null
> +++ b/lib/jhash.c
> @@ -0,0 +1,149 @@
> +/* Jenkins hash support.
> + *
> + * Copyright (C) 2006. Bob Jenkins (bob_jenkins@burtleburtle.net)
> + *
> + * http://burtleburtle.net/bob/hash/
> + *
> + * These are the credits from Bob's sources:
> + *
> + * lookup3.c, by Bob Jenkins, May 2006, Public Domain.
> + *
> + * These are functions for producing 32-bit hashes for hash table lookup.
> + * hashword(), hashlittle(), hashlittle2(), hashbig(), mix(), and final()
> + * are externally useful functions.  Routines to test the hash are included
> + * if SELF_TEST is defined.  You can use this free for any purpose.  It's in
> + * the public domain.  It has no warranty.
> + *
> + * Copyright (C) 2009-2010 Jozsef Kadlecsik (kadlec@blackhole.kfki.hu)
> + *
> + * I've modified Bob's hash to be useful in the Linux kernel, and
> + * any bugs present are my fault.
> + * Jozsef
> + */
> +#include <linux/export.h>
> +#include <linux/jhash.h>
> +
> +/* __jhash_mix -- mix 3 32-bit values reversibly. */
> +#define __jhash_mix(a, b, c)                   \
> +{                                              \
> +       a -= c;  a ^= rol32(c, 4);  c += b;     \
> +       b -= a;  b ^= rol32(a, 6);  a += c;     \
> +       c -= b;  c ^= rol32(b, 8);  b += a;     \
> +       a -= c;  a ^= rol32(c, 16); c += b;     \
> +       b -= a;  b ^= rol32(a, 19); a += c;     \
> +       c -= b;  c ^= rol32(b, 4);  b += a;     \
> +}
> +
> +/* __jhash_final - final mixing of 3 32-bit values (a,b,c) into c */
> +#define __jhash_final(a, b, c)                 \
> +{                                              \
> +       c ^= b; c -= rol32(b, 14);              \
> +       a ^= c; a -= rol32(c, 11);              \
> +       b ^= a; b -= rol32(a, 25);              \
> +       c ^= b; c -= rol32(b, 16);              \
> +       a ^= c; a -= rol32(c, 4);               \
> +       b ^= a; b -= rol32(a, 14);              \
> +       c ^= b; c -= rol32(b, 24);              \
> +}
> +
> +/* jhash - hash an arbitrary key
> + * @k: sequence of bytes as key
> + * @length: the length of the key
> + * @initval: the previous hash, or an arbitray value
> + *
> + * The generic version, hashes an arbitrary sequence of bytes.
> + * No alignment or length assumptions are made about the input key.
> + *
> + * Returns the hash value of the key. The result depends on endianness.
> + */
> +u32 jhash(const void *key, u32 length, u32 initval)
> +{
> +       u32 a, b, c;
> +       const u8 *k = key;
> +
> +       /* Set up the internal state */
> +       a = b = c = JHASH_INITVAL + length + initval;
> +
> +       /* All but the last block: affect some 32 bits of (a,b,c) */
> +       while (length > 12) {
> +               a += __get_unaligned_cpu32(k);
> +               b += __get_unaligned_cpu32(k + 4);
> +               c += __get_unaligned_cpu32(k + 8);
> +               __jhash_mix(a, b, c);
> +               length -= 12;
> +               k += 12;
> +       }
> +       /* Last block: affect all 32 bits of (c) */
> +       /* All the case statements fall through */
> +       switch (length) {
> +       case 12: c += (u32)k[11]<<24;
> +       case 11: c += (u32)k[10]<<16;
> +       case 10: c += (u32)k[9]<<8;
> +       case 9:  c += k[8];
> +       case 8:  b += (u32)k[7]<<24;
> +       case 7:  b += (u32)k[6]<<16;
> +       case 6:  b += (u32)k[5]<<8;
> +       case 5:  b += k[4];
> +       case 4:  a += (u32)k[3]<<24;
> +       case 3:  a += (u32)k[2]<<16;
> +       case 2:  a += (u32)k[1]<<8;
> +       case 1:  a += k[0];
> +                __jhash_final(a, b, c);
> +       case 0: /* Nothing left to add */
> +               break;
> +       }
> +
> +       return c;
> +}
> +EXPORT_SYMBOL_GPL(jhash);
> +
> +/* jhash2 - hash an array of u32's
> + * @k: the key which must be an array of u32's
> + * @length: the number of u32's in the key
> + * @initval: the previous hash, or an arbitray value
> + *
> + * Returns the hash value of the key.
> + */
> +u32 jhash2(const u32 *k, u32 length, u32 initval)
> +{
> +       u32 a, b, c;
> +
> +       /* Set up the internal state */
> +       a = b = c = JHASH_INITVAL + (length<<2) + initval;
> +
> +       /* Handle most of the key */
> +       while (length > 3) {
> +               a += k[0];
> +               b += k[1];
> +               c += k[2];
> +               __jhash_mix(a, b, c);
> +               length -= 3;
> +               k += 3;
> +       }
> +
> +       /* Handle the last 3 u32's: all the case statements fall through */
> +       switch (length) {
> +       case 3: c += k[2];
> +       case 2: b += k[1];
> +       case 1: a += k[0];
> +               __jhash_final(a, b, c);
> +       case 0: /* Nothing left to add */
> +               break;
> +       }
> +
> +       return c;
> +}
> +EXPORT_SYMBOL_GPL(jhash2);
> +
> +/* __jhash_nwords - hash exactly 3, 2 or 1 word(s) */
> +u32 __jhash_nwords(u32 a, u32 b, u32 c, u32 initval)
> +{
> +       a += initval;
> +       b += initval;
> +       c += initval;
> +
> +       __jhash_final(a, b, c);
> +
> +       return c;
> +}
> +EXPORT_SYMBOL_GPL(__jhash_nwords);
> diff --git a/lib/rhashtable.c b/lib/rhashtable.c
> index cc0c697..cf429c5 100644
> --- a/lib/rhashtable.c
> +++ b/lib/rhashtable.c
> @@ -663,11 +663,6 @@ static size_t rounded_hashtable_size(const struct rhashtable_params *params)
>                    (unsigned long)params->min_size);
>  }
>
> -static u32 rhashtable_jhash2(const void *key, u32 length, u32 seed)
> -{
> -       return jhash2(key, length, seed);
> -}
> -
>  /**
>   * rhashtable_init - initialize a new hash table
>   * @ht:                hash table to be initialized
> @@ -773,8 +768,14 @@ int rhashtable_init(struct rhashtable *ht,
>                 ht->p.hashfn = jhash;
>
>                 if (!(ht->key_len & (sizeof(u32) - 1))) {
> +                       typedef u32 (*hashfunc)(const void *k, u32 length, u32 initval);
> +
>                         ht->key_len /= sizeof(u32);
> -                       ht->p.hashfn = rhashtable_jhash2;
> +                       /*
> +                        * jhash2() 1st param is const u32*,
> +                        * p.hashfn wants const void*. Hence the cast:
> +                        */
> +                       ht->p.hashfn = (hashfunc)jhash2;
>                 }
>         }
>
> --
> 1.8.1.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
