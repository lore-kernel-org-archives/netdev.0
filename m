From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ehea: Remove sleep at .ndo_get_stats
Date: Mon, 26 Sep 2011 20:02:12 +0200
Message-ID: <1317060132.2796.4.camel@edumazet-laptop>
References: <1316704497.29549.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1317057325-7410-1-git-send-email-brenohl@br.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: brenohl@br.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61197 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246Ab1IZSCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 14:02:16 -0400
Received: by wyg34 with SMTP id 34so6173343wyg.19
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2011 11:02:15 -0700 (PDT)
In-Reply-To: <1317057325-7410-1-git-send-email-brenohl@br.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 26 septembre 2011 =C3=A0 14:15 -0300, brenohl@br.ibm.com a =C3=
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
>  drivers/net/ethernet/ibm/ehea/ehea_main.c |   26 +++++++++++++++++++=
+------
>  2 files changed, 21 insertions(+), 6 deletions(-)
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
> index 583bcd3..a10f6b3 100644
> --- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
> +++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
> @@ -330,17 +330,24 @@ out:
>  static struct net_device_stats *ehea_get_stats(struct net_device *de=
v)
>  {
>  	struct ehea_port *port =3D netdev_priv(dev);
> +
> +	return &port->stats;
> +}


Hmm...

You should move in ehea_get_stats() all software-computed stats.

Only the hardware assisted stats should be gathered/changed from your
ehea_update_stats() helper.

This way, SNMP readers get accurate stats for all fields but the
stats->multicast and stats->rx_errors that are updated once per second.
