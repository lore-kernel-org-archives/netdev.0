From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] mlx4: Better use of order-0 pages in RX path
Date: Mon, 13 Mar 2017 13:23:02 -0700
Message-ID: <20170313202300.GA52396@ast-mbp.thefacebook.com>
References: <20170313005848.7076-1-edumazet@google.com>
 <20170313173432.GA31333@ast-mbp.thefacebook.com>
 <CANn89iL_C8CMaxmkSvFxBMCjHx49JkEaKGoUPWMRYucrx09LnA@mail.gmail.com>
 <20170313183121.GA36306@ast-mbp.thefacebook.com>
 <CANn89iK1eyXH_6ViU0sj=yH+3+WVtVdXaAVBUkkcA=0dCvTkOA@mail.gmail.com>
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
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34744 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752548AbdCMUXH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 16:23:07 -0400
Received: by mail-pg0-f67.google.com with SMTP id b5so19458609pgg.1
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 13:23:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CANn89iK1eyXH_6ViU0sj=yH+3+WVtVdXaAVBUkkcA=0dCvTkOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 13, 2017 at 11:58:05AM -0700, Eric Dumazet wrote:
> On Mon, Mar 13, 2017 at 11:31 AM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
> > On Mon, Mar 13, 2017 at 10:50:28AM -0700, Eric Dumazet wrote:
> >> On Mon, Mar 13, 2017 at 10:34 AM, Alexei Starovoitov
> >> <alexei.starovoitov@gmail.com> wrote:
> >> > On Sun, Mar 12, 2017 at 05:58:47PM -0700, Eric Dumazet wrote:
> >> >> @@ -767,10 +814,30 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
> >> >>                       case XDP_PASS:
> >> >>                               break;
> >> >>                       case XDP_TX:
> >> >> +                             /* Make sure we have one page ready to replace this one */
> >> >> +                             npage = NULL;
> >> >> +                             if (!ring->page_cache.index) {
> >> >> +                                     npage = mlx4_alloc_page(priv, ring,
> >> >> +                                                             &ndma, numa_mem_id(),
> >> >> +                                                             GFP_ATOMIC | __GFP_MEMALLOC);
> >> >
> >> > did you test this with xdp2 test ?
> >> > under what conditions it allocates ?
> >> > It looks dangerous from security point of view to do allocations here.
> >> > Can it be exploited by an attacker?
> >> > we use xdp for ddos and lb and this is fast path.
> >> > If 1 out of 100s XDP_TX packets hit this allocation we will have serious
> >> > perf regression.
> >> > In general I dont think it's a good idea to penalize x86 in favor of powerpc.
> >> > Can you #ifdef this new code somehow? so we won't have these concerns on x86?
> >>
> >> Normal paths would never hit this point really. I wanted to be extra
> >> safe, because who knows, some guys could be tempted to set
> >> ethtool -G ethX  rx 512 tx 8192
> >>
> >> Before this patch, if you were able to push enough frames in TX ring,
> >> you would also eventually be forced to allocate memory, or drop frames...
> >
> > hmm. not following.
> > Into xdp tx queues packets don't come from stack. It can only be via xdp_tx.
> > So this rx page belongs to driver, not shared with anyone and it only needs to
> > be put onto tx ring, so I don't understand why driver needs to allocating
> > anything here. To refill the rx ring? but why here?
> 
> Because RX ring can be shared, by packets goind to the upper stacks (say TCP)
> 
> So there is no guarantee that the pages in the quarantine pool have
> their page count to 1.
> 
> The normal TX_XDP path will recycle pages in ring->cache_page .
> 
> This is exactly where I pick up a replacement.
> 
> Pages in ring->cache_page have the guarantee to have no other users
> than ourself (mlx4 driver)
> 
> You might have not noticed that current mlx4 driver has a lazy refill
> of RX ring buffers, that eventually
> removes all the pages from RX ring, and we have to recover with this
> lazy mlx4_en_recover_from_oom() thing
> that will attempt to restart the allocations.
> 
> After my patch, we have the guarantee that the RX ring buffer is
> always fully populated.
> 
> When we receive a frame (XDP or not), we drop it if we can not
> replenish the RX slot,
> in case the oldest page in quarantine is not a recycling candidate and
> we can not allocate a new page.

Got it. Could you please add above explanation to the commit log,
since it's a huge difference vs other drivers.
I don't think any other driver in the tree follows this strategy.
I think that's the right call, but it shouldn't be hidden in details.
If that's the right approach (probably is) we should do it
in the other drivers too.
Though I don't see you dropping "to the stack" packet in this patch.
The idea is to drop the packet (whether xdp or not) if rx
buffer cannot be replinshed _regardless_ whether driver
implements recycling, right?

> > rx 512 tx 8192 is meaningless from xdp pov, since most of the tx entries
> > will be unused.
> 
> Yes, but as an author of a kernel patch, I do not want to be
> responsible for a crash
> _if_ someone tries something dumb like that.
> 
> > why are you saying it will cause this if (!ring->page_cache.index) to trigger?
> >
> >> This patch does not penalize x86, quite the contrary.
> >> It brings a (small) improvement on x86, and a huge improvement on powerpc.
> >
> > for normal tcp stack. sure. I'm worried about xdp fast path that needs to be tested.
> 
> Note that TX_XDP in mlx4 is completely broken as I mentioned earlier.

Theory vs practice. We don't see this issue running xdp.
My understanding, since rx and tx napi are scheduled for the same cpu
there is a guarantee that during normal invocation they won't race
and the only problem is due to mlx4_en_recover_from_oom() that can
run rx napi on some random cpu.
