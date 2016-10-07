From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v3 1/6] openvswitch: make skb modifiable in ovs_flow_key_extract*
Date: Fri,  7 Oct 2016 18:07:36 +0200
Message-ID: <1040cca98ef1f2c5b721c5027314e2ba0b842f42.1475855896.git.jbenc@redhat.com>
References: <cover.1475855896.git.jbenc@redhat.com>
Cc: pravin shelar <pshelar@ovn.org>, Eric Garver <e@erig.me>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52878 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754556AbcJGQHx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Oct 2016 12:07:53 -0400
In-Reply-To: <cover.1475855896.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow ovs_flow_key_extract and ovs_flow_key_extract_userspace to modify the
skb. This will be used by the following patch to move vlan tag to the
vlan_tci field.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
v3: new in v3
---
 net/openvswitch/datapath.c |  9 ++++++---
 net/openvswitch/flow.c     | 33 +++++++++++++++++++++++++--------
 net/openvswitch/flow.h     | 14 ++++++++------
 net/openvswitch/vport.c    |  8 +++-----
 4 files changed, 42 insertions(+), 22 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 4d67ea856067..3469a8df3d5e 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -607,10 +607,13 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	if (IS_ERR(flow))
 		goto err_kfree_skb;
 
-	err = ovs_flow_key_extract_userspace(net, a[OVS_PACKET_ATTR_KEY],
-					     packet, &flow->key, log);
-	if (err)
+	packet = ovs_flow_key_extract_userspace(net, a[OVS_PACKET_ATTR_KEY],
+						packet, &flow->key, log);
+	if (IS_ERR(packet)) {
+		err = PTR_ERR(packet);
+		packet = NULL;
 		goto err_flow_free;
+	}
 
 	err = ovs_nla_copy_actions(net, a[OVS_PACKET_ATTR_ACTIONS],
 				   &flow->key, &acts, log);
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index c8c82e109c68..f358608dd33d 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -721,9 +721,12 @@ int ovs_flow_key_update(struct sk_buff *skb, struct sw_flow_key *key)
 	return key_extract(skb, key);
 }
 
-int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
-			 struct sk_buff *skb, struct sw_flow_key *key)
+struct sk_buff *ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
+				     struct sk_buff *skb,
+				     struct sw_flow_key *key)
 {
+	int err;
+
 	/* Extract metadata from packet. */
 	if (tun_info) {
 		key->tun_proto = ip_tunnel_info_af(tun_info);
@@ -753,19 +756,33 @@ int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
 	key->ovs_flow_hash = 0;
 	key->recirc_id = 0;
 
-	return key_extract(skb, key);
+	err = key_extract(skb, key);
+	if (err) {
+		kfree_skb(skb);
+		return ERR_PTR(err);
+	}
+	return skb;
 }
 
-int ovs_flow_key_extract_userspace(struct net *net, const struct nlattr *attr,
-				   struct sk_buff *skb,
-				   struct sw_flow_key *key, bool log)
+struct sk_buff *ovs_flow_key_extract_userspace(struct net *net,
+					       const struct nlattr *attr,
+					       struct sk_buff *skb,
+					       struct sw_flow_key *key,
+					       bool log)
 {
 	int err;
 
 	/* Extract metadata from netlink attributes. */
 	err = ovs_nla_get_flow_metadata(net, attr, key, log);
 	if (err)
-		return err;
+		goto err_free;
 
-	return key_extract(skb, key);
+	err = key_extract(skb, key);
+	if (err)
+		goto err_free;
+	return skb;
+
+err_free:
+	kfree_skb(skb);
+	return ERR_PTR(err);
 }
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index ae783f5c6695..7eb251f1471f 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -224,12 +224,14 @@ void ovs_flow_stats_clear(struct sw_flow *);
 u64 ovs_flow_used_time(unsigned long flow_jiffies);
 
 int ovs_flow_key_update(struct sk_buff *skb, struct sw_flow_key *key);
-int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
-			 struct sk_buff *skb,
-			 struct sw_flow_key *key);
+struct sk_buff *ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
+				     struct sk_buff *skb,
+				     struct sw_flow_key *key);
 /* Extract key from packet coming from userspace. */
-int ovs_flow_key_extract_userspace(struct net *net, const struct nlattr *attr,
-				   struct sk_buff *skb,
-				   struct sw_flow_key *key, bool log);
+struct sk_buff *ovs_flow_key_extract_userspace(struct net *net,
+					       const struct nlattr *attr,
+					       struct sk_buff *skb,
+					       struct sw_flow_key *key,
+					       bool log);
 
 #endif /* flow.h */
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 8f198437c724..8aefcb20cc58 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -455,11 +455,9 @@ int ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
 	}
 
 	/* Extract flow from 'skb' into 'key'. */
-	error = ovs_flow_key_extract(tun_info, skb, &key);
-	if (unlikely(error)) {
-		kfree_skb(skb);
-		return error;
-	}
+	skb = ovs_flow_key_extract(tun_info, skb, &key);
+	if (IS_ERR(skb))
+		return PTR_ERR(skb);
 	ovs_dp_process_packet(skb, &key);
 	return 0;
 }
-- 
1.8.3.1
