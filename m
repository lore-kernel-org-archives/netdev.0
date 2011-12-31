From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] bonding: fix error handling if slave is busy (v2)
Date: Sat, 31 Dec 2011 15:26:46 -0800
Message-ID: <20111231152646.6f0f98fc@nehalam.linuxnetplumber.net>
References: <20111230144023.371be015@nehalam.linuxnetplumber.net>
	<4EFF3419.4050504@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Nicolas de =?ISO-8859-1?B?UGVzbG/8YW4=?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43423 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753251Ab1LaX0y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Dec 2011 18:26:54 -0500
In-Reply-To: <4EFF3419.4050504@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If slave device already has a receive handler registered, then the
error unwind of bonding device enslave function is broken. 

The following will leave a pointer to freed memory in the slave
device list, causing a later kernel panic.
# modprobe dummy
# ip li add dummy0-1 link dummy0 type macvlan
# modprobe bonding
# echo +dummy0 >/sys/class/net/bond0/bonding/slaves

The fix is to detach the slave (which removes it from the list)
in the unwind path.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
v2 - need to keep original err_close for other unwind

--- a/drivers/net/bonding/bond_main.c	2011-12-30 14:20:03.171823181 -0800
+++ b/drivers/net/bonding/bond_main.c	2011-12-31 15:20:16.493379415 -0800
@@ -1822,7 +1822,7 @@ int bond_enslave(struct net_device *bond
 				 "but new slave device does not support netpoll.\n",
 				 bond_dev->name);
 			res = -EBUSY;
-			goto err_close;
+			goto err_detach;
 		}
 	}
 #endif
@@ -1831,7 +1831,7 @@ int bond_enslave(struct net_device *bond
 
 	res = bond_create_slave_symlinks(bond_dev, slave_dev);
 	if (res)
-		goto err_close;
+		goto err_detach;
 
 	res = netdev_rx_handler_register(slave_dev, bond_handle_frame,
 					 new_slave);
@@ -1852,6 +1852,11 @@ int bond_enslave(struct net_device *bond
 err_dest_symlinks:
 	bond_destroy_slave_symlinks(bond_dev, slave_dev);
 
+err_detach:
+	write_lock_bh(&bond->lock);
+	bond_detach_slave(bond, new_slave);
+	write_unlock_bh(&bond->lock);
+
 err_close:
 	dev_close(slave_dev);
 
