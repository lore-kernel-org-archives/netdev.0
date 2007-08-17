From: Nick Piggin <piggin@cyberone.com.au>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 22:14:02 +1000
Message-ID: <46C5910A.6020904@cyberone.com.au>
References: <E1ILCgh-00052A-00@gondolin.me.apana.org.au> <46C32618.2080108@redhat.com> <20070815234021.GA28775@gondor.apana.org.au> <3694fb2e4ed1e4d9bf873c0d050c911e@kernel.crashing.org> <46C3B50E.7010702@yahoo.com.au> <194369f4c96ea0e24decf8f9197d5bad@kernel.crashing.org> <46C505B2.6030704@yahoo.com.au> <18117.4848.695269.72976@cargo.ozlabs.ibm.com> <alpine.LFD.0.999.0708162033400.30176@woody.linux-foundation.org> <alpine.LFD.0.999.0708171016160.3666@enigma.security.iitk.ac.in> <46C54D94.5080803@yahoo.com.au> <alpine.LFD.0.999.0708171358520.3666@enigma.security.iitk.ac.in> <46C56725.6000207@cyberone.com.au> <alpine.LFD.0.999.0708171505200.3666@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Mackerras <paulus@samba.org>,
	Segher Boessenkool <segher@kernel.crashing.org>,
	heiko.carstens@de.ibm.com, horms@verge.net.au,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	rpjday@mindspring.com, ak@suse.de, netdev@vger.kernel.org,
	cfriesen@nortel.com, Andrew Morton <akpm@linux-foundation.org>,
	jesper.juhl@gmail.com, linux-arch@vger.kernel.org, zlynx@acm.org,
	clameter@sgi.com, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert.xu@redhat.com>, davem@davemloft.net,
	wensong@linux-vs.org, wjiang@resilience.com
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.icp-qv1-irony3.iinet.net.au ([203.59.1.108]:4827 "EHLO
	webmail.icp-qv1-irony3.iinet.net.au" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751364AbXHQMOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 08:14:08 -0400
In-Reply-To: <alpine.LFD.0.999.0708171505200.3666@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Satyam Sharma wrote:

>
>On Fri, 17 Aug 2007, Nick Piggin wrote:
>
>>I think they would both be equally ugly,
>>
>
>You think both these are equivalent in terms of "looks":
>
>					|
>while (!atomic_read(&v)) {		|	while (!atomic_read_xxx(&v)) {
>	...				|		...
>	cpu_relax_no_barrier();		|		cpu_relax_no_barrier();
>	order_atomic(&v);		|	}
>}					|
>
>(where order_atomic() is an atomic_t
>specific wrapper as you mentioned below)
>
>?
>

I think the LHS is better if your atomic_read_xxx primitive is using the
crazy one-sided barrier, because the LHS code you immediately know what
barriers are happening, and with the RHS you have to look at the 
atomic_read_xxx
definition.

If your atomic_read_xxx implementation was more intuitive, then both are
pretty well equal. More lines != ugly code.


>>but the atomic_read_volatile
>>variant would be more prone to subtle bugs because of the weird
>>implementation.
>>
>
>What bugs?
>

You can't think for yourself? Your atomic_read_volatile contains a compiler
barrier to the atomic variable before the load. 2 such reads from different
locations look like this:

asm volatile("" : "+m" (v1));
atomic_read(&v1);
asm volatile("" : "+m" (v2));
atomic_read(&v2);

Which implies that the load of v1 can be reordered to occur after the load
of v2. Bet you didn't expect that?

>>Secondly, what sort of code would do such a thing?
>>
>
>See the nodemgr_host_thread() that does something similar, though not
>exactly same.
>

I'm sorry, all this waffling about made up code which might do this and
that is just a waste of time. Seriously, the thread is bloated enough
and never going to get anywhere with all this handwaving. If someone is
saving up all the really real and actually good arguments for why we
must have a volatile here, now is the time to use them.

>>and have barriers both before and after the memory operation,
>>
>
>How could that lead to bugs? (if you can point to existing code,
>but just some testcase / sample code would be fine as well).
>

See above.

>As I said, barrier() is too heavy-handed.
>

Typo. I meant: defined for a single memory location (ie. order(x)).

