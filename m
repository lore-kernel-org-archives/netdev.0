From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 14/17] openvswitch: Pass datapath into
	userspace queue functions
Date: Mon,  6 Jan 2014 16:16:13 -0800
Message-ID: <1389053776-62865-15-git-send-email-jesse@nicira.com>
References: <1389053776-62865-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1389053776-62865-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>

Allows removing the net and dp_ifindex argument and simplify the
code.

Signed-off-by: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c | 34 ++++++++++++++--------------------
 1 file changed, 14 insertions(+), 20 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 497b2fd..235acae 100644
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
1.8.3.2
