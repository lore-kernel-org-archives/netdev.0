From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 1/2] be2net: Fix VF driver load for Lancer
Date: Wed, 18 Jul 2012 18:21:58 +0530
Message-ID: <2ea6d9c9-762b-4079-b2c1-7fa7cfcbb4b5@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:20879 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754399Ab2GRMwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 08:52:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lancer FW has added new capability checks for VFs.
Driver should only use those capabilities which are allowed for VFs.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    3 ++-
 drivers/net/ethernet/emulex/benet/be_main.c |    7 +++++++
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index ddfca65..7932490 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1631,7 +1631,8 @@ int be_cmd_rx_filter(struct be_adapter *adapter, u32 flags, u32 value)
 		/* Reset mcast promisc mode if already set by setting mask
 		 * and not setting flags field
 		 */
-		req->if_flags_mask |=
+		if (!lancer_chip(adapter) || be_physfn(adapter))
+			req->if_flags_mask |=
 				cpu_to_le32(BE_IF_FLAGS_MCAST_PROMISCUOUS);
 
 		req->mcast_num = cpu_to_le32(netdev_mc_count(adapter->netdev));
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index f18375c..4d96771 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2772,6 +2772,13 @@ static int be_setup(struct be_adapter *adapter)
 		en_flags |= BE_IF_FLAGS_RSS;
 	}
 
+	if (lancer_chip(adapter) && !be_physfn(adapter)) {
+		en_flags = BE_IF_FLAGS_UNTAGGED |
+			    BE_IF_FLAGS_BROADCAST |
+			    BE_IF_FLAGS_MULTICAST;
+		cap_flags = en_flags;
+	}
+
 	status = be_cmd_if_create(adapter, cap_flags, en_flags,
 				  &adapter->if_handle, 0);
 	if (status != 0)
-- 
1.6.0.2
