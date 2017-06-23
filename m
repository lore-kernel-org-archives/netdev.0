From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH -net] tls: return -EFAULT if copy_to_user() fails
Date: Fri, 23 Jun 2017 13:15:44 +0300
Message-ID: <20170623101544.c5bvwe5cd6e46bd5@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Aviad Yehezkel <aviadye@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Dave Watson <davejwatson@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:16562 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753694AbdFWKQC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 06:16:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The copy_to_user() function returns the number of bytes remaining but we
want to return -EFAULT here.

Fixes: 3c4d7559159b ("tls: kernel TLS support")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/tls/tls_main.c b/net/tls/tls_main.c
index 2ebc328bda96..a03130a47b85 100644
--- a/net/tls/tls_main.c
+++ b/net/tls/tls_main.c
@@ -273,7 +273,8 @@ static int do_tls_getsockopt_tx(struct sock *sk, char __user *optval,
 	}
 
 	if (len == sizeof(crypto_info)) {
-		rc = copy_to_user(optval, crypto_info, sizeof(*crypto_info));
+		if (copy_to_user(optval, crypto_info, sizeof(*crypto_info)))
+			rc = -EFAULT;
 		goto out;
 	}
 
@@ -293,9 +294,10 @@ static int do_tls_getsockopt_tx(struct sock *sk, char __user *optval,
 		memcpy(crypto_info_aes_gcm_128->iv, ctx->iv,
 		       TLS_CIPHER_AES_GCM_128_IV_SIZE);
 		release_sock(sk);
-		rc = copy_to_user(optval,
-				  crypto_info_aes_gcm_128,
-				  sizeof(*crypto_info_aes_gcm_128));
+		if (copy_to_user(optval,
+				 crypto_info_aes_gcm_128,
+				 sizeof(*crypto_info_aes_gcm_128)))
+			rc = -EFAULT;
 		break;
 	}
 	default:
