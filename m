From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: GRO aggregation
Date: Wed, 12 Sep 2012 11:33:14 +0200
Message-ID: <1347442394.13103.703.camel@edumazet-glaptop>
References: <504F4063.9030706@mellanox.com>
	 ,<1347388396.13103.658.camel@edumazet-glaptop>
	 <36F7E4A28C18BE4DB7C86058E7B607241E622022@MTRDAG01.mtl.com>
	 ,<1347390113.13103.660.camel@edumazet-glaptop>
	 <36F7E4A28C18BE4DB7C86058E7B607241E622083@MTRDAG01.mtl.com>
	 <1347392132.13103.663.camel@edumazet-glaptop>
	 <505054AE.9040901@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Shlomo Pongartz <shlomop@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:51540 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754226Ab2ILJdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 05:33:21 -0400
Received: by eekc1 with SMTP id c1so1084285eek.19
        for <netdev@vger.kernel.org>; Wed, 12 Sep 2012 02:33:20 -0700 (PDT)
In-Reply-To: <505054AE.9040901@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-12 at 12:23 +0300, Shlomo Pongartz wrote:
> On 9/11/2012 10:35 PM, Eric Dumazet wrote:
> > On Tue, 2012-09-11 at 19:24 +0000, Shlomo Pongratz wrote:
> >
> >> I see that in ixgbe the weight for the NAPI is 64 (netif_napi_add). So
> >> if packets are arriving in high rate then an the CPU is fast enough to
> >> collect the packets as they arrive, assuming packets continue to
> >> arrives while the NAPI runs. Then it should have aggregate more. So we
> >> will have less passes trough the stack.
> >>
> > As I said, _if_ your cpu was loaded by other stuff, then you would see
> > biggest GRO packets.
> >
> > GRO is not : "We want to kill latency and have big packets just because
> > its better"
> >
> > Its more like : If load is big enough, try to aggregate TCP frames in
> > less skbs.
> >
> >
> >
> >
> First I want to apologize for breaking the mailing thread. I wasn't at 
> work and used webmail.
> 
> I agree with your but I think that something is still strange.
> On the transmitter side all the offloading are enabled, e.g. TSO and GSO.
> The tcpdump on the sender side shows size of 64240 which is 44 packets 
> of 1460 each.
> Now since the offloading are enabled the HW should transmit 44 frames 
> back to back,
> that is in a burst of 44 * 1500 bytes, which according to my calculation 
> should take 52.8 micro on 10G Ethernet.
> Using ethtool I've set the rx-usecs to 1022 micro, which I think is the 
> maximal value for ixgbe.
> Note that there is no way to set rx-frames on ixgbe.
> Now since the ixgbe weight is 64 I expected that the NAPI will be able 
> to poll for more then 21 packets,
> since 44 packets came in one burst.
> However the results remains the same.

TSO uses PAGE frags, so 64KB needs about 16 pages.

tcp_sendmsg() could even use order-3 pages, so that only 2 pages would
be needed to fill 64KB of data.

GRO uses whatever fragment size provided by NIC, depending on MTU.

One skb has a limit on number of frags.

Handling a huge array of frags would be actually slower in some helper
functions.

Since you dont exactly describe why you ask all these questions, its
hard to guess what problem you try to solve.
