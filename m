From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Fri, 24 Aug 2007 13:19:04 +0100
Message-ID: <200708241319.05760.vda.linux@googlemail.com>
References: <20070815234021.GA28775@gondor.apana.org.au> <alpine.LFD.0.999.0708180709060.3666@enigma.security.iitk.ac.in> <alpine.LFD.0.999.0708172110400.30176@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Satyam Sharma <satyam@infradead.org>,
	Christoph Lameter <clameter@sgi.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	Paul Mackerras <paulus@samba.org>,
	Segher Boessenkool <segher@kernel.crashing.org>,
	heiko.carstens@de.ibm.com, horms@verge.net.au,
	linux-kernel@vger.kernel.org, rpjday@mindspring.com, ak@suse.de,
	netdev@vger.kernel.org, cfriesen@nortel.com,
	akpm@linux-foundation.org, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org, zlynx@acm.org, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>, davem@davemloft.net,
	wensong@linux-vs.org, wjiang@resilience.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.180]:6353 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757142AbXHXMTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 08:19:53 -0400
Received: by el-out-1112.google.com with SMTP id j27so166873elf
        for <netdev@vger.kernel.org>; Fri, 24 Aug 2007 05:19:52 -0700 (PDT)
In-Reply-To: <alpine.LFD.0.999.0708172110400.30176@woody.linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 18 August 2007 05:13, Linus Torvalds wrote:
> On Sat, 18 Aug 2007, Satyam Sharma wrote:
> > No code does (or would do, or should do):
> >
> > 	x.counter++;
> >
> > on an "atomic_t x;" anyway.
>
> That's just an example of a general problem.
>
> No, you don't use "x.counter++". But you *do* use
>
> 	if (atomic_read(&x) <= 1)
>
> and loading into a register is stupid and pointless, when you could just
> do it as a regular memory-operand to the cmp instruction.

It doesn't mean that (volatile int*) cast is bad, it means that current gcc
is bad (or "not good enough"). IOW: instead of avoiding volatile cast,
it's better to fix the compiler.

> And as far as the compiler is concerned, the problem is the 100% same:
> combining operations with the volatile memop.
>
> The fact is, a compiler that thinks that
>
> 	movl mem,reg
> 	cmpl $val,reg
>
> is any better than
>
> 	cmpl $val,mem
>
> is just not a very good compiler.

Linus, in all honesty gcc has many more cases of suboptimal code,
case of "volatile" is just one of many.

Off the top of my head:

http://gcc.gnu.org/bugzilla/show_bug.cgi?id=28417

unsigned v;
void f(unsigned A) { v = ((unsigned long long)A) * 365384439 >> (27+32); }

gcc-4.1.1 -S -Os -fomit-frame-pointer t.c

f:
        movl    $365384439, %eax
        mull    4(%esp)
        movl    %edx, %eax <===== ?
        shrl    $27, %eax
        movl    %eax, v
        ret

Why is it moving %edx to %eax?

gcc-4.2.1 -S -Os -fomit-frame-pointer t.c

f:
        movl    $365384439, %eax
        mull    4(%esp)
        movl    %edx, %eax <===== ?
        xorl    %edx, %edx <===== ??!
        shrl    $27, %eax
        movl    %eax, v
        ret

Progress... Now we also zero out %edx afterwards for no apparent reason.
--
vda
