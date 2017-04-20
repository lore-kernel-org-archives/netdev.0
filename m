From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 03/16] xfrm: Move device notifications to a sepatate file
Date: Thu, 20 Apr 2017 10:55:02 +0200
Message-ID: <1492678515-14347-4-git-send-email-steffen.klassert@secunet.com>
References: <1492678515-14347-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:51586 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S943390AbdDTI4r (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 04:56:47 -0400
In-Reply-To: <1492678515-14347-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is needed for the upcomming IPsec device offloading.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h     |  1 +
 net/xfrm/Makefile      |  2 +-
 net/xfrm/xfrm_device.c | 43 +++++++++++++++++++++++++++++++++++++++++++
 net/xfrm/xfrm_policy.c | 17 +----------------
 4 files changed, 46 insertions(+), 17 deletions(-)
 create mode 100644 net/xfrm/xfrm_device.c

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 159342f..ac984da 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1443,6 +1443,7 @@ struct xfrm6_tunnel {
 void xfrm_init(void);
 void xfrm4_init(void);
 int xfrm_state_init(struct net *net);
+void xfrm_dev_init(void);
 void xfrm_state_fini(struct net *net);
 void xfrm4_state_init(void);
 void xfrm4_protocol_init(void);
diff --git a/net/xfrm/Makefile b/net/xfrm/Makefile
index c0e9619..55b2ac3 100644
--- a/net/xfrm/Makefile
+++ b/net/xfrm/Makefile
@@ -4,7 +4,7 @@
 
 obj-$(CONFIG_XFRM) := xfrm_policy.o xfrm_state.o xfrm_hash.o \
 		      xfrm_input.o xfrm_output.o \
-		      xfrm_sysctl.o xfrm_replay.o
+		      xfrm_sysctl.o xfrm_replay.o xfrm_device.o
 obj-$(CONFIG_XFRM_STATISTICS) += xfrm_proc.o
 obj-$(CONFIG_XFRM_ALGO) += xfrm_algo.o
 obj-$(CONFIG_XFRM_USER) += xfrm_user.o
diff --git a/net/xfrm/xfrm_device.c b/net/xfrm/xfrm_device.c
new file mode 100644
index 0000000..34a260a
--- /dev/null
+++ b/net/xfrm/xfrm_device.c
@@ -0,0 +1,43 @@
+/*
+ * xfrm_device.c - IPsec device offloading code.
+ *
+ * Copyright (c) 2015 secunet Security Networks AG
+ *
+ * Author:
+ * Steffen Klassert <steffen.klassert@secunet.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/errno.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <net/dst.h>
+#include <net/xfrm.h>
+#include <linux/notifier.h>
+
+static int xfrm_dev_event(struct notifier_block *this, unsigned long event, void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+
+	switch (event) {
+	case NETDEV_DOWN:
+		xfrm_garbage_collect(dev_net(dev));
+	}
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block xfrm_dev_notifier = {
+	.notifier_call	= xfrm_dev_event,
+};
+
+void __net_init xfrm_dev_init(void)
+{
+	register_netdevice_notifier(&xfrm_dev_notifier);
+}
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 236cbbc..7befca2 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2929,21 +2929,6 @@ void xfrm_policy_unregister_afinfo(const struct xfrm_policy_afinfo *afinfo)
 }
 EXPORT_SYMBOL(xfrm_policy_unregister_afinfo);
 
-static int xfrm_dev_event(struct notifier_block *this, unsigned long event, void *ptr)
-{
-	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
-
-	switch (event) {
-	case NETDEV_DOWN:
-		xfrm_garbage_collect(dev_net(dev));
-	}
-	return NOTIFY_DONE;
-}
-
-static struct notifier_block xfrm_dev_notifier = {
-	.notifier_call	= xfrm_dev_event,
-};
-
 #ifdef CONFIG_XFRM_STATISTICS
 static int __net_init xfrm_statistics_init(struct net *net)
 {
@@ -3020,7 +3005,7 @@ static int __net_init xfrm_policy_init(struct net *net)
 	INIT_WORK(&net->xfrm.policy_hash_work, xfrm_hash_resize);
 	INIT_WORK(&net->xfrm.policy_hthresh.work, xfrm_hash_rebuild);
 	if (net_eq(net, &init_net))
-		register_netdevice_notifier(&xfrm_dev_notifier);
+		xfrm_dev_init();
 	return 0;
 
 out_bydst:
-- 
2.7.4
