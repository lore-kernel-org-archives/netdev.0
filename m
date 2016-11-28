From: Florian Westphal <fw@strlen.de>
Subject: Re: net: GPF in eth_header
Date: Mon, 28 Nov 2016 23:19:23 +0100
Message-ID: <20161128221923.GC9858@breakpoint.cc>
References: <CANn89iJeWV9YnOzy4eXL4Sbcyw_kj_CA8JrfGaFxMse_MUFL6Q@mail.gmail.com>
 <CAAeHK+x48aKLcKfN2aYA1pBPr4Y4ESUvjCTu0xGPoYZuiRbaaw@mail.gmail.com>
 <1480359019.18162.79.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAAeHK+wWVp46ej0tk5mDnOHpH5Ky0+HiH9_SUqGcT0iTppLaGw@mail.gmail.com>
 <CACT4Y+Yr6UJxXosjx2FO=KtxGr40X07_UBiscs1BP1s8cTaqAA@mail.gmail.com>
 <1480362459.18162.83.camel@edumazet-glaptop3.roam.corp.google.com>
 <1480367152.18162.86.camel@edumazet-glaptop3.roam.corp.google.com>
 <1480367886.18162.88.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161128213444.GA9858@breakpoint.cc>
 <1480371244.18162.91.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
        Dmitry Vyukov <dvyukov@google.com>,
        syzkaller <syzkaller@googlegroups.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        David Miller <davem@davemloft.net>,
        Tom Herbert <tom@herbertland.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Jiri Benc <jbenc@redhat.com>,
        Sabrina Dubroca <sd@queasysnail.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:38602 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755337AbcK1WWY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 17:22:24 -0500
Content-Disposition: inline
In-Reply-To: <1480371244.18162.91.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2016-11-28 at 22:34 +0100, Florian Westphal wrote:
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > > Might be a bug added in commit daaa7d647f81f3
> > > > ("netfilter: ipv6: avoid nf_iterate recursion")
> > > > 
> > > > Florian, what do you think of dropping a packet that presumably was
> > > > mangled badly by nf_ct_frag6_queue() ?
> > 
> > ipv4 definitely frees malformed packets.
> > In general, I think netfilter should avoid 'silent' drops if possible
> > and let skb continue, but of course such skbs should not be made worse
> > as what we ate to begin with...
> > 
> > > > (Like about 48 byte pulled :(, and/or skb->csum changed )
> > 
> > I think this warrants a review of ipv6 reassembly too, bug reported here
> > is because ipv6 nf defrag is also done on output.
> 
> 
> ip6_frag_queue() definitely frees bad/mangled skbs()

Yes, sorry.  nf_ct_frag6_queue is mostly derived from ip6_frag_queue
so any bugs in one might also exist in other.
Thats all I wanted to say here.  I'll check this tomorrow.

> > Looks good, we'll need to change some of the errno return codes in
> > nf_ct_frag6_gather to 0 though for this to work, which should not be too
> > hard ;)
> 
> If the goal is to let buggy packets pass, then we might need to undo
> changes in nf_ct_frag6_queue()

It currently returns -EINVAL in cases where skb wasn't changed/altered
(e.g. because it doesn't have a fragment header), so we should ACCEPT in
that case.

As for 'buggy' packet, I think its ok to mimic ip6_frag_queue, i.e.
if it tosses returning NF_DROP under same circumstance seems ok.

(Passing however will -- on ingress side -- cause snmp stat increments
 in ipv6 reassembly, this still might be desireable).

I'll check where undo might be possible/not too hard.

Thanks Eric for debugging this!
