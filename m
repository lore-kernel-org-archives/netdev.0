From: Meng Xu <mengxu.gatech@gmail.com>
Subject: [PATCH] net/tls: move version check after second userspace fetch
Date: Sun, 24 Sep 2017 11:14:55 -0400
Message-ID: <1506266095-23003-1-git-send-email-mengxu.gatech@gmail.com>
Cc: meng.xu@gatech.edu, sanidhya@gatech.edu, taesoo@gatech.edu,
        Meng Xu <mengxu.gatech@gmail.com>
To: ilyal@mellanox.com, aviadye@mellanox.com, davejwatson@fb.com,
        davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Even the userspace buffer optval passed the version check
(i.e., tmp_crypto_info.version == TLS_1_2_VERSION) after the first fetch,
it can still be changed before the second copy_from_user() and hence,
a version different than TLS_1_2_VERSION may be copied into crypto_info.
This patch moves the version check after the second userspace fetch.

Signed-off-by: Meng Xu <mengxu.gatech@gmail.com>
---
 net/tls/tls_main.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/tls/tls_main.c b/net/tls/tls_main.c
index 60aff60..d4a7bc6 100644
--- a/net/tls/tls_main.c
+++ b/net/tls/tls_main.c
@@ -354,12 +354,6 @@ static int do_tls_setsockopt_tx(struct sock *sk, char __user *optval,
 		goto out;
 	}
 
-	/* check version */
-	if (tmp_crypto_info.version != TLS_1_2_VERSION) {
-		rc = -ENOTSUPP;
-		goto out;
-	}
-
 	/* get user crypto info */
 	crypto_info = &ctx->crypto_send;
 
@@ -382,6 +376,12 @@ static int do_tls_setsockopt_tx(struct sock *sk, char __user *optval,
 			rc = -EFAULT;
 			goto err_crypto_info;
 		}
+
+		/* check version */
+		if (crypto_info->version != TLS_1_2_VERSION) {
+			rc = -ENOTSUPP;
+			goto err_crypto_info;
+		}
 		break;
 	}
 	default:
-- 
2.7.4
