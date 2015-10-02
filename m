From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net] openvswitch: Fix ovs_vport_get_stats()
Date: Fri,  2 Oct 2015 14:56:34 -0700
Message-ID: <1443822994-1928-1-git-send-email-pshelar@nicira.com>
Cc: tomasz.sawicki@objectiveintegration.uk,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34276 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751353AbbJBV4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 17:56:37 -0400
Received: by padhy16 with SMTP id hy16so117096416pad.1
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 14:56:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not every device has dev->tstats set. So when OVS tries to calculate
vport stats it causes kernel panic. Following patch fixes it by
using standard API to get net-device stats.

---8<---
Unable to handle kernel paging request at virtual address 766b4008
Internal error: Oops: 96000005 [#1] PREEMPT SMP
Modules linked in: vport_vxlan vxlan ip6_udp_tunnel udp_tunnel tun bridge stp llc openvswitch ipv6
CPU: 7 PID: 1108 Comm: ovs-vswitchd Not tainted 4.3.0-rc3+ #82
PC is at ovs_vport_get_stats+0x150/0x1f8 [openvswitch]
<snip>
Call trace:
 [<ffffffbffc0859f8>] ovs_vport_get_stats+0x150/0x1f8 [openvswitch]
 [<ffffffbffc07cdb0>] ovs_vport_cmd_fill_info+0x140/0x1e0 [openvswitch]
 [<ffffffbffc07cf0c>] ovs_vport_cmd_dump+0xbc/0x138 [openvswitch]
 [<ffffffc00045a5ac>] netlink_dump+0xb8/0x258
 [<ffffffc00045ace0>] __netlink_dump_start+0x120/0x178
 [<ffffffc00045dd9c>] genl_family_rcv_msg+0x2d4/0x308
 [<ffffffc00045de58>] genl_rcv_msg+0x88/0xc4
 [<ffffffc00045cf24>] netlink_rcv_skb+0xd4/0x100
 [<ffffffc00045dab0>] genl_rcv+0x30/0x48
 [<ffffffc00045c830>] netlink_unicast+0x154/0x200
 [<ffffffc00045cc9c>] netlink_sendmsg+0x308/0x364
 [<ffffffc00041e10c>] sock_sendmsg+0x14/0x2c
 [<ffffffc000420d58>] SyS_sendto+0xbc/0xf0
Code: aa1603e1 f94037a4 aa1303e2 aa1703e0 (f9400465)

Reported-by: Tomasz Sawicki <tomasz.sawicki@objectiveintegration.uk>
Fixes: 8c876639c98 ("openvswitch: Remove vport stats.")
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/vport.c |   42 +++++++++++++-----------------------------
 1 files changed, 13 insertions(+), 29 deletions(-)

diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index dc81dc6..fc5c0b9 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -280,35 +280,19 @@ void ovs_vport_del(struct vport *vport)
  */
 void ovs_vport_get_stats(struct vport *vport, struct ovs_vport_stats *stats)
 {
-	struct net_device *dev = vport->dev;
-	int i;
-
-	memset(stats, 0, sizeof(*stats));
-	stats->rx_errors  = dev->stats.rx_errors;
-	stats->tx_errors  = dev->stats.tx_errors;
-	stats->tx_dropped = dev->stats.tx_dropped;
-	stats->rx_dropped = dev->stats.rx_dropped;
-
-	stats->rx_dropped += atomic_long_read(&dev->rx_dropped);
-	stats->tx_dropped += atomic_long_read(&dev->tx_dropped);
-
-	for_each_possible_cpu(i) {
-		const struct pcpu_sw_netstats *percpu_stats;
-		struct pcpu_sw_netstats local_stats;
-		unsigned int start;
-
-		percpu_stats = per_cpu_ptr(dev->tstats, i);
-
-		do {
-			start = u64_stats_fetch_begin_irq(&percpu_stats->syncp);
-			local_stats = *percpu_stats;
-		} while (u64_stats_fetch_retry_irq(&percpu_stats->syncp, start));
-
-		stats->rx_bytes		+= local_stats.rx_bytes;
-		stats->rx_packets	+= local_stats.rx_packets;
-		stats->tx_bytes		+= local_stats.tx_bytes;
-		stats->tx_packets	+= local_stats.tx_packets;
-	}
+	const struct rtnl_link_stats64 *dev_stats;
+	struct rtnl_link_stats64 temp;
+
+	dev_stats = dev_get_stats(vport->dev, &temp);
+	stats->rx_errors  = dev_stats->rx_errors;
+	stats->tx_errors  = dev_stats->tx_errors;
+	stats->tx_dropped = dev_stats->tx_dropped;
+	stats->rx_dropped = dev_stats->rx_dropped;
+
+	stats->rx_bytes	  = dev_stats->rx_bytes;
+	stats->rx_packets = dev_stats->rx_packets;
+	stats->tx_bytes	  = dev_stats->tx_bytes;
+	stats->tx_packets = dev_stats->tx_packets;
 }
 
 /**
-- 
1.7.1
