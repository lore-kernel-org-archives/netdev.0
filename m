From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Possible bug in net/ipv4/route.c?
Date: Mon, 5 Jul 2010 20:04:13 +0800
Message-ID: <20100705120413.GA6219@gondor.apana.org.au>
References: <CB2DD11991B27C4F99935E6229450D3205B28E91@STORK.scenix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, gren@ubicom.com, gjin@ubicom.com,
	msezgin@ubicom.com, silgen@ubicom.com,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Sol Kavy <skavy@ubicom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:53725 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752680Ab0GEMEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 08:04:21 -0400
Content-Disposition: inline
In-Reply-To: <CB2DD11991B27C4F99935E6229450D3205B28E91@STORK.scenix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sol Kavy <skavy@ubicom.com> wrote:
> Found Linux: 2.6.28
> Arch: Ubicom32 <not yet pushed>
> Project: uCLinux based Router
> Test: Bit torrent Stress Test
>=20
> Note: The top of Linus git net/ipv4/route.c appears to have the same =
issue.
>=20
> The following is a patch for clearing out IP options area in an input=
 skb during link failure processing.=A0 Without this patch, the icmp_se=
nd() can result in a call to ip_options_echo() where the common buffer =
area of the skb is incorrectly interpreted.=A0 Depending on the previou=
s use of the skb->cb[], the interpreted option length values can cause =
stack corruption by copying more than 40 bytes to the output options.
>=20
> In our case, a driver is using the skb->cb[] area to hold driver spec=
ific data.   The driver is not zeroing out the area after use.  I can s=
ee three basic solutions:
>=20
> 1) Drivers are not allowed to use the skb->cb[] area at all.  Ubicom =
should modify the driver to use a different approach.
>=20
> 2) The layer using skb->cb[] should clear this area after use and bef=
ore handing the skb to another layer.  Ubicom should modify the driver =
to clear the skb->cb[] area before sending it up the line.
>=20
> 3) Any layer that "uses" the skb->cb[] area must clear the area befor=
e use.  In which case, the proposed patch would fix the problem for the=
 ipv4_link_failure().  I believe that this is the correct fix because I=
 see ip_rcv() clears the skb->cb[] before using it.
>=20
> Can someone confirm that this is the appropriate fix?=A0 If this is d=
ocumented somewhere, please direct me to the documentation.

Thanks for the report!
=20
> Patch:=A0=20
>=20
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 125ee64..d13805f 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1606,6 +1606,14 @@ static void ipv4_link_failure(struct sk_buff *=
skb)
> {
> =A0=A0=A0=A0=A0=A0=A0 struct rtable *rt;
>=20
> +=A0=A0=A0=A0 =A0=A0/*
> +=A0=A0=A0=A0=A0=A0=A0=A0 * Since link failure can be called with skb=
s from many layers (see arp)
> +=A0=A0=A0=A0=A0=A0=A0=A0 * the cb area of the skb must be cleared be=
fore use. Because the cb area=20
> +=A0=A0=A0=A0=A0=A0=A0=A0 * can be formatted according to the caller =
layer's cb area format and it may cause
> +=A0=A0=A0=A0=A0=A0=A0=A0 * corruptions when it is handled in a diffe=
rent network layer.
> +=A0=A0=A0=A0=A0=A0=A0=A0 */
> +=A0=A0=A0=A0=A0=A0 memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->op=
t));
> =A0=A0=A0=A0=A0=A0=A0 icmp_send(skb, ICMP_DEST_UNREACH, ICMP_HOST_UNR=
EACH, 0);
> =A0=A0=A0=A0=A0=A0=A0=A0rt =3D skb->rtable;
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
length information and overwriting memory.=A0 By clearing the skb->cb[]=
 before processing the icmp_send() against the packet, we ensure that i=
p_options_echo() does not corrupt memory.=A0=A0=20

Generally this area should be cleared on entry to each stack
intending on using it.  So in this case, I'd point the finger
of blame at the bridge stack for letting this packet into the
IP stack through the back entrance without taking the proper
precautions.

Cheers,
--=20
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
