From: Jay Vosburgh <j.vosburgh@gmail.com>
Subject: Re: [PATCH] bonding: Inactive slaves should keep inactive flag's value to 1
Date: Mon, 31 Mar 2014 17:35:19 -0700
Message-ID: <21040.1396312519@famine>
References: <1395998529-5937-1-git-send-email-zheng.x.li@oracle.com>
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	joe.jin@oracle.com
To: Zheng Li <zheng.x.li@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1395998529-5937-1-git-send-email-zheng.x.li@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zheng Li <zheng.x.li@oracle.com> wrote:

>In bond mode tlb and alb, inactive slaves should keep inactive flag to 1 to
>refuse to receive broadcast packets. Now, active slave send broadcast packets
>(for example ARP requests) which will arrive inactive slaves on same host from
>switch, but inactive slave's inactive flag is zero that cause bridge receive the
>broadcast packets to produce a wrong entry in forward table. Typical situation
>is domu send some ARP request which go out from dom0 bond's active slave, then
>the ARP broadcast request packets go back to inactive slave from switch, because
>the inactive slave's inactive flag is zero, kernel will receive the packets and
>pass them to bridge that cause dom0's bridge map domu's MAC address to port of
>bond, bridge should map domu's MAC to port of vif.

	I think the patch is ok (I don't have a machine to test it on at
the moment), but the description above is leaving out some details about
how the problem is induced.

	The actual problem being fixed here is that bond_open is not
setting the inactive flag correctly for some modes (alb and tlb),
resulting in the behavior described above if the bond has been
administratively set down and then back up.  This effect should not
occur when slaves are added while the bond is up; it's something that
only happens after a down/up bounce of the bond.

	That said, the patch itself looks fine to me.

Signed-off-by: Jay Vosburgh <j.vosburgh@gmail.com>

	-J

>Signed-off-by: Zheng Li <zheng.x.li@oracle.com>
>---
> drivers/net/bonding/bond_main.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index e5628fc..f97d72e 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -3058,7 +3058,7 @@ static int bond_open(struct net_device *bond_dev)
> 	if (bond_has_slaves(bond)) {
> 		read_lock(&bond->curr_slave_lock);
> 		bond_for_each_slave(bond, slave, iter) {
>-			if ((bond->params.mode == BOND_MODE_ACTIVEBACKUP)
>+			if ((bond->params.mode == BOND_MODE_ACTIVEBACKUP || bond_is_lb(bond))
> 				&& (slave != bond->curr_active_slave)) {
> 				bond_set_slave_inactive_flags(slave,
> 							      BOND_SLAVE_NOTIFY_NOW);
>-- 
>1.7.6.5

---
	-Jay Vosburgh, j.vosburgh@gmail.com
