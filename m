From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] netvsc: add rcu_read locking to netvsc callback
Date: Tue, 10 Jan 2017 07:50:16 -0800
Message-ID: <20170110155016.4897-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35103 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756384AbdAJPu1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 10:50:27 -0500
Received: by mail-pf0-f182.google.com with SMTP id f144so39561949pfa.2
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 07:50:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lockdep finds a case where netvsc receive processing is incorrectly
assuming it is in RCU safe zone. The driver is using RCU to handle
VF reference but RCU read lock not held.

Fixes 0c9d3ba9a87b ("hv_netvsc: use RCU to protect vf_netdev")

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
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
