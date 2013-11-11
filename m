From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/3 net-next] openvswitch: Use skb_zerocopy() for upcall
Date: Mon, 11 Nov 2013 16:47:44 +0100
Message-ID: <256348abee81e159c3ad558f39a09ebc8db04e4e.1384184208.git.tgraf@suug.ch>
References: <cover.1384184208.git.tgraf@suug.ch>
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, dborkman@redhat.com,
	bhutchings@solarflare.com
To: jesse@nicira.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:37139 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754674Ab3KKPsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 10:48:00 -0500
In-Reply-To: <cover.1384184208.git.tgraf@suug.ch>
In-Reply-To: <cover.1384184208.git.tgraf@suug.ch>
References: <cover.1384184208.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use of skb_zerocopy() avoids the expensive call to memcpy() when
copying the packet data into the Netlink skb. Completes checksum
through skb_checksum_help() if needed.

Cost of memcpy is significantly reduced from:
+   7.48%       vhost-8471  [k] memcpy
+   5.57%     ovs-vswitchd  [k] memcpy
+   2.81%       vhost-8471  [k] csum_partial_copy_generic

to:
+   5.72%     ovs-vswitchd  [k] memcpy
+   3.32%       vhost-5153  [k] memcpy
+   0.68%       vhost-5153  [k] skb_zerocopy

(megaflows disabled)

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/openvswitch/datapath.c | 54 +++++++++++++++++++++++++++++++---------------
 1 file changed, 37 insertions(+), 17 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 0a50574..8dc2496 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -108,10 +108,10 @@ int lockdep_ovsl_is_held(void)
 #endif
 
 static struct vport *new_vport(const struct vport_parms *);
-static int queue_gso_packets(struct net *, int dp_ifindex, struct sk_buff *,
-			     const struct dp_upcall_info *);
-static int queue_userspace_packet(struct net *, int dp_ifindex,
-				  struct sk_buff *,
+static int queue_gso_packets(struct datapath *, struct net *, int dp_ifindex,
+			     struct sk_buff *, const struct dp_upcall_info *);
+static int queue_userspace_packet(struct datapath *, struct net *,
+				  int dp_ifindex, struct sk_buff *,
 				  const struct dp_upcall_info *);
 
 /* Must be called with rcu_read_lock or ovs_mutex. */
@@ -292,9 +292,9 @@ int ovs_dp_upcall(struct datapath *dp, struct sk_buff *skb,
 	}
 
 	if (!skb_is_gso(skb))
-		err = queue_userspace_packet(ovs_dp_get_net(dp), dp_ifindex, skb, upcall_info);
+		err = queue_userspace_packet(dp, ovs_dp_get_net(dp), dp_ifindex, skb, upcall_info);
 	else
-		err = queue_gso_packets(ovs_dp_get_net(dp), dp_ifindex, skb, upcall_info);
+		err = queue_gso_packets(dp, ovs_dp_get_net(dp), dp_ifindex, skb, upcall_info);
 	if (err)
 		goto err;
 
@@ -310,7 +310,7 @@ err:
 	return err;
 }
 
-static int queue_gso_packets(struct net *net, int dp_ifindex,
+static int queue_gso_packets(struct datapath *dp, struct net *net, int dp_ifindex,
 			     struct sk_buff *skb,
 			     const struct dp_upcall_info *upcall_info)
 {
@@ -327,7 +327,7 @@ static int queue_gso_packets(struct net *net, int dp_ifindex,
 	/* Queue all of the segments. */
 	skb = segs;
 	do {
-		err = queue_userspace_packet(net, dp_ifindex, skb, upcall_info);
+		err = queue_userspace_packet(dp, net, dp_ifindex, skb, upcall_info);
 		if (err)
 			break;
 
@@ -381,10 +381,11 @@ static size_t key_attr_size(void)
 }
 
 static size_t upcall_msg_size(const struct sk_buff *skb,
-			      const struct nlattr *userdata)
+			      const struct nlattr *userdata,
+			      unsigned int hdrlen)
 {
 	size_t size = NLMSG_ALIGN(sizeof(struct ovs_header))
-		+ nla_total_size(skb->len) /* OVS_PACKET_ATTR_PACKET */
+		+ nla_total_size(hdrlen) /* OVS_PACKET_ATTR_PACKET */
 		+ nla_total_size(key_attr_size()); /* OVS_PACKET_ATTR_KEY */
 
 	/* OVS_PACKET_ATTR_USERDATA */
@@ -394,14 +395,15 @@ static size_t upcall_msg_size(const struct sk_buff *skb,
 	return size;
 }
 
-static int queue_userspace_packet(struct net *net, int dp_ifindex,
-				  struct sk_buff *skb,
+static int queue_userspace_packet(struct datapath *dp, struct net *net,
+				  int dp_ifindex, struct sk_buff *skb,
 				  const struct dp_upcall_info *upcall_info)
 {
 	struct ovs_header *upcall;
 	struct sk_buff *nskb = NULL;
 	struct sk_buff *user_skb; /* to be queued to userspace */
 	struct nlattr *nla;
+	unsigned int hlen;
 	int err;
 
 	if (vlan_tx_tag_present(skb)) {
@@ -422,7 +424,21 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
 		goto out;
 	}
 
-	user_skb = genlmsg_new(upcall_msg_size(skb, upcall_info->userdata), GFP_ATOMIC);
+	/* Complete checksum if needed */
+	if (skb->ip_summed == CHECKSUM_PARTIAL &&
+	    (err = skb_checksum_help(skb)))
+		goto out;
+
+	/* Older versions of OVS user space enforce alignment of the last
+	 * Netlink attribute to NLA_ALIGNTO which would require extensive
+	 * padding logic. Only perform zerocopy if padding is not required.
+	 */
+	if (dp->user_features & OVS_DP_F_UNALIGNED)
+		hlen = skb_zerocopy_headlen(skb);
+	else
+		hlen = skb->len;
+
+	user_skb = genlmsg_new(upcall_msg_size(skb, upcall_info->userdata, hlen), GFP_ATOMIC);
 	if (!user_skb) {
 		err = -ENOMEM;
 		goto out;
@@ -441,13 +457,17 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
 			  nla_len(upcall_info->userdata),
 			  nla_data(upcall_info->userdata));
 
-	nla = __nla_reserve(user_skb, OVS_PACKET_ATTR_PACKET, skb->len);
+	/* Only reserve room for attribute header, packet data is added
+	 * in skb_zerocopy() */
+	if (!(nla = nla_reserve(user_skb, OVS_PACKET_ATTR_PACKET, 0)))
+		goto out;
+	nla->nla_len = nla_attr_size(skb->len);
+
+	skb_zerocopy(user_skb, skb, skb->len, hlen);
 
-	skb_copy_and_csum_dev(skb, nla_data(nla));
+	((struct nlmsghdr *) user_skb->data)->nlmsg_len = user_skb->len;
 
-	genlmsg_end(user_skb, upcall);
 	err = genlmsg_unicast(net, user_skb, upcall_info->portid);
-
 out:
 	kfree_skb(nskb);
 	return err;
-- 
1.8.3.1
