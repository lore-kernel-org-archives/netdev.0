From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net-next 09/14] tg3: Improve small packet
 performance
Date: Wed, 4 Aug 2010 15:47:29 -0700
Message-ID: <1280962049.7554.25.camel@HP1>
References: <1280784368-4226-9-git-send-email-mcarlson@broadcom.com>
 <20100804222741.GA18708@kryten>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"andy@greyhouse.net" <andy@greyhouse.net>
To: "Anton Blanchard" <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2976 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756909Ab0HDWsq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Aug 2010 18:48:46 -0400
In-Reply-To: <20100804222741.GA18708@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2010-08-04 at 15:27 -0700, Anton Blanchard wrote:
> Hi,
> 
> Just saw this go in:
>   
> >  static inline u32 tg3_tx_avail(struct tg3_napi *tnapi)
> >  {
> > -	smp_mb();
> > +	/* Tell compiler to fetch tx indices from memory. */
> > +	barrier();
> >  	return tnapi->tx_pending -
> >  	       ((tnapi->tx_prod - tnapi->tx_cons) & (TG3_TX_RING_SIZE - 1));
> >  }
> 
> Which worries me. Are we sure we don't need any ordering (eg smp_rmb)?
> A compiler barrier does nothing to ensure two loads are ordered.

We generally only get an estimate of the available tx ring size when we
call tg3_tx_avail(), so memory barriers are not generally needed.  We
put a compiler barrier there to make sure that the compiler will fetch
the tx_prod and tx_cons from memory to give us a better estimate.

In specific cases detailed in the patch description, we do need memory
barriers when we call netif_tx_stop_queue() and then check for the tx
ring.  We decided to put memory barriers exactly where they're needed
instead of inside tg3_tx_avail() which is an overkill.

Thanks.


