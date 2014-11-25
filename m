From: alexander.duyck@gmail.com
Subject: [net PATCH 1/2] ip6_udp_tunnel: Fix checksum calculation
Date: Mon, 24 Nov 2014 20:08:32 -0800
Message-ID: <20141125040831.13612.4374.stgit@ahduyck-workstation.home>
References: <20141125035808.13612.52556.stgit@ahduyck-workstation.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	Andy Zhou <azhou@nicira.com>, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:62029 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290AbaKYEId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 23:08:33 -0500
Received: by mail-pd0-f171.google.com with SMTP id y13so3077712pdi.16
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 20:08:33 -0800 (PST)
In-Reply-To: <20141125035808.13612.52556.stgit@ahduyck-workstation.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>

The UDP checksum calculation for VXLAN tunnels is currently using the
socket addresses instead of the actual packet source and destination
addresses.  As a result the checksum calculated is incorrect in some
cases.

Also uh->check was being set twice, first it was set to 0, and then it is
set again in udp6_set_csum.  This change removes the redundant assignment
to 0.

Fixes: acbf74a7 ("vxlan: Refactor vxlan driver to make use of the common UDP tunnel functions.")

Cc: Andy Zhou <azhou@nicira.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv6/ip6_udp_tunnel.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/ipv6/ip6_udp_tunnel.c b/net/ipv6/ip6_udp_tunnel.c
index b04ed72..8db6c98 100644
--- a/net/ipv6/ip6_udp_tunnel.c
+++ b/net/ipv6/ip6_udp_tunnel.c
@@ -79,15 +79,13 @@ int udp_tunnel6_xmit_skb(struct socket *sock, struct dst_entry *dst,
 	uh->source = src_port;
 
 	uh->len = htons(skb->len);
-	uh->check = 0;
 
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED
 			    | IPSKB_REROUTED);
 	skb_dst_set(skb, dst);
 
-	udp6_set_csum(udp_get_no_check6_tx(sk), skb, &inet6_sk(sk)->saddr,
-		      &sk->sk_v6_daddr, skb->len);
+	udp6_set_csum(udp_get_no_check6_tx(sk), skb, saddr, daddr, skb->len);
 
 	__skb_push(skb, sizeof(*ip6h));
 	skb_reset_network_header(skb);
