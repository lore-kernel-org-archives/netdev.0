From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH v2 net] rocker: handle non-bridge master change
Date: Tue, 24 Mar 2015 09:31:40 +0900
Message-ID: <1427157100-18828-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:32905 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751935AbbCXAbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 20:31:53 -0400
Received: by pabxg6 with SMTP id xg6so194823513pab.0
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 17:31:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Master change notifications may occur other than when joining or
leaving a bridge, for example when being added to or removed from
a bond or Open vSwitch.

Previously in those cases rocker_port_bridge_leave() was called
which results in a null-pointer dereference as rocker_port->bridge_dev
is NULL because there is no bridge device.

This patch makes provision for doing nothing in such cases.

Fixes: 6c7079450071f ("rocker: implement L2 bridge offloading")
Acked-by: Jiri Pirko <jiri@resnulli.us>
Acked-by: Scott Feldman <sfeldma@gmail.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>

---
* Lightly tested to the extent that a null-pointer dereference no longer
  occurs

v2
* Use rocker_port_is_bridged()
* Added Acks
---
 drivers/net/ethernet/rocker/rocker.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 9fb6948..5cecec2 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4468,10 +4468,16 @@ static int rocker_port_master_changed(struct net_device *dev)
 	struct net_device *master = netdev_master_upper_dev_get(dev);
 	int err = 0;
 
+	/* There are currently three cases handled here:
+	 * 1. Joining a bridge
+	 * 2. Leaving a previously joined bridge
+	 * 3. Other, e.g. being added to or removed from a bond or openvswitch,
+	 *    in which case nothing is done
+	 */
 	if (master && master->rtnl_link_ops &&
 	    !strcmp(master->rtnl_link_ops->kind, "bridge"))
 		err = rocker_port_bridge_join(rocker_port, master);
-	else
+	else if (rocker_port_is_bridged(rocker_port))
 		err = rocker_port_bridge_leave(rocker_port);
 
 	return err;
-- 
2.1.4
