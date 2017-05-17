From: linzhang <xiaolou4617@gmail.com>
Subject: [PATCH net v3] net: x25: fix one potential use-after-free issue
Date: Wed, 17 May 2017 12:05:07 +0800
Message-ID: <1494993907-22727-1-git-send-email-xiaolou4617@gmail.com>
Cc: linux-x25@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linzhang <xiaolou4617@gmail.com>
To: andrew.hendry@gmail.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function x25_init is not properly unregister related resources
on error handler.It is will result in kernel oops if x25_init init
failed, so add properly unregister call on error handler.

Also, i adjust the coding style and make x25_register_sysctl properly
return failure.

Signed-off-by: linzhang <xiaolou4617@gmail.com>
---

changelog:

v1 -> v2:
	* make x25_register_sysctl properly return failure

v2 -> v3:
	* keep the same lables as v1
	* fix missing semicolon

---
 include/net/x25.h        |  4 ++--
 net/x25/af_x25.c         | 24 ++++++++++++++++--------
 net/x25/sysctl_net_x25.c |  5 ++++-
 3 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/include/net/x25.h b/include/net/x25.h
index c383aa4..6d30a01 100644
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
+static inline int x25_register_sysctl(void) { return 0; };
 static inline void x25_unregister_sysctl(void) {};
 #endif /* CONFIG_SYSCTL */
 
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 8b911c2..5a1a98d 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1791,32 +1791,40 @@ void x25_kill_by_neigh(struct x25_neigh *nb)
 
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
+	if (rc)
 		goto out_proto;
 
 	dev_add_pack(&x25_packet_type);
 
 	rc = register_netdevice_notifier(&x25_dev_notifier);
-	if (rc != 0)
+	if (rc)
 		goto out_sock;
 
-	pr_info("Linux Version 0.2\n");
+	rc = x25_register_sysctl();
+	if (rc)
+		goto out_dev;
 
-	x25_register_sysctl();
 	rc = x25_proc_init();
-	if (rc != 0)
-		goto out_dev;
+	if (rc)
+		goto out_sysctl;
+
+	pr_info("Linux Version 0.2\n");
+
 out:
 	return rc;
+out_sysctl:
+	x25_unregister_sysctl();
 out_dev:
 	unregister_netdevice_notifier(&x25_dev_notifier);
 out_sock:
+	dev_remove_pack(&x25_packet_type);
 	sock_unregister(AF_X25);
 out_proto:
 	proto_unregister(&x25_proto);
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
