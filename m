From: Patrick Schaaf <bof@bof.de>
Subject: Re: TODO list before feature freeze
Date: Mon, 29 Jul 2002 18:15:01 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020729181501.C570@oknodo.bof.de>
References: <20020729131239.A5183@wotan.suse.de> <Pine.GSO.4.30.0207290719580.12604-100000@shell.cyberus.ca> <20020729135615.A20412@wotan.suse.de> <1027957218.12610.71.camel@tux>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, jamal <hadi@cyberus.ca>,
   Rusty Russell <rusty@rustcorp.com.au>,
   Netfilter-devel <netfilter-devel@lists.netfilter.org>, netdev@oss.sgi.com,
   netfilter-core@lists.netfilter.org, Patrick Schaaf <bof@bof.de>
Return-path: <owner-netdev@oss.sgi.com>
To: Martin Josefsson <gandalf@wlug.westbo.se>
Content-Disposition: inline
In-Reply-To: <1027957218.12610.71.camel@tux>; from gandalf@wlug.westbo.se on Mon, Jul 29, 2002 at 05:40:18PM +0200
List-Id: netdev.vger.kernel.org

(warning: crystal ball engaged to parse from the quoted mail snippets.
Maybe missing context. I'm just reading netfilter-devel)

> On Mon, 2002-07-29 at 13:56, Andi Kleen wrote:
> 
> > here is a patch for 2.4 that just makes it use get_free_pages to test the 
> > TLB theory.

I presume this is about the vmalloc()ed hash bucket table? If yes, it's
certainly an interesting experiment to try making it allocated from an
area without TLB issues. We can expect a TLB miss on every packet with
the current setup, allocating the bucket table from large-TLB memory
would be a clear win of one memory roundtrip.

The netfilter hook statistics patch I mentioned in the other mail,
should be able to show the difference. If my guess is right, you
could see a 5-10% improvement on the ip_conntrack hook functions.

> > Another obvious improvement would be to not use list_heads 
> > for the hash table buckets - a single pointer would likely suffice and 
> > it would cut the hash table in half, saving cache, TLB and memory.
> 
> Martin Josefsson wrote:
> I think the list_heads are used for only one thing currently, for the
> early eviction in case of overload,

Don't forget the nonscanning list_del(), called whenever a conntrack
is unhashed at it's death. However, with a suitable bucket number,
i.e. low chain lengths, the scan on conntrack removal would be OK.

The early_drop() scanning, if it wants to work backward, may as well
work forward, keeping a "last unreplied found" pointer, and returning
that when falling off the single list end.

Thus, I also think that the list could be simple.

>From the top of my head, here are other fields that we could get rid off:

- the ctrack backpointer in each tuple.
- the protocol field in each tuple.
- the 20 byte infos[] array in ip_conntrack.
- we could out-of-line ip_nat_info.

With the current layout, when lists must be walked on a 32-byte-cacheline
box, we are sure to always read two cache lines for the skipped-over
tuples.

> I know I've had plans on rewriting the locking in conntrack which is
> quite frankly horrible, one giant rwlock used for almost everything
> (including the hashtable).

I'd like to see lockmeter statistics before this change. When you split
the one lock into a sectored lock: each conntrack is hashed twice, so
you need to be careful with lock order when adding or removing.
(well, there is another possibility, but I won't go into that now)

> One idea that has come to mind is using RCU

I don't see RCU solving hash link list update problems. Care to explain
how that would work?

> And this eviction which occurs at overload needs to be redone, we can't
> go around dropping one unreplied connection at a time, we need
> gang-eviction of unreplied connections.

I propose to put them all on a seperate LRU list, and reap the oldest.

best regards
  Patrick
