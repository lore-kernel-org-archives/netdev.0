From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 6/24] make atomic_read() behave consistently on frv
Date: Tue, 14 Aug 2007 15:34:25 +1000
Message-ID: <46C13EE1.1000707@yahoo.com.au>
References: <20070811042943.GA13410@linux.vnet.ibm.com> <E1IKSHQ-0007hg-00@gondolin.me.apana.org.au> <20070813060302.GF13410@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, csnook@redhat.com,
	dhowells@redhat.com, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org, ak@suse.de,
	heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S941791AbXHNFe5@vger.kernel.org>
In-Reply-To: <20070813060302.GF13410@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul E. McKenney wrote:
> On Mon, Aug 13, 2007 at 01:15:52PM +0800, Herbert Xu wrote:
> 
>>Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
>>
>>>On Sat, Aug 11, 2007 at 08:54:46AM +0800, Herbert Xu wrote:
>>>
>>>>Chris Snook <csnook@redhat.com> wrote:
>>>>
>>>>>cpu_relax() contains a barrier, so it should do the right thing.  For 
>>>>>non-smp architectures, I'm concerned about interacting with interrupt 
>>>>>handlers.  Some drivers do use atomic_* operations.
>>>>
>>>>What problems with interrupt handlers? Access to int/long must
>>>>be atomic or we're in big trouble anyway.
>>>
>>>Reordering due to compiler optimizations.  CPU reordering does not
>>>affect interactions with interrupt handlers on a given CPU, but
>>>reordering due to compiler code-movement optimization does.  Since
>>>volatile can in some cases suppress code-movement optimizations,
>>>it can affect interactions with interrupt handlers.
>>
>>If such reordering matters, then you should use one of the
>>*mb macros or barrier() rather than relying on possibly
>>hidden volatile cast.
> 
> 
> If communicating among CPUs, sure.  However, when communicating between
> mainline and interrupt/NMI handlers on the same CPU, the barrier() and
> most expecially the *mb() macros are gross overkill.  So there really
> truly is a place for volatile -- not a large place, to be sure, but a
> place nonetheless.

I really would like all volatile users to go away and be replaced
by explicit barriers. It makes things nicer and more explicit... for
atomic_t type there probably aren't many optimisations that can be
made which volatile would disallow (in actual kernel code), but for
others (eg. bitops, maybe atomic ops in UP kernels), there would be.

Maybe it is the safe way to go, but it does obscure cases where there
is a real need for barriers.

Many atomic operations are allowed to be reordered between CPUs, so
I don't have a good idea for the rationale to order them within the
CPU (also loads and stores to long and ptr types are not ordered like
this, although we do consider those to be atomic operations too).

barrier() in a way is like enforcing sequential memory ordering
between process and interrupt context, wheras volatile is just
enforcing coherency of a single memory location (and as such is
cheaper).

What do you think of this crazy idea?

/* Enforce a compiler barrier for only operations to location X.
  * Call multiple times to provide an ordering between multiple
  * memory locations. Other memory operations can be assumed by
  * the compiler to remain unchanged and may be reordered
  */
#define order(x) asm volatile("" : "+m" (x))

-- 
SUSE Labs, Novell Inc.
