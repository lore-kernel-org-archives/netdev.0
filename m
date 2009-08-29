From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Crypto oops in async_chainiv_do_postponed
Date: Sat, 29 Aug 2009 20:46:06 +1000
Message-ID: <20090829104606.GA13141@gondor.apana.org.au>
References: <19095.1264.682820.125602@waldo.imnotcreative.homeip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Brad Bosch <bradbosch@comcast.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <19095.1264.682820.125602@waldo.imnotcreative.homeip.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Brad:

On Thu, Aug 27, 2009 at 05:13:04PM -0500, Brad Bosch wrote:
> 
> I seem to have found a bug in chainiv.c.  The following oops occured
> while using blowfish and hmac-sha with UDP.  The patch (against
> 2.6.27.30) after the oops output below is an completely untested
> possible fix.  We will be testing this fix starting tomorrow.

Thanks for the detailed analysis and patch!

> The null dereference occurs when subreq is dereferenced in
> async_chainiv_do_postponed().  My guess is that the
> skcipher_givcrypt_request block has been freed and subsequently
> overwritten by the time the postponed request is processed.  This
> could happen if chainiv_givencrypt() returns anything other than
> -EINPROGRESS after postponing the request.  From what I can see, this
> could indeed happen since the same err field in async_chainiv_ctx is
> used both when the request is postponed and also when it is later
> processed by the worker thread.  Neither the lock, nor the
> CHAINIV_STATE_INUSE bit in ctx->state will prevent this race which
> results in the -EINPROGRESS err being overwritten between the time it
> is placed in ctx->err in async_chainiv_postpone_request() and when it
> is read back out in async_chainiv_schedule_work().  I am curious why
> this method of returning the error code was used in the first place.

Actually I think the problem is much less subtle than that :)

The problem is that whenever crypto_dequeue_request returns NULL,
chainiv will never see the NULL pointer because we end up converting
the pointer to skcipher_givcrypt_request which would have the value
(NULL - off) where off is non-zero.

Please let me know if this patch fixes the crash for you.

commit 0c7d400fafaeab6014504a6a6249f01bac7f7db4
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Sat Aug 29 20:44:04 2009 +1000

    crypto: skcipher - Fix skcipher_dequeue_givcrypt NULL test
    
    As struct skcipher_givcrypt_request includes struct crypto_request
    at a non-zero offset, testing for NULL after converting the pointer
    returned by crypto_dequeue_request does not work.  This can result
    in IPsec crashes when the queue is depleted.
    
    This patch fixes it by doing the pointer conversion only when the
    return value is non-NULL.  In particular, we create a new function
    __crypto_dequeue_request that does the pointer conversion.
    
    Reported-by: Brad Bosch <bradbosch@comcast.net>
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/crypto/algapi.c b/crypto/algapi.c
index 56c62e2..df0863d 100644
--- a/crypto/algapi.c
+++ b/crypto/algapi.c
@@ -692,7 +692,7 @@ out:
 }
 EXPORT_SYMBOL_GPL(crypto_enqueue_request);
 
-struct crypto_async_request *crypto_dequeue_request(struct crypto_queue *queue)
+void *__crypto_dequeue_request(struct crypto_queue *queue, unsigned int offset)
 {
 	struct list_head *request;
 
@@ -707,7 +707,14 @@ struct crypto_async_request *crypto_dequeue_request(struct crypto_queue *queue)
 	request = queue->list.next;
 	list_del(request);
 
-	return list_entry(request, struct crypto_async_request, list);
+	return (char *)list_entry(request, struct crypto_async_request, list) -
+	       offset;
+}
+EXPORT_SYMBOL_GPL(__crypto_dequeue_request);
+
+struct crypto_async_request *crypto_dequeue_request(struct crypto_queue *queue)
+{
+	return __crypto_dequeue_request(queue, 0);
 }
 EXPORT_SYMBOL_GPL(crypto_dequeue_request);
 
diff --git a/include/crypto/algapi.h b/include/crypto/algapi.h
index 0105454..5a2bd1c 100644
--- a/include/crypto/algapi.h
+++ b/include/crypto/algapi.h
@@ -137,6 +137,7 @@ struct crypto_instance *crypto_alloc_instance(const char *name,
 void crypto_init_queue(struct crypto_queue *queue, unsigned int max_qlen);
 int crypto_enqueue_request(struct crypto_queue *queue,
 			   struct crypto_async_request *request);
+void *__crypto_dequeue_request(struct crypto_queue *queue, unsigned int offset);
 struct crypto_async_request *crypto_dequeue_request(struct crypto_queue *queue);
 int crypto_tfm_in_queue(struct crypto_queue *queue, struct crypto_tfm *tfm);
 
diff --git a/include/crypto/internal/skcipher.h b/include/crypto/internal/skcipher.h
index 2ba42cd..3a748a6 100644
--- a/include/crypto/internal/skcipher.h
+++ b/include/crypto/internal/skcipher.h
@@ -79,8 +79,8 @@ static inline int skcipher_enqueue_givcrypt(
 static inline struct skcipher_givcrypt_request *skcipher_dequeue_givcrypt(
 	struct crypto_queue *queue)
 {
-	return container_of(ablkcipher_dequeue_request(queue),
-			    struct skcipher_givcrypt_request, creq);
+	return __crypto_dequeue_request(
+		queue, offsetof(struct skcipher_givcrypt_request, creq.base));
 }
 
 static inline void *skcipher_givcrypt_reqctx(

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
