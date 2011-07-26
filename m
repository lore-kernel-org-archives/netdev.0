From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [patch net-next-2.6] forcedeth: fix vlans
Date: Tue, 26 Jul 2011 19:45:19 +0200
Message-ID: <CAHXqBF+Yr8Bw0LZHPpPuFY9iDyxxCCKw7S7FZkuGseiCK-es3g@mail.gmail.com>
References: <1311698510-2599-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, johnstul@us.ibm.com,
	w41ter@gmail.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:50327 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202Ab1GZRpj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2011 13:45:39 -0400
Received: by qyk29 with SMTP id 29so1602295qyk.19
        for <netdev@vger.kernel.org>; Tue, 26 Jul 2011 10:45:39 -0700 (PDT)
In-Reply-To: <1311698510-2599-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/7/26 Jiri Pirko <jpirko@redhat.com>:
> For some reason, when rxaccel is disabled, NV_RX3_VLAN_TAG_PRESENT is
> still set and some pseudorandom vids appear. So check for
> NETIF_F_HW_VLAN_RX as well. Also set correctly hw_features and set vl=
an
> mode on probe.
>
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> ---
> =C2=A0drivers/net/forcedeth.c | =C2=A0 =C2=A08 ++++++--
> =C2=A01 files changed, 6 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
> index e64cd9c..256a272 100644
> --- a/drivers/net/forcedeth.c
> +++ b/drivers/net/forcedeth.c
> @@ -2764,7 +2764,8 @@ static int nv_rx_process_optimized(struct net_d=
evice *dev, int limit)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0prefetch(skb->data);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0vlanflags =3D le32_to_cpu(np->get_rx.ex->buflow);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 if (vlanflags & NV_RX3_VLAN_TAG_PRESENT) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 if (dev->features & NETIF_F_HW_VLAN_RX &&
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 vlanflags & NV_RX3_VLAN_TAG_PRESENT) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 vid =3D vlanflags & NV_RX=
3_VLAN_TAG_MASK;

Please add comment that resembles this patch's description. This is a
bad idea to do in the general case as this will cause VLAN tagged
packets that were in the queue before feature change to be
misinterpreted.

>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__vlan_hwaccel_put_tag(skb, v=
id);
> @@ -5337,7 +5338,8 @@ static int __devinit nv_probe(struct pci_dev *p=
ci_dev, const struct pci_device_i
> =C2=A0 =C2=A0 =C2=A0 =C2=A0np->vlanctl_bits =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (id->driver_data & DEV_HAS_VLAN) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0np->vlanctl_bi=
ts =3D NVREG_VLANCONTROL_ENABLE;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev->features |=3D=
 NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev->hw_features |=
=3D NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev->features |=3D=
 dev->hw_features;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}

=46or better readability, hw_features -> features copy should be done
only once in this function.

Best Regards,
Micha=C5=82 Miros=C5=82aw
