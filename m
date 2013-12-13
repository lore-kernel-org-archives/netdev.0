From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 4/6] openvswitch: Pass datapath into userspace queue functions
Date: Fri, 13 Dec 2013 15:22:20 +0100
Message-ID: <b57ab263da3b567afc78f746bbddbd5cc3ebe87c.1386943635.git.tgraf@suug.ch>
References: <cover.1386943635.git.tgraf@suug.ch>
Cc: dev@openvswitch.org, eric.dumazet@gmail.com, fleitner@redhat.com,
	ffusco@redhat.com, dborkmann@redhat.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, davem@davemloft.net
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:43934 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752718Ab3LMOWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 09:22:42 -0500
In-Reply-To: <cover.1386943635.git.tgraf@suug.ch>
In-Reply-To: <cover.1386943635.git.tgraf@suug.ch>
References: <cover.1386943635.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allows removing the net and dp_ifindex argument and simplify the
code.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/openvswitch/datapath.c | 34 ++++++++++++++--------------------
 1 file changed, 14 insertions(+), 20 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 8eaa39a..8f6318c 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -108,10 +108,9 @@ int lockdep_ovsl_is_held(void)
 #endif
 
 static struct vport *new_vport(const struct vport_parms *);
-static int queue_gso_packets(struct net *, int dp_ifindex, struct sk_buff *,
+static int queue_gso_packets(struct datapath *dp, struct sk_buff *,
 			     const struct dp_upcall_info *);
-static int queue_userspace_packet(struct net *, int dp_ifindex,
-				  struct sk_buff *,
+static int queue_userspace_packet(struct datapath *dp, struct sk_buff *,
 				  const struct dp_upcall_info *);
 
 /* Must be called with rcu_read_lock or ovs_mutex. */
@@ -277,7 +276,6 @@ int ovs_dp_upcall(struct datapath *dp, struct sk_buff *skb,
 		  const struct dp_upcall_info *upcall_info)
 {
 	struct dp_stats_percpu *stats;
-	int dp_ifindex;
 	int err;
 
 	if (upcall_info->portid == 0) {
@@ -285,16 +283,10 @@ int ovs_dp_upcall(struct datapath *dp, struct sk_buff *skb,
 		goto err;
 	}
 
-	dp_ifindex = get_dpifindex(dp);
-	if (!dp_ifindex) {
-		err = -ENODEV;
-		goto err;
-	}
-
 	if (!skb_is_gso(skb))
-		err = queue_userspace_packet(ovs_dp_get_net(dp), dp_ifindex, skb, upcall_info);
+		err = queue_userspace_packet(dp, skb, upcall_info);
 	else
-		err = queue_gso_packets(ovs_dp_get_net(dp), dp_ifindex, skb, upcall_info);
+		err = queue_gso_packets(dp, skb, upcall_info);
 	if (err)
 		goto err;
 
@@ -310,8 +302,7 @@ err:
 	return err;
 }
 
-static int queue_gso_packets(struct net *net, int dp_ifindex,
-			     struct sk_buff *skb,
+static int queue_gso_packets(struct datapath *dp, struct sk_buff *skb,
 			     const struct dp_upcall_info *upcall_info)
 {
 	unsigned short gso_type = skb_shinfo(skb)->gso_type;
@@ -327,7 +318,7 @@ static int queue_gso_packets(struct net *net, int dp_ifindex,
 	/* Queue all of the segments. */
 	skb = segs;
 	do {
-		err = queue_userspace_packet(net, dp_ifindex, skb, upcall_info);
+		err = queue_userspace_packet(dp, skb, upcall_info);
 		if (err)
 			break;
 
@@ -394,8 +385,7 @@ static size_t upcall_msg_size(const struct sk_buff *skb,
 	return size;
 }
 
-static int queue_userspace_packet(struct net *net, int dp_ifindex,
-				  struct sk_buff *skb,
+static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 				  const struct dp_upcall_info *upcall_info)
 {
 	struct ovs_header *upcall;
@@ -403,11 +393,15 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
 	struct sk_buff *user_skb; /* to be queued to userspace */
 	struct nlattr *nla;
 	struct genl_info info = {
-		.dst_sk = net->genl_sock,
+		.dst_sk = ovs_dp_get_net(dp)->genl_sock,
 		.snd_portid = upcall_info->portid,
 	};
 	size_t len;
-	int err;
+	int err, dp_ifindex;
+
+	dp_ifindex = get_dpifindex(dp);
+	if (!dp_ifindex)
+		return -ENODEV;
 
 	if (vlan_tx_tag_present(skb)) {
 		nskb = skb_clone(skb, GFP_ATOMIC);
@@ -452,7 +446,7 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
 	skb_copy_and_csum_dev(skb, nla_data(nla));
 
 	genlmsg_end(user_skb, upcall);
-	err = genlmsg_unicast(net, user_skb, upcall_info->portid);
+	err = genlmsg_unicast(ovs_dp_get_net(dp), user_skb, upcall_info->portid);
 
 out:
 	kfree_skb(nskb);
-- 
1.8.3.1
