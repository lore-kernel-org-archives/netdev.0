From: "Brad Bosch" <bradbosch@comcast.net>
Subject: Re: Crypto oops in async_chainiv_do_postponed
Date: Wed, 2 Sep 2009 18:47:49 -0500
Message-ID: <19103.1061.50828.809996@waldo.imnotcreative.homeip.net>
References: <19095.1264.682820.125602@waldo.imnotcreative.homeip.net>
	<20090829104606.GA13141@gondor.apana.org.au>
	<19099.63038.425414.514063@waldo.imnotcreative.homeip.net>
	<20090831220459.GA15713@gondor.apana.org.au>
	<19101.16628.347039.619378@waldo.imnotcreative.homeip.net>
	<20090901221721.GA1964@gondor.apana.org.au>
	<19102.31846.180030.843571@waldo.imnotcreative.homeip.net>
	<20090902215712.GA16941@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Brad Bosch <bradbosch@comcast.net>, linux-crypto@vger.kernel.org,
	netdev@vger.kernel.org, offbase0@gmail.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:37648
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753826AbZIBXru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 19:47:50 -0400
In-Reply-To: <20090902215712.GA16941@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu writes:
 > On Wed, Sep 02, 2009 at 09:08:38AM -0500, Brad Bosch wrote:
 > > 
 > > Assume the worker thread is executing between the dequeue in
 > > async_chainiv_do_postponed and the clear_bit call in
 > > async_chainiv_schedule_work.  Further assume that we are processing
 > 
 > It cannot.  The worker thread can only execute when it owns
 > the INUSE bit.  In that case do_postponed will never call the
 > schedule_work function.

In the example I cited (one entry in the queue when the worker
function starts), async_chainiv_schedule_work is indeed executed.
(indirectly) by async_chainiv_givencrypt_tail from the worker thread.
I'm sorry I didn't make it more clear that it is that code path I was
talking about.

 > 
 > Perhaps you were misled by the clear_bit call in schedule_work.
 > That is only used if we end up not scheduling the work.

No, I was not misled.  But apparently, I was not clear.  I do
understand how you use the INUSE bit.  I did not say above that
INUSE is not set when the worker thread is running (at least not for
the first part of my example).  If you had read further, you might
have noticed that the following paragraphs showed that indeed I do
understand that INUSE is set in the worker thread as evidenced by
"thread one calls test_and_set_bit which returns 1" I have added one
sentence (marked by **) to my event description below to make my
understanding more clear.  Please read on.

Assume the worker thread is executing between the dequeue in
async_chainiv_do_postponed and the clear_bit call in
async_chainiv_schedule_work.  Further assume that we are processing
the last item on the queue so durring this time, ctx->queue.qlen =
0.  **INUSE is still set at this point.

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

Thanks

--Brad
