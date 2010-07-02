From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fwd: Possible bug in net/ipv4/route.c?
Date: Fri, 02 Jul 2010 07:38:31 +0200
Message-ID: <1278049111.2597.6.camel@edumazet-laptop>
References: <4C2D53D3.6050106@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35138 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593Ab0GBFov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 01:44:51 -0400
In-Reply-To: <4C2D53D3.6050106@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 juillet 2010 =C3=A0 11:49 +0900, YOSHIFUJI Hideaki a =C3=
=A9crit :
> Switch to netdev.
>=20

thanks ;)

> --yoshfuji
>=20
> -------- Original Message --------
> Subject: Possible bug in net/ipv4/route.c?
> Date: Thu, 1 Jul 2010 16:00:29 -0700
> From: Sol Kavy <skavy@ubicom.com>
> To: <linux-kernel@vger.kernel.org>
> CC: Greg Ren <gren@ubicom.com>, Guojun Jin <gjin@ubicom.com>,        =
Murat Sezgin <msezgin@ubicom.com>, Sener Ilgen <silgen@ubicom.com>
>=20
> Found Linux: 2.6.28
> Arch: Ubicom32 <not yet pushed>
> Project: uCLinux based Router
> Test: Bit torrent Stress Test
>=20
> Note: The top of Linus git net/ipv4/route.c appears to have the same =
issue.
>=20

Please use < 72 char lines

> The following is a patch for clearing out IP options area in an input

>  skb during link failure processing.  Without this patch, the

>  icmp_send() can result in a call to ip_options_echo() where the=20

> common buffer area of the skb is incorrectly interpreted.  Depending =
on the previous use of the skb->cb[], the interpreted option length val=
ues can cause stack corruption by copying more than 40 bytes to the out=
put options.
>=20
> In our case, a driver is using the skb->cb[] area to hold driver
> specific data.   The driver is not zeroing out the area after use.  I
> can see three basic solutions:
>=20
> 1) Drivers are not allowed to use the skb->cb[] area at all.  Ubicom
> should modify the driver to use a different approach.
>=20
> 2) The layer using skb->cb[] should clear this area after use and
> before handing the skb to another layer.  Ubicom should modify the
> driver to clear the skb->cb[] area before sending it up the line.
>=20

This is the right option. If you use one word in cb[], only your driver
knows how to clear it efficiently.

> 3) Any layer that "uses" the skb->cb[] area must clear the area befor=
e
> use.  In which case, the proposed patch would fix the problem for the
> ipv4_link_failure().  I believe that this is the correct fix because =
I
> see ip_rcv() clears the skb->cb[] before using it.
>=20

No : ip_rcv clears() skb->cb when leaving ip_rcv, not entering.

skb allocation clears whole cb[], and each layer is responsible to clea=
r
the part it eventually dirtied.

> Can someone confirm that this is the appropriate fix?  If this is
> documented somewhere, please direct me to the documentation.
>=20
> Please send email to sol@ubicom.com in addition to posting your
> response.
>=20
> Thanks,
>=20
> Sol Kavy/Murat Sezgin
> Ubicom, Inc.
>=20
> Patch: =20
>=20
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 125ee64..d13805f 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1606,6 +1606,14 @@ static void ipv4_link_failure(struct sk_buff *=
skb)
> {
>         struct rtable *rt;
>=20
> +       /*
> +         * Since link failure can be called with skbs from many laye=
rs (see arp)
> +         * the cb area of the skb must be cleared before use. Becaus=
e the cb area=20
> +         * can be formatted according to the caller layer's cb area =
format and it may cause
> +         * corruptions when it is handled in a different network lay=
er.
> +         */
> +       memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
>         icmp_send(skb, ICMP_DEST_UNREACH, ICMP_HOST_UNREACH, 0);
>         rt =3D skb->rtable;
>=20
> The packet is enqueud by:
> do_IRQ()->do_softirq()->__do_softirq()->net_rx_action()->ubi32_eth_na=
pi_poll()->ubi32_eth_receive()->__vlan_hwaccel_rx()->netif_receive_skb(=
)->br_handle_frame()->nf_hook_slow()->br_nf_pre_routing_finish()->br_nf=
r_pre_routing_finish_bridge()->neight_resolve_output()->__neigh_event_s=
end().
>=20
> The packet is then dequeued by:=20
> do_IRQ() -> irq_exit() -> do_softirq() -> run_timer_softirq() -> neig=
h_timer_handler() -> arp_error_report() -> ipv4_link_failure() -> icmp_=
send() -> ip_options_echo().
>=20
> Because the Ubicom Ethernet driver overwrites the common buffer area,=
 the enqueued packet contains garbage when casted as an IP options data=
 structure.  This results in ip_options_echo() miss reading the option =
length information and overwriting memory.  By clearing the skb->cb[] b=
efore processing the icmp_send() against the packet, we ensure that ip_=
options_echo() does not corrupt memory.  =20
>=20
>=20
>=20


