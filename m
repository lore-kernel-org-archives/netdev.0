From: Jussi Peltola <plz@plz.fi>
Subject: Re: [PATCH] Fixup packets with incorrect ethertype sent by ZTE MF821D
Date: Sun, 13 Nov 2016 19:25:25 +0200
Message-ID: <20161113172525.GS2745@pokute.pelzi.net>
References: <20161113134753.GR2745@pokute.pelzi.net>
 <87zil3cq9i.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out1.dynaco.fi ([185.82.144.207]:40891 "EHLO
        smtp-out1.dynaco.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753258AbcKMRZh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 12:25:37 -0500
Content-Disposition: inline
In-Reply-To: <87zil3cq9i.fsf@miraculix.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 13, 2016 at 05:12:57PM +0100, Bjørn Mork wrote:
> In any case, if we're going to add a fix like this, then I want it way
> more generic.  The only valid ethertypes expected from the modem is IP,
> IPV6 or ARP. Testing against those three, resetting anything else to IP,
> will at least catch *any* bogus value.
 
Yes, this is pretty obvious, and it's pretty easy to look for an initial
4 or 6 and assume anything else is ARP (and just pass it through since
no reports of wrong ARP ethertype have been seen as far as I know and
fixing ARP up is probably futile if the L2 addresses in the body or
header don't make sense.)

I didn't bother writing this before sending this one first to provoke
discussion. It should actually be pretty simple; just pop the L2 header
if it looks like it's too broken and later add a new one if (!rawip).

> But I'm not convinced I want this additional processing of every packet
> just to let Qualcomm go on hiring monkeys-on-crack to write their
> firmware. At least not when we do have raw-ip as a workaround for the
> issue.
> 
> Feel free to try to convince me, though.

This is a modem widely sold in Finland by one of the telcos that has
enabled IPv6 to all subscribers. So the population affected is
definitely not just one person - but I will have to see if rawip works
and then see if ModemManager can be made to use that by default. I
didn't initially even think of trying, because v6 only works on this
modem after a router solicit. But who knows...

I find bugs like this, where the general answer for users (or userspace
parts like ModemManager) is "just disable this ipv6 crap" pretty nasty.
Even if the required fix is not exactly elegant, brokenness like this
can greatly set back getting v6 enabled when available.

As more v6 is deployed around the world I would expect more broken
Qualcomm modems to show themselves. I'll have to try to test this modem
to see if this bug disappears when the telco does not have IPv6; if so,
people are in for annoying surprises as the modem suddenly stops working
when the telco deploys v6.

I can agree with the lack of elegance. But I don't see processing per
every packet as a significant issue when the devices connect over USB
and their transfer rates are limited by the real world performance of
mobile networks, and the other option is that the device just doesn't
work at all. A knob would definitely feel wrong, as there is no
indication this logic will ever break any functionality for anyone, it
just wastes a few CPU cycles if the modem is not broken.
