From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.23-rc5: possible irq lock inversion dependency detected
Date: Mon, 10 Sep 2007 21:00:24 +0800
Message-ID: <20070910130024.GA27939@gondor.apana.org.au>
References: <alpine.DEB.0.999.0709021455510.7103@sheep.housecafe.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jamal <hadi@cyberus.ca>
To: Christian Kujau <lists@nerdbynature.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2409 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758062AbXIJNAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2007 09:00:42 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.0.999.0709021455510.7103@sheep.housecafe.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 02, 2007 at 01:11:29PM +0000, Christian Kujau wrote:
> 
> after upgrading to 2.6.23-rc5 (and applying davem's fix [0]), lockdep 
> was quite noisy when I tried to shape my external (wireless) interface:
> 
> [ 6400.534545] FahCore_78.exe/3552 just changed the state of lock:
> [ 6400.534713]  (&dev->ingress_lock){-+..}, at: [<c038d595>] 
> netif_receive_skb+0x2d5/0x3c0
> [ 6400.534941] but this lock took another, soft-read-irq-unsafe lock in the 
> past:
> [ 6400.535145]  (police_lock){-.--}

This is a genuine dead-lock.  The police lock can be taken
for reading with softirqs on.  If a second CPU tries to take
the police lock for writing, while holding the ingress lock,
then a softirq on the first CPU can dead-lock when it tries
to get the ingress lock.

The minimal fix would be to make sure that we disable BH on
the first CPU.  Jamal, could you take a look at this please?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
