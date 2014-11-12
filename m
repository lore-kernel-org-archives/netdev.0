From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] crypto: aesni-intel - avoid IPsec re-ordering
Date: Wed, 12 Nov 2014 09:41:38 +0100
Message-ID: <20141112084138.GL6390@secunet.com>
References: <1415771371-30774-1-git-send-email-ming.liu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <herbert@gondor.apana.org.au>, <davem@davemloft.net>,
	<ying.xue@windriver.com>, <linux-crypto@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Ming Liu <ming.liu@windriver.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1415771371-30774-1-git-send-email-ming.liu@windriver.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 12, 2014 at 01:49:31PM +0800, Ming Liu wrote:
> So far, the encryption/decryption are asynchronously processed in
> softirq and cryptd which would result in a implicit order of data,
> therefore leads IPSec stack also out of order while encapsulating
> or decapsulating packets.
> 
> Consider the following scenario:
> 
>              DECRYPTION INBOUND
>                       |
>                       |
>              +-----Packet A
>              |        |
>              |        |
>              |     Packet B
>              |        |
>     (cryptd) |        | (software interrupts)
>              |      ......
>              |        |
>              |        |
>              |     Packet B(decrypted)
>              |        |
>              |        |
>              +---> Packet A(decrypted)
>                       |
>                       |
>              DECRYPTION OUTBOUND
> 
> Add cryptd_flush_queue function fixing it by being called from softirq
> to flush all previous queued elements before processing a new one. To
> prevent cryptd_flush_queue() being accessed from software interrupts,
> local_bh_disable/enable needs to be relocated in several places.
> 
> Signed-off-by: Ming Liu <ming.liu@windriver.com>
> ---
> I was told that I need resend this patch with git, so here it is:
> 
> I've figured out a new patch for this issue reported by me previously,
> the basic idea is adding a cryptd_flush_queue function fixing it by
> being called from softirq to flush all previous queued elements
> before processing a new one, and it works very well so far per my test.

I doubt that this approach can work. The cryptd encrypt/decrypt functions
assume to be called from a workqueue worker, they can't be called from
atomic context.

Can't we just use cryptd unconditionally to fix this reordering problem?

> 
>  crypto/ablk_helper.c    |  10 ++++-
>  crypto/cryptd.c         | 107 ++++++++++++++++++++++++++++++++++++++++--------
>  include/crypto/cryptd.h |  13 ++++++
>  3 files changed, 111 insertions(+), 19 deletions(-)
> 
> diff --git a/crypto/ablk_helper.c b/crypto/ablk_helper.c
> index ffe7278..600a70f 100644
> --- a/crypto/ablk_helper.c
> +++ b/crypto/ablk_helper.c
> @@ -70,16 +70,19 @@ int ablk_encrypt(struct ablkcipher_request *req)
>  {
>  	struct crypto_ablkcipher *tfm = crypto_ablkcipher_reqtfm(req);
>  	struct async_helper_ctx *ctx = crypto_ablkcipher_ctx(tfm);
> +	struct crypto_tfm *req_tfm = crypto_ablkcipher_tfm(
> +		crypto_ablkcipher_crt(&ctx->cryptd_tfm->base)->base);
>  
>  	if (!may_use_simd()) {
>  		struct ablkcipher_request *cryptd_req =
>  			ablkcipher_request_ctx(req);
>  
>  		*cryptd_req = *req;
> -		ablkcipher_request_set_tfm(cryptd_req, &ctx->cryptd_tfm->base);
> +		cryptd_req->base.tfm = req_tfm;
>  
>  		return crypto_ablkcipher_encrypt(cryptd_req);
>  	} else {
> +		cryptd_flush_queue(req_tfm, CRYPTD_ENCRYPT);

Where is CRYPTD_ENCRYPT defined?
This does not even compile when applied to the cryptodev tree.

>  		return __ablk_encrypt(req);
>  	}
>  }
> @@ -89,13 +92,15 @@ int ablk_decrypt(struct ablkcipher_request *req)
>  {
>  	struct crypto_ablkcipher *tfm = crypto_ablkcipher_reqtfm(req);
>  	struct async_helper_ctx *ctx = crypto_ablkcipher_ctx(tfm);
> +	struct crypto_tfm *req_tfm = crypto_ablkcipher_tfm(
> +		crypto_ablkcipher_crt(&ctx->cryptd_tfm->base)->base);
>  
>  	if (!may_use_simd()) {
>  		struct ablkcipher_request *cryptd_req =
>  			ablkcipher_request_ctx(req);
>  
>  		*cryptd_req = *req;
> -		ablkcipher_request_set_tfm(cryptd_req, &ctx->cryptd_tfm->base);
> +		cryptd_req->base.tfm = req_tfm;
>  
>  		return crypto_ablkcipher_decrypt(cryptd_req);
>  	} else {
> @@ -105,6 +110,7 @@ int ablk_decrypt(struct ablkcipher_request *req)
>  		desc.info = req->info;
>  		desc.flags = 0;
>  
> +		cryptd_flush_queue(req_tfm, CRYPTD_DECRYPT);

Same here.

>  		return crypto_blkcipher_crt(desc.tfm)->decrypt(
>  			&desc, req->dst, req->src, req->nbytes);
>  	}
> diff --git a/crypto/cryptd.c b/crypto/cryptd.c
> index e592c90..0b387a1 100644
> --- a/crypto/cryptd.c
> +++ b/crypto/cryptd.c
> @@ -119,11 +119,13 @@ static int cryptd_enqueue_request(struct cryptd_queue *queue,
>  	int cpu, err;
>  	struct cryptd_cpu_queue *cpu_queue;
>  
> +	local_bh_disable();
>  	cpu = get_cpu();
>  	cpu_queue = this_cpu_ptr(queue->cpu_queue);
>  	err = crypto_enqueue_request(&cpu_queue->queue, request);
>  	queue_work_on(cpu, kcrypto_wq, &cpu_queue->work);
>  	put_cpu();
> +	local_bh_enable();
>  
>  	return err;
>  }
> @@ -147,11 +149,9 @@ static void cryptd_queue_worker(struct work_struct *work)
>  	preempt_disable();
>  	backlog = crypto_get_backlog(&cpu_queue->queue);
>  	req = crypto_dequeue_request(&cpu_queue->queue);
> -	preempt_enable();
> -	local_bh_enable();

Everything below the local_bh_enable() should not run in atomic context
as the subsequent functions may set the CRYPTO_TFM_REQ_MAY_SLEEP flag.

>  
>  	if (!req)
> -		return;
> +		goto out;
>  
>  	if (backlog)
>  		backlog->complete(backlog, -EINPROGRESS);
> @@ -159,6 +159,9 @@ static void cryptd_queue_worker(struct work_struct *work)
>  
>  	if (cpu_queue->queue.qlen)
>  		queue_work(kcrypto_wq, &cpu_queue->work);
> +out:
> +	preempt_enable();
> +	local_bh_enable();
>  }

...

>  
> +void cryptd_flush_queue(struct crypto_tfm *tfm, cryptd_type_t type)
> +{
> +	struct crypto_instance *inst = crypto_tfm_alg_instance(tfm);
> +	struct cryptd_instance_ctx *ictx = crypto_instance_ctx(inst);
> +	struct cryptd_queue *cryptd_queue = ictx->queue;
> +	struct cryptd_cpu_queue *cpu_queue;
> +	struct crypto_queue *queue;
> +	struct crypto_async_request *req, *tmp, *backlog;
> +	crypto_completion_t complete;
> +	int cpu;
> +	unsigned int len;
> +
> +	switch (type) {
> +	case CRYPTD_BLKCIPHER_ENCRYPT:
> +		complete = cryptd_blkcipher_encrypt;
> +		break;
> +	case CRYPTD_BLKCIPHER_DECRYPT:
> +		complete = cryptd_blkcipher_decrypt;
> +		break;
> +	case CRYPTD_HASH_INIT:
> +		complete = cryptd_hash_init;
> +		break;
> +	case CRYPTD_HASH_UPDATE:
> +		complete = cryptd_hash_update;
> +		break;
> +	case CRYPTD_HASH_FINAL:
> +		complete = cryptd_hash_final;
> +		break;
> +	case CRYPTD_HASH_FINUP:
> +		complete = cryptd_hash_finup;
> +		break;
> +	case CRYPTD_HASH_DIGEST:
> +		complete = cryptd_hash_digest;
> +		break;
> +	case CRYPTD_AEAD_ENCRYPT:
> +		complete = cryptd_aead_encrypt;
> +		break;
> +	case CRYPTD_AEAD_DECRYPT:
> +		complete = cryptd_aead_decrypt;
> +		break;
> +	default:
> +		complete = NULL;
> +	}
> +
> +	if (complete == NULL)
> +		return;
> +
> +	local_bh_disable();
> +	cpu = get_cpu();
> +	cpu_queue = this_cpu_ptr(cryptd_queue->cpu_queue);
> +	queue = &cpu_queue->queue;
> +	len = queue->qlen;
> +
> +	if (!len)
> +		goto out;
> +
> +	list_for_each_entry_safe(req, tmp, &queue->list, list) {
> +		if (req->complete == complete) {
> +			queue->qlen--;
> +
> +			if (queue->backlog != &queue->list) {
> +				backlog = container_of(queue->backlog,
> +					struct crypto_async_request, list);
> +				queue->backlog = queue->backlog->next;
> +			} else
> +				backlog = NULL;
> +
> +			list_del(&req->list);
> +
> +			if (backlog)
> +				backlog->complete(backlog, -EINPROGRESS);
> +			req->complete(req, 0);

Same here, the complete function can not run in atomic context.

Also, this can not ensure that the request is finalized.
Subsequent algorithms may run asynchronously too, so this
does not fix the reordering problem completely.
