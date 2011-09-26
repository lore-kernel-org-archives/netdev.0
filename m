From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ehea: Remove sleep at .ndo_get_stats
Date: Mon, 26 Sep 2011 21:42:59 +0200
Message-ID: <1317066179.2796.9.camel@edumazet-laptop>
References: <1317060132.2796.4.camel@edumazet-laptop>
	 <1317064918-1481-1-git-send-email-brenohl@br.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: brenohl@br.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:35965 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752953Ab1IZTnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 15:43:06 -0400
Received: by wwf22 with SMTP id 22so7228376wwf.1
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2011 12:43:04 -0700 (PDT)
In-Reply-To: <1317064918-1481-1-git-send-email-brenohl@br.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 26 septembre 2011 =C3=A0 16:21 -0300, brenohl@br.ibm.com a =C3=
=A9crit :
> Currently ehea ndo_get_stats can sleep in two places, in a hcall
> and in a GFP_KERNEL alloc, which is not correct.
> This patch creates a delayed workqueue that grabs the information eac=
h 1
> sec from the hardware, and place it into the device structure, so tha=
t,
> .ndo_get_stats quickly returns the device structure statistics block.
>=20
> Signed-off-by: Breno Leitao <brenohl@br.ibm.com>
> ---
>  drivers/net/ethernet/ibm/ehea/ehea.h      |    1 +
>  drivers/net/ethernet/ibm/ehea/ehea_main.c |   53 ++++++++++++++++---=
---------
>  2 files changed, 31 insertions(+), 23 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/ibm/ehea/ehea.h b/drivers/net/ether=
net/ibm/ehea/ehea.h
> index 7dd5e6a..0b8e6a9 100644
> --- a/drivers/net/ethernet/ibm/ehea/ehea.h
> +++ b/drivers/net/ethernet/ibm/ehea/ehea.h
> @@ -459,6 +459,7 @@ struct ehea_port {
>  	struct ehea_mc_list *mc_list;	 /* Multicast MAC addresses */
>  	struct ehea_eq *qp_eq;
>  	struct work_struct reset_task;
> +	struct delayed_work stats_work;
>  	struct mutex port_lock;
>  	char int_aff_name[EHEA_IRQ_NAME_SIZE];
>  	int allmulti;			 /* Indicates IFF_ALLMULTI state */
> diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/=
ethernet/ibm/ehea/ehea_main.c
> index 583bcd3..976988d 100644
> --- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
> +++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
> @@ -331,16 +331,34 @@ static struct net_device_stats *ehea_get_stats(=
struct net_device *dev)
>  {
>  	struct ehea_port *port =3D netdev_priv(dev);
>  	struct net_device_stats *stats =3D &port->stats;
> -	struct hcp_ehea_port_cb2 *cb2;
> -	u64 hret, rx_packets, tx_packets, rx_bytes =3D 0, tx_bytes =3D 0;
>  	int i;
> =20
> -	memset(stats, 0, sizeof(*stats));
> +	for (i =3D 0; i < port->num_def_qps; i++) {
> +		stats->rx_packets +=3D port->port_res[i].rx_packets;
> +		stats->rx_bytes   +=3D port->port_res[i].rx_bytes;
> +	}
> +

No.

You _really_ need the temporary variables, and set stats->field once
final result is known. Right now, you are adding data over and over.

Please test your patches :(

> +	for (i =3D 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
> +		stats->tx_packets +=3D port->port_res[i].tx_packets;
> +		stats->tx_bytes   +=3D port->port_res[i].tx_bytes;
> +	}
> +
> +	return &port->stats;

	return stats;

> +}
> +
