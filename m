From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] loopback: optimization
Date: Thu, 06 Nov 2008 00:14:16 +0100
Message-ID: <491228C8.3010100@cosmosbay.com>
References: <20081103213758.59a8361d@extreme> <20081105123659.6045b216@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:40816 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752412AbYKEXOa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 18:14:30 -0500
In-Reply-To: <20081105123659.6045b216@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> Convert loopback device from using common network queues to a per-cpu
> receive queue with NAPI. This gives a small 1% performance gain when
> measured over 5 runs of tbench. Not sure if it's worth bothering
> though.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
>=20
> --- a/drivers/net/loopback.c	2008-11-04 15:36:29.000000000 -0800
> +++ b/drivers/net/loopback.c	2008-11-05 10:00:20.000000000 -0800
> @@ -59,7 +59,10 @@
> =20
> +/* Special case version of napi_schedule since loopback device has n=
o hard irq */
> +void napi_schedule_irq(struct napi_struct *n)
> +{
> +	if (napi_schedule_prep(n)) {
> +		list_add_tail(&n->poll_list, &__get_cpu_var(softnet_data).poll_lis=
t);
> +		__raise_softirq_irqoff(NET_RX_SOFTIRQ);
> +	}
> +}
> +

Stephen, I dont get it.

Sure loopback device cannot generate hard irqs, but what prevent's a re=
al hardware
interrupt to call NIC driver that can call napi_schedule() and corrupt =
softnet_data.poll_list ?

Why not using a queue dedicated on loopback directly in cpu_var(softnet=
_data) ?

(ie not using a napi structure for each cpu and each loopback dev)

This queue would be irq safe yes.

net_rx_action could handle this list without local_irq_disable()/local_=
irq_enable() games.

Hum, maybe complex for loopback_dev_stop() to purge all queues without =
interfering with other namespaces.




