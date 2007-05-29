From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] b44: netpoll locking fix
Date: Wed, 30 May 2007 00:20:41 +0200
Message-ID: <20070529222041.GB31200@electric-eye.fr.zoreil.com>
References: <20070529211458.GA31200@electric-eye.fr.zoreil.com> <20070529142734.3de0ef4f@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain; charset=unknown-8bit
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gary Zambrano <zambrano@broadcom.com>, jgarzik@pobox.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:52431 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750740AbXE2WYx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 May 2007 18:24:53 -0400
Content-Disposition: inline
In-Reply-To: <20070529142734.3de0ef4f@freepuppy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@linux-foundation.org> :
=E2=85=9C...]
> Better to just get rid of using the lock as a transmit lock and
> use netif_tx_lock instead.
> --- a/drivers/net/b44.c	2007-05-29 09:51:43.000000000 -0700
> +++ b/drivers/net/b44.c	2007-05-29 14:26:03.000000000 -0700
> @@ -607,6 +607,7 @@ static void b44_tx(struct b44 *bp)
>  {
>  	u32 cur, cons;
> =20
> +	netif_tx_lock(bp->dev);
>  	cur  =3D br32(bp, B44_DMATX_STAT) & DMATX_STAT_CDMASK;
>  	cur /=3D sizeof(struct dma_desc);
> =20

(damn, you are quick)

I am not completely convinced.

1. netpoll_send_skb (calls netif_tx_trylock(dev))
   -> netpoll_poll(np)
      -> poll_napi(np)
         -> np->dev->poll(np->dev, &budget) ( =3D=3D b44_poll)
            -> b44_tx
               -> netif_tx_lock(bp->dev) *deadlock*

2. Hunk #5 clashes with John Linville's wireless-dev#master

3. Moderately appropriate for 2.6.22-rc (imho, fwiw, etc.)

--=20
Ueimor
