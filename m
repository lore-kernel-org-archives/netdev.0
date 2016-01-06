From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/8] bridge: Propagate vlan add failure to user
Date: Wed,  6 Jan 2016 11:11:49 +0100
Message-ID: <1452075116-5726-2-git-send-email-jiri@resnulli.us>
References: <1452075116-5726-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:34430 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752276AbcAFKMB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 05:12:01 -0500
Received: by mail-wm0-f53.google.com with SMTP id u188so54429973wmu.1
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 02:12:00 -0800 (PST)
In-Reply-To: <1452075116-5726-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

Disallow adding interfaces to a bridge when vlan filtering operation
failed. Send the failure code to the user.

Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/bridge/br_if.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 8d1d4a2..3bd46f4 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -511,8 +511,10 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	if (br_fdb_insert(br, p, dev->dev_addr, 0))
 		netdev_err(dev, "failed insert local address bridge forwarding table\n");
 
-	if (nbp_vlan_init(p))
+	if (nbp_vlan_init(p)) {
 		netdev_err(dev, "failed to initialize vlan filtering on this port\n");
+		goto err6;
+	}
 
 	spin_lock_bh(&br->lock);
 	changed_addr = br_stp_recalculate_bridge_id(br);
@@ -533,6 +535,12 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 
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
