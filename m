From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net] net/mlx5e: Do not recycle pages from emergency reserve
Date: Tue, 24 Jan 2017 11:21:18 +0200
Message-ID: <CALzJLG-K0eDRzr_QcXxYth-hrnSKRtT96-7j=RUC703Gg2hqUw@mail.gmail.com>
References: <1484809388.16328.19.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG8DzzpO97ehxWAdm=18Hw3Q9N6poTviDYuEFgyc9+O9RA@mail.gmail.com>
 <CALx6S35+miSu6QgjyQYVDGqu4hkq0eoj+wHha35HH5+DdSQtEg@mail.gmail.com>
 <CAPe+=50xs=MMqxHPgTiGa3qytL7633Cygf_vBWuAuq=ceLyacg@mail.gmail.com>
 <1485026809.16328.181.camel@edumazet-glaptop3.roam.corp.google.com> <20170123101455.380ef896@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>, Davem <davem@davemloft.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:33191 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750713AbdAXJVk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 04:21:40 -0500
Received: by mail-qt0-f196.google.com with SMTP id n13so23658538qtc.0
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 01:21:39 -0800 (PST)
In-Reply-To: <20170123101455.380ef896@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 11:14 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> On Sat, 21 Jan 2017 11:26:49 -0800
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>> > My previous measurements show approx 20=E2=84=85 speedup on a UDP test=
 with
>> > delivery to remote CPU.
>> >
>> I find this a bit strange. When you have time (ie not while driving your
>> car or during week end) please give more details, for example on message
>> size.
>
> I tested this with both 64 bytes and 1500 bytes.  After I moved to 50G
> and 100G testing then I don't need to use 64 bytes packets to provoke
> the bottlenecks in the stack ;-)
>

Exactly! for XDP like uses cases, page cache maybe a non required optimizat=
ion.
but when you start testing a typical TCP use cases over 50/100G link
you will need
more buffers (pages) to host the traffic for longer periods, you will
hit that bottleneck.

>> Was it before skb_condense() was added ?
>
> It tested this just before skb_condense() was added.  BUT
> skb_condense() does not get activated when using mlx5, because uses
> build_skb() ie. not using frags.
>

Well, we can always replace build_skb with alloc_skb +
memcpy(skb->data, headlen) + add_skb_frag(payload)
does it it worth it ? and is it healthy that both skb->data and
skb_shinfo(skb)->frags[i] point to the same page ?

> For people that don't realize this:
>  Eric's optimization in skb_condense() is about trading remote CPU
>  atomic refcnt (put_page) for copy + local CPU refcnt dec.
>
> My measurements show cycles cost local=3D31 vs. remote=3D208, thus a
> estimated saving around 177 cycles.  Which is spend on calling a fairly
> complex function __pskb_pull_tail(), and only works for more complex
> SKBs with frags.
>
> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   LinkedIn: http://www.linkedin.com/in/brouer
