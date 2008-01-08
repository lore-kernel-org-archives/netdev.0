From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH 0/3] bonding: 3 fixes for 2.6.24
Date: Tue, 8 Jan 2008 14:17:06 -0500
Message-ID: <20080108191706.GD8728@gospo.usersys.redhat.com>
References: <11997574203125-git-send-email-fubar@us.ibm.com> <Pine.LNX.4.64.0801081949290.1135@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54543 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753560AbYAHTRq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2008 14:17:46 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801081949290.1135@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 08, 2008 at 07:50:22PM +0100, Krzysztof Oledzki wrote:
> 
> 
> On Mon, 7 Jan 2008, Jay Vosburgh wrote:
> 
> >	Following are three fixes to fix locking problems and
> >silence locking-related warnings in the current 2.6.24-rc.
> >
> >	patch 1: fix locking in sysfs primary/active selection
> >
> >	Call core network functions with expected locks to
> >eliminate potential deadlock and silence warnings.
> >
> >	patch 2: fix ASSERT_RTNL that produces spurious warnings
> >
> >	Relocate ASSERT_RTNL to remove a false warning; after patch,
> >ASSERT is located in code that holds only RTNL (additional locks were
> >causing the ASSERT to trip)
> >
> >	patch 3: fix locking during alb failover and slave removal
> >
> >	Fix all call paths into alb_fasten_mac_swap to hold only RTNL.
> >Eliminates deadlock and silences warnings.
> >
> >	Patches are against the current netdev-2.6#upstream branch.
> >
> >	Please apply for 2.6.24.
> 
> 2.6.24-rc7 + patches #1, #2, #3:
> 
> bonding: bond0: setting mode to active-backup (1).
> bonding: bond0: Setting MII monitoring interval to 100.
> ADDRCONF(NETDEV_UP): bond0: link is not ready
> bonding: bond0: Adding slave eth0.
> e1000: eth0: e1000_watchdog: NIC Link is Up 1000 Mbps Full Duplex, Flow 
> Control: RX/TX
> bonding: bond0: making interface eth0 the new active one.
> bonding: bond0: first active interface up!
> bonding: bond0: enslaving eth0 as an active interface with an up link.
> bonding: bond0: Adding slave eth1.
> ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
> 
> =========================================================
> [ INFO: possible irq lock inversion dependency detected ]
> 2.6.24-rc7 #1
> ---------------------------------------------------------
> events/0/9 just changed the state of lock:
>  (&mc->mca_lock){-+..}, at: [<c041258e>] mld_ifc_timer_expire+0x130/0x1fb
> but this lock took another, soft-read-irq-unsafe lock in the past:
>  (&bond->lock){-.--}
> 
> and interrupts could create inverse lock ordering between them.
> 
> 

Jay's patches will not fix this issue.  I think something like this did
it for me, but as I mentioned to Jay in the last thread, I'm not
convinced it doesn't violate some of the locking expectations we have.

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 423298c..3c6619a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3915,7 +3915,7 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
 	struct bonding *bond = bond_dev->priv;
 	struct dev_mc_list *dmi;
 
-	write_lock_bh(&bond->lock);
+	read_lock(&bond->lock);
 
 	/*
 	 * Do promisc before checking multicast_mode
@@ -3957,7 +3957,7 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
 	bond_mc_list_destroy(bond);
 	bond_mc_list_copy(bond_dev->mc_list, bond, GFP_ATOMIC);
 
-	write_unlock_bh(&bond->lock);
+	read_unlock(&bond->lock);
 }
 
 /*


