From: jamal <hadi@cyberus.ca>
Subject: [RFC/PATCH][Bonding]: keep slave state when admin down
Date: Thu, 20 Jul 2006 09:19:16 -0400
Message-ID: <1153401556.5098.43.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-fj0MxAgA1jxixXy0u0RA"
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:5532 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S964874AbWGTNTV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jul 2006 09:19:21 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1G3YR1-0006et-AU
	for netdev@vger.kernel.org; Thu, 20 Jul 2006 09:19:23 -0400
To: Jay Vosburgh <fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-fj0MxAgA1jxixXy0u0RA
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


When a bonding netdevice is admin-ed down it looses the slaves
attributes (set via ifenslave). This is not consistent with other
behavior of netdevices (example a qdisc attached to a netdevice doesnt
disappear or an attached IP address etc).
The included patch fixes this. Ive tested by ifenslaving, downing the
bond, checking /proc and making sure it still has the slaves, up-ing the
bond and making sure things continue to work.

Jay/Bonding folks if you are ok with it, just ACK it or include it in
your tree etc. Otherwise we can discuss. This is against linus tree.

cheers,
jamal

--=-fj0MxAgA1jxixXy0u0RA
Content-Disposition: attachment; filename=bond_p2
Content-Type: text/x-patch; name=bond_p2; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 8b95123..df319be 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3420,7 +3420,6 @@ static int bond_close(struct net_device 
 
 	write_lock_bh(&bond->lock);
 
-	bond_mc_list_destroy(bond);
 
 	/* signal timers not to re-arm */
 	bond->kill_timers = 1;
@@ -3451,8 +3450,6 @@ static int bond_close(struct net_device 
 		break;
 	}
 
-	/* Release the bonded slaves */
-	bond_release_all(bond_dev);
 
 	if ((bond->params.mode == BOND_MODE_TLB) ||
 	    (bond->params.mode == BOND_MODE_ALB)) {
@@ -4237,6 +4234,9 @@ static void bond_free_all(void)
 	list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list) {
 		struct net_device *bond_dev = bond->dev;
 
+		bond_mc_list_destroy(bond);
+		/* Release the bonded slaves */
+		bond_release_all(bond_dev);
 		unregister_netdevice(bond_dev);
 		bond_deinit(bond_dev);
 	}

--=-fj0MxAgA1jxixXy0u0RA--

