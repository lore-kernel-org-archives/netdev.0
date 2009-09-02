From: "Brad Bosch" <bradbosch@comcast.net>
Subject: Re: Crypto oops in async_chainiv_do_postponed
Date: Wed, 2 Sep 2009 09:23:39 -0500
Message-ID: <19102.32747.302331.693874@waldo.imnotcreative.homeip.net>
References: <19095.1264.682820.125602@waldo.imnotcreative.homeip.net>
	<20090829104606.GA13141@gondor.apana.org.au>
	<19099.63038.425414.514063@waldo.imnotcreative.homeip.net>
	<20090831220459.GA15713@gondor.apana.org.au>
	<19101.16628.347039.619378@waldo.imnotcreative.homeip.net>
	<20090901221721.GA1964@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	offbase0@gmail.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20090901221721.GA1964@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(resent due to bounce notification for vger)
Herbert Xu writes:
 > On Tue, Sep 01, 2009 at 10:42:44AM -0500, Brad Bosch wrote:
 > > 
 > > Now, ctx-err may be used by both async_chainiv_postpone_request to
 > > store the return value from skcipher_enqueue_givcrypt and by
 > > async_chainiv_givencrypt_tail to store the return value from
 > > crypto_ablkcipher_encrypt at the same time.  This can cause the
 > > calling function to think async_chainiv_givencrypt has completed it's
 > > work, when in fact, the work was defered.
 > 
 > async_chainiv_postpone_request never touches ctx->err unless
 > it can obtain the INUSE bit lock.  On the other hand, the normal
 > patch async_chainiv_givencrypt_tail never relinquishes the INUSE
 > bit until it is finisehd with ctx->err.

But the above statements are not adequate to demonstrate that your use
of the INUSE flag always prevents a condition where both
async_chainiv_postpone_request and async_chainiv_givencrypt_tail
operate on the same ctx at the same time.  The flaw in your logic may
be that async_chainiv_schedule_work does not have solid assurance that
it's thread is the one that holds the INUSE bit when it calls
clear_bit.

I seem to have trouble getting the details right in describing a path
that causes both uses of ctx->err to happen at the same time.  Let me
try again.

Assume the worker thread is executing between the dequeue in
async_chainiv_do_postponed and the clear_bit call in
async_chainiv_schedule_work.  Further assume that we are processing
the last item on the queue so durring this time, ctx->queue.qlen =
0.

Meanwhile, three threads enter async_chainiv_givencrypt for the same
ctx at about the same time.

Thread one calls test_and_set_bit which returns 1 and calls
async_cahiniv_postpone_request but suppose it has not yet enqueued.
Now INUSE is set and qlen=0.

Next, the worker thread calls clear_bit in async_chainiv_schedule_work
but it is interrupted before it can call test_and_set_bit.  Now INUSE
is clear and qlen=0

The test_and_set_bit in thread two is called at this moment and
returns 0 and then calls async_chainiv_givencrypt_tail.  Now INUSE is
set and qlen=0.

Thread one now locks the ctx and calls skcipher_enqueue_givcrypt and
unlocks.  Now INUSE is set and qlen=1.

Thread three calls test_and_set_bit which returns 1 and then it clears
INUSE since qlen=1 and it calls postpone with INUSE clear and qlen=1

Now thread three will use ctx->err to hold the return value of
skcipher_enqueue_givcrypt at the same time as thread two uses ctx->err
to hold the return value of crypto_ablkcipher_encrypt!

Did I make a mistake above?  I suspect more bad things can happen as
well in this scenario, but I'm just focusing on the use of ctx->err here.

 > 
 > Please let me know whether it actually fixes your problem though
 > so I can get this upstream.

Unfortunately, the offset problem is not easily reproduced with our
application, so testing long enough to be sure the problem is fixed
(assuming that it was indeed the cause of the oops) may not be
practical.  All I can say at the moment is that I have not seen the
crash since I introduced the two patches I sent you.

Thanks for taking the time to discuss this!

--Brad
