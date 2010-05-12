From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: [BUG] crashes with kvm/nat networking and net-next
Date: Wed, 12 May 2010 16:03:54 +0200
Message-ID: <4BEAB54A.2070203@pandora.be>
References: <20100511202544.267d33ee@nehalam> <1273649526.2621.3.camel@edumazet-laptop> <4BEA8E79.9000406@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from juliette.telenet-ops.be ([195.130.137.74]:57656 "EHLO
	juliette.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754157Ab0ELOJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 10:09:01 -0400
In-Reply-To: <4BEA8E79.9000406@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Eric Dumazet wrote:
>> Le mardi 11 mai 2010 =E0 20:25 -0700, Stephen Hemminger a =E9crit :
>>> This is a regression that is showing up now in net-next, not sure w=
hat
>>> changed recently in bridge netfilter that could be causing it?
>>>
>>> [ 4593.956206] BUG: unable to handle kernel NULL pointer dereferenc=
e at 0000000000000018
>>> [ 4593.956219] IP: [<ffffffffa03357a4>] br_nf_forward_finish+0x154/=
0x170 [bridge]
>> Not sure, but br_nf_forward_ip() has following check :
>>
>> if (!skb->nf_bridge)
>> 	return NF_ACCEPT;
>>
>> while br_nf_forward_arp() missed this check ...
>>
>> So we can dereference null pointer later
>=20
> That looks correct to me, offset 0x18 would be nf_bridge_info->mask.
> Bart, please review, thanks.
>=20
>> diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
>> index 93f80fe..cd2e5f5 100644
>> --- a/net/bridge/br_netfilter.c
>> +++ b/net/bridge/br_netfilter.c
>> @@ -723,6 +723,9 @@ static unsigned int br_nf_forward_arp(unsigned i=
nt hook, struct sk_buff *skb,
>>  		return NF_ACCEPT;
>>  #endif
>> =20
>> +	if (!skb->nf_bridge)
>> +		return NF_ACCEPT;
>> +
>>  	if (skb->protocol !=3D htons(ETH_P_ARP)) {
>>  		if (!IS_VLAN_ARP(skb))
>>  			return NF_ACCEPT;

That won't fix it since nf_bridge isn't used in the ARP case. The
correct fix is below. Does anyone know why the null pointer
dereference (skb->nf_bridge->mask & BRNF_8021Q) in
nf_bridge_update_protocol() didn't cause my uml kernel to crash??

cheers,
Bart


Don't call nf_bridge_update_protocol() for ARP traffic as
skb->nf_bridge isn't used in the ARP case.


Signed-off-by: Bart De Schuymer <bdschuym@pandora.be>
Reported-by: Stephen Hemminger <shemminger@vyatta.com>

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 93f80fe..4442099 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -643,10 +643,10 @@ static int br_nf_forward_finish(struct sk_buff *s=
kb)
 			skb->pkt_type =3D PACKET_OTHERHOST;
 			nf_bridge->mask ^=3D BRNF_PKT_TYPE;
 		}
+		nf_bridge_update_protocol(skb);
 	} else {
 		in =3D *((struct net_device **)(skb->cb));
 	}
-	nf_bridge_update_protocol(skb);
 	nf_bridge_push_encap_header(skb);
=20
 	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_FORWARD, skb, in,

--=20
Bart De Schuymer
www.artinalgorithms.be
