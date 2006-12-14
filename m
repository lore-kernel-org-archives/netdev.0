From: Ralf Baechle <ralf@linux-mips.org>
Subject: [AX.25 2/7] Fix unchecked ax25_protocol_register uses.
Date: Thu, 14 Dec 2006 23:42:08 +0100
Message-ID: <11661361342093-git-send-email-ralf@linux-mips.org>
References: <11661361331883-git-send-email-ralf@linux-mips.org>
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org,
	Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:47091 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751824AbWLNXOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Dec 2006 18:14:47 -0500
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <11661361331883-git-send-email-ralf@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace ax25_protocol_register by ax25_register_pid which assumes the
caller has done the memory allocation.  This allows replacing the
kmalloc allocations entirely by static allocations.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 include/net/ax25.h     |    9 ++++++++-
 net/ax25/ax25_iface.c  |   41 ++++++++++++-----------------------------
 net/netrom/af_netrom.c |    7 ++++++-
 net/rose/af_rose.c     |    7 ++++++-
 4 files changed, 32 insertions(+), 32 deletions(-)

Index: linux-net/include/net/ax25.h
===================================================================
--- linux-net.orig/include/net/ax25.h
+++ linux-net/include/net/ax25.h
@@ -333,7 +333,14 @@ extern void ax25_ds_t3timer_expiry(ax25_
 extern void ax25_ds_idletimer_expiry(ax25_cb *);
 
 /* ax25_iface.c */
-extern int __must_check ax25_protocol_register(unsigned int, int (*)(struct sk_buff *, ax25_cb *));
+
+struct ax25_protocol {
+	struct ax25_protocol *next;
+	unsigned int pid;
+	int (*func)(struct sk_buff *, ax25_cb *);
+};
+
+extern void ax25_register_pid(struct ax25_protocol *ap);
 extern void ax25_protocol_release(unsigned int);
 extern int __must_check ax25_linkfail_register(void (*)(ax25_cb *, int));
 extern void ax25_linkfail_release(void (*)(ax25_cb *, int));
Index: linux-net/net/ax25/ax25_iface.c
===================================================================
--- linux-net.orig/net/ax25/ax25_iface.c
+++ linux-net/net/ax25/ax25_iface.c
@@ -29,11 +29,7 @@
 #include <linux/mm.h>
 #include <linux/interrupt.h>
 
-static struct protocol_struct {
-	struct protocol_struct *next;
-	unsigned int pid;
-	int (*func)(struct sk_buff *, ax25_cb *);
-} *protocol_list = NULL;
+static struct ax25_protocol *protocol_list;
 static DEFINE_RWLOCK(protocol_list_lock);
 
 static struct linkfail_struct {
@@ -49,36 +45,23 @@ static struct listen_struct {
 } *listen_list = NULL;
 static DEFINE_SPINLOCK(listen_lock);
 
-int ax25_protocol_register(unsigned int pid,
-	int (*func)(struct sk_buff *, ax25_cb *))
+/*
+ * Do not register the internal protocols AX25_P_TEXT, AX25_P_SEGMENT,
+ * AX25_P_IP or AX25_P_ARP ...
+ */
+void ax25_register_pid(struct ax25_protocol *ap)
 {
-	struct protocol_struct *protocol;
-
-	if (pid == AX25_P_TEXT || pid == AX25_P_SEGMENT)
-		return 0;
-#ifdef CONFIG_INET
-	if (pid == AX25_P_IP || pid == AX25_P_ARP)
-		return 0;
-#endif
-	if ((protocol = kmalloc(sizeof(*protocol), GFP_ATOMIC)) == NULL)
-		return 0;
-
-	protocol->pid  = pid;
-	protocol->func = func;
-
 	write_lock_bh(&protocol_list_lock);
-	protocol->next = protocol_list;
-	protocol_list  = protocol;
+	ap->next = protocol_list;
+	protocol_list = ap;
 	write_unlock_bh(&protocol_list_lock);
-
-	return 1;
 }
 
-EXPORT_SYMBOL(ax25_protocol_register);
+EXPORT_SYMBOL_GPL(ax25_register_pid);
 
 void ax25_protocol_release(unsigned int pid)
 {
-	struct protocol_struct *s, *protocol;
+	struct ax25_protocol *s, *protocol;
 
 	write_lock_bh(&protocol_list_lock);
 	protocol = protocol_list;
@@ -223,7 +206,7 @@ EXPORT_SYMBOL(ax25_listen_release);
 int (*ax25_protocol_function(unsigned int pid))(struct sk_buff *, ax25_cb *)
 {
 	int (*res)(struct sk_buff *, ax25_cb *) = NULL;
-	struct protocol_struct *protocol;
+	struct ax25_protocol *protocol;
 
 	read_lock(&protocol_list_lock);
 	for (protocol = protocol_list; protocol != NULL; protocol = protocol->next)
@@ -263,7 +246,7 @@ void ax25_link_failed(ax25_cb *ax25, int
 
 int ax25_protocol_is_registered(unsigned int pid)
 {
-	struct protocol_struct *protocol;
+	struct ax25_protocol *protocol;
 	int res = 0;
 
 	read_lock_bh(&protocol_list_lock);
Index: linux-net/net/netrom/af_netrom.c
===================================================================
--- linux-net.orig/net/netrom/af_netrom.c
+++ linux-net/net/netrom/af_netrom.c
@@ -1377,6 +1377,11 @@ static struct notifier_block nr_dev_noti
 
 static struct net_device **dev_nr;
 
+static struct ax25_protocol nr_pid = {
+	.pid	= AX25_P_NETROM,
+	.func	= nr_route_frame
+};
+
 static int __init nr_proto_init(void)
 {
 	int i;
@@ -1424,7 +1429,7 @@ static int __init nr_proto_init(void)
 		
 	register_netdevice_notifier(&nr_dev_notifier);
 
-	ax25_protocol_register(AX25_P_NETROM, nr_route_frame);
+	ax25_register_pid(&nr_pid);
 	ax25_linkfail_register(nr_link_failed);
 
 #ifdef CONFIG_SYSCTL
Index: linux-net/net/rose/af_rose.c
===================================================================
--- linux-net.orig/net/rose/af_rose.c
+++ linux-net/net/rose/af_rose.c
@@ -1481,6 +1481,11 @@ static struct notifier_block rose_dev_no
 
 static struct net_device **dev_rose;
 
+static struct ax25_protocol rose_pid = {
+	.pid	= AX25_P_ROSE,
+	.func	= rose_route_frame
+};
+
 static int __init rose_proto_init(void)
 {
 	int i;
@@ -1530,7 +1535,7 @@ static int __init rose_proto_init(void)
 	sock_register(&rose_family_ops);
 	register_netdevice_notifier(&rose_dev_notifier);
 
-	ax25_protocol_register(AX25_P_ROSE, rose_route_frame);
+	ax25_register_pid(&rose_pid);
 	ax25_linkfail_register(rose_link_failed);
 
 #ifdef CONFIG_SYSCTL
