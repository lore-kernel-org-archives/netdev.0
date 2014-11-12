From: Ming Liu <ming.liu@windriver.com>
Subject: Re: HELP: IPsec reordering issue
Date: Wed, 12 Nov 2014 11:29:44 +0800
Message-ID: <5462D428.7060008@windriver.com>
References: <53D9B2EE.5040002@gmail.com> <20140731062321.GA2957@gondor.apana.org.au> <53DE0772.2090106@gmail.com> <20140814084740.GA30846@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------070903090500000905060908"
Cc: <steffen.klassert@secunet.com>, <davem@davemloft.net>,
	<linux-crypto@vger.kernel.org>, <netdev@vger.kernel.org>,
	Xue Ying <ying.xue@windriver.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20140814084740.GA30846@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--------------070903090500000905060908
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit

Hi, Herbert:

I've figured out a new patch for this issue reported by me previously, 
the basic idea is adding a cryptd_flush_queue function fixing it by 
being called from softirq to flush all previous queued elements before 
processing a new one, and it works very well so far per my test,  would 
you please review it?

the best,
thank you

On 08/14/2014 04:47 PM, Herbert Xu wrote:
> On Sun, Aug 03, 2014 at 05:57:06PM +0800, Ming Liu wrote:
>> Please review this attached patch instead, the original one has a
>> problem causing the kernel crash.
> Thanks for the patch.  I think it would better to enforce ordering
> for all operations rather than treat encryptions separately from
> decryptions.  We could conceivably have more complex operations made
> up from both encryptions and decryptions that could then get
> out-of-order.
>
> It would also make the code simpler.
>
> Cheers,


--------------070903090500000905060908
Content-Type: text/x-patch;
	name="0001-crypto-aesni-intel-avoid-IPsec-re-ordering.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="0001-crypto-aesni-intel-avoid-IPsec-re-ordering.patch"

>From 5e00cd925755015d4057ded1b24fd994e507a21e Mon Sep 17 00:00:00 2001
From: Ming Liu <ming.liu@windriver.com>
Date: Wed, 12 Nov 2014 11:11:57 +0800
Subject: [PATCH] crypto: aesni-intel - avoid IPsec re-ordering

So far, the encryption/decryption are asynchronously processed in
softirq and cryptd which would result in a implicit order of data,
therefore leads IPSec stack also out of order while encapsulating
or decapsulating packets.

Consider the following scenario:

             DECRYPTION INBOUND
                      |
                      |
             +-----Packet A
             |        |
             |        |
             |     Packet B
             |        |
    (cryptd) |        | (software interrupts)
             |      ......
             |        |
             |        |
             |     Packet B(decrypted)
             |        |
             |        |
             +---> Packet A(decrypted)
                      |
                      |
             DECRYPTION OUTBOUND

Add cryptd_flush_queue function fixing it by being called from softirq
to flush all previous queued elements before processing a new one. To
prevent cryptd_flush_queue() being accessed from software interrupts,
local_bh_disable/enable needs to be relocated in several places.

Signed-off-by: Ming Liu <ming.liu@windriver.com>
---
 crypto/ablk_helper.c    |  10 ++++-
 crypto/cryptd.c         | 107 ++++++++++++++++++++++++++++++++++++++++--------
 include/crypto/cryptd.h |  13 ++++++
 3 files changed, 111 insertions(+), 19 deletions(-)

diff --git a/crypto/ablk_helper.c b/crypto/ablk_helper.c
index ffe7278..600a70f 100644
--- a/crypto/ablk_helper.c
+++ b/crypto/ablk_helper.c
@@ -70,16 +70,19 @@ int ablk_encrypt(struct ablkcipher_request *req)
 {
 	struct crypto_ablkcipher *tfm = crypto_ablkcipher_reqtfm(req);
 	struct async_helper_ctx *ctx = crypto_ablkcipher_ctx(tfm);
+	struct crypto_tfm *req_tfm = crypto_ablkcipher_tfm(
+		crypto_ablkcipher_crt(&ctx->cryptd_tfm->base)->base);
 
 	if (!may_use_simd()) {
 		struct ablkcipher_request *cryptd_req =
 			ablkcipher_request_ctx(req);
 
 		*cryptd_req = *req;
-		ablkcipher_request_set_tfm(cryptd_req, &ctx->cryptd_tfm->base);
+		cryptd_req->base.tfm = req_tfm;
 
 		return crypto_ablkcipher_encrypt(cryptd_req);
 	} else {
+		cryptd_flush_queue(req_tfm, CRYPTD_ENCRYPT);
 		return __ablk_encrypt(req);
 	}
 }
@@ -89,13 +92,15 @@ int ablk_decrypt(struct ablkcipher_request *req)
 {
 	struct crypto_ablkcipher *tfm = crypto_ablkcipher_reqtfm(req);
 	struct async_helper_ctx *ctx = crypto_ablkcipher_ctx(tfm);
+	struct crypto_tfm *req_tfm = crypto_ablkcipher_tfm(
+		crypto_ablkcipher_crt(&ctx->cryptd_tfm->base)->base);
 
 	if (!may_use_simd()) {
 		struct ablkcipher_request *cryptd_req =
 			ablkcipher_request_ctx(req);
 
 		*cryptd_req = *req;
-		ablkcipher_request_set_tfm(cryptd_req, &ctx->cryptd_tfm->base);
+		cryptd_req->base.tfm = req_tfm;
 
 		return crypto_ablkcipher_decrypt(cryptd_req);
 	} else {
@@ -105,6 +110,7 @@ int ablk_decrypt(struct ablkcipher_request *req)
 		desc.info = req->info;
 		desc.flags = 0;
 
+		cryptd_flush_queue(req_tfm, CRYPTD_DECRYPT);
 		return crypto_blkcipher_crt(desc.tfm)->decrypt(
 			&desc, req->dst, req->src, req->nbytes);
 	}
diff --git a/crypto/cryptd.c b/crypto/cryptd.c
index e592c90..0b387a1 100644
--- a/crypto/cryptd.c
+++ b/crypto/cryptd.c
@@ -119,11 +119,13 @@ static int cryptd_enqueue_request(struct cryptd_queue *queue,
 	int cpu, err;
 	struct cryptd_cpu_queue *cpu_queue;
 
+	local_bh_disable();
 	cpu = get_cpu();
 	cpu_queue = this_cpu_ptr(queue->cpu_queue);
 	err = crypto_enqueue_request(&cpu_queue->queue, request);
 	queue_work_on(cpu, kcrypto_wq, &cpu_queue->work);
 	put_cpu();
+	local_bh_enable();
 
 	return err;
 }
@@ -147,11 +149,9 @@ static void cryptd_queue_worker(struct work_struct *work)
 	preempt_disable();
 	backlog = crypto_get_backlog(&cpu_queue->queue);
 	req = crypto_dequeue_request(&cpu_queue->queue);
-	preempt_enable();
-	local_bh_enable();
 
 	if (!req)
-		return;
+		goto out;
 
 	if (backlog)
 		backlog->complete(backlog, -EINPROGRESS);
@@ -159,6 +159,9 @@ static void cryptd_queue_worker(struct work_struct *work)
 
 	if (cpu_queue->queue.qlen)
 		queue_work(kcrypto_wq, &cpu_queue->work);
+out:
+	preempt_enable();
+	local_bh_enable();
 }
 
 static inline struct cryptd_queue *cryptd_get_queue(struct crypto_tfm *tfm)
@@ -209,9 +212,7 @@ static void cryptd_blkcipher_crypt(struct ablkcipher_request *req,
 	req->base.complete = rctx->complete;
 
 out:
-	local_bh_disable();
 	rctx->complete(&req->base, err);
-	local_bh_enable();
 }
 
 static void cryptd_blkcipher_encrypt(struct crypto_async_request *req, int err)
@@ -446,9 +447,7 @@ static void cryptd_hash_init(struct crypto_async_request *req_async, int err)
 	req->base.complete = rctx->complete;
 
 out:
-	local_bh_disable();
 	rctx->complete(&req->base, err);
-	local_bh_enable();
 }
 
 static int cryptd_hash_init_enqueue(struct ahash_request *req)
@@ -471,9 +470,7 @@ static void cryptd_hash_update(struct crypto_async_request *req_async, int err)
 	req->base.complete = rctx->complete;
 
 out:
-	local_bh_disable();
 	rctx->complete(&req->base, err);
-	local_bh_enable();
 }
 
 static int cryptd_hash_update_enqueue(struct ahash_request *req)
@@ -494,9 +491,7 @@ static void cryptd_hash_final(struct crypto_async_request *req_async, int err)
 	req->base.complete = rctx->complete;
 
 out:
-	local_bh_disable();
 	rctx->complete(&req->base, err);
-	local_bh_enable();
 }
 
 static int cryptd_hash_final_enqueue(struct ahash_request *req)
@@ -517,9 +512,7 @@ static void cryptd_hash_finup(struct crypto_async_request *req_async, int err)
 	req->base.complete = rctx->complete;
 
 out:
-	local_bh_disable();
 	rctx->complete(&req->base, err);
-	local_bh_enable();
 }
 
 static int cryptd_hash_finup_enqueue(struct ahash_request *req)
@@ -546,9 +539,7 @@ static void cryptd_hash_digest(struct crypto_async_request *req_async, int err)
 	req->base.complete = rctx->complete;
 
 out:
-	local_bh_disable();
 	rctx->complete(&req->base, err);
-	local_bh_enable();
 }
 
 static int cryptd_hash_digest_enqueue(struct ahash_request *req)
@@ -641,9 +632,7 @@ static void cryptd_aead_crypt(struct aead_request *req,
 	err = crypt( req );
 	req->base.complete = rctx->complete;
 out:
-	local_bh_disable();
 	rctx->complete(&req->base, err);
-	local_bh_enable();
 }
 
 static void cryptd_aead_encrypt(struct crypto_async_request *areq, int err)
@@ -895,6 +884,90 @@ void cryptd_free_ahash(struct cryptd_ahash *tfm)
 }
 EXPORT_SYMBOL_GPL(cryptd_free_ahash);
 
+void cryptd_flush_queue(struct crypto_tfm *tfm, cryptd_type_t type)
+{
+	struct crypto_instance *inst = crypto_tfm_alg_instance(tfm);
+	struct cryptd_instance_ctx *ictx = crypto_instance_ctx(inst);
+	struct cryptd_queue *cryptd_queue = ictx->queue;
+	struct cryptd_cpu_queue *cpu_queue;
+	struct crypto_queue *queue;
+	struct crypto_async_request *req, *tmp, *backlog;
+	crypto_completion_t complete;
+	int cpu;
+	unsigned int len;
+
+	switch (type) {
+	case CRYPTD_BLKCIPHER_ENCRYPT:
+		complete = cryptd_blkcipher_encrypt;
+		break;
+	case CRYPTD_BLKCIPHER_DECRYPT:
+		complete = cryptd_blkcipher_decrypt;
+		break;
+	case CRYPTD_HASH_INIT:
+		complete = cryptd_hash_init;
+		break;
+	case CRYPTD_HASH_UPDATE:
+		complete = cryptd_hash_update;
+		break;
+	case CRYPTD_HASH_FINAL:
+		complete = cryptd_hash_final;
+		break;
+	case CRYPTD_HASH_FINUP:
+		complete = cryptd_hash_finup;
+		break;
+	case CRYPTD_HASH_DIGEST:
+		complete = cryptd_hash_digest;
+		break;
+	case CRYPTD_AEAD_ENCRYPT:
+		complete = cryptd_aead_encrypt;
+		break;
+	case CRYPTD_AEAD_DECRYPT:
+		complete = cryptd_aead_decrypt;
+		break;
+	default:
+		complete = NULL;
+	}
+
+	if (complete == NULL)
+		return;
+
+	local_bh_disable();
+	cpu = get_cpu();
+	cpu_queue = this_cpu_ptr(cryptd_queue->cpu_queue);
+	queue = &cpu_queue->queue;
+	len = queue->qlen;
+
+	if (!len)
+		goto out;
+
+	list_for_each_entry_safe(req, tmp, &queue->list, list) {
+		if (req->complete == complete) {
+			queue->qlen--;
+
+			if (queue->backlog != &queue->list) {
+				backlog = container_of(queue->backlog,
+					struct crypto_async_request, list);
+				queue->backlog = queue->backlog->next;
+			} else
+				backlog = NULL;
+
+			list_del(&req->list);
+
+			if (backlog)
+				backlog->complete(backlog, -EINPROGRESS);
+			req->complete(req, 0);
+		}
+
+		if (--len == 0)
+			goto out;
+	}
+
+out:
+	put_cpu();
+	local_bh_enable();
+}
+EXPORT_SYMBOL_GPL(cryptd_flush_queue);
+
 struct cryptd_aead *cryptd_alloc_aead(const char *alg_name,
 						  u32 type, u32 mask)
 {
diff --git a/include/crypto/cryptd.h b/include/crypto/cryptd.h
index ba98918..a63a296 100644
--- a/include/crypto/cryptd.h
+++ b/include/crypto/cryptd.h
@@ -16,6 +16,18 @@
 #include <linux/kernel.h>
 #include <crypto/hash.h>
 
+typedef enum {
+	CRYPTD_BLKCIPHER_ENCRYPT,
+	CRYPTD_BLKCIPHER_DECRYPT,
+	CRYPTD_HASH_INIT,
+	CRYPTD_HASH_UPDATE,
+	CRYPTD_HASH_FINAL,
+	CRYPTD_HASH_FINUP,
+	CRYPTD_HASH_DIGEST,
+	CRYPTD_AEAD_ENCRYPT,
+	CRYPTD_AEAD_DECRYPT,
+} cryptd_type_t;
+
 struct cryptd_ablkcipher {
 	struct crypto_ablkcipher base;
 };
@@ -48,6 +60,7 @@ struct cryptd_ahash *cryptd_alloc_ahash(const char *alg_name,
 struct crypto_shash *cryptd_ahash_child(struct cryptd_ahash *tfm);
 struct shash_desc *cryptd_shash_desc(struct ahash_request *req);
 void cryptd_free_ahash(struct cryptd_ahash *tfm);
+void cryptd_flush_queue(struct crypto_tfm *tfm, cryptd_type_t type);
 
 struct cryptd_aead {
 	struct crypto_aead base;
-- 
1.8.4.1


--------------070903090500000905060908--
