From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] netfilter: nf_conntrack: fix RCU race in
 nf_conntrack_find_get
Date: Wed, 8 Jan 2014 21:18:38 +0100
Message-ID: <20140108201838.GI9894@breakpoint.cc>
References: <1389090711-15843-1-git-send-email-avagin@openvz.org>
 <1389107305.26646.20.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140107152520.GF9894@breakpoint.cc>
 <1389188536.26646.84.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140108140444.GH9894@breakpoint.cc>
 <1389202287.26646.95.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, Andrey Vagin <avagin@openvz.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, vvs@openvz.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1389202287.26646.95.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > The confirmed bit should always be set here.
> 
> So why are you testing it ?

To detect ct object recycling when tuple is identical.

This is my understanding of how we can end up with two
cpus thinking they have exclusive ownership of the same ct:

A cpu0: starts lookup: find ct for tuple t
B cpu1: starts lookup: find ct for tuple t
C cpu0: finds ct c for tuple t, no refcnt taken yet
  cpu1: finds ct c for tuple t, no refcnt taken yet
   cpu2: destroys ct c, removes from hash table, calls ->destroy function
D cpu0: tries to increment refcnt; fails since its 0: lookup ends
E cpu0: allocates a new ct object since no acceptable ct was found for t
F cpu0: allocator gives us just-freed ct c
G cpu0: initialises ct, sets refcnt to 1
H cpu0: adds extensions, ct object is put on unconfirmed list and
        assigned to skb->nfct
I cpu0: skb continues through network stack
J cpu1: tries to increment refcnt, ok
K cpu1: checks if ct matches requested tuple t: it does
L cpu0: sets refcnt conntrack tuple, allocates extensions, etc.
  cpu1: sets skb->nfct to ct, skb continues through network stack

-> both cpu0 and cpu1 reference a ct object that was not in hash table

cpu0 and cpu1 will then race, for example in
net/ipv4/netfilter/iptable_nat.c:nf_nat_rule_find():

        if (!nf_nat_initialized(ct, HOOK2MANIP(hooknum)))
              ret = alloc_null_binding(ct, hooknum);

[ Its possible that I misunderstand and that there is something that
  precents this from happening.  Usually its the 'tuple equal' test
  that is performed post-atomic-inc-not-zero that detects the recycling,
  so step K above would fail ]

The idea of the 'confirmed bit test' is that when its not set then the
conntrack was recycled and should not be used before the cpu that
currently 'owns' that entry has put it into the hash table again.

> I did this RCU conversion, so I think I know what I am talking about.

Yes, I know.  If you have any suggestions on how to fix it, I'd be very
interested to hear about them.

> The entry should not be put into hash table (or refcnt set to 1),
> if its not ready. It is that simple.

I understand what you're saying, but I don't see how we can do it.

I think the assumption that we have a refcnt on skb->nfct is everywhere.

If I understand you correctly we'd have to differentiate between
'can be used fully (e.g. nf_nat_setup_info done for both directions)'
and 'a new conntrack was created (extensions may not be ready yet)'.

But currently in both cases the ct is assigned to the skb, and in both
cases a refcnt is taken.  I am out of ideas, except perhaps using
ct->lock to serialize the nat setup (but I don't like that since
I'm not sure that the nat race is the only one).

> We need to address this problem without adding an extra test and
> possible loop for the lookups.

Agreed.  I don't like the extra test either.

Many thanks for looking into this Eric!
