From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 1/4][NETNS][ICMP]: Register pernet subsys to make
 ICMP sysctls per-net.
Date: Wed, 26 Mar 2008 11:51:21 +0300
Message-ID: <47EA0E89.5040200@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:41624 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751324AbYCZIvZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 04:51:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This includes adding pernet_operations, empty init and exit
hooks and a bit of changes in sysctl_ipv4_init just not to
have this part in next patches.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/sysctl_net_ipv4.c |   24 +++++++++++++++++++++++-
 1 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 88286f3..c2fca30 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -811,12 +811,34 @@ struct ctl_path net_ipv4_ctl_path[] = {
 };
 EXPORT_SYMBOL_GPL(net_ipv4_ctl_path);
 
+static __net_init int ipv4_sysctl_init_net(struct net *net)
+{
+	return 0;
+}
+
+static __net_exit void ipv4_sysctl_exit_net(struct net *net)
+{
+}
+
+static __net_initdata struct pernet_operations ipv4_sysctl_ops = {
+	.init = ipv4_sysctl_init_net,
+	.exit = ipv4_sysctl_exit_net,
+};
+
 static __init int sysctl_ipv4_init(void)
 {
 	struct ctl_table_header *hdr;
 
 	hdr = register_sysctl_paths(net_ipv4_ctl_path, ipv4_table);
-	return hdr == NULL ? -ENOMEM : 0;
+	if (hdr == NULL)
+		return -ENOMEM;
+
+	if (register_pernet_subsys(&ipv4_sysctl_ops)) {
+		unregister_sysctl_table(hdr);
+		return -ENOMEM;
+	}
+
+	return 0;
 }
 
 __initcall(sysctl_ipv4_init);
-- 
1.5.3.4

