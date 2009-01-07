From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Wed, 7 Jan 2009 15:42:32 +1100
Message-ID: <20090107044232.GA22218@gondor.apana.org.au>
References: <20081224152841.GB13113@1wt.eu> <20090106183223.GA11964@ioremap.net> <20090106183704.GC32491@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <zbr@ioremap.net>, Willy Tarreau <w@1wt.eu>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755495AbZAGEnG@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090106183704.GC32491@kernel.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 06, 2009 at 06:37:05PM +0000, Jens Axboe wrote:
> 
> I'll give this a spin tomorrow as well. A hunch tells me that this is
> likely a page reuse issue, that splice is getting the reference to the
> buffer dropped before the data has really been transmitted. IOW, the
> page is likely fine reaching the ->sendpage() bit, but will be reused
> before the data has actually been transmitted. So once you get that far,
> other random data from that page is going out.

I see the problem.

The socket pipes in net/core/skbuff.c use references on the skb
to hold down the memory in skb->head as well as the pages in the
skb.

Unfortunately, once the pipe is fed into sendpage we only use
page reference counting to pin down the memory.  So as soon as
sendpage returns we drop the ref count on the skb, thus freeing
the memory in skb->head, which is yet to be transmitted.

Moral: Using page reference counts on skb->head is wrong.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
