From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH v2 10/14] ixgbe: Update ixgbe to use new vlan accleration.
Date: Fri, 22 Oct 2010 15:24:00 +0200
Message-ID: <AANLkTindxJD1a5UPV+6vWbDEeMUTy1QgPs1X8pT-b69D@mail.gmail.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
	<1287618974-4714-11-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:49741 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754750Ab0JVNYB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Oct 2010 09:24:01 -0400
Received: by ywk9 with SMTP id 9so656820ywk.19
        for <netdev@vger.kernel.org>; Fri, 22 Oct 2010 06:24:01 -0700 (PDT)
In-Reply-To: <1287618974-4714-11-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/10/21 Jesse Gross <jesse@nicira.com>:
> Make the ixgbe driver use the new vlan accleration model.
[...]
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -954,17 +954,13 @@ static void ixgbe_receive_skb(struct ixgbe_q_ve=
ctor *q_vector,
> =A0 =A0 =A0 =A0bool is_vlan =3D (status & IXGBE_RXD_STAT_VP);
> =A0 =A0 =A0 =A0u16 tag =3D le16_to_cpu(rx_desc->wb.upper.vlan);
>
> - =A0 =A0 =A0 if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (adapter->vlgrp && is_vlan && (tag &=
 VLAN_VID_MASK))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vlan_gro_receive(napi, =
adapter->vlgrp, tag, skb);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 napi_gro_receive(napi, =
skb);
> - =A0 =A0 =A0 } else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (adapter->vlgrp && is_vlan && (tag &=
 VLAN_VID_MASK))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vlan_hwaccel_rx(skb, ad=
apter->vlgrp, tag);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_rx(skb);
> - =A0 =A0 =A0 }
> + =A0 =A0 =A0 if (is_vlan && (tag & VLAN_VID_MASK))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __vlan_hwaccel_put_tag(skb, tag);

I know that this is carried over from the driver, but why tag =3D=3D 0 =
is
treated differently here? VID0 is somewhat special, as normally it
means 802.1p packet, but i.e. in embedded world people are using it as
normal VID. It would be nice to have this handled consistently in the
VLAN core - deliver to base dev (tag stripped) if vlan 0 is not
configured and to vlan dev if it is.

> +
> + =A0 =A0 =A0 if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 napi_gro_receive(napi, skb);
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_rx(skb);
> =A0}
>
> =A0/**

Best Regards,
Micha=B3 Miros=B3aw
