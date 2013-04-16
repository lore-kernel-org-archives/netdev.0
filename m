From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 03/10] openvswitch: Refine Netlink
	message size calculation and kill FLOW_BUFSIZE
Date: Tue, 16 Apr 2013 14:00:12 -0700
Message-ID: <1366146019-9015-4-git-send-email-jesse@nicira.com>
References: <1366146019-9015-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1366146019-9015-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

Kills the FLOW_BUFSIZE constant which needs to be calculated manually
and replaces it with key_attr_size() based on nla_total_size().
Calculates the size of datapath messages instead of relying on
NLMSG_DEFAULT_SIZE and moves the existing message size calculations
into own functions for clarity.

Signed-off-by: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c |   76 ++++++++++++++++++++++++++++++--------------
 net/openvswitch/flow.h     |   21 ------------
 2 files changed, 52 insertions(+), 45 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index bca63c8..49ee37b 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -337,6 +337,35 @@ static int queue_gso_packets(struct net *net, int dp_ifindex,
 	return err;
 }
 
+static size_t key_attr_size(void)
+{
+	return    nla_total_size(4)   /* OVS_KEY_ATTR_PRIORITY */
+		+ nla_total_size(4)   /* OVS_KEY_ATTR_IN_PORT */
+		+ nla_total_size(4)   /* OVS_KEY_ATTR_SKB_MARK */
+		+ nla_total_size(12)  /* OVS_KEY_ATTR_ETHERNET */
+		+ nla_total_size(2)   /* OVS_KEY_ATTR_ETHERTYPE */
+		+ nla_total_size(4)   /* OVS_KEY_ATTR_8021Q */
+		+ nla_total_size(0)   /* OVS_KEY_ATTR_ENCAP */
+		+ nla_total_size(2)   /* OVS_KEY_ATTR_ETHERTYPE */
+		+ nla_total_size(40)  /* OVS_KEY_ATTR_IPV6 */
+		+ nla_total_size(2)   /* OVS_KEY_ATTR_ICMPV6 */
+		+ nla_total_size(28); /* OVS_KEY_ATTR_ND */
+}
+
+static size_t upcall_msg_size(const struct sk_buff *skb,
+			      const struct nlattr *userdata)
+{
+	size_t size = NLMSG_ALIGN(sizeof(struct ovs_header))
+		+ nla_total_size(skb->len) /* OVS_PACKET_ATTR_PACKET */
+		+ nla_total_size(key_attr_size()); /* OVS_PACKET_ATTR_KEY */
+
+	/* OVS_PACKET_ATTR_USERDATA */
+	if (userdata)
+		size += NLA_ALIGN(userdata->nla_len);
+
+	return size;
+}
+
 static int queue_userspace_packet(struct net *net, int dp_ifindex,
 				  struct sk_buff *skb,
 				  const struct dp_upcall_info *upcall_info)
@@ -345,7 +374,6 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
 	struct sk_buff *nskb = NULL;
 	struct sk_buff *user_skb; /* to be queued to userspace */
 	struct nlattr *nla;
-	unsigned int len;
 	int err;
 
 	if (vlan_tx_tag_present(skb)) {
@@ -366,13 +394,7 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
 		goto out;
 	}
 
-	len = sizeof(struct ovs_header);
-	len += nla_total_size(skb->len);
-	len += nla_total_size(FLOW_BUFSIZE);
-	if (upcall_info->userdata)
-		len += NLA_ALIGN(upcall_info->userdata->nla_len);
-
-	user_skb = genlmsg_new(len, GFP_ATOMIC);
+	user_skb = genlmsg_new(upcall_msg_size(skb, upcall_info->userdata), GFP_ATOMIC);
 	if (!user_skb) {
 		err = -ENOMEM;
 		goto out;
@@ -801,6 +823,16 @@ static struct genl_multicast_group ovs_dp_flow_multicast_group = {
 	.name = OVS_FLOW_MCGROUP
 };
 
+static size_t ovs_flow_cmd_msg_size(const struct sw_flow_actions *acts)
+{
+	return NLMSG_ALIGN(sizeof(struct ovs_header))
+		+ nla_total_size(key_attr_size()) /* OVS_FLOW_ATTR_KEY */
+		+ nla_total_size(sizeof(struct ovs_flow_stats)) /* OVS_FLOW_ATTR_STATS */
+		+ nla_total_size(1) /* OVS_FLOW_ATTR_TCP_FLAGS */
+		+ nla_total_size(8) /* OVS_FLOW_ATTR_USED */
+		+ nla_total_size(acts->actions_len); /* OVS_FLOW_ATTR_ACTIONS */
+}
+
 /* Called with genl_lock. */
 static int ovs_flow_cmd_fill_info(struct sw_flow *flow, struct datapath *dp,
 				  struct sk_buff *skb, u32 portid,
@@ -879,25 +911,11 @@ error:
 static struct sk_buff *ovs_flow_cmd_alloc_info(struct sw_flow *flow)
 {
 	const struct sw_flow_actions *sf_acts;
-	int len;
 
 	sf_acts = rcu_dereference_protected(flow->sf_acts,
 					    lockdep_genl_is_held());
 
-	/* OVS_FLOW_ATTR_KEY */
-	len = nla_total_size(FLOW_BUFSIZE);
-	/* OVS_FLOW_ATTR_ACTIONS */
-	len += nla_total_size(sf_acts->actions_len);
-	/* OVS_FLOW_ATTR_STATS */
-	len += nla_total_size(sizeof(struct ovs_flow_stats));
-	/* OVS_FLOW_ATTR_TCP_FLAGS */
-	len += nla_total_size(1);
-	/* OVS_FLOW_ATTR_USED */
-	len += nla_total_size(8);
-
-	len += NLMSG_ALIGN(sizeof(struct ovs_header));
-
-	return genlmsg_new(len, GFP_KERNEL);
+	return genlmsg_new(ovs_flow_cmd_msg_size(sf_acts), GFP_KERNEL);
 }
 
 static struct sk_buff *ovs_flow_cmd_build_info(struct sw_flow *flow,
@@ -1213,6 +1231,16 @@ static struct genl_multicast_group ovs_dp_datapath_multicast_group = {
 	.name = OVS_DATAPATH_MCGROUP
 };
 
+static size_t ovs_dp_cmd_msg_size(void)
+{
+	size_t msgsize = NLMSG_ALIGN(sizeof(struct ovs_header));
+
+	msgsize += nla_total_size(IFNAMSIZ);
+	msgsize += nla_total_size(sizeof(struct ovs_dp_stats));
+
+	return msgsize;
+}
+
 static int ovs_dp_cmd_fill_info(struct datapath *dp, struct sk_buff *skb,
 				u32 portid, u32 seq, u32 flags, u8 cmd)
 {
@@ -1251,7 +1279,7 @@ static struct sk_buff *ovs_dp_cmd_build_info(struct datapath *dp, u32 portid,
 	struct sk_buff *skb;
 	int retval;
 
-	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	skb = genlmsg_new(ovs_dp_cmd_msg_size(), GFP_KERNEL);
 	if (!skb)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index a7bb60f..0875fde 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -138,27 +138,6 @@ int ovs_flow_extract(struct sk_buff *, u16 in_port, struct sw_flow_key *,
 void ovs_flow_used(struct sw_flow *, struct sk_buff *);
 u64 ovs_flow_used_time(unsigned long flow_jiffies);
 
-/* Upper bound on the length of a nlattr-formatted flow key.  The longest
- * nlattr-formatted flow key would be:
- *
- *                         struct  pad  nl hdr  total
- *                         ------  ---  ------  -----
- *  OVS_KEY_ATTR_PRIORITY      4    --     4      8
- *  OVS_KEY_ATTR_IN_PORT       4    --     4      8
- *  OVS_KEY_ATTR_SKB_MARK      4    --     4      8
- *  OVS_KEY_ATTR_ETHERNET     12    --     4     16
- *  OVS_KEY_ATTR_ETHERTYPE     2     2     4      8  (outer VLAN ethertype)
- *  OVS_KEY_ATTR_8021Q         4    --     4      8
- *  OVS_KEY_ATTR_ENCAP         0    --     4      4  (VLAN encapsulation)
- *  OVS_KEY_ATTR_ETHERTYPE     2     2     4      8  (inner VLAN ethertype)
- *  OVS_KEY_ATTR_IPV6         40    --     4     44
- *  OVS_KEY_ATTR_ICMPV6        2     2     4      8
- *  OVS_KEY_ATTR_ND           28    --     4     32
- *  -------------------------------------------------
- *  total                                       152
- */
-#define FLOW_BUFSIZE 152
-
 int ovs_flow_to_nlattrs(const struct sw_flow_key *, struct sk_buff *);
 int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
 		      const struct nlattr *);
-- 
1.7.10.4
