From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Clean up fib_hash datastructures
Date: Mon, 20 Sep 2004 12:11:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040920121123.70baf895.davem@davemloft.net>
References: <20040918203319.24004d6e.davem@davemloft.net>
	<1095645106.1048.190.camel@jzny.localdomain>
	<20040919195351.0b3560e6.davem@davemloft.net>
	<1095686672.1049.301.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1095686672.1049.301.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 20 Sep 2004 09:24:32 -0400
jamal <hadi@cyberus.ca> wrote:

> On Sun, 2004-09-19 at 22:53, David S. Miller wrote:
> > 
> > There are two problems.  Well, logically one, which is the seperation
> > out of fib_node from the code.
> > 
> > I need to expose the layout of fib_node for other reasons.
> > 
> > If you look at Ben LaHaise's case, the issue becomes evident.
> 
> IIRC, he was having issues when 1000 devices all came up at once and all
> tried to add local scope routes?

Furthermore, once you have 1000 devices the algorithms in
net/ipv4/fib_semantics.c fall apart.

The code in fib_semantics.c was written assuming that next
hop information composed of a small set of unique entries.
So even if your routing tables were huge, those routing
entries pointed to a small group of unique next-hop objects
(which is what fib_info represents).

So all of that code was using a singly linked list of all
fib_info's to do lookups.  Therefore once you have a couple
thousand entries, even the simplest event processing becomes
expensive.

> > Firstly, fib_semantics was not designed to scale at all,
> > thus last weeks patches to add the hash tables.  
> 
> Will have to look at those patches - already in?

Yes, current 2.6.x tree has the new fib_semantics.c code.

> I like the idea except for when enforcing that scheme to be used
> by other algorithms[1]. 

It is the core issue.

I read from this statement that it is envisioned that some
fib_node lookup algorithm could, in a different way, find
all fib_nodes corresponding to a given fib_info.  I ask you
to provide what that mechanism might be before I am willing
to be concerned about this possibility :-)

> > So the general idea I was after was:
> > 
> > 1) All things performing pure longest-matching prefix
> >    lookup on an ipv4 address is confined to fib_node objects
> >    and the actual lookup algorithm.
> > 
> > 2) Everything that occurs once we have a matching fib_node
> >    object, is consolidated into a common pieces of code
> >    that does all the TOS, priority, et al. magic
> 
> sigh. Ok, some of the stuff in fib_node like TOS lookups are
> necessary for _total_ RFC1812 compliance. So i see where you are coming
> from although i am not a big fan of it. I will chew on it in the
> background.

Jamal and others, while I have your brains active in this area
I have a question.

I tried very hard to preserve existing behavior wrt. TOS
handling wrt. the setting of CONFIG_IP_ROUTE_TOS.  Basically,
the r->rtm_tos is ignored when adding routes, and treated as
zero.

I believe I was successful in preserving existing behavior, but
I wonder if it makes sense any longer.  CONFIG_IP_ROUTE_TOS
changes not one data structure.  It does exactly:

1) Controls the presence of a TOS comparison in
   fib_rules.c:fib_lookup()

2) Controls, in fib_hash.c:
	a) TOS comparison in fn_hash_lookup()
	b) whether TOS is paid attention to in fn_hash_insert
	c) similarly in fn_hash_delete()

In the TOS comparison changes, the TOS test treats zero
TOS values as "any TOS".  Therefore unless the user explicitly
tried to add a non-zero TOS route, TOS makes no difference
in behavior both with and without CONFIG_IP_ROUTE_TOS set.

Therefore, I think it behooves us just kill off this config
value.  It saves a mere 6 or 7 lines of code and no data
space.
