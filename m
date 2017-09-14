From: Ilya Lesokhin <ilyal@mellanox.com>
Subject: [PATCH net-next 1/5] tls: Move release of tls_ctx into tls_sw_free_resources
Date: Thu, 14 Sep 2017 13:46:24 +0300
Message-ID: <1505385988-94522-2-git-send-email-ilyal@mellanox.com>
References: <1505385988-94522-1-git-send-email-ilyal@mellanox.com>
Cc: davejwatson@fb.com, tom@herbertland.com,
        hannes@stressinduktion.org, borisp@mellanox.com,
        ilyal@mellanox.com, aviadye@mellanox.com, liranl@mellanox.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37256 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751837AbdINKqf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2017 06:46:35 -0400
In-Reply-To: <1505385988-94522-1-git-send-email-ilyal@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move release of tls_ctx into sw specific code.
This is required because the device offload implementation
requires this context to remain alive until there are
no more in-flight SKBs.

Signed-off-by: Boris Pismenny <borisp@mellanox.com>
Signed-off-by: Ilya Lesokhin <ilyal@mellanox.com>
Signed-off-by: Aviad Yehezkel <aviadye@mellanox.com>
---
 net/tls/tls_main.c | 5 ++---
 net/tls/tls_sw.c   | 1 +
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/tls/tls_main.c b/net/tls/tls_main.c
index 60aff60..ae20ee3 100644
--- a/net/tls/tls_main.c
+++ b/net/tls/tls_main.c
@@ -232,12 +232,11 @@ static void tls_sk_proto_close(struct sock *sk, long timeout)
 			sg++;
 		}
 	}
-	ctx->free_resources(sk);
+
 	kfree(ctx->rec_seq);
 	kfree(ctx->iv);
-
 	sk_proto_close = ctx->sk_proto_close;
-	kfree(ctx);
+	ctx->free_resources(sk);
 
 	release_sock(sk);
 	sk_proto_close(sk, timeout);
diff --git a/net/tls/tls_sw.c b/net/tls/tls_sw.c
index fa596fa..db1e566 100644
--- a/net/tls/tls_sw.c
+++ b/net/tls/tls_sw.c
@@ -650,6 +650,7 @@ void tls_sw_free_resources(struct sock *sk)
 	tls_free_both_sg(sk);
 
 	kfree(ctx);
+	kfree(tls_ctx);
 }
 
 int tls_set_sw_offload(struct sock *sk, struct tls_context *ctx)
-- 
1.8.3.1
