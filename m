From: Cong Wang <amwang@redhat.com>
Subject: Re: [v5 Patch 1/3] netpoll: add generic support for bridge and bonding
 devices
Date: Fri, 28 May 2010 16:16:34 +0800
Message-ID: <4BFF7BE2.6020503@redhat.com>
References: <20100505081514.5157.83783.sendpatchset@localhost.localdomain> <20100527180545.GA2345@sysclose.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050607000507050808060501"
Cc: linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Andy Gospodarek <gospo@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jeff Moyer <jmoyer@redhat.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>
To: Flavio Leitner <fbl@sysclose.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1545 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754684Ab0E1INA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 May 2010 04:13:00 -0400
In-Reply-To: <20100527180545.GA2345@sysclose.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050607000507050808060501
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 05/28/10 02:05, Flavio Leitner wrote:
>
> Hi guys!
>
> I finally could test this to see if an old problem reported on bugzilla[1] was
> fixed now, but unfortunately it is still there.
>
> The ticket is private I guess, but basically the problem happens when bonding
> driver tries to print something after it had taken the write_lock (monitor
> functions, enslave/de-enslave), so the printk() will pass through netpoll, then
> on bonding again which no matter what mode you use, it will try to read_lock()
> the lock again. The result is a deadlock and the entire system hangs.
>

Does the attached patch fix this hang?

Thanks!

----------------------->

We should notify netconsole that bond is changing its slaves
when we use active-backup mode.

Signed-off-by: WANG Cong <amwang@redhat.com>

----


--------------050607000507050808060501
Content-Type: text/x-patch;
 name="drivers-net-bonding-fix-activebackup-deadlock.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="drivers-net-bonding-fix-activebackup-deadlock.diff"

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 5e12462..9494c02 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1199,6 +1199,7 @@ void bond_select_active_slave(struct bonding *bond)
 
 	best_slave = bond_find_best_slave(bond);
 	if (best_slave != bond->curr_active_slave) {
+		netdev_bonding_change(bond->dev, NETDEV_BONDING_DESLAVE);
 		bond_change_active_slave(bond, best_slave);
 		rv = bond_set_carrier(bond);
 		if (!rv)
@@ -2154,6 +2155,7 @@ static int bond_ioctl_change_active(struct net_device *bond_dev, struct net_devi
 	    (old_active) &&
 	    (new_active->link == BOND_LINK_UP) &&
 	    IS_UP(new_active->dev)) {
+		netdev_bonding_change(bond->dev, NETDEV_BONDING_DESLAVE);
 		write_lock_bh(&bond->curr_slave_lock);
 		bond_change_active_slave(bond, new_active);
 		write_unlock_bh(&bond->curr_slave_lock);

--------------050607000507050808060501--
