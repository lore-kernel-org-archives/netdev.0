From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH 4/4] bnx2x: merge common code when stopping queue
Date: Wed, 10 Mar 2010 18:02:06 +0200
Message-ID: <1268236926.30985.4.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1268153703-4186-1-git-send-email-sgruszka@redhat.com>
 <1268153703-4186-2-git-send-email-sgruszka@redhat.com>
 <1268153703-4186-3-git-send-email-sgruszka@redhat.com>
 <1268153703-4186-4-git-send-email-sgruszka@redhat.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Vladislav Zolotarov" <vladz@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: "Stanislaw Gruszka" <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2514 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756814Ab0CJQCY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 11:02:24 -0500
In-Reply-To: <1268153703-4186-4-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-03-09 at 08:55 -0800, Stanislaw Gruszka wrote:
> Main reason for merge code is willingness to use memory barrier to av=
oid
> races with bnx2x_tx_int(). There is no real situation possible to
> trigger the races. But if we assume that bug of not stopped and full
> queue can happen, we should also stop queue then in the safe way.
>=20
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
> ---
> I have no strong fillings that patch should be applied, if Vladislav
> do not want the patch, I'll will not argue.
>=20
Stanislaw,

As you wrote, there is no real situation possible to trigger this race.
So basically, you are changing the code from =E2=80=9Creturn=E2=80=9D o=
n error to =E2=80=9Cgo
to=E2=80=9D  and in the =E2=80=9Cgo to=E2=80=9D branch you add some har=
mless but useless code in
the form of smp_mb and testing for a possible wake again. I find the
code to be less readable after this change and harder to maintain so I
prefer not to include this code change.

Thanks for all the changes and you participant in improving the bnx2x!

Eilon

>  drivers/net/bnx2x_main.c |   37 ++++++++++++++++++++----------------=
-
>  1 files changed, 20 insertions(+), 17 deletions(-)
>=20
> diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
> index 6c042a7..6751ca2 100644
> --- a/drivers/net/bnx2x_main.c
> +++ b/drivers/net/bnx2x_main.c
> @@ -11176,10 +11176,9 @@ static netdev_tx_t bnx2x_start_xmit(struct s=
k_buff *skb, struct net_device *dev)
>  	struct eth_tx_bd *tx_data_bd, *total_pkt_bd =3D NULL;
>  	struct eth_tx_parse_bd *pbd =3D NULL;
>  	u16 pkt_prod, bd_prod;
> -	int nbd, fp_index;
> +	int i, ret, nbd, fp_index;
>  	dma_addr_t mapping;
>  	u32 xmit_type =3D bnx2x_xmit_type(bp, skb);
> -	int i;
>  	u8 hlen =3D 0;
>  	__le16 pkt_size =3D 0;
> =20
> @@ -11194,10 +11193,9 @@ static netdev_tx_t bnx2x_start_xmit(struct s=
k_buff *skb, struct net_device *dev)
>  	fp =3D &bp->fp[fp_index];
> =20
>  	if (unlikely(bnx2x_tx_avail(fp) < (skb_shinfo(skb)->nr_frags + 3)))=
 {
> -		fp->eth_q_stats.driver_xoff++;
> -		netif_tx_stop_queue(txq);
>  		BNX2X_ERR("BUG! Tx ring full when queue awake!\n");
> -		return NETDEV_TX_BUSY;
> +		ret =3D NETDEV_TX_BUSY;
> +		goto stop_queue;
>  	}
> =20
>  	DP(NETIF_MSG_TX_QUEUED, "SKB: summed %x  protocol %x  protocol(%x,%=
x)"
> @@ -11425,22 +11423,27 @@ static netdev_tx_t bnx2x_start_xmit(struct =
sk_buff *skb, struct net_device *dev)
>  	mmiowb();
> =20
>  	fp->tx_bd_prod +=3D nbd;
> +	fp->tx_pkt++;
> =20
> -	if (unlikely(bnx2x_tx_avail(fp) < MAX_SKB_FRAGS + 3)) {
> -		netif_tx_stop_queue(txq);
> +	ret =3D NETDEV_TX_OK;
> +	if (unlikely(bnx2x_tx_avail(fp) < MAX_SKB_FRAGS + 3))
> +		goto stop_queue;
> =20
> -		/* paired memory barrier is in bnx2x_tx_int(), we have to keep
> -		 * ordering of set_bit() in netif_tx_stop_queue() and read of
> -		 * fp->bd_tx_cons */
> -		smp_mb();
> +	return ret;
> =20
> -		fp->eth_q_stats.driver_xoff++;
> -		if (bnx2x_tx_avail(fp) >=3D MAX_SKB_FRAGS + 3)
> -			netif_tx_wake_queue(txq);
> -	}
> -	fp->tx_pkt++;
> +stop_queue:
> +	netif_tx_stop_queue(txq);
> +
> +	/* paired memory barrier is in bnx2x_tx_int(), we have to keep
> +	 * ordering of set_bit() in netif_tx_stop_queue() and read of
> +	 * fp->bd_tx_cons */
> +	smp_mb();
> =20
> -	return NETDEV_TX_OK;
> +	fp->eth_q_stats.driver_xoff++;
> +	if (bnx2x_tx_avail(fp) >=3D MAX_SKB_FRAGS + 3)
> +		netif_tx_wake_queue(txq);
> +
> +	return ret;
>  }
> =20
>  /* called with rtnl_lock */



