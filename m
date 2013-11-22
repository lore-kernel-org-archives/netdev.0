From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net 3/3] be2net: Avoid programming permenant MAC by BE3-R VFs
Date: Fri, 22 Nov 2013 12:51:28 -0600
Message-ID: <20131122185128.GA4182@emulex.com>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:34639 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755976Ab3KVSvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 13:51:31 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On BE3-R, the PF programs the initial MAC address for its VFs. Doing it again
in VF probe, causes a FW error which although harmless generates
an unnecessary error log message.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |  1 +
 drivers/net/ethernet/emulex/benet/be_main.c | 10 ++++------
 2 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index f4825db..5878df6 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -503,6 +503,7 @@ struct be_adapter {
 };
 
 #define be_physfn(adapter)		(!adapter->virtfn)
+#define be_virtfn(adapter)		(adapter->virtfn)
 #define	sriov_enabled(adapter)		(adapter->num_vfs > 0)
 #define sriov_want(adapter)             (be_physfn(adapter) &&	\
 					 (num_vfs || pci_num_vf(adapter->pdev)))
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 9b148cf..78a0e85 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3253,12 +3253,10 @@ static int be_mac_setup(struct be_adapter *adapter)
 		memcpy(mac, adapter->netdev->dev_addr, ETH_ALEN);
 	}
 
-	/* On BE3 VFs this cmd may fail due to lack of privilege.
-	 * Ignore the failure as in this case pmac_id is fetched
-	 * in the IFACE_CREATE cmd.
-	 */
-	be_cmd_pmac_add(adapter, mac, adapter->if_handle,
-			&adapter->pmac_id[0], 0);
+	/* For BE3-R VFs, the PF programs the initial MAC address */
+	if (!(BEx_chip(adapter) && be_virtfn(adapter)))
+		be_cmd_pmac_add(adapter, mac, adapter->if_handle,
+				&adapter->pmac_id[0], 0);
 	return 0;
 }
 
-- 
1.8.1.2
