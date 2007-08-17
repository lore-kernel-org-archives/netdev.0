From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 15:38:07 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708171448440.3666@enigma.security.iitk.ac.in>
References: <E1ILCgh-00052A-00@gondolin.me.apana.org.au>
 <18117.4848.695269.72976@cargo.ozlabs.ibm.com>
 <alpine.LFD.0.999.0708162033400.30176@woody.linux-foundation.org>
 <200708171052.39477.ak@suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Mackerras <paulus@samba.org>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	Segher Boessenkool <segher@kernel.crashing.org>,
	heiko.carstens@de.ibm.com, horms@verge.net.au,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	rpjday@mindspring.com, netdev@vger.kernel.org, cfriesen@nortel.com,
	Andrew Morton <akpm@linux-foundation.org>,
	jesper.juhl@gmail.com, linux-arch@vger.kernel.org, zlynx@acm.org,
	clameter@sgi.com, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert.xu@redhat.com>, davem@davemloft.net,
	wensong@linux-vs.org, wjiang@resilience.com
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:41999 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755748AbXHQJzc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 05:55:32 -0400
In-Reply-To: <200708171052.39477.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 17 Aug 2007, Andi Kleen wrote:

> On Friday 17 August 2007 05:42, Linus Torvalds wrote:
> > On Fri, 17 Aug 2007, Paul Mackerras wrote:
> > > I'm really surprised it's as much as a few K.  I tried it on powerpc
> > > and it only saved 40 bytes (10 instructions) for a G5 config.
> >
> > One of the things that "volatile" generally screws up is a simple
> >
> > 	volatile int i;
> >
> > 	i++;
> 
> But for atomic_t people use atomic_inc() anyways which does this correctly.
> It shouldn't really matter for atomic_t.
> 
> I'm worrying a bit that the volatile atomic_t change caused subtle code 
> breakage like these delay read loops people here pointed out.

Umm, I followed most of the thread, but which breakage is this?

> Wouldn't it be safer to just re-add the volatile to atomic_read() 
> for 2.6.23? Or alternatively make it asm(), but volatile seems more
> proven.

The problem with volatile is not just trashy code generation (which also
definitely is a major problem), but definition holes, and implementation
inconsistencies. Making it asm() is not the only other alternative to
volatile either (read another reply to this mail), but considering most
of the thread has been about people not wanting even a
atomic_read_volatile() variant, making atomic_read() itself have volatile
semantics sounds ... strange :-)


PS: http://lkml.org/lkml/2007/8/15/407 was submitted a couple days back,
any word if you saw that?

I have another one for you:


[PATCH] i386, x86_64: __const_udelay() should not be marked inline

Because it can never get inlined in any callsite (each translation unit
is compiled separately for the kernel and so the implementation of
__const_udelay() would be invisible to all other callsites). In fact it
turns out, the correctness of callsites at arch/x86_64/kernel/crash.c:97
and arch/i386/kernel/crash.c:101 explicitly _depends_ upon it not being
inlined, and also it's an exported symbol (modules may want to call
mdelay() and udelay() that often becomes __const_udelay() after some
macro-ing in various headers). So let's not mark it as "inline" either.

Signed-off-by: Satyam Sharma <satyam@infradead.org>

---

 arch/i386/lib/delay.c   |    2 +-
 arch/x86_64/lib/delay.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/i386/lib/delay.c b/arch/i386/lib/delay.c
index f6edb11..0082c99 100644
--- a/arch/i386/lib/delay.c
+++ b/arch/i386/lib/delay.c
@@ -74,7 +74,7 @@ void __delay(unsigned long loops)
 	delay_fn(loops);
 }
 
-inline void __const_udelay(unsigned long xloops)
+void __const_udelay(unsigned long xloops)
 {
 	int d0;
 
diff --git a/arch/x86_64/lib/delay.c b/arch/x86_64/lib/delay.c
index 2dbebd3..d0cd9cd 100644
--- a/arch/x86_64/lib/delay.c
+++ b/arch/x86_64/lib/delay.c
@@ -38,7 +38,7 @@ void __delay(unsigned long loops)
 }
 EXPORT_SYMBOL(__delay);
 
-inline void __const_udelay(unsigned long xloops)
+void __const_udelay(unsigned long xloops)
 {
 	__delay(((xloops * HZ * cpu_data[raw_smp_processor_id()].loops_per_jiffy) >> 32) + 1);
 }
