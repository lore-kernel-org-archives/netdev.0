From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Clean up fib_hash datastructures
Date: 21 Sep 2004 23:30:09 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095823808.1045.40.camel@jzny.localdomain>
References: <20040918203319.24004d6e.davem@davemloft.net>
	 <1095645106.1048.190.camel@jzny.localdomain>
	 <20040919195351.0b3560e6.davem@davemloft.net>
	 <1095686672.1049.301.camel@jzny.localdomain>
	 <20040920121123.70baf895.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040920121123.70baf895.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-09-20 at 15:11, David S. Miller wrote:
> On 20 Sep 2004 09:24:32 -0400
> jamal <hadi@cyberus.ca> wrote:
> 
> > On Sun, 2004-09-19 at 22:53, David S. Miller wrote:

Sorry missed this (that what happens with reading email backwards).

> Furthermore, once you have 1000 devices the algorithms in
> net/ipv4/fib_semantics.c fall apart.

Yikes - I just looked.
fib_sync_down and up are horrible. I think its at least 0(n^2). Yes, I
can see what would happen when you suddenly bring down 1000 devices.

> The code in fib_semantics.c was written assuming that next
> hop information composed of a small set of unique entries.
> So even if your routing tables were huge, those routing
> entries pointed to a small group of unique next-hop objects
> (which is what fib_info represents).
> 

yep - i see it.

> So all of that code was using a singly linked list of all
> fib_info's to do lookups.  Therefore once you have a couple
> thousand entries, even the simplest event processing becomes
> expensive.

Good cleanup in -bk7 with the hashes.

> > I like the idea except for when enforcing that scheme to be used
> > by other algorithms[1]. 
> 
> It is the core issue.
> 
> I read from this statement that it is envisioned that some
> fib_node lookup algorithm could, in a different way, find
> all fib_nodes corresponding to a given fib_info.  I ask you
> to provide what that mechanism might be before I am willing
> to be concerned about this possibility :-)

The way i see it is any new alg will have a fib_info at the end of its
lookup but not fib_node. fib_semantics only cares about fib_info.
Hence my comment above (my worry being you are breaking this
relationship - in particular now that you are thrwoing out TOS)

BTW, dont see the code in -bk7.

> Jamal and others, while I have your brains active in this area
> I have a question.
> 
> I tried very hard to preserve existing behavior wrt. TOS
> handling wrt. the setting of CONFIG_IP_ROUTE_TOS.  Basically,
> the r->rtm_tos is ignored when adding routes, and treated as
> zero.
> 
> I believe I was successful in preserving existing behavior, but
> I wonder if it makes sense any longer.  CONFIG_IP_ROUTE_TOS
> changes not one data structure.  It does exactly:
> 
> 1) Controls the presence of a TOS comparison in
>    fib_rules.c:fib_lookup()
> 
> 2) Controls, in fib_hash.c:
> 	a) TOS comparison in fn_hash_lookup()
> 	b) whether TOS is paid attention to in fn_hash_insert
> 	c) similarly in fn_hash_delete()
> 
> In the TOS comparison changes, the TOS test treats zero
> TOS values as "any TOS".  Therefore unless the user explicitly
> tried to add a non-zero TOS route, TOS makes no difference
> in behavior both with and without CONFIG_IP_ROUTE_TOS set.
> 
> Therefore, I think it behooves us just kill off this config
> value.  It saves a mere 6 or 7 lines of code and no data
> space.

Still need comment on this after killing TOS?

cheers,
jamal
