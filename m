From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: 4.6.3, pppoe + shaper workload, skb_panic / skb_push /
 ppp_start_xmit
Date: Mon, 1 Aug 2016 22:54:25 +0200
Message-ID: <20160801205425.GC3031@alphalink.fr>
References: <c72d23549eaa7aadee1a66a6bb788a4a@nuclearcat.com>
 <CAM_iQpWuCw6Bgm=1BWMkoFkuav5xV+FyKPq0Ef+3N_qpQqv=AA@mail.gmail.com>
 <20160728110948.GA3046@alphalink.fr>
 <e6cb92be01af6190350b9b3765bee6e3@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:39268 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751467AbcHAVUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2016 17:20:06 -0400
Content-Disposition: inline
In-Reply-To: <e6cb92be01af6190350b9b3765bee6e3@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 28, 2016 at 02:28:23PM +0300, Denys Fedoryshchenko wrote:
> On 2016-07-28 14:09, Guillaume Nault wrote:
> > On Tue, Jul 12, 2016 at 10:31:18AM -0700, Cong Wang wrote:
> > > On Mon, Jul 11, 2016 at 12:45 PM,  <nuclearcat@nuclearcat.com> wrote:
> > > > Hi
> > > >
> > > > On latest kernel i noticed kernel panic happening 1-2 times per day. It is
> > > > also happening on older kernel (at least 4.5.3).
> > > >
> > > ...
> > > >  [42916.426463] Call Trace:
> > > >  [42916.426658]  <IRQ>
> > > >
> > > >  [42916.426719]  [<ffffffff81843786>] skb_push+0x36/0x37
> > > >  [42916.427111]  [<ffffffffa00e8ce5>] ppp_start_xmit+0x10f/0x150
> > > > [ppp_generic]
> > > >  [42916.427314]  [<ffffffff81853467>] dev_hard_start_xmit+0x25a/0x2d3
> > > >  [42916.427516]  [<ffffffff818530f2>] ?
> > > > validate_xmit_skb.isra.107.part.108+0x11d/0x238
> > > >  [42916.427858]  [<ffffffff8186dee3>] sch_direct_xmit+0x89/0x1b5
> > > >  [42916.428060]  [<ffffffff8186e142>] __qdisc_run+0x133/0x170
> > > >  [42916.428261]  [<ffffffff81850034>] net_tx_action+0xe3/0x148
> > > >  [42916.428462]  [<ffffffff810c401a>] __do_softirq+0xb9/0x1a9
> > > >  [42916.428663]  [<ffffffff810c4251>] irq_exit+0x37/0x7c
> > > >  [42916.428862]  [<ffffffff8102b8f7>] smp_apic_timer_interrupt+0x3d/0x48
> > > >  [42916.429063]  [<ffffffff818cb15c>] apic_timer_interrupt+0x7c/0x90
> > > 
> > > Interesting, we call a skb_cow_head() before skb_push() in
> > > ppp_start_xmit(),
> > > I have no idea why this could happen.
> > > 
> > The skb is corrupted: head is at ffff8800b0bf2800 while data is at
> > ffa00500b0bf284c.
> > 
> > Figuring out how this corruption happened is going to be hard without a
> > way to reproduce the problem.
> > 
> > Denys, can you confirm you're using a vanilla kernel?
> > Also I guess the ppp devices and tc settings are handled by accel-ppp.
> > If so, can you share more info about your setup (accel-ppp.conf, radius
> > attributes, iptables...) so that I can try to reproduce it on my
> > machines?
> 
> I have slight modification from vanilla:
> 
> --- linux/net/sched/sch_htb.c	2016-06-08 01:23:53.000000000 +0000
> +++ linux-new/net/sched/sch_htb.c	2016-06-21 14:03:08.398486593 +0000
> @@ -1495,10 +1495,10 @@
>  				cl->common.classid);
>  			cl->quantum = 1000;
>  		}
> -		if (!hopt->quantum && cl->quantum > 200000) {
> +		if (!hopt->quantum && cl->quantum > 2000000) {
>  			pr_warn("HTB: quantum of class %X is big. Consider r2q change.\n",
>  				cl->common.classid);
> -			cl->quantum = 200000;
> +			cl->quantum = 2000000;
>  		}
>  		if (hopt->quantum)
>  			cl->quantum = hopt->quantum;
> 
> But i guess it should not be reason of crash (it is related to another
> system,  without it i was unable to shape over 7Gbps, maybe with latest
> kernel i will not need this patch).
>
I guess such a big quantum is probably going to add some stress on HTB
because of longer dequeues. But that shouldn't make the kernel panic.
Anyway, I'm certainly not an HTB expert, so I can't comment further.
BTW, what about setting ->quantum directly and drop this patch if you
really need values this big?

> I'm trying to make reproducible conditions of crash, because right now it
> happens only on some servers in large networks (completely different ISPs,
> so i excluded possible hardware fault of specific server). It is complex
> config, i have accel-ppp, plus my own "shaping daemon" that apply several
> shapers on ppp interfaces. Wost thing it happens only on live customers, i
> am unable to reproduce same on stress tests. Also until recent kernel i
> was getting different panic messages (but all related to ppp).
> 
In the logs I commented earlier, the skb is probably corrupted before
the ppp_start_xmit() call. The PPP module hasn't done anything at this
stage, unless the packet was forwarded from another PPP interface.
In short, corruption could have happened anywhere. So we really need to
narrow down the scope or get a way to reproduce the problem.

> I think also at least one reason of crash also was fixed by "ppp: defer
> netns reference release for ppp channel" in 4.7.0 (maybe thats why i am
> getting less crashes recently).
> I tried also various kernel debug options that doesn't cause major
> performance degradation (locks checking, freed memory poisoning and etc),
> without any luck yet.
> Is it useful if i will post panics that at least
> occurs twice? (I will post below example, got recently)
Do you mean that you have many more different panics traces?
