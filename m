From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] vlan: remove one synchronize_net() call
Date: Mon, 09 May 2011 16:40:44 +0200
Message-ID: <1304952044.3342.42.camel@edumazet-laptop>
References: <1304948155.3342.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Jesse Gross <jesse@nicira.com>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:40462 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753780Ab1EIOks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 10:40:48 -0400
Received: by eyx24 with SMTP id 24so1558538eyx.19
        for <netdev@vger.kernel.org>; Mon, 09 May 2011 07:40:47 -0700 (PDT)
In-Reply-To: <1304948155.3342.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At VLAN dismantle phase, unregister_vlan_dev() makes one
synchronize_net() call after vlan_group_set_device(grp, vlan_id, NULL).

This call can be safely removed because we are calling
unregister_netdevice_queue() to queue device for deletion, and this
process needs at least one rcu grace period to complete.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Ben Greear <greearb@candelatech.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Jesse Gross <jesse@nicira.com>
Cc: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 include/linux/if_vlan.h |    1 -
 net/8021q/vlan.c        |   10 ++++------
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 546d9d3..290bd8a 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -86,7 +86,6 @@ struct vlan_group {
 					    * the vlan is attached to.
 					    */
 	unsigned int		nr_vlans;
-	int			killall;
 	struct hlist_node	hlist;	/* linked list */
 	struct net_device **vlan_devices_arrays[VLAN_GROUP_ARRAY_SPLIT_PARTS]=
;
 	struct rcu_head		rcu;
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 969e700..718d635d 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -120,9 +120,10 @@ void unregister_vlan_dev(struct net_device *dev, s=
truct list_head *head)
 	grp->nr_vlans--;
=20
 	vlan_group_set_device(grp, vlan_id, NULL);
-	if (!grp->killall)
-		synchronize_net();
-
+	/* Because unregister_netdevice_queue() makes sure at least one rcu
+	 * grace period is respected before device freeing,
+	 * we dont need to call synchronize_net() here.
+	 */
 	unregister_netdevice_queue(dev, head);
=20
 	/* If the group is now empty, kill off the group. */
@@ -478,9 +479,6 @@ static int vlan_device_event(struct notifier_block =
*unused, unsigned long event,
 		if (dev->reg_state !=3D NETREG_UNREGISTERING)
 			break;
=20
-		/* Delete all VLANs for this dev. */
-		grp->killall =3D 1;
-
 		for (i =3D 0; i < VLAN_N_VID; i++) {
 			vlandev =3D vlan_group_get_device(grp, i);
 			if (!vlandev)


