From: Ralf Baechle <ralf@linux-mips.org>
Subject: [AX.25 5/7] Fix unchecked ax25_linkfail_register uses
Date: Thu, 14 Dec 2006 23:42:11 +0100
Message-ID: <1166136135289-git-send-email-ralf@linux-mips.org>
References: <11661361331883-git-send-email-ralf@linux-mips.org>
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org,
	Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:47091 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751780AbWLNXOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Dec 2006 18:14:43 -0500
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <11661361331883-git-send-email-ralf@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ax25_linkfail_register uses kmalloc and the callers were ignoring the
error value.  Rewrite to let the caller deal with the allocation.  This
allows the use of static allocation of kmalloc use entirely.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 include/net/ax25.h     |   10 +++++++-
 net/ax25/ax25_iface.c  |   55 ++++++++-----------------------------------------
 net/netrom/af_netrom.c |    8 +++++--
 net/rose/af_rose.c     |    8 +++++--
 4 files changed, 29 insertions(+), 52 deletions(-)

Index: linux-net/include/net/ax25.h
===================================================================
--- linux-net.orig/include/net/ax25.h
+++ linux-net/include/net/ax25.h
@@ -342,8 +342,14 @@ struct ax25_protocol {
 
 extern void ax25_register_pid(struct ax25_protocol *ap);
 extern void ax25_protocol_release(unsigned int);
-extern int __must_check ax25_linkfail_register(void (*)(ax25_cb *, int));
-extern void ax25_linkfail_release(void (*)(ax25_cb *, int));
+
+struct ax25_linkfail {
+	struct hlist_node lf_node;
+	void (*func)(ax25_cb *, int);
+};
+
+extern void ax25_linkfail_register(struct ax25_linkfail *lf);
+extern void ax25_linkfail_release(struct ax25_linkfail *lf);
 extern int __must_check ax25_listen_register(ax25_address *,
 	struct net_device *);
 extern void ax25_listen_release(ax25_address *, struct net_device *);
Index: linux-net/net/ax25/ax25_iface.c
===================================================================
--- linux-net.orig/net/ax25/ax25_iface.c
+++ linux-net/net/ax25/ax25_iface.c
@@ -32,10 +32,7 @@
 static struct ax25_protocol *protocol_list;
 static DEFINE_RWLOCK(protocol_list_lock);
 
-static struct linkfail_struct {
-	struct linkfail_struct *next;
-	void (*func)(ax25_cb *, int);
-} *linkfail_list = NULL;
+static HLIST_HEAD(ax25_linkfail_list);
 static DEFINE_SPINLOCK(linkfail_lock);
 
 static struct listen_struct {
@@ -93,54 +90,19 @@ void ax25_protocol_release(unsigned int 
 
 EXPORT_SYMBOL(ax25_protocol_release);
 
-int ax25_linkfail_register(void (*func)(ax25_cb *, int))
+void ax25_linkfail_register(struct ax25_linkfail *lf)
 {
-	struct linkfail_struct *linkfail;
-
-	if ((linkfail = kmalloc(sizeof(*linkfail), GFP_ATOMIC)) == NULL)
-		return 0;
-
-	linkfail->func = func;
-
 	spin_lock_bh(&linkfail_lock);
-	linkfail->next = linkfail_list;
-	linkfail_list  = linkfail;
+	hlist_add_head(&lf->lf_node, &ax25_linkfail_list);
 	spin_unlock_bh(&linkfail_lock);
-
-	return 1;
 }
 
 EXPORT_SYMBOL(ax25_linkfail_register);
 
-void ax25_linkfail_release(void (*func)(ax25_cb *, int))
+void ax25_linkfail_release(struct ax25_linkfail *lf)
 {
-	struct linkfail_struct *s, *linkfail;
-
 	spin_lock_bh(&linkfail_lock);
-	linkfail = linkfail_list;
-	if (linkfail == NULL) {
-		spin_unlock_bh(&linkfail_lock);
-		return;
-	}
-
-	if (linkfail->func == func) {
-		linkfail_list = linkfail->next;
-		spin_unlock_bh(&linkfail_lock);
-		kfree(linkfail);
-		return;
-	}
-
-	while (linkfail != NULL && linkfail->next != NULL) {
-		if (linkfail->next->func == func) {
-			s = linkfail->next;
-			linkfail->next = linkfail->next->next;
-			spin_unlock_bh(&linkfail_lock);
-			kfree(s);
-			return;
-		}
-
-		linkfail = linkfail->next;
-	}
+	hlist_del_init(&lf->lf_node);
 	spin_unlock_bh(&linkfail_lock);
 }
 
@@ -237,11 +199,12 @@ int (*ax25_protocol_function(unsigned in
 
 void ax25_link_failed(ax25_cb *ax25, int reason)
 {
-	struct linkfail_struct *linkfail;
+	struct ax25_linkfail *lf;
+	struct hlist_node *node;
 
 	spin_lock_bh(&linkfail_lock);
-	for (linkfail = linkfail_list; linkfail != NULL; linkfail = linkfail->next)
-		(linkfail->func)(ax25, reason);
+	hlist_for_each_entry(lf, node, &ax25_linkfail_list, lf_node)
+		lf->func(ax25, reason);
 	spin_unlock_bh(&linkfail_lock);
 }
 
Index: linux-net/net/netrom/af_netrom.c
===================================================================
--- linux-net.orig/net/netrom/af_netrom.c
+++ linux-net/net/netrom/af_netrom.c
@@ -1382,6 +1382,10 @@ static struct ax25_protocol nr_pid = {
 	.func	= nr_route_frame
 };
 
+static struct ax25_linkfail nr_linkfail_notifier = {
+	.func	= nr_link_failed,
+};
+
 static int __init nr_proto_init(void)
 {
 	int i;
@@ -1430,7 +1434,7 @@ static int __init nr_proto_init(void)
 	register_netdevice_notifier(&nr_dev_notifier);
 
 	ax25_register_pid(&nr_pid);
-	ax25_linkfail_register(nr_link_failed);
+	ax25_linkfail_register(&nr_linkfail_notifier);
 
 #ifdef CONFIG_SYSCTL
 	nr_register_sysctl();
@@ -1479,7 +1483,7 @@ static void __exit nr_exit(void)
 	nr_unregister_sysctl();
 #endif
 
-	ax25_linkfail_release(nr_link_failed);
+	ax25_linkfail_release(&nr_linkfail_notifier);
 	ax25_protocol_release(AX25_P_NETROM);
 
 	unregister_netdevice_notifier(&nr_dev_notifier);
Index: linux-net/net/rose/af_rose.c
===================================================================
--- linux-net.orig/net/rose/af_rose.c
+++ linux-net/net/rose/af_rose.c
@@ -1487,6 +1487,10 @@ static struct ax25_protocol rose_pid = {
 	.func	= rose_route_frame
 };
 
+static struct ax25_linkfail rose_linkfail_notifier = {
+	.func	= rose_link_failed
+};
+
 static int __init rose_proto_init(void)
 {
 	int i;
@@ -1537,7 +1541,7 @@ static int __init rose_proto_init(void)
 	register_netdevice_notifier(&rose_dev_notifier);
 
 	ax25_register_pid(&rose_pid);
-	ax25_linkfail_register(rose_link_failed);
+	ax25_linkfail_register(&rose_linkfail_notifier);
 
 #ifdef CONFIG_SYSCTL
 	rose_register_sysctl();
@@ -1585,7 +1589,7 @@ static void __exit rose_exit(void)
 	rose_rt_free();
 
 	ax25_protocol_release(AX25_P_ROSE);
-	ax25_linkfail_release(rose_link_failed);
+	ax25_linkfail_release(&rose_linkfail_notifier);
 
 	if (ax25cmp(&rose_callsign, &null_ax25_address) != 0)
 		ax25_listen_release(&rose_callsign, NULL);
