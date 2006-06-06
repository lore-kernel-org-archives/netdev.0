From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Add netif_tx_lock
Date: Mon, 05 Jun 2006 21:57:48 -0700 (PDT)
Message-ID: <20060605.215748.28787254.davem@davemloft.net>
References: <20060601111503.GA16097@gondor.apana.org.au>
	<20060605.213250.85688925.davem@davemloft.net>
	<adapshmnbam.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, mchan@broadcom.com, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:13468
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932092AbWFFE5t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jun 2006 00:57:49 -0400
To: rdreier@cisco.com
In-Reply-To: <adapshmnbam.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Mon, 05 Jun 2006 21:44:01 -0700

>  > IPOIB is going to BUG() with this change.  Because now, in their
>  > multicast code, you're going to local_bh_disable() via
>  > netif_tx_unlock() with hw IRQs disabled which is illegal.
>  > 
>  > It shows a bug here in the locking of the IPOIB driver.
> 
> Sorry, I haven't followed this thread closely.  Can you expand on what
> the bug in ipoib's multicast locking is?

It disables hw interrupts, and takes the xmit_lock.

xmit_lock is a BH only spinlock, you can't take it from hw
interrupts, or inside of a HW irq protected spinlock.

You can take it on the outside of a HW irq lock protected
area like this:

	spin_lock_bh(&dev->xmit_lock);

	spin_lock_irq(&whatever_lock);

	spin_unlock_irq(&whatever_lock);

	spin_unlock_bh(&dev->xmit_lock);

but not the other way around.
