From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 2/3] sha512: reduce stack usage to safe number
Date: Sat, 14 Jan 2012 11:08:45 -0800
Message-ID: <CA+55aFziQSzTpfnxQ+k83Ui-65TDHu5GZFoJhhPoR504K_d7pw@mail.gmail.com>
References: <20120111003611.GA12257@gondor.apana.org.au> <20120112235514.GA5065@p183.telecom.by>
 <20120113070813.GA20068@gondor.apana.org.au> <1326450942.2272.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1326451301.2272.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1326452246.2272.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CACVxJT9FOYdRFZJ0WRe+5ty4t4XLwgHKWaoZBWB+Zjm-yCEMEA@mail.gmail.com>
 <1326458053.3826.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20120114182024.GA4207@p183.telecom.by> <20120114182737.GB4207@p183.telecom.by>
 <20120114184057.GA5516@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	ken@codelabs.ch, Steffen Klassert <steffen.klassert@secunet.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, security@kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20120114184057.GA5516@p183.telecom.by>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 14, 2012 at 10:40 AM, Alexey Dobriyan <adobriyan@gmail.com>=
 wrote:
>
> Line by line explanation:
> * BLEND_OP
> =A0array is "circular" now, all indexes have to be modulo 16.
> =A0Round number is positive, so remainder operation should be
> =A0without surprises.

Don't use "%" except on unsigned values. Even if it's positive, if
it's a signed number and the compiler doesn't *see* that it is
absolutely positive, division is nontrivial. Even when you divide by a
constant.

=46or example, "% 16" on an 'int' on x86-64 will generate

	movl	%edi, %edx
	sarl	$31, %edx
	shrl	$28, %edx
	leal	(%rdi,%rdx), %eax
	andl	$15, %eax
	subl	%edx, %eax

in order to get the signed case right. The fact that the end result is
correct for unsigned numbers is irrelevant: it's still stupid and
slow.

With an unsigned int, '% 16' will generate the obvious

	andl	$15, %eax

instead.

Quite frankly, stop using division in the first place. Dividing by
powers-of-two and expecting the compiler to fix things up is just
stupid, *exactly* because of issues like these: you either have to
think about it carefully, or the compiler may end up creating crap
code.

So just use "& 15" instead. That doesn't have these kinds of issues.
It is a *good* thing when the C code is close to the end result you
want to generate. It is *not* a good thing to write code that looks
nothing like the end result and just expect the compiler to do the
right thing. Even if the compiler does do the right thing, what was
the advantage?

                         Linus
