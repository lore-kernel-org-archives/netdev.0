From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH v2] net: ip_finish_output_gso: If skb_gso_network_seglen exceeds MTU, allow segmentation for local udp tunneled skbs
Date: Fri, 15 Jul 2016 14:43:07 +0300
Message-ID: <1468582987-18990-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: shmulik.ladkani@ravellosystems.com,
	Eric Dumazet <edumazet@google.com>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34250 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932735AbcGOLn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 07:43:56 -0400
Received: by mail-wm0-f66.google.com with SMTP id q128so1906690wma.1
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 04:43:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Given:
 - tap0 and vxlan0 are bridged
 - vxlan0 stacked on eth0, eth0 having small mtu (e.g. 1400)

Assume GSO skbs arriving from tap0 having a gso_size as determined by
user-provided virtio_net_hdr (e.g. 1460 corresponding to VM mtu of 1500).

After encapsulation these skbs have skb_gso_network_seglen that exceed
eth0's ip_skb_dst_mtu.

These skbs are accidentally passed to ip_finish_output2 AS IS.
Alas, each final segment (segmented either by validate_xmit_skb or by
hardware UFO) would be larger than eth0 mtu.
As a result, those above-mtu segments get dropped on certain networks.

This behavior is not aligned with the NON-GSO case:
Assume a non-gso 1500-sized IP packet arrives from tap0. After
encapsulation, the vxlan datagram is fragmented normally at the
ip_finish_output-->ip_fragment code path.

The expected behavior for the GSO case would be segmenting the
"gso-oversized" skb first, then fragmenting each segment according to
dst mtu, and finally passing the resulting fragments to ip_finish_output2.

'ip_finish_output_gso' already supports this "Slowpath" behavior,
but it is only considered if IPSKB_FORWARDED is set (which is not set in
the bridged case).

In order to support the bridged case, we'll mark skbs arriving from an
ingress interface that get udp-encaspulated as "allowed to be fragmented".

This mark (as well as the original IPSKB_FORWARDED mark) gets tested in
'ip_finish_output_gso', in order to determine whether validating the
network seglen is needed.

Note the TUNNEL_DONT_FRAGMENT tun_flag is still honoured (both in the
gso and non-gso cases), which serves users wishing to forbid
fragmentation at the udp tunnel endpoint.

Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Florian Westphal <fw@strlen.de>
Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---

v2: Instead of completely removing the IPSKB_FORWARDED condition of
    'ip_finish_output_gso' (forcing an expensive 'skb_gso_validate_mtu'
    on all local traffic), augment the condition to the tunneled
    usecase, as suggested by Florian and Hannes.

 include/net/ip.h          |  1 +
 net/ipv4/ip_output.c      | 10 +++++++---
 net/ipv4/ip_tunnel_core.c |  9 +++++++++
 3 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 08f36cd2b8..9742b92dc9 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -47,6 +47,7 @@ struct inet_skb_parm {
 #define IPSKB_REROUTED		BIT(4)
 #define IPSKB_DOREDIRECT	BIT(5)
 #define IPSKB_FRAG_PMTU		BIT(6)
+#define IPSKB_FRAG_SEGS		BIT(7)
 
 	u16			frag_max_size;
 };
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index e23f141c9b..18bb7639dd 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -221,11 +221,15 @@ static int ip_finish_output_gso(struct net *net, struct sock *sk,
 {
 	netdev_features_t features;
 	struct sk_buff *segs;
+	int allow_frag;
 	int ret = 0;
 
-	/* common case: locally created skb or seglen is <= mtu */
-	if (((IPCB(skb)->flags & IPSKB_FORWARDED) == 0) ||
-	      skb_gso_validate_mtu(skb, mtu))
+	allow_frag = IPCB(skb)->flags & (IPSKB_FORWARDED | IPSKB_FRAG_SEGS);
+
+	/* common case: locally created skb and fragmentation of segments is
+	 * not allowed, or seglen is <= mtu
+	 */
+	if (!allow_frag || skb_gso_validate_mtu(skb, mtu))
 		return ip_finish_output2(net, sk, skb);
 
 	/* Slowpath -  GSO segment length is exceeding the dst MTU.
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index afd6b5968c..9d847c3025 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -63,6 +63,7 @@ void iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 	int pkt_len = skb->len - skb_inner_network_offset(skb);
 	struct net *net = dev_net(rt->dst.dev);
 	struct net_device *dev = skb->dev;
+	int skb_iif = skb->skb_iif;
 	struct iphdr *iph;
 	int err;
 
@@ -72,6 +73,14 @@ void iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 	skb_dst_set(skb, &rt->dst);
 	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
 
+	if (skb_iif && proto == IPPROTO_UDP) {
+		/* Arrived from an ingress interface and got udp encapuslated.
+		 * The encapsulated network segment length may exceed dst mtu.
+		 * Allow IP Fragmentation of segments.
+		 */
+		IPCB(skb)->flags |= IPSKB_FRAG_SEGS;
+	}
+
 	/* Push down and install the IP header. */
 	skb_push(skb, sizeof(struct iphdr));
 	skb_reset_network_header(skb);
-- 
2.7.4
