From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] tg3: Fix tx race condition
Date: Mon, 07 Aug 2006 20:05:36 -0700
Message-ID: <1155006336.5328.24.camel@rh4>
References: <1155005186.5328.13.camel@rh4>
 <20060808025117.GA13077@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:55556 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1751226AbWHHDEn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 23:04:43 -0400
To: "Herbert Xu" <herbert@gondor.apana.org.au>
In-Reply-To: <20060808025117.GA13077@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-08 at 12:51 +1000, Herbert Xu wrote:

> > 2. Eliminate the private tx_lock altogether and rely solely on
> > netif_tx_lock.  This eliminates one spinlock in tg3_start_xmit()
> > when the ring is full.
> 
> Why not get rid of the lock altogether? By making sure memory
> barriers are present on the stop/wake paths the locks are not
> needed anymore.

Without the lock, I think you can still wake the queue with an empty
ring in some cases.  Although we handle it properly by returning
NETDEV_TX_BUSY, it is considered a BUG condition in tg3.

> 
> > 4. Make tx_cons and tx_prod volatile to guarantee that
> > tg3_start_xmit() and tg3_tx() will see the latest ring indices.
> 
> Such uses of volatile are bad inside the kernel because they
> don't actually provide hardware memory barriers and their effect
> on the compiler are given by constructs such as mb() anyway.
> 

Just trying to prevent the compiler from optimizing the code.  In cases
where we need hardware barriers we use mb.

> So we should simply add memory barriers where needed.
> 

I can do that.  It will be more mb() scattered in the driver.  Actually,
I can probably hide it in the TX_BUFFS_AVAIL() macro.

