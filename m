From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Thu, 16 Aug 2007 06:48:53 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708160637510.24380@enigma.security.iitk.ac.in>
References: <20070815145207.GA23106@gondor.apana.org.au> <46C3253F.5090707@s5r6.in-berlin.de>
 <20070815162722.GD9645@linux.vnet.ibm.com> <d4406222873856f472b9173a14a19aa2@kernel.crashing.org>
 <20070815185724.GH9645@linux.vnet.ibm.com>
 <alpine.LFD.0.999.0708160118330.16414@enigma.security.iitk.ac.in>
 <2d2eeab6276cab2e6cc5830d36a43b98@kernel.crashing.org>
 <alpine.LFD.0.999.0708160338520.22701@enigma.security.iitk.ac.in>
 <20070816003226.GA29491@gondor.apana.org.au>
 <alpine.LFD.0.999.0708160621260.24380@enigma.security.iitk.ac.in>
 <20070816005156.GA29698@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Segher Boessenkool <segher@kernel.crashing.org>,
	horms@verge.net.au, Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, ak@suse.de,
	netdev@vger.kernel.org, cfriesen@nortel.com,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, zlynx@acm.org,
	clameter@sgi.com, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>, davem@davemloft.net,
	Linus Torvalds <torvalds@linux-foundation.org>,
	wensong@linux-vs.org, wjiang@resilience.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S937641AbXHPBGg@vger.kernel.org>
In-Reply-To: <20070816005156.GA29698@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Herbert,


On Thu, 16 Aug 2007, Herbert Xu wrote:

> On Thu, Aug 16, 2007 at 06:28:42AM +0530, Satyam Sharma wrote:
> >
> > > The udelay itself certainly should have some form of cpu_relax in it.
> > 
> > Yes, a form of barrier() must be present in mdelay() or udelay() itself
> > as you say, having it in __const_udelay() is *not* enough (superflous
> > actually, considering it is already a separate translation unit and
> > invisible to the compiler).
> 
> As long as __const_udelay does something which has the same
> effect as barrier it is enough even if it's in the same unit.

Only if __const_udelay() is inlined. But as I said, __const_udelay()
-- although marked "inline" -- will never be inlined anywhere in the
kernel in reality. It's an exported symbol, and never inlined from
modules. Even from built-in targets, the definition of __const_udelay
is invisible when gcc is compiling the compilation units of those
callsites. The compiler has no idea that that function has barriers
or not, so we're saved here _only_ by the lucky fact that
__const_udelay() is in a different compilation unit.


> As a matter of fact it does on i386 where __delay either uses
> rep_nop or asm/volatile.

__delay() can be either delay_tsc() or delay_loop() on i386.

delay_tsc() uses the rep_nop() there for it's own little busy
loop, actually. But for a call site that inlines __const_udelay()
-- if it were ever moved to a .h file and marked inline -- the
call to __delay() will _still_ be across compilation units. So,
again for this case, it does not matter if the callee function
has compiler barriers or not (it would've been a different story
if we were discussing real/CPU barriers, I think), what saves us
here is just the fact that a call is made to a function from a
different compilation unit, which is invisible to the compiler
when compiling the callsite, and hence acting as the compiler
barrier.

Regarding delay_loop(), it uses "volatile" for the "asm" which
has quite different semantics from the C language "volatile"
type-qualifier keyword and does not imply any compiler barrier
at all.


Satyam
