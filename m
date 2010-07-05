From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Possible bug in net/ipv4/route.c?
Date: Mon, 5 Jul 2010 11:03:28 -0700
Message-ID: <20100705110328.65702fc1@nehalam>
References: <CB2DD11991B27C4F99935E6229450D3205B28E91@STORK.scenix.com>
	<20100705120413.GA6219@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sol Kavy <skavy@ubicom.com>, linux-kernel@vger.kernel.org,
	gren@ubicom.com, gjin@ubicom.com, msezgin@ubicom.com,
	silgen@ubicom.com, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39378 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751695Ab0GESDe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 14:03:34 -0400
In-Reply-To: <20100705120413.GA6219@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 5 Jul 2010 20:04:13 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Sol Kavy <skavy@ubicom.com> wrote:
> > Found Linux: 2.6.28
> > Arch: Ubicom32 <not yet pushed>
> > Project: uCLinux based Router
> > Test: Bit torrent Stress Test
> >=20
> > Note: The top of Linus git net/ipv4/route.c appears to have the sam=
e issue.
> >=20
> > The following is a patch for clearing out IP options area in an inp=
ut skb during link failure processing.=A0 Without this patch, the icmp_=
send() can result in a call to ip_options_echo() where the common buffe=
r area of the skb is incorrectly interpreted.=A0 Depending on the previ=
ous use of the skb->cb[], the interpreted option length values can caus=
e stack corruption by copying more than 40 bytes to the output options.
> >=20
> > In our case, a driver is using the skb->cb[] area to hold driver sp=
ecific data.   The driver is not zeroing out the area after use.  I can=
 see three basic solutions:
> >=20
> > 1) Drivers are not allowed to use the skb->cb[] area at all.  Ubico=
m should modify the driver to use a different approach.
> >=20
> > 2) The layer using skb->cb[] should clear this area after use and b=
efore handing the skb to another layer.  Ubicom should modify the drive=
r to clear the skb->cb[] area before sending it up the line.
> >=20
> > 3) Any layer that "uses" the skb->cb[] area must clear the area bef=
ore use.  In which case, the proposed patch would fix the problem for t=
he ipv4_link_failure().  I believe that this is the correct fix because=
 I see ip_rcv() clears the skb->cb[] before using it.
> >=20
> > Can someone confirm that this is the appropriate fix?=A0 If this is=
 documented somewhere, please direct me to the documentation.
>=20
> Thanks for the report!
> =20
> > Patch:=A0=20
> >=20
> > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> > index 125ee64..d13805f 100644
> > --- a/net/ipv4/route.c
> > +++ b/net/ipv4/route.c
> > @@ -1606,6 +1606,14 @@ static void ipv4_link_failure(struct sk_buff=
 *skb)
> > {
> > =A0=A0=A0=A0=A0=A0=A0 struct rtable *rt;
> >=20
> > +=A0=A0=A0=A0 =A0=A0/*
> > +=A0=A0=A0=A0=A0=A0=A0=A0 * Since link failure can be called with s=
kbs from many layers (see arp)
> > +=A0=A0=A0=A0=A0=A0=A0=A0 * the cb area of the skb must be cleared =
before use. Because the cb area=20
> > +=A0=A0=A0=A0=A0=A0=A0=A0 * can be formatted according to the calle=
r layer's cb area format and it may cause
> > +=A0=A0=A0=A0=A0=A0=A0=A0 * corruptions when it is handled in a dif=
ferent network layer.
> > +=A0=A0=A0=A0=A0=A0=A0=A0 */
> > +=A0=A0=A0=A0=A0=A0 memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->=
opt));
> > =A0=A0=A0=A0=A0=A0=A0 icmp_send(skb, ICMP_DEST_UNREACH, ICMP_HOST_U=
NREACH, 0);
> > =A0=A0=A0=A0=A0=A0=A0=A0rt =3D skb->rtable;
> >=20
> > The packet is enqueud by:
> > do_IRQ()->do_softirq()->__do_softirq()->net_rx_action()->ubi32_eth_=
napi_poll()->ubi32_eth_receive()->__vlan_hwaccel_rx()->netif_receive_sk=
b()->br_handle_frame()->nf_hook_slow()->br_nf_pre_routing_finish()->br_=
nfr_pre_routing_finish_bridge()->neight_resolve_output()->__neigh_event=
_send().
> >=20
> > The packet is then dequeued by:=20
> > do_IRQ() -> irq_exit() -> do_softirq() -> run_timer_softirq() -> ne=
igh_timer_handler() -> arp_error_report() -> ipv4_link_failure() -> icm=
p_send() -> ip_options_echo().
> >=20
> > Because the Ubicom Ethernet driver overwrites the common buffer are=
a, the enqueued packet contains garbage when casted as an IP options da=
ta structure.  This results in ip_options_echo() miss reading the optio=
n length information and overwriting memory.=A0 By clearing the skb->cb=
[] before processing the icmp_send() against the packet, we ensure that=
 ip_options_echo() does not corrupt memory.=A0=A0=20
>=20
> Generally this area should be cleared on entry to each stack
> intending on using it.  So in this case, I'd point the finger
> of blame at the bridge stack for letting this packet into the
> IP stack through the back entrance without taking the proper
> precautions.

The CB is used in two places in the bridge code.
1) The recent multicast changes (IGMP)
2) Netfilter / ebtables to store header.

Ebtables is okay because the only part of the cb[] it uses
is the incoming device (brdev) which is always initialized coming into
the bridge: br_dev_xmit and br_handle_frame_finish

The IGMP code looks buggy.

/* net device transmit always called with no BH (preempt_disabled) */
netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
{
=2E.. [A]
	BR_INPUT_SKB_CB(skb)->brdev =3D dev;

	skb_reset_mac_header(skb);
	skb_pull(skb, ETH_HLEN);

	if (is_multicast_ether_addr(dest)) {
		if (br_multicast_rcv(br, NULL, skb))
			goto out;

		mdst =3D br_mdb_get(br, skb);
		if (mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb))
			... [B]

The problem is that br_dev_xmit is looking at flags in the CB[] that
are uninitialized.

if br_dev_xmit cleared the CB at [A] the mrouters_only would always be =
zero
at [B].

Where should the mrouters and igmp_only fields in skb be initialized?


