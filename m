From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: multicast, interfaces, kernel 3.0+...
Date: Sat, 22 Sep 2012 08:43:07 +0400
Message-ID: <505D41DB.7060508@msgid.tls.msk.ru>
References: <505CB607.7080207@msgid.tls.msk.ru> <505D3CE0.2050603@msgid.tls.msk.ru> <20120922.003133.2272531217856660981.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:36860 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751560Ab2IVEnL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Sep 2012 00:43:11 -0400
In-Reply-To: <20120922.003133.2272531217856660981.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22.09.2012 08:31, David Miller wrote:
> From: Michael Tokarev <mjt@tls.msk.ru>
> Date: Sat, 22 Sep 2012 08:21:52 +0400
> 
>> The IP_ADD_MEMBERSHIP interface is apparently misdefined, because it
>> accepts an IP address of an interface, instead of an ifindex, or
>> ifname, or something like this, since there's no, obviously, 1:1
>> correspondence between ifaces and addresses, an iface can have no
>> addresses assotiated with it, or two ifaces can share one IP address
>> like in my case.  But the "questionable" part is the "usualness" of
>> this setup I have here, with two ifaces having the same IP address.
> 
> Can you at least look at the API specification for IP_ADD_MEMBERSHIP
> before making such claims?

As I mentioned in previous email, I haven't dealt with multicast before,
so obviously I tried my best to learn before making any claims at all.
And the fine manual, http://tldp.org/HOWTO/Multicast-HOWTO-6.html ,
says:

 6.4 IP_ADD_MEMBERSHIP.

 The ip_mreq structure (taken from /usr/include/linux/in.h) has the following members:

    struct ip_mreq
    {
            struct in_addr imr_multiaddr;   /* IP multicast address of group */
            struct in_addr imr_interface;   /* local IP address of interface */
    };

 ...
 setsockopt (socket, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mreq, sizeof(mreq));

Yes I probably should have read the mentioned header and the manpage too.
But the app does this:

 setsockopt(567, SOL_IP, IP_ADD_MEMBERSHIP, "\344\5\6\7\nM\7Z", 8) = 0
 setsockopt(567, SOL_IP, IP_ADD_MEMBERSHIP, "\344\5\6\7\nM\7Z", 8) = -1 EADDRINUSE (Address already in use)

so apparently sizeof(mreq) is 8 bytes for it, and I just didn't think there
may be additional fields in "real life".  That was puzzling, so I asked.
(This is most likely a generic java interface to this facility, not
linux-specific).

As you can see, I at least tried.  It wasn't apparently successful, but
that isn't entirely my fault either, -- the "canonical" howto does not
mention that there might be more members in this structure.. ;)

> The IP_ADD_MEMBERSHIP interface allows for the specification of a
> specific interface, the structure you pass into IP_ADD_MEMBERSHIP has
> an ->imr_ifindex field and this is the first key the call uses
> to pick a device.

Ok, after you mentioned this, I looked at the other sources and indeed
it has.  I stand corrected, and my questions answered.

> If you do not specify an explicit ifindex, and leave it at zero which
> I bet your application is doing, it picks the first address which has
> the specified address.
> 
> As you have discovered, just specifying the address can cause unwanted
> effects when multiple devices have the same IP address.  Because the
> order of network devices in the system is never, and has never, been
> guaranteed.
> 
> So the selection in this situation is essentially random because
> you haven't given the kernel enough information to choose things
> the way that you want it to.

Yes, that's what I thought too, it was just puzzling with the missing
bits of info.  And yes I remember when order of addresses changed
in various places (routing table was one example) and people started
complaining, even when order had never been deterministic.

I'm not complaining, I'm just asking.  And you answered my questions
perfectly, thank you!

/mjt
