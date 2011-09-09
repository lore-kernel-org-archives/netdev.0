From: John H <uothrawn@yahoo.com>
Subject: Using gretap to tunnel layer 2 traffic
Date: Fri, 9 Sep 2011 10:25:04 -0700 (PDT)
Message-ID: <1315589104.22676.YahooMailNeo@web45104.mail.sp1.yahoo.com>
Reply-To: John H <uothrawn@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm7-vm0.bullet.mail.sp2.yahoo.com ([98.139.91.192]:35228 "HELO
	nm7-vm0.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758672Ab1IIR0G convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Sep 2011 13:26:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am attempting to tunnel Layer 2 traffic through a gretap device,=20
while encrypting the GRE tunnel with IPsec. My test environment is as f=
ollows:

10.0.1.1=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 10.0.1.2
client_a <--> server_left <=3D=3D> server_right <---> client_b
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 gretap/=
IPsec
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0

On the servers, I have two VLANs per server, corresponding to the unenc=
rypted
and encrypted interfaces.=A0 On each server, the unencrypted VLAN is=20
bridged with the gretap device.=A0 All VLANs and physical devices have =
MTUs of=20
1500.=A0 The gretap device has a resultant MTU of 1462, thereby causing=
 the=20
bridge device to have an MTU of 1462.

Traffic for the most part works as it is expected to behave. However,=20
packets are dropped when client_a sends an ICMP packet to client_b whic=
h=20
has an MTU less than client_a's device MTU but larger than server_left'=
s=20
MTU. I suspect other protocols would behave similarly (silently droppin=
g
packets).=A0 I an running "ping -c 1 -s 1450 10.0.1.2" on client_a, thi=
s results
in an ICMP packet being sent with an MTU of 1478.

An MTU of 1478 is larger than the bridge device's MTU of 1462, causing =
the=20
packet to be silently discarded per net/bridge/br_forward.c=20
in function br_dev_queue_push_xmit:

int br_dev_queue_push_xmit(struct sk_buff *skb)
{
=A0=A0=A0 /* drop mtu oversized packets except gso */
=A0=A0=A0 if (packet_length(skb) > skb->dev->mtu && !skb_is_gso(skb))
=A0=A0=A0=A0=A0=A0=A0 kfree_skb(skb);
=A0=A0=A0 else {
=A0=A0=A0 ....
=A0=A0 =A0
If the gretap device supported GSO, I suspect that this would not be a
problem. (ethtool -k gretapLeftRight states that GSO/GRO/LRO is not=20
supported)

=46unction br_dev_queue_push_xmit eventually calls ipgre_tunnel_xmit, i=
f the=20
packet is not dropped.

I would think that br_dev_queue_push_xmit should call ipgre_tunnel_xmit
regardless of the device MTU and ipgre_tunnel_xmit would handle packet
fragmentation internally, but it never has the chance.

I have tried allowing all packets through br_dev_queue_push_xmit
and explicitly setting the Don't Frament field to 0 in ipgre_tunnel_xmi=
t,
but this didn't solve problem.

Given that this would be tunneling Layer 2 traffic, it wouldn't make se=
nse
to send an ICMP_FRAG_NEEDED response from the bridge.

The real question is, however, why is any client able to send a single =
ICMP
packet with size 1478 bytes when one of the hops along the way only=20
supports 1462 bytes per its MTU? Shouldn't this have been negotiated=20
beforehand?
