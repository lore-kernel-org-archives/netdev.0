From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the crypto tree with the net-next tree
Date: Mon, 7 Mar 2016 13:18:34 +1100
Message-ID: <20160307131834.70da82d4@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Howells <dhowells@redhat.com>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Herbert,

Today's linux-next merge of the crypto tree got a conflict in:

  net/rxrpc/rxkad.c

between commit:

  0d12f8a4027d ("rxrpc: Keep the skb private record of the Rx header in host byte order")

from the net-next tree and commit:

  1afe593b4239 ("rxrpc: Use skcipher")

from the crypto tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

-- 
Cheers,
Stephen Rothwell

diff --cc net/rxrpc/rxkad.c
index 3106a0c4960b,0d96b48a6492..000000000000
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@@ -128,21 -128,23 +128,23 @@@ static void rxkad_prime_packet_security
  	token = conn->key->payload.data[0];
  	memcpy(&iv, token->kad->session_key, sizeof(iv));
  
- 	desc.tfm = conn->cipher;
- 	desc.info = iv.x;
- 	desc.flags = 0;
- 
 -	tmpbuf.x[0] = conn->epoch;
 -	tmpbuf.x[1] = conn->cid;
 +	tmpbuf.x[0] = htonl(conn->epoch);
 +	tmpbuf.x[1] = htonl(conn->cid);
  	tmpbuf.x[2] = 0;
  	tmpbuf.x[3] = htonl(conn->security_ix);
  
  	sg_init_one(&sg[0], &tmpbuf, sizeof(tmpbuf));
  	sg_init_one(&sg[1], &tmpbuf, sizeof(tmpbuf));
- 	crypto_blkcipher_encrypt_iv(&desc, &sg[0], &sg[1], sizeof(tmpbuf));
+ 
+ 	skcipher_request_set_tfm(req, conn->cipher);
+ 	skcipher_request_set_callback(req, 0, NULL, NULL);
+ 	skcipher_request_set_crypt(req, &sg[1], &sg[0], sizeof(tmpbuf), iv.x);
+ 
+ 	crypto_skcipher_encrypt(req);
+ 	skcipher_request_zero(req);
  
  	memcpy(&conn->csum_iv, &tmpbuf.x[2], sizeof(conn->csum_iv));
 -	ASSERTCMP(conn->csum_iv.n[0], ==, tmpbuf.x[2]);
 +	ASSERTCMP((u32 __force)conn->csum_iv.n[0], ==, (u32 __force)tmpbuf.x[2]);
  
  	_leave("");
  }
@@@ -251,12 -267,12 +267,12 @@@ out
   * checksum an RxRPC packet header
   */
  static int rxkad_secure_packet(const struct rxrpc_call *call,
 -				struct sk_buff *skb,
 -				size_t data_size,
 -				void *sechdr)
 +			       struct sk_buff *skb,
 +			       size_t data_size,
 +			       void *sechdr)
  {
  	struct rxrpc_skb_priv *sp;
- 	struct blkcipher_desc desc;
+ 	SKCIPHER_REQUEST_ON_STACK(req, call->conn->cipher);
  	struct rxrpc_crypt iv;
  	struct scatterlist sg[2];
  	struct {
@@@ -280,15 -297,12 +296,12 @@@
  
  	/* continue encrypting from where we left off */
  	memcpy(&iv, call->conn->csum_iv.x, sizeof(iv));
- 	desc.tfm = call->conn->cipher;
- 	desc.info = iv.x;
- 	desc.flags = 0;
  
  	/* calculate the security checksum */
 -	x = htonl(call->channel << (32 - RXRPC_CIDSHIFT));
 -	x |= sp->hdr.seq & cpu_to_be32(0x3fffffff);
 -	tmpbuf.x[0] = sp->hdr.callNumber;
 -	tmpbuf.x[1] = x;
 +	x = call->channel << (32 - RXRPC_CIDSHIFT);
 +	x |= sp->hdr.seq & 0x3fffffff;
 +	tmpbuf.x[0] = htonl(sp->hdr.callNumber);
 +	tmpbuf.x[1] = htonl(x);
  
  	sg_init_one(&sg[0], &tmpbuf, sizeof(tmpbuf));
  	sg_init_one(&sg[1], &tmpbuf, sizeof(tmpbuf));
@@@ -513,25 -539,29 +536,28 @@@ static int rxkad_verify_packet(const st
  
  	/* continue encrypting from where we left off */
  	memcpy(&iv, call->conn->csum_iv.x, sizeof(iv));
- 	desc.tfm = call->conn->cipher;
- 	desc.info = iv.x;
- 	desc.flags = 0;
  
  	/* validate the security checksum */
 -	x = htonl(call->channel << (32 - RXRPC_CIDSHIFT));
 -	x |= sp->hdr.seq & cpu_to_be32(0x3fffffff);
 -	tmpbuf.x[0] = call->call_id;
 -	tmpbuf.x[1] = x;
 +	x = call->channel << (32 - RXRPC_CIDSHIFT);
 +	x |= sp->hdr.seq & 0x3fffffff;
 +	tmpbuf.x[0] = htonl(call->call_id);
 +	tmpbuf.x[1] = htonl(x);
  
  	sg_init_one(&sg[0], &tmpbuf, sizeof(tmpbuf));
  	sg_init_one(&sg[1], &tmpbuf, sizeof(tmpbuf));
- 	crypto_blkcipher_encrypt_iv(&desc, &sg[0], &sg[1], sizeof(tmpbuf));
+ 
+ 	skcipher_request_set_tfm(req, call->conn->cipher);
+ 	skcipher_request_set_callback(req, 0, NULL, NULL);
+ 	skcipher_request_set_crypt(req, &sg[1], &sg[0], sizeof(tmpbuf), iv.x);
+ 
+ 	crypto_skcipher_encrypt(req);
+ 	skcipher_request_zero(req);
  
  	y = ntohl(tmpbuf.x[1]);
 -	y = (y >> 16) & 0xffff;
 -	if (y == 0)
 -		y = 1; /* zero checksums are not permitted */
 +	cksum = (y >> 16) & 0xffff;
 +	if (cksum == 0)
 +		cksum = 1; /* zero checksums are not permitted */
  
 -	cksum = htons(y);
  	if (sp->hdr.cksum != cksum) {
  		*_abort_code = RXKADSEALEDINCON;
  		_leave(" = -EPROTO [csum failed]");
