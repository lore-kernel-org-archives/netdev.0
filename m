From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH] i386: Fix a couple busy loops in
 mach_wakecpu.h:wait_for_init_deassert()
Date: Fri, 24 Aug 2007 19:00:13 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708241812110.20322@enigma.security.iitk.ac.in>
References: <46C2350A.1010807@redhat.com> <20070815081841.GA16551@osiris.boeblingen.de.ibm.com>
 <alpine.LFD.0.999.0708160606580.24380@enigma.security.iitk.ac.in>
 <200708241259.33659.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Chris Snook <csnook@redhat.com>, clameter@sgi.com,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	ak@suse.de, davem@davemloft.net, schwidefsky@de.ibm.com,
	wensong@linux-vs.org, horms@verge.net.au, wjiang@resilience.com,
	cfriesen@nortel.com, zlynx@acm.org, rpjday@mindspring.com,
	jesper.juhl@gmail.com, segher@kernel.crashing.org,
	Nick Piggin <nickpiggin@yahoo.com.au>
To: Denys Vlasenko <vda.linux@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:39263 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758249AbXHXNRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 09:17:42 -0400
In-Reply-To: <200708241259.33659.vda.linux@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Denys,


On Fri, 24 Aug 2007, Denys Vlasenko wrote:

> On Thursday 16 August 2007 01:39, Satyam Sharma wrote:
> >
> >  static inline void wait_for_init_deassert(atomic_t *deassert)
> >  {
> > -	while (!atomic_read(deassert));
> > +	while (!atomic_read(deassert))
> > +		cpu_relax();
> >  	return;
> >  }
> 
> For less-than-briliant people like me, it's totally non-obvious that
> cpu_relax() is needed for correctness here, not just to make P4 happy.

This thread has been round-and-round with exactly the same discussions
:-) I had proposed few such variants to make a compiler barrier implicit
in atomic_{read,set} myself, but frankly, at least personally speaking
(now that I know better), I'm not so much in favour of implicit barriers
(compiler, memory or both) in atomic_{read,set}.

This might sound like an about-turn if you read my own postings to Nick
Piggin from a week back, but I do agree with most his opinions on the
matter now -- separation of barriers from atomic ops is actually good,
beneficial to certain code that knows what it's doing, explicit usage
of barriers stands out more clearly (most people here who deal with it
do know cpu_relax() is an explicit compiler barrier) compared to an
implicit usage in an atomic_read() or such variant ...


> IOW: "atomic_read" name quite unambiguously means "I will read
> this variable from main memory". Which is not true and creates
> potential for confusion and bugs.

I'd have to disagree here -- atomic ops are all about _atomicity_ of
memory accesses, not _making_ them happen (or visible to other CPUs)
_then and there_ itself. The latter are the job of barriers.

The behaviour (and expectations) are quite comprehensively covered in
atomic_ops.txt -- let alone atomic_{read,set}, even atomic_{inc,dec}
are permitted by archs' implementations to _not_ have any memory
barriers, for that matter. [It is unrelated that on x86 making them
SMP-safe requires the use of the LOCK prefix that also happens to be
an implicit memory barrier.]

An argument was also made about consistency of atomic_{read,set} w.r.t.
the other atomic ops -- but clearly, they are all already consistent!
All of them are atomic :-) The fact that atomic_{read,set} do _not_
require any inline asm or LOCK prefix whereas the others do, has to do
with the fact that unlike all others, atomic_{read,set} are not RMW ops
and hence guaranteed to be atomic just as they are in plain & simple C.

But if people do seem to have a mixed / confused notion of atomicity
and barriers, and if there's consensus, then as I'd said earlier, I
have no issues in going with the consensus (eg. having API variants).
Linus would be more difficult to convince, however, I suspect :-)


Satyam
