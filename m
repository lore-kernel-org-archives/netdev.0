From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] macvlan: Support creating macvlans from macvlans
Date: Fri, 06 Mar 2009 07:24:40 -0800
Message-ID: <m1bpsellmv.fsf@fess.ebiederm.org>
References: <m1ocwfsgw7.fsf@fess.ebiederm.org> <49B12B20.7000602@trash.net>
	<m1sklqohw2.fsf@fess.ebiederm.org> <49B13259.9040701@trash.net>
	<m14oy6n15y.fsf@fess.ebiederm.org> <49B13C7D.10308@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:35313 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624AbZCFPYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2009 10:24:47 -0500
In-Reply-To: <49B13C7D.10308@trash.net> (Patrick McHardy's message of "Fri\, 06 Mar 2009 16\:08\:45 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> writes:

> Eric W. Biederman wrote:
>> Patrick McHardy <kaber@trash.net> writes:
>>
>>> That makes sense of course. I'm mainly wondering whether a namespace
>>> should be able to directly affect the real device like this. This
>>> might move it to promiscous mode, or affect other performce-relevant
>>> settings. Its also looks like you can steal the MAC address of a
>>> different macvlan device this way and have the packets directed to you
>>> (new devices are added to the beginning of the hash chains, so they
>>> are found first on lookups).
>>
>> To a large extent those are things that we already can do, simply by
>> having multiple mcavlans in different network namespaces.  I could
>> push it into promiscous mode by adding more multicast listeners,
>> and I could steal the mac address of another macvlan by changing
>> my mac address if I happen to come first in the hash chain.
>>
>> Hmm.  Actually that appears to be a macvlan bug.  It looks like if I
>> change the macaddress on a macvlan we don't update the hash chains.
>> So unless we have the same low byte we will be on the wrong hash chain
>> and not receive the packets for the mac we specified.  Ouch!
>
> The address can only be changed while the device is down and unhashed.

Point.  The dev_unicast/dev_unicast_delete in macvlan_set_mac_address
appears to be completely unnecessary then.

>> It is also trivial to spoof a different macvlan device by using
>> PF_PACKET and sending packets with the source mac address of
>> another macvlan.
>
> Yes, but that doesn't allow one namespace to deny service to
> a different one.

No for that I guess it seems I just need to down the interface
change the mac and up the interface again.

>> Also this still requires CAP_NET_ADMIN, as much as I would like
>> to remove that restriction.
>>
>> Your concerns don't appear to be new to allowing the creation
>> of a macvlan from a macvlan or fundamental to creating
>> a macvlan from a macvlan.  You still must have access to at
>> least a macvlan in your namespace to create a new one.  So
>> I don't think those issues bear on my patch.
>
> No, they're not, but it seemed worth pointing out. Your patch
> looks perfectly fine.

Thanks.

Would you be opposed to changes that made macvlan more robust.
Such as refusing to come up if the macaddress is already in use.
And perhaps denying the sending of packets with the wrong source
mac?

> Acked-by: Patrick McHardy <kaber@trash.net>
