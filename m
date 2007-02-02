From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 5/7] [S390]: Adapt netiucv driver to new IUCV API
Date: Fri, 2 Feb 2007 13:06:46 +0100
Message-ID: <20070202120646.GF10392@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:37528 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932801AbXBBMHv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 07:07:51 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l12C7nn2020187
	for <netdev@vger.kernel.org>; Fri, 2 Feb 2007 07:07:49 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l12C6nSu305478
	for <netdev@vger.kernel.org>; Fri, 2 Feb 2007 07:06:49 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l12C6ne5018390
	for <netdev@vger.kernel.org>; Fri, 2 Feb 2007 07:06:49 -0500
Received: from goulee.de.ibm.com (dyn-9-152-216-77.boeblingen.de.ibm.com [9.152.216.77])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id l12C6hCD018058
	for <netdev@vger.kernel.org>; Fri, 2 Feb 2007 07:06:48 -0500
Received: from goulee.de.ibm.com (localhost.localdomain [127.0.0.1])
	by goulee.de.ibm.com (8.13.1/8.13.1) with ESMTP id l12C6k9T014854
	for <netdev@vger.kernel.org>; Fri, 2 Feb 2007 13:06:46 +0100
Received: (from pavlic@localhost)
	by goulee.de.ibm.com (8.13.1/8.13.1/Submit) id l12C6kVr014851
	for netdev@vger.kernel.org; Fri, 2 Feb 2007 13:06:46 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Martin Schwidefsky <schwidefsky@de.ibm.com>

Adapt netiucv network device driver to new IUCV API

Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 drivers/s390/net/netiucv.c | 1318 ++++++++++++++++++++++----------------------
 1 files changed, 654 insertions(+), 664 deletions(-)

diff --git a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
index d7d1cc0..6387b48 100644
--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -1,7 +1,7 @@
 /*
  * IUCV network driver
  *
- * Copyright (C) 2001 IBM Deutschland Entwicklung GmbH, IBM Corporation
+ * Copyright 2001 IBM Deutschland Entwicklung GmbH, IBM Corporation
  * Author(s): Fritz Elfert (elfert@de.ibm.com, felfert@millenux.com)
  *
  * Sysfs integration and all bugs therein by Cornelia Huck
@@ -58,13 +58,94 @@ #include <net/dst.h>
 #include <asm/io.h>
 #include <asm/uaccess.h>
 
-#include "iucv.h"
+#include <net/iucv/iucv.h>
 #include "fsm.h"
 
 MODULE_AUTHOR
     ("(C) 2001 IBM Corporation by Fritz Elfert (felfert@millenux.com)");
 MODULE_DESCRIPTION ("Linux for S/390 IUCV network driver");
 
+/**
+ * Debug Facility stuff
+ */
+#define IUCV_DBF_SETUP_NAME "iucv_setup"
+#define IUCV_DBF_SETUP_LEN 32
+#define IUCV_DBF_SETUP_PAGES 2
+#define IUCV_DBF_SETUP_NR_AREAS 1
+#define IUCV_DBF_SETUP_LEVEL 3
+
+#define IUCV_DBF_DATA_NAME "iucv_data"
+#define IUCV_DBF_DATA_LEN 128
+#define IUCV_DBF_DATA_PAGES 2
+#define IUCV_DBF_DATA_NR_AREAS 1
+#define IUCV_DBF_DATA_LEVEL 2
+
+#define IUCV_DBF_TRACE_NAME "iucv_trace"
+#define IUCV_DBF_TRACE_LEN 16
+#define IUCV_DBF_TRACE_PAGES 4
+#define IUCV_DBF_TRACE_NR_AREAS 1
+#define IUCV_DBF_TRACE_LEVEL 3
+
+#define IUCV_DBF_TEXT(name,level,text) \
+	do { \
+		debug_text_event(iucv_dbf_##name,level,text); \
+	} while (0)
+
+#define IUCV_DBF_HEX(name,level,addr,len) \
+	do { \
+		debug_event(iucv_dbf_##name,level,(void*)(addr),len); \
+	} while (0)
+
+DECLARE_PER_CPU(char[256], iucv_dbf_txt_buf);
+
+#define IUCV_DBF_TEXT_(name,level,text...)				\
+	do {								\
+		char* iucv_dbf_txt_buf = get_cpu_var(iucv_dbf_txt_buf);	\
+		sprintf(iucv_dbf_txt_buf, text);			\
+		debug_text_event(iucv_dbf_##name,level,iucv_dbf_txt_buf); \
+		put_cpu_var(iucv_dbf_txt_buf);				\
+	} while (0)
+
+#define IUCV_DBF_SPRINTF(name,level,text...) \
+	do { \
+		debug_sprintf_event(iucv_dbf_trace, level, ##text ); \
+		debug_sprintf_event(iucv_dbf_trace, level, text ); \
+	} while (0)
+
+/**
+ * some more debug stuff
+ */
+#define IUCV_HEXDUMP16(importance,header,ptr) \
+PRINT_##importance(header "%02x %02x %02x %02x  %02x %02x %02x %02x  " \
+		   "%02x %02x %02x %02x  %02x %02x %02x %02x\n", \
+		   *(((char*)ptr)),*(((char*)ptr)+1),*(((char*)ptr)+2), \
+		   *(((char*)ptr)+3),*(((char*)ptr)+4),*(((char*)ptr)+5), \
+		   *(((char*)ptr)+6),*(((char*)ptr)+7),*(((char*)ptr)+8), \
+		   *(((char*)ptr)+9),*(((char*)ptr)+10),*(((char*)ptr)+11), \
+		   *(((char*)ptr)+12),*(((char*)ptr)+13), \
+		   *(((char*)ptr)+14),*(((char*)ptr)+15)); \
+PRINT_##importance(header "%02x %02x %02x %02x  %02x %02x %02x %02x  " \
+		   "%02x %02x %02x %02x  %02x %02x %02x %02x\n", \
+		   *(((char*)ptr)+16),*(((char*)ptr)+17), \
+		   *(((char*)ptr)+18),*(((char*)ptr)+19), \
+		   *(((char*)ptr)+20),*(((char*)ptr)+21), \
+		   *(((char*)ptr)+22),*(((char*)ptr)+23), \
+		   *(((char*)ptr)+24),*(((char*)ptr)+25), \
+		   *(((char*)ptr)+26),*(((char*)ptr)+27), \
+		   *(((char*)ptr)+28),*(((char*)ptr)+29), \
+		   *(((char*)ptr)+30),*(((char*)ptr)+31));
+
+static inline void iucv_hex_dump(unsigned char *buf, size_t len)
+{
+	size_t i;
+
+	for (i = 0; i < len; i++) {
+		if (i && !(i % 16))
+			printk("\n");
+		printk("%02x ", *(buf + i));
+	}
+	printk("\n");
+}
 
 #define PRINTK_HEADER " iucv: "       /* for debugging */
 
@@ -73,6 +154,25 @@ static struct device_driver netiucv_driv
 	.bus  = &iucv_bus,
 };
 
+static int netiucv_callback_connreq(struct iucv_path *,
+				    u8 ipvmid[8], u8 ipuser[16]);
+static void netiucv_callback_connack(struct iucv_path *, u8 ipuser[16]);
+static void netiucv_callback_connrej(struct iucv_path *, u8 ipuser[16]);
+static void netiucv_callback_connsusp(struct iucv_path *, u8 ipuser[16]);
+static void netiucv_callback_connres(struct iucv_path *, u8 ipuser[16]);
+static void netiucv_callback_rx(struct iucv_path *, struct iucv_message *);
+static void netiucv_callback_txdone(struct iucv_path *, struct iucv_message *);
+
+static struct iucv_handler netiucv_handler = {
+	.path_pending	  = netiucv_callback_connreq,
+	.path_complete	  = netiucv_callback_connack,
+	.path_severed	  = netiucv_callback_connrej,
+	.path_quiesced	  = netiucv_callback_connsusp,
+	.path_resumed	  = netiucv_callback_connres,
+	.message_pending  = netiucv_callback_rx,
+	.message_complete = netiucv_callback_txdone
+};
+
 /**
  * Per connection profiling data
  */
@@ -92,9 +192,8 @@ struct connection_profile {
  * Representation of one iucv connection
  */
 struct iucv_connection {
-	struct iucv_connection    *next;
-	iucv_handle_t             handle;
-	__u16                     pathid;
+	struct list_head	  list;
+	struct iucv_path	  *path;
 	struct sk_buff            *rx_buff;
 	struct sk_buff            *tx_buff;
 	struct sk_buff_head       collect_queue;
@@ -112,12 +211,9 @@ struct iucv_connection {
 /**
  * Linked list of all connection structs.
  */
-struct iucv_connection_struct {
-	struct iucv_connection *iucv_connections;
-	rwlock_t iucv_rwlock;
-};
-
-static struct iucv_connection_struct iucv_conns;
+static struct list_head iucv_connection_list =
+	LIST_HEAD_INIT(iucv_connection_list);
+static rwlock_t iucv_connection_rwlock = RW_LOCK_UNLOCKED;
 
 /**
  * Representation of event-data for the
@@ -142,11 +238,11 @@ struct netiucv_priv {
 /**
  * Link level header for a packet.
  */
-typedef struct ll_header_t {
-	__u16 next;
-} ll_header;
+struct ll_header {
+	u16 next;
+};
 
-#define NETIUCV_HDRLEN           (sizeof(ll_header))
+#define NETIUCV_HDRLEN		 (sizeof(struct ll_header))
 #define NETIUCV_BUFSIZE_MAX      32768
 #define NETIUCV_BUFSIZE_DEFAULT  NETIUCV_BUFSIZE_MAX
 #define NETIUCV_MTU_MAX          (NETIUCV_BUFSIZE_MAX - NETIUCV_HDRLEN)
@@ -158,36 +254,26 @@ #define NETIUCV_TIMEOUT_5SEC     5000
  * Compatibility macros for busy handling
  * of network devices.
  */
-static __inline__ void netiucv_clear_busy(struct net_device *dev)
+static inline void netiucv_clear_busy(struct net_device *dev)
 {
-	clear_bit(0, &(((struct netiucv_priv *)dev->priv)->tbusy));
+	struct netiucv_priv *priv = netdev_priv(dev);
+	clear_bit(0, &priv->tbusy);
 	netif_wake_queue(dev);
 }
 
-static __inline__ int netiucv_test_and_set_busy(struct net_device *dev)
+static inline int netiucv_test_and_set_busy(struct net_device *dev)
 {
+	struct netiucv_priv *priv = netdev_priv(dev);
 	netif_stop_queue(dev);
-	return test_and_set_bit(0, &((struct netiucv_priv *)dev->priv)->tbusy);
+	return test_and_set_bit(0, &priv->tbusy);
 }
 
-static __u8 iucv_host[8] = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
-static __u8 iucvMagic[16] = {
+static u8 iucvMagic[16] = {
 	0xF0, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40,
 	0xF0, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40
 };
 
 /**
- * This mask means the 16-byte IUCV "magic" and the origin userid must
- * match exactly as specified in order to give connection_pending()
- * control.
- */
-static __u8 netiucv_mask[] = {
-	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
-	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
-	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
-};
-
-/**
  * Convert an iucv userId to its printable
  * form (strip whitespace at end).
  *
@@ -195,8 +281,7 @@ static __u8 netiucv_mask[] = {
  *
  * @returns The printable string (static data!!)
  */
-static __inline__ char *
-netiucv_printname(char *name)
+static inline char *netiucv_printname(char *name)
 {
 	static char tmp[9];
 	char *p = tmp;
@@ -379,8 +464,7 @@ static debug_info_t *iucv_dbf_trace = NU
 
 DEFINE_PER_CPU(char[256], iucv_dbf_txt_buf);
 
-static void
-iucv_unregister_dbf_views(void)
+static void iucv_unregister_dbf_views(void)
 {
 	if (iucv_dbf_setup)
 		debug_unregister(iucv_dbf_setup);
@@ -389,8 +473,7 @@ iucv_unregister_dbf_views(void)
 	if (iucv_dbf_trace)
 		debug_unregister(iucv_dbf_trace);
 }
-static int
-iucv_register_dbf_views(void)
+static int iucv_register_dbf_views(void)
 {
 	iucv_dbf_setup = debug_register(IUCV_DBF_SETUP_NAME,
 					IUCV_DBF_SETUP_PAGES,
@@ -422,125 +505,111 @@ iucv_register_dbf_views(void)
 	return 0;
 }
 
-/**
+/*
  * Callback-wrappers, called from lowlevel iucv layer.
- *****************************************************************************/
+ */
 
-static void
-netiucv_callback_rx(iucv_MessagePending *eib, void *pgm_data)
+static void netiucv_callback_rx(struct iucv_path *path,
+				struct iucv_message *msg)
 {
-	struct iucv_connection *conn = (struct iucv_connection *)pgm_data;
+	struct iucv_connection *conn = path->private;
 	struct iucv_event ev;
 
 	ev.conn = conn;
-	ev.data = (void *)eib;
-
+	ev.data = msg;
 	fsm_event(conn->fsm, CONN_EVENT_RX, &ev);
 }
 
-static void
-netiucv_callback_txdone(iucv_MessageComplete *eib, void *pgm_data)
+static void netiucv_callback_txdone(struct iucv_path *path,
+				    struct iucv_message *msg)
 {
-	struct iucv_connection *conn = (struct iucv_connection *)pgm_data;
+	struct iucv_connection *conn = path->private;
 	struct iucv_event ev;
 
 	ev.conn = conn;
-	ev.data = (void *)eib;
+	ev.data = msg;
 	fsm_event(conn->fsm, CONN_EVENT_TXDONE, &ev);
 }
 
-static void
-netiucv_callback_connack(iucv_ConnectionComplete *eib, void *pgm_data)
+static void netiucv_callback_connack(struct iucv_path *path, u8 ipuser[16])
 {
-	struct iucv_connection *conn = (struct iucv_connection *)pgm_data;
-	struct iucv_event ev;
+	struct iucv_connection *conn = path->private;
 
-	ev.conn = conn;
-	ev.data = (void *)eib;
-	fsm_event(conn->fsm, CONN_EVENT_CONN_ACK, &ev);
+	fsm_event(conn->fsm, CONN_EVENT_CONN_ACK, conn);
 }
 
-static void
-netiucv_callback_connreq(iucv_ConnectionPending *eib, void *pgm_data)
+static int netiucv_callback_connreq(struct iucv_path *path,
+				    u8 ipvmid[8], u8 ipuser[16])
 {
-	struct iucv_connection *conn = (struct iucv_connection *)pgm_data;
+	struct iucv_connection *conn = path->private;
 	struct iucv_event ev;
+	int rc;
 
-	ev.conn = conn;
-	ev.data = (void *)eib;
-	fsm_event(conn->fsm, CONN_EVENT_CONN_REQ, &ev);
+	if (memcmp(iucvMagic, ipuser, sizeof(ipuser)))
+		/* ipuser must match iucvMagic. */
+		return -EINVAL;
+	rc = -EINVAL;
+	read_lock_bh(&iucv_connection_rwlock);
+	list_for_each_entry(conn, &iucv_connection_list, list) {
+		if (strncmp(ipvmid, conn->userid, 8))
+			continue;
+		/* Found a matching connection for this path. */
+		conn->path = path;
+		ev.conn = conn;
+		ev.data = path;
+		fsm_event(conn->fsm, CONN_EVENT_CONN_REQ, &ev);
+		rc = 0;
+	}
+	read_unlock_bh(&iucv_connection_rwlock);
+	return rc;
 }
 
-static void
-netiucv_callback_connrej(iucv_ConnectionSevered *eib, void *pgm_data)
+static void netiucv_callback_connrej(struct iucv_path *path, u8 ipuser[16])
 {
-	struct iucv_connection *conn = (struct iucv_connection *)pgm_data;
-	struct iucv_event ev;
+	struct iucv_connection *conn = path->private;
 
-	ev.conn = conn;
-	ev.data = (void *)eib;
-	fsm_event(conn->fsm, CONN_EVENT_CONN_REJ, &ev);
+	fsm_event(conn->fsm, CONN_EVENT_CONN_REJ, conn);
 }
 
-static void
-netiucv_callback_connsusp(iucv_ConnectionQuiesced *eib, void *pgm_data)
+static void netiucv_callback_connsusp(struct iucv_path *path, u8 ipuser[16])
 {
-	struct iucv_connection *conn = (struct iucv_connection *)pgm_data;
-	struct iucv_event ev;
+	struct iucv_connection *conn = path->private;
 
-	ev.conn = conn;
-	ev.data = (void *)eib;
-	fsm_event(conn->fsm, CONN_EVENT_CONN_SUS, &ev);
+	fsm_event(conn->fsm, CONN_EVENT_CONN_SUS, conn);
 }
 
-static void
-netiucv_callback_connres(iucv_ConnectionResumed *eib, void *pgm_data)
+static void netiucv_callback_connres(struct iucv_path *path, u8 ipuser[16])
 {
-	struct iucv_connection *conn = (struct iucv_connection *)pgm_data;
-	struct iucv_event ev;
+	struct iucv_connection *conn = path->private;
 
-	ev.conn = conn;
-	ev.data = (void *)eib;
-	fsm_event(conn->fsm, CONN_EVENT_CONN_RES, &ev);
-}
-
-static iucv_interrupt_ops_t netiucv_ops = {
-	.ConnectionPending  = netiucv_callback_connreq,
-	.ConnectionComplete = netiucv_callback_connack,
-	.ConnectionSevered  = netiucv_callback_connrej,
-	.ConnectionQuiesced = netiucv_callback_connsusp,
-	.ConnectionResumed  = netiucv_callback_connres,
-	.MessagePending     = netiucv_callback_rx,
-	.MessageComplete    = netiucv_callback_txdone
-};
+	fsm_event(conn->fsm, CONN_EVENT_CONN_RES, conn);
+}
 
 /**
  * Dummy NOP action for all statemachines
  */
-static void
-fsm_action_nop(fsm_instance *fi, int event, void *arg)
+static void fsm_action_nop(fsm_instance *fi, int event, void *arg)
 {
 }
 
-/**
+/*
  * Actions of the connection statemachine
- *****************************************************************************/
+ */
 
 /**
- * Helper function for conn_action_rx()
- * Unpack a just received skb and hand it over to
- * upper layers.
+ * netiucv_unpack_skb
+ * @conn: The connection where this skb has been received.
+ * @pskb: The received skb.
  *
- * @param conn The connection where this skb has been received.
- * @param pskb The received skb.
+ * Unpack a just received skb and hand it over to upper layers.
+ * Helper function for conn_action_rx.
  */
-//static __inline__ void
-static void
-netiucv_unpack_skb(struct iucv_connection *conn, struct sk_buff *pskb)
+static void netiucv_unpack_skb(struct iucv_connection *conn,
+			       struct sk_buff *pskb)
 {
 	struct net_device     *dev = conn->netdev;
-	struct netiucv_priv   *privptr = dev->priv;
-	__u16          offset = 0;
+	struct netiucv_priv   *privptr = netdev_priv(dev);
+	u16 offset = 0;
 
 	skb_put(pskb, NETIUCV_HDRLEN);
 	pskb->dev = dev;
@@ -549,7 +618,7 @@ netiucv_unpack_skb(struct iucv_connectio
 
 	while (1) {
 		struct sk_buff *skb;
-		ll_header *header = (ll_header *)pskb->data;
+		struct ll_header *header = (struct ll_header *) pskb->data;
 
 		if (!header->next)
 			break;
@@ -595,40 +664,37 @@ netiucv_unpack_skb(struct iucv_connectio
 	}
 }
 
-static void
-conn_action_rx(fsm_instance *fi, int event, void *arg)
+static void conn_action_rx(fsm_instance *fi, int event, void *arg)
 {
-	struct iucv_event *ev = (struct iucv_event *)arg;
+	struct iucv_event *ev = arg;
 	struct iucv_connection *conn = ev->conn;
-	iucv_MessagePending *eib = (iucv_MessagePending *)ev->data;
-	struct netiucv_priv *privptr =(struct netiucv_priv *)conn->netdev->priv;
-
-	__u32 msglen = eib->ln1msg2.ipbfln1f;
+	struct iucv_message *msg = ev->data;
+	struct netiucv_priv *privptr = netdev_priv(conn->netdev);
 	int rc;
 
 	IUCV_DBF_TEXT(trace, 4, __FUNCTION__);
 
 	if (!conn->netdev) {
-		/* FRITZ: How to tell iucv LL to drop the msg? */
+		iucv_message_reject(conn->path, msg);
 		PRINT_WARN("Received data for unlinked connection\n");
 		IUCV_DBF_TEXT(data, 2,
-			"Received data for unlinked connection\n");
+			      "Received data for unlinked connection\n");
 		return;
 	}
-	if (msglen > conn->max_buffsize) {
-		/* FRITZ: How to tell iucv LL to drop the msg? */
+	if (msg->length > conn->max_buffsize) {
+		iucv_message_reject(conn->path, msg);
 		privptr->stats.rx_dropped++;
 		PRINT_WARN("msglen %d > max_buffsize %d\n",
-			msglen, conn->max_buffsize);
+			   msg->length, conn->max_buffsize);
 		IUCV_DBF_TEXT_(data, 2, "msglen %d > max_buffsize %d\n",
-			msglen, conn->max_buffsize);
+			       msg->length, conn->max_buffsize);
 		return;
 	}
 	conn->rx_buff->data = conn->rx_buff->tail = conn->rx_buff->head;
 	conn->rx_buff->len = 0;
-	rc = iucv_receive(conn->pathid, eib->ipmsgid, eib->iptrgcls,
-			  conn->rx_buff->data, msglen, NULL, NULL, NULL);
-	if (rc || msglen < 5) {
+	rc = iucv_message_receive(conn->path, msg, 0, conn->rx_buff->data,
+				  msg->length, NULL);
+	if (rc || msg->length < 5) {
 		privptr->stats.rx_errors++;
 		PRINT_WARN("iucv_receive returned %08x\n", rc);
 		IUCV_DBF_TEXT_(data, 2, "rc %d from iucv_receive\n", rc);
@@ -637,26 +703,26 @@ conn_action_rx(fsm_instance *fi, int eve
 	netiucv_unpack_skb(conn, conn->rx_buff);
 }
 
-static void
-conn_action_txdone(fsm_instance *fi, int event, void *arg)
+static void conn_action_txdone(fsm_instance *fi, int event, void *arg)
 {
-	struct iucv_event *ev = (struct iucv_event *)arg;
+	struct iucv_event *ev = arg;
 	struct iucv_connection *conn = ev->conn;
-	iucv_MessageComplete *eib = (iucv_MessageComplete *)ev->data;
+	struct iucv_message *msg = ev->data;
+	struct iucv_message txmsg;
 	struct netiucv_priv *privptr = NULL;
-			         /* Shut up, gcc! skb is always below 2G. */
-	__u32 single_flag = eib->ipmsgtag;
-	__u32 txbytes = 0;
-	__u32 txpackets = 0;
-	__u32 stat_maxcq = 0;
+	u32 single_flag = msg->tag;
+	u32 txbytes = 0;
+	u32 txpackets = 0;
+	u32 stat_maxcq = 0;
 	struct sk_buff *skb;
 	unsigned long saveflags;
-	ll_header header;
+	struct ll_header header;
+	int rc;
 
 	IUCV_DBF_TEXT(trace, 4, __FUNCTION__);
 
-	if (conn && conn->netdev && conn->netdev->priv)
-		privptr = (struct netiucv_priv *)conn->netdev->priv;
+	if (conn && conn->netdev)
+		privptr = netdev_priv(conn->netdev);
 	conn->prof.tx_pending--;
 	if (single_flag) {
 		if ((skb = skb_dequeue(&conn->commit_queue))) {
@@ -688,56 +754,55 @@ conn_action_txdone(fsm_instance *fi, int
 		conn->prof.maxmulti = conn->collect_len;
 	conn->collect_len = 0;
 	spin_unlock_irqrestore(&conn->collect_lock, saveflags);
-	if (conn->tx_buff->len) {
-		int rc;
-
-		header.next = 0;
-		memcpy(skb_put(conn->tx_buff, NETIUCV_HDRLEN), &header,
-		       NETIUCV_HDRLEN);
+	if (conn->tx_buff->len == 0) {
+		fsm_newstate(fi, CONN_STATE_IDLE);
+		return;
+	}
 
-		conn->prof.send_stamp = xtime;
-		rc = iucv_send(conn->pathid, NULL, 0, 0, 0, 0,
+	header.next = 0;
+	memcpy(skb_put(conn->tx_buff, NETIUCV_HDRLEN), &header, NETIUCV_HDRLEN);
+	conn->prof.send_stamp = xtime;
+	txmsg.class = 0;
+	txmsg.tag = 0;
+	rc = iucv_message_send(conn->path, &txmsg, 0, 0,
 			       conn->tx_buff->data, conn->tx_buff->len);
-		conn->prof.doios_multi++;
-		conn->prof.txlen += conn->tx_buff->len;
-		conn->prof.tx_pending++;
-		if (conn->prof.tx_pending > conn->prof.tx_max_pending)
-			conn->prof.tx_max_pending = conn->prof.tx_pending;
-		if (rc) {
-			conn->prof.tx_pending--;
-			fsm_newstate(fi, CONN_STATE_IDLE);
-			if (privptr)
-				privptr->stats.tx_errors += txpackets;
-			PRINT_WARN("iucv_send returned %08x\n",	rc);
-			IUCV_DBF_TEXT_(data, 2, "rc %d from iucv_send\n", rc);
-		} else {
-			if (privptr) {
-				privptr->stats.tx_packets += txpackets;
-				privptr->stats.tx_bytes += txbytes;
-			}
-			if (stat_maxcq > conn->prof.maxcqueue)
-				conn->prof.maxcqueue = stat_maxcq;
-		}
-	} else
+	conn->prof.doios_multi++;
+	conn->prof.txlen += conn->tx_buff->len;
+	conn->prof.tx_pending++;
+	if (conn->prof.tx_pending > conn->prof.tx_max_pending)
+		conn->prof.tx_max_pending = conn->prof.tx_pending;
+	if (rc) {
+		conn->prof.tx_pending--;
 		fsm_newstate(fi, CONN_STATE_IDLE);
+		if (privptr)
+			privptr->stats.tx_errors += txpackets;
+		PRINT_WARN("iucv_send returned %08x\n",	rc);
+		IUCV_DBF_TEXT_(data, 2, "rc %d from iucv_send\n", rc);
+	} else {
+		if (privptr) {
+			privptr->stats.tx_packets += txpackets;
+			privptr->stats.tx_bytes += txbytes;
+		}
+		if (stat_maxcq > conn->prof.maxcqueue)
+			conn->prof.maxcqueue = stat_maxcq;
+	}
 }
 
-static void
-conn_action_connaccept(fsm_instance *fi, int event, void *arg)
+static void conn_action_connaccept(fsm_instance *fi, int event, void *arg)
 {
-	struct iucv_event *ev = (struct iucv_event *)arg;
+	struct iucv_event *ev = arg;
 	struct iucv_connection *conn = ev->conn;
-	iucv_ConnectionPending *eib = (iucv_ConnectionPending *)ev->data;
+	struct iucv_path *path = ev->data;
 	struct net_device *netdev = conn->netdev;
-	struct netiucv_priv *privptr = (struct netiucv_priv *)netdev->priv;
+	struct netiucv_priv *privptr = netdev_priv(netdev);
 	int rc;
-	__u16 msglimit;
-	__u8 udata[16];
 
 	IUCV_DBF_TEXT(trace, 3, __FUNCTION__);
 
-	rc = iucv_accept(eib->ippathid, NETIUCV_QUEUELEN_DEFAULT, udata, 0,
-			 conn->handle, conn, NULL, &msglimit);
+	conn->path = path;
+	path->msglim = NETIUCV_QUEUELEN_DEFAULT;
+	path->flags = 0;
+	rc = iucv_path_accept(path, &netiucv_handler, NULL, conn);
 	if (rc) {
 		PRINT_WARN("%s: IUCV accept failed with error %d\n",
 		       netdev->name, rc);
@@ -745,183 +810,126 @@ conn_action_connaccept(fsm_instance *fi,
 		return;
 	}
 	fsm_newstate(fi, CONN_STATE_IDLE);
-	conn->pathid = eib->ippathid;
-	netdev->tx_queue_len = msglimit;
+	netdev->tx_queue_len = conn->path->msglim;
 	fsm_event(privptr->fsm, DEV_EVENT_CONUP, netdev);
 }
 
-static void
-conn_action_connreject(fsm_instance *fi, int event, void *arg)
+static void conn_action_connreject(fsm_instance *fi, int event, void *arg)
 {
-	struct iucv_event *ev = (struct iucv_event *)arg;
-	struct iucv_connection *conn = ev->conn;
-	struct net_device *netdev = conn->netdev;
-	iucv_ConnectionPending *eib = (iucv_ConnectionPending *)ev->data;
-	__u8 udata[16];
+	struct iucv_event *ev = arg;
+	struct iucv_path *path = ev->data;
 
 	IUCV_DBF_TEXT(trace, 3, __FUNCTION__);
-
-	iucv_sever(eib->ippathid, udata);
-	if (eib->ippathid != conn->pathid) {
-		PRINT_INFO("%s: IR Connection Pending; "
-			"pathid %d does not match original pathid %d\n",
-			netdev->name, eib->ippathid, conn->pathid);
-		IUCV_DBF_TEXT_(data, 2,
-			"connreject: IR pathid %d, conn. pathid %d\n",
-			eib->ippathid, conn->pathid);
-		iucv_sever(conn->pathid, udata);
-	}
+	iucv_path_sever(path, NULL);
 }
 
-static void
-conn_action_connack(fsm_instance *fi, int event, void *arg)
+static void conn_action_connack(fsm_instance *fi, int event, void *arg)
 {
-	struct iucv_event *ev = (struct iucv_event *)arg;
-	struct iucv_connection *conn = ev->conn;
-	iucv_ConnectionComplete *eib = (iucv_ConnectionComplete *)ev->data;
+	struct iucv_connection *conn = arg;
 	struct net_device *netdev = conn->netdev;
-	struct netiucv_priv *privptr = (struct netiucv_priv *)netdev->priv;
+	struct netiucv_priv *privptr = netdev_priv(netdev);
 
 	IUCV_DBF_TEXT(trace, 3, __FUNCTION__);
-
 	fsm_deltimer(&conn->timer);
 	fsm_newstate(fi, CONN_STATE_IDLE);
-	if (eib->ippathid != conn->pathid) {
-		PRINT_INFO("%s: IR Connection Complete; "
-			"pathid %d does not match original pathid %d\n",
-			netdev->name, eib->ippathid, conn->pathid);
-		IUCV_DBF_TEXT_(data, 2,
-			"connack: IR pathid %d, conn. pathid %d\n",
-			eib->ippathid, conn->pathid);
-		conn->pathid = eib->ippathid;
-	}
-	netdev->tx_queue_len = eib->ipmsglim;
+	netdev->tx_queue_len = conn->path->msglim;
 	fsm_event(privptr->fsm, DEV_EVENT_CONUP, netdev);
 }
 
-static void
-conn_action_conntimsev(fsm_instance *fi, int event, void *arg)
+static void conn_action_conntimsev(fsm_instance *fi, int event, void *arg)
 {
-	struct iucv_connection *conn = (struct iucv_connection *)arg;
-	__u8 udata[16];
+	struct iucv_connection *conn = arg;
 
 	IUCV_DBF_TEXT(trace, 3, __FUNCTION__);
-
 	fsm_deltimer(&conn->timer);
-	iucv_sever(conn->pathid, udata);
+	iucv_path_sever(conn->path, NULL);
 	fsm_newstate(fi, CONN_STATE_STARTWAIT);
 }
 
-static void
-conn_action_connsever(fsm_instance *fi, int event, void *arg)
+static void conn_action_connsever(fsm_instance *fi, int event, void *arg)
 {
-	struct iucv_event *ev = (struct iucv_event *)arg;
-	struct iucv_connection *conn = ev->conn;
+	struct iucv_connection *conn = arg;
 	struct net_device *netdev = conn->netdev;
-	struct netiucv_priv *privptr = (struct netiucv_priv *)netdev->priv;
-	__u8 udata[16];
+	struct netiucv_priv *privptr = netdev_priv(netdev);
 
 	IUCV_DBF_TEXT(trace, 3, __FUNCTION__);
 
 	fsm_deltimer(&conn->timer);
-	iucv_sever(conn->pathid, udata);
+	iucv_path_sever(conn->path, NULL);
 	PRINT_INFO("%s: Remote dropped connection\n", netdev->name);
 	IUCV_DBF_TEXT(data, 2,
-		"conn_action_connsever: Remote dropped connection\n");
+		      "conn_action_connsever: Remote dropped connection\n");
 	fsm_newstate(fi, CONN_STATE_STARTWAIT);
 	fsm_event(privptr->fsm, DEV_EVENT_CONDOWN, netdev);
 }
 
-static void
-conn_action_start(fsm_instance *fi, int event, void *arg)
+static void conn_action_start(fsm_instance *fi, int event, void *arg)
 {
-	struct iucv_event *ev = (struct iucv_event *)arg;
-	struct iucv_connection *conn = ev->conn;
-	__u16 msglimit;
+	struct iucv_connection *conn = arg;
 	int rc;
 
 	IUCV_DBF_TEXT(trace, 3, __FUNCTION__);
 
-	if (!conn->handle) {
-		IUCV_DBF_TEXT(trace, 5, "calling iucv_register_program\n");
-		conn->handle =
-			iucv_register_program(iucvMagic, conn->userid,
-					      netiucv_mask,
-					      &netiucv_ops, conn);
-		fsm_newstate(fi, CONN_STATE_STARTWAIT);
-		if (!conn->handle) {
-			fsm_newstate(fi, CONN_STATE_REGERR);
-			conn->handle = NULL;
-			IUCV_DBF_TEXT(setup, 2,
-				"NULL from iucv_register_program\n");
-			return;
-		}
-
-		PRINT_DEBUG("%s('%s'): registered successfully\n",
-			 conn->netdev->name, conn->userid);
-	}
-
+	fsm_newstate(fi, CONN_STATE_STARTWAIT);
 	PRINT_DEBUG("%s('%s'): connecting ...\n",
-		 conn->netdev->name, conn->userid);
+		    conn->netdev->name, conn->userid);
 
-	/* We must set the state before calling iucv_connect because the callback
-	 * handler could be called at any point after the connection request is
-	 * sent */
+	/*
+	 * We must set the state before calling iucv_connect because the
+	 * callback handler could be called at any point after the connection
+	 * request is sent
+	 */
 
 	fsm_newstate(fi, CONN_STATE_SETUPWAIT);
-	rc = iucv_connect(&(conn->pathid), NETIUCV_QUEUELEN_DEFAULT, iucvMagic,
-			  conn->userid, iucv_host, 0, NULL, &msglimit,
-			  conn->handle, conn);
+	conn->path = iucv_path_alloc(NETIUCV_QUEUELEN_DEFAULT, 0, GFP_KERNEL);
+	rc = iucv_path_connect(conn->path, &netiucv_handler, conn->userid,
+			       NULL, iucvMagic, conn);
 	switch (rc) {
-		case 0:
-			conn->netdev->tx_queue_len = msglimit;
-			fsm_addtimer(&conn->timer, NETIUCV_TIMEOUT_5SEC,
-				CONN_EVENT_TIMER, conn);
-			return;
-		case 11:
-			PRINT_INFO("%s: User %s is currently not available.\n",
-			       conn->netdev->name,
-			       netiucv_printname(conn->userid));
-			fsm_newstate(fi, CONN_STATE_STARTWAIT);
-			return;
-		case 12:
-			PRINT_INFO("%s: User %s is currently not ready.\n",
-			       conn->netdev->name,
-			       netiucv_printname(conn->userid));
-			fsm_newstate(fi, CONN_STATE_STARTWAIT);
-			return;
-		case 13:
-			PRINT_WARN("%s: Too many IUCV connections.\n",
-			       conn->netdev->name);
-			fsm_newstate(fi, CONN_STATE_CONNERR);
-			break;
-		case 14:
-			PRINT_WARN(
-			       "%s: User %s has too many IUCV connections.\n",
-			       conn->netdev->name,
-			       netiucv_printname(conn->userid));
-			fsm_newstate(fi, CONN_STATE_CONNERR);
-			break;
-		case 15:
-			PRINT_WARN(
-			       "%s: No IUCV authorization in CP directory.\n",
-			       conn->netdev->name);
-			fsm_newstate(fi, CONN_STATE_CONNERR);
-			break;
-		default:
-			PRINT_WARN("%s: iucv_connect returned error %d\n",
-			       conn->netdev->name, rc);
-			fsm_newstate(fi, CONN_STATE_CONNERR);
-			break;
+	case 0:
+		conn->netdev->tx_queue_len = conn->path->msglim;
+		fsm_addtimer(&conn->timer, NETIUCV_TIMEOUT_5SEC,
+			     CONN_EVENT_TIMER, conn);
+		return;
+	case 11:
+		PRINT_INFO("%s: User %s is currently not available.\n",
+			   conn->netdev->name,
+			   netiucv_printname(conn->userid));
+		fsm_newstate(fi, CONN_STATE_STARTWAIT);
+		break;
+	case 12:
+		PRINT_INFO("%s: User %s is currently not ready.\n",
+			   conn->netdev->name,
+			   netiucv_printname(conn->userid));
+		fsm_newstate(fi, CONN_STATE_STARTWAIT);
+		break;
+	case 13:
+		PRINT_WARN("%s: Too many IUCV connections.\n",
+			   conn->netdev->name);
+		fsm_newstate(fi, CONN_STATE_CONNERR);
+		break;
+	case 14:
+		PRINT_WARN("%s: User %s has too many IUCV connections.\n",
+			   conn->netdev->name,
+			   netiucv_printname(conn->userid));
+		fsm_newstate(fi, CONN_STATE_CONNERR);
+		break;
+	case 15:
+		PRINT_WARN("%s: No IUCV authorization in CP directory.\n",
+			   conn->netdev->name);
+		fsm_newstate(fi, CONN_STATE_CONNERR);
+		break;
+	default:
+		PRINT_WARN("%s: iucv_connect returned error %d\n",
+			   conn->netdev->name, rc);
+		fsm_newstate(fi, CONN_STATE_CONNERR);
+		break;
 	}
 	IUCV_DBF_TEXT_(setup, 5, "iucv_connect rc is %d\n", rc);
-	IUCV_DBF_TEXT(trace, 5, "calling iucv_unregister_program\n");
-	iucv_unregister_program(conn->handle);
-	conn->handle = NULL;
+	kfree(conn->path);
+	conn->path = NULL;
 }
 
-static void
-netiucv_purge_skb_queue(struct sk_buff_head *q)
+static void netiucv_purge_skb_queue(struct sk_buff_head *q)
 {
 	struct sk_buff *skb;
 
@@ -931,36 +939,34 @@ netiucv_purge_skb_queue(struct sk_buff_h
 	}
 }
 
-static void
-conn_action_stop(fsm_instance *fi, int event, void *arg)
+static void conn_action_stop(fsm_instance *fi, int event, void *arg)
 {
-	struct iucv_event *ev = (struct iucv_event *)arg;
+	struct iucv_event *ev = arg;
 	struct iucv_connection *conn = ev->conn;
 	struct net_device *netdev = conn->netdev;
-	struct netiucv_priv *privptr = (struct netiucv_priv *)netdev->priv;
+	struct netiucv_priv *privptr = netdev_priv(netdev);
 
 	IUCV_DBF_TEXT(trace, 3, __FUNCTION__);
 
 	fsm_deltimer(&conn->timer);
 	fsm_newstate(fi, CONN_STATE_STOPPED);
 	netiucv_purge_skb_queue(&conn->collect_queue);
-	if (conn->handle)
-		IUCV_DBF_TEXT(trace, 5, "calling iucv_unregister_program\n");
-		iucv_unregister_program(conn->handle);
-	conn->handle = NULL;
+	if (conn->path) {
+		IUCV_DBF_TEXT(trace, 5, "calling iucv_path_sever\n");
+		iucv_path_sever(conn->path, iucvMagic);
+		kfree(conn->path);
+		conn->path = NULL;
+	}
 	netiucv_purge_skb_queue(&conn->commit_queue);
 	fsm_event(privptr->fsm, DEV_EVENT_CONDOWN, netdev);
 }
 
-static void
-conn_action_inval(fsm_instance *fi, int event, void *arg)
+static void conn_action_inval(fsm_instance *fi, int event, void *arg)
 {
-	struct iucv_event *ev = (struct iucv_event *)arg;
-	struct iucv_connection *conn = ev->conn;
+	struct iucv_connection *conn = arg;
 	struct net_device *netdev = conn->netdev;
 
-	PRINT_WARN("%s: Cannot connect without username\n",
-	       netdev->name);
+	PRINT_WARN("%s: Cannot connect without username\n", netdev->name);
 	IUCV_DBF_TEXT(data, 2, "conn_action_inval called\n");
 }
 
@@ -999,29 +1005,27 @@ static const fsm_node conn_fsm[] = {
 static const int CONN_FSM_LEN = sizeof(conn_fsm) / sizeof(fsm_node);
 
 
-/**
+/*
  * Actions for interface - statemachine.
- *****************************************************************************/
+ */
 
 /**
- * Startup connection by sending CONN_EVENT_START to it.
+ * dev_action_start
+ * @fi: An instance of an interface statemachine.
+ * @event: The event, just happened.
+ * @arg: Generic pointer, casted from struct net_device * upon call.
  *
- * @param fi    An instance of an interface statemachine.
- * @param event The event, just happened.
- * @param arg   Generic pointer, casted from struct net_device * upon call.
+ * Startup connection by sending CONN_EVENT_START to it.
  */
-static void
-dev_action_start(fsm_instance *fi, int event, void *arg)
+static void dev_action_start(fsm_instance *fi, int event, void *arg)
 {
-	struct net_device   *dev = (struct net_device *)arg;
-	struct netiucv_priv *privptr = dev->priv;
-	struct iucv_event   ev;
+	struct net_device   *dev = arg;
+	struct netiucv_priv *privptr = netdev_priv(dev);
 
 	IUCV_DBF_TEXT(trace, 3, __FUNCTION__);
 
-	ev.conn = privptr->conn;
 	fsm_newstate(fi, DEV_STATE_STARTWAIT);
-	fsm_event(privptr->conn->fsm, CONN_EVENT_START, &ev);
+	fsm_event(privptr->conn->fsm, CONN_EVENT_START, privptr->conn);
 }
 
 /**
@@ -1034,8 +1038,8 @@ dev_action_start(fsm_instance *fi, int e
 static void
 dev_action_stop(fsm_instance *fi, int event, void *arg)
 {
-	struct net_device   *dev = (struct net_device *)arg;
-	struct netiucv_priv *privptr = dev->priv;
+	struct net_device   *dev = arg;
+	struct netiucv_priv *privptr = netdev_priv(dev);
 	struct iucv_event   ev;
 
 	IUCV_DBF_TEXT(trace, 3, __FUNCTION__);
@@ -1057,8 +1061,8 @@ dev_action_stop(fsm_instance *fi, int ev
 static void
 dev_action_connup(fsm_instance *fi, int event, void *arg)
 {
-	struct net_device   *dev = (struct net_device *)arg;
-	struct netiucv_priv *privptr = dev->priv;
+	struct net_device   *dev = arg;
+	struct netiucv_priv *privptr = netdev_priv(dev);
 
 	IUCV_DBF_TEXT(trace, 3, __FUNCTION__);
 
@@ -1131,11 +1135,13 @@ static const int DEV_FSM_LEN = sizeof(de
  *
  * @return 0 on success, -ERRNO on failure. (Never fails.)
  */
-static int
-netiucv_transmit_skb(struct iucv_connection *conn, struct sk_buff *skb) {
+static int netiucv_transmit_skb(struct iucv_connection *conn,
+				struct sk_buff *skb)
+{
+	struct iucv_message msg;
 	unsigned long saveflags;
-	ll_header header;
-	int       rc = 0;
+	struct ll_header header;
+	int rc;
 
 	if (fsm_getstate(conn->fsm) != CONN_STATE_IDLE) {
 		int l = skb->len + NETIUCV_HDRLEN;
@@ -1145,11 +1151,12 @@ netiucv_transmit_skb(struct iucv_connect
 		    (conn->max_buffsize - NETIUCV_HDRLEN)) {
 			rc = -EBUSY;
 			IUCV_DBF_TEXT(data, 2,
-				"EBUSY from netiucv_transmit_skb\n");
+				      "EBUSY from netiucv_transmit_skb\n");
 		} else {
 			atomic_inc(&skb->users);
 			skb_queue_tail(&conn->collect_queue, skb);
 			conn->collect_len += l;
+			rc = 0;
 		}
 		spin_unlock_irqrestore(&conn->collect_lock, saveflags);
 	} else {
@@ -1188,9 +1195,10 @@ netiucv_transmit_skb(struct iucv_connect
 		fsm_newstate(conn->fsm, CONN_STATE_TX);
 		conn->prof.send_stamp = xtime;
 
-		rc = iucv_send(conn->pathid, NULL, 0, 0, 1 /* single_flag */,
-			0, nskb->data, nskb->len);
-			       /* Shut up, gcc! nskb is always below 2G. */
+		msg.tag = 1;
+		msg.class = 0;
+		rc = iucv_message_send(conn->path, &msg, 0, 0,
+				       nskb->data, nskb->len);
 		conn->prof.doios_single++;
 		conn->prof.txlen += skb->len;
 		conn->prof.tx_pending++;
@@ -1200,7 +1208,7 @@ netiucv_transmit_skb(struct iucv_connect
 			struct netiucv_priv *privptr;
 			fsm_newstate(conn->fsm, CONN_STATE_IDLE);
 			conn->prof.tx_pending--;
-			privptr = (struct netiucv_priv *)conn->netdev->priv;
+			privptr = netdev_priv(conn->netdev);
 			if (privptr)
 				privptr->stats.tx_errors++;
 			if (copied)
@@ -1226,9 +1234,9 @@ netiucv_transmit_skb(struct iucv_connect
 	return rc;
 }
 
-/**
+/*
  * Interface API for upper network layers
- *****************************************************************************/
+ */
 
 /**
  * Open an interface.
@@ -1238,9 +1246,11 @@ netiucv_transmit_skb(struct iucv_connect
  *
  * @return 0 on success, -ERRNO on failure. (Never fails.)
  */
-static int
-netiucv_open(struct net_device *dev) {
-	fsm_event(((struct netiucv_priv *)dev->priv)->fsm, DEV_EVENT_START,dev);
+static int netiucv_open(struct net_device *dev)
+{
+	struct netiucv_priv *priv = netdev_priv(dev);
+
+	fsm_event(priv->fsm, DEV_EVENT_START, dev);
 	return 0;
 }
 
@@ -1252,9 +1262,11 @@ netiucv_open(struct net_device *dev) {
  *
  * @return 0 on success, -ERRNO on failure. (Never fails.)
  */
-static int
-netiucv_close(struct net_device *dev) {
-	fsm_event(((struct netiucv_priv *)dev->priv)->fsm, DEV_EVENT_STOP, dev);
+static int netiucv_close(struct net_device *dev)
+{
+	struct netiucv_priv *priv = netdev_priv(dev);
+
+	fsm_event(priv->fsm, DEV_EVENT_STOP, dev);
 	return 0;
 }
 
@@ -1271,8 +1283,8 @@ netiucv_close(struct net_device *dev) {
  */
 static int netiucv_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	int          rc = 0;
-	struct netiucv_priv *privptr = dev->priv;
+	struct netiucv_priv *privptr = netdev_priv(dev);
+	int rc;
 
 	IUCV_DBF_TEXT(trace, 4, __FUNCTION__);
 	/**
@@ -1312,40 +1324,41 @@ static int netiucv_tx(struct sk_buff *sk
 		return -EBUSY;
 	}
 	dev->trans_start = jiffies;
-	if (netiucv_transmit_skb(privptr->conn, skb))
-		rc = 1;
+	rc = netiucv_transmit_skb(privptr->conn, skb) != 0;
 	netiucv_clear_busy(dev);
 	return rc;
 }
 
 /**
- * Returns interface statistics of a device.
+ * netiucv_stats
+ * @dev: Pointer to interface struct.
  *
- * @param dev Pointer to interface struct.
+ * Returns interface statistics of a device.
  *
- * @return Pointer to stats struct of this interface.
+ * Returns pointer to stats struct of this interface.
  */
-static struct net_device_stats *
-netiucv_stats (struct net_device * dev)
+static struct net_device_stats *netiucv_stats (struct net_device * dev)
 {
+	struct netiucv_priv *priv = netdev_priv(dev);
+
 	IUCV_DBF_TEXT(trace, 5, __FUNCTION__);
-	return &((struct netiucv_priv *)dev->priv)->stats;
+	return &priv->stats;
 }
 
 /**
- * Sets MTU of an interface.
+ * netiucv_change_mtu
+ * @dev: Pointer to interface struct.
+ * @new_mtu: The new MTU to use for this interface.
  *
- * @param dev     Pointer to interface struct.
- * @param new_mtu The new MTU to use for this interface.
+ * Sets MTU of an interface.
  *
- * @return 0 on success, -EINVAL if MTU is out of valid range.
+ * Returns 0 on success, -EINVAL if MTU is out of valid range.
  *         (valid range is 576 .. NETIUCV_MTU_MAX).
  */
-static int
-netiucv_change_mtu (struct net_device * dev, int new_mtu)
+static int netiucv_change_mtu(struct net_device * dev, int new_mtu)
 {
 	IUCV_DBF_TEXT(trace, 3, __FUNCTION__);
-	if ((new_mtu < 576) || (new_mtu > NETIUCV_MTU_MAX)) {
+	if (new_mtu < 576 || new_mtu > NETIUCV_MTU_MAX) {
 		IUCV_DBF_TEXT(setup, 2, "given MTU out of valid range\n");
 		return -EINVAL;
 	}
@@ -1353,12 +1366,12 @@ netiucv_change_mtu (struct net_device * 
 	return 0;
 }
 
-/**
+/*
  * attributes in sysfs
- *****************************************************************************/
+ */
 
-static ssize_t
-user_show (struct device *dev, struct device_attribute *attr, char *buf)
+static ssize_t user_show(struct device *dev, struct device_attribute *attr,
+			 char *buf)
 {
 	struct netiucv_priv *priv = dev->driver_data;
 
@@ -1366,8 +1379,8 @@ user_show (struct device *dev, struct de
 	return sprintf(buf, "%s\n", netiucv_printname(priv->conn->userid));
 }
 
-static ssize_t
-user_write (struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
+static ssize_t user_write(struct device *dev, struct device_attribute *attr,
+			  const char *buf, size_t count)
 {
 	struct netiucv_priv *priv = dev->driver_data;
 	struct net_device *ndev = priv->conn->netdev;
@@ -1375,80 +1388,70 @@ user_write (struct device *dev, struct d
 	char    *tmp;
 	char 	username[9];
 	int 	i;
-	struct iucv_connection **clist = &iucv_conns.iucv_connections;
-	unsigned long flags;
+	struct iucv_connection *cp;
 
 	IUCV_DBF_TEXT(trace, 3, __FUNCTION__);
-	if (count>9) {
-		PRINT_WARN("netiucv: username too long (%d)!\n", (int)count);
+	if (count > 9) {
+		PRINT_WARN("netiucv: username too long (%d)!\n", (int) count);
 		IUCV_DBF_TEXT_(setup, 2,
-			"%d is length of username\n", (int)count);
+			       "%d is length of username\n", (int) count);
 		return -EINVAL;
 	}
 
 	tmp = strsep((char **) &buf, "\n");
-	for (i=0, p=tmp; i<8 && *p; i++, p++) {
-		if (isalnum(*p) || (*p == '$'))
+	for (i = 0, p = tmp; i < 8 && *p; i++, p++) {
+		if (isalnum(*p) || (*p == '$')) {
 			username[i]= toupper(*p);
-		else if (*p == '\n') {
+			continue;
+		}
+		if (*p == '\n') {
 			/* trailing lf, grr */
 			break;
-		} else {
-			PRINT_WARN("netiucv: Invalid char %c in username!\n",
-				*p);
-			IUCV_DBF_TEXT_(setup, 2,
-				"username: invalid character %c\n",
-				*p);
-			return -EINVAL;
 		}
+		PRINT_WARN("netiucv: Invalid char %c in username!\n", *p);
+		IUCV_DBF_TEXT_(setup, 2,
+			       "username: invalid character %c\n", *p);
+		return -EINVAL;
 	}
-	while (i<8)
+	while (i < 8)
 		username[i++] = ' ';
 	username[8] = '\0';
 
-	if (memcmp(username, priv->conn->userid, 9)) {
-		/* username changed */
-		if (ndev->flags & (IFF_UP | IFF_RUNNING)) {
-			PRINT_WARN(
-				"netiucv: device %s active, connected to %s\n",
-				dev->bus_id, priv->conn->userid);
-			PRINT_WARN("netiucv: user cannot be updated\n");
-			IUCV_DBF_TEXT(setup, 2, "user_write: device active\n");
-			return -EBUSY;
+	if (memcmp(username, priv->conn->userid, 9) &&
+	    (ndev->flags & (IFF_UP | IFF_RUNNING))) {
+		/* username changed while the interface is active. */
+		PRINT_WARN("netiucv: device %s active, connected to %s\n",
+			   dev->bus_id, priv->conn->userid);
+		PRINT_WARN("netiucv: user cannot be updated\n");
+		IUCV_DBF_TEXT(setup, 2, "user_write: device active\n");
+		return -EBUSY;
+	}
+	read_lock_bh(&iucv_connection_rwlock);
+	list_for_each_entry(cp, &iucv_connection_list, list) {
+		if (!strncmp(username, cp->userid, 9) && cp->netdev != ndev) {
+			read_unlock_bh(&iucv_connection_rwlock);
+			PRINT_WARN("netiucv: Connection to %s already "
+				   "exists\n", username);
+			return -EEXIST;
 		}
 	}
-	read_lock_irqsave(&iucv_conns.iucv_rwlock, flags);
-	while (*clist) {
-                if (!strncmp(username, (*clist)->userid, 9) ||
-		    ((*clist)->netdev != ndev))
-                        break;
-                clist = &((*clist)->next);
-        }
-	read_unlock_irqrestore(&iucv_conns.iucv_rwlock, flags);
-        if (*clist) {
-                PRINT_WARN("netiucv: Connection to %s already exists\n",
-                        username);
-                return -EEXIST;
-        }
+	read_unlock_bh(&iucv_connection_rwlock);
 	memcpy(priv->conn->userid, username, 9);
-
 	return count;
-
 }
 
 static DEVICE_ATTR(user, 0644, user_show, user_write);
 
-static ssize_t
-buffer_show (struct device *dev, struct device_attribute *attr, char *buf)
-{
-	struct netiucv_priv *priv = dev->driver_data;
+static ssize_t buffer_show (struct device *dev, struct device_attribute *attr,
+			    char *buf)
+{	struct netiucv_priv *priv = dev->driver_data;
 
 	IUCV_DBF_TEXT(trace, 5, __FUNCTION__);
 	return sprintf(buf, "%d\n", priv->conn->max_buffsize);
 }
 
-static ssize_t
-buffer_write (struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
+static ssize_t buffer_write (struct device *dev, struct device_attribute *attr,
+			     const char *buf, size_t count)
 {
 	struct netiucv_priv *priv = dev->driver_data;
 	struct net_device *ndev = priv->conn->netdev;
@@ -1502,8 +1505,8 @@ buffer_write (struct device *dev, struct
 
 static DEVICE_ATTR(buffer, 0644, buffer_show, buffer_write);
 
-static ssize_t
-dev_fsm_show (struct device *dev, struct device_attribute *attr, char *buf)
+static ssize_t dev_fsm_show (struct device *dev, struct device_attribute *attr,
+			     char *buf)
 {
 	struct netiucv_priv *priv = dev->driver_data;
 
@@ -1513,8 +1516,8 @@ dev_fsm_show (struct device *dev, struct
 
 static DEVICE_ATTR(device_fsm_state, 0444, dev_fsm_show, NULL);
 
-static ssize_t
-conn_fsm_show (struct device *dev, struct device_attribute *attr, char *buf)
+static ssize_t conn_fsm_show (struct device *dev,
+			      struct device_attribute *attr, char *buf)
 {
 	struct netiucv_priv *priv = dev->driver_data;
 
@@ -1524,8 +1527,8 @@ conn_fsm_show (struct device *dev, struc
 
 static DEVICE_ATTR(connection_fsm_state, 0444, conn_fsm_show, NULL);
 
-static ssize_t
-maxmulti_show (struct device *dev, struct device_attribute *attr, char *buf)
+static ssize_t maxmulti_show (struct device *dev,
+			      struct device_attribute *attr, char *buf)
 {
 	struct netiucv_priv *priv = dev->driver_data;
 
@@ -1533,8 +1536,9 @@ maxmulti_show (struct device *dev, struc
 	return sprintf(buf, "%ld\n", priv->conn->prof.maxmulti);
 }
 
-static ssize_t
-maxmulti_write (struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
+static ssize_t maxmulti_write (struct device *dev,
+			       struct device_attribute *attr,
+			       const char *buf, size_t count)
 {
 	struct netiucv_priv *priv = dev->driver_data;
 
@@ -1545,8 +1549,8 @@ maxmulti_write (struct device *dev, stru
 
 static DEVICE_ATTR(max_tx_buffer_used, 0644, maxmulti_show, maxmulti_write);
 
-static ssize_t
-maxcq_show (struct device *dev, struct device_attribute *attr, char *buf)
+static ssize_t maxcq_show (struct device *dev, struct device_attribute *attr,
+			   char *buf)
 {
 	struct netiucv_priv *priv = dev->driver_data;
 
@@ -1554,8 +1558,8 @@ maxcq_show (struct device *dev, struct d
 	return sprintf(buf, "%ld\n", priv->conn->prof.maxcqueue);
 }
 
-static ssize_t
-maxcq_write (struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
+static ssize_t maxcq_write (struct device *dev, struct device_attribute *attr,
+			    const char *buf, size_t count)
 {
 	struct netiucv_priv *priv = dev->driver_data;
 
@@ -1566,8 +1570,8 @@ maxcq_write (struct device *dev, struct 
 
 static DEVICE_ATTR(max_chained_skbs, 0644, maxcq_show, maxcq_write);
 
-static ssize_t
-sdoio_show (struct device *dev, struct device_attribute *attr, char *buf)
+static ssize_t sdoio_show (struct device *dev, struct device_attribute *attr,
+			   char *buf)
 {
 	struct netiucv_priv *priv = dev->driver_data;
 
@@ -1575,8 +1579,8 @@ sdoio_show (struct device *dev, struct d
 	return sprintf(buf, "%ld\n", priv->conn->prof.doios_single);
 }
 
-static ssize_t
-sdoio_write (struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
+static ssize_t sdoio_write (struct device *dev, struct device_attribute *attr,
+			    const char *buf, size_t count)
 {
 	struct netiucv_priv *priv = dev->driver_data;
 
@@ -1587,8 +1591,8 @@ sdoio_write (struct device *dev, struct 
 
 static DEVICE_ATTR(tx_single_write_ops, 0644, sdoio_show, sdoio_write);
 
-static ssize_t
-mdoio_show (struct device *dev, struct device_attribute *attr, char *buf)
+static ssize_t mdoio_show (struct device *dev, struct device_attribute *attr,
+			   char *buf)
 {
 	struct netiucv_priv *priv = dev->driver_data;
 
@@ -1596,8 +1600,8 @@ mdoio_show (struct device *dev, struct d
 	return sprintf(buf, "%ld\n", priv->conn->prof.doios_multi);
 }
 
-static ssize_t
-mdoio_write (struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
+static ssize_t mdoio_write (struct device *dev, struct device_attribute *attr,
+			    const char *buf, size_t count)
 {
 	struct netiucv_priv *priv = dev->driver_data;
 
@@ -1608,8 +1612,8 @@ mdoio_write (struct device *dev, struct 
 
 static DEVICE_ATTR(tx_multi_write_ops, 0644, mdoio_show, mdoio_write);
 
-static ssize_t
-txlen_show (struct device *dev, struct device_attribute *attr, char *buf)
+static ssize_t txlen_show (struct device *dev, struct device_attribute *attr,
+			   char *buf)
 {
 	struct netiucv_priv *priv = dev->driver_data;
 
@@ -1617,8 +1621,8 @@ txlen_show (struct device *dev, struct d
 	return sprintf(buf, "%ld\n", priv->conn->prof.txlen);
 }
 
-static ssize_t
-txlen_write (struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
+static ssize_t txlen_write (struct device *dev, struct device_attribute *attr,
+			    const char *buf, size_t count)
 {
 	struct netiucv_priv *priv = dev->driver_data;
 
@@ -1629,8 +1633,8 @@ txlen_write (struct device *dev, struct 
 
 static DEVICE_ATTR(netto_bytes, 0644, txlen_show, txlen_write);
 
-static ssize_t
-txtime_show (struct device *dev, struct device_attribute *attr, char *buf)
+static ssize_t txtime_show (struct device *dev, struct device_attribute *attr,
+			    char *buf)
 {
 	struct netiucv_priv *priv = dev->driver_data;
 
@@ -1638,8 +1642,8 @@ txtime_show (struct device *dev, struct 
 	return sprintf(buf, "%ld\n", priv->conn->prof.tx_time);
 }
 
-static ssize_t
-txtime_write (struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
+static ssize_t txtime_write (struct device *dev, struct device_attribute *attr,
+			     const char *buf, size_t count)
 {
 	struct netiucv_priv *priv = dev->driver_data;
 
@@ -1650,8 +1654,8 @@ txtime_write (struct device *dev, struct
 
 static DEVICE_ATTR(max_tx_io_time, 0644, txtime_show, txtime_write);
 
-static ssize_t
-txpend_show (struct device *dev, struct device_attribute *attr, char *buf)
+static ssize_t txpend_show (struct device *dev, struct device_attribute *attr,
+			    char *buf)
 {
 	struct netiucv_priv *priv = dev->driver_data;
 
@@ -1659,8 +1663,8 @@ txpend_show (struct device *dev, struct 
 	return sprintf(buf, "%ld\n", priv->conn->prof.tx_pending);
 }
 
-static ssize_t
-txpend_write (struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
+static ssize_t txpend_write (struct device *dev, struct device_attribute *attr,
+			     const char *buf, size_t count)
 {
 	struct netiucv_priv *priv = dev->driver_data;
 
@@ -1671,8 +1675,8 @@ txpend_write (struct device *dev, struct
 
 static DEVICE_ATTR(tx_pending, 0644, txpend_show, txpend_write);
 
-static ssize_t
-txmpnd_show (struct device *dev, struct device_attribute *attr, char *buf)
+static ssize_t txmpnd_show (struct device *dev, struct device_attribute *attr,
+			    char *buf)
 {
 	struct netiucv_priv *priv = dev->driver_data;
 
@@ -1680,8 +1684,8 @@ txmpnd_show (struct device *dev, struct 
 	return sprintf(buf, "%ld\n", priv->conn->prof.tx_max_pending);
 }
 
-static ssize_t
-txmpnd_write (struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
+static ssize_t txmpnd_write (struct device *dev, struct device_attribute *attr,
+			     const char *buf, size_t count)
 {
 	struct netiucv_priv *priv = dev->driver_data;
 
@@ -1721,8 +1725,7 @@ static struct attribute_group netiucv_st
 	.attrs = netiucv_stat_attrs,
 };
 
-static inline int
-netiucv_add_files(struct device *dev)
+static inline int netiucv_add_files(struct device *dev)
 {
 	int ret;
 
@@ -1736,18 +1739,16 @@ netiucv_add_files(struct device *dev)
 	return ret;
 }
 
-static inline void
-netiucv_remove_files(struct device *dev)
+static inline void netiucv_remove_files(struct device *dev)
 {
 	IUCV_DBF_TEXT(trace, 3, __FUNCTION__);
 	sysfs_remove_group(&dev->kobj, &netiucv_stat_attr_group);
 	sysfs_remove_group(&dev->kobj, &netiucv_attr_group);
 }
 
-static int
-netiucv_register_device(struct net_device *ndev)
+static int netiucv_register_device(struct net_device *ndev)
 {
-	struct netiucv_priv *priv = ndev->priv;
+	struct netiucv_priv *priv = netdev_priv(ndev);
 	struct device *dev = kzalloc(sizeof(struct device), GFP_KERNEL);
 	int ret;
 
@@ -1786,8 +1787,7 @@ out_unreg:
 	return ret;
 }
 
-static void
-netiucv_unregister_device(struct device *dev)
+static void netiucv_unregister_device(struct device *dev)
 {
 	IUCV_DBF_TEXT(trace, 3, __FUNCTION__);
 	netiucv_remove_files(dev);
@@ -1798,107 +1798,89 @@ netiucv_unregister_device(struct device 
  * Allocate and initialize a new connection structure.
  * Add it to the list of netiucv connections;
  */
-static struct iucv_connection *
-netiucv_new_connection(struct net_device *dev, char *username)
-{
-	unsigned long flags;
-	struct iucv_connection **clist = &iucv_conns.iucv_connections;
-	struct iucv_connection *conn =
-		kzalloc(sizeof(struct iucv_connection), GFP_KERNEL);
-
-	if (conn) {
-		skb_queue_head_init(&conn->collect_queue);
-		skb_queue_head_init(&conn->commit_queue);
-		spin_lock_init(&conn->collect_lock);
-		conn->max_buffsize = NETIUCV_BUFSIZE_DEFAULT;
-		conn->netdev = dev;
-
-		conn->rx_buff = alloc_skb(NETIUCV_BUFSIZE_DEFAULT,
-					  GFP_KERNEL | GFP_DMA);
-		if (!conn->rx_buff) {
-			kfree(conn);
-			return NULL;
-		}
-		conn->tx_buff = alloc_skb(NETIUCV_BUFSIZE_DEFAULT,
-					  GFP_KERNEL | GFP_DMA);
-		if (!conn->tx_buff) {
-			kfree_skb(conn->rx_buff);
-			kfree(conn);
-			return NULL;
-		}
-		conn->fsm = init_fsm("netiucvconn", conn_state_names,
-				     conn_event_names, NR_CONN_STATES,
-				     NR_CONN_EVENTS, conn_fsm, CONN_FSM_LEN,
-				     GFP_KERNEL);
-		if (!conn->fsm) {
-			kfree_skb(conn->tx_buff);
-			kfree_skb(conn->rx_buff);
-			kfree(conn);
-			return NULL;
-		}
-		fsm_settimer(conn->fsm, &conn->timer);
-		fsm_newstate(conn->fsm, CONN_STATE_INVALID);
-
-		if (username) {
-			memcpy(conn->userid, username, 9);
-			fsm_newstate(conn->fsm, CONN_STATE_STOPPED);
-		}
+static struct iucv_connection *netiucv_new_connection(struct net_device *dev,
+						      char *username)
+{
+	struct iucv_connection *conn;
 
-		write_lock_irqsave(&iucv_conns.iucv_rwlock, flags);
-		conn->next = *clist;
-		*clist = conn;
-		write_unlock_irqrestore(&iucv_conns.iucv_rwlock, flags);
+	conn = kzalloc(sizeof(*conn), GFP_KERNEL);
+	if (!conn)
+		goto out;
+	skb_queue_head_init(&conn->collect_queue);
+	skb_queue_head_init(&conn->commit_queue);
+	spin_lock_init(&conn->collect_lock);
+	conn->max_buffsize = NETIUCV_BUFSIZE_DEFAULT;
+	conn->netdev = dev;
+
+	conn->rx_buff = alloc_skb(conn->max_buffsize, GFP_KERNEL | GFP_DMA);
+	if (!conn->rx_buff)
+		goto out_conn;
+	conn->tx_buff = alloc_skb(conn->max_buffsize, GFP_KERNEL | GFP_DMA);
+	if (!conn->tx_buff)
+		goto out_rx;
+	conn->fsm = init_fsm("netiucvconn", conn_state_names,
+			     conn_event_names, NR_CONN_STATES,
+			     NR_CONN_EVENTS, conn_fsm, CONN_FSM_LEN,
+			     GFP_KERNEL);
+	if (!conn->fsm)
+		goto out_tx;
+
+	fsm_settimer(conn->fsm, &conn->timer);
+	fsm_newstate(conn->fsm, CONN_STATE_INVALID);
+
+	if (username) {
+		memcpy(conn->userid, username, 9);
+		fsm_newstate(conn->fsm, CONN_STATE_STOPPED);
 	}
+
+	write_lock_bh(&iucv_connection_rwlock);
+	list_add_tail(&conn->list, &iucv_connection_list);
+	write_unlock_bh(&iucv_connection_rwlock);
 	return conn;
+
+out_tx:
+	kfree_skb(conn->tx_buff);
+out_rx:
+	kfree_skb(conn->rx_buff);
+out_conn:
+	kfree(conn);
+out:
+	return NULL;
 }
 
 /**
  * Release a connection structure and remove it from the
  * list of netiucv connections.
  */
-static void
-netiucv_remove_connection(struct iucv_connection *conn)
+static void netiucv_remove_connection(struct iucv_connection *conn)
 {
-	struct iucv_connection **clist = &iucv_conns.iucv_connections;
-	unsigned long flags;
-
 	IUCV_DBF_TEXT(trace, 3, __FUNCTION__);
-	if (conn == NULL)
-		return;
-	write_lock_irqsave(&iucv_conns.iucv_rwlock, flags);
-	while (*clist) {
-		if (*clist == conn) {
-			*clist = conn->next;
-			write_unlock_irqrestore(&iucv_conns.iucv_rwlock, flags);
-			if (conn->handle) {
-				iucv_unregister_program(conn->handle);
-				conn->handle = NULL;
-			}
-			fsm_deltimer(&conn->timer);
-			kfree_fsm(conn->fsm);
-			kfree_skb(conn->rx_buff);
-			kfree_skb(conn->tx_buff);
-			return;
-		}
-		clist = &((*clist)->next);
+	write_lock_bh(&iucv_connection_rwlock);
+	list_del_init(&conn->list);
+	write_unlock_bh(&iucv_connection_rwlock);
+	if (conn->path) {
+		iucv_path_sever(conn->path, iucvMagic);
+		kfree(conn->path);
+		conn->path = NULL;
 	}
-	write_unlock_irqrestore(&iucv_conns.iucv_rwlock, flags);
+	fsm_deltimer(&conn->timer);
+	kfree_fsm(conn->fsm);
+	kfree_skb(conn->rx_buff);
+	kfree_skb(conn->tx_buff);
 }
 
 /**
  * Release everything of a net device.
  */
-static void
-netiucv_free_netdevice(struct net_device *dev)
+static void netiucv_free_netdevice(struct net_device *dev)
 {
-	struct netiucv_priv *privptr;
+	struct netiucv_priv *privptr = netdev_priv(dev);
 
 	IUCV_DBF_TEXT(trace, 3, __FUNCTION__);
 
 	if (!dev)
 		return;
 
-	privptr = (struct netiucv_priv *)dev->priv;
 	if (privptr) {
 		if (privptr->conn)
 			netiucv_remove_connection(privptr->conn);
@@ -1913,11 +1895,8 @@ netiucv_free_netdevice(struct net_device
 /**
  * Initialize a net device. (Called from kernel in alloc_netdev())
  */
-static void
-netiucv_setup_netdevice(struct net_device *dev)
+static void netiucv_setup_netdevice(struct net_device *dev)
 {
-        memset(dev->priv, 0, sizeof(struct netiucv_priv));
-
 	dev->mtu	         = NETIUCV_MTU_DEFAULT;
 	dev->hard_start_xmit     = netiucv_tx;
 	dev->open	         = netiucv_open;
@@ -1936,8 +1915,7 @@ netiucv_setup_netdevice(struct net_devic
 /**
  * Allocate and initialize everything of a net device.
  */
-static struct net_device *
-netiucv_init_netdevice(char *username)
+static struct net_device *netiucv_init_netdevice(char *username)
 {
 	struct netiucv_priv *privptr;
 	struct net_device *dev;
@@ -1946,40 +1924,40 @@ netiucv_init_netdevice(char *username)
 			   netiucv_setup_netdevice);
 	if (!dev)
 		return NULL;
-	if (dev_alloc_name(dev, dev->name) < 0) {
-		free_netdev(dev);
-		return NULL;
-	}
+	if (dev_alloc_name(dev, dev->name) < 0)
+		goto out_netdev;
 
-	privptr = (struct netiucv_priv *)dev->priv;
+	privptr = netdev_priv(dev);
 	privptr->fsm = init_fsm("netiucvdev", dev_state_names,
 				dev_event_names, NR_DEV_STATES, NR_DEV_EVENTS,
 				dev_fsm, DEV_FSM_LEN, GFP_KERNEL);
-	if (!privptr->fsm) {
-		free_netdev(dev);
-		return NULL;
-	}
+	if (!privptr->fsm)
+		goto out_netdev;
+
 	privptr->conn = netiucv_new_connection(dev, username);
 	if (!privptr->conn) {
-		kfree_fsm(privptr->fsm);
-		free_netdev(dev);
 		IUCV_DBF_TEXT(setup, 2, "NULL from netiucv_new_connection\n");
-		return NULL;
+		goto out_fsm;
 	}
 	fsm_newstate(privptr->fsm, DEV_STATE_STOPPED);
-
 	return dev;
+
+out_fsm:
+	kfree_fsm(privptr->fsm);
+out_netdev:
+	free_netdev(dev);
+	return NULL;
 }
 
-static ssize_t
-conn_write(struct device_driver *drv, const char *buf, size_t count)
+static ssize_t conn_write(struct device_driver *drv,
+			  const char *buf, size_t count)
 {
-	char *p;
+	const char *p;
 	char username[9];
-	int i, ret;
+	int i, rc;
 	struct net_device *dev;
-	struct iucv_connection **clist = &iucv_conns.iucv_connections;
-	unsigned long flags;
+	struct netiucv_priv *priv;
+	struct iucv_connection *cp;
 
 	IUCV_DBF_TEXT(trace, 3, __FUNCTION__);
 	if (count>9) {
@@ -1988,83 +1966,82 @@ conn_write(struct device_driver *drv, co
 		return -EINVAL;
 	}
 
-	for (i=0, p=(char *)buf; i<8 && *p; i++, p++) {
-		if (isalnum(*p) || (*p == '$'))
-			username[i]= toupper(*p);
-		else if (*p == '\n') {
+	for (i = 0, p = buf; i < 8 && *p; i++, p++) {
+		if (isalnum(*p) || *p == '$') {
+			username[i] = toupper(*p);
+			continue;
+		}
+		if (*p == '\n')
 			/* trailing lf, grr */
 			break;
-		} else {
-			PRINT_WARN("netiucv: Invalid character in username!\n");
-			IUCV_DBF_TEXT_(setup, 2,
-				"conn_write: invalid character %c\n", *p);
-			return -EINVAL;
-		}
+		PRINT_WARN("netiucv: Invalid character in username!\n");
+		IUCV_DBF_TEXT_(setup, 2,
+			       "conn_write: invalid character %c\n", *p);
+		return -EINVAL;
 	}
-	while (i<8)
+	while (i < 8)
 		username[i++] = ' ';
 	username[8] = '\0';
 
-	read_lock_irqsave(&iucv_conns.iucv_rwlock, flags);
-	while (*clist) {
-		if (!strncmp(username, (*clist)->userid, 9))
-			break;
-		clist = &((*clist)->next);
-	}
-	read_unlock_irqrestore(&iucv_conns.iucv_rwlock, flags);
-	if (*clist) {
-		PRINT_WARN("netiucv: Connection to %s already exists\n",
-			username);
-		return -EEXIST;
+	read_lock_bh(&iucv_connection_rwlock);
+	list_for_each_entry(cp, &iucv_connection_list, list) {
+		if (!strncmp(username, cp->userid, 9)) {
+			read_unlock_bh(&iucv_connection_rwlock);
+			PRINT_WARN("netiucv: Connection to %s already "
+				   "exists\n", username);
+			return -EEXIST;
+		}
 	}
+	read_unlock_bh(&iucv_connection_rwlock);
+
 	dev = netiucv_init_netdevice(username);
 	if (!dev) {
-		PRINT_WARN(
-		       "netiucv: Could not allocate network device structure "
-		       "for user '%s'\n", netiucv_printname(username));
+		PRINT_WARN("netiucv: Could not allocate network device "
+			   "structure for user '%s'\n",
+			   netiucv_printname(username));
 		IUCV_DBF_TEXT(setup, 2, "NULL from netiucv_init_netdevice\n");
 		return -ENODEV;
 	}
 
-	if ((ret = netiucv_register_device(dev))) {
+	rc = netiucv_register_device(dev);
+	if (rc) {
 		IUCV_DBF_TEXT_(setup, 2,
-			"ret %d from netiucv_register_device\n", ret);
+			"ret %d from netiucv_register_device\n", rc);
 		goto out_free_ndev;
 	}
 
 	/* sysfs magic */
-	SET_NETDEV_DEV(dev,
-			(struct device*)((struct netiucv_priv*)dev->priv)->dev);
+	priv = netdev_priv(dev);
+	SET_NETDEV_DEV(dev, priv->dev);
 
-	if ((ret = register_netdev(dev))) {
-		netiucv_unregister_device((struct device*)
-			((struct netiucv_priv*)dev->priv)->dev);
-		goto out_free_ndev;
-	}
+	rc = register_netdev(dev);
+	if (rc)
+		goto out_unreg;
 
 	PRINT_INFO("%s: '%s'\n", dev->name, netiucv_printname(username));
 
 	return count;
 
+out_unreg:
+	netiucv_unregister_device(priv->dev);
 out_free_ndev:
 	PRINT_WARN("netiucv: Could not register '%s'\n", dev->name);
 	IUCV_DBF_TEXT(setup, 2, "conn_write: could not register\n");
 	netiucv_free_netdevice(dev);
-	return ret;
+	return rc;
 }
 
-DRIVER_ATTR(connection, 0200, NULL, conn_write);
+static DRIVER_ATTR(connection, 0200, NULL, conn_write);
 
-static ssize_t
-remove_write (struct device_driver *drv, const char *buf, size_t count)
+static ssize_t remove_write (struct device_driver *drv,
+			     const char *buf, size_t count)
 {
-	struct iucv_connection **clist = &iucv_conns.iucv_connections;
-	unsigned long flags;
+	struct iucv_connection *cp;
         struct net_device *ndev;
         struct netiucv_priv *priv;
         struct device *dev;
         char name[IFNAMSIZ];
-        char *p;
+	const char *p;
         int i;
 
         IUCV_DBF_TEXT(trace, 3, __FUNCTION__);
@@ -2072,33 +2049,27 @@ remove_write (struct device_driver *drv,
         if (count >= IFNAMSIZ)
                 count = IFNAMSIZ - 1;;
 
-        for (i=0, p=(char *)buf; i<count && *p; i++, p++) {
-                if ((*p == '\n') || (*p == ' ')) {
+	for (i = 0, p = buf; i < count && *p; i++, p++) {
+		if (*p == '\n' || *p == ' ')
                         /* trailing lf, grr */
                         break;
-                } else {
-                        name[i]=*p;
-                }
+		name[i] = *p;
         }
         name[i] = '\0';
 
-	read_lock_irqsave(&iucv_conns.iucv_rwlock, flags);
-        while (*clist) {
-                ndev = (*clist)->netdev;
-                priv = (struct netiucv_priv*)ndev->priv;
+	read_lock_bh(&iucv_connection_rwlock);
+	list_for_each_entry(cp, &iucv_connection_list, list) {
+		ndev = cp->netdev;
+		priv = netdev_priv(ndev);
                 dev = priv->dev;
-
-                if (strncmp(name, ndev->name, count)) {
-                        clist = &((*clist)->next);
-                        continue;
-                }
-		read_unlock_irqrestore(&iucv_conns.iucv_rwlock, flags);
+		if (strncmp(name, ndev->name, count))
+			continue;
+		read_unlock_bh(&iucv_connection_rwlock);
                 if (ndev->flags & (IFF_UP | IFF_RUNNING)) {
-                        PRINT_WARN(
-                                "netiucv: net device %s active with peer %s\n",
-                                ndev->name, priv->conn->userid);
+			PRINT_WARN("netiucv: net device %s active with peer "
+				   "%s\n", ndev->name, priv->conn->userid);
                         PRINT_WARN("netiucv: %s cannot be removed\n",
-                                ndev->name);
+				   ndev->name);
 			IUCV_DBF_TEXT(data, 2, "remove_write: still active\n");
                         return -EBUSY;
                 }
@@ -2106,75 +2077,94 @@ remove_write (struct device_driver *drv,
                 netiucv_unregister_device(dev);
                 return count;
         }
-	read_unlock_irqrestore(&iucv_conns.iucv_rwlock, flags);
+	read_unlock_bh(&iucv_connection_rwlock);
         PRINT_WARN("netiucv: net device %s unknown\n", name);
 	IUCV_DBF_TEXT(data, 2, "remove_write: unknown device\n");
         return -EINVAL;
 }
 
-DRIVER_ATTR(remove, 0200, NULL, remove_write);
+static DRIVER_ATTR(remove, 0200, NULL, remove_write);
 
-static void
-netiucv_banner(void)
+static struct attribute * netiucv_drv_attrs[] = {
+	&driver_attr_connection.attr,
+	&driver_attr_remove.attr,
+	NULL,
+};
+
+static struct attribute_group netiucv_drv_attr_group = {
+	.attrs = netiucv_drv_attrs,
+};
+
+static void netiucv_banner(void)
 {
 	PRINT_INFO("NETIUCV driver initialized\n");
 }
 
-static void __exit
-netiucv_exit(void)
+static void __exit netiucv_exit(void)
 {
+	struct iucv_connection *cp;
+	struct net_device *ndev;
+	struct netiucv_priv *priv;
+	struct device *dev;
+
 	IUCV_DBF_TEXT(trace, 3, __FUNCTION__);
-	while (iucv_conns.iucv_connections) {
-		struct net_device *ndev = iucv_conns.iucv_connections->netdev;
-		struct netiucv_priv *priv = (struct netiucv_priv*)ndev->priv;
-		struct device *dev = priv->dev;
+	while (!list_empty(&iucv_connection_list)) {
+		cp = list_entry(iucv_connection_list.next,
+				struct iucv_connection, list);
+		list_del(&cp->list);
+		ndev = cp->netdev;
+		priv = netdev_priv(ndev);
+		dev = priv->dev;
 
 		unregister_netdev(ndev);
 		netiucv_unregister_device(dev);
 	}
 
-	driver_remove_file(&netiucv_driver, &driver_attr_connection);
-	driver_remove_file(&netiucv_driver, &driver_attr_remove);
+	sysfs_remove_group(&netiucv_driver.kobj, &netiucv_drv_attr_group);
 	driver_unregister(&netiucv_driver);
+	iucv_unregister(&netiucv_handler, 1);
 	iucv_unregister_dbf_views();
 
 	PRINT_INFO("NETIUCV driver unloaded\n");
 	return;
 }
 
-static int __init
-netiucv_init(void)
+static int __init netiucv_init(void)
 {
-	int ret;
+	int rc;
 
-	ret = iucv_register_dbf_views();
-	if (ret) {
-		PRINT_WARN("netiucv_init failed, "
-			"iucv_register_dbf_views rc = %d\n", ret);
-		return ret;
-	}
+	rc = iucv_register_dbf_views();
+	if (rc)
+		goto out;
+	rc = iucv_register(&netiucv_handler, 1);
+	if (rc)
+		goto out_dbf;
 	IUCV_DBF_TEXT(trace, 3, __FUNCTION__);
-	ret = driver_register(&netiucv_driver);
-	if (ret) {
+	rc = driver_register(&netiucv_driver);
+	if (rc) {
 		PRINT_ERR("NETIUCV: failed to register driver.\n");
-		IUCV_DBF_TEXT_(setup, 2, "ret %d from driver_register\n", ret);
-		iucv_unregister_dbf_views();
-		return ret;
+		IUCV_DBF_TEXT_(setup, 2, "ret %d from driver_register\n", rc);
+		goto out_iucv;
 	}
 
-	/* Add entry for specifying connections. */
-	ret = driver_create_file(&netiucv_driver, &driver_attr_connection);
-	if (!ret) {
-		ret = driver_create_file(&netiucv_driver, &driver_attr_remove);
-		netiucv_banner();
-		rwlock_init(&iucv_conns.iucv_rwlock);
-	} else {
-		PRINT_ERR("NETIUCV: failed to add driver attribute.\n");
-		IUCV_DBF_TEXT_(setup, 2, "ret %d from driver_create_file\n", ret);
-		driver_unregister(&netiucv_driver);
-		iucv_unregister_dbf_views();
+	rc = sysfs_create_group(&netiucv_driver.kobj, &netiucv_drv_attr_group);
+	if (rc) {
+		PRINT_ERR("NETIUCV: failed to add driver attributes.\n");
+		IUCV_DBF_TEXT_(setup, 2,
+			       "ret %d - netiucv_drv_attr_group\n", rc);
+		goto out_driver;
 	}
-	return ret;
+	netiucv_banner();
+	return rc;
+
+out_driver:
+	driver_unregister(&netiucv_driver);
+out_iucv:
+	iucv_unregister(&netiucv_handler, 1);
+out_dbf:
+	iucv_unregister_dbf_views();
+out:
+	return rc;
 }
 
 module_init(netiucv_init);
-- 
1.4.2.3

