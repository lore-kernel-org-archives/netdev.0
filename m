From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH v6 3/5] rxrpc: check return value of skb_to_sgvec always
Date: Tue, 25 Apr 2017 20:47:32 +0200
Message-ID: <20170425184734.26563-3-Jason@zx2c4.com>
References: <20170425155215.4835-1-Jason@zx2c4.com>
 <20170425184734.26563-1-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	David.Laight@aculab.com,
	kernel-hardening@lists.openwall.com,
	davem@davemloft.net
Return-path: <kernel-hardening-return-7574-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170425184734.26563-1-Jason@zx2c4.com>
List-Id: netdev.vger.kernel.org

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
---
 net/rxrpc/rxkad.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index 4374e7b9c7bf..dcf46c9c3ece 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -229,7 +229,9 @@ static int rxkad_secure_packet_encrypt(const struct rxrpc_call *call,
 	len &= ~(call->conn->size_align - 1);
 
 	sg_init_table(sg, nsg);
-	skb_to_sgvec(skb, sg, 0, len);
+	err = skb_to_sgvec(skb, sg, 0, len);
+	if (unlikely(err < 0))
+		goto out;
 	skcipher_request_set_crypt(req, sg, sg, len, iv.x);
 	crypto_skcipher_encrypt(req);
 
@@ -342,7 +344,8 @@ static int rxkad_verify_packet_1(struct rxrpc_call *call, struct sk_buff *skb,
 		goto nomem;
 
 	sg_init_table(sg, nsg);
-	skb_to_sgvec(skb, sg, offset, 8);
+	if (unlikely(skb_to_sgvec(skb, sg, offset, 8) < 0))
+		goto nomem;
 
 	/* start the decryption afresh */
 	memset(&iv, 0, sizeof(iv));
@@ -429,7 +432,8 @@ static int rxkad_verify_packet_2(struct rxrpc_call *call, struct sk_buff *skb,
 	}
 
 	sg_init_table(sg, nsg);
-	skb_to_sgvec(skb, sg, offset, len);
+	if (unlikely(skb_to_sgvec(skb, sg, offset, len) < 0))
+		goto nomem;
 
 	/* decrypt from the session key */
 	token = call->conn->params.key->payload.data[0];
-- 
2.12.2
