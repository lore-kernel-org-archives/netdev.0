From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Thu, 16 Aug 2007 06:53:45 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708160649590.24380@enigma.security.iitk.ac.in>
References: <20070809131423.GA9927@shell.boston.redhat.com>
 <Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com>
 <alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in>
 <46C2D6F3.3070707@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in>
 <9350e9fab505c92af8d5e1f3441d6ad2@kernel.crashing.org>
 <alpine.LFD.0.999.0708160102550.16414@enigma.security.iitk.ac.in>
 <d36ec7799cfb43557770951c1cd57355@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Christoph Lameter <clameter@sgi.com>, heiko.carstens@de.ibm.com,
	horms@verge.net.au, Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, ak@suse.de, cfriesen@nortel.com,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, zlynx@acm.org,
	schwidefsky@de.ibm.com, Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	Linus Torvalds <torvalds@linux-foundation.org>,
	wensong@linux-vs.org, wjiang@resilience.com
To: Segher Boessenkool <segher@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:50344 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762600AbXHPBLO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 21:11:14 -0400
In-Reply-To: <d36ec7799cfb43557770951c1cd57355@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, 15 Aug 2007, Segher Boessenkool wrote:

> [...]
> > BTW:
> > 
> > #define atomic_read(a)	(*(volatile int *)&(a))
> > #define atomic_set(a,i)	(*(volatile int *)&(a) = (i))
> > 
> > int a;
> > 
> > void func(void)
> > {
> > 	int b;
> > 
> > 	b = atomic_read(a);
> > 	atomic_set(a, 20);
> > 	b = atomic_read(a);
> > }
> > 
> > gives:
> > 
> > func:
> > 	pushl	%ebp
> > 	movl	a, %eax
> > 	movl	%esp, %ebp
> > 	movl	$20, a
> > 	movl	a, %eax
> > 	popl	%ebp
> > 	ret
> > 
> > so the first atomic_read() wasn't optimized away.
> 
> Of course.  It is executed by the abstract machine, so
> it will be executed by the actual machine.  On the other
> hand, try
> 
> 	b = 0;
> 	if (b)
> 		b = atomic_read(a);
> 
> or similar.

Yup, obviously. Volatile accesses (or any access to volatile objects),
or even "__volatile__ asms" (which gcc normally promises never to elid)
can always be optimized for cases such as these where the compiler can
trivially determine that the code in question is not reachable.
