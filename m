From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] KS8695: update ksp->next_rx_desc_read at the end
 of rx loop
Date: Tue, 16 Mar 2010 16:52:00 +0100
Message-ID: <1268754720.3094.55.camel@edumazet-laptop>
References: <f69abfc31003160842r59c25bbdl2029d3f20e668e53@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, davem@davemloft.net
To: Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f211.google.com ([209.85.218.211]:51169 "EHLO
	mail-bw0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756627Ab0CPPwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 11:52:07 -0400
Received: by bwz3 with SMTP id 3so99204bwz.29
        for <netdev@vger.kernel.org>; Tue, 16 Mar 2010 08:52:05 -0700 (PDT)
In-Reply-To: <f69abfc31003160842r59c25bbdl2029d3f20e668e53@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 16 mars 2010 =C3=A0 16:42 +0100, Yegor Yefremov a =C3=A9crit :
> KS8695: update ksp->next_rx_desc_read at the end of rx loop
>=20
> There is no need to adjust the next rx descriptor after each packet,
> so do it only once at the end of the routine.
>=20
> Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>
>=20
> Index: linux-2.6.34-rc1/drivers/net/arm/ks8695net.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.34-rc1.orig/drivers/net/arm/ks8695net.c
> +++ linux-2.6.34-rc1/drivers/net/arm/ks8695net.c
> @@ -538,12 +538,13 @@ rx_finished:
>  			 */
>  			last_rx_processed =3D buff_n;
>  			buff_n =3D (buff_n + 1) & MAX_RX_DESC_MASK;
> -			/*And note which RX descriptor we last did */
> -			if (likely(last_rx_processed !=3D -1))
> -				ksp->next_rx_desc_read =3D
> -					(last_rx_processed + 1) &
> -					MAX_RX_DESC_MASK;
>  	}
> +
> +	/*And note which RX descriptor we last did */
> +	if (likely(last_rx_processed !=3D -1))
> +		ksp->next_rx_desc_read =3D
> +			(last_rx_processed + 1) & MAX_RX_DESC_MASK;
> +

Very strange to see all these computations...

At this point, why not use

if (likely(last_rx_processed !=3D -1))
	ksp->next_rx_desc_read =3D buff_n;

or even get rid of last_rx_processed completely and do :


diff --git a/drivers/net/arm/ks8695net.c b/drivers/net/arm/ks8695net.c
index a1d4188..ac6ab04 100644
--- a/drivers/net/arm/ks8695net.c
+++ b/drivers/net/arm/ks8695net.c
@@ -461,7 +461,6 @@ static int ks8695_rx(struct ks8695_priv *ksp, int b=
udget)
 	int buff_n;
 	u32 flags;
 	int pktlen;
-	int last_rx_processed =3D -1;
 	int received =3D 0;
=20
 	buff_n =3D ksp->next_rx_desc_read;
@@ -533,17 +532,9 @@ rx_failure:
 			ksp->rx_ring[buff_n].status =3D cpu_to_le32(RDES_OWN);
 rx_finished:
 			received++;
-			/* And note this as processed so we can start
-			 * from here next time
-			 */
-			last_rx_processed =3D buff_n;
 			buff_n =3D (buff_n + 1) & MAX_RX_DESC_MASK;
-			/*And note which RX descriptor we last did */
-			if (likely(last_rx_processed !=3D -1))
-				ksp->next_rx_desc_read =3D
-					(last_rx_processed + 1) &
-					MAX_RX_DESC_MASK;
 	}
+	ksp->next_rx_desc_read =3D buff_n;
 	/* And refill the buffers */
 	ks8695_refill_rxbuffers(ksp);
=20



