From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: TODO list before feature freeze
Date: 29 Jul 2002 17:40:18 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <1027957218.12610.71.camel@tux>
References: <20020729131239.A5183@wotan.suse.de>
	<Pine.GSO.4.30.0207290719580.12604-100000@shell.cyberus.ca>
	<20020729135615.A20412@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, Rusty Russell <rusty@rustcorp.com.au>,
   Netfilter-devel <netfilter-devel@lists.netfilter.org>, netdev@oss.sgi.com,
   netfilter-core@lists.netfilter.org, Patrick Schaaf <bof@bof.de>
Return-path: <owner-netdev@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20020729135615.A20412@wotan.suse.de>
List-Id: netdev.vger.kernel.org

On Mon, 2002-07-29 at 13:56, Andi Kleen wrote:

> here is a patch for 2.4 that just makes it use get_free_pages to test the 
> TLB theory. Another obvious improvement would be to not use list_heads 
> for the hash table buckets - a single pointer would likely suffice and 
> it would cut the hash table in half, saving cache, TLB and memory.

I think the list_heads are used for only one thing currently, for the
early eviction in case of overload, then it scans backwards in the
chains to find unreplied connections to evict, or so the comment in
early_drop() says:

/* Traverse backwards: gives us oldest, which is roughly LRU */

but then it uses the normal LIST_FIND macro which I think traverses the
list in the normal forward direction. I havn't looked into the rest of
the code but I can't seem to remember anything that needs list_heads.

I think Patrick Schaaf is looking into conntrack as we speak. Maybe he
has any ideas?

I know I've had plans on rewriting the locking in conntrack which is
quite frankly horrible, one giant rwlock used for almost everything
(including the hashtable). One idea that has come to mind is using RCU
(need to learn more about it) or maybe use one rwlock per N buckets or
something. Looking at some stats from one of my routers I see that an
average connection is over 130 packets long so the ratio between reads
and writes is quite good.

And this eviction which occurs at overload needs to be redone, we can't
go around dropping one unreplied connection at a time, we need
gang-eviction of unreplied connections. We've had some nasty DDoS's here
in which our routers have been spending all cputime in conntrack trying
to evict connections to make room for the SYN floods coming in at
>130kpps.

-- 
/Martin

Never argue with an idiot. They drag you down to their level, then beat
you with experience.
