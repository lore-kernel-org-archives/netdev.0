From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net v2] netvsc: add rcu_read locking to netvsc callback
Date: Wed, 11 Jan 2017 09:16:32 -0800
Message-ID: <20170111171632.31241-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:33609 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934916AbdAKRQt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 12:16:49 -0500
Received: by mail-pg0-f47.google.com with SMTP id 204so29726521pge.0
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 09:16:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The receive callback (in tasklet context) is using RCU to get reference
to associated VF network device but this is not safe. RCU read lock
needs to be held. Found by running with full lockdep debugging
enabled.

Fixes: f207c10d9823 ("hv_netvsc: use RCU to protect vf_netdev")
Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
v2 - fix commit message

 drivers/net/hyperv/netvsc_drv.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index c9414c054852..fcab8019dda0 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -659,6 +659,7 @@ int netvsc_recv_callback(struct hv_device *device_obj,
 	 * policy filters on the host). Deliver these via the VF
 	 * interface in the guest.
 	 */
+	rcu_read_lock();
 	vf_netdev = rcu_dereference(net_device_ctx->vf_netdev);
 	if (vf_netdev && (vf_netdev->flags & IFF_UP))
 		net = vf_netdev;
@@ -667,6 +668,7 @@ int netvsc_recv_callback(struct hv_device *device_obj,
 	skb = netvsc_alloc_recv_skb(net, packet, csum_info, *data, vlan_tci);
 	if (unlikely(!skb)) {
 		++net->stats.rx_dropped;
+		rcu_read_unlock();
 		return NVSP_STAT_FAIL;
 	}
 
@@ -696,6 +698,7 @@ int netvsc_recv_callback(struct hv_device *device_obj,
 	 * TODO - use NAPI?
 	 */
 	netif_rx(skb);
+	rcu_read_unlock();
 
 	return 0;
 }
-- 
2.11.0
