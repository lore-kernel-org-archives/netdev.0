From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Wed, 15 Aug 2007 18:01:10 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in>
References: <20070809131423.GA9927@shell.boston.redhat.com>
 <Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com>
 <alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in>
 <46C2D6F3.3070707@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Christoph Lameter <clameter@sgi.com>,
	Chris Snook <csnook@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	ak@suse.de, heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:36735 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752829AbXHOMTA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 08:19:00 -0400
In-Reply-To: <46C2D6F3.3070707@s5r6.in-berlin.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, 15 Aug 2007, Stefan Richter wrote:

> Satyam Sharma wrote:
> > [ BTW, why do we want the compiler to not optimize atomic_read()'s in
> >   the first place? Atomic ops guarantee atomicity, which has nothing
> >   to do with "volatility" -- users that expect "volatility" from
> >   atomic ops are the ones who must be fixed instead, IMHO. ]
> 
> LDD3 says on page 125:  "The following operations are defined for the
> type [atomic_t] and are guaranteed to be atomic with respect to all
> processors of an SMP computer."
> 
> Doesn't "atomic WRT all processors" require volatility?

No, it definitely doesn't. Why should it?

"Atomic w.r.t. all processors" is just your normal, simple "atomicity"
for SMP systems (ensure that that object is modified / set / replaced
in main memory atomically) and has nothing to do with "volatile"
behaviour.

"Volatile behaviour" itself isn't consistently defined (at least
definitely not consistently implemented in various gcc versions across
platforms), but it is /expected/ to mean something like: "ensure that
every such access actually goes all the way to memory, and is not
re-ordered w.r.t. to other accesses, as far as the compiler can take
care of these". The last "as far as compiler can take care" disclaimer
comes about due to CPUs doing their own re-ordering nowadays.

For example (say on i386):

(A)
$ cat tp1.c
int a;

void func(void)
{
	a = 10;
	a = 20;
}
$ gcc -Os -S tp1.c
$ cat tp1.s
...
movl    $20, a
...

(B)
$ cat tp2.c
volatile int a;

void func(void)
{
	a = 10;
	a = 20;
}
$ gcc -Os -S tp2.c
$ cat tp2.s
...
movl    $10, a
movl    $20, a
...

(C)
$ cat tp3.c
int a;

void func(void)
{
	*(volatile int *)&a = 10;
	*(volatile int *)&a = 20;
}
$ gcc -Os -S tp3.c
$ cat tp3.s
...
movl    $10, a
movl    $20, a
...

In (A) the compiler optimized "a = 10;" away, but the actual store
of the final value "20" to "a" was still "atomic". (B) and (C) also
exhibit "volatile" behaviour apart from the "atomicity".

But as others replied, it seems some callers out there depend upon
atomic ops exhibiting "volatile" behaviour as well, so that answers
my initial question, actually. I haven't looked at the code Paul
pointed me at, but I wonder if that "forget(x)" macro would help
those cases. I'd wish to avoid the "volatile" primitive, personally.


Satyam
