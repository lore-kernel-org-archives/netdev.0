From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 5/5] bridge: add RCU annotations to bridge port lookup
Date: Mon, 15 Nov 2010 08:38:14 -0800
Message-ID: <20101115163828.520584677@vyatta.com>
References: <20101115163809.215552143@vyatta.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:38458 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757880Ab0KOQlo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Nov 2010 11:41:44 -0500
Content-Disposition: inline; filename=bridge-port_get_rtnl.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

br_port_get() renamed to br_port_get_rtnl() to make clear RTNL is held.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/bridge/br_if.c      |    2 +-
 net/bridge/br_netlink.c |    4 ++--
 net/bridge/br_notify.c  |    4 ++--
 net/bridge/br_private.h |    9 +++++----
 4 files changed, 10 insertions(+), 9 deletions(-)

--- a/net/bridge/br_netlink.c	2010-11-15 08:25:50.049646467 -0800
+++ b/net/bridge/br_netlink.c	2010-11-15 08:27:57.772866001 -0800
@@ -119,7 +119,7 @@ static int br_dump_ifinfo(struct sk_buff
 
 	idx = 0;
 	for_each_netdev(net, dev) {
-		struct net_bridge_port *port = br_port_get(dev);
+		struct net_bridge_port *port = br_port_get_rtnl(dev);
 
 		/* not a bridge port */
 		if (!port || idx < cb->args[0])
@@ -171,7 +171,7 @@ static int br_rtm_setlink(struct sk_buff
 	if (!dev)
 		return -ENODEV;
 
-	p = br_port_get(dev);
+	p = br_port_get_rtnl(dev);
 	if (!p)
 		return -EINVAL;
 
--- a/net/bridge/br_private.h	2010-11-15 08:27:46.747612478 -0800
+++ b/net/bridge/br_private.h	2010-11-15 08:27:57.776866451 -0800
@@ -159,9 +159,10 @@ static inline struct net_bridge_port *br
 	return br_port_exists(dev) ? port : NULL;
 }
 
-static inline struct net_bridge_port *br_port_get(struct net_device *dev)
+static inline struct net_bridge_port *br_port_get_rtnl(struct net_device *dev)
 {
-	return br_port_exists(dev) ? dev->rx_handler_data : NULL;
+	return br_port_exists(dev) ?
+		rtnl_dereference(dev->rx_handler_data) : NULL;
 }
 
 struct br_cpu_netstats {
--- a/net/bridge/br_if.c	2010-11-15 08:25:50.049646467 -0800
+++ b/net/bridge/br_if.c	2010-11-15 08:27:57.776866451 -0800
@@ -475,7 +475,7 @@ int br_del_if(struct net_bridge *br, str
 {
 	struct net_bridge_port *p;
 
-	p = br_port_get(dev);
+	p = br_port_get_rtnl(dev);
 	if (!p || p->br != br)
 		return -EINVAL;
 
--- a/net/bridge/br_notify.c	2010-11-15 08:25:50.045645976 -0800
+++ b/net/bridge/br_notify.c	2010-11-15 08:27:57.780866901 -0800
@@ -37,10 +37,10 @@ static int br_device_event(struct notifi
 	int err;
 
 	/* not a port of a bridge */
-	if (!br_port_exists(dev))
+	p = br_port_get_rtnl(dev);
+	if (!p)
 		return NOTIFY_DONE;
 
-	p = br_port_get(dev);
 	br = p->br;
 
 	switch (event) {


