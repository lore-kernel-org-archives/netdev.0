From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH] bonding: ban stacked bonding support
Date: Fri, 20 Feb 2015 21:55:41 -0500
Message-ID: <20150221025541.GA1332@gospo.home.greyhouse.net>
References: <20150220222042.GA15595@p183.telecom.by>
 <22754.1424474040@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Dobriyan <adobriyan@gmail.com>, davem@davemloft.net,
	vfalico@gmail.com, andy@greyhouse.net, netdev@vger.kernel.org
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:53406 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754931AbbBUCzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 21:55:50 -0500
Received: by mail-qg0-f54.google.com with SMTP id z60so17124799qgd.13
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 18:55:50 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <22754.1424474040@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 20, 2015 at 03:14:00PM -0800, Jay Vosburgh wrote:
> Alexey Dobriyan <adobriyan@gmail.com> wrote:
> 
> >Does Linux support it at all?
> >
> >In short: if you add bonding master as a slave, and then release it,
> >it will no longer be a IFF_BONDING creating problems like described at
> >https://bugzilla.kernel.org/show_bug.cgi?id=89541
> >
> >	echo +bond1 >/sys/class/net/bonding_masters
> >	echo 1 >/sys/class/net/bond1/bonding/mode
> >	echo +bond2 >/sys/class/net/bonding_masters
> >	echo +bond2 >/sys/class/net/bond1/bonding/slaves
> >	echo -bond2 >/sys/class/net/bond1/bonding/slaves
> >	echo -bond2 >/sys/class/net/bonding_masters
> >
> >	cat /proc/net/bonding/bond2		# should not exist
> >		[oops]
> >
> >Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> 
> 	I think it's time to disallow stacking like this; it never
> really worked quite right as far as I can remember, and I thought it was
> disallowed at some point in the past.  I don't believe the stacked bonds
> function correctly for receive in the current kernel, either, although
> I'd have to test it again to confirm that.
> 
> 	The usual case for desiring to stack bonds is an active-backup
> pair of LACP / 802.3ad bonds (such as the bugzilla referenced above),
> but the 802.3ad mode handles this situation internally, so no stack is
> necessary.

Completely agree.

> 
> >---
> >
> > drivers/net/bonding/bond_main.c |    5 +++++
> > 1 file changed, 5 insertions(+)
> >
> >--- a/drivers/net/bonding/bond_main.c
> >+++ b/drivers/net/bonding/bond_main.c
> >@@ -1248,6 +1248,11 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
> > 			    slave_dev->name);
> > 	}
> > 
> >+	if (slave_dev->flags & IFF_MASTER) {
> >+		netdev_dbg(bond_dev, "stacked bonding not supported\n");
> >+		return -EBUSY;
> >+	}
> >+
> > 	/* already enslaved */
> > 	if (slave_dev->flags & IFF_SLAVE) {
> > 		netdev_dbg(bond_dev, "Error: Device was already enslaved\n");
> 
> 	Instead of a separate block for IFF_MASTER, the IFF_SLAVE line
> could be replaced with something like:
> 
> 	if (netif_is_bond_slave(slave_dev) || netif_is_bond_master(slave_dev)) {
> 		netdev_dbg(bond_dev, "Error: Device is bond slave or master\n");
> 
> 	With that caveat:
I would say adding the check for netif_is_bond_master() is critical
since a check for only IFF_MASTER would fail when trying to add a bridge
to a bond and that failure would not be desireable.

Fix that and you can also add:

Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>

to your next post.

> 
> Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>
> 
> 	This is probably a good candidate for -stable as well.
Agree

(Though netif_is_bond_master() was added in 3.10; luckily it would be an
easy backport.)

> 
> 	-J
> 
> ---
> 	-Jay Vosburgh, jay.vosburgh@canonical.com
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
