From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: [patch net-next 11/13] sw_flow: add misc section to key
	with in_port_ifindex field
Date: Wed,  3 Sep 2014 11:24:58 +0200
Message-ID: <1409736300-12303-12-git-send-email-jiri@resnulli.us>
References: <1409736300-12303-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org,
 buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
 aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1409736300-12303-1-git-send-email-jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

Signed-off-by: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
---
 include/net/sw_flow.h        |  3 +++
 net/openvswitch/hw_offload.c | 22 ++++++++++++++++++++++
 net/switchdev/switchdev.c    |  2 ++
 3 files changed, 27 insertions(+)

diff --git a/include/net/sw_flow.h b/include/net/sw_flow.h
index 3af7758..a144d8e 100644
--- a/include/net/sw_flow.h
+++ b/include/net/sw_flow.h
@@ -69,6 +69,9 @@ struct sw_flow_key {
 			} nd;
 		} ipv6;
 	};
+	struct {
+		u32	in_port_ifindex; /* Input switch port ifindex (or 0). */
+	} misc;
 } __aligned(BITS_PER_LONG/8); /* Ensure that we can do comparisons as longs. */
 
 struct sw_flow_key_range {
diff --git a/net/openvswitch/hw_offload.c b/net/openvswitch/hw_offload.c
index 45a0c5f..5c3edd0 100644
--- a/net/openvswitch/hw_offload.c
+++ b/net/openvswitch/hw_offload.c
@@ -83,6 +83,24 @@ errout:
 	return err;
 }
 
+void ovs_hw_flow_adjust(struct datapath *dp, struct ovs_flow *flow)
+{
+	struct vport *vport;
+
+	flow->flow.key.misc.in_port_ifindex = 0;
+	flow->flow.mask->key.misc.in_port_ifindex = 0;
+	vport = ovs_vport_ovsl(dp, flow->flow.key.phy.in_port);
+	if (vport && vport->ops->type == OVS_VPORT_TYPE_NETDEV) {
+		struct net_device *dev;
+
+		dev = vport->ops->get_netdev(vport);
+		if (dev) {
+			flow->flow.key.misc.in_port_ifindex = dev->ifindex;
+			flow->flow.mask->key.misc.in_port_ifindex = 0xFFFFFFFF;
+		}
+	}
+}
+
 int ovs_hw_flow_insert(struct datapath *dp, struct ovs_flow *flow)
 {
 	struct sw_flow_actions *actions;
@@ -93,6 +111,8 @@ int ovs_hw_flow_insert(struct datapath *dp, struct ovs_flow *flow)
 	ASSERT_OVSL();
 	BUG_ON(flow->flow.actions);
 
+	ovs_hw_flow_adjust(dp, flow);
+
 	err = sw_flow_action_create(dp, &actions, flow->sf_acts);
 	if (err)
 		return err;
@@ -124,6 +144,8 @@ int ovs_hw_flow_remove(struct datapath *dp, struct ovs_flow *flow)
 
 	ASSERT_OVSL();
 
+	ovs_hw_flow_adjust(dp, flow);
+
 	if (!flow->flow.actions) {
 		err = sw_flow_action_create(dp, &actions, flow->sf_acts);
 		if (err)
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index e079707..05acb0b 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -129,6 +129,8 @@ static void print_flow(const struct sw_flow *flow, struct net_device *dev,
 	print_flow_key_ip(PREFIX_MASK, &flow->mask->key);
 	print_flow_key_ipv4(PREFIX_NONE, &flow->key);
 	print_flow_key_ipv4(PREFIX_MASK, &flow->mask->key);
+	print_flow_key_misc(PREFIX_NONE, &flow->key);
+	print_flow_key_misc(PREFIX_MASK, &flow->mask->key);
 	print_flow_actions(flow->actions);
 }
 
-- 
1.9.3
