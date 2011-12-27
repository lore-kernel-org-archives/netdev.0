From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 08/23] tipc: Hide media-specific addressing details from generic bearer code
Date: Tue, 27 Dec 2011 12:39:27 -0500
Message-ID: <1325007582-31610-9-git-send-email-paul.gortmaker@windriver.com>
References: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39393 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754794Ab1L0RkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 12:40:00 -0500
In-Reply-To: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Reworks TIPC's media address data structure and associated processing
routines to transfer all media-specific details of address conversion
to the associated TIPC media adaptation code. TIPC's generic bearer code
now only needs to know which media type an address is associated with
and whether or not it is a broadcast address, and totally ignores the
"value" field that contains the actual media-specific addressing info.

These changes eliminate the need for a number of endianness conversion
operations and will make it easier for TIPC to support new media types
in the future.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bearer.c    |   14 ++++++--------
 net/tipc/bearer.h    |   17 ++++++++---------
 net/tipc/discover.c  |    4 ++--
 net/tipc/eth_media.c |   22 +++++++++++++---------
 net/tipc/msg.c       |    9 ++++++---
 net/tipc/msg.h       |   16 ++++++----------
 6 files changed, 41 insertions(+), 41 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 17652f2..aa37261 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -108,7 +108,8 @@ int  tipc_register_media(struct media *m_ptr)
 
 	if (!media_name_valid(m_ptr->name))
 		goto exit;
-	if (m_ptr->bcast_addr.type != htonl(m_ptr->type_id))
+	if ((m_ptr->bcast_addr.media_id != m_ptr->type_id) ||
+	    !m_ptr->bcast_addr.broadcast)
 		goto exit;
 	if (m_ptr->priority > TIPC_MAX_LINK_PRI)
 		goto exit;
@@ -138,20 +139,17 @@ void tipc_media_addr_printf(struct print_buf *pb, struct tipc_media_addr *a)
 {
 	char addr_str[MAX_ADDR_STR];
 	struct media *m_ptr;
-	u32 media_type;
 
-	media_type = ntohl(a->type);
-	m_ptr = media_find_id(media_type);
+	m_ptr = media_find_id(a->media_id);
 
 	if (m_ptr && !m_ptr->addr2str(a, addr_str, sizeof(addr_str)))
 		tipc_printf(pb, "%s(%s)", m_ptr->name, addr_str);
 	else {
-		unchar *addr = (unchar *)&a->dev_addr;
 		u32 i;
 
-		tipc_printf(pb, "UNKNOWN(%u)", media_type);
-		for (i = 0; i < (sizeof(*a) - sizeof(a->type)); i++)
-			tipc_printf(pb, "-%02x", addr[i]);
+		tipc_printf(pb, "UNKNOWN(%u)", a->media_id);
+		for (i = 0; i < sizeof(a->value); i++)
+			tipc_printf(pb, "-%02x", a->value[i]);
 	}
 }
 
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 41a61d2..54a5a57 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -59,17 +59,16 @@
 #define TIPC_MEDIA_TYPE_ETH	1
 
 /*
- * Destination address structure used by TIPC bearers when sending messages
- *
- * IMPORTANT: The fields of this structure MUST be stored using the specified
- * byte order indicated below, as the structure is exchanged between nodes
- * as part of a link setup process.
+ * struct tipc_media_addr - destination address used by TIPC bearers
+ * @value: address info (format defined by media)
+ * @media_id: TIPC media type identifier
+ * @broadcast: non-zero if address is a broadcast address
  */
+
 struct tipc_media_addr {
-	__be32  type;			/* bearer type (network byte order) */
-	union {
-		__u8   eth_addr[6];	/* 48 bit Ethernet addr (byte array) */
-	} dev_addr;
+	u8 value[TIPC_MEDIA_ADDR_SIZE];
+	u8 media_id;
+	u8 broadcast;
 };
 
 struct tipc_bearer;
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index f2fb96e..1ea2d44 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -84,7 +84,7 @@ static struct sk_buff *tipc_disc_init_msg(u32 type,
 		msg_set_non_seq(msg, 1);
 		msg_set_dest_domain(msg, dest_domain);
 		msg_set_bc_netid(msg, tipc_net_id);
-		msg_set_media_addr(msg, &b_ptr->addr);
+		b_ptr->media->addr2msg(&b_ptr->addr, msg_media_addr(msg));
 	}
 	return buf;
 }
@@ -130,7 +130,7 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 	u32 type = msg_type(msg);
 	int link_fully_up;
 
-	msg_get_media_addr(msg, &media_addr);
+	b_ptr->media->msg2addr(&media_addr, msg_media_addr(msg));
 	buf_discard(buf);
 
 	/* Validate discovery message from requesting node */
diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index ebba0fc..3b75c0d 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -54,18 +54,24 @@ struct eth_bearer {
 	struct packet_type tipc_packet_type;
 };
 
+static struct media eth_media_info;
 static struct eth_bearer eth_bearers[MAX_ETH_BEARERS];
 static int eth_started;
 static struct notifier_block notifier;
 
 /**
  * eth_media_addr_set - initialize Ethernet media address structure
+ *
+ * Media-dependent "value" field stores MAC address in first 6 bytes
+ * and zeroes out the remaining bytes.
  */
 
 static void eth_media_addr_set(struct tipc_media_addr *a, char *mac)
 {
-	a->type = htonl(TIPC_MEDIA_TYPE_ETH);
-	memcpy(&a->dev_addr.eth_addr, mac, ETH_ALEN);
+	memcpy(a->value, mac, ETH_ALEN);
+	memset(a->value + ETH_ALEN, 0, sizeof(a->value) - ETH_ALEN);
+	a->media_id = TIPC_MEDIA_TYPE_ETH;
+	a->broadcast = !memcmp(mac, eth_media_info.bcast_addr.value, ETH_ALEN);
 }
 
 /**
@@ -94,7 +100,7 @@ static int send_msg(struct sk_buff *buf, struct tipc_bearer *tb_ptr,
 
 	skb_reset_network_header(clone);
 	clone->dev = dev;
-	dev_hard_header(clone, dev, ETH_P_TIPC, &dest->dev_addr.eth_addr,
+	dev_hard_header(clone, dev, ETH_P_TIPC, dest->value,
 			dev->dev_addr, clone->len);
 	dev_queue_xmit(clone);
 	return 0;
@@ -256,12 +262,10 @@ static int recv_notification(struct notifier_block *nb, unsigned long evt,
 
 static int eth_addr2str(struct tipc_media_addr *a, char *str_buf, int str_size)
 {
-	unchar *addr = (unchar *)&a->dev_addr;
-
 	if (str_size < 18)	/* 18 = strlen("aa:bb:cc:dd:ee:ff\0") */
 		return 1;
 
-	sprintf(str_buf, "%pM", addr);
+	sprintf(str_buf, "%pM", a->value);
 	return 0;
 }
 
@@ -293,7 +297,7 @@ static int eth_addr2msg(struct tipc_media_addr *a, char *msg_area)
 {
 	memset(msg_area, 0, TIPC_MEDIA_ADDR_SIZE);
 	msg_area[TIPC_MEDIA_TYPE_OFFSET] = TIPC_MEDIA_TYPE_ETH;
-	memcpy(msg_area + ETH_ADDR_OFFSET, a->dev_addr.eth_addr, ETH_ALEN);
+	memcpy(msg_area + ETH_ADDR_OFFSET, a->value, ETH_ALEN);
 	return 0;
 }
 
@@ -322,8 +326,8 @@ static struct media eth_media_info = {
 	.str2addr	= eth_str2addr,
 	.addr2msg	= eth_addr2msg,
 	.msg2addr	= eth_msg2addr,
-	.bcast_addr	= { htonl(TIPC_MEDIA_TYPE_ETH),
-			    { {0xff, 0xff, 0xff, 0xff, 0xff, 0xff} } },
+	.bcast_addr	= { { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff },
+			    TIPC_MEDIA_TYPE_ETH, 1 },
 	.priority	= TIPC_DEF_LINK_PRI,
 	.tolerance	= TIPC_DEF_LINK_TOL,
 	.window		= TIPC_DEF_LINK_WIN,
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 83d5096..3e4d3e2 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -333,11 +333,14 @@ void tipc_msg_dbg(struct print_buf *buf, struct tipc_msg *msg, const char *str)
 	}
 
 	if (msg_user(msg) ==  LINK_CONFIG) {
-		u32 *raw = (u32 *)msg;
-		struct tipc_media_addr *orig = (struct tipc_media_addr *)&raw[5];
+		struct tipc_media_addr orig;
+
 		tipc_printf(buf, ":DDOM(%x):", msg_dest_domain(msg));
 		tipc_printf(buf, ":NETID(%u):", msg_bc_netid(msg));
-		tipc_media_addr_printf(buf, orig);
+		memcpy(orig.value, msg_media_addr(msg), sizeof(orig.value));
+		orig.media_id = 0;
+		orig.broadcast = 0;
+		tipc_media_addr_printf(buf, &orig);
 	}
 	if (msg_user(msg) == BCAST_PROTOCOL) {
 		tipc_printf(buf, "BCNACK:AFTER(%u):", msg_bcgap_after(msg));
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index d93178f..7b0cda1 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -78,6 +78,8 @@
 
 #define MAX_MSG_SIZE (MAX_H_SIZE + TIPC_MAX_USER_MSG_SIZE)
 
+#define TIPC_MEDIA_ADDR_OFFSET	5
+
 
 struct tipc_msg {
 	__be32 hdr[15];
@@ -682,6 +684,10 @@ static inline void msg_set_redundant_link(struct tipc_msg *m, u32 r)
 	msg_set_bits(m, 5, 12, 0x1, r);
 }
 
+static inline char *msg_media_addr(struct tipc_msg *m)
+{
+	return (char *)&m->hdr[TIPC_MEDIA_ADDR_OFFSET];
+}
 
 /*
  * Word 9
@@ -734,14 +740,4 @@ int tipc_msg_build(struct tipc_msg *hdr, struct iovec const *msg_sect,
 		   u32 num_sect, unsigned int total_len,
 			    int max_size, int usrmem, struct sk_buff **buf);
 
-static inline void msg_set_media_addr(struct tipc_msg *m, struct tipc_media_addr *a)
-{
-	memcpy(&((int *)m)[5], a, sizeof(*a));
-}
-
-static inline void msg_get_media_addr(struct tipc_msg *m, struct tipc_media_addr *a)
-{
-	memcpy(a, &((int *)m)[5], sizeof(*a));
-}
-
 #endif
-- 
1.7.4.4
