From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Clean up fib_hash datastructures
Date: 20 Sep 2004 09:24:32 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095686672.1049.301.camel@jzny.localdomain>
References: <20040918203319.24004d6e.davem@davemloft.net>
	 <1095645106.1048.190.camel@jzny.localdomain>
	 <20040919195351.0b3560e6.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040919195351.0b3560e6.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2004-09-19 at 22:53, David S. Miller wrote:
> 
> There are two problems.  Well, logically one, which is the seperation
> out of fib_node from the code.
> 
> I need to expose the layout of fib_node for other reasons.
> 
> If you look at Ben LaHaise's case, the issue becomes evident.

IIRC, he was having issues when 1000 devices all came up at once and all
tried to add local scope routes?

> Firstly, fib_semantics was not designed to scale at all,
> thus last weeks patches to add the hash tables.  

Will have to look at those patches - already in?

> That takes
> care of half of his problems, the other half is because of
> fn_hash_flush() and is what is relevant to this discussion.
> 
> fn_hash_flush() walks the entire table of routes looking for
> routes pointing to fib_info objects which are RTNH_F_DEAD.
> 
> The simple solution is to make fib_info contain a list of
> fib_node objects, then when code marks a fib_info as RTNH_F_DEAD
> we just walk the list and kill the fib_node objects directly.

I like the idea except for when enforcing that scheme to be used
by other algorithms[1]. 

> But because the layout of fib_node entirely is hidden in
> fib_hash.c, and we want to allow pluggable lookup implementations,
> something has to give.

Makes sense.

> So the general idea I was after was:
> 
> 1) All things performing pure longest-matching prefix
>    lookup on an ipv4 address is confined to fib_node objects
>    and the actual lookup algorithm.
> 
> 2) Everything that occurs once we have a matching fib_node
>    object, is consolidated into a common pieces of code
>    that does all the TOS, priority, et al. magic

sigh. Ok, some of the stuff in fib_node like TOS lookups are
necessary for _total_ RFC1812 compliance. So i see where you are coming
from although i am not a big fan of it. I will chew on it in the
background.

> Anyways, we can do this differently.  But at least with my
> patch we have the means to do _something_.
> 
> > BTW, one thought to improve perfomance is to change the linked list in
> > each of the buckets away from a linked list. 
> 
> Come again?  I'm a little slow today, you'll have to be a bit
> more explicit about what your idea is exactly :-)

Never mind. I just realized you have plans to do binary search in the
hash to replace linked lists.

cheers,
jamal

[1] The other structures which the other algs _must_ use apart from
fib_info from a quick scan are: fib_result (I think this is fair),
flowi, and to a small degree fib_rule (if we continue keeping policy
routing where it is right now). Seems like a very clean separation to
just simply replace fib_hash.c if the TOS thing can be resolved.
