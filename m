From: Andi Kleen <ak@suse.de>
Subject: Re: TODO list before feature freeze
Date: Mon, 29 Jul 2002 22:51:47 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020729225147.A24288@wotan.suse.de>
References: <20020729131239.A5183@wotan.suse.de> <200207291525.g6TFPTTu011558@marajade.sandelman.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com,
   netfilter-core@lists.netfilter.org
Return-path: <owner-netdev@oss.sgi.com>
To: Michael Richardson <mcr@sandelman.ottawa.on.ca>
Content-Disposition: inline
In-Reply-To: <200207291525.g6TFPTTu011558@marajade.sandelman.ottawa.on.ca>
List-Id: netdev.vger.kernel.org

On Mon, Jul 29, 2002 at 11:25:28AM -0400, Michael Richardson wrote:
> 
> >>>>> "Andi" == Andi Kleen <ak@suse.de> writes:
>     Andi> (case in point: we have at least one report that routing
>     Andi> performance breaks down with ip_conntrack when memory size is
>     Andi> increased over 1GB on P3s. The hash table size depends on the
>     Andi> memory size. The problem does not occur on P4s. P4s have larger
>     Andi> TLBs than P3s.)
> 
>   That's a non-obvious result.
> 
>   I'll bet that most of the memory-size based hash tables in the kernel
> suffer from similar problems. A good topic for a paper, I'd say.

In fact there have been papers about this like
http://www.citi.umich.edu/projects/linux-scalability/reports/hash.html
but the results were unfortunately not adapted.

This has been discussed for a long time. Linux hash tables suffer often
from poor hash functions (some are good, but others are not so great),
excessive sizing to cover the poor functions and using double pointer heads 
when not needed (=hash table twice as big). Excessive sizing wastes memory
(several MB just for hash tables on a standard system including some gems
like a incredible big mount hash table that near nobody needs to manage 
their 5-10 mounts) 

I wrote a slist.h that works like the linux
list.h some time ago, but uses lists instead of rings with a single pointer
head to at least avoid the last problem. In the following discussion
the preference was for a more generic hash table ADT instead of another
list abstraction.

So if you wanted to put some work into this I would:

- Develop some simple and tasteful and linux like (most of the existing
ones in other software packages fail at least one of these) generic hash table
abstraction.
- Convert all the big hash tables to this generic code.
- Let it use single pointer heads.
- Make it implement the sizing based on memory size in common code with a 
single knob to tune it per system. In fact I think it should definitely
take L2 cache size in account, not only main memory.
- Add generic statistics as CONFIG option so that you can see hit rates
for all your hash tables and how much space they need.
- Make it either use the existing hash function per table or a generic good 
hash function like http://burtleburtle.net/bob/hash/evahash.html

Try out all these knobs and write a paper about it.

- Try to get it merged with the best results as default options

Unfortunately netfilter hash is a bad example for this, because its
DoS handling requirements (LRU etc.) are more complex than what most other 
linux hash tables need and I am not sure if it would make sense to 
put it into generic code. On the other hand if the generic code is flexible
enough it would be possible to implement it on top of it.

-Andi
