From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 1/2] net: move and rename netif_notify_peers()
Date: Fri, 10 Aug 2012 16:14:56 +0800
Message-ID: <1344586497-2702-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13668 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756532Ab2HJIPS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2012 04:15:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I believe net/core/dev.c is a better place for netif_notify_peers(),
because other net event notify functions also stay in this file.

And rename it to netdev_notify_peers().

Cc: David S. Miller <davem@davemloft.net>
Cc: Ian Campbell <Ian.Campbell@citrix.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 drivers/net/hyperv/netvsc_drv.c |    2 +-
 drivers/net/virtio_net.c        |    2 +-
 drivers/net/xen-netfront.c      |    2 +-
 include/linux/netdevice.h       |    3 +--
 net/core/dev.c                  |   18 ++++++++++++++++++
 net/sched/sch_generic.c         |   18 ------------------
 6 files changed, 22 insertions(+), 23 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 8c5a1c4..e91111a 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -400,7 +400,7 @@ static void netvsc_send_garp(struct work_struct *w)
 	ndev_ctx = container_of(w, struct net_device_context, dwork.work);
 	net_device = hv_get_drvdata(ndev_ctx->device_ctx);
 	net = net_device->ndev;
-	netif_notify_peers(net);
+	netdev_notify_peers(net);
 }
 
 
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 83d2b0c..81a64c5 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -993,7 +993,7 @@ static void virtnet_config_changed_work(struct work_struct *work)
 		goto done;
 
 	if (v & VIRTIO_NET_S_ANNOUNCE) {
-		netif_notify_peers(vi->dev);
+		netdev_notify_peers(vi->dev);
 		virtnet_ack_link_announce(vi);
 	}
 
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 3089990..39afd37 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1731,7 +1731,7 @@ static void netback_changed(struct xenbus_device *dev,
 		break;
 
 	case XenbusStateConnected:
-		netif_notify_peers(netdev);
+		netdev_notify_peers(netdev);
 		break;
 
 	case XenbusStateClosing:
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a9db4f3..8d4b731 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2246,8 +2246,6 @@ extern void netif_carrier_on(struct net_device *dev);
 
 extern void netif_carrier_off(struct net_device *dev);
 
-extern void netif_notify_peers(struct net_device *dev);
-
 /**
  *	netif_dormant_on - mark device as dormant.
  *	@dev: network device
@@ -2596,6 +2594,7 @@ extern void		__dev_set_rx_mode(struct net_device *dev);
 extern int		dev_set_promiscuity(struct net_device *dev, int inc);
 extern int		dev_set_allmulti(struct net_device *dev, int inc);
 extern void		netdev_state_change(struct net_device *dev);
+extern void		netdev_notify_peers(struct net_device *dev);
 extern int		netdev_bonding_change(struct net_device *dev,
 					      unsigned long event);
 extern void		netdev_features_change(struct net_device *dev);
diff --git a/net/core/dev.c b/net/core/dev.c
index a39354e..1eb9636 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1109,6 +1109,24 @@ void netdev_state_change(struct net_device *dev)
 }
 EXPORT_SYMBOL(netdev_state_change);
 
+/**
+ * 	netdev_notify_peers - notify network peers about existence of @dev
+ * 	@dev: network device
+ *
+ * Generate traffic such that interested network peers are aware of
+ * @dev, such as by generating a gratuitous ARP. This may be used when
+ * a device wants to inform the rest of the network about some sort of
+ * reconfiguration such as a failover event or virtual machine
+ * migration.
+ */
+void netdev_notify_peers(struct net_device *dev)
+{
+	rtnl_lock();
+	call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, dev);
+	rtnl_unlock();
+}
+EXPORT_SYMBOL(netdev_notify_peers);
+
 int netdev_bonding_change(struct net_device *dev, unsigned long event)
 {
 	return call_netdevice_notifiers(event, dev);
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 511323e..6c4d5fe 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -324,24 +324,6 @@ void netif_carrier_off(struct net_device *dev)
 }
 EXPORT_SYMBOL(netif_carrier_off);
 
-/**
- * 	netif_notify_peers - notify network peers about existence of @dev
- * 	@dev: network device
- *
- * Generate traffic such that interested network peers are aware of
- * @dev, such as by generating a gratuitous ARP. This may be used when
- * a device wants to inform the rest of the network about some sort of
- * reconfiguration such as a failover event or virtual machine
- * migration.
- */
-void netif_notify_peers(struct net_device *dev)
-{
-	rtnl_lock();
-	call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, dev);
-	rtnl_unlock();
-}
-EXPORT_SYMBOL(netif_notify_peers);
-
 /* "NOOP" scheduler: the best scheduler, recommended for all interfaces
    under all circumstances. It is difficult to invent anything faster or
    cheaper.
-- 
1.7.7.6
