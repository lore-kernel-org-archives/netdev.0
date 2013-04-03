From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: [PATCH 4/5] tipc: add InfiniBand media type
Date: Wed,  3 Apr 2013 14:43:29 +0200
Message-ID: <1364993010-15515-5-git-send-email-kaber@trash.net>
References: <1364993010-15515-1-git-send-email-kaber@trash.net>
Cc: allan.stephens-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jon.maloy-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1364993010-15515-1-git-send-email-kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add InfiniBand media type based on the ethernet media type.

The only real difference is that in case of InfiniBand, we need the entire
20 bytes of space reserved for media addresses, so the TIPC media type ID is
not explicitly stored in the packet payload.

Sample output of tipc-config:

# tipc-config -v -addr -netid -nt=all -p -m -b -n -ls

node address: <10.1.4>
current network id: 4711
Type       Lower      Upper      Port Identity              Publication Scope
0          167776257  167776257  <10.1.1:1855512577>        1855512578  cluster
           167776260  167776260  <10.1.4:1216454657>        1216454658  zone
1          1          1          <10.1.4:1216479235>        1216479236  node
Ports:
1216479235: bound to {1,1}
1216454657: bound to {0,167776260}
Media:
eth
ib
Bearers:
ib:ib0
Nodes known:
<10.1.1>: up
Link <broadcast-link>
  Window:20 packets
  RX packets:0 fragments:0/0 bundles:0/0
  TX packets:0 fragments:0/0 bundles:0/0
  RX naks:0 defs:0 dups:0
  TX naks:0 acks:0 dups:0
  Congestion bearer:0 link:0  Send queue max:0 avg:0

Link <10.1.4:ib0-10.1.1:ib0>
  ACTIVE  MTU:2044  Priority:10  Tolerance:1500 ms  Window:50 packets
  RX packets:80 fragments:0/0 bundles:0/0
  TX packets:40 fragments:0/0 bundles:0/0
  TX profile sample:22 packets  average:54 octets
  0-64:100% -256:0% -1024:0% -4096:0% -16384:0% -32768:0% -66000:0%
  RX states:410 probes:213 naks:0 defs:0 dups:0
  TX states:410 probes:197 naks:0 acks:0 dups:0
  Congestion bearer:0 link:0  Send queue max:1 avg:0

Signed-off-by: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
---
 net/tipc/Kconfig    |   7 +
 net/tipc/Makefile   |   2 +
 net/tipc/bearer.c   |   2 +-
 net/tipc/bearer.h   |   9 ++
 net/tipc/core.c     |  14 +-
 net/tipc/ib_media.c | 387 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 418 insertions(+), 3 deletions(-)
 create mode 100644 net/tipc/ib_media.c

diff --git a/net/tipc/Kconfig b/net/tipc/Kconfig
index 4f99600..900ee66 100644
--- a/net/tipc/Kconfig
+++ b/net/tipc/Kconfig
@@ -31,3 +31,10 @@ config TIPC_PORTS
 
 	  Setting this to a smaller value saves some memory,
 	  setting it to higher allows for more ports.
+
+config TIPC_MEDIA_IB
+	bool "InfiniBand media type support"
+	depends on INFINIBAND_IPOIB
+	help
+	  Saying Y here will enable support for running TIPC on
+	  IP-over-InfiniBand devices.
diff --git a/net/tipc/Makefile b/net/tipc/Makefile
index 6cd55d6..4df8e02 100644
--- a/net/tipc/Makefile
+++ b/net/tipc/Makefile
@@ -9,3 +9,5 @@ tipc-y	+= addr.o bcast.o bearer.o config.o \
 	   name_distr.o  subscr.o name_table.o net.o  \
 	   netlink.o node.o node_subscr.o port.o ref.o  \
 	   socket.o log.o eth_media.o
+
+tipc-$(CONFIG_TIPC_MEDIA_IB)	+= ib_media.o
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 45d5398..cb29ef7 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -39,7 +39,7 @@
 #include "bearer.h"
 #include "discover.h"
 
-#define MAX_ADDR_STR 32
+#define MAX_ADDR_STR 60
 
 static struct tipc_media *media_list[MAX_MEDIA];
 static u32 media_count;
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 3b3fa26..be68105 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -56,6 +56,7 @@
  * Identifiers of supported TIPC media types
  */
 #define TIPC_MEDIA_TYPE_ETH	1
+#define TIPC_MEDIA_TYPE_IB	2
 
 /**
  * struct tipc_media_addr - destination address used by TIPC bearers
@@ -174,6 +175,14 @@ int tipc_disable_bearer(const char *name);
 int  tipc_eth_media_start(void);
 void tipc_eth_media_stop(void);
 
+#ifdef CONFIG_TIPC_MEDIA_IB
+int  tipc_ib_media_start(void);
+void tipc_ib_media_stop(void);
+#else
+int  tipc_ib_media_start(void) { return 0; }
+void tipc_ib_media_stop(void)  { return; }
+#endif
+
 int tipc_media_set_priority(const char *name, u32 new_value);
 int tipc_media_set_window(const char *name, u32 new_value);
 void tipc_media_addr_printf(char *buf, int len, struct tipc_media_addr *a);
diff --git a/net/tipc/core.c b/net/tipc/core.c
index fc05cec..133aa4a 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -82,6 +82,7 @@ static void tipc_core_stop_net(void)
 {
 	tipc_net_stop();
 	tipc_eth_media_stop();
+	tipc_ib_media_stop();
 }
 
 /**
@@ -93,8 +94,17 @@ int tipc_core_start_net(unsigned long addr)
 
 	tipc_net_start(addr);
 	res = tipc_eth_media_start();
-	if (res)
-		tipc_core_stop_net();
+	if (res < 0)
+		goto err1;
+	res = tipc_ib_media_start();
+	if (res < 0)
+		goto err2;
+	return res;
+
+err2:
+	tipc_eth_media_stop();
+err1:
+	tipc_core_stop_net();
 	return res;
 }
 
diff --git a/net/tipc/ib_media.c b/net/tipc/ib_media.c
new file mode 100644
index 0000000..2a2864c
--- /dev/null
+++ b/net/tipc/ib_media.c
@@ -0,0 +1,387 @@
+/*
+ * net/tipc/ib_media.c: Infiniband bearer support for TIPC
+ *
+ * Copyright (c) 2013 Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
+ *
+ * Based on eth_media.c, which carries the following copyright notice:
+ *
+ * Copyright (c) 2001-2007, Ericsson AB
+ * Copyright (c) 2005-2008, 2011, Wind River Systems
+ * All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. Neither the names of the copyright holders nor the names of its
+ *    contributors may be used to endorse or promote products derived from
+ *    this software without specific prior written permission.
+ *
+ * Alternatively, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") version 2 as published by the Free
+ * Software Foundation.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
+ * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
+ * POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <linux/if_infiniband.h>
+#include "core.h"
+#include "bearer.h"
+
+#define MAX_IB_BEARERS		MAX_BEARERS
+
+/**
+ * struct ib_bearer - Infiniband bearer data structure
+ * @bearer: ptr to associated "generic" bearer structure
+ * @dev: ptr to associated Infiniband network device
+ * @tipc_packet_type: used in binding TIPC to Infiniband driver
+ * @cleanup: work item used when disabling bearer
+ */
+
+struct ib_bearer {
+	struct tipc_bearer *bearer;
+	struct net_device *dev;
+	struct packet_type tipc_packet_type;
+	struct work_struct setup;
+	struct work_struct cleanup;
+};
+
+static struct tipc_media ib_media_info;
+static struct ib_bearer ib_bearers[MAX_IB_BEARERS];
+static int ib_started;
+
+/**
+ * ib_media_addr_set - initialize Infiniband media address structure
+ *
+ * Media-dependent "value" field stores MAC address in first 6 bytes
+ * and zeroes out the remaining bytes.
+ */
+static void ib_media_addr_set(const struct tipc_bearer *tb_ptr,
+			      struct tipc_media_addr *a, char *mac)
+{
+	BUILD_BUG_ON(sizeof(a->value) < INFINIBAND_ALEN);
+	memcpy(a->value, mac, INFINIBAND_ALEN);
+	a->media_id = TIPC_MEDIA_TYPE_IB;
+	a->broadcast = !memcmp(mac, tb_ptr->bcast_addr.value, INFINIBAND_ALEN);
+}
+
+/**
+ * send_msg - send a TIPC message out over an InfiniBand interface
+ */
+static int send_msg(struct sk_buff *buf, struct tipc_bearer *tb_ptr,
+		    struct tipc_media_addr *dest)
+{
+	struct sk_buff *clone;
+	struct net_device *dev;
+	int delta;
+
+	clone = skb_clone(buf, GFP_ATOMIC);
+	if (!clone)
+		return 0;
+
+	dev = ((struct ib_bearer *)(tb_ptr->usr_handle))->dev;
+	delta = dev->hard_header_len - skb_headroom(buf);
+
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
+/**
+ * recv_msg - handle incoming TIPC message from an InfiniBand interface
+ *
+ * Accept only packets explicitly sent to this node, or broadcast packets;
+ * ignores packets sent using InfiniBand multicast, and traffic sent to other
+ * nodes (which can happen if interface is running in promiscuous mode).
+ */
+static int recv_msg(struct sk_buff *buf, struct net_device *dev,
+		    struct packet_type *pt, struct net_device *orig_dev)
+{
+	struct ib_bearer *ib_ptr = (struct ib_bearer *)pt->af_packet_priv;
+
+	if (!net_eq(dev_net(dev), &init_net)) {
+		kfree_skb(buf);
+		return 0;
+	}
+
+	if (likely(ib_ptr->bearer)) {
+		if (likely(buf->pkt_type <= PACKET_BROADCAST)) {
+			buf->next = NULL;
+			tipc_recv_msg(buf, ib_ptr->bearer);
+			return 0;
+		}
+	}
+	kfree_skb(buf);
+	return 0;
+}
+
+/**
+ * setup_bearer - setup association between InfiniBand bearer and interface
+ */
+static void setup_bearer(struct work_struct *work)
+{
+	struct ib_bearer *ib_ptr =
+		container_of(work, struct ib_bearer, setup);
+
+	dev_add_pack(&ib_ptr->tipc_packet_type);
+}
+
+/**
+ * enable_bearer - attach TIPC bearer to an InfiniBand interface
+ */
+static int enable_bearer(struct tipc_bearer *tb_ptr)
+{
+	struct net_device *dev = NULL;
+	struct net_device *pdev = NULL;
+	struct ib_bearer *ib_ptr = &ib_bearers[0];
+	struct ib_bearer *stop = &ib_bearers[MAX_IB_BEARERS];
+	char *driver_name = strchr((const char *)tb_ptr->name, ':') + 1;
+	int pending_dev = 0;
+
+	/* Find unused InfiniBand bearer structure */
+	while (ib_ptr->dev) {
+		if (!ib_ptr->bearer)
+			pending_dev++;
+		if (++ib_ptr == stop)
+			return pending_dev ? -EAGAIN : -EDQUOT;
+	}
+
+	/* Find device with specified name */
+	read_lock(&dev_base_lock);
+	for_each_netdev(&init_net, pdev) {
+		if (!strncmp(pdev->name, driver_name, IFNAMSIZ)) {
+			dev = pdev;
+			dev_hold(dev);
+			break;
+		}
+	}
+	read_unlock(&dev_base_lock);
+	if (!dev)
+		return -ENODEV;
+
+	/* Create InfiniBand bearer for device */
+	ib_ptr->dev = dev;
+	ib_ptr->tipc_packet_type.type = htons(ETH_P_TIPC);
+	ib_ptr->tipc_packet_type.dev = dev;
+	ib_ptr->tipc_packet_type.func = recv_msg;
+	ib_ptr->tipc_packet_type.af_packet_priv = ib_ptr;
+	INIT_LIST_HEAD(&(ib_ptr->tipc_packet_type.list));
+	INIT_WORK(&ib_ptr->setup, setup_bearer);
+	schedule_work(&ib_ptr->setup);
+
+	/* Associate TIPC bearer with InfiniBand bearer */
+	ib_ptr->bearer = tb_ptr;
+	tb_ptr->usr_handle = (void *)ib_ptr;
+	memset(tb_ptr->bcast_addr.value, 0, sizeof(tb_ptr->bcast_addr.value));
+	memcpy(tb_ptr->bcast_addr.value, dev->broadcast, INFINIBAND_ALEN);
+	tb_ptr->bcast_addr.media_id = TIPC_MEDIA_TYPE_IB;
+	tb_ptr->bcast_addr.broadcast = 1;
+	tb_ptr->mtu = dev->mtu;
+	tb_ptr->blocked = 0;
+	ib_media_addr_set(tb_ptr, &tb_ptr->addr, (char *)dev->dev_addr);
+	return 0;
+}
+
+/**
+ * cleanup_bearer - break association between InfiniBand bearer and interface
+ *
+ * This routine must be invoked from a work queue because it can sleep.
+ */
+static void cleanup_bearer(struct work_struct *work)
+{
+	struct ib_bearer *ib_ptr =
+		container_of(work, struct ib_bearer, cleanup);
+
+	dev_remove_pack(&ib_ptr->tipc_packet_type);
+	dev_put(ib_ptr->dev);
+	ib_ptr->dev = NULL;
+}
+
+/**
+ * disable_bearer - detach TIPC bearer from an InfiniBand interface
+ *
+ * Mark InfiniBand bearer as inactive so that incoming buffers are thrown away,
+ * then get worker thread to complete bearer cleanup.  (Can't do cleanup
+ * here because cleanup code needs to sleep and caller holds spinlocks.)
+ */
+static void disable_bearer(struct tipc_bearer *tb_ptr)
+{
+	struct ib_bearer *ib_ptr = (struct ib_bearer *)tb_ptr->usr_handle;
+
+	ib_ptr->bearer = NULL;
+	INIT_WORK(&ib_ptr->cleanup, cleanup_bearer);
+	schedule_work(&ib_ptr->cleanup);
+}
+
+/**
+ * recv_notification - handle device updates from OS
+ *
+ * Change the state of the InfiniBand bearer (if any) associated with the
+ * specified device.
+ */
+static int recv_notification(struct notifier_block *nb, unsigned long evt,
+			     void *dv)
+{
+	struct net_device *dev = (struct net_device *)dv;
+	struct ib_bearer *ib_ptr = &ib_bearers[0];
+	struct ib_bearer *stop = &ib_bearers[MAX_IB_BEARERS];
+
+	if (!net_eq(dev_net(dev), &init_net))
+		return NOTIFY_DONE;
+
+	while ((ib_ptr->dev != dev)) {
+		if (++ib_ptr == stop)
+			return NOTIFY_DONE;	/* couldn't find device */
+	}
+	if (!ib_ptr->bearer)
+		return NOTIFY_DONE;		/* bearer had been disabled */
+
+	ib_ptr->bearer->mtu = dev->mtu;
+
+	switch (evt) {
+	case NETDEV_CHANGE:
+		if (netif_carrier_ok(dev))
+			tipc_continue(ib_ptr->bearer);
+		else
+			tipc_block_bearer(ib_ptr->bearer->name);
+		break;
+	case NETDEV_UP:
+		tipc_continue(ib_ptr->bearer);
+		break;
+	case NETDEV_DOWN:
+		tipc_block_bearer(ib_ptr->bearer->name);
+		break;
+	case NETDEV_CHANGEMTU:
+	case NETDEV_CHANGEADDR:
+		tipc_block_bearer(ib_ptr->bearer->name);
+		tipc_continue(ib_ptr->bearer);
+		break;
+	case NETDEV_UNREGISTER:
+	case NETDEV_CHANGENAME:
+		tipc_disable_bearer(ib_ptr->bearer->name);
+		break;
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block notifier = {
+	.notifier_call	= recv_notification,
+	.priority	= 0,
+};
+
+/**
+ * ib_addr2str - convert InfiniBand address to string
+ */
+static int ib_addr2str(struct tipc_media_addr *a, char *str_buf, int str_size)
+{
+	if (str_size < 60)	/* 60 = 19 * strlen("xx:") + strlen("xx\0") */
+		return 1;
+
+	sprintf(str_buf, "%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x:"
+			 "%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x",
+		a->value[0], a->value[1], a->value[2], a->value[3],
+		a->value[4], a->value[5], a->value[6], a->value[7],
+		a->value[8], a->value[9], a->value[10], a->value[11],
+		a->value[12], a->value[13], a->value[14], a->value[15],
+		a->value[16], a->value[17], a->value[18], a->value[19]);
+
+	return 0;
+}
+
+/**
+ * ib_addr2msg - convert InfiniBand address format to message header format
+ */
+static int ib_addr2msg(struct tipc_media_addr *a, char *msg_area)
+{
+	memset(msg_area, 0, TIPC_MEDIA_ADDR_SIZE);
+	msg_area[TIPC_MEDIA_TYPE_OFFSET] = TIPC_MEDIA_TYPE_IB;
+	memcpy(msg_area, a->value, INFINIBAND_ALEN);
+	return 0;
+}
+
+/**
+ * ib_msg2addr - convert message header address format to InfiniBand format
+ */
+static int ib_msg2addr(const struct tipc_bearer *tb_ptr,
+		       struct tipc_media_addr *a, char *msg_area)
+{
+	ib_media_addr_set(tb_ptr, a, msg_area);
+	return 0;
+}
+
+/*
+ * InfiniBand media registration info
+ */
+static struct tipc_media ib_media_info = {
+	.send_msg	= send_msg,
+	.enable_bearer	= enable_bearer,
+	.disable_bearer	= disable_bearer,
+	.addr2str	= ib_addr2str,
+	.addr2msg	= ib_addr2msg,
+	.msg2addr	= ib_msg2addr,
+	.priority	= TIPC_DEF_LINK_PRI,
+	.tolerance	= TIPC_DEF_LINK_TOL,
+	.window		= TIPC_DEF_LINK_WIN,
+	.type_id	= TIPC_MEDIA_TYPE_IB,
+	.name		= "ib"
+};
+
+/**
+ * tipc_ib_media_start - activate InfiniBand bearer support
+ *
+ * Register InfiniBand media type with TIPC bearer code.  Also register
+ * with OS for notifications about device state changes.
+ */
+int tipc_ib_media_start(void)
+{
+	int res;
+
+	if (ib_started)
+		return -EINVAL;
+
+	res = tipc_register_media(&ib_media_info);
+	if (res)
+		return res;
+
+	res = register_netdevice_notifier(&notifier);
+	if (!res)
+		ib_started = 1;
+	return res;
+}
+
+/**
+ * tipc_ib_media_stop - deactivate InfiniBand bearer support
+ */
+void tipc_ib_media_stop(void)
+{
+	if (!ib_started)
+		return;
+
+	flush_scheduled_work();
+	unregister_netdevice_notifier(&notifier);
+	ib_started = 0;
+}
-- 
1.8.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
