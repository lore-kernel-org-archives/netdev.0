From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH REPOST 7/10] bonding: Don't release slaves when master is admin down
Date: Fri, 22 Sep 2006 21:54:37 -0700
Message-ID: <200609230454.k8N4sbZt028904@death.nxdomain.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:49317 "EHLO e4.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1750997AbWIWEyk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2006 00:54:40 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8N4sder032625
	for <netdev@vger.kernel.org>; Sat, 23 Sep 2006 00:54:39 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8N4sdEm286864
	for <netdev@vger.kernel.org>; Sat, 23 Sep 2006 00:54:39 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8N4sciw015555
	for <netdev@vger.kernel.org>; Sat, 23 Sep 2006 00:54:39 -0400
To: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



From: jamal <hadi@cyberus.ca>

When a bonding netdevice is admin-ed down it loses the slaves
attributes (set via ifenslave). This is not consistent with other
behavior of netdevices (example a qdisc attached to a netdevice doesnt
disappear or an attached IP address etc).
The included patch fixes this. Ive tested by ifenslaving, downing the
bond, checking /proc and making sure it still has the slaves, up-ing the
bond and making sure things continue to work.

Jay/Bonding folks if you are ok with it, just ACK it or include it in
your tree etc. Otherwise we can discuss.


Acked-by: Jay Vosburgh <fubar@us.ibm.com>


--- netdev-2.6.git-upstream/drivers/net/bonding/bond_main.c	2006/08/26 17:24:41	1.5
+++ netdev-2.6.git-upstream/drivers/net/bonding/bond_main.c	2006/08/26 18:21:39	1.6
@@ -3430,7 +3430,6 @@ static int bond_close(struct net_device 
 
 	write_lock_bh(&bond->lock);
 
-	bond_mc_list_destroy(bond);
 
 	/* signal timers not to re-arm */
 	bond->kill_timers = 1;
@@ -3461,8 +3460,6 @@ static int bond_close(struct net_device 
 		break;
 	}
 
-	/* Release the bonded slaves */
-	bond_release_all(bond_dev);
 
 	if ((bond->params.mode == BOND_MODE_TLB) ||
 	    (bond->params.mode == BOND_MODE_ALB)) {
@@ -4248,6 +4245,9 @@ static void bond_free_all(void)
 	list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list) {
 		struct net_device *bond_dev = bond->dev;
 
+		bond_mc_list_destroy(bond);
+		/* Release the bonded slaves */
+		bond_release_all(bond_dev);
 		unregister_netdevice(bond_dev);
 		bond_deinit(bond_dev);
 	}

