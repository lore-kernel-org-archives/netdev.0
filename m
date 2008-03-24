From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 2/5][NETNS][TCP]: Register /proc/net/tcp in a namespace.
Date: Mon, 24 Mar 2008 13:48:54 +0300
Message-ID: <47E78716.7000903@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:42083 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756706AbYCXKsz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Mar 2008 06:48:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the commit f40c8174d3c21bf178283f3ef3aa8c7bf238fdec ([NETNS][IPV4] 
tcp - make proc handle the network namespaces) it is now possible to make
this file present in newly created namespaces.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/tcp_ipv4.c |   19 +++++++++++++++++--
 1 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 1a47719..9ec4d0f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2425,14 +2425,29 @@ static struct tcp_seq_afinfo tcp4_seq_afinfo = {
 	.seq_fops	= &tcp4_seq_fops,
 };
 
+static int tcp4_proc_init_net(struct net *net)
+{
+	return tcp_proc_register(net, &tcp4_seq_afinfo);
+}
+
+static void tcp4_proc_exit_net(struct net *net)
+{
+	tcp_proc_unregister(net, &tcp4_seq_afinfo);
+}
+
+static struct pernet_operations tcp4_net_ops = {
+	.init = tcp4_proc_init_net,
+	.exit = tcp4_proc_exit_net,
+};
+
 int __init tcp4_proc_init(void)
 {
-	return tcp_proc_register(&init_net, &tcp4_seq_afinfo);
+	return register_pernet_subsys(&tcp4_net_ops);
 }
 
 void tcp4_proc_exit(void)
 {
-	tcp_proc_unregister(&init_net, &tcp4_seq_afinfo);
+	unregister_pernet_subsys(&tcp4_net_ops);
 }
 #endif /* CONFIG_PROC_FS */
 
-- 
1.5.3.4

