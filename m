From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tcp: Do not apply TSO segment limit to non-TSO packets
Date: Fri, 02 Jan 2015 10:24:00 -0800
Message-ID: <1420223040.32621.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n>
	 <20141201102522.GA16579@gondor.apana.org.au>
	 <20141231133923.GA30248@gondor.apana.org.au>
	 <20141231134217.GB30248@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Jarosch <thomas.jarosch@intra2net.com>,
	netdev@vger.kernel.org, edumazet@google.com,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:34950 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745AbbABSYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 13:24:03 -0500
Received: by mail-pd0-f180.google.com with SMTP id fl12so8350953pdb.25
        for <netdev@vger.kernel.org>; Fri, 02 Jan 2015 10:24:02 -0800 (PST)
In-Reply-To: <20141231134217.GB30248@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-01 at 00:42 +1100, Herbert Xu wrote:
> On Thu, Jan 01, 2015 at 12:39:23AM +1100, Herbert Xu wrote:
> >
> > Thomas Jarosch reported IPsec TCP stalls when a PMTU event occurs.
> > 
> > In fact the problem was completely unrelated to IPsec.  The bug is
> > also reproducible if you just disable TSO/GSO.
> 
> This raises two interesting questions.
> 
> Firstly not many people test non-TSO code paths anymore so bugs
> are likely to persist for a long time there.  Perhaps it's time
> to remove the non-TSO code path altogether? The GSO code path
> should provide enough speed-up in terms of boosting the effective
> MTU to offset the cost of copying.

> Secondly why are we dealing with hardware TSO segment limits
> by limiting the size of the TSO packet in the TCP stack? Surely
> in this case GSO is free since there won't be any copying?

It might depends on the device capabilities.

Non TSO/GSO path is known to be better for devices unable to perform TX
checksumming, as we compute the checksum at the time we copy data from
user to kernel (csum_and_copy_from_user() from tcp_sendmsg())).

With BQL+TSQ, having to compute the TX hash means bringing data into cpu
caches a second time right before ndo_start_xmit()

But maybe this gain is very relative in a full blown configuration, with
netfilter / complex qdisc being used.

Thanks Herbert !
