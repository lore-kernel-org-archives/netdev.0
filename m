From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 4/5] bridge: vlan: fix possible null ptr derefs on port init and deinit
Date: Wed, 30 Sep 2015 20:16:54 +0200
Message-ID: <1443637015-4153-5-git-send-email-razor@blackwall.org>
References: <1443637015-4153-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, vyasevich@gmail.com,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:32965 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933175AbbI3SRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 14:17:04 -0400
Received: by wiclk2 with SMTP id lk2so211169634wic.0
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 11:17:03 -0700 (PDT)
In-Reply-To: <1443637015-4153-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

When a new port is being added we need to make vlgrp available after
rhashtable has been initialized and when removing a port we need to
flush the vlans and free the resources after we're sure noone can use
the port, i.e. after it's removed from the port list and synchronize_rcu
is executed.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_if.c   |  3 ++-
 net/bridge/br_vlan.c | 16 ++++++++++------
 2 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 45e4757c6fd2..934cae9fa317 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -248,7 +248,6 @@ static void del_nbp(struct net_bridge_port *p)
 
 	list_del_rcu(&p->list);
 
-	nbp_vlan_flush(p);
 	br_fdb_delete_by_port(br, p, 0, 1);
 	nbp_update_port_count(br);
 
@@ -257,6 +256,8 @@ static void del_nbp(struct net_bridge_port *p)
 	dev->priv_flags &= ~IFF_BRIDGE_PORT;
 
 	netdev_rx_handler_unregister(dev);
+	/* use the synchronize_rcu done by netdev_rx_handler_unregister */
+	nbp_vlan_flush(p);
 
 	br_multicast_del_port(p);
 
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 90ac4b0c55c1..7e9d60a402e2 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -854,16 +854,20 @@ err_rhtbl:
 
 int nbp_vlan_init(struct net_bridge_port *p)
 {
+	struct net_bridge_vlan_group *vg;
 	int ret = -ENOMEM;
 
-	p->vlgrp = kzalloc(sizeof(struct net_bridge_vlan_group), GFP_KERNEL);
-	if (!p->vlgrp)
+	vg = kzalloc(sizeof(struct net_bridge_vlan_group), GFP_KERNEL);
+	if (!vg)
 		goto out;
 
-	ret = rhashtable_init(&p->vlgrp->vlan_hash, &br_vlan_rht_params);
+	ret = rhashtable_init(&vg->vlan_hash, &br_vlan_rht_params);
 	if (ret)
 		goto err_rhtbl;
-	INIT_LIST_HEAD(&p->vlgrp->vlan_list);
+	INIT_LIST_HEAD(&vg->vlan_list);
+	/* Make sure everything's committed before publishing vg */
+	smp_wmb();
+	p->vlgrp = vg;
 	if (p->br->default_pvid) {
 		ret = nbp_vlan_add(p, p->br->default_pvid,
 				   BRIDGE_VLAN_INFO_PVID |
@@ -875,9 +879,9 @@ out:
 	return ret;
 
 err_vlan_add:
-	rhashtable_destroy(&p->vlgrp->vlan_hash);
+	rhashtable_destroy(&vg->vlan_hash);
 err_rhtbl:
-	kfree(p->vlgrp);
+	kfree(vg);
 
 	goto out;
 }
-- 
2.4.3
