From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH] net: ping: make ping_v6_sendmsg static
Date: Wed, 23 Mar 2016 17:59:51 +0800
Message-ID: <1458727191-36958-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:2418 "EHLO
	cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751039AbcCWKAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 06:00:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As ping_v6_sendmsg is used only in this file,
making it static

The body of "pingv6_prot" and "pingv6_protosw" were
moved at the middle of the file, to avoid having to
declare some static prototypes.

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 include/net/ping.h |  1 -
 net/ipv6/ping.c    | 59 +++++++++++++++++++++++++++---------------------------
 2 files changed, 29 insertions(+), 31 deletions(-)

diff --git a/include/net/ping.h b/include/net/ping.h
index 5fd7cc2..4cd90d6 100644
--- a/include/net/ping.h
+++ b/include/net/ping.h
@@ -79,7 +79,6 @@ int  ping_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 		  int flags, int *addr_len);
 int  ping_common_sendmsg(int family, struct msghdr *msg, size_t len,
 			 void *user_icmph, size_t icmph_len);
-int  ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len);
 int  ping_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
 bool ping_rcv(struct sk_buff *skb);
 
diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index 263a516..c382db7 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -26,35 +26,6 @@
 #include <net/transp_v6.h>
 #include <net/ping.h>
 
-struct proto pingv6_prot = {
-	.name =		"PINGv6",
-	.owner =	THIS_MODULE,
-	.init =		ping_init_sock,
-	.close =	ping_close,
-	.connect =	ip6_datagram_connect_v6_only,
-	.disconnect =	udp_disconnect,
-	.setsockopt =	ipv6_setsockopt,
-	.getsockopt =	ipv6_getsockopt,
-	.sendmsg =	ping_v6_sendmsg,
-	.recvmsg =	ping_recvmsg,
-	.bind =		ping_bind,
-	.backlog_rcv =	ping_queue_rcv_skb,
-	.hash =		ping_hash,
-	.unhash =	ping_unhash,
-	.get_port =	ping_get_port,
-	.obj_size =	sizeof(struct raw6_sock),
-};
-EXPORT_SYMBOL_GPL(pingv6_prot);
-
-static struct inet_protosw pingv6_protosw = {
-	.type =      SOCK_DGRAM,
-	.protocol =  IPPROTO_ICMPV6,
-	.prot =      &pingv6_prot,
-	.ops =       &inet6_dgram_ops,
-	.flags =     INET_PROTOSW_REUSE,
-};
-
-
 /* Compatibility glue so we can support IPv6 when it's compiled as a module */
 static int dummy_ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len,
 				 int *addr_len)
@@ -77,7 +48,7 @@ static int dummy_ipv6_chk_addr(struct net *net, const struct in6_addr *addr,
 	return 0;
 }
 
-int ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
+static int ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
@@ -192,6 +163,34 @@ int ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	return len;
 }
 
+struct proto pingv6_prot = {
+	.name =		"PINGv6",
+	.owner =	THIS_MODULE,
+	.init =		ping_init_sock,
+	.close =	ping_close,
+	.connect =	ip6_datagram_connect_v6_only,
+	.disconnect =	udp_disconnect,
+	.setsockopt =	ipv6_setsockopt,
+	.getsockopt =	ipv6_getsockopt,
+	.sendmsg =	ping_v6_sendmsg,
+	.recvmsg =	ping_recvmsg,
+	.bind =		ping_bind,
+	.backlog_rcv =	ping_queue_rcv_skb,
+	.hash =		ping_hash,
+	.unhash =	ping_unhash,
+	.get_port =	ping_get_port,
+	.obj_size =	sizeof(struct raw6_sock),
+};
+EXPORT_SYMBOL_GPL(pingv6_prot);
+
+static struct inet_protosw pingv6_protosw = {
+	.type =      SOCK_DGRAM,
+	.protocol =  IPPROTO_ICMPV6,
+	.prot =      &pingv6_prot,
+	.ops =       &inet6_dgram_ops,
+	.flags =     INET_PROTOSW_REUSE,
+};
+
 #ifdef CONFIG_PROC_FS
 static void *ping_v6_seq_start(struct seq_file *seq, loff_t *pos)
 {
-- 
1.8.3.1
