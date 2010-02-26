From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 8/13] bridge: Add multicast start/stop hooks
Date: Fri, 26 Feb 2010 23:35:13 +0800
Message-ID: <E1Nl2Dh-0006w8-Gl@gondolin.me.apana.org.au>
References: <20100226153410.GA26419@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52523 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965125Ab0BZPfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 10:35:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bridge: Add multicast start/stop hooks

This patch hooks up the bridge start/stop and add/delete/disable
port functions to the new multicast module.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/bridge/br_device.c |    6 +++++-
 net/bridge/br_if.c     |    4 ++++
 net/bridge/br_stp.c    |    2 ++
 net/bridge/br_stp_if.c |    1 +
 4 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index be35629..91dffe7 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -51,6 +51,7 @@ static int br_dev_open(struct net_device *dev)
 	br_features_recompute(br);
 	netif_start_queue(dev);
 	br_stp_enable_bridge(br);
+	br_multicast_open(br);
 
 	return 0;
 }
@@ -61,7 +62,10 @@ static void br_dev_set_multicast_list(struct net_device *dev)
 
 static int br_dev_stop(struct net_device *dev)
 {
-	br_stp_disable_bridge(netdev_priv(dev));
+	struct net_bridge *br = netdev_priv(dev);
+
+	br_stp_disable_bridge(br);
+	br_multicast_stop(br);
 
 	netif_stop_queue(dev);
 
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index a2cbe61..cc3cdfd 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -147,6 +147,8 @@ static void del_nbp(struct net_bridge_port *p)
 
 	rcu_assign_pointer(dev->br_port, NULL);
 
+	br_multicast_del_port(p);
+
 	kobject_uevent(&p->kobj, KOBJ_REMOVE);
 	kobject_del(&p->kobj);
 
@@ -209,6 +211,7 @@ static struct net_device *new_bridge_dev(struct net *net, const char *name)
 	INIT_LIST_HEAD(&br->age_list);
 
 	br_stp_timer_init(br);
+	br_multicast_init(br);
 
 	return dev;
 }
@@ -260,6 +263,7 @@ static struct net_bridge_port *new_nbp(struct net_bridge *br,
 	br_init_port(p);
 	p->state = BR_STATE_DISABLED;
 	br_stp_port_timer_init(p);
+	br_multicast_add_port(p);
 
 	return p;
 }
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index fd3f8d6..edcf14b 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -386,6 +386,8 @@ static void br_make_forwarding(struct net_bridge_port *p)
 	else
 		p->state = BR_STATE_LEARNING;
 
+	br_multicast_enable_port(p);
+
 	br_log_state(p);
 
 	if (br->forward_delay != 0)
diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 9a52ac5..d527119 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -108,6 +108,7 @@ void br_stp_disable_port(struct net_bridge_port *p)
 	del_timer(&p->hold_timer);
 
 	br_fdb_delete_by_port(br, p, 0);
+	br_multicast_disable_port(p);
 
 	br_configuration_update(br);
 
