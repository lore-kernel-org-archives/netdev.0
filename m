From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 1/4 net-2.6.25][UNIX] Extend unix_sysctl_(un)register prototypes
Date: Fri, 30 Nov 2007 19:26:51 +0300
Message-ID: <475039CB.5010204@openvz.org>
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
Received: from sacred.ru ([62.205.161.221]:58280 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761232AbXK3Q1n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 11:27:43 -0500
In-Reply-To: <47503919.8060103@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add the struct net * argument to both of them to use in 
the future. Also make the register one return an error code. 

It is useless right now, but will make the future patches
much simpler.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index a1c805d..e0fba26 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -60,11 +60,11 @@ struct unix_sock {
 
 #ifdef CONFIG_SYSCTL
 extern int sysctl_unix_max_dgram_qlen;
-extern void unix_sysctl_register(void);
-extern void unix_sysctl_unregister(void);
+extern int unix_sysctl_register(struct net *net);
+extern void unix_sysctl_unregister(struct net *net);
 #else
-static inline void unix_sysctl_register(void) {}
-static inline void unix_sysctl_unregister(void) {}
+static inline int unix_sysctl_register(struct net *net) { return 0; }
+static inline void unix_sysctl_unregister(struct net *net) {}
 #endif
 #endif
 #endif
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 393197a..a0aa6d3 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2175,7 +2175,7 @@ static int __init af_unix_init(void)
 
 	sock_register(&unix_family_ops);
 	register_pernet_subsys(&unix_net_ops);
-	unix_sysctl_register();
+	unix_sysctl_register(&init_net);
 out:
 	return rc;
 }
@@ -2183,7 +2183,7 @@ out:
 static void __exit af_unix_exit(void)
 {
 	sock_unregister(PF_UNIX);
-	unix_sysctl_unregister();
+	unix_sysctl_unregister(&init_net);
 	proto_unregister(&unix_proto);
 	unregister_pernet_subsys(&unix_net_ops);
 }
diff --git a/net/unix/sysctl_net_unix.c b/net/unix/sysctl_net_unix.c
index eb0bd57..b2e0407 100644
--- a/net/unix/sysctl_net_unix.c
+++ b/net/unix/sysctl_net_unix.c
@@ -48,12 +48,13 @@ static ctl_table unix_root_table[] = {
 
 static struct ctl_table_header * unix_sysctl_header;
 
-void unix_sysctl_register(void)
+int unix_sysctl_register(struct net *net)
 {
 	unix_sysctl_header = register_sysctl_table(unix_root_table);
+	return unix_sysctl_header == NULL ? -ENOMEM : 0;
 }
 
-void unix_sysctl_unregister(void)
+void unix_sysctl_unregister(struct net *net)
 {
 	unregister_sysctl_table(unix_sysctl_header);
 }
-- 
1.5.3.4

