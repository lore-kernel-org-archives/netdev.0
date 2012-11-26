From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: in balance-rr mode, set curr_active_slave only if it is up
Date: Mon, 26 Nov 2012 10:36:46 -0800
Message-ID: <1380.1353955006@death.nxdomain>
References: <20121122125202.14252C35B8@unicorn.suse.cz>
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>,
	linux-kernel@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <20121122125202.14252C35B8@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michal Kubecek <mkubecek@suse.cz> wrote:

>If all slaves of a balance-rr bond with ARP monitor are enslaved
>with down link state, bond keeps down state even after slaves
>go up.
>
>This is caused by bond_enslave() setting curr_active_slave to
>first slave not taking into account its link state. As
>bond_loadbalance_arp_mon() uses curr_active_slave to identify
>whether slave's down->up transition should update bond's link
>state, bond stays down even if slaves are up (until first slave
>goes from up to down at least once).

	The bond_loadbalance_arp_mon function actually uses
curr_active_slave to determine whether or not to do a "failover" (select
a new active slave), which in turn will call bond_set_carrier() from
within bond_select_active_slave().

	Other than that nitpick about the description, I see how setting
curr_active_slave to a down slave would cause loadbalance_arp_mon to
skip the "failover" step (because it presumes that an active slave is
always up, and therefore no new one needs to be selected), and thus skip
setting the master's carrier state.

	-J

>Before commit f31c7937 "bonding: start slaves with link down for
>ARP monitor", this was masked by slaves always starting in UP
>state with ARP monitor (and MII monitor not relying on
>curr_active_slave being NULL if there is no slave up).
>
>Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


> drivers/net/bonding/bond_main.c |    2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 5f5b69f..c8bff3e 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -1838,7 +1838,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
> 		 * anyway (it holds no special properties of the bond device),
> 		 * so we can change it without calling change_active_interface()
> 		 */
>-		if (!bond->curr_active_slave)
>+		if (!bond->curr_active_slave && new_slave->link == BOND_LINK_UP)
> 			bond->curr_active_slave = new_slave;
>
> 		break;
>-- 
>1.7.10.4
>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
