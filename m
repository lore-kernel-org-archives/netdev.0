From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v2 net-next] tcp: md5: use kmalloc() backed scratch areas
Date: Wed, 29 Jun 2016 08:26:43 -0700
Message-ID: <CALCETrVKjwKkzR+qwsC=DMvM9tR4beAtvw=LLjzsAyuztV4bWw@mail.gmail.com>
References: <1466827910.6850.123.camel@edumazet-glaptop3.roam.corp.google.com>
 <1466828771.6850.124.camel@edumazet-glaptop3.roam.corp.google.com>
 <1466829439.6850.126.camel@edumazet-glaptop3.roam.corp.google.com>
 <1466870975.6850.139.camel@edumazet-glaptop3.roam.corp.google.com>
 <1467046313.6850.171.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALCETrUSi3T5JXMunEO9RM5ZEz=aA2xtf9encEVYGxJF4mbhKg@mail.gmail.com>
 <20160628034150.GA13953@gondor.apana.org.au> <CALCETrXOT-zaV8O1Yu4RGybGvPv5C7gr=7EWjTKvUQUaRxz1aQ@mail.gmail.com>
 <20160629022337.GB23390@gondor.apana.org.au> <CALCETrW3zzMRazohKfOh7PKb5jegJOmyrC7EiCEF0eQ5SArNyg@mail.gmail.com>
 <20160629150257.GA29490@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f50.google.com ([209.85.213.50]:32991 "EHLO
	mail-vk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752660AbcF2P1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 11:27:04 -0400
Received: by mail-vk0-f50.google.com with SMTP id j3so70836643vkb.0
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2016 08:27:03 -0700 (PDT)
In-Reply-To: <20160629150257.GA29490@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 29, 2016 at 8:02 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Wed, Jun 29, 2016 at 07:59:22AM -0700, Andy Lutomirski wrote:
>>> I suspect that, if you compare a synchronous implementation that can
>> use virtual addresses to a DMA based implementation that can't, you'll
>> find that, for short messages like tcp md5 uses, the synchronous
>> implementation would win every time.  I'm wondering if shash should
>> gain the ability to use scatterlists and, if it doesn't already have
>> it, the ability to use synchronous hardware implementations (like
>> SHA-NI, for example, although I don't think that's useful for MD5).
>
> I don't understand, if you add SGs to shash you get ahash.  So
> why wouldn't you just use ahash?

Two reasons:

1. Code like tcp md5 would be simpler if it could pass a scatterlist
to hash the skb but use a virtual address for the header.

2. The actual calling sequence and the amount of indirection is much
less for shash, so hashing short buffer is probably *much* faster.

ahash is very featureful, but it's also quite heavyweight and it's
missing the ability to use virtual addresses directly (for good
reason).  shash is simpler and probably much faster on short buffers,
but the only feature it's missing for most callers (the ones that want
synchronous operation) is the ability to use a scatterlist.  Given
that the crypto code already has the ability to walk a scatterlist,
map it, and hash it, it seems like it might be a nice addition to let
shash objects invoke that code path if they want
(crypto_shash_update_sg?).  This would have no overhead for users that
don't call it, and I bet it would both speed up and reduce the amount
of code in users like tcp md5.

--Andy
