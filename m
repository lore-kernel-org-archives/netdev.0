From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net v2] ipv4: ipv6: better estimate tunnel header cut for correct ufo handling
Date: Sun, 23 Feb 2014 22:24:27 +0100
Message-ID: <20140223212427.GD6598@order.stressinduktion.org>
References: <1682505.dP4nT04FC9@h2o.as.studentenwerk.mhn.de> <1581659.JtJ1UQaXJr@h2o.as.studentenwerk.mhn.de> <20140211024403.GE11150@order.stressinduktion.org> <5911515.kv7YDRiZP1@h2o.as.studentenwerk.mhn.de> <20140217160916.GE22833@order.stressinduktion.org> <20140220024418.GG1179@order.stressinduktion.org> <CAM_iQpW0ai2NMyVV1FGpDn5qKDUxYoqsXZ-GutfccQp92SyKwQ@mail.gmail.com> <20140221011952.GA28822@order.stressinduktion.org> <20140223210509.GC6598@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Cong Wang <xiyou.wangcong@gmail.com>,
	Wolfgang Walter <linux@stwm.de>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47693 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751618AbaBWVY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Feb 2014 16:24:28 -0500
Content-Disposition: inline
In-Reply-To: <20140223210509.GC6598@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the UFO fragmentation process does not correctly handle inner
UDP frames.

(The following tcpdumps are captured on the parent interface with ufo
disabled while tunnel has ufo enabled, 2000 bytes payload, mtu 1280,
both sit device):

IPv6:
16:39:10.031613 IP (tos 0x0, ttl 64, id 3208, offset 0, flags [DF], proto IPv6 (41), length 1300)
    192.168.122.151 > 1.1.1.1: IP6 (hlim 64, next-header Fragment (44) payload length: 1240) 2001::1 > 2001::8: frag (0x00000001:0|1232) 44883 > distinct: UDP, length 2000
16:39:10.031709 IP (tos 0x0, ttl 64, id 3209, offset 0, flags [DF], proto IPv6 (41), length 844)
    192.168.122.151 > 1.1.1.1: IP6 (hlim 64, next-header Fragment (44) payload length: 784) 2001::1 > 2001::8: frag (0x00000001:0|776) 58979 > 46366: UDP, length 5471

We can see that fragmentation header offset is not correctly updated.
(fragmentation id handling is corrected by 916e4cf46d0204 ("ipv6: reuse
ip6_frag_id from ip6_ufo_append_data")).

IPv4:
16:39:57.737761 IP (tos 0x0, ttl 64, id 3209, offset 0, flags [DF], proto IPIP (4), length 1296)
    192.168.122.151 > 1.1.1.1: IP (tos 0x0, ttl 64, id 57034, offset 0, flags [none], proto UDP (17), length 1276)
    192.168.99.1.35961 > 192.168.99.2.distinct: UDP, length 2000
16:39:57.738028 IP (tos 0x0, ttl 64, id 3210, offset 0, flags [DF], proto IPIP (4), length 792)
    192.168.122.151 > 1.1.1.1: IP (tos 0x0, ttl 64, id 57035, offset 0, flags [none], proto UDP (17), length 772)
    192.168.99.1.13531 > 192.168.99.2.20653: UDP, length 51109

In this case fragmentation id is incremented and offset is not updated.

First, I aligned inet_gso_segment and ipv6_gso_segment:
* align naming of flags
* ipv6_gso_segment: setting skb->encapsulation is unnecessary, as we
  always ensure that the state of this flag is left untouched when
  returning from upper gso segmenation function
* ipv6_gso_segment: move skb_reset_inner_headers below updating the
  fragmentation header data, we don't care for updating fragmentation
  header data
* remove currently unneeded comment indicating skb->encapsulation might
  get changed by upper gso_segment callback (gre and udp-tunnel reset
  encapsulation after segmentation on each fragment)

If we encounter an IPIP or SIT gso skb we now check for the protocol ==
IPPROTO_UDP and that we at least have already traversed another ip(6)
protocol header.

The reason why we have to special case GSO_IPIP and GSO_SIT is that
we reset skb->encapsulation to 0 while skb_mac_gso_segment the inner
protocol of GSO_UDP_TUNNEL or GSO_GRE packets.

Reported-by: Wolfgang Walter <linux@stwm.de>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
Changelog v2:

* Instead of removing the comment "/* Note : following gso_segment() might
  change skb->encapsulation */" I just moved it to the ip6_offload.c file by
  accident.

 net/ipv4/af_inet.c     |  6 ++++--
 net/ipv6/ip6_offload.c | 19 +++++++++++--------
 2 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index ecd2c3f..4661649 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1296,8 +1296,10 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 
 	segs = ERR_PTR(-EPROTONOSUPPORT);
 
-	/* Note : following gso_segment() might change skb->encapsulation */
-	udpfrag = !skb->encapsulation && proto == IPPROTO_UDP;
+	if (skb_shinfo(skb)->gso_type & (SKB_GSO_SIT|SKB_GSO_IPIP))
+		udpfrag = proto == IPPROTO_UDP && encap;
+	else
+		udpfrag = proto == IPPROTO_UDP && !skb->encapsulation;
 
 	ops = rcu_dereference(inet_offloads[proto]);
 	if (likely(ops && ops->callbacks.gso_segment))
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 1e8683b..02281a1 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -89,7 +89,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 	unsigned int unfrag_ip6hlen;
 	u8 *prevhdr;
 	int offset = 0;
-	bool tunnel;
+	bool encap, udpfrag;
 	int nhoff;
 
 	if (unlikely(skb_shinfo(skb)->gso_type &
@@ -110,8 +110,8 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 	if (unlikely(!pskb_may_pull(skb, sizeof(*ipv6h))))
 		goto out;
 
-	tunnel = SKB_GSO_CB(skb)->encap_level > 0;
-	if (tunnel)
+	encap = SKB_GSO_CB(skb)->encap_level > 0;
+	if (encap)
 		features = skb->dev->hw_enc_features & netif_skb_features(skb);
 	SKB_GSO_CB(skb)->encap_level += sizeof(*ipv6h);
 
@@ -121,6 +121,11 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 
 	proto = ipv6_gso_pull_exthdrs(skb, ipv6h->nexthdr);
 
+	if (skb_shinfo(skb)->gso_type & (SKB_GSO_SIT|SKB_GSO_IPIP))
+		udpfrag = proto == IPPROTO_UDP && encap;
+	else
+		udpfrag = proto == IPPROTO_UDP && !skb->encapsulation;
+
 	ops = rcu_dereference(inet6_offloads[proto]);
 	if (likely(ops && ops->callbacks.gso_segment)) {
 		skb_reset_transport_header(skb);
@@ -133,13 +138,9 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 	for (skb = segs; skb; skb = skb->next) {
 		ipv6h = (struct ipv6hdr *)(skb_mac_header(skb) + nhoff);
 		ipv6h->payload_len = htons(skb->len - nhoff - sizeof(*ipv6h));
-		if (tunnel) {
-			skb_reset_inner_headers(skb);
-			skb->encapsulation = 1;
-		}
 		skb->network_header = (u8 *)ipv6h - skb->head;
 
-		if (!tunnel && proto == IPPROTO_UDP) {
+		if (udpfrag) {
 			unfrag_ip6hlen = ip6_find_1stfragopt(skb, &prevhdr);
 			fptr = (struct frag_hdr *)((u8 *)ipv6h + unfrag_ip6hlen);
 			fptr->frag_off = htons(offset);
@@ -148,6 +149,8 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 			offset += (ntohs(ipv6h->payload_len) -
 				   sizeof(struct frag_hdr));
 		}
+		if (encap)
+			skb_reset_inner_headers(skb);
 	}
 
 out:
-- 
1.8.5.3
