From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/4] ixgbe: fix panic when using macvlan with l2-fwd-offload enabled
Date: Thu, 27 Oct 2016 14:27:54 -0700
Message-ID: <1477603677-39957-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1477603677-39957-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:29768 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1032107AbcJ0V2A (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Oct 2016 17:28:00 -0400
In-Reply-To: <1477603677-39957-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Fix NULL pointer dereference in the case where a macvlan interface is
brought up while the PF is still down:

BUG: unable to handle kernel NULL pointer dereference at 0000000000000010
IP: [<ffffffffa0170fb2>] ixgbe_alloc_rx_buffers+0x42/0x1a0 [ixgbe]

Call Trace:
[<ffffffffa017336b>] ixgbe_configure_rx_ring+0x2eb/0x3d0 [ixgbe]
[<ffffffffa0173811>] ixgbe_fwd_ring_up+0xd1/0x380 [ixgbe]
[<ffffffffa0179709>] ixgbe_fwd_add+0x149/0x230 [ixgbe]
[<ffffffffa0113480>] macvlan_open+0x260/0x2b0 [macvlan]

Reported-by: Matthew Garrett <mjg59@coreos.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index a244d9a..bd93d82 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9135,10 +9135,14 @@ static void *ixgbe_fwd_add(struct net_device *pdev, struct net_device *vdev)
 		goto fwd_add_err;
 	fwd_adapter->pool = pool;
 	fwd_adapter->real_adapter = adapter;
-	err = ixgbe_fwd_ring_up(vdev, fwd_adapter);
-	if (err)
-		goto fwd_add_err;
-	netif_tx_start_all_queues(vdev);
+
+	if (netif_running(pdev)) {
+		err = ixgbe_fwd_ring_up(vdev, fwd_adapter);
+		if (err)
+			goto fwd_add_err;
+		netif_tx_start_all_queues(vdev);
+	}
+
 	return fwd_adapter;
 fwd_add_err:
 	/* unwind counter and free adapter struct */
-- 
2.7.4
