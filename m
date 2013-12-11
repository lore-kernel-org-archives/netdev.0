From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 5/7] tipc: relocate common functions from media to bearer
Date: Tue, 10 Dec 2013 20:45:42 -0800
Message-ID: <1386737144-32334-6-git-send-email-jon.maloy@ericsson.com>
References: <1386737144-32334-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Patrick McHardy <kaber@trash.net>,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.ne1.yahoo.com ([98.138.207.11]:45391 "HELO
	smtp104.biz.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751491Ab3LKEq2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 23:46:28 -0500
In-Reply-To: <1386737144-32334-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

Currently, registering a TIPC stack handler in the network device layer
is done twice, once for Ethernet (eth_media) and Infiniband (ib_media)
repectively. But, as this registration is not media specific, we can
avoid some code duplication by moving the registering function to
the generic bearer layer, to the file bearer.c, and call it only once.
The same is true for the network device event notifier.

As a side effect, the two workqueues we are using for for setting up/
cleaning up media can now be eliminated. Furthermore, the array for
storing the specific media type structs, media_array[], can be entirely
deleted.

Note that the eth_started and ib_started flags were removed during the
code relocation.  There is now only one call to bearer_setup and
bearer_cleanup, and these can logically not race against each other.

Despite its size, this cleanup work incurs no functional changes in TIPC.
In particular, it should be noted that the sequence ordering of received
packets is unaffected by this change, since packet reception never was
subject to any work queue handling in the first place.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bearer.c    |  105 +++++++++++++++++++++++++-
 net/tipc/bearer.h    |   11 +--
 net/tipc/core.c      |    8 +-
 net/tipc/eth_media.c |  199 +-------------------------------------------------
 net/tipc/ib_media.c  |  192 +-----------------------------------------------
 5 files changed, 114 insertions(+), 401 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 2411bac..e95e0b9 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -367,7 +367,7 @@ exit:
 /**
  * tipc_reset_bearer - Reset all links established over this bearer
  */
-int tipc_reset_bearer(struct tipc_bearer *b_ptr)
+static int tipc_reset_bearer(struct tipc_bearer *b_ptr)
 {
 	struct tipc_link *l_ptr;
 	struct tipc_link *temp_l_ptr;
@@ -432,7 +432,110 @@ int tipc_disable_bearer(const char *name)
 	return res;
 }
 
+/**
+ * tipc_l2_rcv_msg - handle incoming TIPC message from an interface
+ * @buf: the received packet
+ * @dev: the net device that the packet was received on
+ * @pt: the packet_type structure which was used to register this handler
+ * @orig_dev: the original receive net device in case the device is a bond
+ *
+ * Accept only packets explicitly sent to this node, or broadcast packets;
+ * ignores packets sent using interface multicast, and traffic sent to other
+ * nodes (which can happen if interface is running in promiscuous mode).
+ */
+static int tipc_l2_rcv_msg(struct sk_buff *buf, struct net_device *dev,
+			   struct packet_type *pt, struct net_device *orig_dev)
+{
+	struct tipc_bearer *b_ptr;
+
+	if (!net_eq(dev_net(dev), &init_net)) {
+		kfree_skb(buf);
+		return NET_RX_DROP;
+	}
+
+	rcu_read_lock();
+	b_ptr = rcu_dereference(dev->tipc_ptr);
+	if (likely(b_ptr)) {
+		if (likely(buf->pkt_type <= PACKET_BROADCAST)) {
+			buf->next = NULL;
+			tipc_recv_msg(buf, b_ptr);
+			rcu_read_unlock();
+			return NET_RX_SUCCESS;
+		}
+	}
+	rcu_read_unlock();
+
+	kfree_skb(buf);
+	return NET_RX_DROP;
+}
+
+/**
+ * tipc_l2_device_event - handle device events from network device
+ * @nb: the context of the notification
+ * @evt: the type of event
+ * @ptr: the net device that the event was on
+ *
+ * This function is called by the Ethernet driver in case of link
+ * change event.
+ */
+static int tipc_l2_device_event(struct notifier_block *nb, unsigned long evt,
+				void *ptr)
+{
+	struct tipc_bearer *b_ptr;
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 
+	if (!net_eq(dev_net(dev), &init_net))
+		return NOTIFY_DONE;
+
+	rcu_read_lock();
+	b_ptr = rcu_dereference(dev->tipc_ptr);
+	if (!b_ptr) {
+		rcu_read_unlock();
+		return NOTIFY_DONE;
+	}
+
+	b_ptr->mtu = dev->mtu;
+
+	switch (evt) {
+	case NETDEV_CHANGE:
+		if (netif_carrier_ok(dev))
+			break;
+	case NETDEV_DOWN:
+	case NETDEV_CHANGEMTU:
+	case NETDEV_CHANGEADDR:
+		tipc_reset_bearer(b_ptr);
+		break;
+	case NETDEV_UNREGISTER:
+	case NETDEV_CHANGENAME:
+		tipc_disable_bearer(b_ptr->name);
+		break;
+	}
+	rcu_read_unlock();
+
+	return NOTIFY_OK;
+}
+
+static struct packet_type tipc_packet_type __read_mostly = {
+	.type = __constant_htons(ETH_P_TIPC),
+	.func = tipc_l2_rcv_msg,
+};
+
+static struct notifier_block notifier = {
+	.notifier_call  = tipc_l2_device_event,
+	.priority	= 0,
+};
+
+int tipc_bearer_setup(void)
+{
+	dev_add_pack(&tipc_packet_type);
+	return register_netdevice_notifier(&notifier);
+}
+
+void tipc_bearer_cleanup(void)
+{
+	unregister_netdevice_notifier(&notifier);
+	dev_remove_pack(&tipc_packet_type);
+}
 
 void tipc_bearer_stop(void)
 {
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 91b8d8b..0974c2f 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -162,25 +162,16 @@ extern struct tipc_bearer tipc_bearers[];
 
 void tipc_recv_msg(struct sk_buff *buf, struct tipc_bearer *tb_ptr);
 
-int  tipc_reset_bearer(struct tipc_bearer *b_ptr);
-
 int tipc_enable_bearer(const char *bearer_name, u32 disc_domain, u32 priority);
 int tipc_disable_bearer(const char *name);
 
 /*
  * Routines made available to TIPC by supported media types
  */
-int  tipc_eth_media_start(void);
-void tipc_eth_media_stop(void);
 extern struct tipc_media eth_media_info;
 
 #ifdef CONFIG_TIPC_MEDIA_IB
-int  tipc_ib_media_start(void);
-void tipc_ib_media_stop(void);
 extern struct tipc_media ib_media_info;
-#else
-static inline int tipc_ib_media_start(void) { return 0; }
-static inline void tipc_ib_media_stop(void) { return; }
 #endif
 
 int tipc_media_set_priority(const char *name, u32 new_value);
@@ -194,6 +185,8 @@ void tipc_bearer_remove_dest(struct tipc_bearer *b_ptr, u32 dest);
 struct tipc_bearer *tipc_bearer_find(const char *name);
 struct tipc_bearer *tipc_bearer_find_interface(const char *if_name);
 struct tipc_media *tipc_media_find(const char *name);
+int tipc_bearer_setup(void);
+void tipc_bearer_cleanup(void);
 void tipc_bearer_stop(void);
 
 /**
diff --git a/net/tipc/core.c b/net/tipc/core.c
index c6d3f75..f9e88d8 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -82,8 +82,7 @@ struct sk_buff *tipc_buf_acquire(u32 size)
 static void tipc_core_stop_net(void)
 {
 	tipc_net_stop();
-	tipc_eth_media_stop();
-	tipc_ib_media_stop();
+	tipc_bearer_cleanup();
 }
 
 /**
@@ -94,10 +93,7 @@ int tipc_core_start_net(unsigned long addr)
 	int res;
 
 	tipc_net_start(addr);
-	res = tipc_eth_media_start();
-	if (res < 0)
-		goto err;
-	res = tipc_ib_media_start();
+	res = tipc_bearer_setup();
 	if (res < 0)
 		goto err;
 	return res;
diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index c5f685d..f28f716 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -37,49 +37,9 @@
 #include "core.h"
 #include "bearer.h"
 
-#define MAX_ETH_MEDIA		MAX_BEARERS
-
 #define ETH_ADDR_OFFSET	4	/* message header offset of MAC address */
 
 /**
- * struct eth_media - Ethernet bearer data structure
- * @bearer: ptr to associated "generic" bearer structure
- * @dev: ptr to associated Ethernet network device
- * @tipc_packet_type: used in binding TIPC to Ethernet driver
- * @setup: work item used when enabling bearer
- * @cleanup: work item used when disabling bearer
- */
-struct eth_media {
-	struct tipc_bearer *bearer;
-	struct net_device *dev;
-	struct packet_type tipc_packet_type;
-	struct work_struct setup;
-	struct work_struct cleanup;
-};
-
-
-static struct eth_media eth_media_array[MAX_ETH_MEDIA];
-static int eth_started;
-
-static int recv_notification(struct notifier_block *nb, unsigned long evt,
-			     void *dv);
-static int recv_msg(struct sk_buff *buf, struct net_device *dev,
-		    struct packet_type *pt, struct net_device *orig_dev);
-
-/*
- * Network device notifier info
- */
-static struct notifier_block notifier = {
-	.notifier_call	= recv_notification,
-	.priority	= 0
-};
-
-static struct packet_type tipc_packet_type __read_mostly = {
-	.type = __constant_htons(ETH_P_TIPC),
-	.func = recv_msg,
-};
-
-/**
  * eth_media_addr_set - initialize Ethernet media address structure
  *
  * Media-dependent "value" field stores MAC address in first 6 bytes
@@ -101,16 +61,14 @@ static int send_msg(struct sk_buff *buf, struct tipc_bearer *tb_ptr,
 		    struct tipc_media_addr *dest)
 {
 	struct sk_buff *clone;
-	struct net_device *dev;
 	int delta;
+	struct net_device *dev = tb_ptr->dev;
 
 	clone = skb_clone(buf, GFP_ATOMIC);
 	if (!clone)
 		return 0;
 
-	dev = ((struct eth_media *)(tb_ptr->usr_handle))->dev;
 	delta = dev->hard_header_len - skb_headroom(buf);
-
 	if ((delta > 0) &&
 	    pskb_expand_head(clone, SKB_DATA_ALIGN(delta), 0, GFP_ATOMIC)) {
 		kfree_skb(clone);
@@ -127,79 +85,21 @@ static int send_msg(struct sk_buff *buf, struct tipc_bearer *tb_ptr,
 }
 
 /**
- * recv_msg - handle incoming TIPC message from an Ethernet interface
- *
- * Accept only packets explicitly sent to this node, or broadcast packets;
- * ignores packets sent using Ethernet multicast, and traffic sent to other
- * nodes (which can happen if interface is running in promiscuous mode).
- */
-static int recv_msg(struct sk_buff *buf, struct net_device *dev,
-		    struct packet_type *pt, struct net_device *orig_dev)
-{
-	struct tipc_bearer *b_ptr;
-
-	if (!net_eq(dev_net(dev), &init_net)) {
-		kfree_skb(buf);
-		return NET_RX_DROP;
-	}
-
-	rcu_read_lock();
-	b_ptr = rcu_dereference(dev->tipc_ptr);
-	if (likely(b_ptr)) {
-		if (likely(buf->pkt_type <= PACKET_BROADCAST)) {
-			buf->next = NULL;
-			tipc_recv_msg(buf, b_ptr);
-			rcu_read_unlock();
-			return NET_RX_SUCCESS;
-		}
-	}
-	rcu_read_unlock();
-
-	kfree_skb(buf);
-	return NET_RX_DROP;
-}
-
-/**
- * setup_media - setup association between Ethernet bearer and interface
- */
-static void setup_media(struct work_struct *work)
-{
-	dev_add_pack(&tipc_packet_type);
-}
-
-/**
  * enable_media - attach TIPC bearer to an Ethernet interface
  */
 static int enable_media(struct tipc_bearer *tb_ptr)
 {
 	struct net_device *dev;
-	struct eth_media *eb_ptr = &eth_media_array[0];
-	struct eth_media *stop = &eth_media_array[MAX_ETH_MEDIA];
 	char *driver_name = strchr((const char *)tb_ptr->name, ':') + 1;
-	int pending_dev = 0;
-
-	/* Find unused Ethernet bearer structure */
-	while (eb_ptr->dev) {
-		if (!eb_ptr->bearer)
-			pending_dev++;
-		if (++eb_ptr == stop)
-			return pending_dev ? -EAGAIN : -EDQUOT;
-	}
 
 	/* Find device with specified name */
 	dev = dev_get_by_name(&init_net, driver_name);
 	if (!dev)
 		return -ENODEV;
 
-	/* Create Ethernet bearer for device */
-	eb_ptr->dev = dev;
-	INIT_WORK(&eb_ptr->setup, setup_media);
-	schedule_work(&eb_ptr->setup);
-
 	/* Associate TIPC bearer with Ethernet bearer */
 	tb_ptr->dev = dev;
-	eb_ptr->bearer = tb_ptr;
-	tb_ptr->usr_handle = (void *)eb_ptr;
+	tb_ptr->usr_handle = NULL;
 	memset(tb_ptr->bcast_addr.value, 0, sizeof(tb_ptr->bcast_addr.value));
 	memcpy(tb_ptr->bcast_addr.value, dev->broadcast, ETH_ALEN);
 	tb_ptr->bcast_addr.media_id = TIPC_MEDIA_TYPE_ETH;
@@ -211,21 +111,6 @@ static int enable_media(struct tipc_bearer *tb_ptr)
 }
 
 /**
- * cleanup_media - break association between Ethernet bearer and interface
- *
- * This routine must be invoked from a work queue because it can sleep.
- */
-static void cleanup_media(struct work_struct *work)
-{
-	struct eth_media *eb_ptr =
-		container_of(work, struct eth_media, cleanup);
-
-	dev_remove_pack(&tipc_packet_type);
-	dev_put(eb_ptr->dev);
-	eb_ptr->dev = NULL;
-}
-
-/**
  * disable_media - detach TIPC bearer from an Ethernet interface
  *
  * Mark Ethernet bearer as inactive so that incoming buffers are thrown away,
@@ -234,55 +119,8 @@ static void cleanup_media(struct work_struct *work)
  */
 static void disable_media(struct tipc_bearer *tb_ptr)
 {
-	struct eth_media *eb_ptr = (struct eth_media *)tb_ptr->usr_handle;
-
-	eb_ptr->bearer = NULL;
-	INIT_WORK(&eb_ptr->cleanup, cleanup_media);
-	schedule_work(&eb_ptr->cleanup);
 	RCU_INIT_POINTER(tb_ptr->dev->tipc_ptr, NULL);
-}
-
-/**
- * recv_notification - handle device updates from OS
- *
- * Change the state of the Ethernet bearer (if any) associated with the
- * specified device.
- */
-static int recv_notification(struct notifier_block *nb, unsigned long evt,
-			     void *ptr)
-{
-	struct tipc_bearer *b_ptr;
-	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
-
-	if (!net_eq(dev_net(dev), &init_net))
-		return NOTIFY_DONE;
-
-	rcu_read_lock();
-	b_ptr = rcu_dereference(dev->tipc_ptr);
-	if (!b_ptr) {
-		rcu_read_unlock();
-		return NOTIFY_DONE;		/* bearer had been disabled */
-	}
-
-	b_ptr->mtu = dev->mtu;
-
-	switch (evt) {
-	case NETDEV_CHANGE:
-		if (netif_carrier_ok(dev))
-			break;
-	case NETDEV_DOWN:
-	case NETDEV_CHANGEMTU:
-	case NETDEV_CHANGEADDR:
-		tipc_reset_bearer(b_ptr);
-		break;
-	case NETDEV_UNREGISTER:
-	case NETDEV_CHANGENAME:
-		tipc_disable_bearer(b_ptr->name);
-		break;
-	}
-	rcu_read_unlock();
-
-	return NOTIFY_OK;
+	dev_put(tb_ptr->dev);
 }
 
 /**
@@ -338,34 +176,3 @@ struct tipc_media eth_media_info = {
 	.name		= "eth"
 };
 
-/**
- * tipc_eth_media_start - activate Ethernet bearer support
- *
- * Register Ethernet media type with TIPC bearer code.  Also register
- * with OS for notifications about device state changes.
- */
-int tipc_eth_media_start(void)
-{
-	int res;
-
-	if (eth_started)
-		return -EINVAL;
-
-	res = register_netdevice_notifier(&notifier);
-	if (!res)
-		eth_started = 1;
-	return res;
-}
-
-/**
- * tipc_eth_media_stop - deactivate Ethernet bearer support
- */
-void tipc_eth_media_stop(void)
-{
-	if (!eth_started)
-		return;
-
-	flush_scheduled_work();
-	unregister_netdevice_notifier(&notifier);
-	eth_started = 0;
-}
diff --git a/net/tipc/ib_media.c b/net/tipc/ib_media.c
index 9fdf03c..62d91ae 100644
--- a/net/tipc/ib_media.c
+++ b/net/tipc/ib_media.c
@@ -42,34 +42,6 @@
 #include "core.h"
 #include "bearer.h"
 
-#define MAX_IB_MEDIA		MAX_BEARERS
-
-/**
- * struct ib_media - Infiniband media data structure
- * @bearer: ptr to associated "generic" bearer structure
- * @dev: ptr to associated Infiniband network device
- * @tipc_packet_type: used in binding TIPC to Infiniband driver
- * @cleanup: work item used when disabling bearer
- */
-
-struct ib_media {
-	struct tipc_bearer *bearer;
-	struct net_device *dev;
-	struct packet_type tipc_packet_type;
-	struct work_struct setup;
-	struct work_struct cleanup;
-};
-
-static struct ib_media ib_media_array[MAX_IB_MEDIA];
-static int ib_started;
-static int recv_msg(struct sk_buff *buf, struct net_device *dev,
-		    struct packet_type *pt, struct net_device *orig_dev);
-
-static struct packet_type tipc_packet_type __read_mostly = {
-	.type = __constant_htons(ETH_P_TIPC),
-	.func = recv_msg,
-};
-
 /**
  * ib_media_addr_set - initialize Infiniband media address structure
  *
@@ -92,16 +64,14 @@ static int send_msg(struct sk_buff *buf, struct tipc_bearer *tb_ptr,
 		    struct tipc_media_addr *dest)
 {
 	struct sk_buff *clone;
-	struct net_device *dev;
 	int delta;
+	struct net_device *dev = tb_ptr->dev;
 
 	clone = skb_clone(buf, GFP_ATOMIC);
 	if (!clone)
 		return 0;
 
-	dev = ((struct ib_media *)(tb_ptr->usr_handle))->dev;
 	delta = dev->hard_header_len - skb_headroom(buf);
-
 	if ((delta > 0) &&
 	    pskb_expand_head(clone, SKB_DATA_ALIGN(delta), 0, GFP_ATOMIC)) {
 		kfree_skb(clone);
@@ -118,79 +88,21 @@ static int send_msg(struct sk_buff *buf, struct tipc_bearer *tb_ptr,
 }
 
 /**
- * recv_msg - handle incoming TIPC message from an InfiniBand interface
- *
- * Accept only packets explicitly sent to this node, or broadcast packets;
- * ignores packets sent using InfiniBand multicast, and traffic sent to other
- * nodes (which can happen if interface is running in promiscuous mode).
- */
-static int recv_msg(struct sk_buff *buf, struct net_device *dev,
-		    struct packet_type *pt, struct net_device *orig_dev)
-{
-	struct tipc_bearer *b_ptr;
-
-	if (!net_eq(dev_net(dev), &init_net)) {
-		kfree_skb(buf);
-		return NET_RX_DROP;
-	}
-
-	rcu_read_lock();
-	b_ptr = rcu_dereference(dev->tipc_ptr);
-	if (likely(b_ptr)) {
-		if (likely(buf->pkt_type <= PACKET_BROADCAST)) {
-			buf->next = NULL;
-			tipc_recv_msg(buf, b_ptr);
-			rcu_read_unlock();
-			return NET_RX_SUCCESS;
-		}
-	}
-	rcu_read_unlock();
-
-	kfree_skb(buf);
-	return NET_RX_DROP;
-}
-
-/**
- * setup_bearer - setup association between InfiniBand bearer and interface
- */
-static void setup_media(struct work_struct *work)
-{
-	dev_add_pack(&tipc_packet_type);
-}
-
-/**
  * enable_media - attach TIPC bearer to an InfiniBand interface
  */
 static int enable_media(struct tipc_bearer *tb_ptr)
 {
 	struct net_device *dev;
-	struct ib_media *ib_ptr = &ib_media_array[0];
-	struct ib_media *stop = &ib_media_array[MAX_IB_MEDIA];
 	char *driver_name = strchr((const char *)tb_ptr->name, ':') + 1;
-	int pending_dev = 0;
-
-	/* Find unused InfiniBand bearer structure */
-	while (ib_ptr->dev) {
-		if (!ib_ptr->bearer)
-			pending_dev++;
-		if (++ib_ptr == stop)
-			return pending_dev ? -EAGAIN : -EDQUOT;
-	}
 
 	/* Find device with specified name */
 	dev = dev_get_by_name(&init_net, driver_name);
 	if (!dev)
 		return -ENODEV;
 
-	/* Create InfiniBand bearer for device */
-	ib_ptr->dev = dev;
-	INIT_WORK(&ib_ptr->setup, setup_media);
-	schedule_work(&ib_ptr->setup);
-
 	/* Associate TIPC bearer with InfiniBand bearer */
 	tb_ptr->dev = dev;
-	ib_ptr->bearer = tb_ptr;
-	tb_ptr->usr_handle = (void *)ib_ptr;
+	tb_ptr->usr_handle = NULL;
 	memset(tb_ptr->bcast_addr.value, 0, sizeof(tb_ptr->bcast_addr.value));
 	memcpy(tb_ptr->bcast_addr.value, dev->broadcast, INFINIBAND_ALEN);
 	tb_ptr->bcast_addr.media_id = TIPC_MEDIA_TYPE_IB;
@@ -202,21 +114,6 @@ static int enable_media(struct tipc_bearer *tb_ptr)
 }
 
 /**
- * cleanup_bearer - break association between InfiniBand bearer and interface
- *
- * This routine must be invoked from a work queue because it can sleep.
- */
-static void cleanup_bearer(struct work_struct *work)
-{
-	struct ib_media *ib_ptr =
-		container_of(work, struct ib_media, cleanup);
-
-	dev_remove_pack(&tipc_packet_type);
-	dev_put(ib_ptr->dev);
-	ib_ptr->dev = NULL;
-}
-
-/**
  * disable_media - detach TIPC bearer from an InfiniBand interface
  *
  * Mark InfiniBand bearer as inactive so that incoming buffers are thrown away,
@@ -225,63 +122,11 @@ static void cleanup_bearer(struct work_struct *work)
  */
 static void disable_media(struct tipc_bearer *tb_ptr)
 {
-	struct ib_media *ib_ptr = (struct ib_media *)tb_ptr->usr_handle;
-
-	ib_ptr->bearer = NULL;
-	INIT_WORK(&ib_ptr->cleanup, cleanup_bearer);
-	schedule_work(&ib_ptr->cleanup);
 	RCU_INIT_POINTER(tb_ptr->dev->tipc_ptr, NULL);
+	dev_put(tb_ptr->dev);
 }
 
 /**
- * recv_notification - handle device updates from OS
- *
- * Change the state of the InfiniBand bearer (if any) associated with the
- * specified device.
- */
-static int recv_notification(struct notifier_block *nb, unsigned long evt,
-			     void *ptr)
-{
-	struct tipc_bearer *b_ptr;
-	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
-
-	if (!net_eq(dev_net(dev), &init_net))
-		return NOTIFY_DONE;
-
-	rcu_read_lock();
-	b_ptr = rcu_dereference(dev->tipc_ptr);
-	if (!b_ptr) {
-		rcu_read_unlock();
-		return NOTIFY_DONE;		/* bearer had been disabled */
-	}
-
-	b_ptr->mtu = dev->mtu;
-
-	switch (evt) {
-	case NETDEV_CHANGE:
-		if (netif_carrier_ok(dev))
-			break;
-	case NETDEV_DOWN:
-	case NETDEV_CHANGEMTU:
-	case NETDEV_CHANGEADDR:
-		tipc_reset_bearer(b_ptr);
-		break;
-	case NETDEV_UNREGISTER:
-	case NETDEV_CHANGENAME:
-		tipc_disable_bearer(b_ptr->name);
-		break;
-	}
-	rcu_read_unlock();
-
-	return NOTIFY_OK;
-}
-
-static struct notifier_block notifier = {
-	.notifier_call	= recv_notification,
-	.priority	= 0,
-};
-
-/**
  * ib_addr2str - convert InfiniBand address to string
  */
 static int ib_addr2str(struct tipc_media_addr *a, char *str_buf, int str_size)
@@ -332,34 +177,3 @@ struct tipc_media ib_media_info = {
 	.name		= "ib"
 };
 
-/**
- * tipc_ib_media_start - activate InfiniBand bearer support
- *
- * Register InfiniBand media type with TIPC bearer code.  Also register
- * with OS for notifications about device state changes.
- */
-int tipc_ib_media_start(void)
-{
-	int res;
-
-	if (ib_started)
-		return -EINVAL;
-
-	res = register_netdevice_notifier(&notifier);
-	if (!res)
-		ib_started = 1;
-	return res;
-}
-
-/**
- * tipc_ib_media_stop - deactivate InfiniBand bearer support
- */
-void tipc_ib_media_stop(void)
-{
-	if (!ib_started)
-		return;
-
-	flush_scheduled_work();
-	unregister_netdevice_notifier(&notifier);
-	ib_started = 0;
-}
-- 
1.7.9.5
