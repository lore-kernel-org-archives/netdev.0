From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [RFC PATCH] net: ip_finish_output_gso: Attempt gso_size clamping if segments exceed mtu
Date: Mon, 22 Aug 2016 15:06:10 +0300
Message-ID: <1471867570-1406-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <edumazet@google.com>,
        Florian Westphal <fw@strlen.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26975 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752299AbcHVMHU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 08:07:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are cases where gso skbs (which originate from an ingress
interface) have a gso_size value that exceeds the output dst mtu:

 - ipv4 forwarding middlebox having in/out interfaces with different mtus
   addressed by fe6cc55f3a 'net: ip, ipv6: handle gso skbs in forwarding path'
 - bridge having a tunnel member interface stacked over a device with small mtu
   addressed by b8247f095e 'net: ip_finish_output_gso: If skb_gso_network_seglen exceeds MTU, allow segmentation for local udp tunneled skbs'

In both cases, such skbs are identified, then go through early software
segmentation+fragmentation as part of ip_finish_output_gso.

Another approach is to shrink the gso_size to a value suitable so
resulting segments are smaller than dst mtu, as suggeted by Eric
Dumazet (as part of [1]) and Florian Westphal (as part of [2]).

This will void the need for software segmentation/fragmentation at
ip_finish_output_gso, thus significantly improve throughput and lower
cpu load.

This RFC patch attempts to implement this gso_size clamping.

[1] https://patchwork.ozlabs.org/patch/314327/
[2] https://patchwork.ozlabs.org/patch/644724/

Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Florian Westphal <fw@strlen.de>

Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---

 Comments welcome.

 Few questions embedded in the patch.

 Florian, in fe6cc55f you described a BUG due to gso_size decrease.
 I've tested both bridged and routed cases, but in my setups failed to
 hit the issue; Appreciate if you can provide some hints.

 net/ipv4/ip_output.c | 44 ++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 44 insertions(+)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index dde37fb..b911b43 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -216,6 +216,40 @@ static int ip_finish_output2(struct net *net, struct sock *sk, struct sk_buff *s
 	return -EINVAL;
 }
 
+static inline int skb_gso_clamp(struct sk_buff *skb, unsigned int network_len)
+{
+	struct skb_shared_info *shinfo = skb_shinfo(skb);
+	unsigned short gso_size;
+	unsigned int seglen;
+
+	if (shinfo->gso_size == GSO_BY_FRAGS)
+		return -EINVAL;
+
+	seglen = skb_gso_network_seglen(skb);
+
+	/* Decrease gso_size to fit specified network length */
+	gso_size = shinfo->gso_size - (seglen - network_len);
+	if (shinfo->gso_type & SKB_GSO_UDP)
+		gso_size &= ~7;
+
+	if (!(shinfo->gso_type & SKB_GSO_DODGY)) {
+		/* Recalculate gso_segs for skbs of trusted sources.
+		 * Untrusted skbs will have their gso_segs calculated by
+		 * skb_gso_segment.
+		 */
+		unsigned int hdr_len, payload_len;
+
+		hdr_len = seglen - shinfo->gso_size;
+		payload_len = skb->len - hdr_len;
+		shinfo->gso_segs = DIV_ROUND_UP(payload_len, gso_size);
+
+		// Q: need to verify gso_segs <= dev->gso_max_segs?
+		//    seems to be protected by netif_skb_features
+	}
+	shinfo->gso_size = gso_size;
+	return 0;
+}
+
 static int ip_finish_output_gso(struct net *net, struct sock *sk,
 				struct sk_buff *skb, unsigned int mtu)
 {
@@ -237,6 +271,16 @@ static int ip_finish_output_gso(struct net *net, struct sock *sk,
 	 * 2) skb arrived via virtio-net, we thus get TSO/GSO skbs directly
 	 * from host network stack.
 	 */
+
+	/* Attempt to clamp gso_size to avoid segmenting and fragmenting.
+	 *
+	 * Q: policy needed? per device?
+	 */
+	if (sysctl_ip_output_gso_clamp) {
+		if (!skb_gso_clamp(skb, mtu))
+			return ip_finish_output2(net, sk, skb);
+	}
+
 	features = netif_skb_features(skb);
 	BUILD_BUG_ON(sizeof(*IPCB(skb)) > SKB_SGO_CB_OFFSET);
 	segs = skb_gso_segment(skb, features & ~NETIF_F_GSO_MASK);
-- 
1.9.1
