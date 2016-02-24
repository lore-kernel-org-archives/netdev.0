From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/5] ppp: lock ppp structure before modifying mru
 in ppp_ioctl()
Date: Wed, 24 Feb 2016 15:32:02 -0500 (EST)
Message-ID: <20160224.153202.880408949435562278.davem@davemloft.net>
References: <cover.1456167043.git.g.nault@alphalink.fr>
	<be5fc2cf38f44951ea15f366bc52fb4d780009d2.1456167043.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulus@samba.org
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56589 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753232AbcBXUcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 15:32:05 -0500
In-Reply-To: <be5fc2cf38f44951ea15f366bc52fb4d780009d2.1456167043.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Mon, 22 Feb 2016 20:47:13 +0100

> PPP's Tx and Rx paths read ppp->mru under protection of ppp_xmit_lock()
> and ppp_recv_lock() respectively.
> Therefore ppp_ioctl() must hold the xmit and recv locks before
> concurrently updating ppp->mru.
> 
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
 ...
> diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
> index fc8ad00..4d342ae 100644
> --- a/drivers/net/ppp/ppp_generic.c
> +++ b/drivers/net/ppp/ppp_generic.c
> @@ -654,7 +654,10 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
>  	case PPPIOCSMRU:
>  		if (get_user(val, p))
>  			break;
> +		ppp_lock(ppp);
>  		ppp->mru = val;
> +		ppp_unlock(ppp);
> +

I see no bug here at all.

The store here is atomic, and all of those mentioned code paths only
read the MRU once and then use that value for the duration of the
rest of the processing of that PPP frame.

No possible corruptions or misbehavior can occur and I therefore think
the lack of locking here is completely legitimate.

You absolutely must demonstrate a case of corruption or misbehavior
when you want to add supposedly "missing locking".  Otherwise I'll have
a hard time accepting your changes.  This is especially for a subsystem
that as been around as long as PPP.
