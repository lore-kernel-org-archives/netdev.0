From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] mlx4: Better use of order-0 pages in RX path
Date: Mon, 13 Mar 2017 11:31:23 -0700
Message-ID: <20170313183121.GA36306@ast-mbp.thefacebook.com>
References: <20170313005848.7076-1-edumazet@google.com>
 <20170313173432.GA31333@ast-mbp.thefacebook.com>
 <CANn89iL_C8CMaxmkSvFxBMCjHx49JkEaKGoUPWMRYucrx09LnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34889 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751777AbdCMSb2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 14:31:28 -0400
Received: by mail-pg0-f65.google.com with SMTP id g2so14448265pge.2
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 11:31:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CANn89iL_C8CMaxmkSvFxBMCjHx49JkEaKGoUPWMRYucrx09LnA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 13, 2017 at 10:50:28AM -0700, Eric Dumazet wrote:
> On Mon, Mar 13, 2017 at 10:34 AM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
> > On Sun, Mar 12, 2017 at 05:58:47PM -0700, Eric Dumazet wrote:
> >> @@ -767,10 +814,30 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
> >>                       case XDP_PASS:
> >>                               break;
> >>                       case XDP_TX:
> >> +                             /* Make sure we have one page ready to replace this one */
> >> +                             npage = NULL;
> >> +                             if (!ring->page_cache.index) {
> >> +                                     npage = mlx4_alloc_page(priv, ring,
> >> +                                                             &ndma, numa_mem_id(),
> >> +                                                             GFP_ATOMIC | __GFP_MEMALLOC);
> >
> > did you test this with xdp2 test ?
> > under what conditions it allocates ?
> > It looks dangerous from security point of view to do allocations here.
> > Can it be exploited by an attacker?
> > we use xdp for ddos and lb and this is fast path.
> > If 1 out of 100s XDP_TX packets hit this allocation we will have serious
> > perf regression.
> > In general I dont think it's a good idea to penalize x86 in favor of powerpc.
> > Can you #ifdef this new code somehow? so we won't have these concerns on x86?
> 
> Normal paths would never hit this point really. I wanted to be extra
> safe, because who knows, some guys could be tempted to set
> ethtool -G ethX  rx 512 tx 8192
> 
> Before this patch, if you were able to push enough frames in TX ring,
> you would also eventually be forced to allocate memory, or drop frames...

hmm. not following.
Into xdp tx queues packets don't come from stack. It can only be via xdp_tx.
So this rx page belongs to driver, not shared with anyone and it only needs to
be put onto tx ring, so I don't understand why driver needs to allocating
anything here. To refill the rx ring? but why here?
rx 512 tx 8192 is meaningless from xdp pov, since most of the tx entries
will be unused.
why are you saying it will cause this if (!ring->page_cache.index) to trigger?

> This patch does not penalize x86, quite the contrary.
> It brings a (small) improvement on x86, and a huge improvement on powerpc.

for normal tcp stack. sure. I'm worried about xdp fast path that needs to be tested.
