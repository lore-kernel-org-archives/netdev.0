From: frank.blaschka@de.ibm.com
Subject: [patch 01/11] [PATCH] iucv: introduce loadable iucv interface
Date: Wed, 27 Jul 2011 18:12:43 +0200
Message-ID: <20110727161338.451476486@de.ibm.com>
References: <20110727161242.018577444@de.ibm.com>
To: netdev@vger.kernel.org, linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([194.196.100.162]:60982 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754723Ab1G0QNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2011 12:13:54 -0400
Content-Disposition: inline; filename=net1117-iucv-introduce-loadable-iucv-interface.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

This patch adds a symbol to dynamically load iucv functions.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 include/net/iucv/iucv.h |   36 +++++++++++++++++++++++++++++++++++-
 net/iucv/iucv.c         |   23 +++++++++++++++++++++++
 2 files changed, 58 insertions(+), 1 deletion(-)

--- a/include/net/iucv/iucv.h
+++ b/include/net/iucv/iucv.h
@@ -120,7 +120,7 @@ struct iucv_message {
 	u32 reply_size;
 	u8  rmmsg[8];
 	u8  flags;
-};
+} __packed;
 
 /*
  * struct iucv_handler
@@ -459,3 +459,37 @@ int __iucv_message_send(struct iucv_path
 int iucv_message_send2way(struct iucv_path *path, struct iucv_message *msg,
 			  u8 flags, u32 srccls, void *buffer, size_t size,
 			  void *answer, size_t asize, size_t *residual);
+
+struct iucv_interface {
+	int (*message_receive)(struct iucv_path *path, struct iucv_message *msg,
+		u8 flags, void *buffer, size_t size, size_t *residual);
+	int (*__message_receive)(struct iucv_path *path,
+		struct iucv_message *msg, u8 flags, void *buffer, size_t size,
+		size_t *residual);
+	int (*message_reply)(struct iucv_path *path, struct iucv_message *msg,
+		u8 flags, void *reply, size_t size);
+	int (*message_reject)(struct iucv_path *path, struct iucv_message *msg);
+	int (*message_send)(struct iucv_path *path, struct iucv_message *msg,
+		u8 flags, u32 srccls, void *buffer, size_t size);
+	int (*__message_send)(struct iucv_path *path, struct iucv_message *msg,
+		u8 flags, u32 srccls, void *buffer, size_t size);
+	int (*message_send2way)(struct iucv_path *path,
+		struct iucv_message *msg, u8 flags, u32 srccls, void *buffer,
+		size_t size, void *answer, size_t asize, size_t *residual);
+	int (*message_purge)(struct iucv_path *path, struct iucv_message *msg,
+		u32 srccls);
+	int (*path_accept)(struct iucv_path *path, struct iucv_handler *handler,
+		u8 userdata[16], void *private);
+	int (*path_connect)(struct iucv_path *path,
+		struct iucv_handler *handler,
+		u8 userid[8], u8 system[8], u8 userdata[16], void *private);
+	int (*path_quiesce)(struct iucv_path *path, u8 userdata[16]);
+	int (*path_resume)(struct iucv_path *path, u8 userdata[16]);
+	int (*path_sever)(struct iucv_path *path, u8 userdata[16]);
+	int (*iucv_register)(struct iucv_handler *handler, int smp);
+	void (*iucv_unregister)(struct iucv_handler *handler, int smp);
+	struct bus_type *bus;
+	struct device *root;
+};
+
+extern struct iucv_interface iucv_if;
--- a/net/iucv/iucv.c
+++ b/net/iucv/iucv.c
@@ -1974,6 +1974,27 @@ out:
 	return rc;
 }
 
+struct iucv_interface iucv_if = {
+	.message_receive = iucv_message_receive,
+	.__message_receive = __iucv_message_receive,
+	.message_reply = iucv_message_reply,
+	.message_reject = iucv_message_reject,
+	.message_send = iucv_message_send,
+	.__message_send = __iucv_message_send,
+	.message_send2way = iucv_message_send2way,
+	.message_purge = iucv_message_purge,
+	.path_accept = iucv_path_accept,
+	.path_connect = iucv_path_connect,
+	.path_quiesce = iucv_path_quiesce,
+	.path_resume = iucv_path_resume,
+	.path_sever = iucv_path_sever,
+	.iucv_register = iucv_register,
+	.iucv_unregister = iucv_unregister,
+	.bus = NULL,
+	.root = NULL,
+};
+EXPORT_SYMBOL(iucv_if);
+
 /**
  * iucv_init
  *
@@ -2037,6 +2058,8 @@ static int __init iucv_init(void)
 	rc = bus_register(&iucv_bus);
 	if (rc)
 		goto out_reboot;
+	iucv_if.root = iucv_root;
+	iucv_if.bus = &iucv_bus;
 	return 0;
 
 out_reboot:

