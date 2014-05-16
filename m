From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH net,v2] ipv4: ip_tunnels: disable cache for nbma gre tunnels
Date: Fri, 16 May 2014 08:34:39 +0300
Message-ID: <1400218479-10166-1-git-send-email-timo.teras@iki.fi>
References: <20140515.232905.995406666776115109.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:63135 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752719AbaEPFea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 01:34:30 -0400
Received: by mail-la0-f45.google.com with SMTP id gl10so1567864lab.18
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 22:34:29 -0700 (PDT)
In-Reply-To: <20140515.232905.995406666776115109.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The connected check fails to check for ip_gre nbma mode tunnels
properly. ip_gre creates temporary tnl_params with daddr specified
to pass-in the actual target on per-packet basis from neighbor
layer. Detect these tunnels by inspecting the actual tunnel
configuration.

Minimal test case:
 ip route add 192.168.1.1/32 via 10.0.0.1
 ip route add 192.168.1.2/32 via 10.0.0.2
 ip tunnel add nbma0 mode gre key 1 tos c0
 ip addr add 172.17.0.0/16 dev nbma0
 ip link set nbma0 up
 ip neigh add 172.17.0.1 lladdr 192.168.1.1 dev nbma0
 ip neigh add 172.17.0.2 lladdr 192.168.1.2 dev nbma0
 ping 172.17.0.1
 ping 172.17.0.2

The second ping should be going to 192.168.1.2 and head 10.0.0.2;
but cached gre tunnel level route is used and it's actually going
to 192.168.1.1 via 10.0.0.1.

The lladdr's need to go to separate dst for the bug to trigger.
Test case uses separate route entries, but this can also happen
when the route entry is same: if there is a nexthop exception or
the GRE tunnel is IPsec'ed in which case the dst points to xfrm
bundle unique to the gre lladdr.

=46ixes: 7d442fab0a67 ("ipv4: Cache dst in tunnels")
Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
Cc: Tom Herbert <therbert@google.com>
Cc: Eric Dumazet <edumazet@google.com>
---
Should go to 3.14-stable too.

 net/ipv4/ip_tunnel.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index e77381d..4eb9196 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -538,9 +538,10 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct ne=
t_device *dev,
 	unsigned int max_headroom;	/* The extra header space needed */
 	__be32 dst;
 	int err;
-	bool connected =3D true;
+	bool connected;
=20
 	inner_iph =3D (const struct iphdr *)skb_inner_network_header(skb);
+	connected =3D (tunnel->parms.iph.daddr !=3D 0);
=20
 	dst =3D tnl_params->daddr;
 	if (dst =3D=3D 0) {
--=20
1.9.3
