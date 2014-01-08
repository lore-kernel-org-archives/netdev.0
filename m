From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] netfilter: nf_conntrack: fix RCU race in
 nf_conntrack_find_get
Date: Wed, 8 Jan 2014 15:04:44 +0100
Message-ID: <20140108140444.GH9894@breakpoint.cc>
References: <1389090711-15843-1-git-send-email-avagin@openvz.org>
 <1389107305.26646.20.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140107152520.GF9894@breakpoint.cc>
 <1389188536.26646.84.camel@edumazet-glaptop2.roam.corp.google.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1389188536.26646.84.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > This will also set up a null-binding when no matching SNAT/DNAT/MASQERUADE
> > rule existed.
> > 
> > The manipulations of the skb->nfct->ext nat area are performed without
> > a lock.  Concurrent access is supposedly impossible as the conntrack
> > should not (yet) be in the hash table.
> > 
> > The confirmed bit is set right before we insert the conntrack into
> > the hash table (after we traversed rules, ct is ready to be
> > 'published').
> > 
> > i.e. when the confirmed bit is NOT set we should not be 'seeing' the nf_conn
> > struct when we perform the lookup, as it should still be sitting on the
> > 'unconfirmed' list, being invisible to readers.
> > 
> > Does that explanation make sense to you?
> > 
> > Thanks for looking into this.
> 
> Still, this patch adds a loop. And maybe an infinite one if confirmed
> bit is set from an context that was interrupted by this one.

Hmm.  There should be at most one retry.

The confirmed bit should always be set here.
If it isn't then this conntrack shouldn't be in the hash table, i.e.
when we re-try we should find the same conntrack again with the bit set.

Asuming the other cpu git interrupted after setting confirmed
bit but before inserting it into the hash table, then our re-try
should not be able find a matching entry.

Maybe I am missing something, but I don't see how we could (upon
retry) find the very same entry again with the bit still not set.

> If you need to test the confirmed bit, then you also need to test it
> before taking the refcount.

I don't think that would make sense, because it should always be
set (inserting conntrack into hash table without confirmed set is
illegal, and it is never unset again).

[ when allocating a new conntrack, ct->status is zeroed, which also
  clears the flag.  This happens just before we set the new objects
  refcount to 1 ]
