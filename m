From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net 5/6] openvswitch: Fix vport_send double free
Date: Tue, 23 Dec 2014 16:20:32 -0800
Message-ID: <1419380432-1665-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog124.obsmtp.com ([74.125.149.151]:36746 "HELO
	na3sys009aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755294AbaLXAUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2014 19:20:35 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so8867787pab.6
        for <netdev@vger.kernel.org>; Tue, 23 Dec 2014 16:20:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Today vport-send has complex error handling because it involves
freeing skb and updating stats depending on return value from
vport send implementation.
This can be simplified by delegating responsibility of freeing
skb to the vport implementation for all cases. So that
vport-send needs just update stats.

Fixes: 91b7514cdf ("openvswitch: Unify vport error stats
handling")
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/ipv4/geneve.c              |    6 +++++-
 net/openvswitch/vport-geneve.c |    3 +++
 net/openvswitch/vport-gre.c    |   18 +++++++++++-------
 net/openvswitch/vport-vxlan.c  |    2 ++
 net/openvswitch/vport.c        |    5 ++---
 5 files changed, 23 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve.c
index 95e47c9..394a200 100644
--- a/net/ipv4/geneve.c
+++ b/net/ipv4/geneve.c
@@ -122,14 +122,18 @@ int geneve_xmit_skb(struct geneve_sock *gs, struct rtable *rt,
 	int err;
 
 	skb = udp_tunnel_handle_offloads(skb, !gs->sock->sk->sk_no_check_tx);
+	if (IS_ERR(skb))
+		return PTR_ERR(skb);
 
 	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
 			+ GENEVE_BASE_HLEN + opt_len + sizeof(struct iphdr)
 			+ (vlan_tx_tag_present(skb) ? VLAN_HLEN : 0);
 
 	err = skb_cow_head(skb, min_headroom);
-	if (unlikely(err))
+	if (unlikely(err)) {
+		kfree_skb(skb);
 		return err;
+	}
 
 	skb = vlan_hwaccel_push_inside(skb);
 	if (unlikely(!skb))
diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
index 347fa23..484864d 100644
--- a/net/openvswitch/vport-geneve.c
+++ b/net/openvswitch/vport-geneve.c
@@ -219,7 +219,10 @@ static int geneve_tnl_send(struct vport *vport, struct sk_buff *skb)
 			      false);
 	if (err < 0)
 		ip_rt_put(rt);
+	return err;
+
 error:
+	kfree_skb(skb);
 	return err;
 }
 
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index 6b69df5..28f54e9 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -73,7 +73,7 @@ static struct sk_buff *__build_header(struct sk_buff *skb,
 
 	skb = gre_handle_offloads(skb, !!(tun_key->tun_flags & TUNNEL_CSUM));
 	if (IS_ERR(skb))
-		return NULL;
+		return skb;
 
 	tpi.flags = filter_tnl_flags(tun_key->tun_flags);
 	tpi.proto = htons(ETH_P_TEB);
@@ -144,7 +144,7 @@ static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
 
 	if (unlikely(!OVS_CB(skb)->egress_tun_info)) {
 		err = -EINVAL;
-		goto error;
+		goto err_free_skb;
 	}
 
 	tun_key = &OVS_CB(skb)->egress_tun_info->tunnel;
@@ -157,8 +157,10 @@ static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
 	fl.flowi4_proto = IPPROTO_GRE;
 
 	rt = ip_route_output_key(net, &fl);
-	if (IS_ERR(rt))
-		return PTR_ERR(rt);
+	if (IS_ERR(rt)) {
+		err = PTR_ERR(rt);
+		goto err_free_skb;
+	}
 
 	tunnel_hlen = ip_gre_calc_hlen(tun_key->tun_flags);
 
@@ -183,8 +185,9 @@ static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
 
 	/* Push Tunnel header. */
 	skb = __build_header(skb, tunnel_hlen);
-	if (unlikely(!skb)) {
-		err = 0;
+	if (IS_ERR(skb)) {
+		err = PTR_ERR(rt);
+		skb = NULL;
 		goto err_free_rt;
 	}
 
@@ -198,7 +201,8 @@ static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
 			     tun_key->ipv4_tos, tun_key->ipv4_ttl, df, false);
 err_free_rt:
 	ip_rt_put(rt);
-error:
+err_free_skb:
+	kfree_skb(skb);
 	return err;
 }
 
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index 38f95a5..d7c46b3 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -187,7 +187,9 @@ static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
 			     false);
 	if (err < 0)
 		ip_rt_put(rt);
+	return err;
 error:
+	kfree_skb(skb);
 	return err;
 }
 
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 9584526..53f3ebb 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -519,10 +519,9 @@ int ovs_vport_send(struct vport *vport, struct sk_buff *skb)
 		u64_stats_update_end(&stats->syncp);
 	} else if (sent < 0) {
 		ovs_vport_record_error(vport, VPORT_E_TX_ERROR);
-		kfree_skb(skb);
-	} else
+	} else {
 		ovs_vport_record_error(vport, VPORT_E_TX_DROPPED);
-
+	}
 	return sent;
 }
 
-- 
1.7.1
