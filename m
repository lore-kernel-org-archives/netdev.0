From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] x86: Run checksumming in parallel accross multiple alu's
Date: Thu, 31 Oct 2013 14:30:03 -0400
Message-ID: <20131031183003.GC25894@hmsreliant.think-freely.org>
References: <201310300525.r9U5Pdqo014902@ib.usersys.redhat.com>
 <20131030110214.GA10220@localhost.localdomain>
 <52710B09.6090302@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Laight <David.Laight@ACULAB.COM>
To: Doug Ledford <dledford@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52710B09.6090302@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 30, 2013 at 09:35:05AM -0400, Doug Ledford wrote:
> On 10/30/2013 07:02 AM, Neil Horman wrote:
> 
> >That does makes sense, but it then begs the question, whats the advantage of
> >having multiple alu's at all?
> 
> There's lots of ALU operations that don't operate on the flags or
> other entities that can be run in parallel.
> 
> >If they're just going to serialize on the
> >updating of the condition register, there doesn't seem to be much advantage in
> >having multiple alu's at all, especially if a common use case (parallelizing an
> >operation on a large linear dataset) resulted in lower performance.
> >
> >/me wonders if rearranging the instructions into this order:
> >adcq 0*8(src), res1
> >adcq 1*8(src), res2
> >adcq 2*8(src), res1
> >
> >would prevent pipeline stalls.  That would be interesting data, and (I think)
> >support your theory, Doug.  I'll give that a try
> 
> Just to avoid spending too much time on various combinations, here
> are the methods I've tried:
> 
> Original code
> 2 chains doing interleaved memory accesses
> 2 chains doing serial memory accesses (as above)
> 4 chains doing serial memory accesses
> 4 chains using 32bit values in 64bit registers so you can always use
> add instead of adc and never need the carry flag
> 
> And I've done all of the above with simple prefetch and smart prefetch.
> 
> 


So, above and beyond this I spent yesterday trying this pattern, something Doug
and I discussed together offline:
 
asm("prefetch 5*64(%[src])\n\t"
    "addq 0*8(%[src]),%[res1]\n\t"
    "jo 2f\n\t"
    "incq %[cry]\n\t"
    "2:addq 1*8(%[src]),%[res2]\n\t"
    "jc 3f\n\t"
    "incq %[cry]\n\t"
    "3:addq 2*8(%[src]),%[res1]\n\t"
    ...

The hope being that by using the add instead instead of the adc instruction, and
alternatively testing the overflow and carry flags, I could break the
serialization on the flags register between subeuqent adds and start doing
things in parallel (creating a poor mans adcx/adox instruction in effect).  It
functions, but unfortunately the performance lost to the completely broken
branch prediction that this inflicts makes it a non starter:


Base Performance:
 Performance counter stats for './test.sh' (20 runs):

        48,143,372 L1-dcache-load-misses                                         ( +-  0.03% ) [74.99%]
                 0 L1-dcache-prefetches                                         [75.00%]
    13,913,339,911 cycles                    #    0.000 GHz                      ( +-  0.06% ) [75.01%]
        28,878,999 branch-misses                                                 ( +-  0.05% ) [75.00%]

       5.367618727 seconds time elapsed                                          ( +-  0.06% )


Prefetch and simluated adcx/adox from above:
 Performance counter stats for './test.sh' (20 runs):

        35,704,331 L1-dcache-load-misses                                         ( +-  0.07% ) [75.00%]
                 0 L1-dcache-prefetches                                         [75.00%]
    19,751,409,264 cycles                    #    0.000 GHz                      ( +-  0.59% ) [75.00%]
        34,850,056 branch-misses                                                 ( +-  1.29% ) [75.00%]

       7.768602160 seconds time elapsed                                          ( +-  1.38% )


With the above instruction changes the prefetching lowers our dcache miss rate
significantly, but greatly raises our branch miss rate, and absolutely kills our
cycle count and run time.

At this point I feel like this is dead in the water.  I apologize for wasting
everyones time.  The best thing to do here would seem to be:

1) Add in some prefetching (from what I've seen a simple prefetch is as
performant as smart prefetching), so we may as well do it exactly as
csum_copy_from_user does it, and save ourselves the extra while loop.

2) Revisit this when the AVX extensions, or the adcx/adox instructions are
available and we can really preform parallel alu ops here.

Does that sound reasonable?
Neil
