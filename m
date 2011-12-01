From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 1/2] unix: Reformat proc files creation
Date: Thu, 01 Dec 2011 21:41:43 +0400
Message-ID: <4ED7BC57.5070903@parallels.com>
References: <4ED7BC37.2030805@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:44555 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755739Ab1LARlu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Dec 2011 12:41:50 -0500
In-Reply-To: <4ED7BC37.2030805@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This just makes codepaths better prepared for yet another
proc file creation.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 net/unix/af_unix.c |   34 +++++++++++++++++++++++++++-------
 1 files changed, 27 insertions(+), 7 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 466fbcc..4b83a9c 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2326,6 +2326,29 @@ static const struct file_operations unix_seq_fops = {
 	.release	= seq_release_net,
 };
 
+static int unix_proc_create(struct net *net)
+{
+	if (!proc_net_fops_create(net, "unix", 0, &unix_seq_fops))
+		goto out;
+
+	return 0;
+out:
+	return -ENOMEM;
+}
+
+static void unix_proc_destroy(struct net *net)
+{
+	proc_net_remove(net, "unix");
+}
+#else
+static inline int unix_proc_create(struct net *net)
+{
+	return 0;
+}
+
+static inline void unix_proc_destroy(struct net *net)
+{
+}
 #endif
 
 static const struct net_proto_family unix_family_ops = {
@@ -2343,13 +2366,10 @@ static int __net_init unix_net_init(struct net *net)
 	if (unix_sysctl_register(net))
 		goto out;
 
-#ifdef CONFIG_PROC_FS
-	if (!proc_net_fops_create(net, "unix", 0, &unix_seq_fops)) {
+	error = unix_proc_create(net);
+	if (error)
 		unix_sysctl_unregister(net);
-		goto out;
-	}
-#endif
-	error = 0;
+
 out:
 	return error;
 }
@@ -2357,7 +2377,7 @@ out:
 static void __net_exit unix_net_exit(struct net *net)
 {
 	unix_sysctl_unregister(net);
-	proc_net_remove(net, "unix");
+	unix_proc_destroy(net);
 }
 
 static struct pernet_operations unix_net_ops = {
-- 
1.5.5.6
