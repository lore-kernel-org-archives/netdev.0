From: James Chapman <jchapman@katalix.com>
Subject: [RFC PATCH 6/8] l2tp: export additional genetlink APIs
Date: Sun, 22 Feb 2009 17:52:20 GMT
Message-ID: <200902221752.n1MHqKa4006549@bert.katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:48308 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751689AbZBVRqj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Feb 2009 12:46:39 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.katalix.com (Postfix) with ESMTP id 20DF1A62087
	for <netdev@vger.kernel.org>; Sun, 22 Feb 2009 17:52:34 +0000 (GMT)
Received: from mail.katalix.com ([127.0.0.1])
	by localhost (mail.katalix.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id WrZEthdeE0+C for <netdev@vger.kernel.org>;
	Sun, 22 Feb 2009 17:52:28 +0000 (GMT)
Received: from bert.katalix.com (localhost.localdomain [127.0.0.1])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.katalix.com (Postfix) with ESMTPS id 7F991A620A2
	for <netdev@vger.kernel.org>; Sun, 22 Feb 2009 17:52:21 +0000 (GMT)
Received: (from james@localhost)
	by bert.katalix.com (8.14.2/8.14.2/Submit) id n1MHqKa4006549
	for netdev@vger.kernel.org; Sun, 22 Feb 2009 17:52:20 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export genl_lock API for use by modules.

This lets kernel modules which use genl netlink APIs serialize netlink
processing.

Signed-off-by: James Chapman <jchapman@katalix.com>

Index: net-next-2.6-l2tpv3-2/include/linux/genetlink.h
===================================================================
--- net-next-2.6-l2tpv3-2.orig/include/linux/genetlink.h
+++ net-next-2.6-l2tpv3-2/include/linux/genetlink.h
@@ -80,4 +80,12 @@ enum {
 
 #define CTRL_ATTR_MCAST_GRP_MAX (__CTRL_ATTR_MCAST_GRP_MAX - 1)
 
+#ifdef __KERNEL__
+
+/* All generic netlink requests are serialized by a global lock.  */
+extern void genl_lock(void);
+extern void genl_unlock(void);
+
+#endif /* __KERNEL__ */
+
 #endif	/* __LINUX_GENERIC_NETLINK_H */
Index: net-next-2.6-l2tpv3-2/net/netlink/genetlink.c
===================================================================
--- net-next-2.6-l2tpv3-2.orig/net/netlink/genetlink.c
+++ net-next-2.6-l2tpv3-2/net/netlink/genetlink.c
@@ -22,15 +22,17 @@ struct sock *genl_sock = NULL;
 
 static DEFINE_MUTEX(genl_mutex); /* serialization of message processing */
 
-static inline void genl_lock(void)
+void genl_lock(void)
 {
 	mutex_lock(&genl_mutex);
 }
+EXPORT_SYMBOL(genl_lock);
 
-static inline void genl_unlock(void)
+void genl_unlock(void)
 {
 	mutex_unlock(&genl_mutex);
 }
+EXPORT_SYMBOL(genl_unlock);
 
 #define GENL_FAM_TAB_SIZE	16
 #define GENL_FAM_TAB_MASK	(GENL_FAM_TAB_SIZE - 1)
