From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] Fixup packets with incorrect ethertype sent by ZTE MF821D
Date: Mon, 14 Nov 2016 12:37:30 +0100
Message-ID: <87lgwmcmx1.fsf@miraculix.mork.no>
References: <20161113134753.GR2745@pokute.pelzi.net>
        <87zil3cq9i.fsf@miraculix.mork.no>
        <20161113172525.GS2745@pokute.pelzi.net>
        <20161114002218.GW2745@pokute.pelzi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org
To: Jussi Peltola <plz@plz.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:50583 "EHLO canardo.mork.no"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753581AbcKNLhn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 06:37:43 -0500
In-Reply-To: <20161114002218.GW2745@pokute.pelzi.net> (Jussi Peltola's message
        of "Mon, 14 Nov 2016 02:22:18 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jussi Peltola <plz@plz.fi> writes:

> So here's another stab. The comments and the current implementation are
> not in sync: any non-multicast address starting with a null octet gets
> rewritten, while the comment specifically mentions 00:a0:c6:00:00:00. It
> is certainly not elegant but re-writing all unicast destinations with
> our address does come to mind instead of special cases.

The known bug is related to 00:a0:c6:00:00:00 only.  But the workaround
catches anything starting with 00 for simplicity.  It's a deliberate
trade-off.  Could probably be clearer from the comments, yes.

> This patch fails to handle the invalid destinations in either way so I
> will send another one if you think it's worthwhile to go on. And it
> seems I forgot htons but I need this device for work now so a better
> patch must wait :)
>
> commit 35d3a46b7f1ece70e24386acbdd16af4507cb5f3
> Author: Jussi Peltola <plz@plz.fi>
> Date:   Mon Nov 14 01:45:32 2016 +0200
>
>     Attempt to fix up packets with a broken ethernet header
>=20=20=20=20=20
>     Signed-off-by: Jussi Peltola <plz@plz.fi>
>
> diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
> index 3ff76c6..7308d6b 100644
> --- a/drivers/net/usb/qmi_wwan.c
> +++ b/drivers/net/usb/qmi_wwan.c
> @@ -153,25 +153,57 @@ static const u8 default_modem_addr[ETH_ALEN] =3D {0=
x02, 0x50, 0xf3};
>=20=20
>  static const u8 buggy_fw_addr[ETH_ALEN] =3D {0x00, 0xa0, 0xc6, 0x00, 0x0=
0, 0x00};
>=20=20
> -/* Make up an ethernet header if the packet doesn't have one.
> +/* Check if the ethernet header has an unknown ethertype, and return a
> + * guess of the correct one based on the L3 header, or zero if the type =
was
> + * known or detection failed.
> + */
> +static __be16 detect_bogus_header(struct sk_buff *skb) {
> +       struct ethhdr *eth_hdr =3D (struct ethhdr*) skb->data;
> +
> +       switch (eth_hdr->h_proto) {
> +       case ETH_P_IP:
> +       case ETH_P_IPV6:
> +       case ETH_P_ARP:
> +               return 0;
> +       default:
> +               switch (skb->data[14] & 0xf0) {
> +               case 0x40:
> +                       return htons(ETH_P_IP);
> +               case 0x60:
> +                       return htons(ETH_P_IPV6);
> +               default:
> +                       /* pass on undetectable packets */
> +                       return 0;
> +               }
> +       }
> +       /*NOTREACHED*/
> +       return 0;
> +}
> +
> +/* Make up an ethernet header if the packet doesn't have a correct one.
>   *
>   * A firmware bug common among several devices cause them to send raw
>   * IP packets under some circumstances.  There is no way for the
>   * driver/host to know when this will happen.  And even when the bug
>   * hits, some packets will still arrive with an intact header.
>   *
> - * The supported devices are only capably of sending IPv4, IPv6 and
> + * The supported devices are only capable of sending IPv4, IPv6 and
>   * ARP packets on a point-to-point link. Any packet with an ethernet
>   * header will have either our address or a broadcast/multicast
> - * address as destination.  ARP packets will always have a header.
> + * address as destination. ARP packets will always have a header.
>   *
>   * This means that this function will reliably add the appropriate
> - * header iff necessary, provided our hardware address does not start
> + * header if necessary, provided our hardware address does not start
>   * with 4 or 6.
>   *
>   * Another common firmware bug results in all packets being addressed
>   * to 00:a0:c6:00:00:00 despite the host address being different.
> - * This function will also fixup such packets.
> + *
> + * Some devices will send packets with garbage source/destination MACs a=
nd
> + * ethertypes.
> + *
> + * This function will try to fix up all such packets.
> + *
>   */
>  static int qmi_wwan_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
>  {
> @@ -179,8 +211,8 @@ static int qmi_wwan_rx_fixup(struct usbnet *dev, stru=
ct sk_buff *skb)
>         bool rawip =3D info->flags & QMI_WWAN_FLAG_RAWIP;
>         __be16 proto;
>=20=20
> -       /* This check is no longer done by usbnet */
> -       if (skb->len < dev->net->hard_header_len)
> +       /* Shorter is definitely invalid and breaks subsequent tests */
> +       if (skb->len < 15)
>                 return 0;
>=20=20
>         switch (skb->data[0] & 0xf0) {


Makes sense, but could we please use some reasonable macro or something
instead of an arbitrary magic number?  Anything shorter than an IP
header will be bogus, for example.



> @@ -190,17 +222,17 @@ static int qmi_wwan_rx_fixup(struct usbnet *dev, st=
ruct sk_buff *skb)
>         case 0x60:
>                 proto =3D htons(ETH_P_IPV6);
>                 break;
> -       case 0x00:
> +       default:
>                 if (rawip)
>                         return 0;
>                 if (is_multicast_ether_addr(skb->data))
>                         return 1;
> -               /* possibly bogus destination - rewrite just in case */
> -               skb_reset_mac_header(skb);
> -               goto fix_dest;
> -       default:
> -               if (rawip)
> -                       return 0;
> +               proto =3D detect_bogus_header(skb);
> +               if (proto) {
> +                       /* remove terminally broken header */
> +                       skb_pull(skb, ETH_HLEN);
> +                       break;
> +               }
>                 /* pass along other packets without modifications */
>                 return 1;
>         }


Am I missing somehting, or is this removing the bogus destination
address fixup?  In any case, I don't have any device with that bug
available or the time to go and test it.  So I want you to either leave
that part of the code alone, or verify the workaround on a device with
the "00:a0:c6:00:00:00" bug.


> @@ -208,17 +240,17 @@ static int qmi_wwan_rx_fixup(struct usbnet *dev, st=
ruct sk_buff *skb)
>                 skb->dev =3D dev->net; /* normally set by eth_type_trans =
*/
>                 skb->protocol =3D proto;
>                 return 1;
> +       } else {


Completely unnecessary "else". We return from the other branch.

In any case, this change is not related to the rest of the patch and is
just making review more confusing.  And why would you add more indenting
levels than strictly necessary?


But please: Try to make the device work with raw-ip first. Qualcomm
never managed to fix their fake ethernet mode, and have given up on it.
Newer devices don't have that mode at all.  The device you have does
still have the mode.  But as is pretty obvious from the observed
behaviour: It's completely untested and not really working.  If you look
at the Windows driver, I'm pretty sure you'll find that the only reason
it works is because they use raw-ip mode.

FWIW, I regret having chosen the fake ethernet mode as the default for
qmi_wwan.  I did not anticipate the number of firmware issues Qualcomm
could manage to create simply adding a made-up ethernet header.  And I
did not anticipate them finally dropping it on the floor, forcing us to
support raw-ip mode anyway.

But with raw-ip support, there is absolutely no reason to play around
with fixing up the ethernet header bugs anymore.  If you have an older
device where it sort of works, then by all means use it.  But otherwise:
Use raw-ip mode.  I don't think I would have wanted any of the existing
header fixups either if the driver had supported raw-ip when they were
proposed.


Bj=C3=B8rn
