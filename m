From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Crypto oops in async_chainiv_do_postponed
Date: Thu, 3 Sep 2009 11:53:44 +1000
Message-ID: <20090903015344.GA18313@gondor.apana.org.au>
References: <19095.1264.682820.125602@waldo.imnotcreative.homeip.net> <20090829104606.GA13141@gondor.apana.org.au> <19099.63038.425414.514063@waldo.imnotcreative.homeip.net> <20090831220459.GA15713@gondor.apana.org.au> <19101.16628.347039.619378@waldo.imnotcreative.homeip.net> <20090901221721.GA1964@gondor.apana.org.au> <19102.31846.180030.843571@waldo.imnotcreative.homeip.net> <20090902215712.GA16941@gondor.apana.org.au> <19103.1061.50828.809996@waldo.imnotcreative.homeip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	offbase0@gmail.com
To: Brad Bosch <bradbosch@comcast.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <19103.1061.50828.809996@waldo.imnotcreative.homeip.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 02, 2009 at 06:47:49PM -0500, Brad Bosch wrote:
>
> Assume the worker thread is executing between the dequeue in
> async_chainiv_do_postponed and the clear_bit call in
> async_chainiv_schedule_work.  Further assume that we are processing
> the last item on the queue so durring this time, ctx->queue.qlen =
> 0.  **INUSE is still set at this point.
> 
> Meanwhile, three threads enter async_chainiv_givencrypt for the same
> ctx at about the same time.
> 
> Thread one calls test_and_set_bit which returns 1 and calls
> async_cahiniv_postpone_request but suppose it has not yet enqueued.
> Now INUSE is set and qlen=0.
> 
> Next, the worker thread calls clear_bit in async_chainiv_schedule_work
> but it is interrupted before it can call test_and_set_bit.  Now INUSE
> is clear and qlen=0
> 
> The test_and_set_bit in thread two is called at this moment and
> returns 0 and then calls async_chainiv_givencrypt_tail.  Now INUSE is
> set and qlen=0.
> 
> Thread one now locks the ctx and calls skcipher_enqueue_givcrypt and
> unlocks.  Now INUSE is set and qlen=1.
> 
> Thread three calls test_and_set_bit which returns 1 and then it clears
> INUSE since qlen=1 and it calls postpone with INUSE clear and qlen=1

How can thread three clear INUSE if test_and_set_bit returned 1?
If thread three sees it set then it will postpone.  It can only
clear it if it was not set originally.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
