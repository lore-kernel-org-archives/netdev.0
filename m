From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 11/11] xfrm: Add encapsulation header offsets while SKB is not encrypted
Date: Fri, 23 Sep 2016 09:53:48 +0200
Message-ID: <1474617228-26103-12-git-send-email-steffen.klassert@secunet.com>
References: <1474617228-26103-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Ilan Tayari <ilant@mellanox.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        "Boris Pismenny" <borisp@mellanox.com>,
        Ariel Levkovich <lariel@mellanox.com>,
        "Hay, Joshua A" <joshua.a.hay@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:46022 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758613AbcIWHyJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 03:54:09 -0400
In-Reply-To: <1474617228-26103-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilan Tayari <ilant@mellanox.com>

Both esp4 and esp6 used to assume that the SKB payload is encrypted
and therefore the inner_network and inner_transport offsets are
not relevant.
When doing crypto offload in the NIC, this is no longer the case
and the NIC driver needs these offsets so it can do TX TCP checksum
offloading.
This patch sets the inner_network and inner_transport members of
the SKB, as well as encapsulation, to reflect the actual positions
of these headers, and removes them only once encryption is done
on the payload.

Signed-off-by: Ilan Tayari <ilant@mellanox.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/xfrm4_mode_transport.c | 2 ++
 net/ipv4/xfrm4_mode_tunnel.c    | 3 +++
 net/ipv6/xfrm6_mode_transport.c | 1 +
 net/ipv6/xfrm6_mode_tunnel.c    | 3 +++
 net/xfrm/xfrm_output.c          | 6 +++---
 5 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/xfrm4_mode_transport.c b/net/ipv4/xfrm4_mode_transport.c
index 7b447f3..2cb2a50 100644
--- a/net/ipv4/xfrm4_mode_transport.c
+++ b/net/ipv4/xfrm4_mode_transport.c
@@ -23,6 +23,8 @@ static int xfrm4_transport_output(struct xfrm_state *x, struct sk_buff *skb)
 	struct iphdr *iph = ip_hdr(skb);
 	int ihl = iph->ihl * 4;
 
+	skb_set_inner_transport_header(skb, skb_transport_offset(skb));
+
 	skb_set_network_header(skb, -x->props.header_len);
 	skb->mac_header = skb->network_header +
 			  offsetof(struct iphdr, protocol);
diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
index 35feda6..b55ad81 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -33,6 +33,9 @@ static int xfrm4_mode_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 	struct iphdr *top_iph;
 	int flags;
 
+	skb_set_inner_network_header(skb, skb_network_offset(skb));
+	skb_set_inner_transport_header(skb, skb_transport_offset(skb));
+
 	skb_set_network_header(skb, -x->props.header_len);
 	skb->mac_header = skb->network_header +
 			  offsetof(struct iphdr, protocol);
diff --git a/net/ipv6/xfrm6_mode_transport.c b/net/ipv6/xfrm6_mode_transport.c
index 4e34410..66cc00c 100644
--- a/net/ipv6/xfrm6_mode_transport.c
+++ b/net/ipv6/xfrm6_mode_transport.c
@@ -26,6 +26,7 @@ static int xfrm6_transport_output(struct xfrm_state *x, struct sk_buff *skb)
 	int hdr_len;
 
 	iph = ipv6_hdr(skb);
+	skb_set_inner_transport_header(skb, skb_transport_offset(skb));
 
 	hdr_len = x->type->hdr_offset(x, skb, &prevhdr);
 	skb_set_mac_header(skb, (prevhdr - x->props.header_len) - skb->data);
diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
index 372855e..b8af4bb 100644
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -36,6 +36,9 @@ static int xfrm6_mode_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 	struct ipv6hdr *top_iph;
 	int dsfield;
 
+	skb_set_inner_network_header(skb, skb_network_offset(skb));
+	skb_set_inner_transport_header(skb, skb_transport_offset(skb));
+
 	skb_set_network_header(skb, -x->props.header_len);
 	skb->mac_header = skb->network_header +
 			  offsetof(struct ipv6hdr, nexthdr);
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index fdd5fa1..aa0dd7a 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -99,9 +99,6 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 
 		skb_dst_force(skb);
 
-		/* Inner headers are invalid now. */
-		skb->encapsulation = 0;
-
 		if (skb_shinfo(skb)->gso_type & SKB_GSO_ESP) {
 			x->type->encap(x, skb);
 		} else {
@@ -243,6 +240,7 @@ int xfrm_output(struct sock *sk, struct sk_buff *skb)
 		if (skb->sp)
 			secpath_put(skb->sp);
 		skb->sp = sp;
+		skb->encapsulation = 1;
 
 		skb->sp->xvec[skb->sp->len++] = x;
 		xfrm_state_hold(x);
@@ -254,6 +252,8 @@ int xfrm_output(struct sock *sk, struct sk_buff *skb)
 		}
 		if (x->xso.dev->features & NETIF_F_HW_ESP_TX_CSUM)
 			goto out;
+	} else {
+		skb->encapsulation = 0;
 	}
 
 	if (skb_is_gso(skb))
-- 
1.9.1
