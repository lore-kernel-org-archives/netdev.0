From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Clean up fib_hash datastructures
Date: Sun, 19 Sep 2004 19:53:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040919195351.0b3560e6.davem@davemloft.net>
References: <20040918203319.24004d6e.davem@davemloft.net>
	<1095645106.1048.190.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1095645106.1048.190.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 19 Sep 2004 21:51:46 -0400
jamal <hadi@cyberus.ca> wrote:

> I wasnt %100 sure about the need to 
> separate fib node into those two. It seems to complicate things.
> If you want to allow introduction of new algos, then fib_node itself is
> gonna have to go as well IMO. Its an artifact or current alg.
> I am actually thinking nothing at all stays of fib_hash.c for any new
> algorithm. Infact thats the only new piece/file that a new algorithm
> should write.

There are two problems.  Well, logically one, which is the seperation
out of fib_node from the code.

I need to expose the layout of fib_node for other reasons.

If you look at Ben LaHaise's case, the issue becomes evident.
Firstly, fib_semantics was not designed to scale at all,
thus last weeks patches to add the hash tables.  That takes
care of half of his problems, the other half is because of
fn_hash_flush() and is what is relevant to this discussion.

fn_hash_flush() walks the entire table of routes looking for
routes pointing to fib_info objects which are RTNH_F_DEAD.

The simple solution is to make fib_info contain a list of
fib_node objects, then when code marks a fib_info as RTNH_F_DEAD
we just walk the list and kill the fib_node objects directly.

But because the layout of fib_node entirely is hidden in
fib_hash.c, and we want to allow pluggable lookup implementations,
something has to give.

So the general idea I was after was:

1) All things performing pure longest-matching prefix
   lookup on an ipv4 address is confined to fib_node objects
   and the actual lookup algorithm.

2) Everything that occurs once we have a matching fib_node
   object, is consolidated into a common pieces of code
   that does all the TOS, priority, et al. magic

Anyways, we can do this differently.  But at least with my
patch we have the means to do _something_.

> BTW, one thought to improve perfomance is to change the linked list in
> each of the buckets away from a linked list. 

Come again?  I'm a little slow today, you'll have to be a bit
more explicit about what your idea is exactly :-)
