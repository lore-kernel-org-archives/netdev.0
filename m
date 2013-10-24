From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/11] igbvf: integer wrapping bug setting the mtu
Date: Thu, 24 Oct 2013 08:27:28 -0700
Message-ID: <1382628458-26601-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1382628458-26601-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:32845 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755024Ab3JXP1n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Oct 2013 11:27:43 -0400
In-Reply-To: <1382628458-26601-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>

If new_mtu is very large then "new_mtu + ETH_HLEN + ETH_FCS_LEN" can
wrap and the check on the next line can underflow. This is one of those
bugs which can be triggered by the user if you have namespaces
configured.

Also since this is something the user can trigger then we don't want to
have dev_err() message.

This is a static checker fix and I'm not sure what the impact is.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Tested-by: Sibai Li Sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igbvf/netdev.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 93eb7ee..f48ae71 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -2343,10 +2343,9 @@ static int igbvf_change_mtu(struct net_device *netdev, int new_mtu)
 	struct igbvf_adapter *adapter = netdev_priv(netdev);
 	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
 
-	if ((new_mtu < 68) || (max_frame > MAX_JUMBO_FRAME_SIZE)) {
-		dev_err(&adapter->pdev->dev, "Invalid MTU setting\n");
+	if (new_mtu < 68 || new_mtu > INT_MAX - ETH_HLEN - ETH_FCS_LEN ||
+	    max_frame > MAX_JUMBO_FRAME_SIZE)
 		return -EINVAL;
-	}
 
 #define MAX_STD_JUMBO_FRAME_SIZE 9234
 	if (max_frame > MAX_STD_JUMBO_FRAME_SIZE) {
-- 
1.8.3.1
