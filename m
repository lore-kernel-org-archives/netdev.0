From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] [PATCH] Optimize TCP sendmsg in favour of fast devices?
Date: Wed, 27 Jan 2010 12:42:12 +0530
Message-ID: <OF7EA723DA.DC2FF4FC-ON652576B8.002064CB-652576B8.00267739@in.ibm.com>
References: <20100121.012520.254679483.davem@davemloft.net> <20100121094157.GA15262@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp09.in.ibm.com ([122.248.162.9]:39057 "EHLO
	e28smtp09.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754078Ab0A0HAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 02:00:18 -0500
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp09.in.ibm.com (8.14.3/8.13.1) with ESMTP id o0R6RHNw020083
	for <netdev@vger.kernel.org>; Wed, 27 Jan 2010 11:57:17 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0R70ETo2953340
	for <netdev@vger.kernel.org>; Wed, 27 Jan 2010 12:30:14 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0R70D81022563
	for <netdev@vger.kernel.org>; Wed, 27 Jan 2010 18:00:14 +1100
In-Reply-To: <20100121094157.GA15262@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Herbert,

> Herbert Xu <herbert@gondor.apana.org.au> wrote on 01/21/2010 03:11 PM

Sorry for the late response.

> >> I had to remove the F_SG flag from cxgb3 driver (using ethtool
> >> didn't show any difference in performance since GSO was enabled
> >> on the device due to register_netdev setting it). Testing show a
> >> drop of 25% in performance with this patch for non-SG device,
> >> the extra alloc/memcpy is showing up.
> >>
> >> For the SG driver, I get a good performace gain (not anywhere
> >> close to 25% though). What do you suggest?
> >
> > I don't think we can add your change if it hurts non-SG
> > devices that much.
>
> Wait, we need to be careful when testing this.  Non-SG devices
> do actually benefit from TSO which they otherwise cannot access.
>
> If you unset the F_SG bit, then that would disable TSO too.  So
> you need to enable GSO to compensate.  So Krishna, did you check
> with tcpdump to see if GSO was really enabled with SG off?

OK, I unset F_SG and set F_GSO (in driver). With this, tcpdump shows
GSO is enabled - the tcp packet sizes builds up to 65160 bytes.

I ran 5 serial netperf's with 16K and another 5 serial netperfs
with 64K I/O sizes, and the aggregate result is:

0. Driver unsets F_SG but sets F_GSO:
      Original code with 16K: 19471.65
      New code with 16K:      19409.70
      Original code with 64K: 21357.23
      New code with 64K:      22050.42

To recap the other tests I did today:

1. Driver unsets F_SG, and with GSO off
      Original code with 16K: 10123.56
      New code with 16K:      7111.12
      Original code with 64K: 11568.99
      New code with 64K:      7611.37

2. Driver unsets F_SG and uses ethtool to set GSO:
      Original code with 16K: 18864.38
      New code with 16K:      18465.54
      Original code with 64K: 21005.43
      New code with 64K:      22529.24

Thanks,

- KK

> IIRC when I did a similar test with e1000 back when I wrote this
> the performance of GSO with SG off was pretty much the same as
> no GSO with SG off.

