From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 10/10] sfc: Support for byte queue limits
Date: Wed, 30 Nov 2011 13:44:03 +0100
Message-ID: <1322657043.2403.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <alpine.DEB.2.00.1111281822060.23687@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:41999 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750695Ab1K3MoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 07:44:09 -0500
Received: by qyk4 with SMTP id 4so231248qyk.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 04:44:09 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1111281822060.23687@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 novembre 2011 =C3=A0 18:33 -0800, Tom Herbert a =C3=A9crit =
:
> Changes to sfc to use byte queue limits.
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---

>  void efx_fini_tx_queue(struct efx_tx_queue *tx_queue)
> @@ -1163,6 +1176,8 @@ static int efx_enqueue_skb_tso(struct efx_tx_qu=
eue *tx_queue,
>  	/* Pass off to hardware */
>  	efx_nic_push_buffers(tx_queue);
> =20
> +	netdev_tx_sent_queue(tx_queue->core_txq, skb->len);
> +
>  	tx_queue->tso_bursts++;
>  	return NETDEV_TX_OK;
> =20

Small fix here :

[PATCH net-next] sfc: fix race in efx_enqueue_skb_tso()

As soon as skb is pushed to hardware, it can be completed and freed, so
we should not dereference skb anymore.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Tom Herbert <therbert@google.com>
CC: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/tx.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/t=
x.c
index ab4c635..e0e00b3 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -1173,11 +1173,11 @@ static int efx_enqueue_skb_tso(struct efx_tx_qu=
eue *tx_queue,
 			goto mem_err;
 	}
=20
+	netdev_tx_sent_queue(tx_queue->core_txq, skb->len);
+
 	/* Pass off to hardware */
 	efx_nic_push_buffers(tx_queue);
=20
-	netdev_tx_sent_queue(tx_queue->core_txq, skb->len);
-
 	tx_queue->tso_bursts++;
 	return NETDEV_TX_OK;
=20
