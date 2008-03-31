From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 12/13 net-2.6.26] [NETNS]: Create tcp control socket in the each namespace.
Date: Mon, 31 Mar 2008 17:16:52 +0400
Message-ID: <1206969413-12096-12-git-send-email-den@openvz.org>
References: <1206969367.10660.16.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:6141 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755537AbYCaNRA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2008 09:17:00 -0400
In-Reply-To: <1206969367.10660.16.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/netns/ipv4.h |    1 +
 net/ipv4/tcp_ipv4.c      |   21 +++++++++++++++++++--
 2 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index af685f7..34ee348 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -28,6 +28,7 @@ struct netns_ipv4 {
 	struct sock		*fibnl;
 
 	struct sock		**icmp_sk;
+	struct sock		*tcp_sock;
 
 	struct netns_frags	frags;
 #ifdef CONFIG_NETFILTER
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index dc8c3dc..1d4a77a 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2488,11 +2488,28 @@ struct proto tcp_prot = {
 #endif
 };
 
+
+static int __net_init tcp_sk_init(struct net *net)
+{
+	return inet_ctl_sock_create(&net->ipv4.tcp_sock,
+				    PF_INET, SOCK_RAW, IPPROTO_TCP, net);
+}
+
+static void __net_exit tcp_sk_exit(struct net *net)
+{
+	inet_ctl_sock_destroy(net->ipv4.tcp_sock);
+}
+
+static struct pernet_operations __net_initdata tcp_sk_ops = {
+       .init = tcp_sk_init,
+       .exit = tcp_sk_exit,
+};
+
 void __init tcp_v4_init(void)
 {
-	if (inet_ctl_sock_create(&tcp_sock, PF_INET, SOCK_RAW,
-				 IPPROTO_TCP, &init_net) < 0)
+	if (register_pernet_device(&tcp_sk_ops))
 		panic("Failed to create the TCP control socket.\n");
+	tcp_sock = init_net.ipv4.tcp_sock;
 }
 
 EXPORT_SYMBOL(ipv4_specific);
-- 
1.5.3.rc5

