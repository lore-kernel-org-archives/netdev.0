From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 11/12] sw_flow: add misc section to key with in_port_ifindex field
Date: Thu, 21 Aug 2014 18:19:04 +0200
Message-ID: <1408637945-10390-12-git-send-email-jiri@resnulli.us>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:43566 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752660AbaHUQTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2014 12:19:49 -0400
Received: by mail-we0-f172.google.com with SMTP id x48so9542703wes.17
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2014 09:19:48 -0700 (PDT)
In-Reply-To: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/sw_flow.h      |  3 +++
 net/core/switchdev.c         | 10 ++++++++++
 net/openvswitch/hw_offload.c | 23 +++++++++++++++++++++++
 3 files changed, 36 insertions(+)

diff --git a/include/linux/sw_flow.h b/include/linux/sw_flow.h
index 079d065..e2ee54a 100644
--- a/include/linux/sw_flow.h
+++ b/include/linux/sw_flow.h
@@ -68,6 +68,9 @@ struct sw_flow_key {
 			} nd;
 		} ipv6;
 	};
+	struct {
+		u32	in_port_ifindex; /* Input switch port ifindex (or 0). */
+	} misc;
 } __aligned(BITS_PER_LONG/8); /* Ensure that we can do comparisons as longs. */
 
 struct sw_flow_key_range {
diff --git a/net/core/switchdev.c b/net/core/switchdev.c
index 4fad097..6d271a0 100644
--- a/net/core/switchdev.c
+++ b/net/core/switchdev.c
@@ -75,6 +75,14 @@ static void print_flow_key_ipv4(const char *prefix,
 		 key->ipv4.arp.sha, key->ipv4.arp.tha);
 }
 
+static void print_flow_key_misc(const char *prefix,
+				const struct sw_flow_key *key)
+{
+	pr_debug("%s misc  { in_port_ifindex %08x }\n",
+		 prefix,
+		 key->misc.in_port_ifindex);
+}
+
 static void print_flow_actions(struct sw_flow_actions *actions)
 {
 	int i;
@@ -120,6 +128,8 @@ static void print_flow(const struct sw_flow *flow, struct net_device *dev,
 	print_flow_key_ip(PREFIX_MASK, &flow->mask->key);
 	print_flow_key_ipv4(PREFIX_NONE, &flow->key);
 	print_flow_key_ipv4(PREFIX_MASK, &flow->mask->key);
+	print_flow_key_misc(PREFIX_NONE, &flow->key);
+	print_flow_key_misc(PREFIX_MASK, &flow->mask->key);
 	print_flow_actions(flow->actions);
 }
 
diff --git a/net/openvswitch/hw_offload.c b/net/openvswitch/hw_offload.c
index edb8a68..ac3997d 100644
--- a/net/openvswitch/hw_offload.c
+++ b/net/openvswitch/hw_offload.c
@@ -82,6 +82,24 @@ errout:
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
@@ -92,6 +110,8 @@ int ovs_hw_flow_insert(struct datapath *dp, struct ovs_flow *flow)
 	ASSERT_OVSL();
 	BUG_ON(flow->flow.actions);
 
+	ovs_hw_flow_adjust(dp, flow);
+
 	err = sw_flow_action_create(dp, &actions, flow->sf_acts);
 	if (err)
 		return err;
@@ -121,6 +141,9 @@ int ovs_hw_flow_remove(struct datapath *dp, struct ovs_flow *flow)
 	int err = 0;
 
 	ASSERT_OVSL();
+
+	ovs_hw_flow_adjust(dp, flow);
+
 	list_for_each_entry(vport, &dp->swdev_rep_list, swdev_rep_list) {
 		dev = vport->ops->get_netdev(vport);
 		BUG_ON(!dev);
-- 
1.9.3
