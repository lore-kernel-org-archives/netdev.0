From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] netfilter: nf_conntrack: fix RCU race in
 nf_conntrack_find_get
Date: Wed, 8 Jan 2014 21:23:43 +0100
Message-ID: <20140108202343.GJ9894@breakpoint.cc>
References: <1389090711-15843-1-git-send-email-avagin@openvz.org>
 <1389107305.26646.20.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140107152520.GF9894@breakpoint.cc>
 <1389188536.26646.84.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140108140444.GH9894@breakpoint.cc>
 <1389202287.26646.95.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140108201838.GI9894@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrey Vagin <avagin@openvz.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, vvs@openvz.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140108201838.GI9894@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian Westphal <fw@strlen.de> wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > The confirmed bit should always be set here.
> > 
> > So why are you testing it ?
> 
> To detect ct object recycling when tuple is identical.
> 
> This is my understanding of how we can end up with two
> cpus thinking they have exclusive ownership of the same ct:
> 
> A cpu0: starts lookup: find ct for tuple t
> B cpu1: starts lookup: find ct for tuple t
> C cpu0: finds ct c for tuple t, no refcnt taken yet
>   cpu1: finds ct c for tuple t, no refcnt taken yet
>    cpu2: destroys ct c, removes from hash table, calls ->destroy function
> D cpu0: tries to increment refcnt; fails since its 0: lookup ends
> E cpu0: allocates a new ct object since no acceptable ct was found for t
> F cpu0: allocator gives us just-freed ct c
> G cpu0: initialises ct, sets refcnt to 1
> H cpu0: adds extensions, ct object is put on unconfirmed list and
>         assigned to skb->nfct
> I cpu0: skb continues through network stack
> J cpu1: tries to increment refcnt, ok
> K cpu1: checks if ct matches requested tuple t: it does
> L cpu0: sets refcnt conntrack tuple, allocates extensions, etc.
    ^^^^
>   cpu1: sets skb->nfct to ct, skb continues through network stack

sorry, for that brain fart  This should only say
  L cpu1: sets skb->nfct to ct, skb continues...
