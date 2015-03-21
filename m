From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v6] switchdev: fix stp update API to work with layered netdevices
Date: Sat, 21 Mar 2015 10:27:28 -0700
Message-ID: <1426958848-2781-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, sfeldma@gmail.com, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:36752 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751474AbbCUR1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 13:27:34 -0400
Received: by pdbcz9 with SMTP id cz9so140041050pdb.3
        for <netdev@vger.kernel.org>; Sat, 21 Mar 2015 10:27:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

make it same as the netdev_switch_port_bridge_setlink/dellink
api (ie traverse lowerdevs to get to the switch port).

removes "WARN_ON(!ops->ndo_switch_parent_id_get)" because
direct bridge ports can be stacked netdevices (like bonds
and team of switch ports) which may not implement this ndo.

v2 to v3:
	- remove changes to bond and team. Bring back the
	transparently following lowerdevs like i initially
	had for setlink/getlink
	(http://www.spinics.net/lists/netdev/msg313436.html)
	dave and scott feldman also seem to prefer it be that
	way and move to non-transparent way of doing things
	if we see a problem down the lane.

v3 to v4:
	- fix ret initialization

v4 to v5:
	- return err on first failure (scott feldman)

v5 to v6:
	- change variable name (err) and initialize to
	-EOPNOTSUPP (scott feldman).

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/switchdev/switchdev.c |   17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index c9bfa00..46568b8 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -47,11 +47,20 @@ EXPORT_SYMBOL_GPL(netdev_switch_parent_id_get);
 int netdev_switch_port_stp_update(struct net_device *dev, u8 state)
 {
 	const struct swdev_ops *ops = dev->swdev_ops;
+	struct net_device *lower_dev;
+	struct list_head *iter;
+	int err = -EOPNOTSUPP;
 
-	if (!ops || !ops->swdev_port_stp_update)
-		return -EOPNOTSUPP;
-	WARN_ON(!ops->swdev_parent_id_get);
-	return ops->swdev_port_stp_update(dev, state);
+	if (ops && ops->swdev_port_stp_update)
+		return ops->swdev_port_stp_update(dev, state);
+
+	netdev_for_each_lower_dev(dev, lower_dev, iter) {
+		err = netdev_switch_port_stp_update(lower_dev, state);
+		if (err && err != -EOPNOTSUPP)
+			return err;
+	}
+
+	return err;
 }
 EXPORT_SYMBOL_GPL(netdev_switch_port_stp_update);
 
-- 
1.7.10.4
