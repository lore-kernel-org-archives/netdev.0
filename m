From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 08/12] netlink: Export genl_lock() API for use by modules
Date: Thu, 18 Mar 2010 10:22:10 +0000
Message-ID: <20100318102209.14576.61503.stgit@bert.katalix.com>
References: <20100318102127.14576.98388.stgit@bert.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:58060 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752363Ab0CRKWQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Mar 2010 06:22:16 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.katalix.com (Postfix) with ESMTP id A0A50A620B5
	for <netdev@vger.kernel.org>; Thu, 18 Mar 2010 10:22:15 +0000 (GMT)
Received: from mail.katalix.com ([127.0.0.1])
	by localhost (mail.katalix.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id BnYODlCGbwSm for <netdev@vger.kernel.org>;
	Thu, 18 Mar 2010 10:22:10 +0000 (GMT)
Received: from bert.katalix.com (localhost.localdomain [127.0.0.1])
	by mail.katalix.com (Postfix) with ESMTP id 40358A620A4
	for <netdev@vger.kernel.org>; Thu, 18 Mar 2010 10:22:10 +0000 (GMT)
In-Reply-To: <20100318102127.14576.98388.stgit@bert.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This lets kernel modules which use genl netlink APIs serialize netlink
processing.

Signed-off-by: James Chapman <jchapman@katalix.com>
---
 include/linux/genetlink.h |    8 ++++++++
 net/netlink/genetlink.c   |    6 ++++--
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/include/linux/genetlink.h b/include/linux/genetlink.h
index b834ef6..61549b2 100644
--- a/include/linux/genetlink.h
+++ b/include/linux/genetlink.h
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
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index a4b6e14..a28fda7 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -20,15 +20,17 @@
 
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

