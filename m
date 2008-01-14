From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 4/4][NETNS][RAW]: Create the /proc/net/raw(6) in
 each namespace.
Date: Mon, 14 Jan 2008 16:13:08 +0300
Message-ID: <478B5FE4.3020602@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:58622 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751199AbYANNNL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2008 08:13:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To do so, just register the proper subsystem and create files in
->init callbacks.

No other special per-namespace handling for raw sockets is required.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/raw.c |   22 +++++++++++++++++++---
 net/ipv6/raw.c |   22 +++++++++++++++++++---
 2 files changed, 38 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 206c869..91a5218 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -1003,15 +1003,31 @@ static const struct file_operations raw_seq_fops = {
 	.release = seq_release_net,
 };
 
-int __init raw_proc_init(void)
+static __net_init int raw_init_net(struct net *net)
 {
-	if (!proc_net_fops_create(&init_net, "raw", S_IRUGO, &raw_seq_fops))
+	if (!proc_net_fops_create(net, "raw", S_IRUGO, &raw_seq_fops))
 		return -ENOMEM;
+
 	return 0;
 }
 
+static __net_exit void raw_exit_net(struct net *net)
+{
+	proc_net_remove(net, "raw");
+}
+
+static __net_initdata struct pernet_operations raw_net_ops = {
+	.init = raw_init_net,
+	.exit = raw_exit_net,
+};
+
+int __init raw_proc_init(void)
+{
+	return register_pernet_subsys(&raw_net_ops);
+}
+
 void __init raw_proc_exit(void)
 {
-	proc_net_remove(&init_net, "raw");
+	unregister_pernet_subsys(&raw_net_ops);
 }
 #endif /* CONFIG_PROC_FS */
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 970529e..4d88055 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1270,16 +1270,32 @@ static const struct file_operations raw6_seq_fops = {
 	.release =	seq_release_net,
 };
 
-int __init raw6_proc_init(void)
+static int raw6_init_net(struct net *net)
 {
-	if (!proc_net_fops_create(&init_net, "raw6", S_IRUGO, &raw6_seq_fops))
+	if (!proc_net_fops_create(net, "raw6", S_IRUGO, &raw6_seq_fops))
 		return -ENOMEM;
+
 	return 0;
 }
 
+static void raw6_exit_net(struct net *net)
+{
+	proc_net_remove(net, "raw6");
+}
+
+static struct pernet_operations raw6_net_ops = {
+	.init = raw6_init_net,
+	.exit = raw6_exit_net,
+};
+
+int __init raw6_proc_init(void)
+{
+	return register_pernet_subsys(&raw6_net_ops);
+}
+
 void raw6_proc_exit(void)
 {
-	proc_net_remove(&init_net, "raw6");
+	unregister_pernet_subsys(&raw6_net_ops);
 }
 #endif	/* CONFIG_PROC_FS */
 
-- 
1.5.3.4

