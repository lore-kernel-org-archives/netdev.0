From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: Remove VRF change to udp_sendmsg
Date: Mon, 31 Aug 2015 09:29:40 -0700
Message-ID: <1441038580-44164-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, tom@herbertland.com,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34296 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752107AbbHaQ3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 12:29:47 -0400
Received: by pabzx8 with SMTP id zx8so144355878pab.1
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2015 09:29:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the VRF change in udp_sendmsg to set the source address. The VRF
driver already has access to the packet on the TX path via the dst. It
can be used to update the source address in the header.

Update function based on OVS.

Cc: Tom Herbert <tom@herbertland.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c | 63 ++++++++++++++++++++++++++++++++++++++++++++++++++-----
 net/ipv4/udp.c    | 18 ----------------
 2 files changed, 58 insertions(+), 23 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index e7094fbd7568..169418254636 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -160,6 +160,58 @@ static netdev_tx_t vrf_process_v6_outbound(struct sk_buff *skb,
 	return NET_XMIT_DROP;
 }
 
+static void update_ipv4_saddr(struct sk_buff *skb, struct iphdr *iph,
+			      __be32 new_addr)
+{
+	int tlen = skb->len - skb_transport_offset(skb);
+
+	if (iph->protocol == IPPROTO_TCP) {
+		if (likely(tlen >= sizeof(struct tcphdr))) {
+			inet_proto_csum_replace4(&tcp_hdr(skb)->check, skb,
+						 iph->saddr, new_addr, 1);
+		}
+	} else if (iph->protocol == IPPROTO_UDP) {
+		if (likely(tlen >= sizeof(struct udphdr))) {
+			struct udphdr *uh = udp_hdr(skb);
+
+			if (uh->check || skb->ip_summed == CHECKSUM_PARTIAL) {
+				inet_proto_csum_replace4(&uh->check, skb,
+							 iph->saddr, new_addr,
+							 1);
+			if (!uh->check)
+				uh->check = CSUM_MANGLED_0;
+			}
+		}
+	}
+
+	csum_replace4(&iph->check, iph->saddr, new_addr);
+	skb_clear_hash(skb);
+	iph->saddr = new_addr;
+}
+
+static int vrf_set_ip_saddr(struct sk_buff *skb, struct net_device *dev)
+{
+	struct iphdr *ip4h = ip_hdr(skb);
+	struct flowi4 fl4 = {
+		.flowi4_oif = dev->ifindex,
+		.flowi4_iif = LOOPBACK_IFINDEX,
+		.flowi4_tos = RT_TOS(ip4h->tos),
+		.flowi4_flags = FLOWI_FLAG_ANYSRC | FLOWI_FLAG_VRFSRC,
+		.daddr = ip4h->daddr,
+	};
+	struct rtable *rt;
+
+	rt = __ip_route_output_key(dev_net(dev), &fl4);
+	if (IS_ERR(rt))
+		return 1;
+
+	ip_rt_put(rt);
+
+	update_ipv4_saddr(skb, ip4h, fl4.saddr);
+
+	return 0;
+}
+
 static int vrf_send_v4_prep(struct sk_buff *skb, struct flowi4 *fl4,
 			    struct net_device *vrf_dev)
 {
@@ -200,11 +252,6 @@ static netdev_tx_t vrf_process_v4_outbound(struct sk_buff *skb,
 	if (vrf_send_v4_prep(skb, &fl4, vrf_dev))
 		goto err;
 
-	if (!ip4h->saddr) {
-		ip4h->saddr = inet_select_addr(skb_dst(skb)->dev, 0,
-					       RT_SCOPE_LINK);
-	}
-
 	ret = ip_local_out(skb);
 	if (unlikely(net_xmit_eval(ret)))
 		vrf_dev->stats.tx_errors++;
@@ -298,12 +345,18 @@ static int vrf_finish_output(struct sock *sk, struct sk_buff *skb)
 static int vrf_output(struct sock *sk, struct sk_buff *skb)
 {
 	struct net_device *dev = skb_dst(skb)->dev;
+	struct iphdr *iph = ip_hdr(skb);
 
 	IP_UPD_PO_STATS(dev_net(dev), IPSTATS_MIB_OUT, skb->len);
 
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_IP);
 
+	if (!iph->saddr && vrf_set_ip_saddr(skb, dev)) {
+		vrf_tx_error(dev, skb);
+		return -EINVAL;
+	}
+
 	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING, sk, skb,
 			    NULL, dev,
 			    vrf_finish_output,
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index c0a15e7f359f..ee3ba30f1ca5 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1017,24 +1017,6 @@ int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 
 		fl4 = &fl4_stack;
 
-		/* unconnected socket. If output device is enslaved to a VRF
-		 * device lookup source address from VRF table. This mimics
-		 * behavior of ip_route_connect{_init}.
-		 */
-		if (netif_index_is_vrf(net, ipc.oif)) {
-			flowi4_init_output(fl4, ipc.oif, sk->sk_mark, tos,
-					   RT_SCOPE_UNIVERSE, sk->sk_protocol,
-					   (flow_flags | FLOWI_FLAG_VRFSRC),
-					   faddr, saddr, dport,
-					   inet->inet_sport);
-
-			rt = ip_route_output_flow(net, fl4, sk);
-			if (!IS_ERR(rt)) {
-				saddr = fl4->saddr;
-				ip_rt_put(rt);
-			}
-		}
-
 		flowi4_init_output(fl4, ipc.oif, sk->sk_mark, tos,
 				   RT_SCOPE_UNIVERSE, sk->sk_protocol,
 				   flow_flags,
-- 
1.9.1
