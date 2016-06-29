From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v2 net-next] tcp: md5: use kmalloc() backed scratch areas
Date: Wed, 29 Jun 2016 07:59:22 -0700
Message-ID: <CALCETrW3zzMRazohKfOh7PKb5jegJOmyrC7EiCEF0eQ5SArNyg@mail.gmail.com>
References: <CALCETrXezCXy4N7wMjYdr+U1A9Avda5bVxTxOQZswinh62gbvw@mail.gmail.com>
 <1466827910.6850.123.camel@edumazet-glaptop3.roam.corp.google.com>
 <1466828771.6850.124.camel@edumazet-glaptop3.roam.corp.google.com>
 <1466829439.6850.126.camel@edumazet-glaptop3.roam.corp.google.com>
 <1466870975.6850.139.camel@edumazet-glaptop3.roam.corp.google.com>
 <1467046313.6850.171.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALCETrUSi3T5JXMunEO9RM5ZEz=aA2xtf9encEVYGxJF4mbhKg@mail.gmail.com>
 <20160628034150.GA13953@gondor.apana.org.au> <CALCETrXOT-zaV8O1Yu4RGybGvPv5C7gr=7EWjTKvUQUaRxz1aQ@mail.gmail.com>
 <20160629022337.GB23390@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f48.google.com ([209.85.213.48]:36483 "EHLO
	mail-vk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752160AbcF2PAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 11:00:47 -0400
Received: by mail-vk0-f48.google.com with SMTP id m127so9966555vkb.3
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2016 07:59:47 -0700 (PDT)
In-Reply-To: <20160629022337.GB23390@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 28, 2016 at 7:23 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Tue, Jun 28, 2016 at 10:35:31AM -0700, Andy Lutomirski wrote:
>>
>> Do you mean this code:
>
> Yes.
>
>> I'm wondering why support for scatterlists is all-or-nothing.  Why
>> can't we initialize a hash object and then alternate between passing
>> it scatterlists and pointers?
>
> Because once you have started hashing the hash state is not stored
> in a consistent format.  Our software code may maintain one format
> while a hardware implementation could do something else altogether.
> So you have to stick with one implementation throughout a particular
> hashing session.
>
>> I'm guessing that ahash enables async operation and shash is
>> synchronous only.  If I'm right, I understand why ahash requires a
>> scatterlist.  What I don't understand is why shash can't also accept a
>> scatterlist.  It appears that most of the ahash users in the tree
>> actually want synchronous crypto and are presumably using ahash for
>> some other reason such as ahash's ability to hash via scatterlist (in
>> this case, struct page *).
>
> ahash is meant to be the interface everyone uses regardless of
> whether they want sync-only or async.  shash should only be used
> for small amounts of hashing on virtual addresses.

I suspect that, if you compare a synchronous implementation that can
use virtual addresses to a DMA based implementation that can't, you'll
find that, for short messages like tcp md5 uses, the synchronous
implementation would win every time.  I'm wondering if shash should
gain the ability to use scatterlists and, if it doesn't already have
it, the ability to use synchronous hardware implementations (like
SHA-NI, for example, although I don't think that's useful for MD5).

--Andy
