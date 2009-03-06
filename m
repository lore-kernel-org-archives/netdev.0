From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] macvlan: Support creating macvlans from macvlans
Date: Fri, 06 Mar 2009 07:03:53 -0800
Message-ID: <m14oy6n15y.fsf@fess.ebiederm.org>
References: <m1ocwfsgw7.fsf@fess.ebiederm.org> <49B12B20.7000602@trash.net>
	<m1sklqohw2.fsf@fess.ebiederm.org> <49B13259.9040701@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58314 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754904AbZCFPD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2009 10:03:58 -0500
In-Reply-To: <49B13259.9040701@trash.net> (Patrick McHardy's message of "Fri\, 06 Mar 2009 15\:25\:29 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> writes:

> That makes sense of course. I'm mainly wondering whether a namespace
> should be able to directly affect the real device like this. This
> might move it to promiscous mode, or affect other performce-relevant
> settings. Its also looks like you can steal the MAC address of a
> different macvlan device this way and have the packets directed to you
> (new devices are added to the beginning of the hash chains, so they
> are found first on lookups).

To a large extent those are things that we already can do, simply by
having multiple mcavlans in different network namespaces.  I could
push it into promiscous mode by adding more multicast listeners,
and I could steal the mac address of another macvlan by changing
my mac address if I happen to come first in the hash chain.

Hmm.  Actually that appears to be a macvlan bug.  It looks like if I
change the macaddress on a macvlan we don't update the hash chains.
So unless we have the same low byte we will be on the wrong hash chain
and not receive the packets for the mac we specified.  Ouch!

It is also trivial to spoof a different macvlan device by using
PF_PACKET and sending packets with the source mac address of
another macvlan.

Also this still requires CAP_NET_ADMIN, as much as I would like
to remove that restriction.

Your concerns don't appear to be new to allowing the creation
of a macvlan from a macvlan or fundamental to creating
a macvlan from a macvlan.  You still must have access to at
least a macvlan in your namespace to create a new one.  So
I don't think those issues bear on my patch.



That said I am not opposed conceptually to something that is much
harder to abuse, and works better for the network namespace case.

Eric
