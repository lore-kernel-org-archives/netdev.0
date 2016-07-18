From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH 2/2] net: ip_finish_output_gso: If skb_gso_network_seglen exceeds MTU, allow segmentation for local udp tunneled skbs
Date: Mon, 18 Jul 2016 14:49:34 +0300
Message-ID: <1468842574-1243-3-git-send-email-shmulik.ladkani@gmail.com>
References: <1468842574-1243-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: shmulik.ladkani@ravellosystems.com,
	Eric Dumazet <edumazet@google.com>, shmulik.ladkani@gmail.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:32063 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398AbcGRLvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 07:51:00 -0400
In-Reply-To: <1468842574-1243-1-git-send-email-shmulik.ladkani@gmail.com>
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
according to the IPSKB_FRAG_SEGS flag, which is only set during ipv4
forwarding (not set in the bridged case).

In order to support the bridged case, we'll mark skbs arriving from an
ingress interface that get udp-encaspulated as "allowed to be fragmented",
causing their network_seglen to be validated by 'ip_finish_output_gso'
(and fragment if needed).

Note the TUNNEL_DONT_FRAGMENT tun_flag is still honoured (both in the
gso and non-gso cases), which serves users wishing to forbid
fragmentation at the udp tunnel endpoint.

Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Florian Westphal <fw@strlen.de>
Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---
 net/ipv4/ip_tunnel_core.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index afd6b59..9d847c3 100644
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
1.9.1
