From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] tcp_cubic: use 32 bit math
Date: Wed, 21 Mar 2007 11:54:19 -0700
Message-ID: <20070321115419.483a655a@freekitty>
References: <20070307170731.2b4397e3@freekitty>
	<20070307.185539.48527371.davem@davemloft.net>
	<45EF7EB7.8040806@linux-foundation.org>
	<20070307.195135.74749102.davem@davemloft.net>
	<20070310114826.GB1608@1wt.eu>
	<20070312141156.08e88b0e@freekitty>
	<20070313205020.GA5418@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	rkuhn@e18.physik.tu-muenchen.de, andi@firstfloor.org,
	dada1@cosmosbay.com, jengelh@linux01.gwdg.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:49532 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933683AbXCUS7Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 14:59:24 -0400
In-Reply-To: <20070313205020.GA5418@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Mar 2007 21:50:20 +0100
Willy Tarreau <w@1wt.eu> wrote:

> Hi Stephen,
> 
> On Mon, Mar 12, 2007 at 02:11:56PM -0700, Stephen Hemminger wrote:
> > > Oh BTW, I have a newer version with a first approximation of the
> > > cbrt() before the div64_64, which allows us to reduce from 3 div64
> > > to only 2 div64. This results in a version which is twice as fast
> > > as the initial one (ncubic), but with slightly less accuracy (0.286%
> > > compared to 0.247). But I see that other functions such as hcbrt()
> > > had a 1.5% avg error, so I think this is not dramatic.
> > 
> > Ignore my hcbrt() it was a less accurate version of andi's stuff.
> 
> OK.
> 
> > > Also, I managed to remove all other divides, to be kind with CPUs
> > > having a slow divide instruction or no divide at all. Since we compute
> > > on limited range (22 bits), we can multiply then shift right. It shows
> > > me even slightly better time on pentium-m and athlon, with a slightly
> > > higher avg error (0.297% compared to 0.286%), and slightly smaller
> > > code.
> > 
> > What does the code look like?
> 
> Well, I have cleaned it a little bit, there were more comments and ifdefs
> than code ! I've appended it to the end of this mail.
> 
> I have changed it a bit, because I noticed that integer divide precision
> was so coarse that there were other possibilities to play with the bits.
> 
> I have experimented with combinations of several methods :
>   - replace integer divides with multiplies/shifts where possible.
> 
>   - compensation for divide imprecisions by adding/removing small
>     values bofore/after them. Often, the integer result of 1/(x*(x-1))
>     is closer to (float)1/(float)x^2 than 1/(x*x). This is because
>     the divide always truncates the result.
> 
>   - use direct result lookup for small values. Small inputs give small
>     outputs which have very few moving bits. Many different values fit
>     in a 32bit integer, so we use a shift offset to lookup the value.
>     I used this in an fls function I wrote a while ago, that I should
>     also post because it is up to twice as fast as the kernel's.
>     Sometimes it seems faster to lookup in from memory, sometimes it
>     is faster from an immediate value. Maybe more visible differences
>     would show up on RISC CPUs where loading 32 bits immediate needs
>     two instructions. I don't know yet, I've not tested on my sparc
>     yet.
> 
>   - use small lookup tables (64 bytes) with 6 bits inputs and at least
>     as many on output. We only lookup the 6 MSB and return the 2-3 MSB
>     of the result.
> 
>   - iterative search and manual refinment of the lookup tables for best
>     accuracy. The avg error rate can easily be halved this way.
> 
> I have duplicated tried several functions with 0, 1, 2 and 3 divides.
> Several of them offer better accuracy over what we currently have, in
> less cycles. Others offer faster results (up to 5 times) with slightly
> less accuracy.
> 
> There is one function which is not to be used, but is just here for
> comparison (ncubic_0div). It does no divide but has awful avg error.
> 
> But one which is interesting is the ncubic_tab0. It does not use any
> divide at all, even not any div64. It shows a 0.6% avg error, which I'm
> not sure is enough or not. It is 6.7 times faster than initial ncubic()
> with less accuracy, and 4 times smaller. I suspect that it can differ
> more on architectures which have no divide instruction.
> 
> Is 0.6% avg error rate is too much, ncubic_tab1() uses one single div64
> and is twice slower (still nearly 3 times faster than ncubic). It show
> 0.195% avg error, which is better than initial ncubic. I think that it
> is a good tradeoff.
> 
> If best accuracy is an absolute requirement, then I have a variation of
> ncubic (ncubic_3div) which does 0.17% in 2/3 of the time (compared to
> 0.247%), and which is slightly smaller.
> 
> I have also added a "size" column, indicating approximative function
> size, provided that the compiler does not reorder the code. On gcc 3.4,
> it's OK, but 4.1 returns garbage. That does not matter, it's just a
> rough estimate anyway.
> 
> Here are the results classed by speed :
> 
> /* Sample output on a Pentium-M 600 MHz :
> 
> Function          clocks mean(us)  max(us)  std(us) Avg err size
> ncubic_tab0           79     0.66     7.20     1.04  0.613%  160
> ncubic_0div           84     0.70     7.64     1.57  4.521%  192
> ncubic_1div          178     1.48    16.27     1.81  0.443%  336
> ncubic_tab1          179     1.49    16.34     1.85  0.195%  320
> ncubic_ndiv3         263     2.18    24.04     3.59  0.250%  512
> ncubic_2div          270     2.24    24.70     2.77  0.187%  512
> ncubic32_1           359     2.98    32.81     3.59  0.238%  544
> ncubic_3div          361     2.99    33.08     3.79  0.170%  656
> ncubic32             364     3.02    33.29     3.51  0.247%  544
> ncubic               529     4.39    48.39     4.92  0.247%  720
> hcbrt                539     4.47    49.25     5.98  1.580%   96
> ocubic               732     4.93    61.83     7.22  0.274%  320
> acbrt                842     6.98    76.73     8.55  0.275%  192
> bictcp              1032     6.95    86.30     9.04  0.172%  768
> 
> And now by avg error :
> 
> ncubic_3div          361     2.99    33.08     3.79  0.170%  656
> bictcp              1032     6.95    86.30     9.04  0.172%  768
> ncubic_2div          270     2.24    24.70     2.77  0.187%  512
> ncubic_tab1          179     1.49    16.34     1.85  0.195%  320
> ncubic32_1           359     2.98    32.81     3.59  0.238%  544
> ncubic               529     4.39    48.39     4.92  0.247%  720
> ncubic32             364     3.02    33.29     3.51  0.247%  544
> ncubic_ndiv3         263     2.18    24.04     3.59  0.250%  512
> ocubic               732     4.93    61.83     7.22  0.274%  320
> acbrt                842     6.98    76.73     8.55  0.275%  192
> ncubic_1div          178     1.48    16.27     1.81  0.443%  336
> ncubic_tab0           79     0.66     7.20     1.04  0.613%  160
> hcbrt                539     4.47    49.25     5.98  1.580%   96
> ncubic_0div           84     0.70     7.64     1.57  4.521%  192
> 
> 
> And here comes the code. I have tried to document it a bit, as much
> as can be done on experimentation code. It is often easier to use
> a pencil and paper to understand how the bits move.
> 
> Regards,
> Willy
> 

The following version of div64_64 is faster because do_div already
optimized for the 32 bit case..

I get the following results on ULV Core Solo (ie slow current processor)
and the following on 64bit Core Duo. ncubic_tab1 seems like
the best (no additional error and about as fast)

ULV Core Solo

Function          clocks mean(us)  max(us)  std(us) Avg err size
ncubic_tab0          192    11.24    45.10    15.28  0.450% -2262
ncubic_0div          201    11.77    47.23    27.40  3.357% -2404
ncubic_1div          324    19.02    76.32    25.82  0.189% -2567
ncubic_tab1          326    19.13    76.73    23.71  0.043% -2059
ncubic_2div          456    26.72   108.92   493.16  0.028% -2790
ncubic_ndiv3         463    27.15   133.37  1889.39  0.104% -3344
ncubic32             549    32.18   130.59   508.97  0.041% -3794
ncubic32_1           574    33.66   138.32   548.48  0.029% -3604
ncubic_3div          581    34.04   140.24   608.55  0.018% -3050
ncubic               733    42.92   173.35   523.19  0.041%  299
ocubic              1046    61.25   283.68  3305.65  0.027% -2232
acbrt               1149    67.32   284.91  1941.55  0.029%  168
bictcp              1663    97.41   394.29   604.86  0.017%  628

Core 2 Duo

Function          clocks mean(us)  max(us)  std(us) Avg err size
ncubic_0div           74     0.03     1.60     0.07  3.357% -2101
ncubic_tab0           74     0.03     1.60     0.04  0.450% -2029
ncubic_1div          142     0.07     3.11     1.05  0.189% -2195
ncubic_tab1          144     0.07     3.18     1.02  0.043% -1638
ncubic_2div          216     0.10     4.74     1.07  0.028% -2326
ncubic_ndiv3         219     0.10     4.76     1.04  0.104% -2709
ncubic32             269     0.13     5.87     1.13  0.041% -1500
ncubic32_1           272     0.13     5.92     1.10  0.029% -2881
ncubic               273     0.13     5.96     1.13  0.041% -1763
ncubic_3div          290     0.14     6.32     1.01  0.018% -2499
acbrt                430     0.20     9.42     1.18  0.029%   77
ocubic               444     0.21     9.82     1.82  0.027% -1924
bictcp               549     0.26    12.06     1.68  0.017%  236



-- 
Stephen Hemminger <shemminger@linux-foundation.org>
