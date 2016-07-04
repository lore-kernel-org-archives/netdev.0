From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 07/11] batman-adv: add generic netlink family for batman-adv
Date: Mon,  4 Jul 2016 15:02:55 +0200
Message-ID: <1467637379-6089-8-git-send-email-sw@simonwunderlich.de>
References: <1467637379-6089-1-git-send-email-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Matthias Schiffer <mschiffer@universe-factory.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sven Eckelmann <sven.eckelmann@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:58228 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753832AbcGDNDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 09:03:13 -0400
In-Reply-To: <1467637379-6089-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthias Schiffer <mschiffer@universe-factory.net>

debugfs is currently severely broken virtually everywhere in the kernel
where files are dynamically added and removed (see
http://lkml.iu.edu/hypermail/linux/kernel/1506.1/02196.html for some
details). In addition to that, debugfs is not namespace-aware.

Instead of adding new debugfs entries, the whole infrastructure should be
moved to netlink. This will fix the long standing problem of large buffers
for debug tables and hard to parse text files.

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
Signed-off-by: Andrew Lunn <andrew@lunn.ch>
[sven.eckelmann@open-mesh.com: Strip down patch to only add genl family,
add missing kerneldoc]
Signed-off-by: Sven Eckelmann <sven.eckelmann@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 MAINTAINERS                     |  1 +
 include/uapi/linux/batman_adv.h | 53 ++++++++++++++++++++++++++++++++++++++
 net/batman-adv/Makefile         |  1 +
 net/batman-adv/main.c           |  3 +++
 net/batman-adv/netlink.c        | 57 +++++++++++++++++++++++++++++++++++++++++
 net/batman-adv/netlink.h        | 26 +++++++++++++++++++
 6 files changed, 141 insertions(+)
 create mode 100644 include/uapi/linux/batman_adv.h
 create mode 100644 net/batman-adv/netlink.c
 create mode 100644 net/batman-adv/netlink.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 0e26025..e25091f 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2291,6 +2291,7 @@ S:	Maintained
 F:	Documentation/ABI/testing/sysfs-class-net-batman-adv
 F:	Documentation/ABI/testing/sysfs-class-net-mesh
 F:	Documentation/networking/batman-adv.txt
+F:	include/uapi/linux/batman_adv.h
 F:	net/batman-adv/
 
 BAYCOM/HDLCDRV DRIVERS FOR AX.25
diff --git a/include/uapi/linux/batman_adv.h b/include/uapi/linux/batman_adv.h
new file mode 100644
index 0000000..79f7972
--- /dev/null
+++ b/include/uapi/linux/batman_adv.h
@@ -0,0 +1,53 @@
+/* Copyright (C) 2016 B.A.T.M.A.N. contributors:
+ *
+ * Matthias Schiffer
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#ifndef _UAPI_LINUX_BATMAN_ADV_H_
+#define _UAPI_LINUX_BATMAN_ADV_H_
+
+#define BATADV_NL_NAME "batadv"
+
+/**
+ * enum batadv_nl_attrs - batman-adv netlink attributes
+ *
+ * @BATADV_ATTR_UNSPEC: unspecified attribute to catch errors
+ * @__BATADV_ATTR_AFTER_LAST: internal use
+ * @NUM_BATADV_ATTR: total number of batadv_nl_attrs available
+ * @BATADV_ATTR_MAX: highest attribute number currently defined
+ */
+enum batadv_nl_attrs {
+	BATADV_ATTR_UNSPEC,
+	/* add attributes above here, update the policy in netlink.c */
+	__BATADV_ATTR_AFTER_LAST,
+	NUM_BATADV_ATTR = __BATADV_ATTR_AFTER_LAST,
+	BATADV_ATTR_MAX = __BATADV_ATTR_AFTER_LAST - 1
+};
+
+/**
+ * enum batadv_nl_commands - supported batman-adv netlink commands
+ *
+ * @BATADV_CMD_UNSPEC: unspecified command to catch errors
+ * @__BATADV_CMD_AFTER_LAST: internal use
+ * @BATADV_CMD_MAX: highest used command number
+ */
+enum batadv_nl_commands {
+	BATADV_CMD_UNSPEC,
+	/* add new commands above here */
+	__BATADV_CMD_AFTER_LAST,
+	BATADV_CMD_MAX = __BATADV_CMD_AFTER_LAST - 1
+};
+
+#endif /* _UAPI_LINUX_BATMAN_ADV_H_ */
diff --git a/net/batman-adv/Makefile b/net/batman-adv/Makefile
index a55f4ec..7da5901 100644
--- a/net/batman-adv/Makefile
+++ b/net/batman-adv/Makefile
@@ -35,6 +35,7 @@ batman-adv-y += icmp_socket.o
 batman-adv-$(CONFIG_BATMAN_ADV_DEBUG) += log.o
 batman-adv-y += main.o
 batman-adv-$(CONFIG_BATMAN_ADV_MCAST) += multicast.o
+batman-adv-y += netlink.o
 batman-adv-$(CONFIG_BATMAN_ADV_NC) += network-coding.o
 batman-adv-y += originator.o
 batman-adv-y += routing.o
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index eab9d1b..275604b 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -57,6 +57,7 @@
 #include "icmp_socket.h"
 #include "log.h"
 #include "multicast.h"
+#include "netlink.h"
 #include "network-coding.h"
 #include "originator.h"
 #include "packet.h"
@@ -99,6 +100,7 @@ static int __init batadv_init(void)
 
 	register_netdevice_notifier(&batadv_hard_if_notifier);
 	rtnl_link_register(&batadv_link_ops);
+	batadv_netlink_register();
 
 	pr_info("B.A.T.M.A.N. advanced %s (compatibility version %i) loaded\n",
 		BATADV_SOURCE_VERSION, BATADV_COMPAT_VERSION);
@@ -109,6 +111,7 @@ static int __init batadv_init(void)
 static void __exit batadv_exit(void)
 {
 	batadv_debugfs_destroy();
+	batadv_netlink_unregister();
 	rtnl_link_unregister(&batadv_link_ops);
 	unregister_netdevice_notifier(&batadv_hard_if_notifier);
 	batadv_hardif_remove_interfaces();
diff --git a/net/batman-adv/netlink.c b/net/batman-adv/netlink.c
new file mode 100644
index 0000000..9e4c865
--- /dev/null
+++ b/net/batman-adv/netlink.c
@@ -0,0 +1,57 @@
+/* Copyright (C) 2016 B.A.T.M.A.N. contributors:
+ *
+ * Matthias Schiffer
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include "netlink.h"
+#include "main.h"
+
+#include <linux/genetlink.h>
+#include <linux/init.h>
+#include <linux/printk.h>
+#include <net/genetlink.h>
+#include <uapi/linux/batman_adv.h>
+
+static struct genl_family batadv_netlink_family = {
+	.id = GENL_ID_GENERATE,
+	.hdrsize = 0,
+	.name = BATADV_NL_NAME,
+	.version = 1,
+	.maxattr = BATADV_ATTR_MAX,
+};
+
+static struct genl_ops batadv_netlink_ops[] = {
+};
+
+/**
+ * batadv_netlink_register - register batadv genl netlink family
+ */
+void __init batadv_netlink_register(void)
+{
+	int ret;
+
+	ret = genl_register_family_with_ops(&batadv_netlink_family,
+					    batadv_netlink_ops);
+	if (ret)
+		pr_warn("unable to register netlink family");
+}
+
+/**
+ * batadv_netlink_unregister - unregister batadv genl netlink family
+ */
+void batadv_netlink_unregister(void)
+{
+	genl_unregister_family(&batadv_netlink_family);
+}
diff --git a/net/batman-adv/netlink.h b/net/batman-adv/netlink.h
new file mode 100644
index 0000000..39044cc
--- /dev/null
+++ b/net/batman-adv/netlink.h
@@ -0,0 +1,26 @@
+/* Copyright (C) 2016 B.A.T.M.A.N. contributors:
+ *
+ * Matthias Schiffer
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
+ */
+
+#ifndef _NET_BATMAN_ADV_NETLINK_H_
+#define _NET_BATMAN_ADV_NETLINK_H_
+
+#include "main.h"
+
+void batadv_netlink_register(void);
+void batadv_netlink_unregister(void);
+
+#endif /* _NET_BATMAN_ADV_NETLINK_H_ */
-- 
2.8.1
