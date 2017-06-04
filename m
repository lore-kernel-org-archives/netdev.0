From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH net-next v10 3/5] rxrpc: check return value of skb_to_sgvec always
Date: Sun,  4 Jun 2017 04:16:24 +0200
Message-ID: <20170604021626.11968-4-Jason@zx2c4.com>
References: <20170604021626.11968-1-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	davem@davemloft.net,
	kernel-hardening@lists.openwall.com
Return-path: <kernel-hardening-return-8261-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170604021626.11968-1-Jason@zx2c4.com>
List-Id: netdev.vger.kernel.org

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Acked-by: David Howells <dhowells@redhat.com>
---
 net/rxrpc/rxkad.c | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index 1bb9b2ccc267..29fe20ad04aa 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -227,7 +227,9 @@ static int rxkad_secure_packet_encrypt(const struct rxrpc_call *call,
 	len &= ~(call->conn->size_align - 1);
 
 	sg_init_table(sg, nsg);
-	skb_to_sgvec(skb, sg, 0, len);
+	err = skb_to_sgvec(skb, sg, 0, len);
+	if (unlikely(err < 0))
+		goto out;
 	skcipher_request_set_crypt(req, sg, sg, len, iv.x);
 	crypto_skcipher_encrypt(req);
 
@@ -324,7 +326,7 @@ static int rxkad_verify_packet_1(struct rxrpc_call *call, struct sk_buff *skb,
 	bool aborted;
 	u32 data_size, buf;
 	u16 check;
-	int nsg;
+	int nsg, ret;
 
 	_enter("");
 
@@ -342,7 +344,9 @@ static int rxkad_verify_packet_1(struct rxrpc_call *call, struct sk_buff *skb,
 		goto nomem;
 
 	sg_init_table(sg, nsg);
-	skb_to_sgvec(skb, sg, offset, 8);
+	ret = skb_to_sgvec(skb, sg, offset, 8);
+	if (unlikely(ret < 0))
+		return ret;
 
 	/* start the decryption afresh */
 	memset(&iv, 0, sizeof(iv));
@@ -409,7 +413,7 @@ static int rxkad_verify_packet_2(struct rxrpc_call *call, struct sk_buff *skb,
 	bool aborted;
 	u32 data_size, buf;
 	u16 check;
-	int nsg;
+	int nsg, ret;
 
 	_enter(",{%d}", skb->len);
 
@@ -434,7 +438,12 @@ static int rxkad_verify_packet_2(struct rxrpc_call *call, struct sk_buff *skb,
 	}
 
 	sg_init_table(sg, nsg);
-	skb_to_sgvec(skb, sg, offset, len);
+	ret = skb_to_sgvec(skb, sg, offset, len);
+	if (unlikely(ret < 0)) {
+		if (sg != _sg)
+			kfree(sg);
+		return ret;
+	}
 
 	/* decrypt from the session key */
 	token = call->conn->params.key->payload.data[0];
-- 
2.13.0
