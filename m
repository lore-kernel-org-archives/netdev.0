From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6] net: vlan: make non-hw-accel rx path similar
 to hw-accel
Date: Sun, 03 Apr 2011 17:23:44 +0200
Message-ID: <4D989100.1090207@gmail.com>
References: <1301739966-7604-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, xiaosuo@gmail.com,
	jesse@nicira.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51470 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751048Ab1DCPXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2011 11:23:49 -0400
Received: by wya21 with SMTP id 21so4079807wya.19
        for <netdev@vger.kernel.org>; Sun, 03 Apr 2011 08:23:48 -0700 (PDT)
In-Reply-To: <1301739966-7604-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/04/2011 12:26, Jiri Pirko a =E9crit :
> Now there are 2 paths for rx vlan frames. When rx-vlan-hw-accel is
> enabled, skb is untagged by NIC, vlan_tci is set and the skb gets int=
o
> vlan code in __netif_receive_skb - vlan_hwaccel_do_receive.
>
> For non-rx-vlan-hw-accel however, tagged skb goes thru whole
> __netif_receive_skb, it's untagged in ptype_base hander and reinjecte=
d
>
> This incosistency is fixed by this patch. Vlan untagging happens earl=
y in
> __netif_receive_skb so the rest of code (ptype_all handlers, rx_handl=
ers)
> see the skb like it was untagged by hw.
>
> Signed-off-by: Jiri Pirko<jpirko@redhat.com>
<snip>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 3da9fb0..bfe9fce 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3130,6 +3130,12 @@ another_round:
>
>   	__this_cpu_inc(softnet_data.processed);
>
> +	if (skb->protocol =3D=3D cpu_to_be16(ETH_P_8021Q)) {
> +		skb =3D vlan_untag(skb);
> +		if (unlikely(!skb))
> +			goto out;
> +	}
> +

I like the general idea of this patch, but I don't like the idea of re-=
inserting specific code=20
inside __netif_receive_skb.

You made a great work removing most - if not all - device specific part=
s from __netif_receive_skb,=20
by introducing rx_handler.

I think the above part (and vlan_untag) should be moved to a vlan_rx_ha=
ndler that would be set on=20
the net_devices that are the parent of a vlan net_device and are NOT hw=
accel.

vlan_rx_handler would return RX_HANDLER_ANOTHER if skb holds a tagged f=
rame (skb->dev changed) and=20
RX_HANDLER_PASS if skb holds an untagged frame (skb->dev unchanged).

This would also cause protocol handlers to receive the untouched (tagge=
d) frame, if no setup=20
required the frame to be untagged, which I think is the right thing to =
do.

 > @@ -3177,7 +3183,7 @@ ncls:
 >   			ret =3D deliver_skb(skb, pt_prev, orig_dev);
 >   			pt_prev =3D NULL;
 >   		}
 > -		if (vlan_hwaccel_do_receive(&skb)) {
 > +		if (vlan_do_receive(&skb)) {
 >   			ret =3D __netif_receive_skb(skb);
 >   			goto out;
 >   		} else if (unlikely(!skb))

Why are you calling __netif_receive_skb here? Can't we simply goto anot=
her_round?

I really think vlan_untag and vlan_do_receive could me merged in a vlan=
_rx_handler.

And if someone consider rx_handler processing happens to late for ptype=
_all handlers, may be it is=20
time to have a look at one of my previous proposed patch: http://patchw=
ork.ozlabs.org/patch/85578/

	Nicolas.
