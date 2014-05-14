From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next v2 6/8] tipc: improve and extend
	media address conversion functions
Date: Wed, 14 May 2014 05:39:13 -0400
Message-ID: <1400060355-26308-7-git-send-email-jon.maloy@ericsson.com>
References: <1400060355-26308-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1400060355-26308-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

TIPC currently handles two media specific addresses: Ethernet MAC
addresses and InfiniBand addresses. Those are kept in three different
formats:

1) A "raw" format as obtained from the device. This format is known
   only by the media specific adapter code in eth_media.c and
   ib_media.c.
2) A "generic" internal format, in the form of struct tipc_media_addr,
   which can be referenced and passed around by the generic media-
   unaware code.
3) A serialized version of the latter, to be conveyed in neighbor
   discovery messages.

Conversion between the three formats can only be done by the media
specific code, so we have function pointers for this purpose in
struct tipc_media. Here, the media adapters can install their own
conversion functions at startup.

We now introduce a new such function, 'raw2addr()', whose purpose
is to convert from format 1 to format 2 above. We also try to as far
as possible uniform commenting, variable names and usage of these
functions, with the purpose of making them more comprehensible.

We can now also remove the function tipc_l2_media_addr_set(), whose
job is done better by the new function.

Finally, we expand the field for serialized addresses (format 3)
in discovery messages from 20 to 32 bytes. This is permitted
according to the spec, and reduces the risk of problems when we
add new media in the future.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/bearer.c    |   36 +++++++----------------------------
 net/tipc/bearer.h    |   35 ++++++++++++++++++----------------
 net/tipc/core.h      |    1 +
 net/tipc/discover.c  |    2 +-
 net/tipc/eth_media.c |   51 +++++++++++++++++++++++++++++++-------------------
 net/tipc/ib_media.c  |   34 ++++++++++++++++++++++-----------
 6 files changed, 83 insertions(+), 76 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index f3259d4..2644743 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -411,28 +411,6 @@ int tipc_disable_bearer(const char *name)
 	return res;
 }
 
-
-/* tipc_l2_media_addr_set - initialize Ethernet media address structure
- *
- * Media-dependent "value" field stores MAC address in first 6 bytes
- * and zeroes out the remaining bytes.
- */
-void tipc_l2_media_addr_set(const struct tipc_bearer *b,
-			    struct tipc_media_addr *a, char *mac)
-{
-	int len = b->media->hwaddr_len;
-
-	if (unlikely(sizeof(a->value) < len)) {
-		WARN_ONCE(1, "Media length invalid\n");
-		return;
-	}
-
-	memcpy(a->value, mac, len);
-	memset(a->value + len, 0, sizeof(a->value) - len);
-	a->media_id = b->media->type_id;
-	a->broadcast = !memcmp(mac, b->bcast_addr.value, len);
-}
-
 int tipc_enable_l2_media(struct tipc_bearer *b)
 {
 	struct net_device *dev;
@@ -443,21 +421,21 @@ int tipc_enable_l2_media(struct tipc_bearer *b)
 	if (!dev)
 		return -ENODEV;
 
-	/* Associate TIPC bearer with Ethernet bearer */
+	/* Associate TIPC bearer with L2 bearer */
 	rcu_assign_pointer(b->media_ptr, dev);
-	memset(b->bcast_addr.value, 0, sizeof(b->bcast_addr.value));
+	memset(&b->bcast_addr, 0, sizeof(b->bcast_addr));
 	memcpy(b->bcast_addr.value, dev->broadcast, b->media->hwaddr_len);
 	b->bcast_addr.media_id = b->media->type_id;
 	b->bcast_addr.broadcast = 1;
 	b->mtu = dev->mtu;
-	tipc_l2_media_addr_set(b, &b->addr, (char *)dev->dev_addr);
+	b->media->raw2addr(b, &b->addr, (char *)dev->dev_addr);
 	rcu_assign_pointer(dev->tipc_ptr, b);
 	return 0;
 }
 
-/* tipc_disable_l2_media - detach TIPC bearer from an Ethernet interface
+/* tipc_disable_l2_media - detach TIPC bearer from an L2 interface
  *
- * Mark Ethernet bearer as inactive so that incoming buffers are thrown away,
+ * Mark L2 bearer as inactive so that incoming buffers are thrown away,
  * then get worker thread to complete bearer cleanup.  (Can't do cleanup
  * here because cleanup code needs to sleep and caller holds spinlocks.)
  */
@@ -473,7 +451,7 @@ void tipc_disable_l2_media(struct tipc_bearer *b)
 }
 
 /**
- * tipc_l2_send_msg - send a TIPC packet out over an Ethernet interface
+ * tipc_l2_send_msg - send a TIPC packet out over an L2 interface
  * @buf: the packet to be sent
  * @b_ptr: the bearer through which the packet is to be sent
  * @dest: peer destination address
@@ -597,7 +575,7 @@ static int tipc_l2_device_event(struct notifier_block *nb, unsigned long evt,
 		tipc_reset_bearer(b_ptr);
 		break;
 	case NETDEV_CHANGEADDR:
-		tipc_l2_media_addr_set(b_ptr, &b_ptr->addr,
+		b_ptr->media->raw2addr(b_ptr, &b_ptr->addr,
 				       (char *)dev->dev_addr);
 		tipc_reset_bearer(b_ptr);
 		break;
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index a983b30..78fccc4 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -42,14 +42,12 @@
 #define MAX_BEARERS	2
 #define MAX_MEDIA	2
 
-/*
- * Identifiers associated with TIPC message header media address info
- *
- * - address info field is 20 bytes long
- * - media type identifier located at offset 3
- * - remaining bytes vary according to media type
+/* Identifiers associated with TIPC message header media address info
+ * - address info field is 32 bytes long
+ * - the field's actual content and length is defined per media
+ * - remaining unused bytes in the field are set to zero
  */
-#define TIPC_MEDIA_ADDR_SIZE	20
+#define TIPC_MEDIA_ADDR_SIZE	32
 #define TIPC_MEDIA_TYPE_OFFSET	3
 
 /*
@@ -77,9 +75,10 @@ struct tipc_bearer;
  * @send_msg: routine which handles buffer transmission
  * @enable_media: routine which enables a media
  * @disable_media: routine which disables a media
- * @addr2str: routine which converts media address to string
- * @addr2msg: routine which converts media address to protocol message area
- * @msg2addr: routine which converts media address from protocol message area
+ * @addr2str: convert media address format to string
+ * @addr2msg: convert from media addr format to discovery msg addr format
+ * @msg2addr: convert from discovery msg addr format to media addr format
+ * @raw2addr: convert from raw addr format to media addr format
  * @priority: default link (and bearer) priority
  * @tolerance: default time (in ms) before declaring link failure
  * @window: default window (in packets) before declaring link congestion
@@ -93,10 +92,16 @@ struct tipc_media {
 			struct tipc_media_addr *dest);
 	int (*enable_media)(struct tipc_bearer *b_ptr);
 	void (*disable_media)(struct tipc_bearer *b_ptr);
-	int (*addr2str)(struct tipc_media_addr *a, char *str_buf, int str_size);
-	int (*addr2msg)(struct tipc_media_addr *a, char *msg_area);
-	int (*msg2addr)(const struct tipc_bearer *b_ptr,
-			struct tipc_media_addr *a, char *msg_area);
+	int (*addr2str)(struct tipc_media_addr *addr,
+			char *strbuf,
+			int bufsz);
+	int (*addr2msg)(char *msg, struct tipc_media_addr *addr);
+	int (*msg2addr)(struct tipc_bearer *b,
+			struct tipc_media_addr *addr,
+			char *msg);
+	int (*raw2addr)(struct tipc_bearer *b,
+			struct tipc_media_addr *addr,
+			char *raw);
 	u32 priority;
 	u32 tolerance;
 	u32 window;
@@ -175,8 +180,6 @@ int tipc_media_set_priority(const char *name, u32 new_value);
 int tipc_media_set_window(const char *name, u32 new_value);
 void tipc_media_addr_printf(char *buf, int len, struct tipc_media_addr *a);
 struct sk_buff *tipc_media_get_names(void);
-void tipc_l2_media_addr_set(const struct tipc_bearer *b,
-			    struct tipc_media_addr *a, char *mac);
 int tipc_enable_l2_media(struct tipc_bearer *b);
 void tipc_disable_l2_media(struct tipc_bearer *b);
 int tipc_l2_send_msg(struct sk_buff *buf, struct tipc_bearer *b,
diff --git a/net/tipc/core.h b/net/tipc/core.h
index 2e00682..bb26ed1 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -57,6 +57,7 @@
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
 #include <linux/rtnetlink.h>
+#include <linux/etherdevice.h>
 
 #define TIPC_MOD_VER "2.0.0"
 
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index bd35c4a..b15cbed 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -83,7 +83,7 @@ static void tipc_disc_init_msg(struct sk_buff *buf, u32 type,
 	msg_set_node_sig(msg, tipc_random);
 	msg_set_dest_domain(msg, dest_domain);
 	msg_set_bc_netid(msg, tipc_net_id);
-	b_ptr->media->addr2msg(&b_ptr->addr, msg_media_addr(msg));
+	b_ptr->media->addr2msg(msg_media_addr(msg), &b_ptr->addr);
 }
 
 /**
diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 67cf3f9..5e1426f 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -1,7 +1,7 @@
 /*
  * net/tipc/eth_media.c: Ethernet bearer support for TIPC
  *
- * Copyright (c) 2001-2007, 2013, Ericsson AB
+ * Copyright (c) 2001-2007, 2013-2014, Ericsson AB
  * Copyright (c) 2005-2008, 2011-2013, Wind River Systems
  * All rights reserved.
  *
@@ -37,39 +37,52 @@
 #include "core.h"
 #include "bearer.h"
 
-#define ETH_ADDR_OFFSET	4	/* message header offset of MAC address */
+#define ETH_ADDR_OFFSET  4  /* MAC addr position inside address field */
 
-/* convert Ethernet address to string */
-static int tipc_eth_addr2str(struct tipc_media_addr *a, char *str_buf,
-			     int str_size)
+/* Convert Ethernet address (media address format) to string */
+static int tipc_eth_addr2str(struct tipc_media_addr *addr,
+			     char *strbuf, int bufsz)
 {
-	if (str_size < 18)	/* 18 = strlen("aa:bb:cc:dd:ee:ff\0") */
+	if (bufsz < 18)	/* 18 = strlen("aa:bb:cc:dd:ee:ff\0") */
 		return 1;
 
-	sprintf(str_buf, "%pM", a->value);
+	sprintf(strbuf, "%pM", addr->value);
 	return 0;
 }
 
-/* convert Ethernet address format to message header format */
-static int tipc_eth_addr2msg(struct tipc_media_addr *a, char *msg_area)
+/* Convert from media address format to discovery message addr format */
+static int tipc_eth_addr2msg(char *msg, struct tipc_media_addr *addr)
 {
-	memset(msg_area, 0, TIPC_MEDIA_ADDR_SIZE);
-	msg_area[TIPC_MEDIA_TYPE_OFFSET] = TIPC_MEDIA_TYPE_ETH;
-	memcpy(msg_area + ETH_ADDR_OFFSET, a->value, ETH_ALEN);
+	memset(msg, 0, TIPC_MEDIA_ADDR_SIZE);
+	msg[TIPC_MEDIA_TYPE_OFFSET] = TIPC_MEDIA_TYPE_ETH;
+	memcpy(msg + ETH_ADDR_OFFSET, addr->value, ETH_ALEN);
 	return 0;
 }
 
-/* convert message header address format to Ethernet format */
-static int tipc_eth_msg2addr(const struct tipc_bearer *tb_ptr,
-			     struct tipc_media_addr *a, char *msg_area)
+/* Convert raw mac address format to media addr format */
+static int tipc_eth_raw2addr(struct tipc_bearer *b,
+			     struct tipc_media_addr *addr,
+			     char *msg)
 {
-	if (msg_area[TIPC_MEDIA_TYPE_OFFSET] != TIPC_MEDIA_TYPE_ETH)
-		return 1;
+	char bcast_mac[ETH_ALEN] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
 
-	tipc_l2_media_addr_set(tb_ptr, a, msg_area + ETH_ADDR_OFFSET);
+	memset(addr, 0, sizeof(*addr));
+	ether_addr_copy(addr->value, msg);
+	addr->media_id = TIPC_MEDIA_TYPE_ETH;
+	addr->broadcast = !memcmp(addr->value, bcast_mac, ETH_ALEN);
 	return 0;
 }
 
+/* Convert discovery msg addr format to Ethernet media addr format */
+static int tipc_eth_msg2addr(struct tipc_bearer *b,
+			     struct tipc_media_addr *addr,
+			     char *msg)
+{
+	/* Skip past preamble: */
+	msg += ETH_ADDR_OFFSET;
+	return tipc_eth_raw2addr(b, addr, msg);
+}
+
 /* Ethernet media registration info */
 struct tipc_media eth_media_info = {
 	.send_msg	= tipc_l2_send_msg,
@@ -78,6 +91,7 @@ struct tipc_media eth_media_info = {
 	.addr2str	= tipc_eth_addr2str,
 	.addr2msg	= tipc_eth_addr2msg,
 	.msg2addr	= tipc_eth_msg2addr,
+	.raw2addr	= tipc_eth_raw2addr,
 	.priority	= TIPC_DEF_LINK_PRI,
 	.tolerance	= TIPC_DEF_LINK_TOL,
 	.window		= TIPC_DEF_LINK_WIN,
@@ -85,4 +99,3 @@ struct tipc_media eth_media_info = {
 	.hwaddr_len	= ETH_ALEN,
 	.name		= "eth"
 };
-
diff --git a/net/tipc/ib_media.c b/net/tipc/ib_media.c
index 844a77e..8522eef 100644
--- a/net/tipc/ib_media.c
+++ b/net/tipc/ib_media.c
@@ -42,7 +42,7 @@
 #include "core.h"
 #include "bearer.h"
 
-/* convert InfiniBand address to string */
+/* convert InfiniBand address (media address format) media address to string */
 static int tipc_ib_addr2str(struct tipc_media_addr *a, char *str_buf,
 			    int str_size)
 {
@@ -54,23 +54,35 @@ static int tipc_ib_addr2str(struct tipc_media_addr *a, char *str_buf,
 	return 0;
 }
 
-/* convert InfiniBand address format to message header format */
-static int tipc_ib_addr2msg(struct tipc_media_addr *a, char *msg_area)
+/* Convert from media address format to discovery message addr format */
+static int tipc_ib_addr2msg(char *msg, struct tipc_media_addr *addr)
 {
-	memset(msg_area, 0, TIPC_MEDIA_ADDR_SIZE);
-	msg_area[TIPC_MEDIA_TYPE_OFFSET] = TIPC_MEDIA_TYPE_IB;
-	memcpy(msg_area, a->value, INFINIBAND_ALEN);
+	memset(msg, 0, TIPC_MEDIA_ADDR_SIZE);
+	memcpy(msg, addr->value, INFINIBAND_ALEN);
 	return 0;
 }
 
-/* convert message header address format to InfiniBand format */
-static int tipc_ib_msg2addr(const struct tipc_bearer *tb_ptr,
-			    struct tipc_media_addr *a, char *msg_area)
+/* Convert raw InfiniBand address format to media addr format */
+static int tipc_ib_raw2addr(struct tipc_bearer *b,
+			    struct tipc_media_addr *addr,
+			    char *msg)
 {
-	tipc_l2_media_addr_set(tb_ptr, a, msg_area);
+	memset(addr, 0, sizeof(*addr));
+	memcpy(addr->value, msg, INFINIBAND_ALEN);
+	addr->media_id = TIPC_MEDIA_TYPE_IB;
+	addr->broadcast = !memcmp(msg, b->bcast_addr.value,
+				  INFINIBAND_ALEN);
 	return 0;
 }
 
+/* Convert discovery msg addr format to InfiniBand media addr format */
+static int tipc_ib_msg2addr(struct tipc_bearer *b,
+			    struct tipc_media_addr *addr,
+			    char *msg)
+{
+	return tipc_ib_raw2addr(b, addr, msg);
+}
+
 /* InfiniBand media registration info */
 struct tipc_media ib_media_info = {
 	.send_msg	= tipc_l2_send_msg,
@@ -79,6 +91,7 @@ struct tipc_media ib_media_info = {
 	.addr2str	= tipc_ib_addr2str,
 	.addr2msg	= tipc_ib_addr2msg,
 	.msg2addr	= tipc_ib_msg2addr,
+	.raw2addr	= tipc_ib_raw2addr,
 	.priority	= TIPC_DEF_LINK_PRI,
 	.tolerance	= TIPC_DEF_LINK_TOL,
 	.window		= TIPC_DEF_LINK_WIN,
@@ -86,4 +99,3 @@ struct tipc_media ib_media_info = {
 	.hwaddr_len	= INFINIBAND_ALEN,
 	.name		= "ib"
 };
-
-- 
1.7.9.5


------------------------------------------------------------------------------
"Accelerate Dev Cycles with Automated Cross-Browser Testing - For FREE
Instantly run your Selenium tests across 300+ browser/OS combos.
Get unparalleled scalability from the best Selenium testing platform available
Simple to use. Nothing to install. Get started now for free."
http://p.sf.net/sfu/SauceLabs
