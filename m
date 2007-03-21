From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] tcp_cubic: use 32 bit math
Date: Wed, 21 Mar 2007 12:58:54 -0700
Message-ID: <20070321125854.465cf4f9@freekitty>
References: <20070307170731.2b4397e3@freekitty>
	<20070307.185539.48527371.davem@davemloft.net>
	<45EF7EB7.8040806@linux-foundation.org>
	<20070307.195135.74749102.davem@davemloft.net>
	<20070310114826.GB1608@1wt.eu>
	<20070312141156.08e88b0e@freekitty>
	<20070313205020.GA5418@1wt.eu>
	<20070321115419.483a655a@freekitty>
	<20070321191537.GA28914@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	rkuhn@e18.physik.tu-muenchen.de, andi@firstfloor.org,
	dada1@cosmosbay.com, jengelh@linux01.gwdg.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:51681 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964780AbXCUUDM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 16:03:12 -0400
In-Reply-To: <20070321191537.GA28914@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 21 Mar 2007 20:15:37 +0100
Willy Tarreau <w@1wt.eu> wrote:

> Hi Stephen,
> 
> On Wed, Mar 21, 2007 at 11:54:19AM -0700, Stephen Hemminger wrote:
> > On Tue, 13 Mar 2007 21:50:20 +0100
> > Willy Tarreau <w@1wt.eu> wrote:
> 
> [...] ( cut my boring part )
> 
> > > Here are the results classed by speed :
> > > 
> > > /* Sample output on a Pentium-M 600 MHz :
> > > 
> > > Function          clocks mean(us)  max(us)  std(us) Avg err size
> > > ncubic_tab0           79     0.66     7.20     1.04  0.613%  160
> > > ncubic_0div           84     0.70     7.64     1.57  4.521%  192
> > > ncubic_1div          178     1.48    16.27     1.81  0.443%  336
> > > ncubic_tab1          179     1.49    16.34     1.85  0.195%  320
> > > ncubic_ndiv3         263     2.18    24.04     3.59  0.250%  512
> > > ncubic_2div          270     2.24    24.70     2.77  0.187%  512
> > > ncubic32_1           359     2.98    32.81     3.59  0.238%  544
> > > ncubic_3div          361     2.99    33.08     3.79  0.170%  656
> > > ncubic32             364     3.02    33.29     3.51  0.247%  544
> > > ncubic               529     4.39    48.39     4.92  0.247%  720
> > > hcbrt                539     4.47    49.25     5.98  1.580%   96
> > > ocubic               732     4.93    61.83     7.22  0.274%  320
> > > acbrt                842     6.98    76.73     8.55  0.275%  192
> > > bictcp              1032     6.95    86.30     9.04  0.172%  768
> > > 
> 
> [...]
> 
> > The following version of div64_64 is faster because do_div already
> > optimized for the 32 bit case..
>

/* 64bit divisor, dividend and result. dynamic precision */
static uint64_t div64_64(uint64_t dividend, uint64_t divisor)
{
	uint32_t high, d;

	high = divisor >> 32;
	if (high) {
		unsigned int shift = fls(high);

		d = divisor >> shift;
		dividend >>= shift;
	} else
		d = divisor;

	do_div(dividend, d);

	return dividend;
}



> Cool, this is interesting because I first wanted to optimize it but did
> not find how to start with this. You seem to get very good results. BTW,
> you did not append your changes.
> 
> However, one thing I do not understand is why your avg error is about 1/3
> below the original one. Was there a precision bug in the original div_64_64
> or did you extend the values used in the test ?
> 
> Or perhaps you used -fast-math to build and the original cbrt() is less
> precise in this case ?

No, but I did use -mtune=pentiumm on the ULV
-- 
Stephen Hemminger <shemminger@linux-foundation.org>
