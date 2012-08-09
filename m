From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [net-next] bonding: don't allow the master to become its slave
Date: Thu, 09 Aug 2012 14:27:08 -0700
Message-ID: <22811.1344547628@death.nxdomain>
References: <1344537049-11473-1-git-send-email-fbl@redhat.com> <1344539003.2593.7.camel@bwh-desktop.uk.solarflarecom.com> <20120809163906.6dc0b6d4@obelix.rh> <20120809195539.GB1783@minipsycho.orion> <1344546593.2593.24.camel@bwh-desktop.uk.solarflarecom.com>
Cc: Jiri Pirko <jpirko@redhat.com>, Flavio Leitner <fbl@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	Leonardo Chiquitto <lchiquitto@suse.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:41505 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753544Ab2HIV12 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2012 17:27:28 -0400
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 9 Aug 2012 17:27:27 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 6B9F0C90026
	for <netdev@vger.kernel.org>; Thu,  9 Aug 2012 17:27:12 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q79LRCX0153308
	for <netdev@vger.kernel.org>; Thu, 9 Aug 2012 17:27:12 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q79LR9Pd013249
	for <netdev@vger.kernel.org>; Thu, 9 Aug 2012 18:27:11 -0300
In-reply-to: <1344546593.2593.24.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> wrote:
>On Thu, 2012-08-09 at 21:55 +0200, Jiri Pirko wrote:
[...]
>> How about other devices who do not use "->master" like vlan, macvlan?
>
>And they shouldn't use master, because they allow multiple upper devices
>may be stacked on a single lower device.  Instead they use iflink, but
>that's an ifindex and not a net_device pointer.
>
>So I think we can catch simple loops with:
>
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -4445,8 +4445,22 @@ int netdev_set_master(struct net_device *slave, struct net_device *master)
> 	ASSERT_RTNL();
>
> 	if (master) {
>+		struct net_device *bottom, *top;
>+
> 		if (old)
> 			return -EBUSY;
>+
>+		/* Prevent loops */
>+		bottom = slave;
>+		while (bottom->iflink != bottom->ifindex)
>+			bottom = __dev_get_by_index(dev_net(bottom),
>+						    bottom->iflink);
>+		top = master;
>+		while (top->master)
>+			top = top->master;
>+		if (top == bottom)
>+			return -EBUSY;
>+
> 		dev_hold(master);
> 	}
>
>--- END ---
>
>But then there can be quite silly device relationships like:
>
>               +-------+
>               | bond0 |
>               ++-----++
>               /       \
>+-------+ +---+---+ +---+---+ +-------+
>| vlan0 | | vlan1 | | vlan2 | | vlan3 |
>+---+---+ +---+---+ +---+---+ +---+---+
>     \       /           \       /
>     ++-----++           ++--+--++
>     | bond1 |           | bond2 |
>     +-------+           +-------+
>      :     :             :     :
>
>Suppose the user tries to make bond0 a slave of bond1; we need to go to
>somewhat more effort to detect the loop.

	If that's hard to do (and it might be; I'm not aware of a
standard way to run up and down those stacks of interfaces, which might
not always be vlans in the middle), there's still the priv_flags &
IFF_BONDING test that bonding could (and probably should) do itself as
well.  The team driver could presumably have a similar test, although I
seem to recall that team was allowed to nest.

	FWIW, I've seen both the top and bottom halves of that picture
in use (i.e., bonds consisting of vlans as slaves or bonds with vlans
configured above them), but not combined as in your diagram.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
