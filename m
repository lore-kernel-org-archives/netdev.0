From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: net: GPF in netlink_getsockbyportid
Date: Mon, 25 Jan 2016 11:17:20 +0100
Message-ID: <20160125101720.GA1360@salvia>
References: <CACT4Y+Zmwr0VbfB5RAoLTCJJAF7epZWbbMkHxtXUwvF3tXbrgQ@mail.gmail.com>
 <20160123192502.GB17729@breakpoint.cc>
 <56A3DCF7.7000404@iogearbox.net>
 <20160124001103.GA2748@breakpoint.cc>
 <20160125100341.GA6735@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Dmitry Vyukov <dvyukov@google.com>,
	"David S. Miller" <davem@davemloft.net>,
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
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160125100341.GA6735@gondor.apana.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 25, 2016 at 06:03:41PM +0800, Herbert Xu wrote:
> On Sun, Jan 24, 2016 at 01:11:03AM +0100, Florian Westphal wrote:
> > Daniel Borkmann <daniel@iogearbox.net> wrote:
> > > On 01/23/2016 08:25 PM, Florian Westphal wrote:
> > > >Dmitry Vyukov <dvyukov@google.com> wrote:
> > > >
> > > >[ CC nf-devel, not sure if its nfnetlink fault or NETLINK_MMAP ]
> > > >
> > > >>The following program causes GPF in netlink_getsockbyportid:
> > [..]
> > 
> > > >CONFIG_NETLINK_MMAP and nfnetlink batching strike in unison :-/
> > > >
> > > >root cause is in nfnetlink_rcv_batch():
> > > >
> > > >296 replay:
> > > >297         status = 0;
> > > >298
> > > >299         skb = netlink_skb_clone(oskb, GFP_KERNEL);
> > > >
> > > >The clone op doesn't copy oskb->sk, so we oops in
> > > >__netlink_alloc_skb -> netlink_getsockbyportid() when nfnetlink_rcv_batch
> > > >tries to send netlink ack.
> > > 
> > > If indeed oskb is the mmap'ed netlink skb, then it's not even allowed
> > > to call into skb_clone()
> > 
> > Right, but in this case there is no mmap'd netlink sk involved -- we
> > crash when we try to look up dst netlink socket to see if there is an
> > mmap'd ring attached.
> > 
> > [ and that code isn't there with CONFIG_NETLINK_MMAP=n ].
> 
> Let's CC Pablo since he wrote the code in question.

I have just sent this patch:

http://patchwork.ozlabs.org/patch/572489/
