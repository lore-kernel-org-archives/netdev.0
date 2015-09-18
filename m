From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next V2 5/5] s390/iucv: do not use arrays as argument
Date: Fri, 18 Sep 2015 16:06:52 +0200
Message-ID: <1442585212-58347-6-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1442585212-58347-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:45199 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752800AbbIROHF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 10:07:05 -0400
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 18 Sep 2015 15:07:03 +0100
In-Reply-To: <1442585212-58347-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

The iucv code uses arrays as arguments. Even though this does not
really cause a problem, it could be misleading, since the compiler
turns array arguments into just a pointer argument. To be more
precise this patch changes the array arguments into pointers.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 drivers/s390/char/monreader.c |  4 ++--
 drivers/s390/char/vmlogrdr.c  |  8 ++++----
 drivers/s390/net/netiucv.c    | 21 ++++++++++-----------
 drivers/s390/net/smsgiucv.c   |  5 ++---
 drivers/tty/hvc/hvc_iucv.c    | 10 +++++-----
 include/net/iucv/iucv.h       | 20 ++++++++++----------
 net/iucv/af_iucv.c            |  9 ++++-----
 net/iucv/iucv.c               | 12 ++++++------
 8 files changed, 43 insertions(+), 46 deletions(-)

diff --git a/drivers/s390/char/monreader.c b/drivers/s390/char/monreader.c
index b7d6030..fc94bfd 100644
--- a/drivers/s390/char/monreader.c
+++ b/drivers/s390/char/monreader.c
@@ -229,7 +229,7 @@ static struct mon_msg *mon_next_message(struct mon_private *monpriv)
 /******************************************************************************
  *                               IUCV handler                                 *
  *****************************************************************************/
-static void mon_iucv_path_complete(struct iucv_path *path, u8 ipuser[16])
+static void mon_iucv_path_complete(struct iucv_path *path, u8 *ipuser)
 {
 	struct mon_private *monpriv = path->private;
 
@@ -237,7 +237,7 @@ static void mon_iucv_path_complete(struct iucv_path *path, u8 ipuser[16])
 	wake_up(&mon_conn_wait_queue);
 }
 
-static void mon_iucv_path_severed(struct iucv_path *path, u8 ipuser[16])
+static void mon_iucv_path_severed(struct iucv_path *path, u8 *ipuser)
 {
 	struct mon_private *monpriv = path->private;
 
diff --git a/drivers/s390/char/vmlogrdr.c b/drivers/s390/char/vmlogrdr.c
index 9bb48d7..799c152 100644
--- a/drivers/s390/char/vmlogrdr.c
+++ b/drivers/s390/char/vmlogrdr.c
@@ -99,8 +99,8 @@ static const struct file_operations vmlogrdr_fops = {
 };
 
 
-static void vmlogrdr_iucv_path_complete(struct iucv_path *, u8 ipuser[16]);
-static void vmlogrdr_iucv_path_severed(struct iucv_path *, u8 ipuser[16]);
+static void vmlogrdr_iucv_path_complete(struct iucv_path *, u8 *ipuser);
+static void vmlogrdr_iucv_path_severed(struct iucv_path *, u8 *ipuser);
 static void vmlogrdr_iucv_message_pending(struct iucv_path *,
 					  struct iucv_message *);
 
@@ -160,7 +160,7 @@ static struct cdev  *vmlogrdr_cdev = NULL;
 static int recording_class_AB;
 
 
-static void vmlogrdr_iucv_path_complete(struct iucv_path *path, u8 ipuser[16])
+static void vmlogrdr_iucv_path_complete(struct iucv_path *path, u8 *ipuser)
 {
 	struct vmlogrdr_priv_t * logptr = path->private;
 
@@ -171,7 +171,7 @@ static void vmlogrdr_iucv_path_complete(struct iucv_path *path, u8 ipuser[16])
 }
 
 
-static void vmlogrdr_iucv_path_severed(struct iucv_path *path, u8 ipuser[16])
+static void vmlogrdr_iucv_path_severed(struct iucv_path *path, u8 *ipuser)
 {
 	struct vmlogrdr_priv_t * logptr = path->private;
 	u8 reason = (u8) ipuser[8];
diff --git a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
index 33f7040..0ba3a2f 100644
--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -149,12 +149,11 @@ static struct device_driver netiucv_driver = {
 	.pm = &netiucv_pm_ops,
 };
 
-static int netiucv_callback_connreq(struct iucv_path *,
-				    u8 ipvmid[8], u8 ipuser[16]);
-static void netiucv_callback_connack(struct iucv_path *, u8 ipuser[16]);
-static void netiucv_callback_connrej(struct iucv_path *, u8 ipuser[16]);
-static void netiucv_callback_connsusp(struct iucv_path *, u8 ipuser[16]);
-static void netiucv_callback_connres(struct iucv_path *, u8 ipuser[16]);
+static int netiucv_callback_connreq(struct iucv_path *, u8 *, u8 *);
+static void netiucv_callback_connack(struct iucv_path *, u8 *);
+static void netiucv_callback_connrej(struct iucv_path *, u8 *);
+static void netiucv_callback_connsusp(struct iucv_path *, u8 *);
+static void netiucv_callback_connres(struct iucv_path *, u8 *);
 static void netiucv_callback_rx(struct iucv_path *, struct iucv_message *);
 static void netiucv_callback_txdone(struct iucv_path *, struct iucv_message *);
 
@@ -556,8 +555,8 @@ static void netiucv_callback_connack(struct iucv_path *path, u8 ipuser[16])
 	fsm_event(conn->fsm, CONN_EVENT_CONN_ACK, conn);
 }
 
-static int netiucv_callback_connreq(struct iucv_path *path,
-				    u8 ipvmid[8], u8 ipuser[16])
+static int netiucv_callback_connreq(struct iucv_path *path, u8 *ipvmid,
+				    u8 *ipuser)
 {
 	struct iucv_connection *conn = path->private;
 	struct iucv_event ev;
@@ -587,21 +586,21 @@ static int netiucv_callback_connreq(struct iucv_path *path,
 	return rc;
 }
 
-static void netiucv_callback_connrej(struct iucv_path *path, u8 ipuser[16])
+static void netiucv_callback_connrej(struct iucv_path *path, u8 *ipuser)
 {
 	struct iucv_connection *conn = path->private;
 
 	fsm_event(conn->fsm, CONN_EVENT_CONN_REJ, conn);
 }
 
-static void netiucv_callback_connsusp(struct iucv_path *path, u8 ipuser[16])
+static void netiucv_callback_connsusp(struct iucv_path *path, u8 *ipuser)
 {
 	struct iucv_connection *conn = path->private;
 
 	fsm_event(conn->fsm, CONN_EVENT_CONN_SUS, conn);
 }
 
-static void netiucv_callback_connres(struct iucv_path *path, u8 ipuser[16])
+static void netiucv_callback_connres(struct iucv_path *path, u8 *ipuser)
 {
 	struct iucv_connection *conn = path->private;
 
diff --git a/drivers/s390/net/smsgiucv.c b/drivers/s390/net/smsgiucv.c
index d8f990b..a851d34 100644
--- a/drivers/s390/net/smsgiucv.c
+++ b/drivers/s390/net/smsgiucv.c
@@ -49,7 +49,7 @@ static DEFINE_SPINLOCK(smsg_list_lock);
 static LIST_HEAD(smsg_list);
 static int iucv_path_connected;
 
-static int smsg_path_pending(struct iucv_path *, u8 ipvmid[8], u8 ipuser[16]);
+static int smsg_path_pending(struct iucv_path *, u8 *, u8 *);
 static void smsg_message_pending(struct iucv_path *, struct iucv_message *);
 
 static struct iucv_handler smsg_handler = {
@@ -57,8 +57,7 @@ static struct iucv_handler smsg_handler = {
 	.message_pending = smsg_message_pending,
 };
 
-static int smsg_path_pending(struct iucv_path *path, u8 ipvmid[8],
-			     u8 ipuser[16])
+static int smsg_path_pending(struct iucv_path *path, u8 *ipvmid, u8 *ipuser)
 {
 	if (strncmp(ipvmid, "*MSG    ", 8) != 0)
 		return -EINVAL;
diff --git a/drivers/tty/hvc/hvc_iucv.c b/drivers/tty/hvc/hvc_iucv.c
index bb809cf..8b70a16 100644
--- a/drivers/tty/hvc/hvc_iucv.c
+++ b/drivers/tty/hvc/hvc_iucv.c
@@ -88,8 +88,8 @@ struct iucv_tty_buffer {
 };
 
 /* IUCV callback handler */
-static	int hvc_iucv_path_pending(struct iucv_path *, u8[8], u8[16]);
-static void hvc_iucv_path_severed(struct iucv_path *, u8[16]);
+static	int hvc_iucv_path_pending(struct iucv_path *, u8 *, u8 *);
+static void hvc_iucv_path_severed(struct iucv_path *, u8 *);
 static void hvc_iucv_msg_pending(struct iucv_path *, struct iucv_message *);
 static void hvc_iucv_msg_complete(struct iucv_path *, struct iucv_message *);
 
@@ -782,8 +782,8 @@ static int hvc_iucv_filter_connreq(u8 ipvmid[8])
  *
  * Locking:	struct hvc_iucv_private->lock
  */
-static	int hvc_iucv_path_pending(struct iucv_path *path,
-				  u8 ipvmid[8], u8 ipuser[16])
+static	int hvc_iucv_path_pending(struct iucv_path *path, u8 *ipvmid,
+				  u8 *ipuser)
 {
 	struct hvc_iucv_private *priv, *tmp;
 	u8 wildcard[9] = "lnxhvc  ";
@@ -881,7 +881,7 @@ out_path_handled:
  *
  * Locking:	struct hvc_iucv_private->lock
  */
-static void hvc_iucv_path_severed(struct iucv_path *path, u8 ipuser[16])
+static void hvc_iucv_path_severed(struct iucv_path *path, u8 *ipuser)
 {
 	struct hvc_iucv_private *priv = path->private;
 
diff --git a/include/net/iucv/iucv.h b/include/net/iucv/iucv.h
index 0894ced..b867b0c 100644
--- a/include/net/iucv/iucv.h
+++ b/include/net/iucv/iucv.h
@@ -141,14 +141,14 @@ struct iucv_handler {
 	  * called is the order of the registration of the iucv handlers
 	  * to the base code.
 	  */
-	int  (*path_pending)(struct iucv_path *, u8 ipvmid[8], u8 ipuser[16]);
+	int  (*path_pending)(struct iucv_path *, u8 *ipvmid, u8 *ipuser);
 	/*
 	 * The path_complete function is called after an iucv interrupt
 	 * type 0x02 has been received for a path that has been established
 	 * for this handler with iucv_path_connect and got accepted by the
 	 * peer with iucv_path_accept.
 	 */
-	void (*path_complete)(struct iucv_path *, u8 ipuser[16]);
+	void (*path_complete)(struct iucv_path *, u8 *ipuser);
 	 /*
 	  * The path_severed function is called after an iucv interrupt
 	  * type 0x03 has been received. The communication peer shutdown
@@ -156,20 +156,20 @@ struct iucv_handler {
 	  * remaining messages can be received until a iucv_path_sever
 	  * shuts down the other end of the path as well.
 	  */
-	void (*path_severed)(struct iucv_path *, u8 ipuser[16]);
+	void (*path_severed)(struct iucv_path *, u8 *ipuser);
 	/*
 	 * The path_quiesced function is called after an icuv interrupt
 	 * type 0x04 has been received. The communication peer has quiesced
 	 * the path. Delivery of messages is stopped until iucv_path_resume
 	 * has been called.
 	 */
-	void (*path_quiesced)(struct iucv_path *, u8 ipuser[16]);
+	void (*path_quiesced)(struct iucv_path *, u8 *ipuser);
 	/*
 	 * The path_resumed function is called after an icuv interrupt
 	 * type 0x05 has been received. The communication peer has resumed
 	 * the path.
 	 */
-	void (*path_resumed)(struct iucv_path *, u8 ipuser[16]);
+	void (*path_resumed)(struct iucv_path *, u8 *ipuser);
 	/*
 	 * The message_pending function is called after an icuv interrupt
 	 * type 0x06 or type 0x07 has been received. A new message is
@@ -256,7 +256,7 @@ static inline void iucv_path_free(struct iucv_path *path)
  * Returns the result of the CP IUCV call.
  */
 int iucv_path_accept(struct iucv_path *path, struct iucv_handler *handler,
-		     u8 userdata[16], void *private);
+		     u8 *userdata, void *private);
 
 /**
  * iucv_path_connect
@@ -274,7 +274,7 @@ int iucv_path_accept(struct iucv_path *path, struct iucv_handler *handler,
  * Returns the result of the CP IUCV call.
  */
 int iucv_path_connect(struct iucv_path *path, struct iucv_handler *handler,
-		      u8 userid[8], u8 system[8], u8 userdata[16],
+		      u8 *userid, u8 *system, u8 *userdata,
 		      void *private);
 
 /**
@@ -287,7 +287,7 @@ int iucv_path_connect(struct iucv_path *path, struct iucv_handler *handler,
  *
  * Returns the result from the CP IUCV call.
  */
-int iucv_path_quiesce(struct iucv_path *path, u8 userdata[16]);
+int iucv_path_quiesce(struct iucv_path *path, u8 *userdata);
 
 /**
  * iucv_path_resume:
@@ -299,7 +299,7 @@ int iucv_path_quiesce(struct iucv_path *path, u8 userdata[16]);
  *
  * Returns the result from the CP IUCV call.
  */
-int iucv_path_resume(struct iucv_path *path, u8 userdata[16]);
+int iucv_path_resume(struct iucv_path *path, u8 *userdata);
 
 /**
  * iucv_path_sever
@@ -310,7 +310,7 @@ int iucv_path_resume(struct iucv_path *path, u8 userdata[16]);
  *
  * Returns the result from the CP IUCV call.
  */
-int iucv_path_sever(struct iucv_path *path, u8 userdata[16]);
+int iucv_path_sever(struct iucv_path *path, u8 *userdata);
 
 /**
  * iucv_message_purge
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index 918151c..fcb2752 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -95,11 +95,10 @@ static void afiucv_hs_callback_txnotify(struct sk_buff *, enum iucv_tx_notify);
 /* Call Back functions */
 static void iucv_callback_rx(struct iucv_path *, struct iucv_message *);
 static void iucv_callback_txdone(struct iucv_path *, struct iucv_message *);
-static void iucv_callback_connack(struct iucv_path *, u8 ipuser[16]);
-static int iucv_callback_connreq(struct iucv_path *, u8 ipvmid[8],
-				 u8 ipuser[16]);
-static void iucv_callback_connrej(struct iucv_path *, u8 ipuser[16]);
-static void iucv_callback_shutdown(struct iucv_path *, u8 ipuser[16]);
+static void iucv_callback_connack(struct iucv_path *, u8 *);
+static int iucv_callback_connreq(struct iucv_path *, u8 *, u8 *);
+static void iucv_callback_connrej(struct iucv_path *, u8 *);
+static void iucv_callback_shutdown(struct iucv_path *, u8 *);
 
 static struct iucv_sock_list iucv_sk_list = {
 	.lock = __RW_LOCK_UNLOCKED(iucv_sk_list.lock),
diff --git a/net/iucv/iucv.c b/net/iucv/iucv.c
index 2a6a1fd..7eaa000 100644
--- a/net/iucv/iucv.c
+++ b/net/iucv/iucv.c
@@ -713,7 +713,7 @@ static struct notifier_block __refdata iucv_cpu_notifier = {
  *
  * Sever an iucv path to free up the pathid. Used internally.
  */
-static int iucv_sever_pathid(u16 pathid, u8 userdata[16])
+static int iucv_sever_pathid(u16 pathid, u8 *userdata)
 {
 	union iucv_param *parm;
 
@@ -876,7 +876,7 @@ static struct notifier_block iucv_reboot_notifier = {
  * Returns the result of the CP IUCV call.
  */
 int iucv_path_accept(struct iucv_path *path, struct iucv_handler *handler,
-		     u8 userdata[16], void *private)
+		     u8 *userdata, void *private)
 {
 	union iucv_param *parm;
 	int rc;
@@ -923,7 +923,7 @@ EXPORT_SYMBOL(iucv_path_accept);
  * Returns the result of the CP IUCV call.
  */
 int iucv_path_connect(struct iucv_path *path, struct iucv_handler *handler,
-		      u8 userid[8], u8 system[8], u8 userdata[16],
+		      u8 *userid, u8 *system, u8 *userdata,
 		      void *private)
 {
 	union iucv_param *parm;
@@ -985,7 +985,7 @@ EXPORT_SYMBOL(iucv_path_connect);
  *
  * Returns the result from the CP IUCV call.
  */
-int iucv_path_quiesce(struct iucv_path *path, u8 userdata[16])
+int iucv_path_quiesce(struct iucv_path *path, u8 *userdata)
 {
 	union iucv_param *parm;
 	int rc;
@@ -1017,7 +1017,7 @@ EXPORT_SYMBOL(iucv_path_quiesce);
  *
  * Returns the result from the CP IUCV call.
  */
-int iucv_path_resume(struct iucv_path *path, u8 userdata[16])
+int iucv_path_resume(struct iucv_path *path, u8 *userdata)
 {
 	union iucv_param *parm;
 	int rc;
@@ -1047,7 +1047,7 @@ out:
  *
  * Returns the result from the CP IUCV call.
  */
-int iucv_path_sever(struct iucv_path *path, u8 userdata[16])
+int iucv_path_sever(struct iucv_path *path, u8 *userdata)
 {
 	int rc;
 
-- 
2.3.8
