From: James Morse <james.morse@arm.com>
Subject: [PATCH net v3] openvswitch: Allocate memory for ovs internal device stats.
Date: Mon, 19 Oct 2015 16:31:55 +0100
Message-ID: <1445268715-21661-1-git-send-email-james.morse@arm.com>
Cc: Pravin Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>, dev@openvswitch.org,
	James Morse <james.morse@arm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:50691 "EHLO foss.arm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753952AbbJSPcj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2015 11:32:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"openvswitch: Remove vport stats" removed the per-vport statistics, in
order to use the netdev's statistics fields.
"openvswitch: Fix ovs_vport_get_stats()" fixed the export of these stats
to user-space, by using the provided netdev_ops to collate them - but ovs
internal devices still use an unallocated dev->tstats field to count
packets, which are no longer exported by this api.

Allocate the dev->tstats field for ovs internal devices, and wire up
ndo_get_stats64 with the original implementation of
ovs_vport_get_stats().

On its own, "openvswitch: Fix ovs_vport_get_stats()" fixes the OOPs,
unmasking a full-on panic on arm64:
=============%<==============
[<ffffffbffc00ce4c>] internal_dev_recv+0xa8/0x170 [openvswitch]
[<ffffffbffc0008b4>] do_output.isra.31+0x60/0x19c [openvswitch]
[<ffffffbffc000bf8>] do_execute_actions+0x208/0x11c0 [openvswitch]
[<ffffffbffc001c78>] ovs_execute_actions+0xc8/0x238 [openvswitch]
[<ffffffbffc003dfc>] ovs_packet_cmd_execute+0x21c/0x288 [openvswitch]
[<ffffffc0005e8c5c>] genl_family_rcv_msg+0x1b0/0x310
[<ffffffc0005e8e60>] genl_rcv_msg+0xa4/0xe4
[<ffffffc0005e7ddc>] netlink_rcv_skb+0xb0/0xdc
[<ffffffc0005e8a94>] genl_rcv+0x38/0x50
[<ffffffc0005e76c0>] netlink_unicast+0x164/0x210
[<ffffffc0005e7b70>] netlink_sendmsg+0x304/0x368
[<ffffffc0005a21c0>] sock_sendmsg+0x30/0x4c
[SNIP]
Kernel panic - not syncing: Fatal exception in interrupt
=============%<==============

Fixes: 8c876639c985 ("openvswitch: Remove vport stats.")
Signed-off-by: James Morse <james.morse@arm.com>
---
Change since v2:
* Fixed error-handling in internal_dev_create() to free the netdev.

Change since v1:
* Removed superfluous rx/tx_dropped increment, already done by dev_get_stats().

 net/openvswitch/vport-internal_dev.c | 46 +++++++++++++++++++++++++++++++++---
 1 file changed, 43 insertions(+), 3 deletions(-)

diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 388b8a6bf112..b3934126daa8 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -106,12 +106,45 @@ static void internal_dev_destructor(struct net_device *dev)
 	free_netdev(dev);
 }
 
+static struct rtnl_link_stats64 *
+internal_get_stats(struct net_device *dev, struct rtnl_link_stats64 *stats)
+{
+	int i;
+
+	memset(stats, 0, sizeof(*stats));
+	stats->rx_errors  = dev->stats.rx_errors;
+	stats->tx_errors  = dev->stats.tx_errors;
+	stats->tx_dropped = dev->stats.tx_dropped;
+	stats->rx_dropped = dev->stats.rx_dropped;
+
+	for_each_possible_cpu(i) {
+		const struct pcpu_sw_netstats *percpu_stats;
+		struct pcpu_sw_netstats local_stats;
+		unsigned int start;
+
+		percpu_stats = per_cpu_ptr(dev->tstats, i);
+
+		do {
+			start = u64_stats_fetch_begin_irq(&percpu_stats->syncp);
+			local_stats = *percpu_stats;
+		} while (u64_stats_fetch_retry_irq(&percpu_stats->syncp, start));
+
+		stats->rx_bytes         += local_stats.rx_bytes;
+		stats->rx_packets       += local_stats.rx_packets;
+		stats->tx_bytes         += local_stats.tx_bytes;
+		stats->tx_packets       += local_stats.tx_packets;
+	}
+
+	return stats;
+}
+
 static const struct net_device_ops internal_dev_netdev_ops = {
 	.ndo_open = internal_dev_open,
 	.ndo_stop = internal_dev_stop,
 	.ndo_start_xmit = internal_dev_xmit,
 	.ndo_set_mac_address = eth_mac_addr,
 	.ndo_change_mtu = internal_dev_change_mtu,
+	.ndo_get_stats64 = internal_get_stats,
 };
 
 static struct rtnl_link_ops internal_dev_link_ops __read_mostly = {
@@ -161,6 +194,11 @@ static struct vport *internal_dev_create(const struct vport_parms *parms)
 		err = -ENOMEM;
 		goto error_free_vport;
 	}
+	vport->dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
+	if (!vport->dev->tstats) {
+		err = -ENOMEM;
+		goto error_free_netdev;
+	}
 
 	dev_net_set(vport->dev, ovs_dp_get_net(vport->dp));
 	internal_dev = internal_dev_priv(vport->dev);
@@ -173,7 +211,7 @@ static struct vport *internal_dev_create(const struct vport_parms *parms)
 	rtnl_lock();
 	err = register_netdevice(vport->dev);
 	if (err)
-		goto error_free_netdev;
+		goto error_unlock;
 
 	dev_set_promiscuity(vport->dev, 1);
 	rtnl_unlock();
@@ -181,8 +219,10 @@ static struct vport *internal_dev_create(const struct vport_parms *parms)
 
 	return vport;
 
-error_free_netdev:
+error_unlock:
 	rtnl_unlock();
+	free_percpu(vport->dev->tstats);
+error_free_netdev:
 	free_netdev(vport->dev);
 error_free_vport:
 	ovs_vport_free(vport);
@@ -198,7 +238,7 @@ static void internal_dev_destroy(struct vport *vport)
 
 	/* unregister_netdevice() waits for an RCU grace period. */
 	unregister_netdevice(vport->dev);
-
+	free_percpu(vport->dev->tstats);
 	rtnl_unlock();
 }
 
-- 
2.1.4
