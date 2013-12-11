From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 4/7] tipc: remove TIPC usage of field af_packet_priv in struct net_device
Date: Tue, 10 Dec 2013 20:45:41 -0800
Message-ID: <1386737144-32334-5-git-send-email-jon.maloy@ericsson.com>
References: <1386737144-32334-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Patrick McHardy <kaber@trash.net>,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.ne1.yahoo.com ([98.138.207.11]:45374 "HELO
	smtp104.biz.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751292Ab3LKEq1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 23:46:27 -0500
In-Reply-To: <1386737144-32334-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

TIPC is currently using the field 'af_packet_priv' in struct net_device
as a handle to find the bearer instance associated to the given network
device. But, by doing so it is blocking other networking cleanups, such
as the one discussed here:

http://patchwork.ozlabs.org/patch/178044/

This commit removes this usage from TIPC. Instead, we introduce a new
field, 'tipc_ptr', to the net_device structure, to serve this purpose.
When TIPC bearer is enabled, the bearer object is associated to
'tipc_ptr'. When a TIPC packet arrives in the recv_msg() upcall
from a networking device, the bearer object can now be obtained from
'tipc_ptr'. When a bearer is disabled, the bearer object is detached
from its underlying network device by setting 'tipc_ptr' to NULL.

Additionally, an RCU lock is used to protect the new pointer.
Henceforth, the existing tipc_net_lock is used in write mode to
serialize write accesses to this pointer, while the new RCU lock is
applied on the read side to ensure that the pointer is 100% valid
within its wrapped area for all readers.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Cc: Patrick McHardy <kaber@trash.net>
Reviewed-by: Paul Gortmaker <paul.gortmaker@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 include/linux/netdevice.h |    3 +++
 net/tipc/bearer.h         |    2 ++
 net/tipc/eth_media.c      |   55 ++++++++++++++++++++++++++-------------------
 net/tipc/ib_media.c       |   54 +++++++++++++++++++++++++-------------------
 4 files changed, 68 insertions(+), 46 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9d55e51..0ca8100 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1283,6 +1283,9 @@ struct net_device {
 #if IS_ENABLED(CONFIG_NET_DSA)
 	struct dsa_switch_tree	*dsa_ptr;	/* dsa specific data */
 #endif
+#if IS_ENABLED(CONFIG_TIPC)
+	struct tipc_bearer __rcu *tipc_ptr;	/* TIPC specific data */
+#endif
 	void 			*atalk_ptr;	/* AppleTalk link 	*/
 	struct in_device __rcu	*ip_ptr;	/* IPv4 specific data	*/
 	struct dn_dev __rcu     *dn_ptr;        /* DECnet specific data */
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index e50266a..91b8d8b 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -105,6 +105,7 @@ struct tipc_media {
 
 /**
  * struct tipc_bearer - Generic TIPC bearer structure
+ * @dev: ptr to associated network device
  * @usr_handle: pointer to additional media-specific information about bearer
  * @mtu: max packet size bearer can support
  * @lock: spinlock for controlling access to bearer
@@ -127,6 +128,7 @@ struct tipc_media {
  * care of initializing all other fields.
  */
 struct tipc_bearer {
+	struct net_device *dev;
 	void *usr_handle;			/* initalized by media */
 	u32 mtu;				/* initalized by media */
 	struct tipc_media_addr addr;		/* initalized by media */
diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 37fb145..c5f685d 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -63,6 +63,9 @@ static int eth_started;
 
 static int recv_notification(struct notifier_block *nb, unsigned long evt,
 			     void *dv);
+static int recv_msg(struct sk_buff *buf, struct net_device *dev,
+		    struct packet_type *pt, struct net_device *orig_dev);
+
 /*
  * Network device notifier info
  */
@@ -71,6 +74,11 @@ static struct notifier_block notifier = {
 	.priority	= 0
 };
 
+static struct packet_type tipc_packet_type __read_mostly = {
+	.type = __constant_htons(ETH_P_TIPC),
+	.func = recv_msg,
+};
+
 /**
  * eth_media_addr_set - initialize Ethernet media address structure
  *
@@ -128,20 +136,25 @@ static int send_msg(struct sk_buff *buf, struct tipc_bearer *tb_ptr,
 static int recv_msg(struct sk_buff *buf, struct net_device *dev,
 		    struct packet_type *pt, struct net_device *orig_dev)
 {
-	struct eth_media *eb_ptr = (struct eth_media *)pt->af_packet_priv;
+	struct tipc_bearer *b_ptr;
 
 	if (!net_eq(dev_net(dev), &init_net)) {
 		kfree_skb(buf);
 		return NET_RX_DROP;
 	}
 
-	if (likely(eb_ptr->bearer)) {
+	rcu_read_lock();
+	b_ptr = rcu_dereference(dev->tipc_ptr);
+	if (likely(b_ptr)) {
 		if (likely(buf->pkt_type <= PACKET_BROADCAST)) {
 			buf->next = NULL;
-			tipc_recv_msg(buf, eb_ptr->bearer);
+			tipc_recv_msg(buf, b_ptr);
+			rcu_read_unlock();
 			return NET_RX_SUCCESS;
 		}
 	}
+	rcu_read_unlock();
+
 	kfree_skb(buf);
 	return NET_RX_DROP;
 }
@@ -151,10 +164,7 @@ static int recv_msg(struct sk_buff *buf, struct net_device *dev,
  */
 static void setup_media(struct work_struct *work)
 {
-	struct eth_media *eb_ptr =
-		container_of(work, struct eth_media, setup);
-
-	dev_add_pack(&eb_ptr->tipc_packet_type);
+	dev_add_pack(&tipc_packet_type);
 }
 
 /**
@@ -183,15 +193,11 @@ static int enable_media(struct tipc_bearer *tb_ptr)
 
 	/* Create Ethernet bearer for device */
 	eb_ptr->dev = dev;
-	eb_ptr->tipc_packet_type.type = htons(ETH_P_TIPC);
-	eb_ptr->tipc_packet_type.dev = dev;
-	eb_ptr->tipc_packet_type.func = recv_msg;
-	eb_ptr->tipc_packet_type.af_packet_priv = eb_ptr;
-	INIT_LIST_HEAD(&(eb_ptr->tipc_packet_type.list));
 	INIT_WORK(&eb_ptr->setup, setup_media);
 	schedule_work(&eb_ptr->setup);
 
 	/* Associate TIPC bearer with Ethernet bearer */
+	tb_ptr->dev = dev;
 	eb_ptr->bearer = tb_ptr;
 	tb_ptr->usr_handle = (void *)eb_ptr;
 	memset(tb_ptr->bcast_addr.value, 0, sizeof(tb_ptr->bcast_addr.value));
@@ -200,6 +206,7 @@ static int enable_media(struct tipc_bearer *tb_ptr)
 	tb_ptr->bcast_addr.broadcast = 1;
 	tb_ptr->mtu = dev->mtu;
 	eth_media_addr_set(tb_ptr, &tb_ptr->addr, (char *)dev->dev_addr);
+	rcu_assign_pointer(dev->tipc_ptr, tb_ptr);
 	return 0;
 }
 
@@ -213,7 +220,7 @@ static void cleanup_media(struct work_struct *work)
 	struct eth_media *eb_ptr =
 		container_of(work, struct eth_media, cleanup);
 
-	dev_remove_pack(&eb_ptr->tipc_packet_type);
+	dev_remove_pack(&tipc_packet_type);
 	dev_put(eb_ptr->dev);
 	eb_ptr->dev = NULL;
 }
@@ -232,6 +239,7 @@ static void disable_media(struct tipc_bearer *tb_ptr)
 	eb_ptr->bearer = NULL;
 	INIT_WORK(&eb_ptr->cleanup, cleanup_media);
 	schedule_work(&eb_ptr->cleanup);
+	RCU_INIT_POINTER(tb_ptr->dev->tipc_ptr, NULL);
 }
 
 /**
@@ -243,21 +251,20 @@ static void disable_media(struct tipc_bearer *tb_ptr)
 static int recv_notification(struct notifier_block *nb, unsigned long evt,
 			     void *ptr)
 {
+	struct tipc_bearer *b_ptr;
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
-	struct eth_media *eb_ptr = &eth_media_array[0];
-	struct eth_media *stop = &eth_media_array[MAX_ETH_MEDIA];
 
 	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
-	while ((eb_ptr->dev != dev)) {
-		if (++eb_ptr == stop)
-			return NOTIFY_DONE;	/* couldn't find device */
-	}
-	if (!eb_ptr->bearer)
+	rcu_read_lock();
+	b_ptr = rcu_dereference(dev->tipc_ptr);
+	if (!b_ptr) {
+		rcu_read_unlock();
 		return NOTIFY_DONE;		/* bearer had been disabled */
+	}
 
-	eb_ptr->bearer->mtu = dev->mtu;
+	b_ptr->mtu = dev->mtu;
 
 	switch (evt) {
 	case NETDEV_CHANGE:
@@ -266,13 +273,15 @@ static int recv_notification(struct notifier_block *nb, unsigned long evt,
 	case NETDEV_DOWN:
 	case NETDEV_CHANGEMTU:
 	case NETDEV_CHANGEADDR:
-		tipc_reset_bearer(eb_ptr->bearer);
+		tipc_reset_bearer(b_ptr);
 		break;
 	case NETDEV_UNREGISTER:
 	case NETDEV_CHANGENAME:
-		tipc_disable_bearer(eb_ptr->bearer->name);
+		tipc_disable_bearer(b_ptr->name);
 		break;
 	}
+	rcu_read_unlock();
+
 	return NOTIFY_OK;
 }
 
diff --git a/net/tipc/ib_media.c b/net/tipc/ib_media.c
index 48e1c07..9fdf03c 100644
--- a/net/tipc/ib_media.c
+++ b/net/tipc/ib_media.c
@@ -62,6 +62,13 @@ struct ib_media {
 
 static struct ib_media ib_media_array[MAX_IB_MEDIA];
 static int ib_started;
+static int recv_msg(struct sk_buff *buf, struct net_device *dev,
+		    struct packet_type *pt, struct net_device *orig_dev);
+
+static struct packet_type tipc_packet_type __read_mostly = {
+	.type = __constant_htons(ETH_P_TIPC),
+	.func = recv_msg,
+};
 
 /**
  * ib_media_addr_set - initialize Infiniband media address structure
@@ -120,20 +127,25 @@ static int send_msg(struct sk_buff *buf, struct tipc_bearer *tb_ptr,
 static int recv_msg(struct sk_buff *buf, struct net_device *dev,
 		    struct packet_type *pt, struct net_device *orig_dev)
 {
-	struct ib_media *ib_ptr = (struct ib_media *)pt->af_packet_priv;
+	struct tipc_bearer *b_ptr;
 
 	if (!net_eq(dev_net(dev), &init_net)) {
 		kfree_skb(buf);
 		return NET_RX_DROP;
 	}
 
-	if (likely(ib_ptr->bearer)) {
+	rcu_read_lock();
+	b_ptr = rcu_dereference(dev->tipc_ptr);
+	if (likely(b_ptr)) {
 		if (likely(buf->pkt_type <= PACKET_BROADCAST)) {
 			buf->next = NULL;
-			tipc_recv_msg(buf, ib_ptr->bearer);
+			tipc_recv_msg(buf, b_ptr);
+			rcu_read_unlock();
 			return NET_RX_SUCCESS;
 		}
 	}
+	rcu_read_unlock();
+
 	kfree_skb(buf);
 	return NET_RX_DROP;
 }
@@ -143,10 +155,7 @@ static int recv_msg(struct sk_buff *buf, struct net_device *dev,
  */
 static void setup_media(struct work_struct *work)
 {
-	struct ib_media *ib_ptr =
-		container_of(work, struct ib_media, setup);
-
-	dev_add_pack(&ib_ptr->tipc_packet_type);
+	dev_add_pack(&tipc_packet_type);
 }
 
 /**
@@ -175,15 +184,11 @@ static int enable_media(struct tipc_bearer *tb_ptr)
 
 	/* Create InfiniBand bearer for device */
 	ib_ptr->dev = dev;
-	ib_ptr->tipc_packet_type.type = htons(ETH_P_TIPC);
-	ib_ptr->tipc_packet_type.dev = dev;
-	ib_ptr->tipc_packet_type.func = recv_msg;
-	ib_ptr->tipc_packet_type.af_packet_priv = ib_ptr;
-	INIT_LIST_HEAD(&(ib_ptr->tipc_packet_type.list));
 	INIT_WORK(&ib_ptr->setup, setup_media);
 	schedule_work(&ib_ptr->setup);
 
 	/* Associate TIPC bearer with InfiniBand bearer */
+	tb_ptr->dev = dev;
 	ib_ptr->bearer = tb_ptr;
 	tb_ptr->usr_handle = (void *)ib_ptr;
 	memset(tb_ptr->bcast_addr.value, 0, sizeof(tb_ptr->bcast_addr.value));
@@ -192,6 +197,7 @@ static int enable_media(struct tipc_bearer *tb_ptr)
 	tb_ptr->bcast_addr.broadcast = 1;
 	tb_ptr->mtu = dev->mtu;
 	ib_media_addr_set(tb_ptr, &tb_ptr->addr, (char *)dev->dev_addr);
+	rcu_assign_pointer(dev->tipc_ptr, tb_ptr);
 	return 0;
 }
 
@@ -205,7 +211,7 @@ static void cleanup_bearer(struct work_struct *work)
 	struct ib_media *ib_ptr =
 		container_of(work, struct ib_media, cleanup);
 
-	dev_remove_pack(&ib_ptr->tipc_packet_type);
+	dev_remove_pack(&tipc_packet_type);
 	dev_put(ib_ptr->dev);
 	ib_ptr->dev = NULL;
 }
@@ -224,6 +230,7 @@ static void disable_media(struct tipc_bearer *tb_ptr)
 	ib_ptr->bearer = NULL;
 	INIT_WORK(&ib_ptr->cleanup, cleanup_bearer);
 	schedule_work(&ib_ptr->cleanup);
+	RCU_INIT_POINTER(tb_ptr->dev->tipc_ptr, NULL);
 }
 
 /**
@@ -235,21 +242,20 @@ static void disable_media(struct tipc_bearer *tb_ptr)
 static int recv_notification(struct notifier_block *nb, unsigned long evt,
 			     void *ptr)
 {
+	struct tipc_bearer *b_ptr;
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
-	struct ib_media *ib_ptr = &ib_media_array[0];
-	struct ib_media *stop = &ib_media_array[MAX_IB_MEDIA];
 
 	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
-	while ((ib_ptr->dev != dev)) {
-		if (++ib_ptr == stop)
-			return NOTIFY_DONE;	/* couldn't find device */
-	}
-	if (!ib_ptr->bearer)
+	rcu_read_lock();
+	b_ptr = rcu_dereference(dev->tipc_ptr);
+	if (!b_ptr) {
+		rcu_read_unlock();
 		return NOTIFY_DONE;		/* bearer had been disabled */
+	}
 
-	ib_ptr->bearer->mtu = dev->mtu;
+	b_ptr->mtu = dev->mtu;
 
 	switch (evt) {
 	case NETDEV_CHANGE:
@@ -258,13 +264,15 @@ static int recv_notification(struct notifier_block *nb, unsigned long evt,
 	case NETDEV_DOWN:
 	case NETDEV_CHANGEMTU:
 	case NETDEV_CHANGEADDR:
-		tipc_reset_bearer(ib_ptr->bearer);
+		tipc_reset_bearer(b_ptr);
 		break;
 	case NETDEV_UNREGISTER:
 	case NETDEV_CHANGENAME:
-		tipc_disable_bearer(ib_ptr->bearer->name);
+		tipc_disable_bearer(b_ptr->name);
 		break;
 	}
+	rcu_read_unlock();
+
 	return NOTIFY_OK;
 }
 
-- 
1.7.9.5
