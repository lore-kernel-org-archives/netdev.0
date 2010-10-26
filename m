From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 2.6.36/stable] vlan: Fix crash when hwaccel rx pkt for
 non-existant vlan.
Date: Mon, 25 Oct 2010 18:51:52 -0700
Message-ID: <AANLkTi=yT9JcwjQHu3P8mc5MZNb_-0BwHpsrH=BV=a84@mail.gmail.com>
References: <1288047166-5660-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49997 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753988Ab0JZBvx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 21:51:53 -0400
Received: by wyf28 with SMTP id 28so4080249wyf.19
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 18:51:52 -0700 (PDT)
In-Reply-To: <1288047166-5660-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 25, 2010 at 3:52 PM, Ben Greear <greearb@candelatech.com> w=
rote:
> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
> index 0eb96f7..2883d0e 100644
> --- a/net/8021q/vlan_core.c
> +++ b/net/8021q/vlan_core.c
> @@ -43,10 +43,16 @@ int vlan_hwaccel_do_receive(struct sk_buff *skb)
> =A0 =A0 =A0 =A0struct net_device *dev =3D skb->dev;
> =A0 =A0 =A0 =A0struct vlan_rx_stats =A0 =A0 *rx_stats;
>
> - =A0 =A0 =A0 skb->dev =3D vlan_dev_info(dev)->real_dev;
> - =A0 =A0 =A0 netif_nit_deliver(skb);
> + =A0 =A0 =A0 if (is_vlan_dev(dev)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->dev =3D vlan_dev_info(dev)->real_d=
ev;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_nit_deliver(skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->dev =3D dev;
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_nit_deliver(skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->pkt_type =3D PACKET_OTHERHOST;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 }

Neither setting skb->pkt_type nor calling netif_nit_deliver() should
be necessary here.  The former is done on receive if there is no
matching device and the latter happens later on in
__netif_receive_skb().  So you should just be able to do:

if (!is_vlan_dev(dev))
    return 0;

One potentially bad outcome of this approach is that other components
like bridging can start to pick up packets with vlan tags in
skb->vlan_tci.  However, in 2.6.36 it isn't able to do filtering on
them and the NIC on the output side may not be able to handle the tag
in the skb.  It's probably not common to have both bridging and a vlan
group on the same device but you'll get into some weird situations if
you do.

Once you start solving these issues you end up with more invasive
changes that look like the implementation in 2.6.37.  Since we don't
want to pull all of that in, it might just be best to deliver the
packet to network taps and then drop it.  That was the original reason
for allowing vlan packets with no device this far into the stack.
