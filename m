From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] div64_64 support
Date: Tue, 6 Mar 2007 14:34:04 +0100
Message-ID: <20070306133404.GA864@one.firstfloor.org>
References: <20070223170527.4ca695b2@freekitty> <Pine.LNX.4.61.0702262108010.23355@yvahk01.tjqt.qr> <20070226143127.5c74bec9@freekitty> <p73slcnawh3.fsf@bingen.suse.de> <20070305155714.3abe1b5e@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Jan Engelhardt <jengelh@linux01.gwdg.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:44883 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933264AbXCFNeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 08:34:08 -0500
Content-Disposition: inline
In-Reply-To: <20070305155714.3abe1b5e@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 05, 2007 at 03:57:14PM -0800, Stephen Hemminger wrote:
> On 03 Mar 2007 03:31:52 +0100
> Andi Kleen <andi@firstfloor.org> wrote:
> 
> > Stephen Hemminger <shemminger@linux-foundation.org> writes:
> > 
> > > Here is another way to handle the 64 bit divide case.
> > > It allows full 64 bit divide by adding the support routine
> > > GCC needs.
> > 
> > Not supplying that was intentional by Linus so that people
> > think twice (or more often) before they using such expensive
> > operations. A plain / looks too innocent.
> > 
> > Is it really needed by CUBIC anyways?  It uses it for getting
> > the cubic root, but the algorithm recommended by Hacker's Delight
> > (great book) doesn't use any divisions at all. Probably better 
> > to use a better algorithm without divisions.
> > 
> 
> I tried the code from Hacker's Delight.
> It is cool, but performance is CPU (and data) dependent:

I did too. My experiences were mixed: on 32bit it was slower,
on 64bit faster on average.  Strangely the 32bit version ran
faster again without -fomit-frame-pointer, so it's likely
some funny interaction with 32bit long long code generation.
The difference is never more than 100 cycles so it shouldn't
be a big issue either way.

For some input arguments (<1% in my testing)
it also gave an answer 1 off from the existing code, 
but I don't think that's a problem.

But more importantly during testing I found that the cubic
code gives a division by zero for input arguments >2^43. If you
have a system with >16TB of memory this could actually be a remotely
exploitable bug :)

I still think it's a good idea to switch to the new function,
especially since it's shorter code.

Here's the patch. Note I didn't verify it with real large window
TCP operations; only unit testing.

-Andi

Use Hacker's delight cube root algorithm in cubic TCP

Shorter code and fixes a theoretically remote exploitable bug.

Signed-off-by: Andi Kleen <ak@suse.de>


Index: linux-2.6.21-rc1-net/net/ipv4/tcp_cubic.c
===================================================================
--- linux-2.6.21-rc1-net.orig/net/ipv4/tcp_cubic.c
+++ linux-2.6.21-rc1-net/net/ipv4/tcp_cubic.c
@@ -93,51 +93,24 @@ static void bictcp_init(struct sock *sk)
 		tcp_sk(sk)->snd_ssthresh = initial_ssthresh;
 }
 
-/* 64bit divisor, dividend and result. dynamic precision */
-static inline u_int64_t div64_64(u_int64_t dividend, u_int64_t divisor)
+static u32 cubic_root(u64 x)
 {
-	u_int32_t d = divisor;
-
-	if (divisor > 0xffffffffULL) {
-		unsigned int shift = fls(divisor >> 32);
-
-		d = divisor >> shift;
-		dividend >>= shift;
-	}
-
-	/* avoid 64 bit division if possible */
-	if (dividend >> 32)
-		do_div(dividend, d);
-	else
-		dividend = (uint32_t) dividend / d;
-
-	return dividend;
-}
-
-/*
- * calculate the cubic root of x using Newton-Raphson
- */
-static u32 cubic_root(u64 a)
-{
-	u32 x, x1;
-
-	/* Initial estimate is based on:
-	 * cbrt(x) = exp(log(x) / 3)
-	 */
-	x = 1u << (fls64(a)/3);
-
-	/*
-	 * Iteration based on:
-	 *                         2
-	 * x    = ( 2 * x  +  a / x  ) / 3
-	 *  k+1          k         k
-	 */
-	do {
-		x1 = x;
-		x = (2 * x + (uint32_t) div64_64(a, x*x)) / 3;
-	} while (abs(x1 - x) > 1);
-
-	return x;
+	int s;
+	u32 y;
+	u64 b;
+	u64 bs;
+
+	y = 0;
+	for (s = 63; s >= 0; s -= 3) {
+		y = 2 * y;
+		b = 3 * y * (y+1) + 1;
+		bs = b << s;
+		if (x >= bs && (b == (bs>>s))) {  /* avoid overflow */
+			x -= bs;
+			y++;
+		}
+	}
+	return y;
 }
 
 /*
