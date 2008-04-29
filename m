From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 8/8][BONDING]: Deadlock between bonding_store_bonds and bond_destroy_sysfs.
Date: Tue, 29 Apr 2008 19:11:48 +0400
Message-ID: <48173AB4.4080009@openvz.org>
References: <481735F4.30909@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:42017 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751497AbYD2Pto (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 11:49:44 -0400
In-Reply-To: <481735F4.30909@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

---
 drivers/net/bonding/bond_main.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 4d852ab..7e7b0b8 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4984,9 +4984,10 @@ err:
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
@@ -4998,9 +4999,10 @@ static void __exit bonding_exit(void)
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
1.5.3.4

