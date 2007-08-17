From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Thu, 16 Aug 2007 20:50:30 -0700 (PDT)
Message-ID: <alpine.LFD.0.999.0708162045150.30176@woody.linux-foundation.org>
References: <E1ILCgh-00052A-00@gondolin.me.apana.org.au> <46C32618.2080108@redhat.com>
 <20070815234021.GA28775@gondor.apana.org.au> <3694fb2e4ed1e4d9bf873c0d050c911e@kernel.crashing.org>
 <46C3B50E.7010702@yahoo.com.au> <194369f4c96ea0e24decf8f9197d5bad@kernel.crashing.org>
 <46C505B2.6030704@yahoo.com.au> <18117.4848.695269.72976@cargo.ozlabs.ibm.com>
 <46C516BA.60700@yahoo.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Paul Mackerras <paulus@samba.org>,
	Segher Boessenkool <segher@kernel.crashing.org>,
	heiko.carstens@de.ibm.com, horms@verge.net.au,
	linux-kernel@vger.kernel.org, rpjday@mindspring.com, ak@suse.de,
	netdev@vger.kernel.org, cfriesen@nortel.com,
	akpm@linux-foundation.org, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org, zlynx@acm.org, satyam@infradead.org,
	clameter@sgi.com, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert.xu@redhat.com>, davem@davemloft.net,
	wensong@linux-vs.org, wjiang@resilience.com
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60646 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753352AbXHQDvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 23:51:31 -0400
In-Reply-To: <46C516BA.60700@yahoo.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 17 Aug 2007, Nick Piggin wrote:
> 
> I'm surprised too. Numbers were from the "...use asm() like the other
> atomic operations already do" thread. According to them,
> 
>   text    data     bss     dec     hex filename
> 3434150  249176  176128 3859454  3ae3fe atomic_normal/vmlinux
> 3436203  249176  176128 3861507  3aec03 atomic_volatile/vmlinux
> 
> The first one is a stock kenel, the second is with atomic_read/set
> cast to volatile. gcc-4.1 -- maybe if you have an earlier gcc it
> won't optimise as much?

No, see my earlier reply. "volatile" really *is* an incredible piece of 
crap.

Just try it yourself:

	volatile int i;
	int j;

	int testme(void)
	{
	        return i <= 1;
	}

	int testme2(void)
	{
	        return j <= 1;
	}

and compile with all the optimizations you can.

I get:

	testme:
	        movl    i(%rip), %eax
	        subl    $1, %eax
	        setle   %al
	        movzbl  %al, %eax
	        ret

vs

	testme2:
	        xorl    %eax, %eax
	        cmpl    $1, j(%rip)
	        setle   %al
	        ret

(now, whether that "xorl + setle" is better than "setle + movzbl", I don't 
really know - maybe it is. But that's not thepoint. The point is the 
difference between

                movl    i(%rip), %eax
                subl    $1, %eax

and

                cmpl    $1, j(%rip)

and imagine this being done for *every* single volatile access.

Just do a 

	git grep atomic_read

to see how atomics are actually used. A lot of them are exactly the above 
kind of "compare against a value".

			Linus
