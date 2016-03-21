From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net 2/2] bridge: update max_gso_segs and max_gso_size
Date: Mon, 21 Mar 2016 09:55:11 -0700
Message-ID: <1458579311-17699-3-git-send-email-edumazet@google.com>
References: <1458579311-17699-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Petri Gynther <pgynther@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33336 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757019AbcCUQzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 12:55:20 -0400
Received: by mail-pf0-f178.google.com with SMTP id 4so140036518pfd.0
        for <netdev@vger.kernel.org>; Mon, 21 Mar 2016 09:55:20 -0700 (PDT)
In-Reply-To: <1458579311-17699-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It can be useful to lower max_gso_segs on NIC with very low
number of TX descriptors like bcmgenet.

However, this is defeated by bridge since it does not propagate
the lower value of max_gso_segs and max_gso_size.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Petri Gynther <pgynther@google.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
---
 net/bridge/br_if.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index a73df3315df9..8217aecf025b 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -437,6 +437,20 @@ int br_min_mtu(const struct net_bridge *br)
 	return mtu;
 }
 
+static void br_set_gso_limits(struct net_bridge *br)
+{
+	unsigned int gso_max_size = GSO_MAX_SIZE;
+	u16 gso_max_segs = GSO_MAX_SEGS;
+	const struct net_bridge_port *p;
+
+	list_for_each_entry(p, &br->port_list, list) {
+		gso_max_size = min(gso_max_size, p->dev->gso_max_size);
+		gso_max_segs = min(gso_max_segs, p->dev->gso_max_segs);
+	}
+	br->dev->gso_max_size = gso_max_size;
+	br->dev->gso_max_segs = gso_max_segs;
+}
+
 /*
  * Recomputes features using slave's features
  */
@@ -564,6 +578,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, br->dev);
 
 	dev_set_mtu(br->dev, br_min_mtu(br));
+	br_set_gso_limits(br);
 
 	kobject_uevent(&p->kobj, KOBJ_ADD);
 
@@ -610,6 +625,7 @@ int br_del_if(struct net_bridge *br, struct net_device *dev)
 	del_nbp(p);
 
 	dev_set_mtu(br->dev, br_min_mtu(br));
+	br_set_gso_limits(br);
 
 	spin_lock_bh(&br->lock);
 	changed_addr = br_stp_recalculate_bridge_id(br);
-- 
2.8.0.rc3.226.g39d4020
