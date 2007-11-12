From: Moni Shoua <monis@voltaire.com>
Subject: Possible bug in bonding
Date: Mon, 12 Nov 2007 18:26:26 +0200
Message-ID: <47387EB2.8050806@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Moni Levy <monil@voltaire.com>, Or Gerlitz <ogerlitz@voltaire.com>,
	netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:34851 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751304AbXKLQ0n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2007 11:26:43 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

As reported last week by Or Gerlitz and confirmed by me, there is a kernel crash 
when trying to unenslave all ib slaves (which leads to bonding master destruction).
I also found that it happens with Ethernet slaves if following the steps:

1. unenslaving all slaves via sysfs
2. deleting the bonding master via sysfs


I see that in commit 6603a6f25e4bca922a7dfbf0bf03072d98850176 
the order of the bonding master destruction sequence was changed 
in 2 places (a part of the commitdiff is below).

Although I might be missing something it looks like a bug to me
to dereference the dev pointer after unregistering it. Am I right?

I also see that the kernel crash doesn't happen when reverting from this 
(part of) the patch.

I'd like to have your opinion please.

thanks
 
    MoniS

---------------------------------------------------------

commit 6603a6f25e4bca922a7dfbf0bf03072d98850176
Author: Jay Vosburgh <fubar@us.ibm.com>
Date:   Wed Oct 17 17:37:50 2007 -0700

    bonding: Convert more locks to _bh, acquire rtnl, for new locking
    
    	Convert more lock acquisitions to _bh flavor to avoid deadlock
    with workqueue activity and add acquisition of RTNL in appropriate places.
    Affects ALB mode, as well as core bonding functions and sysfs.
    
    Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
    Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>


--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1846,9 +1846,9 @@ int bond_release(struct net_device *bond
 */
 void bond_destroy(struct bonding *bond)
 {
+	unregister_netdevice(bond->dev);
 	bond_deinit(bond->dev);
 	bond_destroy_sysfs_entry(bond);
-	unregister_netdevice(bond->dev);
 }

.
.
.

@@ -4473,8 +4473,8 @@ static void bond_free_all(void)
 		bond_mc_list_destroy(bond);
 		/* Release the bonded slaves */
 		bond_release_all(bond_dev);
-		bond_deinit(bond_dev);
 		unregister_netdevice(bond_dev);
+		bond_deinit(bond_dev);
 	}
 
 

