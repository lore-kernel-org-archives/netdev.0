From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 6/7] tipc: eliminate code duplication
	in media layer
Date: Tue, 10 Dec 2013 20:45:43 -0800
Message-ID: <1386737144-32334-7-git-send-email-jon.maloy@ericsson.com>
References: <1386737144-32334-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1386737144-32334-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Ying Xue <ying.xue@windriver.com>

Currently TIPC supports two L2 media types, Ethernet and Infiniband.
Because both these media are accessed through the common net_device API,
several functions in the two media adaptation files turn out to be
fully or almost identical, leading to unnecessary code duplication.

In this commit we extract this common code from the two media files
and move them to the generic bearer.c. Additionally, we change
the function names to reflect their real role: to access L2 media,
irrespective of type.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Cc: Patrick McHardy <kaber@trash.net>
Reviewed-by: Paul Gortmaker <paul.gortmaker@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bearer.c    |  106 +++++++++++++++++++++++++++++++++++++++++-
 net/tipc/bearer.h    |   26 +++++------
 net/tipc/eth_media.c |  124 +++++++-------------------------------------------
 net/tipc/ib_media.c  |  124 +++++++-------------------------------------------
 4 files changed, 149 insertions(+), 231 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index e95e0b9..3bb5f26 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -2,7 +2,7 @@
  * net/tipc/bearer.c: TIPC bearer code
  *
  * Copyright (c) 1996-2006, 2013, Ericsson AB
- * Copyright (c) 2004-2006, 2010-2011, Wind River Systems
+ * Copyright (c) 2004-2006, 2010-2013, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -332,6 +332,7 @@ restart:
 
 	b_ptr = &tipc_bearers[bearer_id];
 	strcpy(b_ptr->name, name);
+	b_ptr->media = m_ptr;
 	res = m_ptr->enable_media(b_ptr);
 	if (res) {
 		pr_warn("Bearer <%s> rejected, enable failure (%d)\n",
@@ -340,7 +341,6 @@ restart:
 	}
 
 	b_ptr->identity = bearer_id;
-	b_ptr->media = m_ptr;
 	b_ptr->tolerance = m_ptr->tolerance;
 	b_ptr->window = m_ptr->window;
 	b_ptr->net_plane = bearer_id + 'A';
@@ -432,6 +432,108 @@ int tipc_disable_bearer(const char *name)
 	return res;
 }
 
+
+/* tipc_l2_media_addr_set - initialize Ethernet media address structure
+ *
+ * Media-dependent "value" field stores MAC address in first 6 bytes
+ * and zeroes out the remaining bytes.
+ */
+void tipc_l2_media_addr_set(const struct tipc_bearer *b,
+			    struct tipc_media_addr *a, char *mac)
+{
+	int len = b->media->hwaddr_len;
+
+	if (unlikely(sizeof(a->value) < len)) {
+		WARN_ONCE(1, "Media length invalid\n");
+		return;
+	}
+
+	memcpy(a->value, mac, len);
+	memset(a->value + len, 0, sizeof(a->value) - len);
+	a->media_id = b->media->type_id;
+	a->broadcast = !memcmp(mac, b->bcast_addr.value, len);
+}
+
+int tipc_enable_l2_media(struct tipc_bearer *b)
+{
+	struct net_device *dev;
+	char *driver_name = strchr((const char *)b->name, ':') + 1;
+
+	/* Find device with specified name */
+	dev = dev_get_by_name(&init_net, driver_name);
+	if (!dev)
+		return -ENODEV;
+
+	/* Associate TIPC bearer with Ethernet bearer */
+	b->media_ptr = dev;
+	memset(b->bcast_addr.value, 0, sizeof(b->bcast_addr.value));
+	memcpy(b->bcast_addr.value, dev->broadcast, b->media->hwaddr_len);
+	b->bcast_addr.media_id = b->media->type_id;
+	b->bcast_addr.broadcast = 1;
+	b->mtu = dev->mtu;
+	tipc_l2_media_addr_set(b, &b->addr, (char *)dev->dev_addr);
+	rcu_assign_pointer(dev->tipc_ptr, b);
+	return 0;
+}
+
+/* tipc_disable_l2_media - detach TIPC bearer from an Ethernet interface
+ *
+ * Mark Ethernet bearer as inactive so that incoming buffers are thrown away,
+ * then get worker thread to complete bearer cleanup.  (Can't do cleanup
+ * here because cleanup code needs to sleep and caller holds spinlocks.)
+ */
+void tipc_disable_l2_media(struct tipc_bearer *b)
+{
+	struct net_device *dev = (struct net_device *)b->media_ptr;
+	RCU_INIT_POINTER(dev->tipc_ptr, NULL);
+	dev_put(dev);
+}
+
+/**
+ * tipc_l2_send_msg - send a TIPC packet out over an Ethernet interface
+ * @buf: the packet to be sent
+ * @b_ptr: the bearer throught which the packet is to be sent
+ * @dest: peer destination address
+ */
+int tipc_l2_send_msg(struct sk_buff *buf, struct tipc_bearer *b,
+		     struct tipc_media_addr *dest)
+{
+	struct sk_buff *clone;
+	int delta;
+	struct net_device *dev = (struct net_device *)b->media_ptr;
+
+	clone = skb_clone(buf, GFP_ATOMIC);
+	if (!clone)
+		return 0;
+
+	delta = dev->hard_header_len - skb_headroom(buf);
+	if ((delta > 0) &&
+	    pskb_expand_head(clone, SKB_DATA_ALIGN(delta), 0, GFP_ATOMIC)) {
+		kfree_skb(clone);
+		return 0;
+	}
+
+	skb_reset_network_header(clone);
+	clone->dev = dev;
+	clone->protocol = htons(ETH_P_TIPC);
+	dev_hard_header(clone, dev, ETH_P_TIPC, dest->value,
+			dev->dev_addr, clone->len);
+	dev_queue_xmit(clone);
+	return 0;
+}
+
+/* tipc_bearer_send- sends buffer to destination over bearer
+ *
+ * IMPORTANT:
+ * The media send routine must not alter the buffer being passed in
+ * as it may be needed for later retransmission!
+ */
+void tipc_bearer_send(struct tipc_bearer *b, struct sk_buff *buf,
+		      struct tipc_media_addr *dest)
+{
+	b->media->send_msg(buf, b, dest);
+}
+
 /**
  * tipc_l2_rcv_msg - handle incoming TIPC message from an interface
  * @buf: the received packet
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 0974c2f..fa95c34 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -84,6 +84,7 @@ struct tipc_bearer;
  * @tolerance: default time (in ms) before declaring link failure
  * @window: default window (in packets) before declaring link congestion
  * @type_id: TIPC media identifier
+ * @hwaddr_len: TIPC media address len
  * @name: media name
  */
 struct tipc_media {
@@ -100,6 +101,7 @@ struct tipc_media {
 	u32 tolerance;
 	u32 window;
 	u32 type_id;
+	u32 hwaddr_len;
 	char name[TIPC_MAX_MEDIA_NAME];
 };
 
@@ -128,8 +130,7 @@ struct tipc_media {
  * care of initializing all other fields.
  */
 struct tipc_bearer {
-	struct net_device *dev;
-	void *usr_handle;			/* initalized by media */
+	void *media_ptr;			/* initalized by media */
 	u32 mtu;				/* initalized by media */
 	struct tipc_media_addr addr;		/* initalized by media */
 	char name[TIPC_MAX_BEARER_NAME];
@@ -178,6 +179,12 @@ int tipc_media_set_priority(const char *name, u32 new_value);
 int tipc_media_set_window(const char *name, u32 new_value);
 void tipc_media_addr_printf(char *buf, int len, struct tipc_media_addr *a);
 struct sk_buff *tipc_media_get_names(void);
+void tipc_l2_media_addr_set(const struct tipc_bearer *b,
+			    struct tipc_media_addr *a, char *mac);
+int tipc_enable_l2_media(struct tipc_bearer *b);
+void tipc_disable_l2_media(struct tipc_bearer *b);
+int tipc_l2_send_msg(struct sk_buff *buf, struct tipc_bearer *b,
+		     struct tipc_media_addr *dest);
 
 struct sk_buff *tipc_bearer_get_names(void);
 void tipc_bearer_add_dest(struct tipc_bearer *b_ptr, u32 dest);
@@ -188,18 +195,7 @@ struct tipc_media *tipc_media_find(const char *name);
 int tipc_bearer_setup(void);
 void tipc_bearer_cleanup(void);
 void tipc_bearer_stop(void);
-
-/**
- * tipc_bearer_send- sends buffer to destination over bearer
- *
- * IMPORTANT:
- * The media send routine must not alter the buffer being passed in
- * as it may be needed for later retransmission!
- */
-static inline void tipc_bearer_send(struct tipc_bearer *b, struct sk_buff *buf,
-				   struct tipc_media_addr *dest)
-{
-	b->media->send_msg(buf, b, dest);
-}
+void tipc_bearer_send(struct tipc_bearer *b, struct sk_buff *buf,
+		      struct tipc_media_addr *dest);
 
 #endif	/* _TIPC_BEARER_H */
diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index f28f716..67cf3f9 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -39,94 +39,9 @@
 
 #define ETH_ADDR_OFFSET	4	/* message header offset of MAC address */
 
-/**
- * eth_media_addr_set - initialize Ethernet media address structure
- *
- * Media-dependent "value" field stores MAC address in first 6 bytes
- * and zeroes out the remaining bytes.
- */
-static void eth_media_addr_set(const struct tipc_bearer *tb_ptr,
-			       struct tipc_media_addr *a, char *mac)
-{
-	memcpy(a->value, mac, ETH_ALEN);
-	memset(a->value + ETH_ALEN, 0, sizeof(a->value) - ETH_ALEN);
-	a->media_id = TIPC_MEDIA_TYPE_ETH;
-	a->broadcast = !memcmp(mac, tb_ptr->bcast_addr.value, ETH_ALEN);
-}
-
-/**
- * send_msg - send a TIPC message out over an Ethernet interface
- */
-static int send_msg(struct sk_buff *buf, struct tipc_bearer *tb_ptr,
-		    struct tipc_media_addr *dest)
-{
-	struct sk_buff *clone;
-	int delta;
-	struct net_device *dev = tb_ptr->dev;
-
-	clone = skb_clone(buf, GFP_ATOMIC);
-	if (!clone)
-		return 0;
-
-	delta = dev->hard_header_len - skb_headroom(buf);
-	if ((delta > 0) &&
-	    pskb_expand_head(clone, SKB_DATA_ALIGN(delta), 0, GFP_ATOMIC)) {
-		kfree_skb(clone);
-		return 0;
-	}
-
-	skb_reset_network_header(clone);
-	clone->dev = dev;
-	clone->protocol = htons(ETH_P_TIPC);
-	dev_hard_header(clone, dev, ETH_P_TIPC, dest->value,
-			dev->dev_addr, clone->len);
-	dev_queue_xmit(clone);
-	return 0;
-}
-
-/**
- * enable_media - attach TIPC bearer to an Ethernet interface
- */
-static int enable_media(struct tipc_bearer *tb_ptr)
-{
-	struct net_device *dev;
-	char *driver_name = strchr((const char *)tb_ptr->name, ':') + 1;
-
-	/* Find device with specified name */
-	dev = dev_get_by_name(&init_net, driver_name);
-	if (!dev)
-		return -ENODEV;
-
-	/* Associate TIPC bearer with Ethernet bearer */
-	tb_ptr->dev = dev;
-	tb_ptr->usr_handle = NULL;
-	memset(tb_ptr->bcast_addr.value, 0, sizeof(tb_ptr->bcast_addr.value));
-	memcpy(tb_ptr->bcast_addr.value, dev->broadcast, ETH_ALEN);
-	tb_ptr->bcast_addr.media_id = TIPC_MEDIA_TYPE_ETH;
-	tb_ptr->bcast_addr.broadcast = 1;
-	tb_ptr->mtu = dev->mtu;
-	eth_media_addr_set(tb_ptr, &tb_ptr->addr, (char *)dev->dev_addr);
-	rcu_assign_pointer(dev->tipc_ptr, tb_ptr);
-	return 0;
-}
-
-/**
- * disable_media - detach TIPC bearer from an Ethernet interface
- *
- * Mark Ethernet bearer as inactive so that incoming buffers are thrown away,
- * then get worker thread to complete bearer cleanup.  (Can't do cleanup
- * here because cleanup code needs to sleep and caller holds spinlocks.)
- */
-static void disable_media(struct tipc_bearer *tb_ptr)
-{
-	RCU_INIT_POINTER(tb_ptr->dev->tipc_ptr, NULL);
-	dev_put(tb_ptr->dev);
-}
-
-/**
- * eth_addr2str - convert Ethernet address to string
- */
-static int eth_addr2str(struct tipc_media_addr *a, char *str_buf, int str_size)
+/* convert Ethernet address to string */
+static int tipc_eth_addr2str(struct tipc_media_addr *a, char *str_buf,
+			     int str_size)
 {
 	if (str_size < 18)	/* 18 = strlen("aa:bb:cc:dd:ee:ff\0") */
 		return 1;
@@ -135,10 +50,8 @@ static int eth_addr2str(struct tipc_media_addr *a, char *str_buf, int str_size)
 	return 0;
 }
 
-/**
- * eth_str2addr - convert Ethernet address format to message header format
- */
-static int eth_addr2msg(struct tipc_media_addr *a, char *msg_area)
+/* convert Ethernet address format to message header format */
+static int tipc_eth_addr2msg(struct tipc_media_addr *a, char *msg_area)
 {
 	memset(msg_area, 0, TIPC_MEDIA_ADDR_SIZE);
 	msg_area[TIPC_MEDIA_TYPE_OFFSET] = TIPC_MEDIA_TYPE_ETH;
@@ -146,33 +59,30 @@ static int eth_addr2msg(struct tipc_media_addr *a, char *msg_area)
 	return 0;
 }
 
-/**
- * eth_str2addr - convert message header address format to Ethernet format
- */
-static int eth_msg2addr(const struct tipc_bearer *tb_ptr,
-			struct tipc_media_addr *a, char *msg_area)
+/* convert message header address format to Ethernet format */
+static int tipc_eth_msg2addr(const struct tipc_bearer *tb_ptr,
+			     struct tipc_media_addr *a, char *msg_area)
 {
 	if (msg_area[TIPC_MEDIA_TYPE_OFFSET] != TIPC_MEDIA_TYPE_ETH)
 		return 1;
 
-	eth_media_addr_set(tb_ptr, a, msg_area + ETH_ADDR_OFFSET);
+	tipc_l2_media_addr_set(tb_ptr, a, msg_area + ETH_ADDR_OFFSET);
 	return 0;
 }
 
-/*
- * Ethernet media registration info
- */
+/* Ethernet media registration info */
 struct tipc_media eth_media_info = {
-	.send_msg	= send_msg,
-	.enable_media	= enable_media,
-	.disable_media	= disable_media,
-	.addr2str	= eth_addr2str,
-	.addr2msg	= eth_addr2msg,
-	.msg2addr	= eth_msg2addr,
+	.send_msg	= tipc_l2_send_msg,
+	.enable_media	= tipc_enable_l2_media,
+	.disable_media	= tipc_disable_l2_media,
+	.addr2str	= tipc_eth_addr2str,
+	.addr2msg	= tipc_eth_addr2msg,
+	.msg2addr	= tipc_eth_msg2addr,
 	.priority	= TIPC_DEF_LINK_PRI,
 	.tolerance	= TIPC_DEF_LINK_TOL,
 	.window		= TIPC_DEF_LINK_WIN,
 	.type_id	= TIPC_MEDIA_TYPE_ETH,
+	.hwaddr_len	= ETH_ALEN,
 	.name		= "eth"
 };
 
diff --git a/net/tipc/ib_media.c b/net/tipc/ib_media.c
index 62d91ae..844a77e 100644
--- a/net/tipc/ib_media.c
+++ b/net/tipc/ib_media.c
@@ -42,94 +42,9 @@
 #include "core.h"
 #include "bearer.h"
 
-/**
- * ib_media_addr_set - initialize Infiniband media address structure
- *
- * Media-dependent "value" field stores MAC address in first 6 bytes
- * and zeroes out the remaining bytes.
- */
-static void ib_media_addr_set(const struct tipc_bearer *tb_ptr,
-			      struct tipc_media_addr *a, char *mac)
-{
-	BUILD_BUG_ON(sizeof(a->value) < INFINIBAND_ALEN);
-	memcpy(a->value, mac, INFINIBAND_ALEN);
-	a->media_id = TIPC_MEDIA_TYPE_IB;
-	a->broadcast = !memcmp(mac, tb_ptr->bcast_addr.value, INFINIBAND_ALEN);
-}
-
-/**
- * send_msg - send a TIPC message out over an InfiniBand interface
- */
-static int send_msg(struct sk_buff *buf, struct tipc_bearer *tb_ptr,
-		    struct tipc_media_addr *dest)
-{
-	struct sk_buff *clone;
-	int delta;
-	struct net_device *dev = tb_ptr->dev;
-
-	clone = skb_clone(buf, GFP_ATOMIC);
-	if (!clone)
-		return 0;
-
-	delta = dev->hard_header_len - skb_headroom(buf);
-	if ((delta > 0) &&
-	    pskb_expand_head(clone, SKB_DATA_ALIGN(delta), 0, GFP_ATOMIC)) {
-		kfree_skb(clone);
-		return 0;
-	}
-
-	skb_reset_network_header(clone);
-	clone->dev = dev;
-	clone->protocol = htons(ETH_P_TIPC);
-	dev_hard_header(clone, dev, ETH_P_TIPC, dest->value,
-			dev->dev_addr, clone->len);
-	dev_queue_xmit(clone);
-	return 0;
-}
-
-/**
- * enable_media - attach TIPC bearer to an InfiniBand interface
- */
-static int enable_media(struct tipc_bearer *tb_ptr)
-{
-	struct net_device *dev;
-	char *driver_name = strchr((const char *)tb_ptr->name, ':') + 1;
-
-	/* Find device with specified name */
-	dev = dev_get_by_name(&init_net, driver_name);
-	if (!dev)
-		return -ENODEV;
-
-	/* Associate TIPC bearer with InfiniBand bearer */
-	tb_ptr->dev = dev;
-	tb_ptr->usr_handle = NULL;
-	memset(tb_ptr->bcast_addr.value, 0, sizeof(tb_ptr->bcast_addr.value));
-	memcpy(tb_ptr->bcast_addr.value, dev->broadcast, INFINIBAND_ALEN);
-	tb_ptr->bcast_addr.media_id = TIPC_MEDIA_TYPE_IB;
-	tb_ptr->bcast_addr.broadcast = 1;
-	tb_ptr->mtu = dev->mtu;
-	ib_media_addr_set(tb_ptr, &tb_ptr->addr, (char *)dev->dev_addr);
-	rcu_assign_pointer(dev->tipc_ptr, tb_ptr);
-	return 0;
-}
-
-/**
- * disable_media - detach TIPC bearer from an InfiniBand interface
- *
- * Mark InfiniBand bearer as inactive so that incoming buffers are thrown away,
- * then get worker thread to complete bearer cleanup.  (Can't do cleanup
- * here because cleanup code needs to sleep and caller holds spinlocks.)
- */
-static void disable_media(struct tipc_bearer *tb_ptr)
-{
-	RCU_INIT_POINTER(tb_ptr->dev->tipc_ptr, NULL);
-	dev_put(tb_ptr->dev);
-}
-
-/**
- * ib_addr2str - convert InfiniBand address to string
- */
-static int ib_addr2str(struct tipc_media_addr *a, char *str_buf, int str_size)
+/* convert InfiniBand address to string */
+static int tipc_ib_addr2str(struct tipc_media_addr *a, char *str_buf,
+			    int str_size)
 {
 	if (str_size < 60)	/* 60 = 19 * strlen("xx:") + strlen("xx\0") */
 		return 1;
@@ -139,10 +54,8 @@ static int ib_addr2str(struct tipc_media_addr *a, char *str_buf, int str_size)
 	return 0;
 }
 
-/**
- * ib_addr2msg - convert InfiniBand address format to message header format
- */
-static int ib_addr2msg(struct tipc_media_addr *a, char *msg_area)
+/* convert InfiniBand address format to message header format */
+static int tipc_ib_addr2msg(struct tipc_media_addr *a, char *msg_area)
 {
 	memset(msg_area, 0, TIPC_MEDIA_ADDR_SIZE);
 	msg_area[TIPC_MEDIA_TYPE_OFFSET] = TIPC_MEDIA_TYPE_IB;
@@ -150,30 +63,27 @@ static int ib_addr2msg(struct tipc_media_addr *a, char *msg_area)
 	return 0;
 }
 
-/**
- * ib_msg2addr - convert message header address format to InfiniBand format
- */
-static int ib_msg2addr(const struct tipc_bearer *tb_ptr,
-		       struct tipc_media_addr *a, char *msg_area)
+/* convert message header address format to InfiniBand format */
+static int tipc_ib_msg2addr(const struct tipc_bearer *tb_ptr,
+			    struct tipc_media_addr *a, char *msg_area)
 {
-	ib_media_addr_set(tb_ptr, a, msg_area);
+	tipc_l2_media_addr_set(tb_ptr, a, msg_area);
 	return 0;
 }
 
-/*
- * InfiniBand media registration info
- */
+/* InfiniBand media registration info */
 struct tipc_media ib_media_info = {
-	.send_msg	= send_msg,
-	.enable_media	= enable_media,
-	.disable_media	= disable_media,
-	.addr2str	= ib_addr2str,
-	.addr2msg	= ib_addr2msg,
-	.msg2addr	= ib_msg2addr,
+	.send_msg	= tipc_l2_send_msg,
+	.enable_media	= tipc_enable_l2_media,
+	.disable_media	= tipc_disable_l2_media,
+	.addr2str	= tipc_ib_addr2str,
+	.addr2msg	= tipc_ib_addr2msg,
+	.msg2addr	= tipc_ib_msg2addr,
 	.priority	= TIPC_DEF_LINK_PRI,
 	.tolerance	= TIPC_DEF_LINK_TOL,
 	.window		= TIPC_DEF_LINK_WIN,
 	.type_id	= TIPC_MEDIA_TYPE_IB,
+	.hwaddr_len	= INFINIBAND_ALEN,
 	.name		= "ib"
 };
 
-- 
1.7.9.5


------------------------------------------------------------------------------
Rapidly troubleshoot problems before they affect your business. Most IT 
organizations don't have a clear picture of how application performance 
affects their revenue. With AppDynamics, you get 100% visibility into your 
Java,.NET, & PHP application. Start your 15-day FREE TRIAL of AppDynamics Pro!
http://pubads.g.doubleclick.net/gampad/clk?id=84349831&iu=/4140/ostg.clktrk
