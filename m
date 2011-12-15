From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 2/13] sock_diag: Fix module netlink aliases
Date: Thu, 15 Dec 2011 16:43:27 +0400
Message-ID: <4EE9EB6F.3000509@parallels.com>
References: <4EE9EB2A.4040909@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:39143 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758745Ab1LOMnd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Dec 2011 07:43:33 -0500
In-Reply-To: <4EE9EB2A.4040909@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've made a mistake when fixing the sock_/inet_diag aliases :(

1. The sock_diag layer should request the family-based alias,
   not just the IPPROTO_IP one;
2. The inet_diag layer should request for AF_INET+protocol alias,
   not just the protocol one.

Thus fix this.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 net/core/sock_diag.c |    4 ++--
 net/dccp/diag.c      |    2 +-
 net/ipv4/inet_diag.c |    7 ++++---
 net/ipv4/tcp_diag.c  |    2 +-
 net/ipv4/udp_diag.c  |    4 ++--
 5 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index 9c27bcd..cee96f3 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -64,7 +64,7 @@ static inline struct sock_diag_handler *sock_diag_lock_handler(int family)
 {
 	if (sock_diag_handlers[family] == NULL)
 		request_module("net-pf-%d-proto-%d-type-%d", PF_NETLINK,
-				NETLINK_SOCK_DIAG, IPPROTO_IP);
+				NETLINK_SOCK_DIAG, family);
 
 	mutex_lock(&sock_diag_table_mutex);
 	return sock_diag_handlers[family];
@@ -103,7 +103,7 @@ static int sock_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	case DCCPDIAG_GETSOCK:
 		if (inet_rcv_compat == NULL)
 			request_module("net-pf-%d-proto-%d-type-%d", PF_NETLINK,
-					NETLINK_SOCK_DIAG, IPPROTO_IP);
+					NETLINK_SOCK_DIAG, AF_INET);
 
 		mutex_lock(&sock_diag_table_mutex);
 		if (inet_rcv_compat != NULL)
diff --git a/net/dccp/diag.c b/net/dccp/diag.c
index e29214d..8f16257 100644
--- a/net/dccp/diag.c
+++ b/net/dccp/diag.c
@@ -83,4 +83,4 @@ module_exit(dccp_diag_fini);
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Arnaldo Carvalho de Melo <acme@mandriva.com>");
 MODULE_DESCRIPTION("DCCP inet_diag handler");
-MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_NETLINK, NETLINK_SOCK_DIAG, 33);
+MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_NETLINK, NETLINK_SOCK_DIAG, 2-33 /* AF_INET - IPPROTO_DCCP */);
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 575e28c..fa27313 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -54,8 +54,8 @@ static DEFINE_MUTEX(inet_diag_table_mutex);
 static const struct inet_diag_handler *inet_diag_lock_handler(int proto)
 {
 	if (!inet_diag_table[proto])
-		request_module("net-pf-%d-proto-%d-type-%d", PF_NETLINK,
-			       NETLINK_SOCK_DIAG, proto);
+		request_module("net-pf-%d-proto-%d-type-%d-%d", PF_NETLINK,
+			       NETLINK_SOCK_DIAG, AF_INET, proto);
 
 	mutex_lock(&inet_diag_table_mutex);
 	if (!inet_diag_table[proto])
@@ -1087,4 +1087,5 @@ static void __exit inet_diag_exit(void)
 module_init(inet_diag_init);
 module_exit(inet_diag_exit);
 MODULE_LICENSE("GPL");
-MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_NETLINK, NETLINK_SOCK_DIAG, 0);
+MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_NETLINK, NETLINK_SOCK_DIAG, 2 /* AF_INET */);
+MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_NETLINK, NETLINK_SOCK_DIAG, 10 /* AF_INET6 */);
diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
index 6334b1f..8cd357a 100644
--- a/net/ipv4/tcp_diag.c
+++ b/net/ipv4/tcp_diag.c
@@ -66,4 +66,4 @@ static void __exit tcp_diag_exit(void)
 module_init(tcp_diag_init);
 module_exit(tcp_diag_exit);
 MODULE_LICENSE("GPL");
-MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_NETLINK, NETLINK_SOCK_DIAG, 6);
+MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_NETLINK, NETLINK_SOCK_DIAG, 2-6 /* AF_INET - IPPROTO_TCP */);
diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index 27910c1..fe9db86 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -197,5 +197,5 @@ static void __exit udp_diag_exit(void)
 module_init(udp_diag_init);
 module_exit(udp_diag_exit);
 MODULE_LICENSE("GPL");
-MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_NETLINK, NETLINK_SOCK_DIAG, 17);
-MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_NETLINK, NETLINK_SOCK_DIAG, 136);
+MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_NETLINK, NETLINK_SOCK_DIAG, 2-17 /* AF_INET - IPPROTO_UDP */);
+MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_NETLINK, NETLINK_SOCK_DIAG, 2-136 /* AF_INET - IPPROTO_UDPLITE */);
-- 
1.5.5.6
