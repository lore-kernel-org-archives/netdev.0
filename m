From: Andy Zhou <azhou@nicira.com>
Subject: [net-next] iptunnel: Fix iptunnel_xmit return code for stats maintenance
Date: Mon, 20 Oct 2014 19:22:36 -0700
Message-ID: <1413858156-31763-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog105.obsmtp.com ([74.125.149.75]:36615 "HELO
	na3sys009aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753835AbaJUC3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2014 22:29:07 -0400
Received: by mail-pa0-f49.google.com with SMTP id hz1so343761pad.8
        for <netdev@vger.kernel.org>; Mon, 20 Oct 2014 19:29:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

iptunnel_xmit() currently always return >= 0 instead of proper error
code, that is used to maintain stats. For example, current return code
conflicts with how iptunnel_xmit_stats() maintains stats.

Unfortunately, the return code can not be changed without readjusting
how SKB memory is managed through the call chain.  The following two
rules are adopted for this patch:

1) Proper error code are always propagate back through the call chain
   so that the caller can maintain stats.

2) Tunnel xmit functions always free resources, e.g. skb and route
   entry.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 drivers/net/vxlan.c            |   21 +++++++++++++--------
 include/net/ip_tunnels.h       |    7 +++++++
 net/ipv4/geneve.c              |    8 ++++++--
 net/ipv4/ip_tunnel_core.c      |   14 +++++++++++---
 net/openvswitch/vport-geneve.c |    5 ++---
 net/openvswitch/vport-gre.c    |    1 +
 net/openvswitch/vport-vxlan.c  |    6 +++---
 net/openvswitch/vport.c        |    8 ++++----
 8 files changed, 47 insertions(+), 23 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index ca30982..93348cb 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1626,8 +1626,10 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 	bool udp_sum = !vs->sock->sk->sk_no_check_tx;
 
 	skb = udp_tunnel_handle_offloads(skb, udp_sum);
-	if (IS_ERR(skb))
-		return -EINVAL;
+	if (IS_ERR(skb)) {
+		err = -EINVAL;
+		goto error;
+	}
 
 	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
 			+ VXLAN_HLEN + sizeof(struct iphdr)
@@ -1636,13 +1638,15 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 	/* Need space for new headers (invalidates iph ptr) */
 	err = skb_cow_head(skb, min_headroom);
 	if (unlikely(err))
-		return err;
+		goto error;
 
 	if (vlan_tx_tag_present(skb)) {
 		if (WARN_ON(!__vlan_put_tag(skb,
 					    skb->vlan_proto,
-					    vlan_tx_tag_get(skb))))
-			return -ENOMEM;
+					    vlan_tx_tag_get(skb)))) {
+			err = -ENOMEM;
+			goto error;
+		}
 
 		skb->vlan_tci = 0;
 	}
@@ -1655,6 +1659,10 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 
 	return udp_tunnel_xmit_skb(vs->sock, rt, skb, src, dst, tos,
 				   ttl, df, src_port, dst_port, xnet);
+error:
+	kfree_skb(skb);
+	ip_rt_put(rt);
+	return err;
 }
 EXPORT_SYMBOL_GPL(vxlan_xmit_skb);
 
@@ -1786,9 +1794,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 				     tos, ttl, df, src_port, dst_port,
 				     htonl(vni << 8),
 				     !net_eq(vxlan->net, dev_net(vxlan->dev)));
-
-		if (err < 0)
-			goto rt_tx_error;
 		iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
 #if IS_ENABLED(CONFIG_IPV6)
 	} else {
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 5bc6ede..80bcf2e 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -174,6 +174,13 @@ static inline u8 ip_tunnel_ecn_encap(u8 tos, const struct iphdr *iph,
 }
 
 int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto);
+
+/* Transmit a packet over IP tunnel
+ * Returns:
+ *	0 Congestion notification received
+ *	>0  Number of bytes in the packet successfully sent
+ *	<0 packet dropped due to error
+ */
 int iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 		  __be32 src, __be32 dst, __u8 proto,
 		  __u8 tos, __u8 ttl, __be16 df, bool xnet);
diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve.c
index 065cd94..90fea48 100644
--- a/net/ipv4/geneve.c
+++ b/net/ipv4/geneve.c
@@ -129,14 +129,14 @@ int geneve_xmit_skb(struct geneve_sock *gs, struct rtable *rt,
 
 	err = skb_cow_head(skb, min_headroom);
 	if (unlikely(err))
-		return err;
+		goto error;
 
 	if (vlan_tx_tag_present(skb)) {
 		if (unlikely(!__vlan_put_tag(skb,
 					     skb->vlan_proto,
 					     vlan_tx_tag_get(skb)))) {
 			err = -ENOMEM;
-			return err;
+			goto error;
 		}
 		skb->vlan_tci = 0;
 	}
@@ -146,6 +146,10 @@ int geneve_xmit_skb(struct geneve_sock *gs, struct rtable *rt,
 
 	return udp_tunnel_xmit_skb(gs->sock, rt, skb, src, dst,
 				   tos, ttl, df, src_port, dst_port, xnet);
+error:
+	kfree_skb(skb);
+	ip_rt_put(rt);
+	return err;
 }
 EXPORT_SYMBOL_GPL(geneve_xmit_skb);
 
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 88c386c..b3ba4a3 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -77,9 +77,17 @@ int iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 	__ip_select_ident(iph, skb_shinfo(skb)->gso_segs ?: 1);
 
 	err = ip_local_out_sk(sk, skb);
-	if (unlikely(net_xmit_eval(err)))
-		pkt_len = 0;
-	return pkt_len;
+
+	/* Deal with positive error numbers. Filter out NET_XMIT_CN */
+	if (err > 0)
+		return net_xmit_errno(err);
+
+	/* Success, return number of bytes transmitted */
+	if (err == 0)
+		err = pkt_len;
+
+	/* Return pkt_len or an error code */
+	return err;
 }
 EXPORT_SYMBOL_GPL(iptunnel_xmit);
 
diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
index 106a9d8..34276fb 100644
--- a/net/openvswitch/vport-geneve.c
+++ b/net/openvswitch/vport-geneve.c
@@ -206,15 +206,14 @@ static int geneve_tnl_send(struct vport *vport, struct sk_buff *skb)
 	tunnel_id_to_vni(tun_key->tun_id, vni);
 	skb->ignore_df = 1;
 
-	err = geneve_xmit_skb(geneve_port->gs, rt, skb, fl.saddr,
+	return  geneve_xmit_skb(geneve_port->gs, rt, skb, fl.saddr,
 			      tun_key->ipv4_dst, tun_key->ipv4_tos,
 			      tun_key->ipv4_ttl, df, sport, dport,
 			      tun_key->tun_flags, vni,
 			      tun_info->options_len, (u8 *)tun_info->options,
 			      false);
-	if (err < 0)
-		ip_rt_put(rt);
 error:
+	kfree_skb(skb);
 	return err;
 }
 
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index 108b82d..8721b30 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -200,6 +200,7 @@ static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
 err_free_rt:
 	ip_rt_put(rt);
 error:
+	kfree_skb(skb);
 	return err;
 }
 
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index 2735e01..ace849a 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -174,15 +174,15 @@ static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
 
 	src_port = udp_flow_src_port(net, skb, 0, 0, true);
 
-	err = vxlan_xmit_skb(vxlan_port->vs, rt, skb,
+	return vxlan_xmit_skb(vxlan_port->vs, rt, skb,
 			     fl.saddr, tun_key->ipv4_dst,
 			     tun_key->ipv4_tos, tun_key->ipv4_ttl, df,
 			     src_port, dst_port,
 			     htonl(be64_to_cpu(tun_key->tun_id) << 8),
 			     false);
-	if (err < 0)
-		ip_rt_put(rt);
+
 error:
+	kfree_skb(skb);
 	return err;
 }
 
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 6015802..eb0a72f 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -480,11 +480,11 @@ int ovs_vport_send(struct vport *vport, struct sk_buff *skb)
 		stats->tx_packets++;
 		stats->tx_bytes += sent;
 		u64_stats_update_end(&stats->syncp);
-	} else if (sent < 0) {
-		ovs_vport_record_error(vport, VPORT_E_TX_ERROR);
-		kfree_skb(skb);
-	} else
+	} else if (sent == -ENOBUFS || sent == -ENOMEM || sent == 0) {
 		ovs_vport_record_error(vport, VPORT_E_TX_DROPPED);
+	} else {
+		ovs_vport_record_error(vport, VPORT_E_TX_ERROR);
+	}
 
 	return sent;
 }
-- 
1.7.9.5
