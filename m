From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 7/7] openvswitch: Use RCU callback when detaching netdevices.
Date: Thu, 29 Nov 2012 10:35:49 -0800
Message-ID: <1354214149-33651-8-git-send-email-jesse@nicira.com>
References: <1354214149-33651-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Justin Pettit <jpettit@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog128.obsmtp.com ([74.125.149.141]:37567 "HELO
	na3sys009aog128.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754590Ab2K2SgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 13:36:06 -0500
Received: by mail-pb0-f70.google.com with SMTP id ro2so16813605pbb.1
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 10:36:06 -0800 (PST)
In-Reply-To: <1354214149-33651-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, each time a device is detached from an OVS datapath
we call synchronize RCU before freeing associated data structures.
However, if a bridge is deleted (which detaches all ports) when
many devices are connected then there can be a long delay.  This
switches to use call_rcu() to group the cost together.

Reported-by: Justin Pettit <jpettit@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/vport-netdev.c |   14 ++++++++++----
 net/openvswitch/vport-netdev.h |    3 +++
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index a903348..a9327e2 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -114,6 +114,15 @@ error:
 	return ERR_PTR(err);
 }
 
+static void free_port_rcu(struct rcu_head *rcu)
+{
+	struct netdev_vport *netdev_vport = container_of(rcu,
+					struct netdev_vport, rcu);
+
+	dev_put(netdev_vport->dev);
+	ovs_vport_free(vport_from_priv(netdev_vport));
+}
+
 static void netdev_destroy(struct vport *vport)
 {
 	struct netdev_vport *netdev_vport = netdev_vport_priv(vport);
@@ -122,10 +131,7 @@ static void netdev_destroy(struct vport *vport)
 	netdev_rx_handler_unregister(netdev_vport->dev);
 	dev_set_promiscuity(netdev_vport->dev, -1);
 
-	synchronize_rcu();
-
-	dev_put(netdev_vport->dev);
-	ovs_vport_free(vport);
+	call_rcu(&netdev_vport->rcu, free_port_rcu);
 }
 
 const char *ovs_netdev_get_name(const struct vport *vport)
diff --git a/net/openvswitch/vport-netdev.h b/net/openvswitch/vport-netdev.h
index f7072a2..6478079 100644
--- a/net/openvswitch/vport-netdev.h
+++ b/net/openvswitch/vport-netdev.h
@@ -20,12 +20,15 @@
 #define VPORT_NETDEV_H 1
 
 #include <linux/netdevice.h>
+#include <linux/rcupdate.h>
 
 #include "vport.h"
 
 struct vport *ovs_netdev_get_vport(struct net_device *dev);
 
 struct netdev_vport {
+	struct rcu_head rcu;
+
 	struct net_device *dev;
 };
 
-- 
1.7.9.5
