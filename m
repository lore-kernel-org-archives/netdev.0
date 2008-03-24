From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 2/11 net-2.6.26] [NETNS]: /proc/net/arp namespacing.
Date: Mon, 24 Mar 2008 17:36:03 +0300
Message-ID: <1206369372-27711-2-git-send-email-den@openvz.org>
References: <1206369185.23705.7.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	containers@lists.osdl.org, xemul@openvz.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:52131 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758706AbYCXOfv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Mar 2008 10:35:51 -0400
In-Reply-To: <1206369185.23705.7.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Seqfile operation showing /proc/net/arp are already namespace aware. All we
need is to register this file for each namespace.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/arp.c |   20 ++++++++++++++++++--
 1 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 6d90ec5..832473e 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1377,13 +1377,29 @@ static const struct file_operations arp_seq_fops = {
 	.release	= seq_release_net,
 };
 
-static int __init arp_proc_init(void)
+
+static int __net_init arp_net_init(struct net *net)
 {
-	if (!proc_net_fops_create(&init_net, "arp", S_IRUGO, &arp_seq_fops))
+	if (!proc_net_fops_create(net, "arp", S_IRUGO, &arp_seq_fops))
 		return -ENOMEM;
 	return 0;
 }
 
+static void __net_exit arp_net_exit(struct net *net)
+{
+	proc_net_remove(net, "arp");
+}
+
+static struct pernet_operations arp_net_ops = {
+	.init = arp_net_init,
+	.exit = arp_net_exit,
+};
+
+static int __init arp_proc_init(void)
+{
+	return register_pernet_subsys(&arp_net_ops);
+}
+
 #else /* CONFIG_PROC_FS */
 
 static int __init arp_proc_init(void)
-- 
1.5.3.rc5

