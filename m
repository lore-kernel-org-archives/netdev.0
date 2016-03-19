From: Jesse Gross <jesse@kernel.org>
Subject: [PATCH net v2 3/3] tunnels: Remove encapsulation offloads on decap.
Date: Sat, 19 Mar 2016 09:32:02 -0700
Message-ID: <1458405122-12565-4-git-send-email-jesse@kernel.org>
References: <1458405122-12565-1-git-send-email-jesse@kernel.org>
Cc: netdev@vger.kernel.org,
	Ramu Ramamurthy <sramamur@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:55660 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754586AbcCSQcs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Mar 2016 12:32:48 -0400
In-Reply-To: <1458405122-12565-1-git-send-email-jesse@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a packet is either locally encapsulated or processed through GRO
it is marked with the offloads that it requires. However, when it is
decapsulated these tunnel offload indications are not removed. This
means that if we receive an encapsulated TCP packet, aggregate it with
GRO, decapsulate, and retransmit the resulting frame on a NIC that does
not support encapsulation, we won't be able to take advantage of hardware
offloads even though it is just a simple TCP packet at this point.

This fixes the problem by stripping off encapsulation offload indications
when packets are decapsulated.

The performance impacts of this bug are significant. In a test where a
Geneve encapsulated TCP stream is sent to a hypervisor, GRO'ed, decapsulated,
and bridged to a VM performance is improved by 60% (5Gbps->8Gbps) as a
result of avoiding unnecessary segmentation at the VM tap interface.

Reported-by: Ramu Ramamurthy <sramamur@linux.vnet.ibm.com>
Fixes: 68c33163 ("v4 GRE: Add TCP segmentation offload for GRE")
Signed-off-by: Jesse Gross <jesse@kernel.org>
---
v2: Additional performance numbers in the commit message.
---
 include/net/ip_tunnels.h  | 16 ++++++++++++++++
 net/ipv4/fou.c            | 13 +++++++++++--
 net/ipv4/ip_tunnel_core.c |  3 ++-
 net/ipv6/sit.c            |  6 ++++--
 4 files changed, 33 insertions(+), 5 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index c35dda9..56050f9 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -305,6 +305,22 @@ struct metadata_dst *iptunnel_metadata_reply(struct metadata_dst *md,
 
 struct sk_buff *iptunnel_handle_offloads(struct sk_buff *skb, int gso_type_mask);
 
+static inline int iptunnel_pull_offloads(struct sk_buff *skb)
+{
+	if (skb_is_gso(skb)) {
+		int err;
+
+		err = skb_unclone(skb, GFP_ATOMIC);
+		if (unlikely(err))
+			return err;
+		skb_shinfo(skb)->gso_type &= ~(NETIF_F_GSO_ENCAP_ALL >>
+					       NETIF_F_GSO_SHIFT);
+	}
+
+	skb->encapsulation = 0;
+	return 0;
+}
+
 static inline void iptunnel_xmit_stats(struct net_device *dev, int pkt_len)
 {
 	if (pkt_len > 0) {
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 7804842..a0586b4 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -48,7 +48,7 @@ static inline struct fou *fou_from_sock(struct sock *sk)
 	return sk->sk_user_data;
 }
 
-static void fou_recv_pull(struct sk_buff *skb, size_t len)
+static int fou_recv_pull(struct sk_buff *skb, size_t len)
 {
 	struct iphdr *iph = ip_hdr(skb);
 
@@ -59,6 +59,7 @@ static void fou_recv_pull(struct sk_buff *skb, size_t len)
 	__skb_pull(skb, len);
 	skb_postpull_rcsum(skb, udp_hdr(skb), len);
 	skb_reset_transport_header(skb);
+	return iptunnel_pull_offloads(skb);
 }
 
 static int fou_udp_recv(struct sock *sk, struct sk_buff *skb)
@@ -68,9 +69,14 @@ static int fou_udp_recv(struct sock *sk, struct sk_buff *skb)
 	if (!fou)
 		return 1;
 
-	fou_recv_pull(skb, sizeof(struct udphdr));
+	if (fou_recv_pull(skb, sizeof(struct udphdr)))
+		goto drop;
 
 	return -fou->protocol;
+
+drop:
+	kfree_skb(skb);
+	return 0;
 }
 
 static struct guehdr *gue_remcsum(struct sk_buff *skb, struct guehdr *guehdr,
@@ -170,6 +176,9 @@ static int gue_udp_recv(struct sock *sk, struct sk_buff *skb)
 	__skb_pull(skb, sizeof(struct udphdr) + hdrlen);
 	skb_reset_transport_header(skb);
 
+	if (iptunnel_pull_offloads(skb))
+		goto drop;
+
 	return -guehdr->proto_ctype;
 
 drop:
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index d27276f..02dd990 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -114,7 +114,8 @@ int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto,
 	skb->vlan_tci = 0;
 	skb_set_queue_mapping(skb, 0);
 	skb_scrub_packet(skb, xnet);
-	return 0;
+
+	return iptunnel_pull_offloads(skb);
 }
 EXPORT_SYMBOL_GPL(iptunnel_pull_header);
 
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index f45b8ff..8338430 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -681,14 +681,16 @@ static int ipip6_rcv(struct sk_buff *skb)
 		skb->mac_header = skb->network_header;
 		skb_reset_network_header(skb);
 		IPCB(skb)->flags = 0;
-		skb->protocol = htons(ETH_P_IPV6);
+		skb->dev = tunnel->dev;
 
 		if (packet_is_spoofed(skb, iph, tunnel)) {
 			tunnel->dev->stats.rx_errors++;
 			goto out;
 		}
 
-		__skb_tunnel_rx(skb, tunnel->dev, tunnel->net);
+		if (iptunnel_pull_header(skb, 0, htons(ETH_P_IPV6),
+		    !net_eq(tunnel->net, dev_net(tunnel->dev))))
+			goto out;
 
 		err = IP_ECN_decapsulate(iph, skb);
 		if (unlikely(err)) {
-- 
2.5.0
