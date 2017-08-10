From: Ilya Lesokhin <ilyal@mellanox.com>
Subject: [PATCH 3/3] tls: Use correct sk->sk_prot for IPV6
Date: Thu, 10 Aug 2017 13:33:16 +0300
Message-ID: <1502361196-127278-4-git-send-email-ilyal@mellanox.com>
References: <1502361196-127278-1-git-send-email-ilyal@mellanox.com>
Cc: davejwatson@fb.com, aviadye@mellanox.com,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:33031 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752533AbdHJKdb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 06:33:31 -0400
In-Reply-To: <1502361196-127278-1-git-send-email-ilyal@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code assumed that only IP version 4 TCP sk->sk_prot was
being used. Now it checks for IPV6 and sets sk->sk_prot
accordingly.

Signed-off-by: Boris Pismenny <borisp@mellanox.com>
Signed-off-by: Ilya Lesokhin <ilyal@mellanox.com>
---
 net/tls/tls_main.c | 61 +++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 49 insertions(+), 12 deletions(-)

diff --git a/net/tls/tls_main.c b/net/tls/tls_main.c
index 60aff60..a5a499f 100644
--- a/net/tls/tls_main.c
+++ b/net/tls/tls_main.c
@@ -41,12 +41,29 @@
 
 #include <net/tls.h>
 
+#if IS_ENABLED(CONFIG_IPV6)
+#include <net/transp_v6.h>
+#endif
+
 MODULE_AUTHOR("Mellanox Technologies");
 MODULE_DESCRIPTION("Transport Layer Security Support");
 MODULE_LICENSE("Dual BSD/GPL");
 
-static struct proto tls_base_prot;
-static struct proto tls_sw_prot;
+enum {
+	TLSV4,
+#if IS_ENABLED(CONFIG_IPV6)
+	TLSV6,
+#endif
+	TLS_NUM_PROTS,
+};
+
+enum {
+	TLS_BASE_TX,
+	TLS_SW_TX,
+	TLS_NUM_CONFIG,
+};
+
+static struct proto tls_prots[TLS_NUM_PROTS][TLS_NUM_CONFIG];
 
 int wait_on_pending_writer(struct sock *sk, long *timeo)
 {
@@ -342,6 +359,7 @@ static int do_tls_setsockopt_tx(struct sock *sk, char __user *optval,
 	struct tls_context *ctx = tls_get_ctx(sk);
 	struct proto *prot = NULL;
 	int rc = 0;
+	int ip_ver = sk->sk_family == AF_INET6 ? TLSV6 : TLSV4;
 
 	if (!optval || (optlen < sizeof(*crypto_info))) {
 		rc = -EINVAL;
@@ -396,7 +414,7 @@ static int do_tls_setsockopt_tx(struct sock *sk, char __user *optval,
 
 	/* currently SW is default, we will have ethtool in future */
 	rc = tls_set_sw_offload(sk, ctx);
-	prot = &tls_sw_prot;
+	prot = &tls_prots[ip_ver][TLS_SW_TX];
 	if (rc)
 		goto err_crypto_info;
 
@@ -443,6 +461,15 @@ static int tls_init(struct sock *sk)
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tls_context *ctx;
 	int rc = 0;
+	int ip_ver = TLSV4;
+
+#if IS_ENABLED(CONFIG_IPV6)
+	if (sk->sk_family == AF_INET6)
+		ip_ver = TLSV6;
+	else
+#endif
+	if (sk->sk_family != AF_INET)
+		return -EINVAL;
 
 	/* allocate tls context */
 	ctx = kzalloc(sizeof(*ctx), GFP_KERNEL);
@@ -453,7 +480,8 @@ static int tls_init(struct sock *sk)
 	icsk->icsk_ulp_data = ctx;
 	ctx->setsockopt = sk->sk_prot->setsockopt;
 	ctx->getsockopt = sk->sk_prot->getsockopt;
-	sk->sk_prot = &tls_base_prot;
+
+	sk->sk_prot = &tls_prots[ip_ver][TLS_BASE_TX];
 out:
 	return rc;
 }
@@ -464,16 +492,25 @@ static int tls_init(struct sock *sk)
 	.init			= tls_init,
 };
 
+static void build_protos(struct proto *prot, struct proto *base)
+{
+	prot[TLS_BASE_TX] = *base;
+	prot[TLS_BASE_TX].setsockopt = tls_setsockopt;
+	prot[TLS_BASE_TX].getsockopt = tls_getsockopt;
+
+	prot[TLS_SW_TX]		= prot[TLS_BASE_TX];
+	prot[TLS_SW_TX].close	= tls_sk_proto_close;
+	prot[TLS_SW_TX].sendmsg		= tls_sw_sendmsg;
+	prot[TLS_SW_TX].sendpage	= tls_sw_sendpage;
+}
+
 static int __init tls_register(void)
 {
-	tls_base_prot			= tcp_prot;
-	tls_base_prot.setsockopt	= tls_setsockopt;
-	tls_base_prot.getsockopt	= tls_getsockopt;
-
-	tls_sw_prot			= tls_base_prot;
-	tls_sw_prot.sendmsg		= tls_sw_sendmsg;
-	tls_sw_prot.sendpage            = tls_sw_sendpage;
-	tls_sw_prot.close               = tls_sk_proto_close;
+	build_protos(tls_prots[TLSV4], &tcp_prot);
+
+#if IS_ENABLED(CONFIG_IPV6)
+	build_protos(tls_prots[TLSV6], &tcpv6_prot);
+#endif
 
 	tcp_register_ulp(&tcp_tls_ulp_ops);
 
-- 
1.8.3.1
