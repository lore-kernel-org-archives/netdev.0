From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Fix networking scatterlist regressions.
Date: Tue, 30 Oct 2007 20:40:02 -0700 (PDT)
Message-ID: <20071030.204002.193703502.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, rusty@rustcorp.com.au,
	jens.axboe@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45281
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752081AbXJaDkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 23:40:03 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I just checked the following bug fix into net-2.6

Rusty, have a quick look at virtio_net wrt. the changes I
made to skb_to_sgvec()'s behavior.  I think I might have
even fixed something :-)

Jens, please review my commentary wrt. sg_mark_end() and
it's nonintuitive behavior which led to these bugs.

Thanks.

[NET]: Fix incorrect sg_mark_end() calls.

This fixes scatterlist corruptions added by

	commit 68e3f5dd4db62619fdbe520d36c9ebf62e672256
	[CRYPTO] users: Fix up scatterlist conversion errors

The issue is that the code calls sg_mark_end() which clobbers the
sg_page() pointer of the final scatterlist entry.

The first part fo the fix makes skb_to_sgvec() do __sg_mark_end().

After considering all skb_to_sgvec() call sites the most correct
solution is to call __sg_mark_end() in skb_to_sgvec() since that is
what all of the callers would end up doing anyways.

I suspect this might have fixed some problems in virtio_net which is
the sole non-crypto user of skb_to_sgvec().

Other similar sg_mark_end() cases were converted over to
__sg_mark_end() as well.

Arguably sg_mark_end() is a poorly named function because it doesn't
just "mark", it clears out the page pointer as a side effect, which is
what led to these bugs in the first place.

The one remaining plain sg_mark_end() call is in scsi_alloc_sgtable()
and arguably it could be converted to __sg_mark_end() if only so that
we can delete this confusing interface from linux/scatterlist.h

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/skbuff.c                     |   16 +++++++++++++---
 net/ipv4/esp4.c                       |   12 +++++++-----
 net/ipv4/tcp_ipv4.c                   |    2 +-
 net/ipv6/esp6.c                       |   13 +++++++------
 net/ipv6/tcp_ipv6.c                   |    2 +-
 net/rxrpc/rxkad.c                     |    9 +++++----
 net/sunrpc/auth_gss/gss_krb5_crypto.c |    6 +++---
 7 files changed, 37 insertions(+), 23 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 573e172..64b50ff 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2028,8 +2028,8 @@ void __init skb_init(void)
  *	Fill the specified scatter-gather list with mappings/pointers into a
  *	region of the buffer space attached to a socket buffer.
  */
-int
-skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
+static int
+__skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
 {
 	int start = skb_headlen(skb);
 	int i, copy = start - offset;
@@ -2078,7 +2078,8 @@ skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
 			if ((copy = end - offset) > 0) {
 				if (copy > len)
 					copy = len;
-				elt += skb_to_sgvec(list, sg+elt, offset - start, copy);
+				elt += __skb_to_sgvec(list, sg+elt, offset - start,
+						      copy);
 				if ((len -= copy) == 0)
 					return elt;
 				offset += copy;
@@ -2090,6 +2091,15 @@ skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
 	return elt;
 }
 
+int skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
+{
+	int nsg = __skb_to_sgvec(skb, sg, offset, len);
+
+	__sg_mark_end(&sg[nsg - 1]);
+
+	return nsg;
+}
+
 /**
  *	skb_cow_data - Check that a socket buffer's data buffers are writable
  *	@skb: The socket buffer to check.
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index cad4278..c31bccb 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -111,9 +111,10 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 				goto unlock;
 		}
 		sg_init_table(sg, nfrags);
-		sg_mark_end(sg, skb_to_sgvec(skb, sg, esph->enc_data +
-						      esp->conf.ivlen -
-						      skb->data, clen));
+		skb_to_sgvec(skb, sg,
+			     esph->enc_data +
+			     esp->conf.ivlen -
+			     skb->data, clen);
 		err = crypto_blkcipher_encrypt(&desc, sg, sg, clen);
 		if (unlikely(sg != &esp->sgbuf[0]))
 			kfree(sg);
@@ -205,8 +206,9 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 			goto out;
 	}
 	sg_init_table(sg, nfrags);
-	sg_mark_end(sg, skb_to_sgvec(skb, sg, sizeof(*esph) + esp->conf.ivlen,
-				     elen));
+	skb_to_sgvec(skb, sg,
+		     sizeof(*esph) + esp->conf.ivlen,
+		     elen);
 	err = crypto_blkcipher_decrypt(&desc, sg, sg, elen);
 	if (unlikely(sg != &esp->sgbuf[0]))
 		kfree(sg);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index d3d8d5d..eec02b2 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1083,7 +1083,7 @@ static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 	sg_set_buf(&sg[block++], key->key, key->keylen);
 	nbytes += key->keylen;
 
-	sg_mark_end(sg, block);
+	__sg_mark_end(&sg[block - 1]);
 
 	/* Now store the Hash into the packet */
 	err = crypto_hash_init(desc);
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index ab17b5e..7db66f1 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -110,9 +110,10 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 				goto unlock;
 		}
 		sg_init_table(sg, nfrags);
-		sg_mark_end(sg, skb_to_sgvec(skb, sg, esph->enc_data +
-						      esp->conf.ivlen -
-						      skb->data, clen));
+		skb_to_sgvec(skb, sg,
+			     esph->enc_data +
+			     esp->conf.ivlen -
+			     skb->data, clen);
 		err = crypto_blkcipher_encrypt(&desc, sg, sg, clen);
 		if (unlikely(sg != &esp->sgbuf[0]))
 			kfree(sg);
@@ -209,9 +210,9 @@ static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 			}
 		}
 		sg_init_table(sg, nfrags);
-		sg_mark_end(sg, skb_to_sgvec(skb, sg,
-					     sizeof(*esph) + esp->conf.ivlen,
-					     elen));
+		skb_to_sgvec(skb, sg,
+			     sizeof(*esph) + esp->conf.ivlen,
+			     elen);
 		ret = crypto_blkcipher_decrypt(&desc, sg, sg, elen);
 		if (unlikely(sg != &esp->sgbuf[0]))
 			kfree(sg);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index f1523b8..4b90328 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -781,7 +781,7 @@ static int tcp_v6_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 	sg_set_buf(&sg[block++], key->key, key->keylen);
 	nbytes += key->keylen;
 
-	sg_mark_end(sg, block);
+	__sg_mark_end(&sg[block - 1]);
 
 	/* Now store the hash into the packet */
 	err = crypto_hash_init(desc);
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index eebefb6..57458d4 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -237,7 +237,8 @@ static int rxkad_secure_packet_encrypt(const struct rxrpc_call *call,
 	len = data_size + call->conn->size_align - 1;
 	len &= ~(call->conn->size_align - 1);
 
-	sg_init_table(sg, skb_to_sgvec(skb, sg, 0, len));
+	sg_init_table(sg, nsg);
+	skb_to_sgvec(skb, sg, 0, len);
 	crypto_blkcipher_encrypt_iv(&desc, sg, sg, len);
 
 	_leave(" = 0");
@@ -344,7 +345,7 @@ static int rxkad_verify_packet_auth(const struct rxrpc_call *call,
 		goto nomem;
 
 	sg_init_table(sg, nsg);
-	sg_mark_end(sg, skb_to_sgvec(skb, sg, 0, 8));
+	skb_to_sgvec(skb, sg, 0, 8);
 
 	/* start the decryption afresh */
 	memset(&iv, 0, sizeof(iv));
@@ -426,7 +427,7 @@ static int rxkad_verify_packet_encrypt(const struct rxrpc_call *call,
 	}
 
 	sg_init_table(sg, nsg);
-	sg_mark_end(sg, skb_to_sgvec(skb, sg, 0, skb->len));
+	skb_to_sgvec(skb, sg, 0, skb->len);
 
 	/* decrypt from the session key */
 	payload = call->conn->key->payload.data;
@@ -701,7 +702,7 @@ static void rxkad_sg_set_buf2(struct scatterlist sg[2],
 		nsg++;
 	}
 
-	sg_mark_end(sg, nsg);
+	__sg_mark_end(sg, nsg);
 
 	ASSERTCMP(sg[0].length + sg[1].length, ==, buflen);
 }
diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index 91cd8f0..4a8aa94 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -211,8 +211,8 @@ encryptor(struct scatterlist *sg, void *data)
 	if (thislen == 0)
 		return 0;
 
-	sg_mark_end(desc->infrags, desc->fragno);
-	sg_mark_end(desc->outfrags, desc->fragno);
+	__sg_mark_end(desc->infrags, desc->fragno);
+	__sg_mark_end(desc->outfrags, desc->fragno);
 
 	ret = crypto_blkcipher_encrypt_iv(&desc->desc, desc->outfrags,
 					  desc->infrags, thislen);
@@ -293,7 +293,7 @@ decryptor(struct scatterlist *sg, void *data)
 	if (thislen == 0)
 		return 0;
 
-	sg_mark_end(desc->frags, desc->fragno);
+	__sg_mark_end(desc->frags, desc->fragno);
 
 	ret = crypto_blkcipher_decrypt_iv(&desc->desc, desc->frags,
 					  desc->frags, thislen);
-- 
1.5.2.5

