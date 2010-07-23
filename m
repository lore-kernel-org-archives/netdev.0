From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next 1/7] be2net: change to call pmac_del only if
 necessary
Date: Fri, 23 Jul 2010 17:19:04 +0530
Message-ID: <20100723114850.GA24854@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:23995 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752162Ab0GWLsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 07:48:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a mac address has not been configured for a VF,
there is no need to call be_cmd_pmac_del.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be.h      |    1 +
 drivers/net/benet/be_main.c |    6 ++++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index f17428c..c730bd6 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -221,6 +221,7 @@ struct be_rx_obj {
 };
 
 #define BE_NUM_MSIX_VECTORS		2	/* 1 each for Tx and Rx */
+#define BE_INVALID_PMAC_ID		0xffffffff
 struct be_adapter {
 	struct pci_dev *pdev;
 	struct net_device *netdev;
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index e6ca923..899881b 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -656,8 +656,9 @@ static int be_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 	if (!is_valid_ether_addr(mac) || (vf >= num_vfs))
 		return -EINVAL;
 
-	status = be_cmd_pmac_del(adapter, adapter->vf_if_handle[vf],
-				adapter->vf_pmac_id[vf]);
+	if (adapter->vf_pmac_id[vf] != BE_INVALID_PMAC_ID)
+		status = be_cmd_pmac_del(adapter, adapter->vf_if_handle[vf],
+					adapter->vf_pmac_id[vf]);
 
 	status = be_cmd_pmac_add(adapter, mac, adapter->vf_if_handle[vf],
 				&adapter->vf_pmac_id[vf]);
@@ -1910,6 +1911,7 @@ static int be_setup(struct be_adapter *adapter)
 				"Interface Create failed for VF %d\n", vf);
 				goto if_destroy;
 			}
+			adapter->vf_pmac_id[vf] = BE_INVALID_PMAC_ID;
 			vf++;
 		}
 	} else if (!be_physfn(adapter)) {
-- 
1.7.0.4

