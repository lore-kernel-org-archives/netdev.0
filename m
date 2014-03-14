From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/16] ixgbe: add check for netif_carrier_ok in ixgbe_xmit_frame
Date: Fri, 14 Mar 2014 02:47:11 -0700
Message-ID: <1394790446-31591-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394790446-31591-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Arun Sharma <asharma@fb.com>,
	stable-kernel <stable@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:43772 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755605AbaCNJr3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Mar 2014 05:47:29 -0400
In-Reply-To: <1394790446-31591-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch prevents reset/s on ifdown/up which can happen if
ixgbe_xmit_frame is invoked (netconsole) while the interface is down and
there are Tx rings to clean:

     kworker/6:0-11169 [006] d..2 75290.700064: ixgbe_xmit_frame <-netpoll_send_skb_on_dev
     kworker/6:0-11169 [006] d..2 75290.700064: ixgbe_xmit_frame_ring <-ixgbe_xmit_frame
     kworker/6:0-11169 [006] .N.. 75290.700097: ixgbe_get_link_capabilities_82599 <-ixgbe_service_task
     kworker/6:0-11169 [006] .N.. 75290.700097: ixgbe_setup_mac_link_82599 <-ixgbe_service_task
     kworker/6:0-11169 [006] .N.. 75290.700099: ixgbe_get_link_capabilities_82599 <-ixgbe_setup_mac_link_82599
     kworker/6:0-11169 [006] .N.. 75290.700100: ixgbe_check_mac_link_generic <-ixgbe_service_task
     kworker/6:0-11169 [006] .N.. 75290.700103: ixgbe_update_stats <-ixgbe_service_task
     kworker/6:0-11169 [006] .N.. 75290.700289: ixgbe_service_task: initiating reset to clear Tx work after link loss

CC: Arun Sharma <asharma@fb.com>
CC: stable-kernel <stable@vger.kernel.org>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 851c413..8bea6ca 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7121,6 +7121,11 @@ static netdev_tx_t __ixgbe_xmit_frame(struct sk_buff *skb,
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_ring *tx_ring;
 
+	if (!netif_carrier_ok(netdev)) {
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
+	}
+
 	/*
 	 * The minimum packet size for olinfo paylen is 17 so pad the skb
 	 * in order to meet this minimum size requirement.
-- 
1.8.3.1
