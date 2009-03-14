From: Pantelis Koukousoulas <pktoss@gmail.com>
Subject: Re: [PATCH] Make virtio_net support carrier detection
Date: Sat, 14 Mar 2009 12:40:43 +0200
Message-ID: <1295ed070903140340g5da5853cq51decf40e2fc03c8@mail.gmail.com>
References: <20090312.055235.56926675.davem@davemloft.net>
	 <200903131017.11572.rusty@rustcorp.com.au>
	 <20090313.120100.266753164.davem@davemloft.net>
	 <200903141049.43202.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, dcbw@redhat.com,
	netdev@vger.kernel.org, markmc@redhat.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f177.google.com ([209.85.219.177]:38361 "EHLO
	mail-ew0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003AbZCNKkr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 06:40:47 -0400
Received: by ewy25 with SMTP id 25so2861876ewy.37
        for <netdev@vger.kernel.org>; Sat, 14 Mar 2009 03:40:44 -0700 (PDT)
In-Reply-To: <200903141049.43202.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I don't think it was straightforward at all. =A0Current virtio_net "c=
ards"
> don't support carrier detection. =A0We reported that (correctly) to u=
serspace,
> like every other driver which doesn't support carrier detect.
>
> So why is virtio_net different? =A0Or should all devices which can't =
detect
> carrier set it to on, so older NetworkManagers work?
>

"The difference between theory and practice is not important in theory
but very important in practice"

The practice is:

1) In real wired network cards, carrier is "off by default" (until you =
plug
a cable) and for laptops it could well be off most of the time (this
is the case here).
So if a "real hardware" driver reports "on" by default it could be wron=
g
often enough to cause serious frustration to the user (having to wait f=
or
a timeout possibly).

So, real hardware drivers cannot afford to lie that the carrier is "on"=
=2E
Only the user can know.

In the server case where carrier is normally "on", you either don't wan=
t to
use NetworkManager, or you would configure the link explicitly in NM an=
yway.


2) In virtio_net, network is "on by default", so the only problem by
reporting "on"
instead of "I have no idea" would be with a future qemu version, *if* t=
he user
does "set_link off" in qemu monitor while using NetworkManager (but usi=
ng
this feature would require a kernel update anyway comparing to what is
there now). For the extremely common case of someone testing a livecd
of a new distro release in existing qemu/kvm, they get the expected res=
ults.


3) There is a real cost of reporting "I have no idea" when the truth is
"it is on unless you do something to turn it off explicitly, oh and you=
 'll
need a future version of qemu (i.e., the "virtual hardware") for that t=
oo".


4) Not supporting carrier detection / reporting is arguably a "virtual
hardware bug".
Just try to sell a real hardware card these days without this feature :=
)
Not to mention that unlike real hardware, adding such small features to
virtio_net has a near-zero cost.

Working around this "virtual hardware bug" (my patch) while it is being=
 fixed
properly (in both the driver and the hardware at the same time), is rea=
sonable
imho because reporting "on" will be correct 100% of the time with
current versions
of qemu and most of the time with future versions as well.

Mark's commit alone achieves the desired effect of reporting carrier
status correctly
but only in the case of newer (yet unreleased?) qemu because of the

+       if (!virtio_has_feature(vi->vdev, VIRTIO_NET_F_STATUS))
+               return;

inside virtnet_update_status(). So, your patch adds the explicit
netif_carrier_on
in the probe function which is essentially replicating the behavior you=
 get with
my patch for current versions of qemu / virtio "hardware", you just hav=
e to wait
another 3 months for 2.6.30 (!!) to get this.

So, I still propose my version for 2.6.29 / -stable and then mark's
commit applies
on top of that just fine (just don't delete the netif_carrier_on)  and
adds the feature
of the user being able to set the status to on / off explicitly if
they have a new version
of qemu / virtio while still doing the "right thing" for current versio=
ns.

Therefore, I guess I should resend my patch to netdev with reworked com=
ments
to reflect this discussion. Hope that is ok with you too.

Pantelis

>
> commit 9f4d26d0f3016cf8813977d624751b94465fa317
> Author: Mark McLoughlin <markmc@redhat.com>
> Date: =A0 Mon Jan 19 17:09:49 2009 -0800
>
> =A0 =A0virtio_net: add link status handling
>
> =A0 =A0Allow the host to inform us that the link is down by adding
> =A0 =A0a VIRTIO_NET_F_STATUS which indicates that device status is
> =A0 =A0available in virtio_net config.
>
> =A0 =A0This is currently useful for simulating link down conditions
> =A0 =A0(e.g. using proposed qemu 'set_link' monitor command) but
> =A0 =A0would also be needed if we were to support device assignment
> =A0 =A0via virtio.
>
> =A0 =A0Signed-off-by: Mark McLoughlin <markmc@redhat.com>
> =A0 =A0Signed-off-by: Rusty Russell <rusty@rustcorp.com.au> (added fu=
ture masking)
> =A0 =A0Signed-off-by: David S. Miller <davem@davemloft.net>
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 30ae6d9..9b33d6e 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -42,6 +42,7 @@ struct virtnet_info
> =A0 =A0 =A0 =A0struct virtqueue *rvq, *svq;
> =A0 =A0 =A0 =A0struct net_device *dev;
> =A0 =A0 =A0 =A0struct napi_struct napi;
> + =A0 =A0 =A0 unsigned int status;
>
> =A0 =A0 =A0 =A0/* The skb we couldn't send because buffers were full.=
 */
> =A0 =A0 =A0 =A0struct sk_buff *last_xmit_skb;
> @@ -611,6 +612,7 @@ static struct ethtool_ops virtnet_ethtool_ops =3D=
 {
> =A0 =A0 =A0 =A0.set_tx_csum =3D virtnet_set_tx_csum,
> =A0 =A0 =A0 =A0.set_sg =3D ethtool_op_set_sg,
> =A0 =A0 =A0 =A0.set_tso =3D ethtool_op_set_tso,
> + =A0 =A0 =A0 .get_link =3D ethtool_op_get_link,
> =A0};
>
> =A0#define MIN_MTU 68
> @@ -636,6 +638,41 @@ static const struct net_device_ops virtnet_netde=
v =3D {
> =A0#endif
> =A0};
>
> +static void virtnet_update_status(struct virtnet_info *vi)
> +{
> + =A0 =A0 =A0 u16 v;
> +
> + =A0 =A0 =A0 if (!virtio_has_feature(vi->vdev, VIRTIO_NET_F_STATUS))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 vi->vdev->config->get(vi->vdev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 offsetof(st=
ruct virtio_net_config, status),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &v, sizeof(=
v));
> +
> + =A0 =A0 =A0 /* Ignore unknown (future) status bits */
> + =A0 =A0 =A0 v &=3D VIRTIO_NET_S_LINK_UP;
> +
> + =A0 =A0 =A0 if (vi->status =3D=3D v)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 vi->status =3D v;
> +
> + =A0 =A0 =A0 if (vi->status & VIRTIO_NET_S_LINK_UP) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_carrier_on(vi->dev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_wake_queue(vi->dev);
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_carrier_off(vi->dev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_stop_queue(vi->dev);
> + =A0 =A0 =A0 }
> +}
> +
> +static void virtnet_config_changed(struct virtio_device *vdev)
> +{
> + =A0 =A0 =A0 struct virtnet_info *vi =3D vdev->priv;
> +
> + =A0 =A0 =A0 virtnet_update_status(vi);
> +}
> +
> =A0static int virtnet_probe(struct virtio_device *vdev)
> =A0{
> =A0 =A0 =A0 =A0int err;
> @@ -738,6 +775,9 @@ static int virtnet_probe(struct virtio_device *vd=
ev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto unregister;
> =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 vi->status =3D VIRTIO_NET_S_LINK_UP;
> + =A0 =A0 =A0 virtnet_update_status(vi);
> +
> =A0 =A0 =A0 =A0pr_debug("virtnet: registered device %s\n", dev->name)=
;
> =A0 =A0 =A0 =A0return 0;
>
> @@ -793,7 +833,7 @@ static unsigned int features[] =3D {
> =A0 =A0 =A0 =A0VIRTIO_NET_F_HOST_TSO4, VIRTIO_NET_F_HOST_UFO, VIRTIO_=
NET_F_HOST_TSO6,
> =A0 =A0 =A0 =A0VIRTIO_NET_F_HOST_ECN, VIRTIO_NET_F_GUEST_TSO4, VIRTIO=
_NET_F_GUEST_TSO6,
> =A0 =A0 =A0 =A0VIRTIO_NET_F_GUEST_ECN, /* We don't yet handle UFO inp=
ut. */
> - =A0 =A0 =A0 VIRTIO_NET_F_MRG_RXBUF,
> + =A0 =A0 =A0 VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS,
> =A0 =A0 =A0 =A0VIRTIO_F_NOTIFY_ON_EMPTY,
> =A0};
>
> @@ -805,6 +845,7 @@ static struct virtio_driver virtio_net =3D {
> =A0 =A0 =A0 =A0.id_table =3D =A0 =A0 id_table,
> =A0 =A0 =A0 =A0.probe =3D =A0 =A0 =A0 =A0virtnet_probe,
> =A0 =A0 =A0 =A0.remove =3D =A0 =A0 =A0 __devexit_p(virtnet_remove),
> + =A0 =A0 =A0 .config_changed =3D virtnet_config_changed,
> =A0};
>
> =A0static int __init init(void)
> diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
> index 5cdd0aa..f76bd4a 100644
> --- a/include/linux/virtio_net.h
> +++ b/include/linux/virtio_net.h
> @@ -21,11 +21,16 @@
> =A0#define VIRTIO_NET_F_HOST_ECN =A013 =A0 =A0 =A0/* Host can handle =
TSO[6] w/ ECN in. */
> =A0#define VIRTIO_NET_F_HOST_UFO =A014 =A0 =A0 =A0/* Host can handle =
UFO in. */
> =A0#define VIRTIO_NET_F_MRG_RXBUF 15 =A0 =A0 =A0/* Host can merge rec=
eive buffers. */
> +#define VIRTIO_NET_F_STATUS =A0 =A016 =A0 =A0 =A0/* virtio_net_confi=
g.status available */
> +
> +#define VIRTIO_NET_S_LINK_UP =A0 1 =A0 =A0 =A0 /* Link is up */
>
> =A0struct virtio_net_config
> =A0{
> =A0 =A0 =A0 =A0/* The config defining mac address (if VIRTIO_NET_F_MA=
C) */
> =A0 =A0 =A0 =A0__u8 mac[6];
> + =A0 =A0 =A0 /* See VIRTIO_NET_F_STATUS and VIRTIO_NET_S_* above */
> + =A0 =A0 =A0 __u16 status;
> =A0} __attribute__((packed));
>
> =A0/* This is the first element of the scatter-gather list. =A0If you=
 don't
>
