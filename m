From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 3/7] [S390]: Adapt monreader driver to new IUCV API
Date: Mon, 5 Feb 2007 15:02:05 +0100
Message-ID: <20070205140205.GD19137@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-s390@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:47800 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932614AbXBEOCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 09:02:00 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Martin Schwidefsky <schwidefsky@de.ibm.com>

Adapt monreader character device driver to new IUCV API

Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

drivers/s390/char/monreader.c |  218 +++++++++++++++++++----------------------
 1 files changed, 101 insertions(+), 117 deletions(-)

diff --git a/drivers/s390/char/monreader.c b/drivers/s390/char/monreader.c
index a138b15..3a1a958 100644
--- a/drivers/s390/char/monreader.c
+++ b/drivers/s390/char/monreader.c
@@ -3,7 +3,7 @@
  *
  * Character device driver for reading z/VM *MONITOR service records.
  *
- * Copyright (C) 2004 IBM Corporation, IBM Deutschland Entwicklung GmbH.
+ * Copyright 2004 IBM Corporation, IBM Deutschland Entwicklung GmbH.
  *
  * Author: Gerald Schaefer <geraldsc@de.ibm.com>
  */
@@ -22,7 +22,7 @@ #include <asm/uaccess.h>
 #include <asm/ebcdic.h>
 #include <asm/extmem.h>
 #include <linux/poll.h>
-#include "../net/iucv.h"
+#include <net/iucv/iucv.h>
 
 
 //#define MON_DEBUG			/* Debug messages on/off */
@@ -50,14 +50,13 @@ static char mon_dcss_name[9] = "MONDCSS\
 struct mon_msg {
 	u32 pos;
 	u32 mca_offset;
-	iucv_MessagePending local_eib;
+	struct iucv_message msg;
 	char msglim_reached;
 	char replied_msglim;
 };
 
 struct mon_private {
-	u16 pathid;
-	iucv_handle_t iucv_handle;
+	struct iucv_path *path;
 	struct mon_msg *msg_array[MON_MSGLIM];
 	unsigned int   write_index;
 	unsigned int   read_index;
@@ -75,8 +74,6 @@ static unsigned long mon_dcss_end;
 static DECLARE_WAIT_QUEUE_HEAD(mon_read_wait_queue);
 static DECLARE_WAIT_QUEUE_HEAD(mon_conn_wait_queue);
 
-static u8 iucv_host[8] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
-
 static u8 user_data_connect[16] = {
 	/* Version code, must be 0x01 for shared mode */
 	0x01,
@@ -100,8 +97,7 @@ static u8 user_data_sever[16] = {
  * Create the 8 bytes EBCDIC DCSS segment name from
  * an ASCII name, incl. padding
  */
-static inline void
-dcss_mkname(char *ascii_name, char *ebcdic_name)
+static inline void dcss_mkname(char *ascii_name, char *ebcdic_name)
 {
 	int i;
 
@@ -119,8 +115,7 @@ dcss_mkname(char *ascii_name, char *ebcd
  * print appropriate error message for segment_load()/segment_type()
  * return code
  */
-static void
-mon_segment_warn(int rc, char* seg_name)
+static void mon_segment_warn(int rc, char* seg_name)
 {
 	switch (rc) {
 	case -ENOENT:
@@ -166,44 +161,37 @@ mon_segment_warn(int rc, char* seg_name)
 	}
 }
 
-static inline unsigned long
-mon_mca_start(struct mon_msg *monmsg)
+static inline unsigned long mon_mca_start(struct mon_msg *monmsg)
 {
-	return monmsg->local_eib.ln1msg1.iprmmsg1_u32;
+	return *(u32 *) &monmsg->msg.rmmsg;
 }
 
-static inline unsigned long
-mon_mca_end(struct mon_msg *monmsg)
+static inline unsigned long mon_mca_end(struct mon_msg *monmsg)
 {
-	return monmsg->local_eib.ln1msg2.ipbfln1f;
+	return *(u32 *) &monmsg->msg.rmmsg[4];
 }
 
-static inline u8
-mon_mca_type(struct mon_msg *monmsg, u8 index)
+static inline u8 mon_mca_type(struct mon_msg *monmsg, u8 index)
 {
 	return *((u8 *) mon_mca_start(monmsg) + monmsg->mca_offset + index);
 }
 
-static inline u32
-mon_mca_size(struct mon_msg *monmsg)
+static inline u32 mon_mca_size(struct mon_msg *monmsg)
 {
 	return mon_mca_end(monmsg) - mon_mca_start(monmsg) + 1;
 }
 
-static inline u32
-mon_rec_start(struct mon_msg *monmsg)
+static inline u32 mon_rec_start(struct mon_msg *monmsg)
 {
 	return *((u32 *) (mon_mca_start(monmsg) + monmsg->mca_offset + 4));
 }
 
-static inline u32
-mon_rec_end(struct mon_msg *monmsg)
+static inline u32 mon_rec_end(struct mon_msg *monmsg)
 {
 	return *((u32 *) (mon_mca_start(monmsg) + monmsg->mca_offset + 8));
 }
 
-static inline int
-mon_check_mca(struct mon_msg *monmsg)
+static inline int mon_check_mca(struct mon_msg *monmsg)
 {
 	if ((mon_rec_end(monmsg) <= mon_rec_start(monmsg)) ||
 	    (mon_rec_start(monmsg) < mon_dcss_start) ||
@@ -221,20 +209,17 @@ mon_check_mca(struct mon_msg *monmsg)
 	return 0;
 }
 
-static inline int
-mon_send_reply(struct mon_msg *monmsg, struct mon_private *monpriv)
+static inline int mon_send_reply(struct mon_msg *monmsg,
+				 struct mon_private *monpriv)
 {
-	u8 prmmsg[8];
 	int rc;
 
 	P_DEBUG("read, REPLY: pathid = 0x%04X, msgid = 0x%08X, trgcls = "
 		"0x%08X\n\n",
-		monmsg->local_eib.ippathid, monmsg->local_eib.ipmsgid,
-		monmsg->local_eib.iptrgcls);
-	rc = iucv_reply_prmmsg(monmsg->local_eib.ippathid,
-				monmsg->local_eib.ipmsgid,
-				monmsg->local_eib.iptrgcls,
-				0, prmmsg);
+		monpriv->path->pathid, monmsg->msg.id, monmsg->msg.class);
+
+	rc = iucv_message_reply(monpriv->path, &monmsg->msg,
+				IUCV_IPRMDATA, NULL, 0);
 	atomic_dec(&monpriv->msglim_count);
 	if (likely(!monmsg->msglim_reached)) {
 		monmsg->pos = 0;
@@ -251,10 +236,19 @@ mon_send_reply(struct mon_msg *monmsg, s
 	return 0;
 }
 
-static inline struct mon_private *
-mon_alloc_mem(void)
+static inline void mon_free_mem(struct mon_private *monpriv)
+{
+	int i;
+
+	for (i = 0; i < MON_MSGLIM; i++)
+		if (monpriv->msg_array[i])
+			kfree(monpriv->msg_array[i]);
+	kfree(monpriv);
+}
+
+static inline struct mon_private *mon_alloc_mem(void)
 {
-	int i,j;
+	int i;
 	struct mon_private *monpriv;
 
 	monpriv = kzalloc(sizeof(struct mon_private), GFP_KERNEL);
@@ -267,16 +261,15 @@ mon_alloc_mem(void)
 						    GFP_KERNEL);
 		if (!monpriv->msg_array[i]) {
 			P_ERROR("open, no memory for msg_array\n");
-			for (j = 0; j < i; j++)
-				kfree(monpriv->msg_array[j]);
+			mon_free_mem(monpriv);
 			return NULL;
 		}
 	}
 	return monpriv;
 }
 
-static inline void
-mon_read_debug(struct mon_msg *monmsg, struct mon_private *monpriv)
+static inline void mon_read_debug(struct mon_msg *monmsg,
+				  struct mon_private *monpriv)
 {
 #ifdef MON_DEBUG
 	u8 msg_type[2], mca_type;
@@ -284,7 +277,7 @@ #ifdef MON_DEBUG
 
 	records_len = mon_rec_end(monmsg) - mon_rec_start(monmsg) + 1;
 
-	memcpy(msg_type, &monmsg->local_eib.iptrgcls, 2);
+	memcpy(msg_type, &monmsg->msg.class, 2);
 	EBCASC(msg_type, 2);
 	mca_type = mon_mca_type(monmsg, 0);
 	EBCASC(&mca_type, 1);
@@ -292,8 +285,7 @@ #ifdef MON_DEBUG
 	P_DEBUG("read, mon_read_index = %i, mon_write_index = %i\n",
 		monpriv->read_index, monpriv->write_index);
 	P_DEBUG("read, pathid = 0x%04X, msgid = 0x%08X, trgcls = 0x%08X\n",
-		monmsg->local_eib.ippathid, monmsg->local_eib.ipmsgid,
-		monmsg->local_eib.iptrgcls);
+		monpriv->path->pathid, monmsg->msg.id, monmsg->msg.class);
 	P_DEBUG("read, msg_type = '%c%c', mca_type = '%c' / 0x%X / 0x%X\n",
 		msg_type[0], msg_type[1], mca_type ? mca_type : 'X',
 		mon_mca_type(monmsg, 1), mon_mca_type(monmsg, 2));
@@ -306,8 +298,7 @@ #ifdef MON_DEBUG
 #endif
 }
 
-static inline void
-mon_next_mca(struct mon_msg *monmsg)
+static inline void mon_next_mca(struct mon_msg *monmsg)
 {
 	if (likely((mon_mca_size(monmsg) - monmsg->mca_offset) == 12))
 		return;
@@ -316,8 +307,7 @@ mon_next_mca(struct mon_msg *monmsg)
 	monmsg->pos = 0;
 }
 
-static inline struct mon_msg *
-mon_next_message(struct mon_private *monpriv)
+static inline struct mon_msg *mon_next_message(struct mon_private *monpriv)
 {
 	struct mon_msg *monmsg;
 
@@ -342,39 +332,37 @@ mon_next_message(struct mon_private *mon
 /******************************************************************************
  *                               IUCV handler                                 *
  *****************************************************************************/
-static void
-mon_iucv_ConnectionComplete(iucv_ConnectionComplete *eib, void *pgm_data)
+static void mon_iucv_path_complete(struct iucv_path *path, u8 ipuser[16])
 {
-	struct mon_private *monpriv = (struct mon_private *) pgm_data;
+	struct mon_private *monpriv = path->private;
 
 	P_DEBUG("IUCV connection completed\n");
 	P_DEBUG("IUCV ACCEPT (from *MONITOR): Version = 0x%02X, Event = "
 		"0x%02X, Sample = 0x%02X\n",
-		eib->ipuser[0], eib->ipuser[1], eib->ipuser[2]);
+		ipuser[0], ipuser[1], ipuser[2]);
 	atomic_set(&monpriv->iucv_connected, 1);
 	wake_up(&mon_conn_wait_queue);
 }
 
-static void
-mon_iucv_ConnectionSevered(iucv_ConnectionSevered *eib, void *pgm_data)
+static void mon_iucv_path_severed(struct iucv_path *path, u8 ipuser[16])
 {
-	struct mon_private *monpriv = (struct mon_private *) pgm_data;
+	struct mon_private *monpriv = path->private;
 
-	P_ERROR("IUCV connection severed with rc = 0x%X\n",
-		(u8) eib->ipuser[0]);
+	P_ERROR("IUCV connection severed with rc = 0x%X\n", ipuser[0]);
+	iucv_path_sever(path, NULL);
 	atomic_set(&monpriv->iucv_severed, 1);
 	wake_up(&mon_conn_wait_queue);
 	wake_up_interruptible(&mon_read_wait_queue);
 }
 
-static void
-mon_iucv_MessagePending(iucv_MessagePending *eib, void *pgm_data)
+static void mon_iucv_message_pending(struct iucv_path *path,
+				     struct iucv_message *msg)
 {
-	struct mon_private *monpriv = (struct mon_private *) pgm_data;
+	struct mon_private *monpriv = path->private;
 
 	P_DEBUG("IUCV message pending\n");
-	memcpy(&monpriv->msg_array[monpriv->write_index]->local_eib, eib,
-	       sizeof(iucv_MessagePending));
+	memcpy(&monpriv->msg_array[monpriv->write_index]->msg,
+	       msg, sizeof(*msg));
 	if (atomic_inc_return(&monpriv->msglim_count) == MON_MSGLIM) {
 		P_WARNING("IUCV message pending, message limit (%i) reached\n",
 			  MON_MSGLIM);
@@ -385,54 +373,45 @@ mon_iucv_MessagePending(iucv_MessagePend
 	wake_up_interruptible(&mon_read_wait_queue);
 }
 
-static iucv_interrupt_ops_t mon_iucvops = {
-	.ConnectionComplete = mon_iucv_ConnectionComplete,
-	.ConnectionSevered  = mon_iucv_ConnectionSevered,
-	.MessagePending     = mon_iucv_MessagePending,
+static struct iucv_handler monreader_iucv_handler = {
+	.path_complete	 = mon_iucv_path_complete,
+	.path_severed	 = mon_iucv_path_severed,
+	.message_pending = mon_iucv_message_pending,
 };
 
 /******************************************************************************
  *                               file operations                              *
  *****************************************************************************/
-static int
-mon_open(struct inode *inode, struct file *filp)
+static int mon_open(struct inode *inode, struct file *filp)
 {
-	int rc, i;
 	struct mon_private *monpriv;
+	int rc;
 
 	/*
 	 * only one user allowed
 	 */
+	rc = -EBUSY;
 	if (test_and_set_bit(MON_IN_USE, &mon_in_use))
-		return -EBUSY;
+		goto out;
 
+	rc = -ENOMEM;
 	monpriv = mon_alloc_mem();
 	if (!monpriv)
-		return -ENOMEM;
+		goto out_use;
 
 	/*
-	 * Register with IUCV and connect to *MONITOR service
+	 * Connect to *MONITOR service
 	 */
-	monpriv->iucv_handle = iucv_register_program("my_monreader    ",
-							MON_SERVICE,
-							NULL,
-							&mon_iucvops,
-							monpriv);
-	if (!monpriv->iucv_handle) {
-		P_ERROR("failed to register with iucv driver\n");
-		rc = -EIO;
-		goto out_error;
-	}
-	P_INFO("open, registered with IUCV\n");
-
-	rc = iucv_connect(&monpriv->pathid, MON_MSGLIM, user_data_connect,
-			  MON_SERVICE, iucv_host, IPRMDATA, NULL, NULL,
-			  monpriv->iucv_handle, NULL);
+	monpriv->path = iucv_path_alloc(MON_MSGLIM, IUCV_IPRMDATA, GFP_KERNEL);
+	if (!monpriv->path)
+		goto out_priv;
+	rc = iucv_path_connect(monpriv->path, &monreader_iucv_handler,
+			       MON_SERVICE, NULL, user_data_connect, monpriv);
 	if (rc) {
 		P_ERROR("iucv connection to *MONITOR failed with "
 			"IPUSER SEVER code = %i\n", rc);
 		rc = -EIO;
-		goto out_unregister;
+		goto out_path;
 	}
 	/*
 	 * Wait for connection confirmation
@@ -444,24 +423,23 @@ mon_open(struct inode *inode, struct fil
 		atomic_set(&monpriv->iucv_severed, 0);
 		atomic_set(&monpriv->iucv_connected, 0);
 		rc = -EIO;
-		goto out_unregister;
+		goto out_path;
 	}
 	P_INFO("open, established connection to *MONITOR service\n\n");
 	filp->private_data = monpriv;
 	return nonseekable_open(inode, filp);
 
-out_unregister:
-	iucv_unregister_program(monpriv->iucv_handle);
-out_error:
-	for (i = 0; i < MON_MSGLIM; i++)
-		kfree(monpriv->msg_array[i]);
-	kfree(monpriv);
+out_path:
+	kfree(monpriv->path);
+out_priv:
+	mon_free_mem(monpriv);
+out_use:
 	clear_bit(MON_IN_USE, &mon_in_use);
+out:
 	return rc;
 }
 
-static int
-mon_close(struct inode *inode, struct file *filp)
+static int mon_close(struct inode *inode, struct file *filp)
 {
 	int rc, i;
 	struct mon_private *monpriv = filp->private_data;
@@ -469,18 +447,12 @@ mon_close(struct inode *inode, struct fi
 	/*
 	 * Close IUCV connection and unregister
 	 */
-	rc = iucv_sever(monpriv->pathid, user_data_sever);
+	rc = iucv_path_sever(monpriv->path, user_data_sever);
 	if (rc)
 		P_ERROR("close, iucv_sever failed with rc = %i\n", rc);
 	else
 		P_INFO("close, terminated connection to *MONITOR service\n");
 
-	rc = iucv_unregister_program(monpriv->iucv_handle);
-	if (rc)
-		P_ERROR("close, iucv_unregister failed with rc = %i\n", rc);
-	else
-		P_INFO("close, unregistered with IUCV\n");
-
 	atomic_set(&monpriv->iucv_severed, 0);
 	atomic_set(&monpriv->iucv_connected, 0);
 	atomic_set(&monpriv->read_ready, 0);
@@ -495,8 +467,8 @@ mon_close(struct inode *inode, struct fi
 	return 0;
 }
 
-static ssize_t
-mon_read(struct file *filp, char __user *data, size_t count, loff_t *ppos)
+static ssize_t mon_read(struct file *filp, char __user *data,
+			size_t count, loff_t *ppos)
 {
 	struct mon_private *monpriv = filp->private_data;
 	struct mon_msg *monmsg;
@@ -563,8 +535,7 @@ out_copy:
 	return count;
 }
 
-static unsigned int
-mon_poll(struct file *filp, struct poll_table_struct *p)
+static unsigned int mon_poll(struct file *filp, struct poll_table_struct *p)
 {
 	struct mon_private *monpriv = filp->private_data;
 
@@ -593,8 +564,7 @@ static struct miscdevice mon_dev = {
 /******************************************************************************
  *                              module init/exit                              *
  *****************************************************************************/
-static int __init
-mon_init(void)
+static int __init mon_init(void)
 {
 	int rc;
 
@@ -603,22 +573,34 @@ mon_init(void)
 		return -ENODEV;
 	}
 
+	/*
+	 * Register with IUCV and connect to *MONITOR service
+	 */
+	rc = iucv_register(&monreader_iucv_handler, 1);
+	if (rc) {
+		P_ERROR("failed to register with iucv driver\n");
+		return rc;
+	}
+	P_INFO("open, registered with IUCV\n");
+
 	rc = segment_type(mon_dcss_name);
 	if (rc < 0) {
 		mon_segment_warn(rc, mon_dcss_name);
-		return rc;
+		goto out_iucv;
 	}
 	if (rc != SEG_TYPE_SC) {
 		P_ERROR("segment %s has unsupported type, should be SC\n",
 			mon_dcss_name);
-		return -EINVAL;
+		rc = -EINVAL;
+		goto out_iucv;
 	}
 
 	rc = segment_load(mon_dcss_name, SEGMENT_SHARED,
 			  &mon_dcss_start, &mon_dcss_end);
 	if (rc < 0) {
 		mon_segment_warn(rc, mon_dcss_name);
-		return -EINVAL;
+		rc = -EINVAL;
+		goto out_iucv;
 	}
 	dcss_mkname(mon_dcss_name, &user_data_connect[8]);
 
@@ -634,14 +616,16 @@ mon_init(void)
 
 out:
 	segment_unload(mon_dcss_name);
+out_iucv:
+	iucv_unregister(&monreader_iucv_handler, 1);
 	return rc;
 }
 
-static void __exit
-mon_exit(void)
+static void __exit mon_exit(void)
 {
 	segment_unload(mon_dcss_name);
 	WARN_ON(misc_deregister(&mon_dev) != 0);
+	iucv_unregister(&monreader_iucv_handler, 1);
 	return;
 }
 
-- 
1.4.2.3

