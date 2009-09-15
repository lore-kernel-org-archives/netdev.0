From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 5/7] ieee802154: merge nl802154 and wpan-class in single module
Date: Wed, 16 Sep 2009 02:13:03 +0400
Message-ID: <1253052785-26190-6-git-send-email-dbaryshkov@gmail.com>
References: <1253052785-26190-1-git-send-email-dbaryshkov@gmail.com>
 <1253052785-26190-2-git-send-email-dbaryshkov@gmail.com>
 <1253052785-26190-3-git-send-email-dbaryshkov@gmail.com>
 <1253052785-26190-4-git-send-email-dbaryshkov@gmail.com>
 <1253052785-26190-5-git-send-email-dbaryshkov@gmail.com>
Cc: linux-zigbee-devel@lists.sourceforge.net,
	Sergey Lapin <slapin@ossfans.org>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f206.google.com ([209.85.219.206]:63125 "EHLO
	mail-ew0-f206.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758713AbZIOWOC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 18:14:02 -0400
Received: by mail-ew0-f206.google.com with SMTP id 2so922640ewy.17
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2009 15:14:05 -0700 (PDT)
In-Reply-To: <1253052785-26190-5-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no real need to have ieee802154 interfaces separate
into several small modules, as neither of them has it's own use.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 net/ieee802154/Makefile     |    4 ++--
 net/ieee802154/netlink.c    |    9 ++-------
 net/ieee802154/wpan-class.c |   23 ++++++++++++++++++++---
 3 files changed, 24 insertions(+), 12 deletions(-)

diff --git a/net/ieee802154/Makefile b/net/ieee802154/Makefile
index 4068a9f..42b1f0d 100644
--- a/net/ieee802154/Makefile
+++ b/net/ieee802154/Makefile
@@ -1,5 +1,5 @@
-obj-$(CONFIG_IEEE802154) +=	nl802154.o af_802154.o wpan-class.o
-nl802154-y		:= netlink.o nl_policy.o
+obj-$(CONFIG_IEEE802154) +=	ieee802154.o af_802154.o
+ieee802154-y		:= netlink.o nl_policy.o wpan-class.o
 af_802154-y		:= af_ieee802154.o raw.o dgram.o
 
 ccflags-y += -Wall -DDEBUG
diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
index ca767bd..0fadd6b 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -643,7 +643,7 @@ static struct genl_ops ieee802154_coordinator_ops[] = {
 							ieee802154_dump_iface),
 };
 
-static int __init ieee802154_nl_init(void)
+int __init ieee802154_nl_init(void)
 {
 	int rc;
 	int i;
@@ -676,14 +676,9 @@ fail:
 	genl_unregister_family(&ieee802154_coordinator_family);
 	return rc;
 }
-module_init(ieee802154_nl_init);
 
-static void __exit ieee802154_nl_exit(void)
+void __exit ieee802154_nl_exit(void)
 {
 	genl_unregister_family(&ieee802154_coordinator_family);
 }
-module_exit(ieee802154_nl_exit);
-
-MODULE_LICENSE("GPL v2");
-MODULE_DESCRIPTION("ieee 802.15.4 configuration interface");
 
diff --git a/net/ieee802154/wpan-class.c b/net/ieee802154/wpan-class.c
index 0cec138..f8479c6 100644
--- a/net/ieee802154/wpan-class.c
+++ b/net/ieee802154/wpan-class.c
@@ -22,6 +22,8 @@
 
 #include <net/wpan-phy.h>
 
+#include "ieee802154.h"
+
 #define MASTER_SHOW_COMPLEX(name, format_string, args...)		\
 static ssize_t name ## _show(struct device *dev,			\
 			    struct device_attribute *attr, char *buf)	\
@@ -169,16 +171,31 @@ EXPORT_SYMBOL(wpan_phy_free);
 
 static int __init wpan_phy_class_init(void)
 {
-	return class_register(&wpan_phy_class);
+	int rc;
+	rc = class_register(&wpan_phy_class);
+	if (rc)
+		goto err;
+
+	rc = ieee802154_nl_init();
+	if (rc)
+		goto err_nl;
+
+	return 0;
+err_nl:
+	class_unregister(&wpan_phy_class);
+err:
+	return rc;
 }
-subsys_initcall(wpan_phy_class_init);
+module_init(wpan_phy_class_init);
 
 static void __exit wpan_phy_class_exit(void)
 {
+	ieee802154_nl_exit();
 	class_unregister(&wpan_phy_class);
 }
 module_exit(wpan_phy_class_exit);
 
-MODULE_DESCRIPTION("IEEE 802.15.4 device class");
 MODULE_LICENSE("GPL v2");
+MODULE_DESCRIPTION("IEEE 802.15.4 configuration interface");
+MODULE_AUTHOR("Dmitry Eremin-Solenikov");
 
-- 
1.6.3.3

