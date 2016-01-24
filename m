From: Florian Westphal <fw@strlen.de>
Subject: Re: net: GPF in netlink_getsockbyportid
Date: Sun, 24 Jan 2016 01:11:03 +0100
Message-ID: <20160124001103.GA2748@breakpoint.cc>
References: <CACT4Y+Zmwr0VbfB5RAoLTCJJAF7epZWbbMkHxtXUwvF3tXbrgQ@mail.gmail.com>
 <20160123192502.GB17729@breakpoint.cc>
 <56A3DCF7.7000404@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Dmitry Vyukov <dvyukov@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Thomas Graf <tgraf@suug.ch>,
	Ken-ichirou MATSUZAWA <chamaken@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	David Herrmann <dh.herrmann@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	netfilter-devel@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:57348 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751456AbcAXALT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2016 19:11:19 -0500
Content-Disposition: inline
In-Reply-To: <56A3DCF7.7000404@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 01/23/2016 08:25 PM, Florian Westphal wrote:
> >Dmitry Vyukov <dvyukov@google.com> wrote:
> >
> >[ CC nf-devel, not sure if its nfnetlink fault or NETLINK_MMAP ]
> >
> >>The following program causes GPF in netlink_getsockbyportid:
[..]

> >CONFIG_NETLINK_MMAP and nfnetlink batching strike in unison :-/
> >
> >root cause is in nfnetlink_rcv_batch():
> >
> >296 replay:
> >297         status = 0;
> >298
> >299         skb = netlink_skb_clone(oskb, GFP_KERNEL);
> >
> >The clone op doesn't copy oskb->sk, so we oops in
> >__netlink_alloc_skb -> netlink_getsockbyportid() when nfnetlink_rcv_batch
> >tries to send netlink ack.
> 
> If indeed oskb is the mmap'ed netlink skb, then it's not even allowed
> to call into skb_clone()

Right, but in this case there is no mmap'd netlink sk involved -- we
crash when we try to look up dst netlink socket to see if there is an
mmap'd ring attached.

[ and that code isn't there with CONFIG_NETLINK_MMAP=n ].
