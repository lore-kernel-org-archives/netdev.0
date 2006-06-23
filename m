From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH REPOST 1/2] Network Event Notifier Mechanism.
Date: Fri, 23 Jun 2006 15:19:28 -0500
Message-ID: <20060623201928.32482.69191.stgit@stevo-desktop>
References: <20060623201918.32482.89765.stgit@stevo-desktop>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-227-247-53.sw.biz.rr.com ([24.227.247.53]:52901 "EHLO
	linux.local") by vger.kernel.org with ESMTP id S1752024AbWFWUT3
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 16:19:29 -0400
To: davem@davemloft.net
In-Reply-To: <20060623201918.32482.89765.stgit@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch uses notifier blocks to implement a network event
notifier mechanism.

Clients register their callback function by calling
register_netevent_notifier() like this:

static struct notifier_block nb = {
        .notifier_call = my_callback_func
};

...

register_netevent_notifier(&nb);
---

 include/net/netevent.h |   41 +++++++++++++++++++++++++++++
 net/core/netevent.c    |   67 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 108 insertions(+), 0 deletions(-)

diff --git a/include/net/netevent.h b/include/net/netevent.h
new file mode 100644
index 0000000..9ceab27
--- /dev/null
+++ b/include/net/netevent.h
@@ -0,0 +1,41 @@
+#ifndef _NET_EVENT_H
+#define _NET_EVENT_H
+
+/*
+ *	Generic netevent notifiers
+ *
+ *	Authors:
+ *      Tom Tucker              <tom@opengridcomputing.com>
+ *
+ * 	Changes:
+ */
+
+#ifdef __KERNEL__
+
+#include <net/dst.h>
+
+struct netevent_redirect {
+	struct dst_entry *old;
+	struct dst_entry *new;
+};
+
+struct netevent_route_change {
+        int event;
+        struct fib_info *fib_info;
+};
+
+enum netevent_notif_type {
+	NETEVENT_NEIGH_UPDATE = 1, /* arg is * struct neighbour */
+	NETEVENT_ROUTE_UPDATE,	   /* arg is * netevent_route_change */
+	NETEVENT_PMTU_UPDATE,
+	NETEVENT_REDIRECT,	   /* arg is * struct netevent_redirect */
+};
+
+extern int register_netevent_notifier(struct notifier_block *nb);
+extern int unregister_netevent_notifier(struct notifier_block *nb);
+extern int call_netevent_notifiers(unsigned long val, void *v);
+
+#endif
+#endif
+
+
diff --git a/net/core/netevent.c b/net/core/netevent.c
new file mode 100644
index 0000000..8f3e0a6
--- /dev/null
+++ b/net/core/netevent.c
@@ -0,0 +1,67 @@
+/*
+ *	Network event notifiers
+ *
+ *	Authors:
+ *      Tom Tucker             <tom@opengridcomputing.com>
+ *
+ *	This program is free software; you can redistribute it and/or
+ *      modify it under the terms of the GNU General Public License
+ *      as published by the Free Software Foundation; either version
+ *      2 of the License, or (at your option) any later version.
+ *
+ *	Fixes:
+ */
+
+#include <linux/rtnetlink.h>
+#include <linux/notifier.h>
+
+static ATOMIC_NOTIFIER_HEAD(netevent_notif_chain);
+
+/**
+ *	register_netevent_notifier - register a netevent notifier block
+ *	@nb: notifier
+ *
+ *	Register a notifier to be called when a netevent occurs.
+ *	The notifier passed is linked into the kernel structures and must
+ *	not be reused until it has been unregistered. A negative errno code
+ *	is returned on a failure.
+ */
+int register_netevent_notifier(struct notifier_block *nb)
+{
+	int err;
+
+	err = atomic_notifier_chain_register(&netevent_notif_chain, nb);
+	return err;
+}
+
+/**
+ *	netevent_unregister_notifier - unregister a netevent notifier block
+ *	@nb: notifier
+ *
+ *	Unregister a notifier previously registered by
+ *	register_neigh_notifier(). The notifier is unlinked into the
+ *	kernel structures and may then be reused. A negative errno code
+ *	is returned on a failure.
+ */
+
+int unregister_netevent_notifier(struct notifier_block *nb)
+{
+	return atomic_notifier_chain_unregister(&netevent_notif_chain, nb);
+}
+
+/**
+ *	call_netevent_notifiers - call all netevent notifier blocks
+ *      @val: value passed unmodified to notifier function
+ *      @v:   pointer passed unmodified to notifier function
+ *
+ *	Call all neighbour notifier blocks.  Parameters and return value
+ *	are as for notifier_call_chain().
+ */
+
+int call_netevent_notifiers(unsigned long val, void *v)
+{
+	return atomic_notifier_call_chain(&netevent_notif_chain, val, v);
+}
+
+EXPORT_SYMBOL_GPL(register_netevent_notifier);
+EXPORT_SYMBOL_GPL(unregister_netevent_notifier);
