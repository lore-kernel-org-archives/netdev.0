From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 1/8] bridge: Propagate vlan add failure to user
Date: Wed,  6 Jan 2016 13:01:04 +0100
Message-ID: <1452081671-8476-2-git-send-email-jiri@resnulli.us>
References: <1452081671-8476-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:33963 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752231AbcAFMBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 07:01:15 -0500
Received: by mail-wm0-f52.google.com with SMTP id u188so57538321wmu.1
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 04:01:15 -0800 (PST)
In-Reply-To: <1452081671-8476-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

Disallow adding interfaces to a bridge when vlan filtering operation
failed. Send the failure code to the user.

Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
v1->v2: set err to return value of nbp_vlan_init
---
 net/bridge/br_if.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 8d1d4a2..c367b3e 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -511,8 +511,11 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	if (br_fdb_insert(br, p, dev->dev_addr, 0))
 		netdev_err(dev, "failed insert local address bridge forwarding table\n");
 
-	if (nbp_vlan_init(p))
+	err = nbp_vlan_init(p);
+	if (err) {
 		netdev_err(dev, "failed to initialize vlan filtering on this port\n");
+		goto err6;
+	}
 
 	spin_lock_bh(&br->lock);
 	changed_addr = br_stp_recalculate_bridge_id(br);
@@ -533,6 +536,12 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 
 	return 0;
 
+err6:
+	list_del_rcu(&p->list);
+	br_fdb_delete_by_port(br, p, 0, 1);
+	nbp_update_port_count(br);
+	netdev_upper_dev_unlink(dev, br->dev);
+
 err5:
 	dev->priv_flags &= ~IFF_BRIDGE_PORT;
 	netdev_rx_handler_unregister(dev);
-- 
1.9.3
