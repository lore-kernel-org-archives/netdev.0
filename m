From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [BUG] crashes with kvm/nat networking and net-next
Date: Wed, 12 May 2010 15:15:40 -0700
Message-ID: <20100512151540.6f09a1b8@nehalam>
References: <20100511202544.267d33ee@nehalam>
	<1273649526.2621.3.camel@edumazet-laptop>
	<4BEA8E79.9000406@trash.net>
	<4BEAB54A.2070203@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Bart De Schuymer <bdschuym@pandora.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39522 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756316Ab0ELWPx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 18:15:53 -0400
In-Reply-To: <4BEAB54A.2070203@pandora.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 May 2010 16:03:54 +0200
Bart De Schuymer <bdschuym@pandora.be> wrote:

> Patrick McHardy wrote:
> > Eric Dumazet wrote:
> >> Le mardi 11 mai 2010 =E0 20:25 -0700, Stephen Hemminger a =E9crit =
:
> >>> This is a regression that is showing up now in net-next, not sure=
 what
> >>> changed recently in bridge netfilter that could be causing it?
> >>>
> >>> [ 4593.956206] BUG: unable to handle kernel NULL pointer derefere=
nce at 0000000000000018
> >>> [ 4593.956219] IP: [<ffffffffa03357a4>] br_nf_forward_finish+0x15=
4/0x170 [bridge]
> >> Not sure, but br_nf_forward_ip() has following check :
> >>
> >> if (!skb->nf_bridge)
> >> 	return NF_ACCEPT;
> >>
> >> while br_nf_forward_arp() missed this check ...
> >>
> >> So we can dereference null pointer later
> >=20
> > That looks correct to me, offset 0x18 would be nf_bridge_info->mask=
=2E
> > Bart, please review, thanks.
> >=20
> >> diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
> >> index 93f80fe..cd2e5f5 100644
> >> --- a/net/bridge/br_netfilter.c
> >> +++ b/net/bridge/br_netfilter.c
> >> @@ -723,6 +723,9 @@ static unsigned int br_nf_forward_arp(unsigned=
 int hook, struct sk_buff *skb,
> >>  		return NF_ACCEPT;
> >>  #endif
> >> =20
> >> +	if (!skb->nf_bridge)
> >> +		return NF_ACCEPT;
> >> +
> >>  	if (skb->protocol !=3D htons(ETH_P_ARP)) {
> >>  		if (!IS_VLAN_ARP(skb))
> >>  			return NF_ACCEPT;
>=20
> That won't fix it since nf_bridge isn't used in the ARP case. The
> correct fix is below. Does anyone know why the null pointer
> dereference (skb->nf_bridge->mask & BRNF_8021Q) in
> nf_bridge_update_protocol() didn't cause my uml kernel to crash??
>=20
> cheers,
> Bart
>=20
>=20
> Don't call nf_bridge_update_protocol() for ARP traffic as
> skb->nf_bridge isn't used in the ARP case.
>=20
>=20
> Signed-off-by: Bart De Schuymer <bdschuym@pandora.be>
> Reported-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
> index 93f80fe..4442099 100644
> --- a/net/bridge/br_netfilter.c
> +++ b/net/bridge/br_netfilter.c
> @@ -643,10 +643,10 @@ static int br_nf_forward_finish(struct sk_buff =
*skb)
>  			skb->pkt_type =3D PACKET_OTHERHOST;
>  			nf_bridge->mask ^=3D BRNF_PKT_TYPE;
>  		}
> +		nf_bridge_update_protocol(skb);
>  	} else {
>  		in =3D *((struct net_device **)(skb->cb));
>  	}
> -	nf_bridge_update_protocol(skb);
>  	nf_bridge_push_encap_header(skb);
> =20
>  	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_FORWARD, skb, in,
>=20

This has worked all day for me without problem.


--=20
