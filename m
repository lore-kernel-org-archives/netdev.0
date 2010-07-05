From: "Sol Kavy" <skavy@ubicom.com>
Subject: RE: Possible bug in net/ipv4/route.c?
Date: Mon, 5 Jul 2010 09:37:34 -0700
Message-ID: <CB2DD11991B27C4F99935E6229450D3205B28FC6@STORK.scenix.com>
References: <CB2DD11991B27C4F99935E6229450D3205B28E91@STORK.scenix.com> <20100705120413.GA6219@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Greg Ren" <gren@ubicom.com>, "Guojun Jin" <gjin@ubicom.com>,
	"Murat Sezgin" <msezgin@ubicom.com>,
	"Sener Ilgen" <silgen@ubicom.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Stephen Hemminger" <shemminger@vyatta.com>,
	<netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server70a.appriver.com ([69.20.116.35]:3614 "EHLO
	server70.appriver.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751551Ab0GESkT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 14:40:19 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20100705120413.GA6219@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So is there some place else that should have the clear instead of ipv4_=
link_failure()?

Sol

-----Original Message-----
=46rom: Herbert Xu [mailto:herbert@gondor.apana.org.au]=20
Sent: Monday, July 05, 2010 5:04 AM
To: Sol Kavy
Cc: linux-kernel@vger.kernel.org; Greg Ren; Guojun Jin; Murat Sezgin; S=
ener Ilgen; David S. Miller; Stephen Hemminger; netdev@vger.kernel.org
Subject: Re: Possible bug in net/ipv4/route.c?

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
> Patch:
>=20
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c index=20
> 125ee64..d13805f 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1606,6 +1606,14 @@ static void ipv4_link_failure(struct sk_buff=20
> *skb) {
> =A0=A0=A0=A0=A0=A0=A0 struct rtable *rt;
>=20
> +=A0=A0=A0=A0 =A0=A0/*
> +=A0=A0=A0=A0=A0=A0=A0=A0 * Since link failure can be called with skb=
s from many=20
> +layers (see arp)
> +=A0=A0=A0=A0=A0=A0=A0=A0 * the cb area of the skb must be cleared be=
fore use. Because=20
> +the cb area
> +=A0=A0=A0=A0=A0=A0=A0=A0 * can be formatted according to the caller =
layer's cb area=20
> +format and it may cause
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
=20
> the enqueued packet contains garbage when casted as an IP options dat=
a structure.  This results in ip_options_echo() miss reading the option=
 length information and overwriting memory.=A0 By clearing the skb->cb[=
] before processing the icmp_send() against the packet, we ensure that =
ip_options_echo() does not corrupt memory.

Generally this area should be cleared on entry to each stack intending =
on using it.  So in this case, I'd point the finger of blame at the bri=
dge stack for letting this packet into the IP stack through the back en=
trance without taking the proper precautions.

Cheers,
--
Email: Herbert Xu <herbert@gondor.apana.org.au> Home Page: http://gondo=
r.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
