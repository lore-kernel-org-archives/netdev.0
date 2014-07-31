From: Ming Liu <liu.ming50@gmail.com>
Subject: HELP: IPsec reordering issue
Date: Thu, 31 Jul 2014 11:07:26 +0800
Message-ID: <53D9B2EE.5040002@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040108030600040004000600"
Cc: herbert@gondor.apana.org.au, Xue Ying <ying.xue@windriver.com>
To: steffen.klassert@secunet.com, davem@davemloft.net,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040108030600040004000600
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi, all:

I encountered a IPsec packets reordering issue, following is the setup 
and scenario

     There is a IPSec IKEv1 tunnel between B & C
     The traffic is UDP from C to A @ 40 mbps
     Packets are coming in order at B but leaving out of order towards A
     If IPSec is disabled between B & C, there is no packet reordering.

The input and output of B is same physical interface but separated by 
two VLANs, and we have directed all our network interrupts to one core.

As per our analysis we are suspecting below is the root cause of the 
problem.
All the packets which are out of order have got -EINPROGRESS error in 
below part of the code.

File: net/ipv4/esp4.c: function esp_input
.....
   aead_request_set_callback(req, 0, esp_input_done, skb);
   aead_request_set_crypt(req, sg, sg, elen, iv);
   aead_request_set_assoc(req, asg, sizeof(*esph));

    err = crypto_aead_decrypt(req);
    if (err == -EINPROGRESS)
         goto out;

    err = esp_input_done2(skb, err);
.....

Below is the place where the packets are either decrypted immediately or 
queue for later decryption.

static int ablk_decrypt(struct ablkcipher_request *req)
{
     struct crypto_ablkcipher *tfm = crypto_ablkcipher_reqtfm(req);
     struct async_aes_ctx *ctx = crypto_ablkcipher_ctx(tfm);

     if (!irq_fpu_usable()) {
         struct ablkcipher_request *cryptd_req =
             ablkcipher_request_ctx(req);
         memcpy(cryptd_req, req, sizeof(*req));
         ablkcipher_request_set_tfm(cryptd_req, &ctx->cryptd_tfm->base);
         return crypto_ablkcipher_decrypt(cryptd_req);
     } else {
         struct blkcipher_desc desc;
         desc.tfm = cryptd_ablkcipher_child(ctx->cryptd_tfm);
         desc.info = req->info;
         desc.flags = 0;
         return crypto_blkcipher_crt(desc.tfm)->decrypt(
             &desc, req->dst, req->src, req->nbytes);
     }
}

Now the problem scenario is, if a packet came for decryption and 
"irq_fpu_usable()" is not usable, then it will be queued for later 
decryption and crypto_aead_decrypt will be reuturned with "-EINPROGRESS" 
error. When the packets are in queue, if some more packets came and 
"irq_fpu_usable()" is usable then those packets will be decrypted before 
the queued packets and queued packets will get out of order.

And we've figure out a patch as the attached, the basic idea is just 
queue the packets if "irq_fpu_usable()" is not usable or if there are 
already few packets queued for decryption. Else decrypt the packets.

Could anybody tell if this is a appropriate fix? Or is this reordering 
thing a real probelm? 'cause I know the IPsec doesn't guarantee order at 
all. Appreciate it very much!

the best,
thank you



--------------040108030600040004000600
Content-Type: text/x-diff;
 name="0001-crypto-aesni-intel-avoid-encrypt-decrypt-re.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-crypto-aesni-intel-avoid-encrypt-decrypt-re.patch"

>From eb0fe7074c61b4e57456c578db897928eb951db9 Mon Sep 17 00:00:00 2001
From: Ming Liu <liu.ming50@gmail.com>
Date: Thu, 31 Jul 2014 09:11:51 +0800
Subject: [PATCH] crypto: aesni-intel - avoid encrypt/decrypt re-ordering on
 particular cpu

So far, the encrypt/decrypt are asynchronously processed in softirq and
cryptd which would result in a implicit order of data, therefore leads
IPSec stack also out of order while encapsulating/decapsulating packets.

Fix by letting encrypt/decrypt are processed only in one context for a
particular period.

Signed-off-by: Ming Liu <liu.ming50@gmail.com>
---
 arch/x86/crypto/aesni-intel_glue.c | 32 ++++++++++++++++-------------
 crypto/cryptd.c                    | 42 ++++++++++++++++++++++++++++++++++++--
 include/crypto/cryptd.h            |  3 ++-
 3 files changed, 60 insertions(+), 17 deletions(-)

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
index 6e24164..0175d1a 100644
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
 
@@ -171,10 +181,15 @@ static void cryptd_blkcipher_crypt(struct ablkcipher_request *req,
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
+	int cpu;
 
-	rctx = ablkcipher_request_ctx(req);
+	queue = cryptd_get_queue(crypto_ablkcipher_tfm(tfm));
 
 	if (unlikely(err == -EINPROGRESS))
 		goto out;
@@ -190,6 +205,13 @@ static void cryptd_blkcipher_crypt(struct ablkcipher_request *req,
 out:
 	local_bh_disable();
 	rctx->complete(&req->base, err);
+	cpu = get_cpu();
+	cpu_queue = this_cpu_ptr(queue->cpu_queue);
+	if ((complete == cryptd_blkcipher_encrypt) && cpu_queue->encrypt_nums)
+		cpu_queue->encrypt_nums--;
+	if ((complete == cryptd_blkcipher_decrypt) && cpu_queue->decrypt_nums)
+		cpu_queue->decrypt_nums--;
+	put_cpu();
 	local_bh_enable();
 }
 
@@ -729,6 +751,22 @@ void cryptd_free_ahash(struct cryptd_ahash *tfm)
 }
 EXPORT_SYMBOL_GPL(cryptd_free_ahash);
 
+unsigned int cryptd_get_encrypt_nums(struct crypto_tfm *tfm)
+{
+	struct cryptd_queue *queue = cryptd_get_queue(tfm);
+	struct cryptd_cpu_queue *cpu_queue = this_cpu_ptr(queue->cpu_queue);
+	return cpu_queue->encrypt_nums;
+}
+EXPORT_SYMBOL_GPL(cryptd_get_encrypt_nums);
+
+unsigned int cryptd_get_decrypt_nums(struct crypto_tfm *tfm)
+{
+        struct cryptd_queue *queue = cryptd_get_queue(tfm);
+        struct cryptd_cpu_queue *cpu_queue = this_cpu_ptr(queue->cpu_queue);
+        return cpu_queue->decrypt_nums;
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


--------------040108030600040004000600--
