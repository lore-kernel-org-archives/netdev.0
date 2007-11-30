From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 4/4 net-2.6.25][UNIX] Make the unix sysctl tables per-namespace
Date: Fri, 30 Nov 2007 19:34:09 +0300
Message-ID: <47503B81.1060101@openvz.org>
References: <47503919.8060103@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:32822 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754102AbXK3Qe0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 11:34:26 -0500
In-Reply-To: <47503919.8060103@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the core. 

 * add the ctl_table_header on the struct net;
 * make the unix_sysctl_register and _unregister clone the table;
 * moves calls to them into per-net init and exit callbacks;
 * move the .data pointer in the proper place.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index b0cf075..f97b2a4 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -11,6 +11,8 @@
 struct proc_dir_entry;
 struct net_device;
 struct sock;
+struct ctl_table_header;
+
 struct net {
 	atomic_t		count;		/* To decided when the network
 						 *  namespace should be freed.
@@ -41,6 +43,7 @@ struct net {
 
 	/* unix sockets */
 	int			sysctl_unix_max_dgram_qlen;
+	struct ctl_table_header	*unix_ctl;
 };
 
 #ifdef CONFIG_NET
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 73620d6..b8a2189 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2139,10 +2139,14 @@ static int unix_net_init(struct net *net)
 	int error = -ENOMEM;
 
 	net->sysctl_unix_max_dgram_qlen = 10;
+	if (unix_sysctl_register(net))
+		goto out;
 
 #ifdef CONFIG_PROC_FS
-	if (!proc_net_fops_create(net, "unix", 0, &unix_seq_fops))
+	if (!proc_net_fops_create(net, "unix", 0, &unix_seq_fops)) {
+		unix_sysctl_unregister(net);
 		goto out;
+	}
 #endif
 	error = 0;
 out:
@@ -2151,6 +2155,7 @@ out:
 
 static void unix_net_exit(struct net *net)
 {
+	unix_sysctl_unregister(net);
 	proc_net_remove(net, "unix");
 }
 
@@ -2175,7 +2180,6 @@ static int __init af_unix_init(void)
 
 	sock_register(&unix_family_ops);
 	register_pernet_subsys(&unix_net_ops);
-	unix_sysctl_register(&init_net);
 out:
 	return rc;
 }
@@ -2183,7 +2187,6 @@ out:
 static void __exit af_unix_exit(void)
 {
 	sock_unregister(PF_UNIX);
-	unix_sysctl_unregister(&init_net);
 	proto_unregister(&unix_proto);
 	unregister_pernet_subsys(&unix_net_ops);
 }
diff --git a/net/unix/sysctl_net_unix.c b/net/unix/sysctl_net_unix.c
index 43dd356..1c57f8f 100644
--- a/net/unix/sysctl_net_unix.c
+++ b/net/unix/sysctl_net_unix.c
@@ -32,16 +32,33 @@ static struct ctl_path unix_path[] = {
 	{ },
 };
 
-static struct ctl_table_header * unix_sysctl_header;
-
 int unix_sysctl_register(struct net *net)
 {
-	unix_sysctl_header = register_sysctl_paths(unix_path, unix_table);
-	return unix_sysctl_header == NULL ? -ENOMEM : 0;
+	struct ctl_table *table;
+
+	table = kmemdup(unix_table, sizeof(unix_table), GFP_KERNEL);
+	if (table == NULL)
+		goto err_alloc;
+
+	table[0].data = &net->sysctl_unix_max_dgram_qlen;
+	net->unix_ctl = register_net_sysctl_table(net, unix_path, table);
+	if (net->unix_ctl != NULL)
+		goto err_reg;
+
+	return 0;
+
+err_reg:
+	kfree(table);
+err_alloc:
+	return -ENOMEM;
 }
 
 void unix_sysctl_unregister(struct net *net)
 {
-	unregister_sysctl_table(unix_sysctl_header);
+	struct ctl_table *table;
+
+	table = net->unix_ctl->ctl_table_arg;
+	unregister_sysctl_table(net->unix_ctl);
+	kfree(table);
 }
 
-- 
1.5.3.4

