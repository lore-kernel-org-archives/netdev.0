From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 3/4] bonding: Deadlock between bonding_store_bonds and bond_destroy_sysfs.
Date: Fri,  2 May 2008 17:49:39 -0700
Message-ID: <12097757842821-git-send-email-fubar@us.ibm.com>
References: <12097757801056-git-send-email-fubar@us.ibm.com>
 <12097757822222-git-send-email-fubar@us.ibm.com>
 <12097757832778-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, Pavel Emelyanov <xemul@openvz.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:47065 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765401AbYECAtt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 May 2008 20:49:49 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m430njfE012011
	for <netdev@vger.kernel.org>; Fri, 2 May 2008 20:49:45 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m430njrT257422
	for <netdev@vger.kernel.org>; Fri, 2 May 2008 20:49:45 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m430nigj010520
	for <netdev@vger.kernel.org>; Fri, 2 May 2008 20:49:45 -0400
In-Reply-To: <12097757832778-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>

The sysfs layer has an internal protection, that ensures, that
all the process sitting inside ->sore/->show callback exits
before the appropriate entry is unregistered (the calltraces
are rather big, but I can provide them if required).

On the other hand, bonding takes rtnl_lock in
a) the bonding_store_bonds, i.e. in ->store callback,
b) module exit before calling the sysfs unregister routines.

Thus, the classical AB-BA deadlock may occur. To reproduce run
# while :; do modprobe bonding; rmmod bonding; done
and
# while :; do echo '+bond%d' > /sys/class/net/bonding_masters ; done
in parallel.

The fix is to move the bond_destroy_sysfs out of the rtnl_lock,
but _before_ bond_free_all to make sure no bonding devices exist
after module unload.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 7ffd819..3977760 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4995,9 +4995,10 @@ err:
 		destroy_workqueue(bond->wq);
 	}
 
+	bond_destroy_sysfs();
+
 	rtnl_lock();
 	bond_free_all();
-	bond_destroy_sysfs();
 	rtnl_unlock();
 out:
 	return res;
@@ -5009,9 +5010,10 @@ static void __exit bonding_exit(void)
 	unregister_netdevice_notifier(&bond_netdev_notifier);
 	unregister_inetaddr_notifier(&bond_inetaddr_notifier);
 
+	bond_destroy_sysfs();
+
 	rtnl_lock();
 	bond_free_all();
-	bond_destroy_sysfs();
 	rtnl_unlock();
 }
 
-- 
1.5.2.4

