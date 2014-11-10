From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 4/6] openvswitch: Remove redundant key ref from upcall_info.
Date: Sun,  9 Nov 2014 19:59:19 -0800
Message-ID: <1415591959-1651-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog136.obsmtp.com ([74.125.149.85]:57799 "HELO
	na3sys009aog136.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752088AbaKJD7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2014 22:59:21 -0500
Received: by mail-pd0-f173.google.com with SMTP id v10so6958619pde.18
        for <netdev@vger.kernel.org>; Sun, 09 Nov 2014 19:59:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct dp_upcall_info has pointer to pkt_key which is already
available in OVS_CB.  This also simplifies upcall handling
for gso packet.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Acked-by: Andy Zhou <azhou@nicira.com>
---
 net/openvswitch/actions.c  |  3 +--
 net/openvswitch/datapath.c | 45 ++++++++++++++++++++++++++-------------------
 net/openvswitch/datapath.h | 12 +++++-------
 3 files changed, 32 insertions(+), 28 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index d4c2f73..10c94ac 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -624,7 +624,6 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 	int rem;
 
 	upcall.cmd = OVS_PACKET_CMD_ACTION;
-	upcall.key = key;
 	upcall.userdata = NULL;
 	upcall.portid = 0;
 	upcall.egress_tun_info = NULL;
@@ -659,7 +658,7 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 		} /* End of switch. */
 	}
 
-	return ovs_dp_upcall(dp, skb, &upcall);
+	return ovs_dp_upcall(dp, skb, key, &upcall);
 }
 
 static int sample(struct datapath *dp, struct sk_buff *skb,
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index c2ac340..7146b38 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -136,8 +136,10 @@ EXPORT_SYMBOL_GPL(lockdep_ovsl_is_held);
 
 static struct vport *new_vport(const struct vport_parms *);
 static int queue_gso_packets(struct datapath *dp, struct sk_buff *,
+			     const struct sw_flow_key *,
 			     const struct dp_upcall_info *);
 static int queue_userspace_packet(struct datapath *dp, struct sk_buff *,
+				  const struct sw_flow_key *,
 				  const struct dp_upcall_info *);
 
 /* Must be called with rcu_read_lock. */
@@ -271,11 +273,10 @@ void ovs_dp_process_packet(struct sk_buff *skb, struct sw_flow_key *key)
 		int error;
 
 		upcall.cmd = OVS_PACKET_CMD_MISS;
-		upcall.key = key;
 		upcall.userdata = NULL;
 		upcall.portid = ovs_vport_find_upcall_portid(p, skb);
 		upcall.egress_tun_info = NULL;
-		error = ovs_dp_upcall(dp, skb, &upcall);
+		error = ovs_dp_upcall(dp, skb, key, &upcall);
 		if (unlikely(error))
 			kfree_skb(skb);
 		else
@@ -299,6 +300,7 @@ out:
 }
 
 int ovs_dp_upcall(struct datapath *dp, struct sk_buff *skb,
+		  const struct sw_flow_key *key,
 		  const struct dp_upcall_info *upcall_info)
 {
 	struct dp_stats_percpu *stats;
@@ -310,9 +312,9 @@ int ovs_dp_upcall(struct datapath *dp, struct sk_buff *skb,
 	}
 
 	if (!skb_is_gso(skb))
-		err = queue_userspace_packet(dp, skb, upcall_info);
+		err = queue_userspace_packet(dp, skb, key, upcall_info);
 	else
-		err = queue_gso_packets(dp, skb, upcall_info);
+		err = queue_gso_packets(dp, skb, key, upcall_info);
 	if (err)
 		goto err;
 
@@ -329,39 +331,43 @@ err:
 }
 
 static int queue_gso_packets(struct datapath *dp, struct sk_buff *skb,
+			     const struct sw_flow_key *key,
 			     const struct dp_upcall_info *upcall_info)
 {
 	unsigned short gso_type = skb_shinfo(skb)->gso_type;
-	struct dp_upcall_info later_info;
 	struct sw_flow_key later_key;
 	struct sk_buff *segs, *nskb;
+	struct ovs_skb_cb ovs_cb;
 	int err;
 
+	ovs_cb = *OVS_CB(skb);
 	segs = __skb_gso_segment(skb, NETIF_F_SG, false);
+	*OVS_CB(skb) = ovs_cb;
 	if (IS_ERR(segs))
 		return PTR_ERR(segs);
 	if (segs == NULL)
 		return -EINVAL;
 
+	if (gso_type & SKB_GSO_UDP) {
+		/* The initial flow key extracted by ovs_flow_key_extract()
+		 * in this case is for a first fragment, so we need to
+		 * properly mark later fragments.
+		 */
+		later_key = *key;
+		later_key.ip.frag = OVS_FRAG_TYPE_LATER;
+	}
+
 	/* Queue all of the segments. */
 	skb = segs;
 	do {
-		err = queue_userspace_packet(dp, skb, upcall_info);
+		*OVS_CB(skb) = ovs_cb;
+		if (gso_type & SKB_GSO_UDP && skb != segs)
+			key = &later_key;
+
+		err = queue_userspace_packet(dp, skb, key, upcall_info);
 		if (err)
 			break;
 
-		if (skb == segs && gso_type & SKB_GSO_UDP) {
-			/* The initial flow key extracted by ovs_flow_extract()
-			 * in this case is for a first fragment, so we need to
-			 * properly mark later fragments.
-			 */
-			later_key = *upcall_info->key;
-			later_key.ip.frag = OVS_FRAG_TYPE_LATER;
-
-			later_info = *upcall_info;
-			later_info.key = &later_key;
-			upcall_info = &later_info;
-		}
 	} while ((skb = skb->next));
 
 	/* Free all of the segments. */
@@ -395,6 +401,7 @@ static size_t upcall_msg_size(const struct dp_upcall_info *upcall_info,
 }
 
 static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
+				  const struct sw_flow_key *key,
 				  const struct dp_upcall_info *upcall_info)
 {
 	struct ovs_header *upcall;
@@ -457,7 +464,7 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 	upcall->dp_ifindex = dp_ifindex;
 
 	nla = nla_nest_start(user_skb, OVS_PACKET_ATTR_KEY);
-	err = ovs_nla_put_flow(upcall_info->key, upcall_info->key, user_skb);
+	err = ovs_nla_put_flow(key, key, user_skb);
 	BUG_ON(err);
 	nla_nest_end(user_skb, nla);
 
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 2bc577b..8de9f7e 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -108,20 +108,18 @@ struct ovs_skb_cb {
 /**
  * struct dp_upcall - metadata to include with a packet to send to userspace
  * @cmd: One of %OVS_PACKET_CMD_*.
- * @key: Becomes %OVS_PACKET_ATTR_KEY.  Must be nonnull.
  * @userdata: If nonnull, its variable-length value is passed to userspace as
  * %OVS_PACKET_ATTR_USERDATA.
- * @pid: Netlink PID to which packet should be sent.  If @pid is 0 then no
- * packet is sent and the packet is accounted in the datapath's @n_lost
+ * @portid: Netlink portid to which packet should be sent.  If @portid is 0
+ * then no packet is sent and the packet is accounted in the datapath's @n_lost
  * counter.
  * @egress_tun_info: If nonnull, becomes %OVS_PACKET_ATTR_EGRESS_TUN_KEY.
  */
 struct dp_upcall_info {
-	u8 cmd;
-	const struct sw_flow_key *key;
+	const struct ovs_tunnel_info *egress_tun_info;
 	const struct nlattr *userdata;
 	u32 portid;
-	const struct ovs_tunnel_info *egress_tun_info;
+	u8 cmd;
 };
 
 /**
@@ -187,7 +185,7 @@ extern struct genl_family dp_vport_genl_family;
 void ovs_dp_process_packet(struct sk_buff *skb, struct sw_flow_key *key);
 void ovs_dp_detach_port(struct vport *);
 int ovs_dp_upcall(struct datapath *, struct sk_buff *,
-		  const struct dp_upcall_info *);
+		  const struct sw_flow_key *, const struct dp_upcall_info *);
 
 const char *ovs_dp_name(const struct datapath *dp);
 struct sk_buff *ovs_vport_cmd_build_info(struct vport *, u32 pid, u32 seq,
-- 
1.9.3
