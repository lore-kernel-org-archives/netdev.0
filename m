From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 2/4] openvswitch: Remove egress_tun_info.
Date: Sat, 29 Aug 2015 17:44:06 -0700
Message-ID: <1440895448-16363-3-git-send-email-pshelar@nicira.com>
References: <1440895448-16363-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36159 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753087AbbH3AoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2015 20:44:17 -0400
Received: by pacgr6 with SMTP id gr6so3115798pac.3
        for <netdev@vger.kernel.org>; Sat, 29 Aug 2015 17:44:17 -0700 (PDT)
In-Reply-To: <1440895448-16363-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tun info is passed using skb-dst pointer. Now we have
converted all vports to netdev based implementation so
Now we can remove redundant pointer to tun-info from OVS_CB.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/actions.c      |    5 -----
 net/openvswitch/datapath.c     |    1 -
 net/openvswitch/datapath.h     |    3 ---
 net/openvswitch/vport-geneve.c |    3 +--
 net/openvswitch/vport-gre.c    |    3 +--
 net/openvswitch/vport-vxlan.c  |    3 +--
 net/openvswitch/vport.c        |    6 +++---
 net/openvswitch/vport.h        |    3 +--
 8 files changed, 7 insertions(+), 20 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 4487543..090d9e3 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -896,10 +896,6 @@ static int execute_set_action(struct sk_buff *skb,
 		skb_dst_drop(skb);
 		dst_hold((struct dst_entry *)tun->tun_dst);
 		skb_dst_set(skb, (struct dst_entry *)tun->tun_dst);
-
-		/* FIXME: Remove when all vports have been converted */
-		OVS_CB(skb)->egress_tun_info = &tun->tun_dst->u.tun_info;
-
 		return 0;
 	}
 
@@ -1159,7 +1155,6 @@ int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb,
 	int err;
 
 	this_cpu_inc(exec_actions_level);
-	OVS_CB(skb)->egress_tun_info = NULL;
 	err = do_execute_actions(dp, skb, key,
 				 acts->actions, acts->actions_len);
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index ec0f8d9..60c2ab8 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -610,7 +610,6 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 		goto err_flow_free;
 
 	rcu_assign_pointer(flow->sf_acts, acts);
-	OVS_CB(packet)->egress_tun_info = NULL;
 	packet->priority = flow->key.phy.priority;
 	packet->mark = flow->key.phy.skb_mark;
 
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 4e785ab..da15fd3 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -94,15 +94,12 @@ struct datapath {
 
 /**
  * struct ovs_skb_cb - OVS data in skb CB
- * @egress_tun_key: Tunnel information about this packet on egress path.
- * NULL if the packet is not being tunneled.
  * @input_vport: The original vport packet came in on. This value is cached
  * when a packet is received by OVS.
  * @mru: The maximum received fragement size; 0 if the packet is not
  * fragmented.
  */
 struct ovs_skb_cb {
-	struct ip_tunnel_info  *egress_tun_info;
 	struct vport		*input_vport;
 	u16			mru;
 };
diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
index fa37c95..24c56e5 100644
--- a/net/openvswitch/vport-geneve.c
+++ b/net/openvswitch/vport-geneve.c
@@ -62,8 +62,7 @@ static int geneve_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
 
 	return ovs_tunnel_get_egress_info(egress_tun_info,
 					  ovs_dp_get_net(vport->dp),
-					  OVS_CB(skb)->egress_tun_info,
-					  IPPROTO_UDP, skb->mark, sport, dport);
+					  skb, IPPROTO_UDP, sport, dport);
 }
 
 static struct vport *geneve_tnl_create(const struct vport_parms *parms)
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index 871801d..36c3984 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -89,8 +89,7 @@ static int gre_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
 {
 	return ovs_tunnel_get_egress_info(egress_tun_info,
 					  ovs_dp_get_net(vport->dp),
-					  OVS_CB(skb)->egress_tun_info,
-					  IPPROTO_GRE, skb->mark, 0, 0);
+					  skb, IPPROTO_GRE, 0, 0);
 }
 
 static struct vport_ops ovs_gre_vport_ops = {
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index 1e8b00a..ed7b23f 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -160,8 +160,7 @@ static int vxlan_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
 	src_port = udp_flow_src_port(net, skb, 0, 0, true);
 
 	return ovs_tunnel_get_egress_info(egress_tun_info, net,
-					  OVS_CB(skb)->egress_tun_info,
-					  IPPROTO_UDP, skb->mark,
+					  skb, IPPROTO_UDP,
 					  src_port, dst_port);
 }
 
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index e2dc9da..bd118f2 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -483,7 +483,6 @@ void ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
 	u64_stats_update_end(&stats->syncp);
 
 	OVS_CB(skb)->input_vport = vport;
-	OVS_CB(skb)->egress_tun_info = NULL;
 	OVS_CB(skb)->mru = 0;
 	/* Extract flow from 'skb' into 'key'. */
 	error = ovs_flow_key_extract(tun_info, skb, &key);
@@ -575,13 +574,14 @@ EXPORT_SYMBOL_GPL(ovs_vport_deferred_free);
 
 int ovs_tunnel_get_egress_info(struct ip_tunnel_info *egress_tun_info,
 			       struct net *net,
-			       const struct ip_tunnel_info *tun_info,
+			       struct sk_buff *skb,
 			       u8 ipproto,
-			       u32 skb_mark,
 			       __be16 tp_src,
 			       __be16 tp_dst)
 {
+	const struct ip_tunnel_info *tun_info = skb_tunnel_info(skb);
 	const struct ip_tunnel_key *tun_key;
+	u32 skb_mark = skb->mark;
 	struct rtable *rt;
 	struct flowi4 fl;
 
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 2f35244..a36aef2 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -61,9 +61,8 @@ int ovs_vport_send(struct vport *, struct sk_buff *);
 
 int ovs_tunnel_get_egress_info(struct ip_tunnel_info *egress_tun_info,
 			       struct net *net,
-			       const struct ip_tunnel_info *tun_info,
+			       struct sk_buff *,
 			       u8 ipproto,
-			       u32 skb_mark,
 			       __be16 tp_src,
 			       __be16 tp_dst);
 int ovs_vport_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
-- 
1.7.1
