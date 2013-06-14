From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 8/8] openvswitch: Simplify interface
	ovs_flow_metadata_from_nlattrs()
Date: Fri, 14 Jun 2013 15:28:57 -0700
Message-ID: <1371248937-35614-9-git-send-email-jesse@nicira.com>
References: <1371248937-35614-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1371248937-35614-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

From: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

This is not functional change, this is just code cleanup.

Signed-off-by: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c |  5 +----
 net/openvswitch/flow.c     | 22 ++++++++++------------
 net/openvswitch/flow.h     |  4 ++--
 3 files changed, 13 insertions(+), 18 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 748aa97..0f783d9 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -739,10 +739,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	if (err)
 		goto err_flow_free;
 
-	err = ovs_flow_metadata_from_nlattrs(&flow->key.phy.priority,
-					     &flow->key.phy.skb_mark,
-					     &flow->key.phy.in_port,
-					     a[OVS_PACKET_ATTR_KEY]);
+	err = ovs_flow_metadata_from_nlattrs(flow, a[OVS_PACKET_ATTR_KEY]);
 	if (err)
 		goto err_flow_free;
 
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index fca4833..093c191 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -1125,10 +1125,8 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
 
 /**
  * ovs_flow_metadata_from_nlattrs - parses Netlink attributes into a flow key.
- * @priority: receives the skb priority
- * @mark: receives the skb mark
- * @in_port: receives the extracted input port.
- * @key: Netlink attribute holding nested %OVS_KEY_ATTR_* Netlink attribute
+ * @flow: Receives extracted in_port, priority, tun_key and skb_mark.
+ * @attr: Netlink attribute holding nested %OVS_KEY_ATTR_* Netlink attribute
  * sequence.
  *
  * This parses a series of Netlink attributes that form a flow key, which must
@@ -1136,15 +1134,15 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
  * get the metadata, that is, the parts of the flow key that cannot be
  * extracted from the packet itself.
  */
-int ovs_flow_metadata_from_nlattrs(u32 *priority, u32 *mark, u16 *in_port,
-			       const struct nlattr *attr)
+int ovs_flow_metadata_from_nlattrs(struct sw_flow *flow,
+				   const struct nlattr *attr)
 {
 	const struct nlattr *nla;
 	int rem;
 
-	*in_port = DP_MAX_PORTS;
-	*priority = 0;
-	*mark = 0;
+	flow->key.phy.in_port = DP_MAX_PORTS;
+	flow->key.phy.priority = 0;
+	flow->key.phy.skb_mark = 0;
 
 	nla_for_each_nested(nla, attr, rem) {
 		int type = nla_type(nla);
@@ -1155,17 +1153,17 @@ int ovs_flow_metadata_from_nlattrs(u32 *priority, u32 *mark, u16 *in_port,
 
 			switch (type) {
 			case OVS_KEY_ATTR_PRIORITY:
-				*priority = nla_get_u32(nla);
+				flow->key.phy.priority = nla_get_u32(nla);
 				break;
 
 			case OVS_KEY_ATTR_IN_PORT:
 				if (nla_get_u32(nla) >= DP_MAX_PORTS)
 					return -EINVAL;
-				*in_port = nla_get_u32(nla);
+				flow->key.phy.in_port = nla_get_u32(nla);
 				break;
 
 			case OVS_KEY_ATTR_SKB_MARK:
-				*mark = nla_get_u32(nla);
+				flow->key.phy.skb_mark = nla_get_u32(nla);
 				break;
 			}
 		}
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 0875fde..2a83e21 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -141,8 +141,8 @@ u64 ovs_flow_used_time(unsigned long flow_jiffies);
 int ovs_flow_to_nlattrs(const struct sw_flow_key *, struct sk_buff *);
 int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
 		      const struct nlattr *);
-int ovs_flow_metadata_from_nlattrs(u32 *priority, u32 *mark, u16 *in_port,
-			       const struct nlattr *);
+int ovs_flow_metadata_from_nlattrs(struct sw_flow *flow,
+				  const struct nlattr *attr);
 
 #define MAX_ACTIONS_BUFSIZE    (16 * 1024)
 #define TBL_MIN_BUCKETS		1024
-- 
1.8.1.2
