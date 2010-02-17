From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH 1/3] vlan: adds vlan_dev_select_queue
Date: Wed, 17 Feb 2010 14:51:15 +0100
Message-ID: <1266414675.3246.12.camel@edumazet-laptop>
References: <20100217123606.18210.13602.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Vasu Dev <vasu.dev@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:65476 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934083Ab0BQNv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 08:51:27 -0500
Received: by bwz19 with SMTP id 19so5498562bwz.28
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2010 05:51:20 -0800 (PST)
In-Reply-To: <20100217123606.18210.13602.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 17 f=C3=A9vrier 2010 =C3=A0 04:36 -0800, Jeff Kirsher a =C3=
=A9crit :
> From: Vasu Dev <vasu.dev@intel.com>
>=20
> This is required to correctly select vlan tx queue for a driver
> supporting multi tx queue with ndo_select_queue implemented since
> currently selected vlan tx queue is unaligned to selected queue by
> ndo_select_queue.
>=20
> Unaligned vlan tx queue causes thrash with higher vlan tx lock
> contention for least fcoe traffic on ixgbe.
>=20
> Added vlan_dev_select_queue adds only minimal required code from
> dev_pick_tx and preserves queue selection for the case ndo_select_que=
ue
> is not implemented.
>=20
> Also updates vlan real_num_tx_queues in case underlying device
> queues has changed.
>=20
> Signed-off-by: Vasu Dev <vasu.dev@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>=20
>  net/8021q/vlan.c     |    1 +
>  net/8021q/vlan_dev.c |   23 +++++++++++++++++++++++
>  2 files changed, 24 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
> index 4535122..6c70805 100644
> --- a/net/8021q/vlan.c
> +++ b/net/8021q/vlan.c
> @@ -378,6 +378,7 @@ static void vlan_transfer_features(struct net_dev=
ice *dev,
>  #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
>  	vlandev->fcoe_ddp_xid =3D dev->fcoe_ddp_xid;
>  #endif
> +	vlandev->real_num_tx_queues =3D dev->real_num_tx_queues;

Hi Jeff

This is a bit dangerous and deserves a self contained patch IMHO.

I would add for example a
	BUG_ON(vlandev->real_num_tx_queues > vlandev->num_tx_queues)

------------------

=46or performance reason, we could avoid calling vlan_dev_select_queue(=
)
for real devices without ndo_select_queue() handler, this would need to
mirror vlan_netdev_ops & vlan_netdev_accel_ops.

It would also make vlan_dev_select_queue shorter and not duplicates
internals of net/dev/core.c :

static u16 vlan_dev_select_queue(struct net_device *dev, struct sk_buff
*skb)
{
       struct net_device *rdev =3D vlan_dev_info(dev)->real_dev;
       const struct net_device_ops *ops =3D rdev->netdev_ops;

       return ops->ndo_select_queue(rdev, skb);
}




