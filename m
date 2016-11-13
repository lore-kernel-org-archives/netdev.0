From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] Fixup packets with incorrect ethertype sent by ZTE MF821D
Date: Sun, 13 Nov 2016 17:12:57 +0100
Message-ID: <87zil3cq9i.fsf@miraculix.mork.no>
References: <20161113134753.GR2745@pokute.pelzi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org
To: Jussi Peltola <plz@plz.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:47903 "EHLO canardo.mork.no"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933689AbcKMQN4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 13 Nov 2016 11:13:56 -0500
In-Reply-To: <20161113134753.GR2745@pokute.pelzi.net> (Jussi Peltola's message
        of "Sun, 13 Nov 2016 15:47:53 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jussi Peltola <plz@plz.fi> writes:

> This brokenness appears reliably after running "rdisc6 wwan0" but I have
> not debugged if this is related to timing or the format of the router
> solicitation. Before receiving a router solicitation, v4 is received
> correctly and v6 does not work. After sending the MF821D a router
> solicitation with rdisc6, v4 is broken but v6 works. With this patch
> (which I am using to write this message) a dual-stack context is usable.
>
> commit 2c25237d19c0c9741c6ebec854def99b88618eac
> Author: Jussi Peltola <plz@plz.fi>
> Date:   Sun Nov 13 15:41:50 2016 +0200
>
>     Fixup packets with incorrect ethertype sent by ZTE MF821D
>=20=20=20=20=20
>     Signed-off-by: Jussi Peltola <plz@plz.fi>
>
> diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
> index 3ff76c6..edd8172 100644
> --- a/drivers/net/usb/qmi_wwan.c
> +++ b/drivers/net/usb/qmi_wwan.c
> @@ -172,6 +172,12 @@ static const u8 buggy_fw_addr[ETH_ALEN] =3D {0x00, 0=
xa0, 0xc6, 0x00, 0x00, 0x00};
>   * Another common firmware bug results in all packets being addressed
>   * to 00:a0:c6:00:00:00 despite the host address being different.
>   * This function will also fixup such packets.
> + *
> + * At least the ZTE MF821D sends IPv4 packets with a bogus ethertype
> + * of 0x63bc, 0xe3bc, 0x63bd or 0xe3bd, and bogus source and
> + * destination MACs after it has received an IPv6 router solicitation
> + * (IPv6 is transmitted correctly). This function will also fix up
> + * such packets.
>   */
>  static int qmi_wwan_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
>  {
> @@ -195,12 +201,21 @@ static int qmi_wwan_rx_fixup(struct usbnet *dev, st=
ruct sk_buff *skb)
>                         return 0;
>                 if (is_multicast_ether_addr(skb->data))
>                         return 1;
> +
>                 /* possibly bogus destination - rewrite just in case */
>                 skb_reset_mac_header(skb);
>                 goto fix_dest;
>         default:
>                 if (rawip)
>                         return 0;
> +
> +               /* Bogus ethertype and src/dst mac for v4 on ZTE MF821D */
> +               if ((skb->data[12] & 0x7f) =3D=3D 0x63
> +                && (skb->data[13] & 0xfe) =3D=3D 0xbc) {
> +                       proto =3D htons(ETH_P_IP);
> +                       goto reset_mac;
> +               }
> +
>                 /* pass along other packets without modifications */
>                 return 1;
>         }
> @@ -213,6 +228,7 @@ static int qmi_wwan_rx_fixup(struct usbnet *dev, stru=
ct sk_buff *skb)
>         if (skb_headroom(skb) < ETH_HLEN)
>                 return 0;
>         skb_push(skb, ETH_HLEN);
> +reset_mac:
>         skb_reset_mac_header(skb);
>         eth_hdr(skb)->h_proto =3D proto;
>         eth_zero_addr(eth_hdr(skb)->h_source);


I must admit that I don't like the additional magic stuff at all.  I
don't doubt a second that it fixes the problem for you.  But there is
also no doubt that the firmware is so broken that there is no way we can
know this fixes anything for anyone else.  Where did the firmware get
those magic numbers?  It's definitely garbage.  But we have no reason to
think the garbage is invariable. It could be part of the firmware code,
or a serial number, or your assigned IPv6 prefix, or something else that
changes between different modems.  The fact that it is stable for you is
unfortunately not proof that it is the same for everyone else.

We have rejected similar fixes when this issue has come up earlier (it
looks like a generic Qualcomm firmware issue shared with other vendors
using the same baseband firmware generation). Using raw-ip is the
recommended workaround for these modems.

In any case, if we're going to add a fix like this, then I want it way
more generic.  The only valid ethertypes expected from the modem is IP,
IPV6 or ARP. Testing against those three, resetting anything else to IP,
will at least catch *any* bogus value.

But I'm not convinced I want this additional processing of every packet
just to let Qualcomm go on hiring monkeys-on-crack to write their
firmware. At least not when we do have raw-ip as a workaround for the
issue.

Feel free to try to convince me, though.


Bj=C3=B8rn
