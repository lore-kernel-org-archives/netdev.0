From: Ming Liu <liu.ming50@gmail.com>
Subject: Re: HELP: IPsec reordering issue
Date: Sun, 03 Aug 2014 17:57:06 +0800
Message-ID: <53DE0772.2090106@gmail.com>
References: <53D9B2EE.5040002@gmail.com> <20140731062321.GA2957@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060405050203030105000606"
Cc: steffen.klassert@secunet.com, davem@davemloft.net,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	Xue Ying <ying.xue@windriver.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20140731062321.GA2957@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060405050203030105000606
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 07/31/2014 02:23 PM, Herbert Xu wrote:
> On Thu, Jul 31, 2014 at 11:07:26AM +0800, Ming Liu wrote:
>> And we've figure out a patch as the attached, the basic idea is just
>> queue the packets if "irq_fpu_usable()" is not usable or if there
>> are already few packets queued for decryption. Else decrypt the
>> packets.
> Yes your description makes sense and I will review your patch
> for inclusion.
Hi, Herbert:

Please review this attached patch instead, the original one has a 
problem causing the kernel crash.

the best,
thank you
>
> Thanks,


--------------060405050203030105000606
Content-Type: text/x-diff;
 name="0001-crypto-aesni-intel-avoid-encrypt-decrypt-re-ordering.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-crypto-aesni-intel-avoid-encrypt-decrypt-re-ordering.pa";
 filename*1="tch"

>From 0b3113eb2e690c3899382360f89281d6a64e8f3a Mon Sep 17 00:00:00 2001
From: Ming Liu <ming.liu@windriver.com>
Date: Sun, 3 Aug 2014 16:23:39 +0800
Subject: [PATCH] crypto: aesni-intel- avoid encrypt/decrypt re-ordering with
 debug

So far, the encrypt/decrypt are asynchronously processed in softirq and
cryptd which would result in a implicit order of data, therefore leads
IPSec stack also out of order while encapsulating/decapsulating packets.

Fix by letting encrypt/decrypt are processed only in one context for a
particular period.
---
 arch/x86/crypto/aesni-intel_glue.c | 32 ++++++++++++----------
 crypto/cryptd.c                    | 55 ++++++++++++++++++++++++++++++++++++--
 include/crypto/cryptd.h            |  3 ++-
 3 files changed, 73 insertions(+), 17 deletions(-)

diff --git a/arch/x86/crypto/aesni-intel_glue.c b/arch/x86/crypto/aesni-intel_glue.c
index 49c552c..1f66d6e 100644
--- a/arch/x86/crypto/aesni-intel_glue.c
+++ b/arch/x86/crypto/aesni-intel_glue.c
@@ -341,20 +341,22 @@ static int ablk_encrypt(struct ablkcipher_request *req)
 {
 	struct crypto_ablkcipher *tfm = crypto_ablkcipher_reqtfm(req);
 	struct async_aes_ctx *ctx = crypto_ablkcipher_ctx(tfm);
+	struct crypto_tfm *req_tfm = crypto_ablkcipher_tfm(
+		crypto_ablkcipher_crt(&ctx->cryptd_tfm->base)->base);
 
-	if (!irq_fpu_usable()) {
-		struct ablkcipher_request *cryptd_req =
-			ablkcipher_request_ctx(req);
-		memcpy(cryptd_req, req, sizeof(*req));
-		ablkcipher_request_set_tfm(cryptd_req, &ctx->cryptd_tfm->base);
-		return crypto_ablkcipher_encrypt(cryptd_req);
-	} else {
+	if (irq_fpu_usable() && !cryptd_get_encrypt_nums(req_tfm)) {
 		struct blkcipher_desc desc;
 		desc.tfm = cryptd_ablkcipher_child(ctx->cryptd_tfm);
 		desc.info = req->info;
 		desc.flags = 0;
 		return crypto_blkcipher_crt(desc.tfm)->encrypt(
 			&desc, req->dst, req->src, req->nbytes);
+	} else {
+		struct ablkcipher_request *cryptd_req =
+			ablkcipher_request_ctx(req);
+		memcpy(cryptd_req, req, sizeof(*req));
+		cryptd_req->base.tfm = req_tfm;
+		return crypto_ablkcipher_encrypt(cryptd_req);
 	}
 }
 
@@ -362,20 +364,22 @@ static int ablk_decrypt(struct ablkcipher_request *req)
 {
 	struct crypto_ablkcipher *tfm = crypto_ablkcipher_reqtfm(req);
 	struct async_aes_ctx *ctx = crypto_ablkcipher_ctx(tfm);
+	struct crypto_tfm *req_tfm = crypto_ablkcipher_tfm(
+		crypto_ablkcipher_crt(&ctx->cryptd_tfm->base)->base);
 
-	if (!irq_fpu_usable()) {
-		struct ablkcipher_request *cryptd_req =
-			ablkcipher_request_ctx(req);
-		memcpy(cryptd_req, req, sizeof(*req));
-		ablkcipher_request_set_tfm(cryptd_req, &ctx->cryptd_tfm->base);
-		return crypto_ablkcipher_decrypt(cryptd_req);
-	} else {
+	if (irq_fpu_usable() && !cryptd_get_decrypt_nums(req_tfm)) {
 		struct blkcipher_desc desc;
 		desc.tfm = cryptd_ablkcipher_child(ctx->cryptd_tfm);
 		desc.info = req->info;
 		desc.flags = 0;
 		return crypto_blkcipher_crt(desc.tfm)->decrypt(
 			&desc, req->dst, req->src, req->nbytes);
+	} else {
+		struct ablkcipher_request *cryptd_req =
+			ablkcipher_request_ctx(req);
+		memcpy(cryptd_req, req, sizeof(*req));
+		cryptd_req->base.tfm = req_tfm;
+		return crypto_ablkcipher_decrypt(cryptd_req);
 	}
 }
 
diff --git a/crypto/cryptd.c b/crypto/cryptd.c
index 6e24164..6710395 100644
--- a/crypto/cryptd.c
+++ b/crypto/cryptd.c
@@ -28,6 +28,8 @@
 struct cryptd_cpu_queue {
 	struct crypto_queue queue;
 	struct work_struct work;
+	unsigned int encrypt_nums;
+	unsigned int decrypt_nums;
 };
 
 struct cryptd_queue {
@@ -62,6 +64,8 @@ struct cryptd_hash_request_ctx {
 };
 
 static void cryptd_queue_worker(struct work_struct *work);
+static void cryptd_blkcipher_encrypt(struct crypto_async_request *req, int err);
+static void cryptd_blkcipher_decrypt(struct crypto_async_request *req, int err);
 
 static int cryptd_init_queue(struct cryptd_queue *queue,
 			     unsigned int max_cpu_qlen)
@@ -75,6 +79,8 @@ static int cryptd_init_queue(struct cryptd_queue *queue,
 	for_each_possible_cpu(cpu) {
 		cpu_queue = per_cpu_ptr(queue->cpu_queue, cpu);
 		crypto_init_queue(&cpu_queue->queue, max_cpu_qlen);
+		cpu_queue->encrypt_nums = 0;
+		cpu_queue->decrypt_nums = 0;
 		INIT_WORK(&cpu_queue->work, cryptd_queue_worker);
 	}
 	return 0;
@@ -101,6 +107,10 @@ static int cryptd_enqueue_request(struct cryptd_queue *queue,
 	cpu = get_cpu();
 	cpu_queue = this_cpu_ptr(queue->cpu_queue);
 	err = crypto_enqueue_request(&cpu_queue->queue, request);
+	if ((err != -EBUSY) && (request->complete == cryptd_blkcipher_encrypt))
+		cpu_queue->encrypt_nums++;
+	if ((err != -EBUSY) && (request->complete == cryptd_blkcipher_decrypt))
+		cpu_queue->decrypt_nums++;
 	queue_work_on(cpu, kcrypto_wq, &cpu_queue->work);
 	put_cpu();
 
@@ -171,10 +181,14 @@ static void cryptd_blkcipher_crypt(struct ablkcipher_request *req,
 						struct scatterlist *src,
 						unsigned int len))
 {
-	struct cryptd_blkcipher_request_ctx *rctx;
+	struct cryptd_blkcipher_request_ctx *rctx = ablkcipher_request_ctx(req);
+	struct crypto_ablkcipher *tfm = crypto_ablkcipher_reqtfm(req);
 	struct blkcipher_desc desc;
+	struct cryptd_queue *queue;
+	struct cryptd_cpu_queue *cpu_queue;
+	crypto_completion_t complete = req->base.complete;
 
-	rctx = ablkcipher_request_ctx(req);
+	queue = cryptd_get_queue(crypto_ablkcipher_tfm(tfm));
 
 	if (unlikely(err == -EINPROGRESS))
 		goto out;
@@ -190,6 +204,13 @@ static void cryptd_blkcipher_crypt(struct ablkcipher_request *req,
 out:
 	local_bh_disable();
 	rctx->complete(&req->base, err);
+	preempt_disable();
+	cpu_queue = this_cpu_ptr(queue->cpu_queue);
+	if ((complete == cryptd_blkcipher_encrypt) && cpu_queue->encrypt_nums)
+		cpu_queue->encrypt_nums--;
+	if ((complete == cryptd_blkcipher_decrypt) && cpu_queue->decrypt_nums)
+		cpu_queue->decrypt_nums--;
+	preempt_enable();
 	local_bh_enable();
 }
 
@@ -729,6 +750,36 @@ void cryptd_free_ahash(struct cryptd_ahash *tfm)
 }
 EXPORT_SYMBOL_GPL(cryptd_free_ahash);
 
+unsigned int cryptd_get_encrypt_nums(struct crypto_tfm *tfm)
+{
+	struct cryptd_queue *queue = cryptd_get_queue(tfm);
+	struct cryptd_cpu_queue *cpu_queue;
+	unsigned int nums;
+
+	preempt_disable();
+	cpu_queue = this_cpu_ptr(queue->cpu_queue);
+	nums = cpu_queue->encrypt_nums;
+	preempt_enable();
+
+	return nums;
+}
+EXPORT_SYMBOL_GPL(cryptd_get_encrypt_nums);
+
+unsigned int cryptd_get_decrypt_nums(struct crypto_tfm *tfm)
+{
+	struct cryptd_queue *queue = cryptd_get_queue(tfm);
+	struct cryptd_cpu_queue *cpu_queue;
+	unsigned int nums;
+
+	preempt_disable();
+	cpu_queue = this_cpu_ptr(queue->cpu_queue);
+	nums = cpu_queue->decrypt_nums;
+	preempt_enable();
+
+	return nums;
+}
+EXPORT_SYMBOL_GPL(cryptd_get_decrypt_nums);
+
 static int __init cryptd_init(void)
 {
 	int err;
diff --git a/include/crypto/cryptd.h b/include/crypto/cryptd.h
index 1c96b25..cacc717 100644
--- a/include/crypto/cryptd.h
+++ b/include/crypto/cryptd.h
@@ -41,5 +41,6 @@ struct cryptd_ahash *cryptd_alloc_ahash(const char *alg_name,
 struct crypto_shash *cryptd_ahash_child(struct cryptd_ahash *tfm);
 struct shash_desc *cryptd_shash_desc(struct ahash_request *req);
 void cryptd_free_ahash(struct cryptd_ahash *tfm);
-
+unsigned int cryptd_get_encrypt_nums(struct crypto_tfm *tfm);
+unsigned int cryptd_get_decrypt_nums(struct crypto_tfm *tfm);
 #endif
-- 
1.8.5.2.233.g932f7e4


--------------060405050203030105000606--
