From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH net-next 2/2] bonding: remove alb_set_mac_address()
Date: Thu, 22 May 2014 11:37:48 -0700
Message-ID: <24646.1400783868@localhost.localdomain>
References: <1400764324-23221-1-git-send-email-vfalico@gmail.com> <1400764324-23221-3-git-send-email-vfalico@gmail.com>
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:55551 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750870AbaEVShx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 14:37:53 -0400
In-reply-to: <1400764324-23221-3-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Veaceslav Falico <vfalico@gmail.com> wrote:

>Currently it's called only from bond_alb_set_mac_address(), which is called
>only for ALB mode, and it does nothing in case the mode is ALB. So,
>basically, it's a no-op. All the needed functionality (modifying the active
>slave's mac address, per example) is handled by the
>bond_alb_set_mac_address() itself.
>
>So remove it, as it's not needed.

	I thought this seemed odd, and I did some looking.  In the days
of yore, before ndo_*, bond_alb_set_mac_address() was used for both alb
and tlb modes, and alb_set_mac_address was not a no-op.

	That changed in this commit:

commit eb7cc59a038b4e1914ae991d313f35904924759f
Author: Stephen Hemminger <shemminger@vyatta.com>
Date:   Wed Nov 19 21:56:05 2008 -0800

    bonding: convert to net_device_ops
    
    Convert to net_device_ops table.
    Note: for some operations move error checking into generic networking
    layer (rather than looking at pointers in bonding).
[...]

	Before this, dev->set_mac_address was bond_alb_set_mac_address
for both alb and tlb modes; after this commit, the now-unified
bond_set_mac_address calls bond_alb_set_mac_address only for alb mode,
and not for tlb mode.

	Looking at alb_set_mac_address, the comment block says that:

 * In TLB mode all slaves are configured to the bond's hw address, but set
 * their dev_addr field to different addresses (based on their permanent hw
 * addresses).
 *
 * For each slave, this function sets the interface to the new address and then
 * changes its dev_addr field to its previous value.

	And, sure enough, that's what the code does.

	So, again, in the days of yore, when a manual change of the
bond's MAC took place, for tlb mode only, it would run through and
change all of the slaves to the new bond MAC, and, importantly, preserve
the dev->dev_addr tomfoolery that the tlb mode does.  This preservation
step appears to not happen currently (and, given the date of the commit
above, hasn't for some years now).

	This makes me wonder if some of the occasional oddball tlb
problems that crop up are due to this omission, since it looks to me
like any time the bond's MAC is manually changed in tlb mode, the
special stashing of MAC addresses in the slave dev->dev_addr won't be
preserved, and all of the slaves would end up using the same MAC, which
would not work so well.

	Separately, I'm not really sure how well this would have worked,
given that the bond would be down to change the MAC, but the slaves
would not necessarily also be down, and some of those slaves may not be
able to change MAC while up.

	So, anyway, in the end, I think this is ok to delete, but only
because the dev_addr MAC stash is about to be replaced with a New &
Shiny somewhere-else MAC stash.  It seems counterproductive to first fix
this, and then almost immediately throw it all away.

	Since there seems to be an actual bug here (and not just useless
dead code removal), I'm also inclined to prefer that this removal should
occur in conjunction with the introduction of the somewhere-else stash.

	Also, since there is (theoretically) a bug here, it may be
necessary to consider the new somewhere-else stash for stable
backporting.

	-J

>CC: Jay Vosburgh <j.vosburgh@gmail.com>
>CC: Andy Gospodarek <andy@greyhouse.net>
>Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
>---
> drivers/net/bonding/bond_alb.c | 61 ------------------------------------------
> 1 file changed, 61 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
>index 965518b..1d772b5 100644
>--- a/drivers/net/bonding/bond_alb.c
>+++ b/drivers/net/bonding/bond_alb.c
>@@ -1256,62 +1256,6 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
> 	return 0;
> }
> 
>-/**
>- * alb_set_mac_address
>- * @bond:
>- * @addr:
>- *
>- * In TLB mode all slaves are configured to the bond's hw address, but set
>- * their dev_addr field to different addresses (based on their permanent hw
>- * addresses).
>- *
>- * For each slave, this function sets the interface to the new address and then
>- * changes its dev_addr field to its previous value.
>- *
>- * Unwinding assumes bond's mac address has not yet changed.
>- */
>-static int alb_set_mac_address(struct bonding *bond, void *addr)
>-{
>-	struct slave *slave, *rollback_slave;
>-	struct list_head *iter;
>-	struct sockaddr sa;
>-	char tmp_addr[ETH_ALEN];
>-	int res;
>-
>-	if (BOND_MODE(bond) == BOND_MODE_ALB)
>-		return 0;
>-
>-	bond_for_each_slave(bond, slave, iter) {
>-		/* save net_device's current hw address */
>-		ether_addr_copy(tmp_addr, slave->dev->dev_addr);
>-
>-		res = dev_set_mac_address(slave->dev, addr);
>-
>-		/* restore net_device's hw address */
>-		ether_addr_copy(slave->dev->dev_addr, tmp_addr);
>-
>-		if (res)
>-			goto unwind;
>-	}
>-
>-	return 0;
>-
>-unwind:
>-	memcpy(sa.sa_data, bond->dev->dev_addr, bond->dev->addr_len);
>-	sa.sa_family = bond->dev->type;
>-
>-	/* unwind from head to the slave that failed */
>-	bond_for_each_slave(bond, rollback_slave, iter) {
>-		if (rollback_slave == slave)
>-			break;
>-		ether_addr_copy(tmp_addr, rollback_slave->dev->dev_addr);
>-		dev_set_mac_address(rollback_slave->dev, &sa);
>-		ether_addr_copy(rollback_slave->dev->dev_addr, tmp_addr);
>-	}
>-
>-	return res;
>-}
>-
> /************************ exported alb funcions ************************/
> 
> int bond_alb_initialize(struct bonding *bond)
>@@ -1777,15 +1721,10 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
> 	struct bonding *bond = netdev_priv(bond_dev);
> 	struct sockaddr *sa = addr;
> 	struct slave *swap_slave;
>-	int res;
> 
> 	if (!is_valid_ether_addr(sa->sa_data))
> 		return -EADDRNOTAVAIL;
> 
>-	res = alb_set_mac_address(bond, addr);
>-	if (res)
>-		return res;
>-
> 	memcpy(bond_dev->dev_addr, sa->sa_data, bond_dev->addr_len);
> 
> 	/* If there is no curr_active_slave there is nothing else to do.
>-- 
>1.8.4

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
