From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v2 net-next] tcp: md5: use kmalloc() backed scratch areas
Date: Tue, 28 Jun 2016 10:35:31 -0700
Message-ID: <CALCETrXOT-zaV8O1Yu4RGybGvPv5C7gr=7EWjTKvUQUaRxz1aQ@mail.gmail.com>
References: <CALCETrXezCXy4N7wMjYdr+U1A9Avda5bVxTxOQZswinh62gbvw@mail.gmail.com>
 <1466827910.6850.123.camel@edumazet-glaptop3.roam.corp.google.com>
 <1466828771.6850.124.camel@edumazet-glaptop3.roam.corp.google.com>
 <1466829439.6850.126.camel@edumazet-glaptop3.roam.corp.google.com>
 <1466870975.6850.139.camel@edumazet-glaptop3.roam.corp.google.com>
 <1467046313.6850.171.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALCETrUSi3T5JXMunEO9RM5ZEz=aA2xtf9encEVYGxJF4mbhKg@mail.gmail.com> <20160628034150.GA13953@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f50.google.com ([209.85.213.50]:36031 "EHLO
	mail-vk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752238AbcF1RgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 13:36:04 -0400
Received: by mail-vk0-f50.google.com with SMTP id k62so22038685vkb.3
        for <netdev@vger.kernel.org>; Tue, 28 Jun 2016 10:35:51 -0700 (PDT)
In-Reply-To: <20160628034150.GA13953@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 27, 2016 at 8:41 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Mon, Jun 27, 2016 at 10:58:42AM -0700, Andy Lutomirski wrote:
>>
>> I wonder if it's worth switching from ahash to shash, though.  It
>> would probably be simpler and faster.
>
> No shash is not appropriate here because it needs to hash skb
> frags which are SG lists.
>

Do you mean this code:

    for (i = 0; i < shi->nr_frags; ++i) {
        const struct skb_frag_struct *f = &shi->frags[i];
        unsigned int offset = f->page_offset;
        struct page *page = skb_frag_page(f) + (offset >> PAGE_SHIFT);

        sg_set_page(&sg, page, skb_frag_size(f),
                offset_in_page(offset));
        ahash_request_set_crypt(req, &sg, NULL, skb_frag_size(f));
        if (crypto_ahash_update(req))
            return 1;
    }

I'm wondering why support for scatterlists is all-or-nothing.  Why
can't we initialize a hash object and then alternate between passing
it scatterlists and pointers?

I'm guessing that ahash enables async operation and shash is
synchronous only.  If I'm right, I understand why ahash requires a
scatterlist.  What I don't understand is why shash can't also accept a
scatterlist.  It appears that most of the ahash users in the tree
actually want synchronous crypto and are presumably using ahash for
some other reason such as ahash's ability to hash via scatterlist (in
this case, struct page *).

--Andy
