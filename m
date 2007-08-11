From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 1/24] make atomic_read() behave consistently on alpha
Date: Sat, 11 Aug 2007 02:38:40 +0200
Message-ID: <ef7e94b08a6515d33039d187e04db5db@kernel.crashing.org>
References: <E1IJPkg-0000x0-00@gondolin.me.apana.org.au> <442f95ba19f8622ce04cf0334f34be11@kernel.crashing.org> <20070811000029.GA12779@gondor.apana.org.au>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, heiko.carstens@de.ibm.com,
	horms@verge.net.au, linux-kernel@vger.kernel.org,
	csnook@redhat.com, rpjday@mindspring.com, netdev@vger.kernel.org,
	ak@suse.de, cfriesen@nortel.com, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org, zlynx@acm.org, schwidefsky@de.ibm.com,
	davem@davemloft.net, wensong@linux-vs.org, wjiang@resilience.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:46204 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757515AbXHKAjp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 20:39:45 -0400
In-Reply-To: <20070811000029.GA12779@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> That means GCC cannot compile Linux; it already optimises
>> some accesses to scalars to smaller accesses when it knows
>> it is allowed to.  Not often though, since it hardly ever
>> helps in the cost model it employs.
>
> Please give an example code snippet + gcc version + arch
> to back this up.

	unsigned char f(unsigned long *p)
	{
	        return *p & 1;
	}

with both

	powerpc64-linux-gcc (GCC) 4.3.0 20070731 (experimental)

and

	powerpc64-linux-gcc-4.2.0 (GCC) 4.2.0

(sorry, I don't have anything newer or older right now; if you
really care, I can test with those too)

generate (in 64-bit mode):

	.L.f:
		lbz 3,7(3)
		rldicl 3,3,0,63
		blr

and in 32-bit mode:

	f:
		stwu 1,-16(1)
		nop
		nop
		lbz 3,3(3)
		addi 1,1,16
		rlwinm 3,3,0,31,31
		blr

(the nops are because I use --with-cpu=970).


But perhaps you do not care for PowerPC, in which case:

	i686-linux-gcc (GCC) 4.2.0 20060410 (experimental)

(sorry for the old version, I don't build x86 compilers
all that often; also I don't have a 64-bit version right
now):

	f:
		pushl   %ebp
		movl    %esp, %ebp
		movl    8(%ebp), %eax
		popl    %ebp
		movzbl  (%eax), %eax
		andl    $1, %eax
		ret


If you want testing with any other versions, and/or for
any other target architecture, I can do that; it takes a
few minutes to build a compiler.

It is quite hard to build a testcase that reads more than
one part of the "long", since for small testcases the
compiler will almost always be smart enough to do one
bigger read instead; but it certainly isn't inconceivable,
and anyway the compiler would be fully in its right to do
reads non-atomically if not instructed otherwise.


Segher

