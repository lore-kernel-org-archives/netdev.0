From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next-2.6 PATCH 3/3] net_dcb: add application notifiers
Date: Mon, 20 Dec 2010 12:50:24 -0800
Message-ID: <20101220205023.24232.72153.stgit@jf-dev1-dcblab>
References: <20101220205013.24232.3980.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@infradead.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30057 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933077Ab0LTUx3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Dec 2010 15:53:29 -0500
In-Reply-To: <20101220205013.24232.3980.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DCBx applications priorities can be changed dynamically. If
application stacks are expected to keep the skb priority
consistent with the dcbx priority the stack will need to
be notified when these changes occur.

This patch adds application notifiers for the stack to register
with.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 include/net/dcbevent.h |   31 +++++++++++++++++++++++++++++++
 net/dcb/Makefile       |    2 +-
 net/dcb/dcbevent.c     |   40 ++++++++++++++++++++++++++++++++++++++++
 net/dcb/dcbnl.c        |    2 ++
 4 files changed, 74 insertions(+), 1 deletions(-)
 create mode 100644 include/net/dcbevent.h
 create mode 100644 net/dcb/dcbevent.c

diff --git a/include/net/dcbevent.h b/include/net/dcbevent.h
new file mode 100644
index 0000000..bc1e7ef
--- /dev/null
+++ b/include/net/dcbevent.h
@@ -0,0 +1,31 @@
+/*
+ * Copyright (c) 2010, Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
+ * Place - Suite 330, Boston, MA 02111-1307 USA.
+ *
+ * Author: John Fastabend <john.r.fastabend@intel.com>
+ */
+
+#ifndef _DCB_EVENT_H
+#define _DCB_EVENT_H
+
+enum dcbevent_notif_type {
+	DCB_APP_EVENT = 1,
+};
+
+extern int register_dcbevent_notifier(struct notifier_block *nb);
+extern int unregister_dcbevent_notifier(struct notifier_block *nb);
+extern int call_dcbevent_notifiers(unsigned long val, void *v);
+
+#endif
diff --git a/net/dcb/Makefile b/net/dcb/Makefile
index 9930f4c..c1282c9 100644
--- a/net/dcb/Makefile
+++ b/net/dcb/Makefile
@@ -1 +1 @@
-obj-$(CONFIG_DCB) += dcbnl.o
+obj-$(CONFIG_DCB) += dcbnl.o dcbevent.o
diff --git a/net/dcb/dcbevent.c b/net/dcb/dcbevent.c
new file mode 100644
index 0000000..665a880
--- /dev/null
+++ b/net/dcb/dcbevent.c
@@ -0,0 +1,40 @@
+/*
+ * Copyright (c) 2010, Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
+ * Place - Suite 330, Boston, MA 02111-1307 USA.
+ *
+ * Author: John Fastabend <john.r.fastabend@intel.com>
+ */
+
+#include <linux/rtnetlink.h>
+#include <linux/notifier.h>
+
+static ATOMIC_NOTIFIER_HEAD(dcbevent_notif_chain);
+
+int register_dcbevent_notifier(struct notifier_block *nb)
+{
+	return atomic_notifier_chain_register(&dcbevent_notif_chain, nb);
+}
+EXPORT_SYMBOL(register_dcbevent_notifier);
+
+int unregister_dcbevent_notifier(struct notifier_block *nb)
+{
+	return atomic_notifier_chain_unregister(&dcbevent_notif_chain, nb);
+}
+EXPORT_SYMBOL(unregister_dcbevent_notifier);
+
+int call_dcbevent_notifiers(unsigned long val, void *v)
+{
+	return atomic_notifier_call_chain(&dcbevent_notif_chain, val, v);
+}
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index adc8c8d..5f1d0ee 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -23,6 +23,7 @@
 #include <net/netlink.h>
 #include <net/rtnetlink.h>
 #include <linux/dcbnl.h>
+#include <net/dcbevent.h>
 #include <linux/rtnetlink.h>
 #include <net/sock.h>
 
@@ -1458,6 +1459,7 @@ u8 dcb_setapp(struct net_device *dev, struct dcb_app *new)
 	}
 out:
 	spin_unlock(&dcb_lock);
+	call_dcbevent_notifiers(DCB_APP_EVENT, new);
 	return 0;
 }
 EXPORT_SYMBOL(dcb_setapp);

