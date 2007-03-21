From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] tcp_cubic: use 32 bit math
Date: Wed, 21 Mar 2007 20:15:37 +0100
Message-ID: <20070321191537.GA28914@1wt.eu>
References: <20070307170731.2b4397e3@freekitty> <20070307.185539.48527371.davem@davemloft.net> <45EF7EB7.8040806@linux-foundation.org> <20070307.195135.74749102.davem@davemloft.net> <20070310114826.GB1608@1wt.eu> <20070312141156.08e88b0e@freekitty> <20070313205020.GA5418@1wt.eu> <20070321115419.483a655a@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	rkuhn@e18.physik.tu-muenchen.de, andi@firstfloor.org,
	dada1@cosmosbay.com, jengelh@linux01.gwdg.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1294 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933804AbXCUTUs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 15:20:48 -0400
Content-Disposition: inline
In-Reply-To: <20070321115419.483a655a@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

On Wed, Mar 21, 2007 at 11:54:19AM -0700, Stephen Hemminger wrote:
> On Tue, 13 Mar 2007 21:50:20 +0100
> Willy Tarreau <w@1wt.eu> wrote:

[...] ( cut my boring part )

> > Here are the results classed by speed :
> > 
> > /* Sample output on a Pentium-M 600 MHz :
> > 
> > Function          clocks mean(us)  max(us)  std(us) Avg err size
> > ncubic_tab0           79     0.66     7.20     1.04  0.613%  160
> > ncubic_0div           84     0.70     7.64     1.57  4.521%  192
> > ncubic_1div          178     1.48    16.27     1.81  0.443%  336
> > ncubic_tab1          179     1.49    16.34     1.85  0.195%  320
> > ncubic_ndiv3         263     2.18    24.04     3.59  0.250%  512
> > ncubic_2div          270     2.24    24.70     2.77  0.187%  512
> > ncubic32_1           359     2.98    32.81     3.59  0.238%  544
> > ncubic_3div          361     2.99    33.08     3.79  0.170%  656
> > ncubic32             364     3.02    33.29     3.51  0.247%  544
> > ncubic               529     4.39    48.39     4.92  0.247%  720
> > hcbrt                539     4.47    49.25     5.98  1.580%   96
> > ocubic               732     4.93    61.83     7.22  0.274%  320
> > acbrt                842     6.98    76.73     8.55  0.275%  192
> > bictcp              1032     6.95    86.30     9.04  0.172%  768
> > 

[...]

> The following version of div64_64 is faster because do_div already
> optimized for the 32 bit case..

Cool, this is interesting because I first wanted to optimize it but did
not find how to start with this. You seem to get very good results. BTW,
you did not append your changes.

However, one thing I do not understand is why your avg error is about 1/3
below the original one. Was there a precision bug in the original div_64_64
or did you extend the values used in the test ?

Or perhaps you used -fast-math to build and the original cbrt() is less
precise in this case ?

> I get the following results on ULV Core Solo (ie slow current processor)
> and the following on 64bit Core Duo. ncubic_tab1 seems like
> the best (no additional error and about as fast)

OK. It was the one I preferred too unless tab0's avg error was acceptable.

> ULV Core Solo
> 
> Function          clocks mean(us)  max(us)  std(us) Avg err size
> ncubic_tab0          192    11.24    45.10    15.28  0.450% -2262
> ncubic_0div          201    11.77    47.23    27.40  3.357% -2404
> ncubic_1div          324    19.02    76.32    25.82  0.189% -2567
> ncubic_tab1          326    19.13    76.73    23.71  0.043% -2059
> ncubic_2div          456    26.72   108.92   493.16  0.028% -2790
> ncubic_ndiv3         463    27.15   133.37  1889.39  0.104% -3344
> ncubic32             549    32.18   130.59   508.97  0.041% -3794
> ncubic32_1           574    33.66   138.32   548.48  0.029% -3604
> ncubic_3div          581    34.04   140.24   608.55  0.018% -3050
> ncubic               733    42.92   173.35   523.19  0.041%  299
> ocubic              1046    61.25   283.68  3305.65  0.027% -2232
> acbrt               1149    67.32   284.91  1941.55  0.029%  168
> bictcp              1663    97.41   394.29   604.86  0.017%  628
> 
> Core 2 Duo
> 
> Function          clocks mean(us)  max(us)  std(us) Avg err size
> ncubic_0div           74     0.03     1.60     0.07  3.357% -2101
> ncubic_tab0           74     0.03     1.60     0.04  0.450% -2029
> ncubic_1div          142     0.07     3.11     1.05  0.189% -2195
> ncubic_tab1          144     0.07     3.18     1.02  0.043% -1638
> ncubic_2div          216     0.10     4.74     1.07  0.028% -2326
> ncubic_ndiv3         219     0.10     4.76     1.04  0.104% -2709
> ncubic32             269     0.13     5.87     1.13  0.041% -1500
> ncubic32_1           272     0.13     5.92     1.10  0.029% -2881
> ncubic               273     0.13     5.96     1.13  0.041% -1763
> ncubic_3div          290     0.14     6.32     1.01  0.018% -2499
> acbrt                430     0.20     9.42     1.18  0.029%   77
> ocubic               444     0.21     9.82     1.82  0.027% -1924
> bictcp               549     0.26    12.06     1.68  0.017%  236

Thanks,
Willy

