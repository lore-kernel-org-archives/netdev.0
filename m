From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v2 net-next] tcp: md5: use kmalloc() backed scratch areas
Date: Wed, 29 Jun 2016 09:41:44 -0700
Message-ID: <CALCETrUR1+au2-11qSAT24832nZcTwjUj8UY09rCMisyHawnaA@mail.gmail.com>
References: <1466829439.6850.126.camel@edumazet-glaptop3.roam.corp.google.com>
 <1466870975.6850.139.camel@edumazet-glaptop3.roam.corp.google.com>
 <1467046313.6850.171.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALCETrUSi3T5JXMunEO9RM5ZEz=aA2xtf9encEVYGxJF4mbhKg@mail.gmail.com>
 <20160628034150.GA13953@gondor.apana.org.au> <CALCETrXOT-zaV8O1Yu4RGybGvPv5C7gr=7EWjTKvUQUaRxz1aQ@mail.gmail.com>
 <20160629022337.GB23390@gondor.apana.org.au> <CALCETrW3zzMRazohKfOh7PKb5jegJOmyrC7EiCEF0eQ5SArNyg@mail.gmail.com>
 <20160629150257.GA29490@gondor.apana.org.au> <CALCETrVKjwKkzR+qwsC=DMvM9tR4beAtvw=LLjzsAyuztV4bWw@mail.gmail.com>
 <20160629153818.GA29838@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f45.google.com ([209.85.213.45]:32991 "EHLO
	mail-vk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751782AbcF2QmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 12:42:05 -0400
Received: by mail-vk0-f45.google.com with SMTP id j3so73840910vkb.0
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2016 09:42:05 -0700 (PDT)
In-Reply-To: <20160629153818.GA29838@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 29, 2016 at 8:38 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Wed, Jun 29, 2016 at 08:26:43AM -0700, Andy Lutomirski wrote:
>>
>> Two reasons:
>>
>> 1. Code like tcp md5 would be simpler if it could pass a scatterlist
>> to hash the skb but use a virtual address for the header.
>
> True.  But I bet we can make it simpler in other ways without
> creating special interfaces for it.  Look at how we do IPsec
> encryption/hashing, this is what TCP md5 should look like.  But
> nobody in their right mind would bother doing this because this
> is dead code.
>
>> 2. The actual calling sequence and the amount of indirection is much
>> less for shash, so hashing short buffer is probably *much* faster.
>
> Really?
>
> Have you measured the speed difference between the ahash and shash
> interfaces? Are you sure that this would matter when compared
> against the speed of hashing a single MD5 block?
>

It's non-negligible.  If I had SHA-NI, it would probably be a bigger
relative difference.

[    0.535717] SHA1 ahash: warming up
[    0.737471] SHA1 ahash: 500000 loops, 386 ns/loop
[    0.737937] SHA1 shash: warming up
[    0.903131] SHA1 shash: 500000 loops, 323 ns/loop
[    1.055409] SHA1 shash_digest: 500000 loops, 303 ns/loop

[    0.574410] SHA1 ahash: warming up
[    0.796927] SHA1 ahash: 500000 loops, 414 ns/loop
[    0.797695] SHA1 shash: warming up
[    0.959772] SHA1 shash: 500000 loops, 316 ns/loop
[    1.100886] SHA1 shash_digest: 500000 loops, 280 ns/loop

Here's MD5:

[    0.504708] MD5 ahash: warming up
[    0.688155] MD5 ahash: 500000 loops, 344 ns/loop
[    0.688971] MD5 shash: warming up
[    0.834953] MD5 shash: 500000 loops, 285 ns/loop
[    0.982021] MD5 shash_digest: 500000 loops, 292 ns/loop

[    0.570780] MD5 ahash: warming up
[    0.754325] MD5 ahash: 500000 loops, 357 ns/loop
[    0.754807] MD5 shash: warming up
[    0.906861] MD5 shash: 500000 loops, 297 ns/loop
[    1.059057] MD5 shash_digest: 500000 loops, 303 ns/loop

If you throw in sub-one-block requests, it'll be worse, because those
requests don't do real work.

Overall, it looks like there's overhead of something like 50ns for
each ahash invocation vs the shash equivalent.  It's not huge, but
it's there.  (This is cache-hot.  I bet it's considerably worse if
cache-cold, because ahash will require a lot more code cache lines as
well as the extra cache lines involved in the scatterlist and whatever
arch stuff is needed to map back and forth between virtual and
physical addresses.

Here's the code:

static void test_ahash(void)
{
    struct crypto_ahash *hash;
    struct ahash_request *req;
    struct scatterlist sg_in;
    char *buf, *out;
    int i;
    u64 end, start;
    unsigned loops = 500000;

    hash = crypto_alloc_ahash("sha1", 0, CRYPTO_ALG_ASYNC);
    if (IS_ERR(hash))
        return;

    req = ahash_request_alloc(hash, GFP_KERNEL);
    if (!req)
        return;

    ahash_request_set_callback(req, 0, NULL, NULL);

    buf = kmalloc(64, GFP_KERNEL);
    memset(buf, 0, 64);
    out = kmalloc(20, GFP_KERNEL);

    pr_err("SHA1 ahash: warming up\n");

    for (i = 0; i < 10000; i++) {
        crypto_ahash_init(req);
        sg_init_one(&sg_in, buf, 64);
        ahash_request_set_crypt(req, &sg_in, NULL, 64);
        if (crypto_ahash_update(req))
            return;
        ahash_request_set_crypt(req, NULL, out, 0);
        if (crypto_ahash_final(req))
            return;
    }

    start = ktime_get_ns();
    for (i = 0; i < loops; i++) {
        crypto_ahash_init(req);
        sg_init_one(&sg_in, buf, 64);
        ahash_request_set_crypt(req, &sg_in, NULL, 64);
        if (crypto_ahash_update(req))
            return;
        ahash_request_set_crypt(req, NULL, out, 0);
        if (crypto_ahash_final(req))
            return;
    }
    end = ktime_get_ns();

    pr_err("SHA1 ahash: %u loops, %llu ns/loop\n", loops, (unsigned
long long)((end-start)/loops));
}

static void test_shash(void)
{
    struct crypto_shash *hash;
    struct shash_desc *desc;
    char *buf, *out;
    int i;
    u64 end, start;
    unsigned loops = 500000;

    hash = crypto_alloc_shash("sha1", 0, CRYPTO_ALG_ASYNC);
    if (IS_ERR(hash))
        return;

    desc = kmalloc(crypto_shash_descsize(hash), GFP_KERNEL);
    if (!desc)
        return;
    desc->tfm = hash;
    desc->flags = 0;

    /*
     * Hmm.  This interface isn't conducive to the use of hardware that
     * needs state beyond what lives in a single memory buffer -- how would
     * the shash implementation know when to free the state?
     */

    buf = kmalloc(64, GFP_KERNEL);
    memset(buf, 0, 64);
    out = kmalloc(20, GFP_KERNEL);

    pr_err("SHA1 shash: warming up\n");

    for (i = 0; i < 10000; i++) {
        crypto_shash_init(desc);
        if (crypto_shash_update(desc, buf, 64))
            return;
        if (crypto_shash_final(desc, out))
            return;
    }

    start = ktime_get_ns();
    for (i = 0; i < loops; i++) {
        /*
         * For fairness, this does init; update; final instead of
         * just digest.
         */
        crypto_shash_init(desc);
        if (crypto_shash_update(desc, buf, 64))
            return;
        if (crypto_shash_final(desc, out))
            return;
    }
    end = ktime_get_ns();

    pr_err("SHA1 shash: %u loops, %llu ns/loop\n", loops, (unsigned
long long)((end-start)/loops));

    start = ktime_get_ns();
    for (i = 0; i < loops; i++) {
        crypto_shash_digest(desc, buf, 64, out);
    }
    end = ktime_get_ns();

    pr_err("SHA1 shash_digest: %u loops, %llu ns/loop\n", loops,
(unsigned long long)((end-start)/loops));
}
