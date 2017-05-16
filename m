From: linzhang <xiaolou4617@gmail.com>
Subject: [PATCH net v2] net: x25: fix one potential use-after-free issue
Date: Tue, 16 May 2017 11:52:54 +0800
Message-ID: <1494906774-16352-1-git-send-email-xiaolou4617@gmail.com>
Cc: nhorman@tuxdriver.com, linux-x25@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linzhang <xiaolou4617@gmail.com>
To: andrew.hendry@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36617 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750713AbdEPDxH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 23:53:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function x25_init is not properly unregister related resources
on error handler.It is will result in kernel oops if x25_init init
failed, so add properly unregister call on error handler.

Also, i adjust the coding style and make x25_register_sysctl properly
return failure.

Signed-off-by: linzhang <xiaolou4617@gmail.com>
---
 include/net/x25.h        |  4 ++--
 net/x25/af_x25.c         | 34 +++++++++++++++++++++-------------
 net/x25/sysctl_net_x25.c |  5 ++++-
 3 files changed, 27 insertions(+), 16 deletions(-)

diff --git a/include/net/x25.h b/include/net/x25.h
index c383aa4..339820c 100644
--- a/include/net/x25.h
+++ b/include/net/x25.h
@@ -298,10 +298,10 @@ int x25_decode(struct sock *, struct sk_buff *, int *, int *, int *, int *,
 
 /* sysctl_net_x25.c */
 #ifdef CONFIG_SYSCTL
-void x25_register_sysctl(void);
+int x25_register_sysctl(void);
 void x25_unregister_sysctl(void);
 #else
-static inline void x25_register_sysctl(void) {};
+static inline int x25_register_sysctl(void) { return 0 };
 static inline void x25_unregister_sysctl(void) {};
 #endif /* CONFIG_SYSCTL */
 
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 8b911c2..75c64de 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1791,34 +1791,42 @@ void x25_kill_by_neigh(struct x25_neigh *nb)
 
 static int __init x25_init(void)
 {
-	int rc = proto_register(&x25_proto, 0);
+	int rc;
 
-	if (rc != 0)
+	rc = proto_register(&x25_proto, 0);
+	if (rc)
 		goto out;
 
 	rc = sock_register(&x25_family_ops);
-	if (rc != 0)
-		goto out_proto;
+	if (rc)
+		goto out_sock;
 
 	dev_add_pack(&x25_packet_type);
 
 	rc = register_netdevice_notifier(&x25_dev_notifier);
-	if (rc != 0)
-		goto out_sock;
+	if (rc)
+		goto out_dev;
 
-	pr_info("Linux Version 0.2\n");
+	rc = x25_register_sysctl();
+	if (rc)
+		goto out_sysctl;
 
-	x25_register_sysctl();
 	rc = x25_proc_init();
-	if (rc != 0)
-		goto out_dev;
+	if (rc)
+		goto out_proc;
+
+	pr_info("Linux Version 0.2\n");
+
 out:
 	return rc;
-out_dev:
+out_proc:
+	x25_unregister_sysctl();
+out_sysctl:
 	unregister_netdevice_notifier(&x25_dev_notifier);
-out_sock:
+out_dev:
+	dev_remove_pack(&x25_packet_type);
 	sock_unregister(AF_X25);
-out_proto:
+out_sock:
 	proto_unregister(&x25_proto);
 	goto out;
 }
diff --git a/net/x25/sysctl_net_x25.c b/net/x25/sysctl_net_x25.c
index a06dfe1..ba078c8 100644
--- a/net/x25/sysctl_net_x25.c
+++ b/net/x25/sysctl_net_x25.c
@@ -73,9 +73,12 @@
 	{ },
 };
 
-void __init x25_register_sysctl(void)
+int __init x25_register_sysctl(void)
 {
 	x25_table_header = register_net_sysctl(&init_net, "net/x25", x25_table);
+	if (!x25_table_header)
+		return -ENOMEM;
+	return 0;
 }
 
 void x25_unregister_sysctl(void)
-- 
1.8.3.1
