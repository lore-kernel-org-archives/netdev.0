From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: netif_tx_disable and lockless TX
Date: Wed, 31 May 2006 17:27:53 -0700
Message-ID: <1149121673.4022.22.camel@rh4>
References: <20060531045811.GA6977@gondor.apana.org.au>
 <20060530.221117.85394939.davem@davemloft.net>
 <1149110429.3078.5.camel@rh4>
 <20060531.170908.46214247.davem@davemloft.net>
 <20060601002525.GA19220@gondor.apana.org.au>
 <1149116466.4022.5.camel@rh4>
 <20060601004235.GA19459@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:14098 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1751500AbWFACH2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 22:07:28 -0400
To: "Herbert Xu" <herbert@gondor.apana.org.au>
In-Reply-To: <20060601004235.GA19459@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-06-01 at 10:42 +1000, Herbert Xu wrote:
> On Wed, May 31, 2006 at 04:01:06PM -0700, Michael Chan wrote:
> > 
> > Oh, I thought your idea was to keep the LLTX and just replace tx_lock
> > with xmit_lock in tg3. But I suppose we can also clear LLTX, remove the
> > tx_lock in hard_start_xmit and convert the rest to avoid changing
> > netpoll.
> 
> That's what I meant.  This has the advantage that things like AF_PACKET
> won't see duplicate packets.

Now that I think about it some more, we can eliminate most of the
tx_lock in tg3 without converting to xmit_lock. In most places, we get
the tx_lock after we call netif_tx_disable(), etc, and quiesce the chip.
So the tx_lock or xmit_lock is really not necessary in most places. The
tp->lock is sufficient after we stop everything.

The only few remaining places where we need it is around
netif_stop_queue/netif_wake_queue in hard_start_xmit and tx completion.
We can either keep the tx_lock or convert to xmit_lock and either way
makes little difference because these are not in the normal fast path.
If we keep the tx_lock, it will be just like BNX2.

