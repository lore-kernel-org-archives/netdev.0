From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bnx2x: Resolving a possible dead-lock
 situation
Date: Tue, 23 Nov 2010 17:29:37 +0100
Message-ID: <1290529777.3046.99.camel@edumazet-laptop>
References: <1290528912.15453.3.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Miller <davem@davemloft.net>,
	Eilon Greenstein <eilong@broadcom.com>,
	netdev list <netdev@vger.kernel.org>
To: Vladislav Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:48107 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755653Ab0KWQ3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Nov 2010 11:29:44 -0500
Received: by vws13 with SMTP id 13so4297246vws.19
        for <netdev@vger.kernel.org>; Tue, 23 Nov 2010 08:29:44 -0800 (PST)
In-Reply-To: <1290528912.15453.3.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 23 novembre 2010 =C3=A0 18:15 +0200, Vladislav Zolotarov a =C3=
=A9crit :
> There is a possible dead-lock situation between sch_direct_xmit()=20
> (called from soft_IRQ context) and bnx2x_tx_int() when called from=20
> an ethtool self-test flow (syscall context).
>=20
> To prevent a dead-lock, disable bottom-halves on a local CPU when tak=
ing
> a tx_lock from bnx2x_tx_int() (use __netif_tx_lock_bh(txq)).
>=20
> The flow in the bnx2x_tx_int() where tx_lock is taken should be hit
> very rarely thus performance penalty of this change should be minimal=
=2E
>=20
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> ---
>  drivers/net/bnx2x/bnx2x_cmn.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_=
cmn.c
> index 94d5f59..5189788 100644
> --- a/drivers/net/bnx2x/bnx2x_cmn.c
> +++ b/drivers/net/bnx2x/bnx2x_cmn.c
> @@ -144,14 +144,14 @@ int bnx2x_tx_int(struct bnx2x_fastpath *fp)
>  		 * stops the queue
>  		 */
> =20
> -		__netif_tx_lock(txq, smp_processor_id());
> +		__netif_tx_lock_bh(txq);
> =20
>  		if ((netif_tx_queue_stopped(txq)) &&
>  		    (bp->state =3D=3D BNX2X_STATE_OPEN) &&
>  		    (bnx2x_tx_avail(fp) >=3D MAX_SKB_FRAGS + 3))
>  			netif_tx_wake_queue(txq);
> =20
> -		__netif_tx_unlock(txq);
> +		__netif_tx_unlock_bh(txq);
>  	}
>  	return 0;
>  }

That seems strange. Even if performance penalty is not minimal, it
should be avoided.

If problem comes from ethtool, why not preventing BH in ethtool itself =
?

diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2=
x_ethtool.c
index d02ffbd..1f7d4e6 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -1499,9 +1499,11 @@ static int bnx2x_run_loopback(struct bnx2x *bp, =
int loopback_mode, u8 link_up)
 	 * updates that have been performed while interrupts were
 	 * disabled.
 	 */
-	if (bp->common.int_block =3D=3D INT_BLOCK_IGU)
+	if (bp->common.int_block =3D=3D INT_BLOCK_IGU) {
+		local_bh_disable();
 		bnx2x_tx_int(fp_tx);
-
+		local_bh_enable();
+	}
 	rx_idx =3D le16_to_cpu(*fp_rx->rx_cons_sb);
 	if (rx_idx !=3D rx_start_idx + num_pkts)
 		goto test_loopback_exit;


