From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next] bonding: RCUify bond_set_rx_mode()
Date: Mon, 5 Aug 2013 20:31:11 +0200
Message-ID: <20130805183111.GA3383@redhat.com>
References: <1375694776-3429-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48428 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754062Ab3HEScG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Aug 2013 14:32:06 -0400
Content-Disposition: inline
In-Reply-To: <1375694776-3429-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 05, 2013 at 11:26:16AM +0200, Veaceslav Falico wrote:
>Currently, we might easily deadlock with bond_set_rx_mode() and
>bond_hw_addr_swap(). bond_set_rx_mode() is called via dev_set_rx_mode(),
>which already holds the netif_addr_lock_bh(bond), and inside it takes the
>bond->curr_active_slave lock, while bond_hw_addr_swap() is called with
>bond->curr_active_slave lock held and then takes netif_addr_lock_bh(bond),
>which results in deadlock.
>
>CPU0                    CPU1
>----                    ----
>lock(&bonding_netdev_addr_lock_key);
>			lock(&bond->curr_slave_lock);
>			lock(&bonding_netdev_addr_lock_key);
>lock(&bond->curr_slave_lock);
>
>Fix this by using the RCU primites in bond_set_rx_mode(). We're safe wrt
>racing of dev_?c_(un)sync() because we hold
>lock(&bonding_netdev_addr_lock_key), and thus nobody will be able to modify
>these lists before we finish.
>
>CC: Jay Vosburgh <fubar@us.ibm.com>
>CC: Andy Gospodarek <andy@greyhouse.net>
>CC: Nikolay Aleksandrov <nikolay@redhat.com>
>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Self-NAK, for clarity. Posted a reworked patch - "[net-next] bonding: remove
locking from bond_set_rx_mode()" for the same issue.

>---
> drivers/net/bonding/bond_main.c |   10 ++++------
> 1 files changed, 4 insertions(+), 6 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 476df7d..fdc01c6 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -3571,24 +3571,22 @@ static void bond_set_rx_mode(struct net_device *bond_dev)
> 	struct bonding *bond = netdev_priv(bond_dev);
> 	struct slave *slave;
>
>-	read_lock(&bond->lock);
>+	rcu_read_lock();
>
> 	if (USES_PRIMARY(bond->params.mode)) {
>-		read_lock(&bond->curr_slave_lock);
>-		slave = bond->curr_active_slave;
>+		slave = rcu_dereference(bond->curr_active_slave);
> 		if (slave) {
> 			dev_uc_sync(slave->dev, bond_dev);
> 			dev_mc_sync(slave->dev, bond_dev);
> 		}
>-		read_unlock(&bond->curr_slave_lock);
> 	} else {
>-		bond_for_each_slave(bond, slave) {
>+		bond_for_each_slave_rcu(bond, slave) {
> 			dev_uc_sync_multiple(slave->dev, bond_dev);
> 			dev_mc_sync_multiple(slave->dev, bond_dev);
> 		}
> 	}
>
>-	read_unlock(&bond->lock);
>+	rcu_read_unlock();
> }
>
> static int bond_neigh_init(struct neighbour *n)
>-- 
>1.7.1
>
