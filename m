From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 4/8] bridge: add vlan filtering change for new bridged device
Date: Wed,  6 Jan 2016 13:01:07 +0100
Message-ID: <1452081671-8476-5-git-send-email-jiri@resnulli.us>
References: <1452081671-8476-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:34019 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752359AbcAFMBT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 07:01:19 -0500
Received: by mail-wm0-f48.google.com with SMTP id u188so57540260wmu.1
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 04:01:18 -0800 (PST)
In-Reply-To: <1452081671-8476-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

Notifying hardware about newly bridged port vlan-aware changes.

Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/bridge/br_vlan.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 190fb33..85e43af 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -907,6 +907,12 @@ err_rhtbl:
 
 int nbp_vlan_init(struct net_bridge_port *p)
 {
+	struct switchdev_attr attr = {
+		.orig_dev = p->br->dev,
+		.id = SWITCHDEV_ATTR_ID_BRIDGE_VLAN_FILTERING,
+		.flags = SWITCHDEV_F_SKIP_EOPNOTSUPP,
+		.u.vlan_filtering = p->br->vlan_enabled,
+	};
 	struct net_bridge_vlan_group *vg;
 	int ret = -ENOMEM;
 
@@ -914,6 +920,10 @@ int nbp_vlan_init(struct net_bridge_port *p)
 	if (!vg)
 		goto out;
 
+	ret = switchdev_port_attr_set(p->dev, &attr);
+	if (ret && ret != -EOPNOTSUPP)
+		goto err_vlan_enabled;
+
 	ret = rhashtable_init(&vg->vlan_hash, &br_vlan_rht_params);
 	if (ret)
 		goto err_rhtbl;
@@ -933,6 +943,7 @@ err_vlan_add:
 	RCU_INIT_POINTER(p->vlgrp, NULL);
 	synchronize_rcu();
 	rhashtable_destroy(&vg->vlan_hash);
+err_vlan_enabled:
 err_rhtbl:
 	kfree(vg);
 
-- 
1.9.3
