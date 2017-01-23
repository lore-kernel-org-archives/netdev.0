From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net] net/mlx5e: Do not recycle pages from emergency
 reserve
Date: Mon, 23 Jan 2017 10:14:55 +0100
Message-ID: <20170123101455.380ef896@redhat.com>
References: <1484809388.16328.19.camel@edumazet-glaptop3.roam.corp.google.com>
        <CALzJLG8DzzpO97ehxWAdm=18Hw3Q9N6poTviDYuEFgyc9+O9RA@mail.gmail.com>
        <CALx6S35+miSu6QgjyQYVDGqu4hkq0eoj+wHha35HH5+DdSQtEg@mail.gmail.com>
        <CAPe+=50xs=MMqxHPgTiGa3qytL7633Cygf_vBWuAuq=ceLyacg@mail.gmail.com>
        <1485026809.16328.181.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: brouer@redhat.com, Tom Herbert <tom@herbertland.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Davem <davem@davemloft.net>,
        Saeed Mahameed <saeedm@dev.mellanox.co.il>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35378 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750741AbdAWJPH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 04:15:07 -0500
In-Reply-To: <1485026809.16328.181.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 21 Jan 2017 11:26:49 -0800
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> > My previous measurements show approx 20℅ speedup on a UDP test with
> > delivery to remote CPU.
> >   
> I find this a bit strange. When you have time (ie not while driving your
> car or during week end) please give more details, for example on message
> size.

I tested this with both 64 bytes and 1500 bytes.  After I moved to 50G
and 100G testing then I don't need to use 64 bytes packets to provoke
the bottlenecks in the stack ;-)

> Was it before skb_condense() was added ?

It tested this just before skb_condense() was added.  BUT
skb_condense() does not get activated when using mlx5, because uses
build_skb() ie. not using frags.  

For people that don't realize this:
 Eric's optimization in skb_condense() is about trading remote CPU
 atomic refcnt (put_page) for copy + local CPU refcnt dec.

My measurements show cycles cost local=31 vs. remote=208, thus a
estimated saving around 177 cycles.  Which is spend on calling a fairly
complex function __pskb_pull_tail(), and only works for more complex
SKBs with frags.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
