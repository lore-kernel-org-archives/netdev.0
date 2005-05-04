From: Andi Kleen <ak@muc.de>
Subject: Re: (diet-)FIB alternative fib_hlist.c
Date: Wed, 04 May 2005 20:39:10 +0200
Message-ID: <m1zmvax2cx.fsf@muc.de>
References: <17016.62444.34282.625407@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens.Laas@data.slu.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <17016.62444.34282.625407@robur.slu.se> (Robert Olsson's
 message of "Wed, 4 May 2005 18:10:20 +0200")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert Olsson <Robert.Olsson@data.slu.se> writes:

> Hello!
>
> fib_hlist is the smallest and simpliest routing algo we could think of
> it's just a sorted (h)list.
>
> routing (FIB lookup) performance. dst hash is not used.
>
>     fib_hlist   fib_hash  test        routing table size 
>     -----------------------------------------------------
>     444 kpps    433 kpps  Single flow. local=19/main=5 entries
>     433 kpps    431 kpps  rDoS.        local=19/main=5
>     0.2 kpps    198 kpps  rDoS         local=19/main=123946
>
> As seen fib_hlist is catastrophe for large routing tables as expected but 
> performs surprisingly well for ordinary routing tables so it should be 
> fine for most hosts and servers. The patch has config option to select FIB.
>
> Probably we soon want to specify differnt lookup schemes for different 
> tables say for local table fib_hash or fib_hlist. While for large main table
> fib_hash2/fib_trie would be better option.

Great patch! I wanted to do something like this for a long time :/
It is a good solution for 99.999% of all users who never have more
than a few routes.

Random comments while reading the code:

I would perhaps add a printk that warns the user if there are
more than 10 routes or so to use a different FIB.

Also I would try to replace the write locks with normal spinlocks.
read/write locks should not be needed for the use case of a normal
client who basically never changes the routing table, and normal
spinlocks are more friendly to modern cache coherency protocols.

With only a few routes it is overkill to have two kmem caches,
which both need at least a page each. With 10-20 routes you
waste half the memory because of that. Better use a single 
slab cache for both object types or just kmalloc.

Now we only need support for loadable fibs, then
distributions could use this too. Loadable ones should
be pretty easy, as long as you dont try to make them unloadable.
The later would need a lot of reference counting in fast paths,
which would be probably a bad idea. And losing that capability
is not a big issue.

-Andi
