From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next 1/2] sock_diag: create udp_info for udp socket stats
Date: Mon,  5 Oct 2015 15:55:26 -0400
Message-ID: <1444074927-27098-2-git-send-email-kraigatgoog@gmail.com>
References: <1444074927-27098-1-git-send-email-kraigatgoog@gmail.com>
Cc: kraigatgoog@gmail.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Eric Dumazet <edumazet@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:34187 "EHLO
	mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752993AbbJETzc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 15:55:32 -0400
Received: by qkbi190 with SMTP id i190so53509211qkb.1
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 12:55:31 -0700 (PDT)
In-Reply-To: <1444074927-27098-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

struct udp_info is intended to be the UDP equivalent of tcp_info for the
INET_DIAG_INFO netlink attribute of TCPDIAG_GETSOCK and
SOCK_DIAG_BY_FAMILY.

Unfortunately, since clients may assume that all instances of the
INET_DIAG_INFO response attribute are serialized versions of tcp_info,
we need to define a new response attribute (INET_DIAG_UDP_INFO) for
returning the new udp_info struct.

This patch prepares the netlink code to return INET_DIAG_UDP_INFO and
udp_info (currently size of zero).

Signed-off-by: Craig Gallek <kraig@google.com>
---
 include/linux/inet_diag.h      |  1 +
 include/uapi/linux/inet_diag.h |  3 ++-
 include/uapi/linux/udp.h       |  3 +++
 net/dccp/diag.c                |  1 +
 net/ipv4/inet_diag.c           | 25 ++++++++++++-------------
 net/ipv4/tcp_diag.c            |  1 +
 net/ipv4/udp_diag.c            |  6 ++++--
 7 files changed, 24 insertions(+), 16 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index 0e707f0..bcf1189 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -25,6 +25,7 @@ struct inet_diag_handler {
 					  void *info);
 	__u16		idiag_type;
 	__u16		idiag_info_size;
+	__u8		idiag_info_type;
 };
 
 struct inet_connection_sock;
diff --git a/include/uapi/linux/inet_diag.h b/include/uapi/linux/inet_diag.h
index 68a1f71..5ad029a 100644
--- a/include/uapi/linux/inet_diag.h
+++ b/include/uapi/linux/inet_diag.h
@@ -113,9 +113,10 @@ enum {
 	INET_DIAG_DCTCPINFO,
 	INET_DIAG_PROTOCOL,  /* response attribute only */
 	INET_DIAG_SKV6ONLY,
+	INET_DIAG_UDP_INFO,
 };
 
-#define INET_DIAG_MAX INET_DIAG_SKV6ONLY
+#define INET_DIAG_MAX INET_DIAG_UDP_INFO
 
 /* INET_DIAG_MEM */
 
diff --git a/include/uapi/linux/udp.h b/include/uapi/linux/udp.h
index 16574ea..6ba37dc 100644
--- a/include/uapi/linux/udp.h
+++ b/include/uapi/linux/udp.h
@@ -37,5 +37,8 @@ struct udphdr {
 #define UDP_ENCAP_ESPINUDP	2 /* draft-ietf-ipsec-udp-encaps-06 */
 #define UDP_ENCAP_L2TPINUDP	3 /* rfc2661 */
 
+struct udp_info {
+};
+
 
 #endif /* _UAPI_LINUX_UDP_H */
diff --git a/net/dccp/diag.c b/net/dccp/diag.c
index 2d84303..3c1bf5c 100644
--- a/net/dccp/diag.c
+++ b/net/dccp/diag.c
@@ -67,6 +67,7 @@ static const struct inet_diag_handler dccp_diag_handler = {
 	.idiag_get_info	 = dccp_diag_get_info,
 	.idiag_type	 = IPPROTO_DCCP,
 	.idiag_info_size = sizeof(struct tcp_info),
+	.idiag_info_type = INET_DIAG_INFO,
 };
 
 static int __init dccp_diag_init(void)
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index ab9f8a6..581b335 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -177,8 +177,17 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 		if (sock_diag_put_meminfo(sk, skb, INET_DIAG_SKMEMINFO))
 			goto errout;
 
+	if ((ext & (1 << (INET_DIAG_INFO - 1))) && handler->idiag_info_size) {
+		attr = nla_reserve(skb, handler->idiag_info_type,
+				   handler->idiag_info_size);
+		if (!attr)
+			goto errout;
+
+		info = nla_data(attr);
+	}
+	handler->idiag_get_info(sk, r, info);
+
 	if (!icsk) {
-		handler->idiag_get_info(sk, r, NULL);
 		goto out;
 	}
 
@@ -204,15 +213,6 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 	}
 #undef EXPIRES_IN_MS
 
-	if ((ext & (1 << (INET_DIAG_INFO - 1))) && handler->idiag_info_size) {
-		attr = nla_reserve(skb, INET_DIAG_INFO,
-				   handler->idiag_info_size);
-		if (!attr)
-			goto errout;
-
-		info = nla_data(attr);
-	}
-
 	if (ext & (1 << (INET_DIAG_CONG - 1))) {
 		int err = 0;
 
@@ -225,8 +225,6 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 			goto errout;
 	}
 
-	handler->idiag_get_info(sk, r, info);
-
 	if (sk->sk_state < TCP_TIME_WAIT) {
 		union tcp_cc_info info;
 		size_t sz = 0;
@@ -1036,7 +1034,8 @@ int inet_diag_handler_get_info(struct sk_buff *skb, struct sock *sk)
 	}
 
 	attr = handler->idiag_info_size
-		? nla_reserve(skb, INET_DIAG_INFO, handler->idiag_info_size)
+		? nla_reserve(skb, handler->idiag_info_type,
+			      handler->idiag_info_size)
 		: NULL;
 	if (attr)
 		info = nla_data(attr);
diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
index 479f349..66e044b 100644
--- a/net/ipv4/tcp_diag.c
+++ b/net/ipv4/tcp_diag.c
@@ -52,6 +52,7 @@ static const struct inet_diag_handler tcp_diag_handler = {
 	.idiag_get_info	 = tcp_diag_get_info,
 	.idiag_type	 = IPPROTO_TCP,
 	.idiag_info_size = sizeof(struct tcp_info),
+	.idiag_info_type = INET_DIAG_INFO,
 };
 
 static int __init tcp_diag_init(void)
diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index 6116604..db48698 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -170,7 +170,8 @@ static const struct inet_diag_handler udp_diag_handler = {
 	.dump_one	 = udp_diag_dump_one,
 	.idiag_get_info  = udp_diag_get_info,
 	.idiag_type	 = IPPROTO_UDP,
-	.idiag_info_size = 0,
+	.idiag_info_size = sizeof(struct udp_info),
+	.idiag_info_type = INET_DIAG_UDP_INFO,
 };
 
 static void udplite_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
@@ -191,7 +192,8 @@ static const struct inet_diag_handler udplite_diag_handler = {
 	.dump_one	 = udplite_diag_dump_one,
 	.idiag_get_info  = udp_diag_get_info,
 	.idiag_type	 = IPPROTO_UDPLITE,
-	.idiag_info_size = 0,
+	.idiag_info_size = sizeof(struct udp_info),
+	.idiag_info_type = INET_DIAG_UDP_INFO,
 };
 
 static int __init udp_diag_init(void)
-- 
2.6.0.rc2.230.g3dd15c0
