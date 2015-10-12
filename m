From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 7/7] switchdev: assert rtnl mutex when going over lower netdevs
Date: Mon, 12 Oct 2015 15:15:10 +0200
Message-ID: <1444655710-8279-8-git-send-email-jiri@resnulli.us>
References: <1444655710-8279-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:36360 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752315AbbJLNPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 09:15:23 -0400
Received: by wicgb1 with SMTP id gb1so148643240wic.1
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 06:15:22 -0700 (PDT)
In-Reply-To: <1444655710-8279-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

netdev_for_each_lower_dev has to be called with rtnl mutex held. So
better enforce it in switchdev functions.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/switchdev/switchdev.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 5d0d731..11e0291 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -494,6 +494,8 @@ EXPORT_SYMBOL_GPL(switchdev_port_obj_del);
  *	@id: object ID
  *	@obj: object to dump
  *	@cb: function to call with a filled object
+ *
+ *	rtnl_lock must be held.
  */
 int switchdev_port_obj_dump(struct net_device *dev, struct switchdev_obj *obj,
 			    switchdev_obj_dump_cb_t *cb)
@@ -503,6 +505,8 @@ int switchdev_port_obj_dump(struct net_device *dev, struct switchdev_obj *obj,
 	struct list_head *iter;
 	int err = -EOPNOTSUPP;
 
+	ASSERT_RTNL();
+
 	if (ops && ops->switchdev_port_obj_dump)
 		return ops->switchdev_port_obj_dump(dev, obj, cb);
 
@@ -1068,6 +1072,8 @@ static struct net_device *switchdev_get_dev_by_nhs(struct fib_info *fi)
 	struct net_device *dev = NULL;
 	int nhsel;
 
+	ASSERT_RTNL();
+
 	/* For this route, all nexthop devs must be on the same switch. */
 
 	for (nhsel = 0; nhsel < fi->fib_nhs; nhsel++) {
@@ -1298,10 +1304,11 @@ void switchdev_port_fwd_mark_set(struct net_device *dev,
 	u32 mark = dev->ifindex;
 	u32 reset_mark = 0;
 
-	if (group_dev && joining) {
-		mark = switchdev_port_fwd_mark_get(dev, group_dev);
-	} else if (group_dev && !joining) {
-		if (dev->offload_fwd_mark == mark)
+	if (group_dev) {
+		ASSERT_RTNL();
+		if (joining)
+			mark = switchdev_port_fwd_mark_get(dev, group_dev);
+		else if (dev->offload_fwd_mark == mark)
 			/* Ohoh, this port was the mark reference port,
 			 * but it's leaving the group, so reset the
 			 * mark for the remaining ports in the group.
-- 
1.9.3
