From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 18:06:09 +1000
Message-ID: <46C556F1.8000407@yahoo.com.au>
References: <alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in> <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au> <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au> <46C40587.7050708@s5r6.in-berlin.de> <20070816081049.GA1431@gondor.apana.org.au> <46C41EE4.9090806@s5r6.in-berlin.de> <46C42767.4070104@s5r6.in-berlin.de> <20070816104250.GB2927@gondor.apana.org.au> <20070816163441.GB16957@linux.vnet.ibm.com> <46C512EB.7020603@yahoo.com.au> <46C54D74.60101@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Mackerras <paulus@samba.org>,
	Satyam Sharma <satyam@infradead.org>,
	Christoph Lameter <clameter@sgi.com>,
	Chris Snook <csnook@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	ak@suse.de, heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761522AbXHQIGt@vger.kernel.org>
In-Reply-To: <46C54D74.60101@s5r6.in-berlin.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stefan Richter wrote:
> Nick Piggin wrote:
> 
>>I don't know why people would assume volatile of atomics. AFAIK, most
>>of the documentation is pretty clear that all the atomic stuff can be
>>reordered etc. except for those that modify and return a value.
> 
> 
> Which documentation is there?

Documentation/atomic_ops.txt


> For driver authors, there is LDD3.  It doesn't specifically cover
> effects of optimization on accesses to atomic_t.
> 
> For architecture port authors, there is Documentation/atomic_ops.txt.
> Driver authors also can learn something from that document, as it
> indirectly documents the atomic_t and bitops APIs.
>

"Semantics and Behavior of Atomic and Bitmask Operations" is
pretty direct :)

Sure, it says that it's for arch maintainers, but there is no
reason why users can't make use of it.


> Prompted by this thread, I reread this document, and indeed, the
> sentence "Unlike the above routines, it is required that explicit memory
> barriers are performed before and after [atomic_{inc,dec}_return]"
> indicates that atomic_read (one of the "above routines") is very
> different from all other atomic_t accessors that return values.
> 
> This is strange.  Why is it that atomic_read stands out that way?  IMO

It is not just atomic_read of course. It is atomic_add,sub,inc,dec,set.


> this API imbalance is quite unexpected by many people.  Wouldn't it be
> beneficial to change the atomic_read API to behave the same like all
> other atomic_t accessors that return values?

It is very consistent and well defined. Operations which both modify
the data _and_ return something are defined to have full barriers
before and after.

What do you want to add to the other atomic accessors? Full memory
barriers? Only compiler barriers? It's quite likely that if you think
some barriers will fix bugs, then there are other bugs lurking there
anyway.

Just use spinlocks if you're not absolutely clear about potential
races and memory ordering issues -- they're pretty cheap and simple.


> OK, it is also different from the other accessors that return data in so
> far as it doesn't modify the data.  But as driver "author", i.e. user of
> the API, I can't see much use of an atomic_read that can be reordered
> and, more importantly, can be optimized away by the compiler.

It will return to you an atomic snapshot of the data (loaded from
memory at some point since the last compiler barrier). All you have
to be aware of compiler barriers and the Linux SMP memory ordering
model, which should be a given if you are writing lockless code.


> Sure, now
> that I learned of these properties I can start to audit code and insert
> barriers where I believe they are needed, but this simply means that
> almost all occurrences of atomic_read will get barriers (unless there
> already are implicit but more or less obvious barriers like msleep).

You might find that these places that appear to need barriers are
buggy for other reasons anyway. Can you point to some in-tree code
we can have a look at?

-- 
SUSE Labs, Novell Inc.
