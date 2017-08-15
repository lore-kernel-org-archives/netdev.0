From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: update VF's netdev->max_mtu if there's a
 change in PF's MTU
Date: Tue, 15 Aug 2017 16:26:22 -0700
Message-ID: <20170815232622.GA2385@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        veerasenareddy.burru@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0086.outbound.protection.outlook.com ([104.47.37.86]:46829
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752031AbdHOX0Y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 19:26:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veerasenareddy Burru <veerasenareddy.burru@cavium.com>

A VF's MTU is capped at the parent PF's MTU.  So if there's a change in the
PF's MTU, then update the VF's netdev->max_mtu.

Also remove duplicate log messages for MTU change.

Signed-off-by: Veerasenareddy Burru <veerasenareddy.burru@cavium.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_core.c    | 3 ---
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 9 ++++++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_core.c b/drivers/net/ethernet/cavium/liquidio/lio_core.c
index d20d0eb..65fb82f 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_core.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_core.c
@@ -165,9 +165,6 @@ void liquidio_link_ctrl_cmd_completion(void *nctrl_ptr)
 		/* If command is successful, change the MTU. */
 		netif_info(lio, probe, lio->netdev, "MTU Changed from %d to %d\n",
 			   netdev->mtu, nctrl->ncmd.s.param1);
-		dev_info(&oct->pci_dev->dev, "%s MTU Changed from %d to %d\n",
-			 netdev->name, netdev->mtu,
-			 nctrl->ncmd.s.param1);
 		netdev->mtu = nctrl->ncmd.s.param1;
 		queue_delayed_work(lio->link_status_wq.wq,
 				   &lio->link_status_wq.wk.work, 0);
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 2fc2da3..968a98e 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -636,6 +636,12 @@ static void update_link_status(struct net_device *netdev,
 			txqs_stop(netdev);
 		}
 
+		if (lio->linfo.link.s.mtu != netdev->max_mtu) {
+			dev_info(&oct->pci_dev->dev, "Max MTU Changed from %d to %d\n",
+				 netdev->max_mtu, lio->linfo.link.s.mtu);
+			netdev->max_mtu = lio->linfo.link.s.mtu;
+		}
+
 		if (lio->linfo.link.s.mtu < netdev->mtu) {
 			dev_warn(&oct->pci_dev->dev,
 				 "PF has changed the MTU for gmx port. Reducing the mtu from %d to %d\n",
@@ -1678,14 +1684,11 @@ static struct net_device_stats *liquidio_get_stats(struct net_device *netdev)
 static int liquidio_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct lio *lio = GET_LIO(netdev);
-	struct octeon_device *oct = lio->oct_dev;
 
 	lio->mtu = new_mtu;
 
 	netif_info(lio, probe, lio->netdev, "MTU Changed from %d to %d\n",
 		   netdev->mtu, new_mtu);
-	dev_info(&oct->pci_dev->dev, "%s MTU Changed from %d to %d\n",
-		 netdev->name, netdev->mtu, new_mtu);
 
 	netdev->mtu = new_mtu;
 
