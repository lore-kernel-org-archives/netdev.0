From: David Lamparter <equinox@diac24.net>
Subject: [PATCH RFC] netns: keep vlan slaves on master netns move
Date: Tue, 24 Aug 2010 13:50:56 +0200
Message-ID: <20100824115056.GA235835@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:34404 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751375Ab0HXLvD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Aug 2010 07:51:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everyone,

attached patch makes it possible to keep macvlan / 802.1q slave devices
on moving their master to a different namespace. as the opposite works
without problems (moving the slaves into a different namespace), this
shouldn't cause problems either.

i've tested this with 802.1q on real ethernet devs and bridges and,
well, it works without crashing, but that obviously doesn't mean it is
correct :) - therefore input very welcome.

RFC,

David

P.S.: who do i Cc: on netns related stuff?

--
previously, if a vlan master device was moved from one network namespace
to another, all 802.1q and macvlan slaves were deleted.

we can use dev->reg_state to figure out whether dev_change_net_namespace
is happening, since that won't set dev->reg_state NETREG_UNREGISTERING.
so, this changes 8021q and macvlan to ignore NETDEV_UNREGISTER when
reg_state is not NETREG_UNREGISTERING.

Signed-off-by: David Lamparter <equinox@diac24.net>
---
 drivers/net/macvlan.c |    4 ++++
 net/8021q/vlan.c      |    4 ++++
 net/core/dev.c        |    4 ++++
 3 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index f15fe2c..f43f8e4 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -754,6 +754,10 @@ static int macvlan_device_event(struct notifier_block *unused,
 		}
 		break;
 	case NETDEV_UNREGISTER:
+		/* twiddle thumbs on netns device moves */
+		if (dev->reg_state != NETREG_UNREGISTERING)
+			break;
+
 		list_for_each_entry_safe(vlan, next, &port->vlans, list)
 			vlan->dev->rtnl_link_ops->dellink(vlan->dev, NULL);
 		break;
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 3c1c8c1..cdc37e8 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -516,6 +516,10 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		break;
 
 	case NETDEV_UNREGISTER:
+		/* twiddle thumbs on netns device moves */
+		if (dev->reg_state != NETREG_UNREGISTERING)
+			break;
+
 		/* Delete all VLANs for this dev. */
 		grp->killall = 1;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 1f466e8..b1589bc 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5618,6 +5618,10 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 
 	/* Notify protocols, that we are about to destroy
 	   this device. They should clean all the things.
+
+	   Note that dev->reg_state stays at NETREG_REGISTERED.
+	   This is wanted because this way 8021q and macvlan know
+	   the device is just moving and can keep their slaves up.
 	*/
 	call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
 	call_netdevice_notifiers(NETDEV_UNREGISTER_BATCH, dev);
-- 
1.7.0.4

