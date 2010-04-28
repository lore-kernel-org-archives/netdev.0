From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 6/7] caif: Bugfixes in CAIF netdevice for close
 and flow control
Date: Wed, 28 Apr 2010 20:54:39 +0200
Message-ID: <1272480880-30672-6-git-send-email-sjur.brandeland@stericsson.com>
References: <1272480880-30672-1-git-send-email-sjur.brandeland@stericsson.com>
 <1272480880-30672-2-git-send-email-sjur.brandeland@stericsson.com>
 <1272480880-30672-3-git-send-email-sjur.brandeland@stericsson.com>
 <1272480880-30672-4-git-send-email-sjur.brandeland@stericsson.com>
 <1272480880-30672-5-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: marcel@holtmann.org, daniel.martensson@stericsson.com,
	sjurbr@gmail.com, linus.walleij@stericsson.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eterpe-smout.broadpark.no ([80.202.8.16]:35420 "EHLO
	eterpe-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756460Ab0D1Szc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 14:55:32 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by eterpe-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L1L00K4COKEDG80@eterpe-smout.broadpark.no> for
 netdev@vger.kernel.org; Wed, 28 Apr 2010 20:55:26 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L1L00MYUOK4Q560@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Wed, 28 Apr 2010 20:55:26 +0200 (CEST)
In-reply-to: <1272480880-30672-5-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Changes:
o Bugfix: Flow control was causing the device to be destroyed.
o Bugfix: Handle CAIF channel connect failures.
o If the underlying link layer is gone the net-device is no longer removed,
  but closed.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 net/caif/chnl_net.c |  130 ++++++++++++++++++++++++++++----------------------
 1 files changed, 73 insertions(+), 57 deletions(-)

diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index f622ff1..610966a 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -22,10 +22,10 @@
 #include <net/caif/cfpkt.h>
 #include <net/caif/caif_dev.h>
 
-#define CAIF_CONNECT_TIMEOUT 30
+/* GPRS PDP connection has MTU to 1500 */
 #define SIZE_MTU 1500
-#define SIZE_MTU_MAX 4080
-#define SIZE_MTU_MIN 68
+/* 5 sec. connect timeout */
+#define CONNECT_TIMEOUT (5 * HZ)
 #define CAIF_NET_DEFAULT_QUEUE_LEN 500
 
 #undef pr_debug
@@ -37,6 +37,13 @@ static LIST_HEAD(chnl_net_list);
 MODULE_LICENSE("GPL");
 MODULE_ALIAS_RTNL_LINK("caif");
 
+enum caif_states {
+	CAIF_CONNECTED		= 1,
+	CAIF_CONNECTING,
+	CAIF_DISCONNECTED,
+	CAIF_SHUTDOWN
+};
+
 struct chnl_net {
 	struct cflayer chnl;
 	struct net_device_stats stats;
@@ -47,7 +54,7 @@ struct chnl_net {
 	wait_queue_head_t netmgmt_wq;
 	/* Flow status to remember and control the transmission. */
 	bool flowenabled;
-	bool pending_close;
+	enum caif_states state;
 };
 
 static void robust_list_del(struct list_head *delete_node)
@@ -58,15 +65,16 @@ static void robust_list_del(struct list_head *delete_node)
 	list_for_each_safe(list_node, n, &chnl_net_list) {
 		if (list_node == delete_node) {
 			list_del(list_node);
-			break;
+			return;
 		}
 	}
+	WARN_ON(1);
 }
 
 static int chnl_recv_cb(struct cflayer *layr, struct cfpkt *pkt)
 {
 	struct sk_buff *skb;
-	struct chnl_net *priv  = NULL;
+	struct chnl_net *priv  = container_of(layr, struct chnl_net, chnl);
 	int pktlen;
 	int err = 0;
 
@@ -91,7 +99,6 @@ static int chnl_recv_cb(struct cflayer *layr, struct cfpkt *pkt)
 	else
 		skb->ip_summed = CHECKSUM_NONE;
 
-	/* FIXME: Drivers should call this in tasklet context. */
 	if (in_interrupt())
 		netif_rx(skb);
 	else
@@ -117,23 +124,25 @@ static void close_work(struct work_struct *work)
 	struct chnl_net *dev = NULL;
 	struct list_head *list_node;
 	struct list_head *_tmp;
-	rtnl_lock();
+	/* May be called with or without RTNL lock held */
+	int islocked = rtnl_is_locked();
+	if (!islocked)
+		rtnl_lock();
 	list_for_each_safe(list_node, _tmp, &chnl_net_list) {
 		dev = list_entry(list_node, struct chnl_net, list_field);
-		if (!dev->pending_close)
-			continue;
-		list_del(list_node);
-		delete_device(dev);
+		if (dev->state == CAIF_SHUTDOWN)
+			dev_close(dev->netdev);
 	}
-	rtnl_unlock();
+	if (!islocked)
+		rtnl_unlock();
 }
 static DECLARE_WORK(close_worker, close_work);
 
 static void chnl_flowctrl_cb(struct cflayer *layr, enum caif_ctrlcmd flow,
 				int phyid)
 {
-	struct chnl_net *priv;
-	pr_debug("CAIF: %s(): NET flowctrl func called flow: %s.\n",
+	struct chnl_net *priv = container_of(layr, struct chnl_net, chnl);
+	pr_debug("CAIF: %s(): NET flowctrl func called flow: %s\n",
 		__func__,
 		flow == CAIF_CTRLCMD_FLOW_ON_IND ? "ON" :
 		flow == CAIF_CTRLCMD_INIT_RSP ? "INIT" :
@@ -143,21 +152,31 @@ static void chnl_flowctrl_cb(struct cflayer *layr, enum caif_ctrlcmd flow,
 		flow == CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND ?
 		 "REMOTE_SHUTDOWN" : "UKNOWN CTRL COMMAND");
 
-	priv = container_of(layr, struct chnl_net, chnl);
+
 
 	switch (flow) {
 	case CAIF_CTRLCMD_FLOW_OFF_IND:
+		priv->flowenabled = false;
+		netif_stop_queue(priv->netdev);
+		break;
 	case CAIF_CTRLCMD_DEINIT_RSP:
+		priv->state = CAIF_DISCONNECTED;
+		break;
 	case CAIF_CTRLCMD_INIT_FAIL_RSP:
+		priv->state = CAIF_DISCONNECTED;
+		wake_up_interruptible(&priv->netmgmt_wq);
+		break;
 	case CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND:
-		priv->flowenabled = false;
+		priv->state = CAIF_SHUTDOWN;
 		netif_tx_disable(priv->netdev);
-		pr_warning("CAIF: %s(): done\n", __func__);
-		priv->pending_close = 1;
 		schedule_work(&close_worker);
 		break;
 	case CAIF_CTRLCMD_FLOW_ON_IND:
+		priv->flowenabled = true;
+		netif_wake_queue(priv->netdev);
+		break;
 	case CAIF_CTRLCMD_INIT_RSP:
+		priv->state = CAIF_CONNECTED;
 		priv->flowenabled = true;
 		netif_wake_queue(priv->netdev);
 		wake_up_interruptible(&priv->netmgmt_wq);
@@ -194,9 +213,6 @@ static int chnl_net_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	pkt = cfpkt_fromnative(CAIF_DIR_OUT, (void *) skb);
 
-	pr_debug("CAIF: %s(): transmit inst %s %d,%p\n",
-		__func__, dev->name, priv->chnl.dn->id, &priv->chnl.dn);
-
 	/* Send the packet down the stack. */
 	result = priv->chnl.dn->transmit(priv->chnl.dn, pkt);
 	if (result) {
@@ -217,61 +233,59 @@ static int chnl_net_open(struct net_device *dev)
 	struct chnl_net *priv = NULL;
 	int result = -1;
 	ASSERT_RTNL();
-
 	priv = netdev_priv(dev);
-	pr_debug("CAIF: %s(): dev name: %s\n", __func__, priv->name);
-
 	if (!priv) {
 		pr_debug("CAIF: %s(): chnl_net_open: no priv\n", __func__);
 		return -ENODEV;
 	}
-	result = caif_connect_client(&priv->conn_req, &priv->chnl);
-	if (result != 0) {
-		pr_debug("CAIF: %s(): err: "
-			 "Unable to register and open device, Err:%d\n",
-			__func__,
-			result);
-		return -ENODEV;
+
+	if (priv->state != CAIF_CONNECTING) {
+		priv->state = CAIF_CONNECTING;
+		result = caif_connect_client(&priv->conn_req, &priv->chnl);
+		if (result != 0) {
+				priv->state = CAIF_DISCONNECTED;
+				pr_debug("CAIF: %s(): err: "
+					"Unable to register and open device,"
+					" Err:%d\n",
+					__func__,
+					result);
+				return result;
+		}
 	}
-	result = wait_event_interruptible(priv->netmgmt_wq, priv->flowenabled);
+
+	result = wait_event_interruptible_timeout(priv->netmgmt_wq,
+						priv->state != CAIF_CONNECTING,
+						CONNECT_TIMEOUT);
 
 	if (result == -ERESTARTSYS) {
 		pr_debug("CAIF: %s(): wait_event_interruptible"
 			 " woken by a signal\n", __func__);
 		return -ERESTARTSYS;
-	} else
-		pr_debug("CAIF: %s(): Flow on recieved\n", __func__);
+	}
+	if (result == 0) {
+		pr_debug("CAIF: %s(): connect timeout\n", __func__);
+		caif_disconnect_client(&priv->chnl);
+		priv->state = CAIF_DISCONNECTED;
+		pr_debug("CAIF: %s(): state disconnected\n", __func__);
+		return -ETIMEDOUT;
+	}
 
+	if (priv->state != CAIF_CONNECTED) {
+		pr_debug("CAIF: %s(): connect failed\n", __func__);
+		return -ECONNREFUSED;
+	}
+	pr_debug("CAIF: %s(): CAIF Netdevice connected\n", __func__);
 	return 0;
 }
 
 static int chnl_net_stop(struct net_device *dev)
 {
 	struct chnl_net *priv;
-	int result = -1;
+
 	ASSERT_RTNL();
 	priv = netdev_priv(dev);
-
-	result = caif_disconnect_client(&priv->chnl);
-	if (result != 0) {
-		pr_debug("CAIF: %s(): chnl_net_stop: err: "
-			 "Unable to STOP device, Err:%d\n",
-			 __func__, result);
-		return -EBUSY;
-	}
-	result = wait_event_interruptible(priv->netmgmt_wq,
-					  !priv->flowenabled);
-
-	if (result == -ERESTARTSYS) {
-		pr_debug("CAIF: %s(): wait_event_interruptible woken by"
-			 " signal, signal_pending(current) = %d\n",
-			 __func__,
-			 signal_pending(current));
-	} else {
-		pr_debug("CAIF: %s(): disconnect received\n", __func__);
-
-	}
-
+	priv->state = CAIF_DISCONNECTED;
+	caif_disconnect_client(&priv->chnl);
 	return 0;
 }
 
@@ -377,6 +391,8 @@ static int ipcaif_newlink(struct net *src_net, struct net_device *dev,
 	ASSERT_RTNL();
 	caifdev = netdev_priv(dev);
 	caif_netlink_parms(data, &caifdev->conn_req);
+	dev_net_set(caifdev->netdev, src_net);
+
 	ret = register_netdevice(dev);
 	if (ret)
 		pr_warning("CAIF: %s(): device rtml registration failed\n",
-- 
1.6.3.3

