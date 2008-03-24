From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 1/5][NETNS][UDP]: Register /proc/net/udp in a namespace.
Date: Mon, 24 Mar 2008 13:46:58 +0300
Message-ID: <47E786A2.6090505@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:41642 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756059AbYCXKrK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Mar 2008 06:47:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the commit a91275eff43a527e1a25d6d034cbcd19ee323e64 ([NETNS][IPV6]
udp - make proc handle the network namespace) it is now possible to make
this file present in newly created namespaces.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/udp.c |   19 +++++++++++++++++--
 1 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 8c1f5ea..7e7f5c2 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1701,14 +1701,29 @@ static struct udp_seq_afinfo udp4_seq_afinfo = {
 	.seq_fops	= &udp4_seq_fops,
 };
 
+static int udp4_proc_init_net(struct net *net)
+{
+	return udp_proc_register(net, &udp4_seq_afinfo);
+}
+
+static void udp4_proc_exit_net(struct net *net)
+{
+	udp_proc_unregister(net, &udp4_seq_afinfo);
+}
+
+static struct pernet_operations udp4_net_ops = {
+	.init = udp4_proc_init_net,
+	.exit = udp4_proc_exit_net,
+};
+
 int __init udp4_proc_init(void)
 {
-	return udp_proc_register(&init_net, &udp4_seq_afinfo);
+	return register_pernet_subsys(&udp4_net_ops);
 }
 
 void udp4_proc_exit(void)
 {
-	udp_proc_unregister(&init_net, &udp4_seq_afinfo);
+	unregister_pernet_subsys(&udp4_net_ops);
 }
 #endif /* CONFIG_PROC_FS */
 
-- 
1.5.3.4

