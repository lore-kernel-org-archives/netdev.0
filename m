From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: Inactive slaves should keep inactive flag's value to 1 in tlb and alb mode.
Date: Thu, 27 Mar 2014 10:23:03 -0700
Message-ID: <9725.1395940983@death.nxdomain>
References: <1395716407-31601-1-git-send-email-zheng.x.li@oracle.com>
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	joe.jin@oracle.com
To: Zheng Li <zheng.x.li@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1395716407-31601-1-git-send-email-zheng.x.li@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zheng Li <zheng.x.li@oracle.com> wrote:

>In bond mode tlb and alb, inactive slaves should keep inactive flag to
>1 to refuse to receive broadcast packets. Now, active slave send broadcast packets
>(for example ARP requests) which will arrive inactive slaves on same host from switch,
>but inactive slave's inactive flag is zero that cause bridge receive the broadcast
>packets to produce a wrong entry in forward table. Typical situation is domu send some
>ARP request which go out from dom0 bond's active slave, then the ARP broadcast request
>packets go back to inactive slave from switch, because the inactive slave's inactive
>flag is zero, kernel will receive the packets and pass them to bridge, that cause dom0's
>bridge map domu's MAC address to port of bond, bridge should map domu's MAC to port of vif.

	It's probably worth noting that this effect is something that
happens after the bonding master device is opened with slaves, i.e.,
it's got a bunch of slaves, and is then set administratively down for
whatever reason, and is now being set back up, and needs to set the
active or inactive state of all the slaves.

	It'd also be a little easier to read if it was formatted for 80
columns.

>Signed-off-by: Zheng Li <zheng.x.li@oracle.com>
>---
> drivers/net/bonding/bond_main.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index e5628fc..8761df6 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -3062,7 +3062,7 @@ static int bond_open(struct net_device *bond_dev)
> 				&& (slave != bond->curr_active_slave)) {
> 				bond_set_slave_inactive_flags(slave,
> 							      BOND_SLAVE_NOTIFY_NOW);
>-			} else {
>+			} else if (!bond_is_lb(bond)) {
> 				bond_set_slave_active_flags(slave,
> 							    BOND_SLAVE_NOTIFY_NOW);

	This patch doesn't do anything for the modes that are
bond_is_lb, i.e., the balance-tlb and -alb modes.  I believe those two
should be set similarly to active-backup: the curr_active_slave is
active, other slaves are inactive.  The "inactive" setting for alb is
special, and means to not pass broadcast or multicast, but let unicast
through.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
