From: Timo Teras <timo.teras@iki.fi>
Subject: Re: [PATCH RFC] net/ipv4: Use next hop exceptions also for input
 routes
Date: Sun, 26 May 2013 12:41:33 +0300
Message-ID: <20130526124133.129d8da6@vostro>
References: <1369314946-12692-1-git-send-email-timo.teras@iki.fi>
	<20130526.000304.483513823383996098.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:39748 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751691Ab3EZJj5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 May 2013 05:39:57 -0400
Received: by mail-wg0-f49.google.com with SMTP id y10so3555974wgg.4
        for <netdev@vger.kernel.org>; Sun, 26 May 2013 02:39:56 -0700 (PDT)
In-Reply-To: <20130526.000304.483513823383996098.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 26 May 2013 00:03:04 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Timo Ter=C3=A4s <timo.teras@iki.fi>
> Date: Thu, 23 May 2013 16:15:46 +0300
>=20
> > Commit d2d68ba9 (ipv4: Cache input routes in fib_info nexthops)
> > assmued that "locally destined, and routed packets, never trigger
> > PMTU events or redirects that will be processed by us".
> >=20
> > However, it seems that tunnel devices do trigger PMTU events in
> > certain cases. At least ip_gre, ip6_gre, sit, and ipip do use the
> > inner flow's skb_dst(skb)->ops->update_pmtu to propage mtu
> > information from the outer flows. These can cause the inner flow
> > mtu to be decreased. If next hop exceptions are not consulted for
> > pmtu, IP fragmentation will not be done properly for these routes.
> >=20
> > It also seems that we really need to have the PMTU information
> > always for netfilter TCPMSS' clamp-to-pmtu feature to work properly=
=2E
> >=20
> > So for the time being, cache separate copies of input routes for
> > each next hop exception.
> >=20
> > Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
>=20
> Thanks for working on this Timo, I am actively reviewing this change
> and thinking about alternatives.

Thanks, I did notice one problems in further testing.

The symptom is that once learned pmtu expires, it is not refreshed by
fragments. This seems to be a dst caching issue. Fundamentally it seems
to be same problem that commit 05ab86c5 (xfrm4: Invalidate all ipv4
routes on IPsec pmtu events) tried to fix by flushing everything.

This some problem now happens with ip_gre bound inner flows as the pmtu
is locally generated and not received from internet to the esp/ah
packets. I believe the flush all approach is not necessary and we can
do better.

I basically have new patch set pending testing. I'll post the new patch
set sometime in next few days.
