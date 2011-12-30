From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] bonding: fix error handling if slave is busy
Date: Fri, 30 Dec 2011 14:40:23 -0800
Message-ID: <20111230144023.371be015@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35240 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751939Ab1L3Wk0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Dec 2011 17:40:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bonding device can cause kernel panic in the enslave error handling.

If slave device already has a receive handler registered, then the
error unwind does not clear the new entry out of the slave list.
This ends up leaving a reference to freed memory in the bond
device slave linked list.

The following is a simple example:
# modprobe dummy
# ip li add dummy0-1 link dummy0 type macvlan
# modprobe bonding
# echo +dummy0 >/sys/class/net/bond0/bonding/slaves
# ip -s li show dev bond0

This returns with -EBUSY, but the bonding device has bogus entry in
the slave list, and will panic on next operation that gets statistics
from bond0.

The fix is to detach the slave (which removes it from the list)
in the unwind path.


Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Patch is against net-next but should be applied to net (3.2), and
stable (3.1 and 3.0).

--- a/drivers/net/bonding/bond_main.c	2011-12-30 14:20:03.171823181 -0800
+++ b/drivers/net/bonding/bond_main.c	2011-12-30 14:20:20.232020474 -0800
@@ -1853,6 +1853,9 @@ err_dest_symlinks:
 	bond_destroy_slave_symlinks(bond_dev, slave_dev);
 
 err_close:
+	write_lock_bh(&bond->lock);
+	bond_detach_slave(bond, new_slave);
+	write_unlock_bh(&bond->lock);
 	dev_close(slave_dev);
 
 err_unset_master:
