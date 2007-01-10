From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH 1/1] bonding: eliminate RTNL assertion spew
Date: Wed, 10 Jan 2007 14:33:58 -0500
Message-ID: <20070110193355.GA13249@gospo.rdu.redhat.com>
References: <20070109225900.GA11755@gospo.rdu.redhat.com> <20070109150935.6ec3ce69@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43048 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965045AbXAJTeT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jan 2007 14:34:19 -0500
To: Stephen Hemminger <shemminger@osdl.org>,
	Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <20070109150935.6ec3ce69@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 09, 2007 at 03:09:35PM -0800, Stephen Hemminger wrote:
> On Tue, 9 Jan 2007 17:59:01 -0500
> Andy Gospodarek <andy@greyhouse.net> wrote:
> 
> > 
> > These changes eliminate the messages indicating that the rtnetlink lock
> > isn't held when bonding tries to change the MAC address of an interface.
> > These calls generally come from timer-pops, but also from sysfs events
> > since neither hold the rtnl lock.  
> > 
> > The spew generally looks something like this:
> > 
> > RTNL: assertion failed at net/core/fib_rules.c (391)
> >  [<c028d12e>] fib_rules_event+0x3a/0xeb
> >  [<c02da576>] notifier_call_chain+0x19/0x29
> >  [<c0280ce6>] dev_set_mac_address+0x46/0x4b
> >  [<f8a2a686>] alb_set_slave_mac_addr+0x5d/0x88 [bonding]
> >  [<f8a2aa7e>] alb_swap_mac_addr+0x88/0x134 [bonding]
> >  [<f8a25ed9>] bond_change_active_slave+0x1a1/0x2c5 [bonding]
> >  [<f8a262e8>] bond_select_active_slave+0xa8/0xe1 [bonding]
> >  [<f8a27ecb>] bond_mii_monitor+0x3af/0x3fd [bonding]
> >  [<c0121896>] run_workqueue+0x85/0xc5
> >  [<f8a27b1c>] bond_mii_monitor+0x0/0x3fd [bonding]
> >  [<c0121d83>] worker_thread+0xe8/0x119
> >  [<c0111179>] default_wake_function+0x0/0xc
> >  [<c0121c9b>] worker_thread+0x0/0x119
> >  [<c0124099>] kthread+0xad/0xd8
> >  [<c0123fec>] kthread+0x0/0xd8
> >  .....
> > 
> > This patch was mostly inspired from parts of some potential bonding
> > updates Jay Vosburgh <fubar@us.ibm.com> and I discussed in December, so
> > he deserves most of the credit for the idea.
> > 
> > I've tested it on several systems and it works as I expect.  Deadlocks
> > between the rtnl and global bond lock are avoided since we drop the
> > global bond lock before taking the rtnl lock.
> > 
> 
> 
> This seems like the ugly way to do it. Couldn't you just change figure out
> how to acquire RTNL first. It wouldn't hurt to acquire it in the monitor
> routine even if you don't need it.
> 
> Conditional locking is a bad road to start down.


Stephen and Jeff, 

Does this seem like a better alternative?  Taking the rtnetlink lock
before the global bond luck should avoid deadlocks since it is done that
way throughout the bonding code.  I didn't notice any immediate problems,
but it was by no means and exhaustive stress test.  

Thanks,

-andy


Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---

 bond_main.c  |   15 +++++++++++++++
 bond_sysfs.c |    6 ++++++
 2 files changed, 21 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6482aed..e324235 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2024,6 +2024,9 @@ void bond_mii_monitor(struct net_device 
 	int delta_in_ticks;
 	int i;
 
+	/* grab rtnl lock before taking bond lock*/
+	rtnl_lock();	
+
 	read_lock(&bond->lock);
 
 	delta_in_ticks = (bond->params.miimon * HZ) / 1000;
@@ -2252,6 +2255,8 @@ re_arm:
 	}
 out:
 	read_unlock(&bond->lock);
+	
+	rtnl_unlock();
 }
 
 
@@ -2557,6 +2562,9 @@ void bond_loadbalance_arp_mon(struct net
 	int delta_in_ticks;
 	int i;
 
+	/* grab rtnl lock before taking bond lock*/
+	rtnl_lock();	
+
 	read_lock(&bond->lock);
 
 	delta_in_ticks = (bond->params.arp_interval * HZ) / 1000;
@@ -2663,6 +2671,8 @@ re_arm:
 	}
 out:
 	read_unlock(&bond->lock);
+	
+	rtnl_unlock();
 }
 
 /*
@@ -2687,6 +2697,9 @@ void bond_activebackup_arp_mon(struct ne
 	int delta_in_ticks;
 	int i;
 
+	/* grab rtnl lock before taking bond lock*/
+	rtnl_lock();	
+
 	read_lock(&bond->lock);
 
 	delta_in_ticks = (bond->params.arp_interval * HZ) / 1000;
@@ -2911,6 +2924,8 @@ re_arm:
 	}
 out:
 	read_unlock(&bond->lock);
+
+	rtnl_unlock();
 }
 
 /*------------------------------ proc/seq_file-------------------------------*/
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index ced9ed8..d23057a 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1028,6 +1028,8 @@ static ssize_t bonding_store_primary(str
 	struct slave *slave;
 	struct bonding *bond = to_bond(cd);
 
+	/* grab rtnl lock before taking bond lock*/
+	rtnl_lock();
 	write_lock_bh(&bond->lock);
 	if (!USES_PRIMARY(bond->params.mode)) {
 		printk(KERN_INFO DRV_NAME
@@ -1063,6 +1065,7 @@ static ssize_t bonding_store_primary(str
 	}
 out:
 	write_unlock_bh(&bond->lock);
+	rtnl_unlock();
 	return count;
 }
 static CLASS_DEVICE_ATTR(primary, S_IRUGO | S_IWUSR, bonding_show_primary, bonding_store_primary);
@@ -1134,6 +1137,8 @@ static ssize_t bonding_store_active_slav
         struct slave *new_active = NULL;
 	struct bonding *bond = to_bond(cd);
 
+	/* grab rtnl lock before taking bond lock*/
+	rtnl_lock();
 	write_lock_bh(&bond->lock);
 	if (!USES_PRIMARY(bond->params.mode)) {
 		printk(KERN_INFO DRV_NAME
@@ -1191,6 +1196,7 @@ static ssize_t bonding_store_active_slav
 	}
 out:
 	write_unlock_bh(&bond->lock);
+	rtnl_unlock();
 	return count;
 
 }
