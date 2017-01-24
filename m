From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net] net/mlx5e: Do not recycle pages from emergency reserve
Date: Tue, 24 Jan 2017 11:29:24 +0200
Message-ID: <CALzJLG_YLH01C-rd4eXCP2r1VGX8_Oy35cYivTzeQCuDK1rGJg@mail.gmail.com>
References: <1484809388.16328.19.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG8DzzpO97ehxWAdm=18Hw3Q9N6poTviDYuEFgyc9+O9RA@mail.gmail.com>
 <CALx6S35+miSu6QgjyQYVDGqu4hkq0eoj+wHha35HH5+DdSQtEg@mail.gmail.com>
 <CAPe+=50xs=MMqxHPgTiGa3qytL7633Cygf_vBWuAuq=ceLyacg@mail.gmail.com>
 <CALzJLG9JEorLwV48H3m0vQ1+VDnpYbKhiBoUw+WW-JFouJoj1g@mail.gmail.com> <CALx6S37EsGgf69R6N5DkLQbOgiHO1J4si4LMJ1+DMjnHW41eMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kernel netdev <netdev@brouer.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Davem <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:35044 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750707AbdAXJ3p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 04:29:45 -0500
Received: by mail-qt0-f196.google.com with SMTP id f4so23684331qte.2
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 01:29:45 -0800 (PST)
In-Reply-To: <CALx6S37EsGgf69R6N5DkLQbOgiHO1J4si4LMJ1+DMjnHW41eMQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 22, 2017 at 7:50 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Sat, Jan 21, 2017 at 12:31 PM, Saeed Mahameed
> <saeedm@dev.mellanox.co.il> wrote:
>> On Sat, Jan 21, 2017 at 9:12 PM, kernel netdev <netdev@brouer.com> wrote:
>>>
>>>
>>> Den 21. jan. 2017 7.10 PM skrev "Tom Herbert" <tom@herbertland.com>:
>>>
>>> On Thu, Jan 19, 2017 at 11:14 AM, Saeed Mahameed
>>> <saeedm@dev.mellanox.co.il> wrote:
>>>> On Thu, Jan 19, 2017 at 9:03 AM, Eric Dumazet <eric.dumazet@gmail.com>
>>>> wrote:
>>>>> From: Eric Dumazet <edumazet@google.com>
>>>>>
>>>>> A driver using dev_alloc_page() must not reuse a page allocated from
>>>>> emergency memory reserve.
>>>>>
>>>>> Otherwise all packets using this page will be immediately dropped,
>>>>> unless for very specific sockets having SOCK_MEMALLOC bit set.
>>>>>
>>>>> This issue might be hard to debug, because only a fraction of received
>>>>> packets would be dropped.
>>>>
>>>> Hi Eric,
>>>>
>>>> When you say reuse, you mean point to the same page from several SKBs ?
>>>>
>>>> Because in our page cache implementation we don't reuse pages that
>>>> already passed to the stack,
>>>> we just keep them in the page cache until the ref count drop back to
>>>> one, so we recycle them (i,e they will be re-used only when no one
>>>> else is using them).
>>>>
>>> Saeed,
>>>
>>> Speaking of the mlx page cache can we remove this or a least make it
>>> optional to use. It is another example of complex functionality being
>>> put into drivers that makes things like backports more complicated and
>>
>> Re complexity, I am not sure the mlx page cache is that complex,
>> we just wrap alloc_page/put_page with our own page cache calls.
>> Roughly the page cache implementation is 200-300 LOC tops all concentrated
>> in one place in the code.
>>
> Taken as part of the RX buffer management code the whole thing in very
> complicated and seems to be completely bereft of any comments in the
> code as to how things are supposed to work.
>

The Idea is fairly simple, maybe we could have made it cleaner if we
better decoupled the page
cache from the rx logic.

The page cache works in parallel to the rx logic, it takes its owns ref counts,
this way the rx logic will continue working as if there was no cache
(get/put_pages).
but instead of of the kernel (get/put_pages) it will call the internal
cache get/put_cache_page.

Yeah I agree, some comments could help. We will work on this when we
fix the HOL issues.
