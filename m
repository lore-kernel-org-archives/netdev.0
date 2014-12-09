From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [bisected] xfrm: TCP connection initiating PMTU discovery
 stalls on v3.
Date: Tue, 09 Dec 2014 06:26:49 -0800
Message-ID: <1418135209.14835.17.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n>
	 <1417785985.4322.1.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5642727.qTG53DqrAk@h2o.as.studentenwerk.mhn.de> <3594382.qsqLZcX7yO@storm>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Walter <linux@stwm.de>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Thomas Jarosch <thomas.jarosch@intra2net.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:44334 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752430AbaLIO0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 09:26:53 -0500
Received: by mail-ie0-f179.google.com with SMTP id rp18so563683iec.38
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 06:26:52 -0800 (PST)
In-Reply-To: <3594382.qsqLZcX7yO@storm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-12-09 at 09:54 +0100, Thomas Jarosch wrote:
> On Monday, 8. December 2014 23:20:42 Wolfgang Walter wrote:
> > Am Freitag, 5. Dezember 2014, 05:26:25 schrieb Eric Dumazet:
> > > On Fri, 2014-12-05 at 13:09 +0100, Wolfgang Walter wrote:
> > > > Hello,
> > > > 
> > > > as reverting this patch fixes this rather annoying problem: is it
> > > > dangerous to revert it as a workaround until the root cause is found?
> > > 
> > > Unfortunately no, this patch fixes a serious issue.
> > > 
> > > We need to find the root cause of your problem instead of trying to work
> > > around it.
> > 
> > I only wanted to use it as local workaround here.
> > 
> > 
> > I looked a bit at at code. I'm not familiar with the network code, though
> > :-).
> 
> If it helps, I'm running the reverted patch on five production boxes hitherto 
> without a hiccup. As far as I understood the original commit message,
> some packet counters might me wrong without it.
> 
> @Eric: What could possibly go wrong(tm)? :)

Crashes in TCP stack, because of packet count mismatches.

The sk_can_gso() status is already tested in tcp_sendmsg() as a hint,
since path behavior can dynamically be changed on existing flow :

<start a TCP flow>
ethtool -K eth0 tso off gso off

In this case, core networking stack detects this and segments the
packets _after_ TCP or IP stack, before they reach eth0.

TCP stack does not have to know that something is changed right before
giving a GSO packet to core networking stack, this would be racy by
nature, as TCP does not know or control full path. Hopefully we do not
take RTNL for every packet we send in TCP !

It seems XFRM triggers in a slow path something which is not correctly
handled.

It is not correct to add a racy kludge in TCP fast path for this very
unlikely case.

I would disable TSO/GSO on xfrm, and problem should disappear.
