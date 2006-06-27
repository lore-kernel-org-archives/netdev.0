From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH Round 3 1/2] Network Event Notifier Mechanism.
Date: Tue, 27 Jun 2006 15:51:00 -0500
Message-ID: <20060627205100.30723.39770.stgit@stevo-desktop>
References: <20060627205050.30723.25753.stgit@stevo-desktop>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-227-247-53.sw.biz.rr.com ([24.227.247.53]:48816 "EHLO
	linux.local") by vger.kernel.org with ESMTP id S1030348AbWF0UvB
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 16:51:01 -0400
To: davem@davemloft.net
In-Reply-To: <20060627205050.30723.25753.stgit@stevo-desktop>
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

 include/net/netevent.h |   49 +++++++++++++++++++++++++++++++++++
 net/core/netevent.c    |   68 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 117 insertions(+), 0 deletions(-)

diff --git a/include/net/netevent.h b/include/net/netevent.h
new file mode 100644
index 0000000..22214c8
--- /dev/null
+++ b/include/net/netevent.h
@@ -0,0 +1,49 @@
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
+/* 
+ * Generic route info structure.
+ *
+ * Family	  Data ptr type
+ * --------------------------------
+ * AF_INET 	- struct fib_info *
+ * AF_INET6	- struct rt6_info *
+ * AF_DECnet	- struct dn_route *
+ */
+struct netevent_route_info {
+	u16 family;
+	void *data;	
+};
+
+struct netevent_redirect {
+	struct dst_entry *old;
+	struct dst_entry *new;
+};
+
+enum netevent_notif_type {
+	NETEVENT_NEIGH_UPDATE = 1, /* arg is struct neighbour ptr */
+	NETEVENT_ROUTE_ADD,   	   /* arg is struct netevent_route_info ptr */
+	NETEVENT_ROUTE_DEL,   	   /* arg is struct netevent_route_info ptr */
+	NETEVENT_PMTU_UPDATE,	   /* arg is struct dst_entry ptr */
+	NETEVENT_REDIRECT,	   /* arg is struct netevent_redirect ptr */
+};
+
+extern int register_netevent_notifier(struct notifier_block *nb);
+extern int unregister_netevent_notifier(struct notifier_block *nb);
+extern int call_netevent_notifiers(unsigned long val, void *v);
+
+#endif
+#endif
diff --git a/net/core/netevent.c b/net/core/netevent.c
new file mode 100644
index 0000000..e995751
--- /dev/null
+++ b/net/core/netevent.c
@@ -0,0 +1,68 @@
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
+EXPORT_SYMBOL_GPL(call_netevent_notifiers);
