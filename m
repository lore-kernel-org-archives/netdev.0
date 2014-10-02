From: <richard.alpe@ericsson.com>
Subject: [PATCH v2 net-next 15/15] tipc: remove old ASCII
	netlink API
Date: Thu, 2 Oct 2014 16:58:41 +0200
Message-ID: <1412261921-28510-16-git-send-email-richard.alpe@ericsson.com>
References: <1412261921-28510-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1412261921-28510-1-git-send-email-richard.alpe@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Richard Alpe <richard.alpe@ericsson.com>

The API has been deprecated along with its user-space tool
"tipc-config". Users shall use the new kernel netlink API already in
place along with the new user space tool "tipc" that's part of the
tipc-utils package.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
---
 include/uapi/linux/tipc_config.h |  299 +--------------------------------
 net/tipc/Makefile                |    2 +-
 net/tipc/bcast.c                 |   41 -----
 net/tipc/bcast.h                 |    1 -
 net/tipc/bearer.c                |   65 --------
 net/tipc/bearer.h                |    1 -
 net/tipc/config.c                |  342 --------------------------------------
 net/tipc/config.h                |   67 --------
 net/tipc/core.c                  |    3 +-
 net/tipc/link.c                  |  311 ----------------------------------
 net/tipc/link.h                  |    7 -
 net/tipc/log.c                   |    1 -
 net/tipc/name_table.c            |  185 +--------------------
 net/tipc/name_table.h            |    1 +
 net/tipc/net.c                   |    1 -
 net/tipc/netlink.c               |   36 ----
 net/tipc/node.c                  |  113 +------------
 net/tipc/node.h                  |    2 -
 net/tipc/socket.c                |   77 ---------
 net/tipc/socket.h                |    1 -
 20 files changed, 8 insertions(+), 1548 deletions(-)
 delete mode 100644 net/tipc/config.c
 delete mode 100644 net/tipc/config.h

diff --git a/include/uapi/linux/tipc_config.h b/include/uapi/linux/tipc_config.h
index d52ebec..cb95d10 100644
--- a/include/uapi/linux/tipc_config.h
+++ b/include/uapi/linux/tipc_config.h
@@ -38,13 +38,6 @@
 #define _LINUX_TIPC_CONFIG_H_
 
 #include <linux/types.h>
-#include <linux/string.h>
-#include <linux/tipc.h>
-#include <asm/byteorder.h>
-
-#ifndef __KERNEL__
-#include <arpa/inet.h> /* for ntohs etc. */
-#endif
 
 /* Netlink commands */
 enum {
@@ -250,115 +243,6 @@ enum {
 };
 
 /*
- * Configuration
- *
- * All configuration management messaging involves sending a request message
- * to the TIPC configuration service on a node, which sends a reply message
- * back.  (In the future multi-message replies may be supported.)
- *
- * Both request and reply messages consist of a transport header and payload.
- * The transport header contains info about the desired operation;
- * the payload consists of zero or more type/length/value (TLV) items
- * which specify parameters or results for the operation.
- *
- * For many operations, the request and reply messages have a fixed number
- * of TLVs (usually zero or one); however, some reply messages may return
- * a variable number of TLVs.  A failed request is denoted by the presence
- * of an "error string" TLV in the reply message instead of the TLV(s) the
- * reply should contain if the request succeeds.
- */
-
-/*
- * Public commands:
- * May be issued by any process.
- * Accepted by own node, or by remote node only if remote management enabled.
- */
-
-#define  TIPC_CMD_NOOP              0x0000    /* tx none, rx none */
-#define  TIPC_CMD_GET_NODES         0x0001    /* tx net_addr, rx node_info(s) */
-#define  TIPC_CMD_GET_MEDIA_NAMES   0x0002    /* tx none, rx media_name(s) */
-#define  TIPC_CMD_GET_BEARER_NAMES  0x0003    /* tx none, rx bearer_name(s) */
-#define  TIPC_CMD_GET_LINKS         0x0004    /* tx net_addr, rx link_info(s) */
-#define  TIPC_CMD_SHOW_NAME_TABLE   0x0005    /* tx name_tbl_query, rx ultra_string */
-#define  TIPC_CMD_SHOW_PORTS        0x0006    /* tx none, rx ultra_string */
-#define  TIPC_CMD_SHOW_LINK_STATS   0x000B    /* tx link_name, rx ultra_string */
-#define  TIPC_CMD_SHOW_STATS        0x000F    /* tx unsigned, rx ultra_string */
-
-/*
- * Protected commands:
- * May only be issued by "network administration capable" process.
- * Accepted by own node, or by remote node only if remote management enabled
- * and this node is zone manager.
- */
-
-#define  TIPC_CMD_GET_REMOTE_MNG    0x4003    /* tx none, rx unsigned */
-#define  TIPC_CMD_GET_MAX_PORTS     0x4004    /* tx none, rx unsigned */
-#define  TIPC_CMD_GET_MAX_PUBL      0x4005    /* obsoleted */
-#define  TIPC_CMD_GET_MAX_SUBSCR    0x4006    /* obsoleted */
-#define  TIPC_CMD_GET_MAX_ZONES     0x4007    /* obsoleted */
-#define  TIPC_CMD_GET_MAX_CLUSTERS  0x4008    /* obsoleted */
-#define  TIPC_CMD_GET_MAX_NODES     0x4009    /* obsoleted */
-#define  TIPC_CMD_GET_MAX_SLAVES    0x400A    /* obsoleted */
-#define  TIPC_CMD_GET_NETID         0x400B    /* tx none, rx unsigned */
-
-#define  TIPC_CMD_ENABLE_BEARER     0x4101    /* tx bearer_config, rx none */
-#define  TIPC_CMD_DISABLE_BEARER    0x4102    /* tx bearer_name, rx none */
-#define  TIPC_CMD_SET_LINK_TOL      0x4107    /* tx link_config, rx none */
-#define  TIPC_CMD_SET_LINK_PRI      0x4108    /* tx link_config, rx none */
-#define  TIPC_CMD_SET_LINK_WINDOW   0x4109    /* tx link_config, rx none */
-#define  TIPC_CMD_SET_LOG_SIZE      0x410A    /* obsoleted */
-#define  TIPC_CMD_DUMP_LOG          0x410B    /* obsoleted */
-#define  TIPC_CMD_RESET_LINK_STATS  0x410C    /* tx link_name, rx none */
-
-/*
- * Private commands:
- * May only be issued by "network administration capable" process.
- * Accepted by own node only; cannot be used on a remote node.
- */
-
-#define  TIPC_CMD_SET_NODE_ADDR     0x8001    /* tx net_addr, rx none */
-#define  TIPC_CMD_SET_REMOTE_MNG    0x8003    /* tx unsigned, rx none */
-#define  TIPC_CMD_SET_MAX_PORTS     0x8004    /* tx unsigned, rx none */
-#define  TIPC_CMD_SET_MAX_PUBL      0x8005    /* obsoleted */
-#define  TIPC_CMD_SET_MAX_SUBSCR    0x8006    /* obsoleted */
-#define  TIPC_CMD_SET_MAX_ZONES     0x8007    /* obsoleted */
-#define  TIPC_CMD_SET_MAX_CLUSTERS  0x8008    /* obsoleted */
-#define  TIPC_CMD_SET_MAX_NODES     0x8009    /* obsoleted */
-#define  TIPC_CMD_SET_MAX_SLAVES    0x800A    /* obsoleted */
-#define  TIPC_CMD_SET_NETID         0x800B    /* tx unsigned, rx none */
-
-/*
- * Reserved commands:
- * May not be issued by any process.
- * Used internally by TIPC.
- */
-
-#define  TIPC_CMD_NOT_NET_ADMIN     0xC001    /* tx none, rx none */
-
-/*
- * TLV types defined for TIPC
- */
-
-#define TIPC_TLV_NONE		0	/* no TLV present */
-#define TIPC_TLV_VOID		1	/* empty TLV (0 data bytes)*/
-#define TIPC_TLV_UNSIGNED	2	/* 32-bit integer */
-#define TIPC_TLV_STRING		3	/* char[128] (max) */
-#define TIPC_TLV_LARGE_STRING	4	/* char[2048] (max) */
-#define TIPC_TLV_ULTRA_STRING	5	/* char[32768] (max) */
-
-#define TIPC_TLV_ERROR_STRING	16	/* char[128] containing "error code" */
-#define TIPC_TLV_NET_ADDR	17	/* 32-bit integer denoting <Z.C.N> */
-#define TIPC_TLV_MEDIA_NAME	18	/* char[TIPC_MAX_MEDIA_NAME] */
-#define TIPC_TLV_BEARER_NAME	19	/* char[TIPC_MAX_BEARER_NAME] */
-#define TIPC_TLV_LINK_NAME	20	/* char[TIPC_MAX_LINK_NAME] */
-#define TIPC_TLV_NODE_INFO	21	/* struct tipc_node_info */
-#define TIPC_TLV_LINK_INFO	22	/* struct tipc_link_info */
-#define TIPC_TLV_BEARER_CONFIG	23	/* struct tipc_bearer_config */
-#define TIPC_TLV_LINK_CONFIG	24	/* struct tipc_link_config */
-#define TIPC_TLV_NAME_TBL_QUERY	25	/* struct tipc_name_table_query */
-#define TIPC_TLV_PORT_REF	26	/* 32-bit port reference */
-
-/*
  * Link priority limits (min, default, max, media default)
  */
 
@@ -387,172 +271,17 @@ enum {
 #define TIPC_DEF_LINK_WIN 50
 #define TIPC_MAX_LINK_WIN 8191
 
-
-struct tipc_node_info {
-	__be32 addr;			/* network address of node */
-	__be32 up;			/* 0=down, 1= up */
-};
-
-struct tipc_link_info {
-	__be32 dest;			/* network address of peer node */
-	__be32 up;			/* 0=down, 1=up */
-	char str[TIPC_MAX_LINK_NAME];	/* link name */
-};
-
-struct tipc_bearer_config {
-	__be32 priority;		/* Range [1,31]. Override per link  */
-	__be32 disc_domain;		/* <Z.C.N> describing desired nodes */
-	char name[TIPC_MAX_BEARER_NAME];
-};
-
-struct tipc_link_config {
-	__be32 value;
-	char name[TIPC_MAX_LINK_NAME];
-};
-
-#define TIPC_NTQ_ALLTYPES 0x80000000
-
-struct tipc_name_table_query {
-	__be32 depth;	/* 1:type, 2:+name info, 3:+port info, 4+:+debug info */
-	__be32 type;	/* {t,l,u} info ignored if high bit of "depth" is set */
-	__be32 lowbound; /* (i.e. displays all entries of name table) */
-	__be32 upbound;
-};
-
-/*
- * The error string TLV is a null-terminated string describing the cause
- * of the request failure.  To simplify error processing (and to save space)
- * the first character of the string can be a special error code character
- * (lying by the range 0x80 to 0xFF) which represents a pre-defined reason.
- */
-
-#define TIPC_CFG_TLV_ERROR      "\x80"  /* request contains incorrect TLV(s) */
-#define TIPC_CFG_NOT_NET_ADMIN  "\x81"	/* must be network administrator */
-#define TIPC_CFG_NOT_ZONE_MSTR	"\x82"	/* must be zone master */
-#define TIPC_CFG_NO_REMOTE	"\x83"	/* remote management not enabled */
-#define TIPC_CFG_NOT_SUPPORTED  "\x84"	/* request is not supported by TIPC */
-#define TIPC_CFG_INVALID_VALUE  "\x85"  /* request has invalid argument value */
-
-/*
- * A TLV consists of a descriptor, followed by the TLV value.
- * TLV descriptor fields are stored in network byte order;
- * TLV values must also be stored in network byte order (where applicable).
- * TLV descriptors must be aligned to addresses which are multiple of 4,
- * so up to 3 bytes of padding may exist at the end of the TLV value area.
- * There must not be any padding between the TLV descriptor and its value.
- */
-
-struct tlv_desc {
-	__be16 tlv_len;		/* TLV length (descriptor + value) */
-	__be16 tlv_type;		/* TLV identifier */
-};
-
-#define TLV_ALIGNTO 4
-
-#define TLV_ALIGN(datalen) (((datalen)+(TLV_ALIGNTO-1)) & ~(TLV_ALIGNTO-1))
-#define TLV_LENGTH(datalen) (sizeof(struct tlv_desc) + (datalen))
-#define TLV_SPACE(datalen) (TLV_ALIGN(TLV_LENGTH(datalen)))
-#define TLV_DATA(tlv) ((void *)((char *)(tlv) + TLV_LENGTH(0)))
-
-static inline int TLV_OK(const void *tlv, __u16 space)
-{
-	/*
-	 * Would also like to check that "tlv" is a multiple of 4,
-	 * but don't know how to do this in a portable way.
-	 * - Tried doing (!(tlv & (TLV_ALIGNTO-1))), but GCC compiler
-	 *   won't allow binary "&" with a pointer.
-	 * - Tried casting "tlv" to integer type, but causes warning about size
-	 *   mismatch when pointer is bigger than chosen type (int, long, ...).
-	 */
-
-	return (space >= TLV_SPACE(0)) &&
-		(ntohs(((struct tlv_desc *)tlv)->tlv_len) <= space);
-}
-
-static inline int TLV_CHECK(const void *tlv, __u16 space, __u16 exp_type)
-{
-	return TLV_OK(tlv, space) &&
-		(ntohs(((struct tlv_desc *)tlv)->tlv_type) == exp_type);
-}
-
-static inline int TLV_SET(void *tlv, __u16 type, void *data, __u16 len)
-{
-	struct tlv_desc *tlv_ptr;
-	int tlv_len;
-
-	tlv_len = TLV_LENGTH(len);
-	tlv_ptr = (struct tlv_desc *)tlv;
-	tlv_ptr->tlv_type = htons(type);
-	tlv_ptr->tlv_len  = htons(tlv_len);
-	if (len && data)
-		memcpy(TLV_DATA(tlv_ptr), data, tlv_len);
-	return TLV_SPACE(len);
-}
-
-/*
- * A TLV list descriptor simplifies processing of messages
- * containing multiple TLVs.
- */
-
-struct tlv_list_desc {
-	struct tlv_desc *tlv_ptr;	/* ptr to current TLV */
-	__u32 tlv_space;		/* # bytes from curr TLV to list end */
-};
-
-static inline void TLV_LIST_INIT(struct tlv_list_desc *list,
-				 void *data, __u32 space)
-{
-	list->tlv_ptr = (struct tlv_desc *)data;
-	list->tlv_space = space;
-}
-
-static inline int TLV_LIST_EMPTY(struct tlv_list_desc *list)
-{
-	return (list->tlv_space == 0);
-}
-
-static inline int TLV_LIST_CHECK(struct tlv_list_desc *list, __u16 exp_type)
-{
-	return TLV_CHECK(list->tlv_ptr, list->tlv_space, exp_type);
-}
-
-static inline void *TLV_LIST_DATA(struct tlv_list_desc *list)
-{
-	return TLV_DATA(list->tlv_ptr);
-}
-
-static inline void TLV_LIST_STEP(struct tlv_list_desc *list)
-{
-	__u16 tlv_space = TLV_ALIGN(ntohs(list->tlv_ptr->tlv_len));
-
-	list->tlv_ptr = (struct tlv_desc *)((char *)list->tlv_ptr + tlv_space);
-	list->tlv_space -= tlv_space;
-}
-
 /*
  * Configuration messages exchanged via NETLINK_GENERIC use the following
  * family id, name, version and command.
  */
 #define TIPC_GENL_NAME		"TIPC"
 #define TIPC_GENL_VERSION	0x1
-#define TIPC_GENL_CMD		0x1
-
-/*
- * TIPC specific header used in NETLINK_GENERIC requests.
- */
-struct tipc_genlmsghdr {
-	__u32 dest;		/* Destination address */
-	__u16 cmd;		/* Command */
-	__u16 reserved;		/* Unused */
-};
-
-#define TIPC_GENL_HDRLEN	NLMSG_ALIGN(sizeof(struct tipc_genlmsghdr))
 
 /*
  * Configuration messages exchanged via TIPC sockets use the TIPC configuration
- * message header, which is defined below.  This structure is analogous
- * to the Netlink message header, but fields are stored in network byte order
- * and no padding is permitted between the header and the message data
+ * message header, which is defined below. Fields are stored in network byte
+ * order and no padding is permitted between the header and the message data
  * that follows.
  */
 
@@ -563,28 +292,4 @@ struct tipc_cfg_msg_hdr {
 	char  tcm_reserved[8];	/* Unused */
 };
 
-#define TCM_F_REQUEST	0x1	/* Flag: Request message */
-#define TCM_F_MORE	0x2	/* Flag: Message to be continued */
-
-#define TCM_ALIGN(datalen)  (((datalen)+3) & ~3)
-#define TCM_LENGTH(datalen) (sizeof(struct tipc_cfg_msg_hdr) + datalen)
-#define TCM_SPACE(datalen)  (TCM_ALIGN(TCM_LENGTH(datalen)))
-#define TCM_DATA(tcm_hdr)   ((void *)((char *)(tcm_hdr) + TCM_LENGTH(0)))
-
-static inline int TCM_SET(void *msg, __u16 cmd, __u16 flags,
-			  void *data, __u16 data_len)
-{
-	struct tipc_cfg_msg_hdr *tcm_hdr;
-	int msg_len;
-
-	msg_len = TCM_LENGTH(data_len);
-	tcm_hdr = (struct tipc_cfg_msg_hdr *)msg;
-	tcm_hdr->tcm_len   = htonl(msg_len);
-	tcm_hdr->tcm_type  = htons(cmd);
-	tcm_hdr->tcm_flags = htons(flags);
-	if (data_len && data)
-		memcpy(TCM_DATA(msg), data, data_len);
-	return TCM_SPACE(data_len);
-}
-
 #endif
diff --git a/net/tipc/Makefile b/net/tipc/Makefile
index b8a13ca..c68864f 100644
--- a/net/tipc/Makefile
+++ b/net/tipc/Makefile
@@ -4,7 +4,7 @@
 
 obj-$(CONFIG_TIPC) := tipc.o
 
-tipc-y	+= addr.o bcast.o bearer.o config.o \
+tipc-y	+= addr.o bcast.o bearer.o \
 	   core.o link.o discover.o msg.o  \
 	   name_distr.o  subscr.o name_table.o net.o  \
 	   netlink.o node.o node_subscr.o \
diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index e12476b..473f3a1 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -867,47 +867,6 @@ msg_full:
 	return -EMSGSIZE;
 }
 
-int tipc_bclink_stats(char *buf, const u32 buf_size)
-{
-	int ret;
-	struct tipc_stats *s;
-
-	if (!bcl)
-		return 0;
-
-	tipc_bclink_lock();
-
-	s = &bcl->stats;
-
-	ret = tipc_snprintf(buf, buf_size, "Link <%s>\n"
-			    "  Window:%u packets\n",
-			    bcl->name, bcl->queue_limit[0]);
-	ret += tipc_snprintf(buf + ret, buf_size - ret,
-			     "  RX packets:%u fragments:%u/%u bundles:%u/%u\n",
-			     s->recv_info, s->recv_fragments,
-			     s->recv_fragmented, s->recv_bundles,
-			     s->recv_bundled);
-	ret += tipc_snprintf(buf + ret, buf_size - ret,
-			     "  TX packets:%u fragments:%u/%u bundles:%u/%u\n",
-			     s->sent_info, s->sent_fragments,
-			     s->sent_fragmented, s->sent_bundles,
-			     s->sent_bundled);
-	ret += tipc_snprintf(buf + ret, buf_size - ret,
-			     "  RX naks:%u defs:%u dups:%u\n",
-			     s->recv_nacks, s->deferred_recv, s->duplicates);
-	ret += tipc_snprintf(buf + ret, buf_size - ret,
-			     "  TX naks:%u acks:%u dups:%u\n",
-			     s->sent_nacks, s->sent_acks, s->retransmitted);
-	ret += tipc_snprintf(buf + ret, buf_size - ret,
-			     "  Congestion link:%u  Send queue max:%u avg:%u\n",
-			     s->link_congs, s->max_queue_sz,
-			     s->queue_sz_counts ?
-			     (s->accu_queue_sz / s->queue_sz_counts) : 0);
-
-	tipc_bclink_unlock();
-	return ret;
-}
-
 int tipc_bclink_reset_stats(void)
 {
 	if (!bcl)
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index 3c0263e..2c2443a 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -95,7 +95,6 @@ void tipc_bclink_rcv(struct sk_buff *buf);
 u32  tipc_bclink_get_last_sent(void);
 u32  tipc_bclink_acks_missing(struct tipc_node *n_ptr);
 void tipc_bclink_update_link_state(struct tipc_node *n_ptr, u32 last_sent);
-int  tipc_bclink_stats(char *stats_buf, const u32 buf_size);
 int  tipc_bclink_reset_stats(void);
 int  tipc_bclink_set_queue_limits(u32 limit);
 void tipc_bcbearer_sort(struct tipc_node_map *nm_ptr, u32 node, bool action);
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 3e33771..6798219 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -35,7 +35,6 @@
  */
 
 #include "core.h"
-#include "config.h"
 #include "bearer.h"
 #include "link.h"
 #include "discover.h"
@@ -123,26 +122,6 @@ void tipc_media_addr_printf(char *buf, int len, struct tipc_media_addr *a)
 }
 
 /**
- * tipc_media_get_names - record names of registered media in buffer
- */
-struct sk_buff *tipc_media_get_names(void)
-{
-	struct sk_buff *buf;
-	int i;
-
-	buf = tipc_cfg_reply_alloc(MAX_MEDIA * TLV_SPACE(TIPC_MAX_MEDIA_NAME));
-	if (!buf)
-		return NULL;
-
-	for (i = 0; media_info_array[i] != NULL; i++) {
-		tipc_cfg_append_tlv(buf, TIPC_TLV_MEDIA_NAME,
-				    media_info_array[i]->name,
-				    strlen(media_info_array[i]->name) + 1);
-	}
-	return buf;
-}
-
-/**
  * bearer_name_validate - validate & (optionally) deconstruct bearer name
  * @name: ptr to bearer name string
  * @name_parts: ptr to area for bearer name components (or NULL if not needed)
@@ -203,34 +182,6 @@ struct tipc_bearer *tipc_bearer_find(const char *name)
 	return NULL;
 }
 
-/**
- * tipc_bearer_get_names - record names of bearers in buffer
- */
-struct sk_buff *tipc_bearer_get_names(void)
-{
-	struct sk_buff *buf;
-	struct tipc_bearer *b;
-	int i, j;
-
-	buf = tipc_cfg_reply_alloc(MAX_BEARERS * TLV_SPACE(TIPC_MAX_BEARER_NAME));
-	if (!buf)
-		return NULL;
-
-	for (i = 0; media_info_array[i] != NULL; i++) {
-		for (j = 0; j < MAX_BEARERS; j++) {
-			b = rtnl_dereference(bearer_list[j]);
-			if (!b)
-				continue;
-			if (b->media == media_info_array[i]) {
-				tipc_cfg_append_tlv(buf, TIPC_TLV_BEARER_NAME,
-						    b->name,
-						    strlen(b->name) + 1);
-			}
-		}
-	}
-	return buf;
-}
-
 void tipc_bearer_add_dest(u32 bearer_id, u32 dest)
 {
 	struct tipc_bearer *b_ptr;
@@ -413,22 +364,6 @@ static void bearer_disable(struct tipc_bearer *b_ptr, bool shutting_down)
 	kfree_rcu(b_ptr, rcu);
 }
 
-int tipc_disable_bearer(const char *name)
-{
-	struct tipc_bearer *b_ptr;
-	int res;
-
-	b_ptr = tipc_bearer_find(name);
-	if (b_ptr == NULL) {
-		pr_warn("Attempt to disable unknown bearer <%s>\n", name);
-		res = -EINVAL;
-	} else {
-		bearer_disable(b_ptr, false);
-		res = 0;
-	}
-	return res;
-}
-
 int tipc_enable_l2_media(struct tipc_bearer *b)
 {
 	struct net_device *dev;
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index b1d9052..8550ec8 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -167,7 +167,6 @@ extern struct tipc_bearer __rcu *bearer_list[];
 
 void tipc_rcv(struct sk_buff *buf, struct tipc_bearer *tb_ptr);
 int tipc_enable_bearer(const char *bearer_name, u32 disc_domain, u32 priority);
-int tipc_disable_bearer(const char *name);
 
 /*
  * Routines made available to TIPC by supported media types
diff --git a/net/tipc/config.c b/net/tipc/config.c
deleted file mode 100644
index 876f4c6..0000000
--- a/net/tipc/config.c
+++ /dev/null
@@ -1,342 +0,0 @@
-/*
- * net/tipc/config.c: TIPC configuration management code
- *
- * Copyright (c) 2002-2006, Ericsson AB
- * Copyright (c) 2004-2007, 2010-2013, Wind River Systems
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions are met:
- *
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the names of the copyright holders nor the names of its
- *    contributors may be used to endorse or promote products derived from
- *    this software without specific prior written permission.
- *
- * Alternatively, this software may be distributed under the terms of the
- * GNU General Public License ("GPL") version 2 as published by the Free
- * Software Foundation.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
- * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
- * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
- * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
- * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
- * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
- * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
- * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
- * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
- * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
- * POSSIBILITY OF SUCH DAMAGE.
- */
-
-#include "core.h"
-#include "socket.h"
-#include "name_table.h"
-#include "config.h"
-#include "server.h"
-
-#define REPLY_TRUNCATED "<truncated>\n"
-
-static const void *req_tlv_area;	/* request message TLV area */
-static int req_tlv_space;		/* request message TLV area size */
-static int rep_headroom;		/* reply message headroom to use */
-
-struct sk_buff *tipc_cfg_reply_alloc(int payload_size)
-{
-	struct sk_buff *buf;
-
-	buf = alloc_skb(rep_headroom + payload_size, GFP_ATOMIC);
-	if (buf)
-		skb_reserve(buf, rep_headroom);
-	return buf;
-}
-
-int tipc_cfg_append_tlv(struct sk_buff *buf, int tlv_type,
-			void *tlv_data, int tlv_data_size)
-{
-	struct tlv_desc *tlv = (struct tlv_desc *)skb_tail_pointer(buf);
-	int new_tlv_space = TLV_SPACE(tlv_data_size);
-
-	if (skb_tailroom(buf) < new_tlv_space)
-		return 0;
-	skb_put(buf, new_tlv_space);
-	tlv->tlv_type = htons(tlv_type);
-	tlv->tlv_len  = htons(TLV_LENGTH(tlv_data_size));
-	if (tlv_data_size && tlv_data)
-		memcpy(TLV_DATA(tlv), tlv_data, tlv_data_size);
-	return 1;
-}
-
-static struct sk_buff *tipc_cfg_reply_unsigned_type(u16 tlv_type, u32 value)
-{
-	struct sk_buff *buf;
-	__be32 value_net;
-
-	buf = tipc_cfg_reply_alloc(TLV_SPACE(sizeof(value)));
-	if (buf) {
-		value_net = htonl(value);
-		tipc_cfg_append_tlv(buf, tlv_type, &value_net,
-				    sizeof(value_net));
-	}
-	return buf;
-}
-
-static struct sk_buff *tipc_cfg_reply_unsigned(u32 value)
-{
-	return tipc_cfg_reply_unsigned_type(TIPC_TLV_UNSIGNED, value);
-}
-
-struct sk_buff *tipc_cfg_reply_string_type(u16 tlv_type, char *string)
-{
-	struct sk_buff *buf;
-	int string_len = strlen(string) + 1;
-
-	buf = tipc_cfg_reply_alloc(TLV_SPACE(string_len));
-	if (buf)
-		tipc_cfg_append_tlv(buf, tlv_type, string, string_len);
-	return buf;
-}
-
-static struct sk_buff *tipc_show_stats(void)
-{
-	struct sk_buff *buf;
-	struct tlv_desc *rep_tlv;
-	char *pb;
-	int pb_len;
-	int str_len;
-	u32 value;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_UNSIGNED))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-
-	value = ntohl(*(u32 *)TLV_DATA(req_tlv_area));
-	if (value != 0)
-		return tipc_cfg_reply_error_string("unsupported argument");
-
-	buf = tipc_cfg_reply_alloc(TLV_SPACE(ULTRA_STRING_MAX_LEN));
-	if (buf == NULL)
-		return NULL;
-
-	rep_tlv = (struct tlv_desc *)buf->data;
-	pb = TLV_DATA(rep_tlv);
-	pb_len = ULTRA_STRING_MAX_LEN;
-
-	str_len = tipc_snprintf(pb, pb_len, "TIPC version " TIPC_MOD_VER "\n");
-	str_len += 1;	/* for "\0" */
-	skb_put(buf, TLV_SPACE(str_len));
-	TLV_SET(rep_tlv, TIPC_TLV_ULTRA_STRING, NULL, str_len);
-
-	return buf;
-}
-
-static struct sk_buff *cfg_enable_bearer(void)
-{
-	struct tipc_bearer_config *args;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_BEARER_CONFIG))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-
-	args = (struct tipc_bearer_config *)TLV_DATA(req_tlv_area);
-	if (tipc_enable_bearer(args->name,
-			       ntohl(args->disc_domain),
-			       ntohl(args->priority)))
-		return tipc_cfg_reply_error_string("unable to enable bearer");
-
-	return tipc_cfg_reply_none();
-}
-
-static struct sk_buff *cfg_disable_bearer(void)
-{
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_BEARER_NAME))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-
-	if (tipc_disable_bearer((char *)TLV_DATA(req_tlv_area)))
-		return tipc_cfg_reply_error_string("unable to disable bearer");
-
-	return tipc_cfg_reply_none();
-}
-
-static struct sk_buff *cfg_set_own_addr(void)
-{
-	u32 addr;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_NET_ADDR))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-
-	addr = ntohl(*(__be32 *)TLV_DATA(req_tlv_area));
-	if (addr == tipc_own_addr)
-		return tipc_cfg_reply_none();
-	if (!tipc_addr_node_valid(addr))
-		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
-						   " (node address)");
-	if (tipc_own_addr)
-		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
-						   " (cannot change node address once assigned)");
-	if (!tipc_net_start(addr))
-		return tipc_cfg_reply_none();
-
-	return tipc_cfg_reply_error_string("cannot change to network mode");
-}
-
-static struct sk_buff *cfg_set_max_ports(void)
-{
-	u32 value;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_UNSIGNED))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-	value = ntohl(*(__be32 *)TLV_DATA(req_tlv_area));
-	if (value == tipc_max_ports)
-		return tipc_cfg_reply_none();
-	if (value < 127 || value > 65535)
-		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
-						   " (max ports must be 127-65535)");
-	return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
-		" (cannot change max ports while TIPC is active)");
-}
-
-static struct sk_buff *cfg_set_netid(void)
-{
-	u32 value;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_UNSIGNED))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-	value = ntohl(*(__be32 *)TLV_DATA(req_tlv_area));
-	if (value == tipc_net_id)
-		return tipc_cfg_reply_none();
-	if (value < 1 || value > 9999)
-		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
-						   " (network id must be 1-9999)");
-	if (tipc_own_addr)
-		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
-			" (cannot change network id once TIPC has joined a network)");
-	tipc_net_id = value;
-	return tipc_cfg_reply_none();
-}
-
-struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area,
-				int request_space, int reply_headroom)
-{
-	struct sk_buff *rep_tlv_buf;
-
-	rtnl_lock();
-
-	/* Save request and reply details in a well-known location */
-	req_tlv_area = request_area;
-	req_tlv_space = request_space;
-	rep_headroom = reply_headroom;
-
-	/* Check command authorization */
-	if (likely(in_own_node(orig_node))) {
-		/* command is permitted */
-	} else {
-		rep_tlv_buf = tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
-							  " (cannot be done remotely)");
-		goto exit;
-	}
-
-	/* Call appropriate processing routine */
-	switch (cmd) {
-	case TIPC_CMD_NOOP:
-		rep_tlv_buf = tipc_cfg_reply_none();
-		break;
-	case TIPC_CMD_GET_NODES:
-		rep_tlv_buf = tipc_node_get_nodes(req_tlv_area, req_tlv_space);
-		break;
-	case TIPC_CMD_GET_LINKS:
-		rep_tlv_buf = tipc_node_get_links(req_tlv_area, req_tlv_space);
-		break;
-	case TIPC_CMD_SHOW_LINK_STATS:
-		rep_tlv_buf = tipc_link_cmd_show_stats(req_tlv_area, req_tlv_space);
-		break;
-	case TIPC_CMD_RESET_LINK_STATS:
-		rep_tlv_buf = tipc_link_cmd_reset_stats(req_tlv_area, req_tlv_space);
-		break;
-	case TIPC_CMD_SHOW_NAME_TABLE:
-		rep_tlv_buf = tipc_nametbl_get(req_tlv_area, req_tlv_space);
-		break;
-	case TIPC_CMD_GET_BEARER_NAMES:
-		rep_tlv_buf = tipc_bearer_get_names();
-		break;
-	case TIPC_CMD_GET_MEDIA_NAMES:
-		rep_tlv_buf = tipc_media_get_names();
-		break;
-	case TIPC_CMD_SHOW_PORTS:
-		rep_tlv_buf = tipc_sk_socks_show();
-		break;
-	case TIPC_CMD_SHOW_STATS:
-		rep_tlv_buf = tipc_show_stats();
-		break;
-	case TIPC_CMD_SET_LINK_TOL:
-	case TIPC_CMD_SET_LINK_PRI:
-	case TIPC_CMD_SET_LINK_WINDOW:
-		rep_tlv_buf = tipc_link_cmd_config(req_tlv_area, req_tlv_space, cmd);
-		break;
-	case TIPC_CMD_ENABLE_BEARER:
-		rep_tlv_buf = cfg_enable_bearer();
-		break;
-	case TIPC_CMD_DISABLE_BEARER:
-		rep_tlv_buf = cfg_disable_bearer();
-		break;
-	case TIPC_CMD_SET_NODE_ADDR:
-		rep_tlv_buf = cfg_set_own_addr();
-		break;
-	case TIPC_CMD_SET_MAX_PORTS:
-		rep_tlv_buf = cfg_set_max_ports();
-		break;
-	case TIPC_CMD_SET_NETID:
-		rep_tlv_buf = cfg_set_netid();
-		break;
-	case TIPC_CMD_GET_MAX_PORTS:
-		rep_tlv_buf = tipc_cfg_reply_unsigned(tipc_max_ports);
-		break;
-	case TIPC_CMD_GET_NETID:
-		rep_tlv_buf = tipc_cfg_reply_unsigned(tipc_net_id);
-		break;
-	case TIPC_CMD_NOT_NET_ADMIN:
-		rep_tlv_buf =
-			tipc_cfg_reply_error_string(TIPC_CFG_NOT_NET_ADMIN);
-		break;
-	case TIPC_CMD_SET_MAX_ZONES:
-	case TIPC_CMD_GET_MAX_ZONES:
-	case TIPC_CMD_SET_MAX_SLAVES:
-	case TIPC_CMD_GET_MAX_SLAVES:
-	case TIPC_CMD_SET_MAX_CLUSTERS:
-	case TIPC_CMD_GET_MAX_CLUSTERS:
-	case TIPC_CMD_SET_MAX_NODES:
-	case TIPC_CMD_GET_MAX_NODES:
-	case TIPC_CMD_SET_MAX_SUBSCR:
-	case TIPC_CMD_GET_MAX_SUBSCR:
-	case TIPC_CMD_SET_MAX_PUBL:
-	case TIPC_CMD_GET_MAX_PUBL:
-	case TIPC_CMD_SET_LOG_SIZE:
-	case TIPC_CMD_SET_REMOTE_MNG:
-	case TIPC_CMD_GET_REMOTE_MNG:
-	case TIPC_CMD_DUMP_LOG:
-		rep_tlv_buf = tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
-							  " (obsolete command)");
-		break;
-	default:
-		rep_tlv_buf = tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
-							  " (unknown command)");
-		break;
-	}
-
-	WARN_ON(rep_tlv_buf->len > TLV_SPACE(ULTRA_STRING_MAX_LEN));
-
-	/* Append an error message if we cannot return all requested data */
-	if (rep_tlv_buf->len == TLV_SPACE(ULTRA_STRING_MAX_LEN)) {
-		if (*(rep_tlv_buf->data + ULTRA_STRING_MAX_LEN) != '\0')
-			sprintf(rep_tlv_buf->data + rep_tlv_buf->len -
-				sizeof(REPLY_TRUNCATED) - 1, REPLY_TRUNCATED);
-	}
-
-	/* Return reply buffer */
-exit:
-	rtnl_unlock();
-	return rep_tlv_buf;
-}
diff --git a/net/tipc/config.h b/net/tipc/config.h
deleted file mode 100644
index 47b1bf1..0000000
--- a/net/tipc/config.h
+++ /dev/null
@@ -1,67 +0,0 @@
-/*
- * net/tipc/config.h: Include file for TIPC configuration service code
- *
- * Copyright (c) 2003-2006, Ericsson AB
- * Copyright (c) 2005, Wind River Systems
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions are met:
- *
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the names of the copyright holders nor the names of its
- *    contributors may be used to endorse or promote products derived from
- *    this software without specific prior written permission.
- *
- * Alternatively, this software may be distributed under the terms of the
- * GNU General Public License ("GPL") version 2 as published by the Free
- * Software Foundation.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
- * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
- * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
- * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
- * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
- * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
- * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
- * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
- * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
- * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
- * POSSIBILITY OF SUCH DAMAGE.
- */
-
-#ifndef _TIPC_CONFIG_H
-#define _TIPC_CONFIG_H
-
-/* ---------------------------------------------------------------------- */
-
-#include "link.h"
-
-struct sk_buff *tipc_cfg_reply_alloc(int payload_size);
-int tipc_cfg_append_tlv(struct sk_buff *buf, int tlv_type,
-			void *tlv_data, int tlv_data_size);
-struct sk_buff *tipc_cfg_reply_string_type(u16 tlv_type, char *string);
-
-static inline struct sk_buff *tipc_cfg_reply_none(void)
-{
-	return tipc_cfg_reply_alloc(0);
-}
-
-static inline struct sk_buff *tipc_cfg_reply_error_string(char *string)
-{
-	return tipc_cfg_reply_string_type(TIPC_TLV_ERROR_STRING, string);
-}
-
-static inline struct sk_buff *tipc_cfg_reply_ultra_string(char *string)
-{
-	return tipc_cfg_reply_string_type(TIPC_TLV_ULTRA_STRING, string);
-}
-
-struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd,
-				const void *req_tlv_area, int req_tlv_space,
-				int headroom);
-#endif
diff --git a/net/tipc/core.c b/net/tipc/core.c
index a5737b8..b78284b 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -37,8 +37,9 @@
 #include "core.h"
 #include "name_table.h"
 #include "subscr.h"
-#include "config.h"
 #include "socket.h"
+#include "net.h"
+#include "bearer.h"
 
 #include <linux/module.h>
 
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 2195197..2e8e184 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -40,7 +40,6 @@
 #include "socket.h"
 #include "name_distr.h"
 #include "discover.h"
-#include "config.h"
 #include "netlink.h"
 
 #include <linux/pkt_sched.h>
@@ -2028,148 +2027,6 @@ static struct tipc_node *tipc_link_find_owner(const char *link_name,
 }
 
 /**
- * link_value_is_valid -- validate proposed link tolerance/priority/window
- *
- * @cmd: value type (TIPC_CMD_SET_LINK_*)
- * @new_value: the new value
- *
- * Returns 1 if value is within range, 0 if not.
- */
-static int link_value_is_valid(u16 cmd, u32 new_value)
-{
-	switch (cmd) {
-	case TIPC_CMD_SET_LINK_TOL:
-		return (new_value >= TIPC_MIN_LINK_TOL) &&
-			(new_value <= TIPC_MAX_LINK_TOL);
-	case TIPC_CMD_SET_LINK_PRI:
-		return (new_value <= TIPC_MAX_LINK_PRI);
-	case TIPC_CMD_SET_LINK_WINDOW:
-		return (new_value >= TIPC_MIN_LINK_WIN) &&
-			(new_value <= TIPC_MAX_LINK_WIN);
-	}
-	return 0;
-}
-
-/**
- * link_cmd_set_value - change priority/tolerance/window for link/bearer/media
- * @name: ptr to link, bearer, or media name
- * @new_value: new value of link, bearer, or media setting
- * @cmd: which link, bearer, or media attribute to set (TIPC_CMD_SET_LINK_*)
- *
- * Caller must hold RTNL lock to ensure link/bearer/media is not deleted.
- *
- * Returns 0 if value updated and negative value on error.
- */
-static int link_cmd_set_value(const char *name, u32 new_value, u16 cmd)
-{
-	struct tipc_node *node;
-	struct tipc_link *l_ptr;
-	struct tipc_bearer *b_ptr;
-	struct tipc_media *m_ptr;
-	int bearer_id;
-	int res = 0;
-
-	node = tipc_link_find_owner(name, &bearer_id);
-	if (node) {
-		tipc_node_lock(node);
-		l_ptr = node->links[bearer_id];
-
-		if (l_ptr) {
-			switch (cmd) {
-			case TIPC_CMD_SET_LINK_TOL:
-				link_set_supervision_props(l_ptr, new_value);
-				tipc_link_proto_xmit(l_ptr, STATE_MSG, 0, 0,
-						     new_value, 0, 0);
-				break;
-			case TIPC_CMD_SET_LINK_PRI:
-				l_ptr->priority = new_value;
-				tipc_link_proto_xmit(l_ptr, STATE_MSG, 0, 0,
-						     0, new_value, 0);
-				break;
-			case TIPC_CMD_SET_LINK_WINDOW:
-				tipc_link_set_queue_limits(l_ptr, new_value);
-				break;
-			default:
-				res = -EINVAL;
-				break;
-			}
-		}
-		tipc_node_unlock(node);
-		return res;
-	}
-
-	b_ptr = tipc_bearer_find(name);
-	if (b_ptr) {
-		switch (cmd) {
-		case TIPC_CMD_SET_LINK_TOL:
-			b_ptr->tolerance = new_value;
-			break;
-		case TIPC_CMD_SET_LINK_PRI:
-			b_ptr->priority = new_value;
-			break;
-		case TIPC_CMD_SET_LINK_WINDOW:
-			b_ptr->window = new_value;
-			break;
-		default:
-			res = -EINVAL;
-			break;
-		}
-		return res;
-	}
-
-	m_ptr = tipc_media_find(name);
-	if (!m_ptr)
-		return -ENODEV;
-	switch (cmd) {
-	case TIPC_CMD_SET_LINK_TOL:
-		m_ptr->tolerance = new_value;
-		break;
-	case TIPC_CMD_SET_LINK_PRI:
-		m_ptr->priority = new_value;
-		break;
-	case TIPC_CMD_SET_LINK_WINDOW:
-		m_ptr->window = new_value;
-		break;
-	default:
-		res = -EINVAL;
-		break;
-	}
-	return res;
-}
-
-struct sk_buff *tipc_link_cmd_config(const void *req_tlv_area, int req_tlv_space,
-				     u16 cmd)
-{
-	struct tipc_link_config *args;
-	u32 new_value;
-	int res;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_LINK_CONFIG))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-
-	args = (struct tipc_link_config *)TLV_DATA(req_tlv_area);
-	new_value = ntohl(args->value);
-
-	if (!link_value_is_valid(cmd, new_value))
-		return tipc_cfg_reply_error_string(
-			"cannot change, value invalid");
-
-	if (!strcmp(args->name, tipc_bclink_name)) {
-		if ((cmd == TIPC_CMD_SET_LINK_WINDOW) &&
-		    (tipc_bclink_set_queue_limits(new_value) == 0))
-			return tipc_cfg_reply_none();
-		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
-						   " (cannot change setting on broadcast link)");
-	}
-
-	res = link_cmd_set_value(args->name, new_value, cmd);
-	if (res)
-		return tipc_cfg_reply_error_string("cannot change link setting");
-
-	return tipc_cfg_reply_none();
-}
-
-/**
  * link_reset_statistics - reset link statistics
  * @l_ptr: pointer to link
  */
@@ -2180,174 +2037,6 @@ static void link_reset_statistics(struct tipc_link *l_ptr)
 	l_ptr->stats.recv_info = l_ptr->next_in_no;
 }
 
-struct sk_buff *tipc_link_cmd_reset_stats(const void *req_tlv_area, int req_tlv_space)
-{
-	char *link_name;
-	struct tipc_link *l_ptr;
-	struct tipc_node *node;
-	unsigned int bearer_id;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_LINK_NAME))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-
-	link_name = (char *)TLV_DATA(req_tlv_area);
-	if (!strcmp(link_name, tipc_bclink_name)) {
-		if (tipc_bclink_reset_stats())
-			return tipc_cfg_reply_error_string("link not found");
-		return tipc_cfg_reply_none();
-	}
-	node = tipc_link_find_owner(link_name, &bearer_id);
-	if (!node)
-		return tipc_cfg_reply_error_string("link not found");
-
-	tipc_node_lock(node);
-	l_ptr = node->links[bearer_id];
-	if (!l_ptr) {
-		tipc_node_unlock(node);
-		return tipc_cfg_reply_error_string("link not found");
-	}
-	link_reset_statistics(l_ptr);
-	tipc_node_unlock(node);
-	return tipc_cfg_reply_none();
-}
-
-/**
- * percent - convert count to a percentage of total (rounding up or down)
- */
-static u32 percent(u32 count, u32 total)
-{
-	return (count * 100 + (total / 2)) / total;
-}
-
-/**
- * tipc_link_stats - print link statistics
- * @name: link name
- * @buf: print buffer area
- * @buf_size: size of print buffer area
- *
- * Returns length of print buffer data string (or 0 if error)
- */
-static int tipc_link_stats(const char *name, char *buf, const u32 buf_size)
-{
-	struct tipc_link *l;
-	struct tipc_stats *s;
-	struct tipc_node *node;
-	char *status;
-	u32 profile_total = 0;
-	unsigned int bearer_id;
-	int ret;
-
-	if (!strcmp(name, tipc_bclink_name))
-		return tipc_bclink_stats(buf, buf_size);
-
-	node = tipc_link_find_owner(name, &bearer_id);
-	if (!node)
-		return 0;
-
-	tipc_node_lock(node);
-
-	l = node->links[bearer_id];
-	if (!l) {
-		tipc_node_unlock(node);
-		return 0;
-	}
-
-	s = &l->stats;
-
-	if (tipc_link_is_active(l))
-		status = "ACTIVE";
-	else if (tipc_link_is_up(l))
-		status = "STANDBY";
-	else
-		status = "DEFUNCT";
-
-	ret = tipc_snprintf(buf, buf_size, "Link <%s>\n"
-			    "  %s  MTU:%u  Priority:%u  Tolerance:%u ms"
-			    "  Window:%u packets\n",
-			    l->name, status, l->max_pkt, l->priority,
-			    l->tolerance, l->queue_limit[0]);
-
-	ret += tipc_snprintf(buf + ret, buf_size - ret,
-			     "  RX packets:%u fragments:%u/%u bundles:%u/%u\n",
-			     l->next_in_no - s->recv_info, s->recv_fragments,
-			     s->recv_fragmented, s->recv_bundles,
-			     s->recv_bundled);
-
-	ret += tipc_snprintf(buf + ret, buf_size - ret,
-			     "  TX packets:%u fragments:%u/%u bundles:%u/%u\n",
-			     l->next_out_no - s->sent_info, s->sent_fragments,
-			     s->sent_fragmented, s->sent_bundles,
-			     s->sent_bundled);
-
-	profile_total = s->msg_length_counts;
-	if (!profile_total)
-		profile_total = 1;
-
-	ret += tipc_snprintf(buf + ret, buf_size - ret,
-			     "  TX profile sample:%u packets  average:%u octets\n"
-			     "  0-64:%u%% -256:%u%% -1024:%u%% -4096:%u%% "
-			     "-16384:%u%% -32768:%u%% -66000:%u%%\n",
-			     s->msg_length_counts,
-			     s->msg_lengths_total / profile_total,
-			     percent(s->msg_length_profile[0], profile_total),
-			     percent(s->msg_length_profile[1], profile_total),
-			     percent(s->msg_length_profile[2], profile_total),
-			     percent(s->msg_length_profile[3], profile_total),
-			     percent(s->msg_length_profile[4], profile_total),
-			     percent(s->msg_length_profile[5], profile_total),
-			     percent(s->msg_length_profile[6], profile_total));
-
-	ret += tipc_snprintf(buf + ret, buf_size - ret,
-			     "  RX states:%u probes:%u naks:%u defs:%u"
-			     " dups:%u\n", s->recv_states, s->recv_probes,
-			     s->recv_nacks, s->deferred_recv, s->duplicates);
-
-	ret += tipc_snprintf(buf + ret, buf_size - ret,
-			     "  TX states:%u probes:%u naks:%u acks:%u"
-			     " dups:%u\n", s->sent_states, s->sent_probes,
-			     s->sent_nacks, s->sent_acks, s->retransmitted);
-
-	ret += tipc_snprintf(buf + ret, buf_size - ret,
-			     "  Congestion link:%u  Send queue"
-			     " max:%u avg:%u\n", s->link_congs,
-			     s->max_queue_sz, s->queue_sz_counts ?
-			     (s->accu_queue_sz / s->queue_sz_counts) : 0);
-
-	tipc_node_unlock(node);
-	return ret;
-}
-
-struct sk_buff *tipc_link_cmd_show_stats(const void *req_tlv_area, int req_tlv_space)
-{
-	struct sk_buff *buf;
-	struct tlv_desc *rep_tlv;
-	int str_len;
-	int pb_len;
-	char *pb;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_LINK_NAME))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-
-	buf = tipc_cfg_reply_alloc(TLV_SPACE(ULTRA_STRING_MAX_LEN));
-	if (!buf)
-		return NULL;
-
-	rep_tlv = (struct tlv_desc *)buf->data;
-	pb = TLV_DATA(rep_tlv);
-	pb_len = ULTRA_STRING_MAX_LEN;
-	str_len = tipc_link_stats((char *)TLV_DATA(req_tlv_area),
-				  pb, pb_len);
-	if (!str_len) {
-		kfree_skb(buf);
-		return tipc_cfg_reply_error_string("link not found");
-	}
-	str_len += 1;	/* for "\0" */
-	skb_put(buf, TLV_SPACE(str_len));
-	TLV_SET(rep_tlv, TIPC_TLV_ULTRA_STRING, NULL, str_len);
-
-	return buf;
-}
-
 /**
  * tipc_link_get_max_pkt - get maximum packet size to use when sending to destination
  * @dest: network address of destination node
diff --git a/net/tipc/link.h b/net/tipc/link.h
index f463e7b..20e9c93 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -217,13 +217,6 @@ void tipc_link_reset_fragments(struct tipc_link *l_ptr);
 int tipc_link_is_up(struct tipc_link *l_ptr);
 int tipc_link_is_active(struct tipc_link *l_ptr);
 void tipc_link_purge_queues(struct tipc_link *l_ptr);
-struct sk_buff *tipc_link_cmd_config(const void *req_tlv_area,
-				     int req_tlv_space,
-				     u16 cmd);
-struct sk_buff *tipc_link_cmd_show_stats(const void *req_tlv_area,
-					 int req_tlv_space);
-struct sk_buff *tipc_link_cmd_reset_stats(const void *req_tlv_area,
-					  int req_tlv_space);
 void tipc_link_reset_all(struct tipc_node *node);
 void tipc_link_reset(struct tipc_link *l_ptr);
 void tipc_link_reset_list(unsigned int bearer_id);
diff --git a/net/tipc/log.c b/net/tipc/log.c
index abef644..b186af0 100644
--- a/net/tipc/log.c
+++ b/net/tipc/log.c
@@ -35,7 +35,6 @@
  */
 
 #include "core.h"
-#include "config.h"
 
 /**
  * tipc_snprintf - append formatted output to print buffer
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 7d69229..7b06a9d 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -35,9 +35,9 @@
  */
 
 #include "core.h"
-#include "config.h"
 #include "name_table.h"
 #include "name_distr.h"
+#include "bcast.h"
 #include "subscr.h"
 
 #define TIPC_NAMETBL_SIZE 1024		/* must be a power of 2 */
@@ -760,189 +760,6 @@ void tipc_nametbl_unsubscribe(struct tipc_subscription *s)
 	write_unlock_bh(&tipc_nametbl_lock);
 }
 
-
-/**
- * subseq_list - print specified sub-sequence contents into the given buffer
- */
-static int subseq_list(struct sub_seq *sseq, char *buf, int len, u32 depth,
-		       u32 index)
-{
-	char portIdStr[27];
-	const char *scope_str[] = {"", " zone", " cluster", " node"};
-	struct publication *publ;
-	struct name_info *info;
-	int ret;
-
-	ret = tipc_snprintf(buf, len, "%-10u %-10u ", sseq->lower, sseq->upper);
-
-	if (depth == 2) {
-		ret += tipc_snprintf(buf - ret, len + ret, "\n");
-		return ret;
-	}
-
-	info = sseq->info;
-
-	list_for_each_entry(publ, &info->zone_list, zone_list) {
-		sprintf(portIdStr, "<%u.%u.%u:%u>",
-			 tipc_zone(publ->node), tipc_cluster(publ->node),
-			 tipc_node(publ->node), publ->ref);
-		ret += tipc_snprintf(buf + ret, len - ret, "%-26s ", portIdStr);
-		if (depth > 3) {
-			ret += tipc_snprintf(buf + ret, len - ret, "%-10u %s",
-					     publ->key, scope_str[publ->scope]);
-		}
-		if (!list_is_last(&publ->zone_list, &info->zone_list))
-			ret += tipc_snprintf(buf + ret, len - ret,
-					     "\n%33s", " ");
-	}
-
-	ret += tipc_snprintf(buf + ret, len - ret, "\n");
-	return ret;
-}
-
-/**
- * nameseq_list - print specified name sequence contents into the given buffer
- */
-static int nameseq_list(struct name_seq *seq, char *buf, int len, u32 depth,
-			u32 type, u32 lowbound, u32 upbound, u32 index)
-{
-	struct sub_seq *sseq;
-	char typearea[11];
-	int ret = 0;
-
-	if (seq->first_free == 0)
-		return 0;
-
-	sprintf(typearea, "%-10u", seq->type);
-
-	if (depth == 1) {
-		ret += tipc_snprintf(buf, len, "%s\n", typearea);
-		return ret;
-	}
-
-	for (sseq = seq->sseqs; sseq != &seq->sseqs[seq->first_free]; sseq++) {
-		if ((lowbound <= sseq->upper) && (upbound >= sseq->lower)) {
-			ret += tipc_snprintf(buf + ret, len - ret, "%s ",
-					    typearea);
-			spin_lock_bh(&seq->lock);
-			ret += subseq_list(sseq, buf + ret, len - ret,
-					  depth, index);
-			spin_unlock_bh(&seq->lock);
-			sprintf(typearea, "%10s", " ");
-		}
-	}
-	return ret;
-}
-
-/**
- * nametbl_header - print name table header into the given buffer
- */
-static int nametbl_header(char *buf, int len, u32 depth)
-{
-	const char *header[] = {
-		"Type       ",
-		"Lower      Upper      ",
-		"Port Identity              ",
-		"Publication Scope"
-	};
-
-	int i;
-	int ret = 0;
-
-	if (depth > 4)
-		depth = 4;
-	for (i = 0; i < depth; i++)
-		ret += tipc_snprintf(buf + ret, len - ret, header[i]);
-	ret += tipc_snprintf(buf + ret, len - ret, "\n");
-	return ret;
-}
-
-/**
- * nametbl_list - print specified name table contents into the given buffer
- */
-static int nametbl_list(char *buf, int len, u32 depth_info,
-			u32 type, u32 lowbound, u32 upbound)
-{
-	struct hlist_head *seq_head;
-	struct name_seq *seq;
-	int all_types;
-	int ret = 0;
-	u32 depth;
-	u32 i;
-
-	all_types = (depth_info & TIPC_NTQ_ALLTYPES);
-	depth = (depth_info & ~TIPC_NTQ_ALLTYPES);
-
-	if (depth == 0)
-		return 0;
-
-	if (all_types) {
-		/* display all entries in name table to specified depth */
-		ret += nametbl_header(buf, len, depth);
-		lowbound = 0;
-		upbound = ~0;
-		for (i = 0; i < TIPC_NAMETBL_SIZE; i++) {
-			seq_head = &table.types[i];
-			hlist_for_each_entry(seq, seq_head, ns_list) {
-				ret += nameseq_list(seq, buf + ret, len - ret,
-						   depth, seq->type,
-						   lowbound, upbound, i);
-			}
-		}
-	} else {
-		/* display only the sequence that matches the specified type */
-		if (upbound < lowbound) {
-			ret += tipc_snprintf(buf + ret, len - ret,
-					"invalid name sequence specified\n");
-			return ret;
-		}
-		ret += nametbl_header(buf + ret, len - ret, depth);
-		i = hash(type);
-		seq_head = &table.types[i];
-		hlist_for_each_entry(seq, seq_head, ns_list) {
-			if (seq->type == type) {
-				ret += nameseq_list(seq, buf + ret, len - ret,
-						   depth, type,
-						   lowbound, upbound, i);
-				break;
-			}
-		}
-	}
-	return ret;
-}
-
-struct sk_buff *tipc_nametbl_get(const void *req_tlv_area, int req_tlv_space)
-{
-	struct sk_buff *buf;
-	struct tipc_name_table_query *argv;
-	struct tlv_desc *rep_tlv;
-	char *pb;
-	int pb_len;
-	int str_len;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_NAME_TBL_QUERY))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-
-	buf = tipc_cfg_reply_alloc(TLV_SPACE(ULTRA_STRING_MAX_LEN));
-	if (!buf)
-		return NULL;
-
-	rep_tlv = (struct tlv_desc *)buf->data;
-	pb = TLV_DATA(rep_tlv);
-	pb_len = ULTRA_STRING_MAX_LEN;
-	argv = (struct tipc_name_table_query *)TLV_DATA(req_tlv_area);
-	read_lock_bh(&tipc_nametbl_lock);
-	str_len = nametbl_list(pb, pb_len, ntohl(argv->depth),
-			       ntohl(argv->type),
-			       ntohl(argv->lowbound), ntohl(argv->upbound));
-	read_unlock_bh(&tipc_nametbl_lock);
-	str_len += 1;	/* for "\0" */
-	skb_put(buf, TLV_SPACE(str_len));
-	TLV_SET(rep_tlv, TIPC_TLV_ULTRA_STRING, NULL, str_len);
-
-	return buf;
-}
-
 int tipc_nametbl_init(void)
 {
 	table.types = kcalloc(TIPC_NAMETBL_SIZE, sizeof(struct hlist_head),
diff --git a/net/tipc/name_table.h b/net/tipc/name_table.h
index b38ebec..3ed7b64 100644
--- a/net/tipc/name_table.h
+++ b/net/tipc/name_table.h
@@ -38,6 +38,7 @@
 #define _TIPC_NAME_TABLE_H
 
 #include "node_subscr.h"
+#include <net/genetlink.h>
 
 struct tipc_subscription;
 struct tipc_port_list;
diff --git a/net/tipc/net.c b/net/tipc/net.c
index fdbbedf..2b7d7f3 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -40,7 +40,6 @@
 #include "subscr.h"
 #include "socket.h"
 #include "node.h"
-#include "config.h"
 
 static const struct nla_policy tipc_nl_net_policy[TIPC_NLA_NET_MAX + 1] = {
 	[TIPC_NLA_NET_UNSPEC]	= { .type = NLA_UNSPEC },
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index 2184231..34b5f3c 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -35,7 +35,6 @@
  */
 
 #include "core.h"
-#include "config.h"
 #include "socket.h"
 #include "name_table.h"
 #include "bearer.h"
@@ -44,36 +43,6 @@
 #include "net.h"
 #include <net/genetlink.h>
 
-static int handle_cmd(struct sk_buff *skb, struct genl_info *info)
-{
-	struct sk_buff *rep_buf;
-	struct nlmsghdr *rep_nlh;
-	struct nlmsghdr *req_nlh = info->nlhdr;
-	struct tipc_genlmsghdr *req_userhdr = info->userhdr;
-	int hdr_space = nlmsg_total_size(GENL_HDRLEN + TIPC_GENL_HDRLEN);
-	u16 cmd;
-
-	if ((req_userhdr->cmd & 0xC000) && (!netlink_capable(skb, CAP_NET_ADMIN)))
-		cmd = TIPC_CMD_NOT_NET_ADMIN;
-	else
-		cmd = req_userhdr->cmd;
-
-	rep_buf = tipc_cfg_do_cmd(req_userhdr->dest, cmd,
-			nlmsg_data(req_nlh) + GENL_HDRLEN + TIPC_GENL_HDRLEN,
-			nlmsg_attrlen(req_nlh, GENL_HDRLEN + TIPC_GENL_HDRLEN),
-			hdr_space);
-
-	if (rep_buf) {
-		skb_push(rep_buf, hdr_space);
-		rep_nlh = nlmsg_hdr(rep_buf);
-		memcpy(rep_nlh, req_nlh, hdr_space);
-		rep_nlh->nlmsg_len = rep_buf->len;
-		genlmsg_unicast(&init_net, rep_buf, NETLINK_CB(skb).portid);
-	}
-
-	return 0;
-}
-
 static const struct nla_policy tipc_nl_policy[TIPC_NLA_MAX + 1] = {
 	[TIPC_NLA_UNSPEC]	= { .type = NLA_UNSPEC, },
 	[TIPC_NLA_BEARER]	= { .type = NLA_NESTED, },
@@ -96,11 +65,6 @@ struct genl_family tipc_genl_family = {
 
 static const struct genl_ops tipc_genl_ops[] = {
 	{
-		/* Legacy ASCII API */
-		.cmd		= TIPC_GENL_CMD,
-		.doit		= handle_cmd,
-	},
-	{
 		.cmd	= TIPC_NL_BEARER_DISABLE,
 		.doit	= tipc_nl_bearer_disable,
 		.policy = tipc_nl_policy,
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 80ca561..1a5ef71 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -35,8 +35,8 @@
  */
 
 #include "core.h"
-#include "config.h"
 #include "node.h"
+#include "link.h"
 #include "name_distr.h"
 #include "socket.h"
 
@@ -414,117 +414,6 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 			       TIPC_NOTIFY_NODE_DOWN;
 }
 
-struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
-{
-	u32 domain;
-	struct sk_buff *buf;
-	struct tipc_node *n_ptr;
-	struct tipc_node_info node_info;
-	u32 payload_size;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_NET_ADDR))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-
-	domain = ntohl(*(__be32 *)TLV_DATA(req_tlv_area));
-	if (!tipc_addr_domain_valid(domain))
-		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
-						   " (network address)");
-
-	spin_lock_bh(&node_list_lock);
-	if (!tipc_num_nodes) {
-		spin_unlock_bh(&node_list_lock);
-		return tipc_cfg_reply_none();
-	}
-
-	/* For now, get space for all other nodes */
-	payload_size = TLV_SPACE(sizeof(node_info)) * tipc_num_nodes;
-	if (payload_size > 32768u) {
-		spin_unlock_bh(&node_list_lock);
-		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
-						   " (too many nodes)");
-	}
-	spin_unlock_bh(&node_list_lock);
-
-	buf = tipc_cfg_reply_alloc(payload_size);
-	if (!buf)
-		return NULL;
-
-	/* Add TLVs for all nodes in scope */
-	rcu_read_lock();
-	list_for_each_entry_rcu(n_ptr, &tipc_node_list, list) {
-		if (!tipc_in_scope(domain, n_ptr->addr))
-			continue;
-		node_info.addr = htonl(n_ptr->addr);
-		node_info.up = htonl(tipc_node_is_up(n_ptr));
-		tipc_cfg_append_tlv(buf, TIPC_TLV_NODE_INFO,
-				    &node_info, sizeof(node_info));
-	}
-	rcu_read_unlock();
-	return buf;
-}
-
-struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
-{
-	u32 domain;
-	struct sk_buff *buf;
-	struct tipc_node *n_ptr;
-	struct tipc_link_info link_info;
-	u32 payload_size;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_NET_ADDR))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-
-	domain = ntohl(*(__be32 *)TLV_DATA(req_tlv_area));
-	if (!tipc_addr_domain_valid(domain))
-		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
-						   " (network address)");
-
-	if (!tipc_own_addr)
-		return tipc_cfg_reply_none();
-
-	spin_lock_bh(&node_list_lock);
-	/* Get space for all unicast links + broadcast link */
-	payload_size = TLV_SPACE((sizeof(link_info)) * (tipc_num_links + 1));
-	if (payload_size > 32768u) {
-		spin_unlock_bh(&node_list_lock);
-		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
-						   " (too many links)");
-	}
-	spin_unlock_bh(&node_list_lock);
-
-	buf = tipc_cfg_reply_alloc(payload_size);
-	if (!buf)
-		return NULL;
-
-	/* Add TLV for broadcast link */
-	link_info.dest = htonl(tipc_cluster_mask(tipc_own_addr));
-	link_info.up = htonl(1);
-	strlcpy(link_info.str, tipc_bclink_name, TIPC_MAX_LINK_NAME);
-	tipc_cfg_append_tlv(buf, TIPC_TLV_LINK_INFO, &link_info, sizeof(link_info));
-
-	/* Add TLVs for any other links in scope */
-	rcu_read_lock();
-	list_for_each_entry_rcu(n_ptr, &tipc_node_list, list) {
-		u32 i;
-
-		if (!tipc_in_scope(domain, n_ptr->addr))
-			continue;
-		tipc_node_lock(n_ptr);
-		for (i = 0; i < MAX_BEARERS; i++) {
-			if (!n_ptr->links[i])
-				continue;
-			link_info.dest = htonl(n_ptr->addr);
-			link_info.up = htonl(tipc_link_is_up(n_ptr->links[i]));
-			strcpy(link_info.str, n_ptr->links[i]->name);
-			tipc_cfg_append_tlv(buf, TIPC_TLV_LINK_INFO,
-					    &link_info, sizeof(link_info));
-		}
-		tipc_node_unlock(n_ptr);
-	}
-	rcu_read_unlock();
-	return buf;
-}
-
 /**
  * tipc_node_get_linkname - get the name of a link
  *
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 17c0921..a8849d7 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -132,8 +132,6 @@ void tipc_node_link_down(struct tipc_node *n_ptr, struct tipc_link *l_ptr);
 void tipc_node_link_up(struct tipc_node *n_ptr, struct tipc_link *l_ptr);
 int tipc_node_active_links(struct tipc_node *n_ptr);
 int tipc_node_is_up(struct tipc_node *n_ptr);
-struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space);
-struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space);
 int tipc_node_get_linkname(u32 bearer_id, u32 node, char *linkname, size_t len);
 void tipc_node_unlock(struct tipc_node *node);
 int tipc_node_add_conn(u32 dnode, u32 port, u32 peer_port);
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 7ffb286..b83e248 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -39,7 +39,6 @@
 #include "node.h"
 #include "link.h"
 #include <linux/export.h>
-#include "config.h"
 #include "socket.h"
 
 #define SS_LISTENING	-1	/* socket is listening */
@@ -2211,82 +2210,6 @@ static int tipc_sk_withdraw(struct tipc_sock *tsk, uint scope,
 	return rc;
 }
 
-static int tipc_sk_show(struct tipc_sock *tsk, char *buf,
-			int len, int full_id)
-{
-	struct publication *publ;
-	int ret;
-
-	if (full_id)
-		ret = tipc_snprintf(buf, len, "<%u.%u.%u:%u>:",
-				    tipc_zone(tipc_own_addr),
-				    tipc_cluster(tipc_own_addr),
-				    tipc_node(tipc_own_addr), tsk->ref);
-	else
-		ret = tipc_snprintf(buf, len, "%-10u:", tsk->ref);
-
-	if (tsk->connected) {
-		u32 dport = tsk_peer_port(tsk);
-		u32 destnode = tsk_peer_node(tsk);
-
-		ret += tipc_snprintf(buf + ret, len - ret,
-				     " connected to <%u.%u.%u:%u>",
-				     tipc_zone(destnode),
-				     tipc_cluster(destnode),
-				     tipc_node(destnode), dport);
-		if (tsk->conn_type != 0)
-			ret += tipc_snprintf(buf + ret, len - ret,
-					     " via {%u,%u}", tsk->conn_type,
-					     tsk->conn_instance);
-	} else if (tsk->published) {
-		ret += tipc_snprintf(buf + ret, len - ret, " bound to");
-		list_for_each_entry(publ, &tsk->publications, pport_list) {
-			if (publ->lower == publ->upper)
-				ret += tipc_snprintf(buf + ret, len - ret,
-						     " {%u,%u}", publ->type,
-						     publ->lower);
-			else
-				ret += tipc_snprintf(buf + ret, len - ret,
-						     " {%u,%u,%u}", publ->type,
-						     publ->lower, publ->upper);
-		}
-	}
-	ret += tipc_snprintf(buf + ret, len - ret, "\n");
-	return ret;
-}
-
-struct sk_buff *tipc_sk_socks_show(void)
-{
-	struct sk_buff *buf;
-	struct tlv_desc *rep_tlv;
-	char *pb;
-	int pb_len;
-	struct tipc_sock *tsk;
-	int str_len = 0;
-	u32 ref = 0;
-
-	buf = tipc_cfg_reply_alloc(TLV_SPACE(ULTRA_STRING_MAX_LEN));
-	if (!buf)
-		return NULL;
-	rep_tlv = (struct tlv_desc *)buf->data;
-	pb = TLV_DATA(rep_tlv);
-	pb_len = ULTRA_STRING_MAX_LEN;
-
-	tsk = tipc_sk_get_next(&ref);
-	for (; tsk; tsk = tipc_sk_get_next(&ref)) {
-		lock_sock(&tsk->sk);
-		str_len += tipc_sk_show(tsk, pb + str_len,
-					pb_len - str_len, 0);
-		release_sock(&tsk->sk);
-		tipc_sk_put(tsk);
-	}
-	str_len += 1;	/* for "\0" */
-	skb_put(buf, TLV_SPACE(str_len));
-	TLV_SET(rep_tlv, TIPC_TLV_ULTRA_STRING, NULL, str_len);
-
-	return buf;
-}
-
 /* tipc_sk_reinit: set non-zero address in all existing sockets
  *                 when we go from standalone to network mode.
  */
diff --git a/net/tipc/socket.h b/net/tipc/socket.h
index d340893..8e3d741 100644
--- a/net/tipc/socket.h
+++ b/net/tipc/socket.h
@@ -43,7 +43,6 @@
 #define TIPC_CONN_OVERLOAD_LIMIT ((TIPC_FLOWCTRL_WIN * 2 + 1) * \
 				  SKB_TRUESIZE(TIPC_MAX_USER_MSG_SIZE))
 int tipc_sk_rcv(struct sk_buff *buf);
-struct sk_buff *tipc_sk_socks_show(void);
 void tipc_sk_mcast_rcv(struct sk_buff *buf);
 void tipc_sk_reinit(void);
 int tipc_sk_ref_table_init(u32 requested_size, u32 start);
-- 
1.7.10.4


------------------------------------------------------------------------------
Meet PCI DSS 3.0 Compliance Requirements with EventLog Analyzer
Achieve PCI DSS 3.0 Compliant Status with Out-of-the-box PCI DSS Reports
Are you Audit-Ready for PCI DSS 3.0 Compliance? Download White paper
Comply to PCI DSS 3.0 Requirement 10 and 11.5 with EventLog Analyzer
http://pubads.g.doubleclick.net/gampad/clk?id=154622311&iu=/4140/ostg.clktrk
