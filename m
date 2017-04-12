From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC ipsec-next 13/14] xfrm: Add encapsulation header offsets while SKB is not encrypted
Date: Wed, 12 Apr 2017 08:26:52 +0200
Message-ID: <1491978413-5700-14-git-send-email-steffen.klassert@secunet.com>
References: <1491978413-5700-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Ilan Tayari <ilant@mellanox.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:57628 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751212AbdDLGaT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 02:30:19 -0400
In-Reply-To: <1491978413-5700-1-git-send-email-steffen.klassert@secunet.com>
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
 net/xfrm/xfrm_output.c          | 2 ++
 5 files changed, 11 insertions(+)

diff --git a/net/ipv4/xfrm4_mode_transport.c b/net/ipv4/xfrm4_mode_transport.c
index 6c2411d..3d36644 100644
--- a/net/ipv4/xfrm4_mode_transport.c
+++ b/net/ipv4/xfrm4_mode_transport.c
@@ -24,6 +24,8 @@ static int xfrm4_transport_output(struct xfrm_state *x, struct sk_buff *skb)
 	struct iphdr *iph = ip_hdr(skb);
 	int ihl = iph->ihl * 4;
 
+	skb_set_inner_transport_header(skb, skb_transport_offset(skb));
+
 	skb_set_network_header(skb, -x->props.header_len);
 	skb->mac_header = skb->network_header +
 			  offsetof(struct iphdr, protocol);
diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
index d3f2434..e6265e2 100644
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
index eb9b36b..7a92c0f 100644
--- a/net/ipv6/xfrm6_mode_transport.c
+++ b/net/ipv6/xfrm6_mode_transport.c
@@ -27,6 +27,7 @@ static int xfrm6_transport_output(struct xfrm_state *x, struct sk_buff *skb)
 	int hdr_len;
 
 	iph = ipv6_hdr(skb);
+	skb_set_inner_transport_header(skb, skb_transport_offset(skb));
 
 	hdr_len = x->type->hdr_offset(x, skb, &prevhdr);
 	skb_set_mac_header(skb, (prevhdr - x->props.header_len) - skb->data);
diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
index 19a60fc..02556e3 100644
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
index a150886..8c0b672 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -205,6 +205,7 @@ int xfrm_output(struct sock *sk, struct sk_buff *skb)
 	int err;
 
 	secpath_reset(skb);
+	skb->encapsulation = 0;
 
 	if (xfrm_dev_offload_ok(skb, x)) {
 		struct sec_path *sp;
@@ -218,6 +219,7 @@ int xfrm_output(struct sock *sk, struct sk_buff *skb)
 		if (skb->sp)
 			secpath_put(skb->sp);
 		skb->sp = sp;
+		skb->encapsulation = 1;
 
 		sp->olen++;
 		sp->xvec[skb->sp->len++] = x;
-- 
2.7.4
