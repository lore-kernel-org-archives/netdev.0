From: Tadeusz Struk <tadeusz.struk@intel.com>
Subject: [PATCH v2 net-next] crypto: algif - explicitly mark end of data
Date: Wed, 01 Apr 2015 13:53:06 -0700
Message-ID: <20150401205305.22123.71178.stgit@tstruk-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-crypto@vger.kernel.org,
	herbert@gondor.apana.org.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:34226 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752220AbbDAUzy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2015 16:55:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the TX sgl is expanded we need to explicitly mark end of data
at the last buffer that contains data.

Changes in v2
 - use type 'bool' and true/false for 'mark'.

Signed-off-by: Tadeusz Struk <tadeusz.struk@intel.com>
---
 crypto/algif_skcipher.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/crypto/algif_skcipher.c b/crypto/algif_skcipher.c
index 8276f21..5eff93f 100644
--- a/crypto/algif_skcipher.c
+++ b/crypto/algif_skcipher.c
@@ -509,11 +509,11 @@ static int skcipher_recvmsg_async(struct socket *sock, struct msghdr *msg,
 	struct skcipher_async_req *sreq;
 	struct ablkcipher_request *req;
 	struct skcipher_async_rsgl *last_rsgl = NULL;
-	unsigned int len = 0, tx_nents = skcipher_all_sg_nents(ctx);
+	unsigned int txbufs = 0, len = 0, tx_nents = skcipher_all_sg_nents(ctx);
 	unsigned int reqlen = sizeof(struct skcipher_async_req) +
 				GET_REQ_SIZE(ctx) + GET_IV_SIZE(ctx);
-	int i = 0;
 	int err = -ENOMEM;
+	bool mark = false;
 
 	lock_sock(sk);
 	req = kmalloc(reqlen, GFP_KERNEL);
@@ -555,7 +555,7 @@ static int skcipher_recvmsg_async(struct socket *sock, struct msghdr *msg,
 			     iov_iter_count(&msg->msg_iter));
 		used = min_t(unsigned long, used, sg->length);
 
-		if (i == tx_nents) {
+		if (txbufs == tx_nents) {
 			struct scatterlist *tmp;
 			int x;
 			/* Ran out of tx slots in async request
@@ -573,10 +573,11 @@ static int skcipher_recvmsg_async(struct socket *sock, struct msghdr *msg,
 			kfree(sreq->tsg);
 			sreq->tsg = tmp;
 			tx_nents *= 2;
+			mark = true;
 		}
 		/* Need to take over the tx sgl from ctx
 		 * to the asynch req - these sgls will be freed later */
-		sg_set_page(sreq->tsg + i++, sg_page(sg), sg->length,
+		sg_set_page(sreq->tsg + txbufs++, sg_page(sg), sg->length,
 			    sg->offset);
 
 		if (list_empty(&sreq->list)) {
@@ -604,6 +605,9 @@ static int skcipher_recvmsg_async(struct socket *sock, struct msghdr *msg,
 		iov_iter_advance(&msg->msg_iter, used);
 	}
 
+	if (mark)
+		sg_mark_end(sreq->tsg + txbufs - 1);
+
 	ablkcipher_request_set_crypt(req, sreq->tsg, sreq->first_sgl.sgl.sg,
 				     len, sreq->iv);
 	err = ctx->enc ? crypto_ablkcipher_encrypt(req) :
