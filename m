From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/4] bnx2: Remove some unnecessary smp_mb() in
 tx fast path.
Date: Tue, 20 Jul 2010 07:38:03 +0200
Message-ID: <1279604283.2458.68.camel@edumazet-laptop>
References: <1279584905-15084-1-git-send-email-mchan@broadcom.com>
	 <1279584905-15084-2-git-send-email-mchan@broadcom.com>
	 <1279584905-15084-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61415 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754346Ab0GTFiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 01:38:07 -0400
Received: by wwj40 with SMTP id 40so330184wwj.1
        for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 22:38:06 -0700 (PDT)
In-Reply-To: <1279584905-15084-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 19 juillet 2010 =C3=A0 17:15 -0700, Michael Chan a =C3=A9crit =
:
> smp_mb() inside bnx2_tx_avail() is used twice in the normal
> bnx2_start_xmit() path (see illustration below).  The full memory
> barrier is only necessary during race conditions with tx completion.
> We can speed up the tx path by replacing smp_mb() in bnx2_tx_avail()
> with a compiler barrier.  The compiler barrier is to force the
> compiler to fetch the tx_prod and tx_cons from memory.
>=20
> In the race condition between bnx2_start_xmit() and bnx2_tx_int(),
> we have the following situation:
>=20
> bnx2_start_xmit()                       bnx2_tx_int()
>     if (!bnx2_tx_avail())
>             BUG();
>=20
>     ...
>=20
>     if (!bnx2_tx_avail())
>             netif_tx_stop_queue();          update_tx_index();
>             smp_mb();                       smp_mb();
>             if (bnx2_tx_avail())            if (netif_tx_queue_stoppe=
d() &&
>                     netif_tx_wake_queue();      bnx2_tx_avail())
>=20
> With smp_mb() removed from bnx2_tx_avail(), we need to add smp_mb() t=
o
> bnx2_start_xmit() as shown above to properly order netif_tx_stop_queu=
e()
> and bnx2_tx_avail() to check the ring index.  If it is not strictly
> ordered, the tx queue can be stopped forever.
>=20
> This improves performance by about 5% with 2 ports running bi-directi=
onal
> 64-byte packets.
>=20
> Reviewed-by: Benjamin Li <benli@broadcom.com>
> Reviewed-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> ---
>  drivers/net/bnx2.c |   10 +++++++++-
>  1 files changed, 9 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index d44ecc3..2af570d 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -253,7 +253,8 @@ static inline u32 bnx2_tx_avail(struct bnx2 *bp, =
struct bnx2_tx_ring_info *txr)
>  {
>  	u32 diff;
> =20
> -	smp_mb();
> +	/* Tell compiler to fetch tx_prod and tx_cons from memory. */
> +	barrier();
> =20
>  	/* The ring uses 256 indices for 255 entries, one of them
>  	 * needs to be skipped.
> @@ -6534,6 +6535,13 @@ bnx2_start_xmit(struct sk_buff *skb, struct ne=
t_device *dev)
> =20
>  	if (unlikely(bnx2_tx_avail(bp, txr) <=3D MAX_SKB_FRAGS)) {
>  		netif_tx_stop_queue(txq);
> +
> +		/* netif_tx_stop_queue() must be done before checking
> +		 * tx index in bnx2_tx_avail() below, because in
> +		 * bnx2_tx_int(), we update tx index before checking for
> +		 * netif_tx_queue_stopped().
> +		 */
> +		smp_mb();
>  		if (bnx2_tx_avail(bp, txr) > bp->tx_wake_thresh)
>  			netif_tx_wake_queue(txq);
>  	}

Excellent,

Is similar patch for tg3 planned ?

Thanks



