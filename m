From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: 2.6.27.18: bnx2/tg3: BUG: "scheduling while atomic" trying toifenslave a second interface to my bond
Date: Mon, 04 May 2009 12:03:37 -0700
Message-ID: <4086.1241463817@death.nxdomain.ibm.com>
References: <1239657348.8944.529.camel@psmith-ubeta.netezza.com> <1241397581.6499.658.camel@homebase.localnet>
Cc: Linux netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: paul@mad-scientist.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:60515 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753108AbZEDTDd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2009 15:03:33 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e9.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n44IqWBb007055
	for <netdev@vger.kernel.org>; Mon, 4 May 2009 14:52:32 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n44J3XUN143450
	for <netdev@vger.kernel.org>; Mon, 4 May 2009 15:03:33 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n44J3Xbq022669
	for <netdev@vger.kernel.org>; Mon, 4 May 2009 15:03:33 -0400
In-reply-to: <1241397581.6499.658.camel@homebase.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Smith <paul@mad-scientist.net> wrote:

>Hi Jay/David/etc.;
>
>This patch is critical for me to properly use mode 6 (balance-alb)
>bonding; I assume it will be needed for others as well.  I haven't
>checked to see if it's still necessary in 2.6.29/2.6.30, but I didn't
>notice it going into the latest 2.6.27.22, released today.
>
>Is this still unofficial?  Is there an official patch on the horizon?

	David, please apply and queue for -stable:

Subject: [PATCH] bonding: fix alb mode locking regression 

	Fix locking issue in alb MAC address management; removed
incorrect locking and replaced with correct locking.  This bug was
introduced in commit:

commit 059fe7a578fba5bbb0fdc0365bfcf6218fa25eb0
Author: Jay Vosburgh <fubar@us.ibm.com>
Date:   Wed Oct 17 17:37:49 2007 -0700

    bonding: Convert locks to _bh, rework alb locking for new locking

	Bug reported by Paul Smith <paul@mad-scientist.net>, who also
tested the fix.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 553a899..46d312b 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1706,10 +1706,8 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
  * Called with RTNL
  */
 int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
-	__releases(&bond->curr_slave_lock)
-	__releases(&bond->lock)
 	__acquires(&bond->lock)
-	__acquires(&bond->curr_slave_lock)
+	__releases(&bond->lock)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct sockaddr *sa = addr;
@@ -1745,9 +1743,6 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 		}
 	}
 
-	write_unlock_bh(&bond->curr_slave_lock);
-	read_unlock(&bond->lock);
-
 	if (swap_slave) {
 		alb_swap_mac_addr(bond, swap_slave, bond->curr_active_slave);
 		alb_fasten_mac_swap(bond, swap_slave, bond->curr_active_slave);
@@ -1755,16 +1750,15 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 		alb_set_slave_mac_addr(bond->curr_active_slave, bond_dev->dev_addr,
 				       bond->alb_info.rlb_enabled);
 
+		read_lock(&bond->lock);
 		alb_send_learning_packets(bond->curr_active_slave, bond_dev->dev_addr);
 		if (bond->alb_info.rlb_enabled) {
 			/* inform clients mac address has changed */
 			rlb_req_update_slave_clients(bond, bond->curr_active_slave);
 		}
+		read_unlock(&bond->lock);
 	}
 
-	read_lock(&bond->lock);
-	write_lock_bh(&bond->curr_slave_lock);
-
 	return 0;
 }
 


