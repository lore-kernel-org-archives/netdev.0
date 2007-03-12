From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] tcp_cubic: use 32 bit math
Date: Mon, 12 Mar 2007 14:11:56 -0700
Message-ID: <20070312141156.08e88b0e@freekitty>
References: <20070307170731.2b4397e3@freekitty>
	<20070307.185539.48527371.davem@davemloft.net>
	<45EF7EB7.8040806@linux-foundation.org>
	<20070307.195135.74749102.davem@davemloft.net>
	<20070310114826.GB1608@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	rkuhn@e18.physik.tu-muenchen.de, andi@firstfloor.org,
	dada1@cosmosbay.com, jengelh@linux01.gwdg.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:42490 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752430AbXCLVNt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2007 17:13:49 -0400
In-Reply-To: <20070310114826.GB1608@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 10 Mar 2007 12:48:26 +0100
Willy Tarreau <w@1wt.eu> wrote:

> On Wed, Mar 07, 2007 at 07:51:35PM -0800, David Miller wrote:
> > From: Stephen Hemminger <shemminger@linux-foundation.org>
> > Date: Wed, 07 Mar 2007 19:10:47 -0800
> > 
> > > David Miller wrote:
> > > > What about Willy Tarreau's supposedly even faster variant?
> > > > Or does this incorporate that set of improvements?
> > > >   
> > > That's what this is:
> > >     x = (2 * x + (uint32_t)div64_64(a, (uint64_t)x*(uint64_t)x)) / 3;
> > 
> > Great, thanks for the clarification.
> 
> Oh BTW, I have a newer version with a first approximation of the
> cbrt() before the div64_64, which allows us to reduce from 3 div64
> to only 2 div64. This results in a version which is twice as fast
> as the initial one (ncubic), but with slightly less accuracy (0.286%
> compared to 0.247). But I see that other functions such as hcbrt()
> had a 1.5% avg error, so I think this is not dramatic.

Ignore my hcbrt() it was a less accurate version of andi's stuff.

> Also, I managed to remove all other divides, to be kind with CPUs
> having a slow divide instruction or no divide at all. Since we compute
> on limited range (22 bits), we can multiply then shift right. It shows
> me even slightly better time on pentium-m and athlon, with a slightly
> higher avg error (0.297% compared to 0.286%), and slightly smaller
> code.

What does the code look like?

 
> I just have to clean experiments from my code to provide a patch.
> David, Stephen, are you interested ?
> 
> $ ./bictcp
> fls(0)=0, fls(1)=1, fls(256)=9
> Calibrating
> Function     clocks  mean(us) max(us)  std(us)  Avg error
> bictcp          936     0.61    24.28     1.99 0.172%
> ocubic          886     0.57    23.51     3.18 0.274%
> ncubic          644     0.42    16.59     2.18 0.247%
> ncubic32        444     0.29    11.47     1.50 0.247%
> ncubic32_1      444     0.29    11.56     1.88 0.238%
> ncubic32b3      337     0.22     8.67     0.88 0.286%
> ncubic_ndiv3    329     0.21     8.46     0.69 0.297%
> acbrt           707     0.46    18.05     0.80 0.275%
> hcbrt           644     0.42    16.44     0.51 1.580%
> 
> 
> Regards,
> Willy
> 


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
