From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] loopback: optimization
Date: Wed, 5 Nov 2008 16:42:51 -0800
Message-ID: <20081105164251.2ca307fb@extreme>
References: <20081103213758.59a8361d@extreme>
	<20081105123659.6045b216@extreme>
	<491228C8.3010100@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58881 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752044AbYKFAmy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 19:42:54 -0500
In-Reply-To: <491228C8.3010100@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 06 Nov 2008 00:14:16 +0100
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Stephen Hemminger a =C3=A9crit :
> > Convert loopback device from using common network queues to a per-c=
pu
> > receive queue with NAPI. This gives a small 1% performance gain whe=
n
> > measured over 5 runs of tbench. Not sure if it's worth bothering
> > though.
> >=20
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >=20
> >=20
> > --- a/drivers/net/loopback.c	2008-11-04 15:36:29.000000000 -0800
> > +++ b/drivers/net/loopback.c	2008-11-05 10:00:20.000000000 -0800
> > @@ -59,7 +59,10 @@
> > =20
> > +/* Special case version of napi_schedule since loopback device has=
 no hard irq */
> > +void napi_schedule_irq(struct napi_struct *n)
> > +{
> > +	if (napi_schedule_prep(n)) {
> > +		list_add_tail(&n->poll_list, &__get_cpu_var(softnet_data).poll_l=
ist);
> > +		__raise_softirq_irqoff(NET_RX_SOFTIRQ);
> > +	}
> > +}
> > +
>=20
> Stephen, I dont get it.
>=20
> Sure loopback device cannot generate hard irqs, but what prevent's a =
real hardware
> interrupt to call NIC driver that can call napi_schedule() and corrup=
t softnet_data.poll_list ?
>=20
> Why not using a queue dedicated on loopback directly in cpu_var(softn=
et_data) ?
>=20
> (ie not using a napi structure for each cpu and each loopback dev)
>=20
> This queue would be irq safe yes.
>=20
> net_rx_action could handle this list without local_irq_disable()/loca=
l_irq_enable() games.
>=20
> Hum, maybe complex for loopback_dev_stop() to purge all queues withou=
t interfering with other namespaces.

I did try a workqueue and kthread version previously, but they both had=
 much worse
performance. Forgot that the NAPI schedule is shared, so yes that would=
 have to locked.

Doing it purely for loopback would mean using a tasklet or another soft=
irq.
