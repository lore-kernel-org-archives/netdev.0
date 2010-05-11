From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next-2.6 1/2] bonding: add keep_all parameter
Date: Tue, 11 May 2010 17:03:45 -0400
Message-ID: <20100511210344.GH7497@gospo.rdu.redhat.com>
References: <20100511002949.GA7497@gospo.rdu.redhat.com> <7958.1273598301@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36721 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750726Ab0EKVDs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 May 2010 17:03:48 -0400
Content-Disposition: inline
In-Reply-To: <7958.1273598301@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 11, 2010 at 10:18:21AM -0700, Jay Vosburgh wrote:
> Andy Gospodarek <andy@greyhouse.net> wrote:
> 
> >
> >In an effort to suppress duplicate frames on certain bonding modes
> >(specifically the modes that do not require additional configuration on
> >the switch or switches connected to the host),
> 
> 	Strictly speaking, the above is incorrect, as the duplicate
> suppression is turned on for the active-backup inactive slaves as well
> as 802.3ad ports that are disabled (any slave that gets the "inactive"
> flag bit set).

It is also effective when using ALB and TLB, right?  I can change the
language if you would like to increase the description's accuracy.

> 
> >[...] code was added in the
> >generic receive patch in 2.6.16.  The current behavior works quite well
> >for most users, but there are some times it would be nice to restore old
> >functionality and allow all frames to make their way up the stack.
> 
> 	Reading netdev lately, it sure looks like everybody wants ways
> to shut off or bypass the duplicate suppression.
> 

I see that too, which was part of the reason to add a configuration
option.  I know many of the people that complained that they were seeing
dups will complain again if they show up in the future, so a config
option seemed like the best way to satisfy both.

> >This patch adds support for a new module option and sysfs file called
> >'keep_all' that will restore pre-2.6.16 functionality if the user
> >desires.  The default value is '0' and retains existing behavior, but
> >the user can set it to '1' and allow all frames up if desired.
> 
> 	Since this is really meant for the queue tagging stuff in the
> next patch, should this really be something that's enabled automatically
> if the queues are configured in such a way that the inactive slave is
> going to receive traffic?
> 

Part of the reason not to have it happen automatically is that the
second patch *should* allow simple pass-through of queue-mapping (though
I didn't mention that specifically) from bond device to underlying
slaves if the user is aware of the number of output queues in their
NIC and doesn't set the queue_ids for any of the slaves.

Another reason not to turn it on automatically is if the network patch
for transmission and reception are actually different.  The 'keep_all=1'
flag might not be needed if transmission is happening on an inactive
interface, but the active interface will receive all responses due to
the way the network is designed.

Again, a big part of the motivation patch was bringing back that
old-functionality to those that desire it and was why I split this out
from the next patch.
 
> 	I also wonder if something like this would satisfy the FCOE guys
> without making __netif_receive_skb / skb_bond_should_drop even more
> complicated than they already are.

I'd love to think so, but you never know.

> >Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> >Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> >---
> > Documentation/networking/bonding.txt |   15 ++++++++++++
> > drivers/net/bonding/bond_main.c      |   15 ++++++++++++
> > drivers/net/bonding/bond_sysfs.c     |   43 +++++++++++++++++++++++++++++++++-
> > drivers/net/bonding/bonding.h        |    1 +
> > include/linux/if.h                   |    1 +
> > net/core/dev.c                       |   26 +++++++++++---------
> > 6 files changed, 88 insertions(+), 13 deletions(-)
> >
> >diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
> >index 61f516b..d64fd2f 100644
> >--- a/Documentation/networking/bonding.txt
> >+++ b/Documentation/networking/bonding.txt
> >@@ -399,6 +399,21 @@ fail_over_mac
> > 	This option was added in bonding version 3.2.0.  The "follow"
> > 	policy was added in bonding version 3.3.0.
> >
> >+keep_all
> >+
> >+	Option to specify whether or not you will keep all frames
> >+	received on an interface that is a member of a bond.  Right
> >+	now checking is done to ensure that most frames ultimately
> >+	classified as duplicates are dropped to keep noise to a
> >+	minimum.  The feature to drop duplicates was added in kernel
> >+	version 2.6.16 (bonding driver version 3.0.2) and this will
> >+	allow that original behavior to be restored if desired.
> >+
> >+	A value of 0 (default) will preserve the current behavior and
> >+	will drop all duplicate frames the bond may receive.  A value
> >+	of 1 will not attempt to avoid duplicate frames and pass all
> >+	of them up the stack.
> 
> 	Two thoughts (presuming for the moment that this doesn't
> change): first, bump the driver version and mention when it was added;
> second, mention that this only applies to active-backup mode.
> 

Happy to update the version.  But shouldn't this impact ALB and TLB
modes too since they have a concept of 'active' slaves?

> > lacp_rate
> >
> > 	Option specifying the rate in which we'll ask our link partner

<snip>

> >--- a/net/core/dev.c
> >+++ b/net/core/dev.c
> >@@ -2758,21 +2758,23 @@ int __skb_bond_should_drop(struct sk_buff *skb, struct net_device *master)
> > 		skb_bond_set_mac_by_master(skb, master);
> > 	}
> >
> >-	if (dev->priv_flags & IFF_SLAVE_INACTIVE) {
> >-		if ((dev->priv_flags & IFF_SLAVE_NEEDARP) &&
> >-		    skb->protocol == __cpu_to_be16(ETH_P_ARP))
> >-			return 0;
> >+	if (unlikely(!(master->priv_flags & IFF_BONDING_KEEP_ALL))) {
> 
> 	So it's unlikely that "keep all" will be turned off?
> 

Grrrr.  That should be an if(likely!(....  Good catch.

> >+		if (dev->priv_flags & IFF_SLAVE_INACTIVE) {
> >+			if ((dev->priv_flags & IFF_SLAVE_NEEDARP) &&
> >+			    skb->protocol == __cpu_to_be16(ETH_P_ARP))
> >+				return 0;
> >
> >-		if (master->priv_flags & IFF_MASTER_ALB) {
> >-			if (skb->pkt_type != PACKET_BROADCAST &&
> >-			    skb->pkt_type != PACKET_MULTICAST)
> >+			if (master->priv_flags & IFF_MASTER_ALB) {
> >+				if (skb->pkt_type != PACKET_BROADCAST &&
> >+				    skb->pkt_type != PACKET_MULTICAST)
> >+					return 0;
> >+			}
> >+			if (master->priv_flags & IFF_MASTER_8023AD &&
> >+			    skb->protocol == __cpu_to_be16(ETH_P_SLOW))
> > 				return 0;
> >-		}
> >-		if (master->priv_flags & IFF_MASTER_8023AD &&
> >-		    skb->protocol == __cpu_to_be16(ETH_P_SLOW))
> >-			return 0;
> >
> >-		return 1;
> >+			return 1;
> >+		}
> > 	}
> > 	return 0;
> > }
> >-- 
> >1.6.2.5
> 
> 	-J
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
