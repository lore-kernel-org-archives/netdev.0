From: Sathya Perla <sathya.perla@broadcom.com>
Subject: [PATCH] be2net: don't enable multicast flag in be_enable_if_filters() routine
Date: Wed,  2 Mar 2016 06:00:28 -0500
Message-ID: <1456916428-30413-1-git-send-email-sathya.perla@broadcom.com>
To: netdev@vger.kernel.org, ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:59765 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751540AbcCBLAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 06:00:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Venkat Duvvuru <venkatkumar.duvvuru@avagotech.com>

When the interface is opened (in be_open()) the routine
be_enable_if_filters() must be called to switch on the basic filtering
capabilities of an interface that are not changed at run-time.
These include the flags UNTAGGED, BROADCAST and PASS_L3L4_ERRORS.
Other flags such as MULTICAST and PROMISC must be enabled later by
be_set_rx_mode() based on the state in the netdev/adapter struct.

be_enable_if_filters() routine is wrongly trying to enable MULTICAST flag
without checking the current adapter state. This can cause the RX_FILTER
cmds to the FW to fail.  This patch fixes this problem by only enabling
the basic filtering flags in be_enable_if_filters().

The VF must be able to issue RX_FILTER cmd with any filter flag, as long
as the PF allowed those flags (if_cap_flags) in the iface it provisioned
for the VF. This rule is applicable even when the VF doesn't have the
FILTMGMT privilege. There is a bug in BE3 FW that wrongly fails RX_FILTER
multicast programming cmds on VFs that don't have FILTMGMT privilege.
This patch also helps in insulating the VF driver from be_open failures due
to the FW bug. A fix for the BE3 FW issue will be available in
versions >= 11.0.283.0 and 10.6.334.0

Reported-by: Ivan Vecera <ivecera@redhat.com>
Signed-off-by: Venkat Duvvuru <venkatkumar.duvvuru@avagotech.com>
Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.h |  9 ++++++---
 drivers/net/ethernet/emulex/benet/be_main.c | 16 +++++++++-------
 2 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 241819b..6d9a8d7 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -622,10 +622,13 @@ enum be_if_flags {
 					 BE_IF_FLAGS_VLAN_PROMISCUOUS |\
 					 BE_IF_FLAGS_MCAST_PROMISCUOUS)
 
-#define BE_IF_EN_FLAGS	(BE_IF_FLAGS_BROADCAST | BE_IF_FLAGS_PASS_L3L4_ERRORS |\
-			BE_IF_FLAGS_MULTICAST | BE_IF_FLAGS_UNTAGGED)
+#define BE_IF_FILT_FLAGS_BASIC (BE_IF_FLAGS_BROADCAST | \
+				BE_IF_FLAGS_PASS_L3L4_ERRORS | \
+				BE_IF_FLAGS_UNTAGGED)
 
-#define BE_IF_ALL_FILT_FLAGS	(BE_IF_EN_FLAGS | BE_IF_FLAGS_ALL_PROMISCUOUS)
+#define BE_IF_ALL_FILT_FLAGS	(BE_IF_FILT_FLAGS_BASIC | \
+				 BE_IF_FLAGS_MULTICAST | \
+				 BE_IF_FLAGS_ALL_PROMISCUOUS)
 
 /* An RX interface is an object with one or more MAC addresses and
  * filtering capabilities. */
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index f99de36..db81e3d 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -125,6 +125,11 @@ static const char * const ue_status_hi_desc[] = {
 	"Unknown"
 };
 
+#define BE_VF_IF_EN_FLAGS	(BE_IF_FLAGS_UNTAGGED | \
+				 BE_IF_FLAGS_BROADCAST | \
+				 BE_IF_FLAGS_MULTICAST | \
+				 BE_IF_FLAGS_PASS_L3L4_ERRORS)
+
 static void be_queue_free(struct be_adapter *adapter, struct be_queue_info *q)
 {
 	struct be_dma_mem *mem = &q->dma_mem;
@@ -3537,7 +3542,7 @@ static int be_enable_if_filters(struct be_adapter *adapter)
 {
 	int status;
 
-	status = be_cmd_rx_filter(adapter, BE_IF_EN_FLAGS, ON);
+	status = be_cmd_rx_filter(adapter, BE_IF_FILT_FLAGS_BASIC, ON);
 	if (status)
 		return status;
 
@@ -3857,8 +3862,7 @@ static int be_vfs_if_create(struct be_adapter *adapter)
 	int status;
 
 	/* If a FW profile exists, then cap_flags are updated */
-	cap_flags = BE_IF_FLAGS_UNTAGGED | BE_IF_FLAGS_BROADCAST |
-		    BE_IF_FLAGS_MULTICAST | BE_IF_FLAGS_PASS_L3L4_ERRORS;
+	cap_flags = BE_VF_IF_EN_FLAGS;
 
 	for_all_vfs(adapter, vf_cfg, vf) {
 		if (!BE3_chip(adapter)) {
@@ -3874,10 +3878,8 @@ static int be_vfs_if_create(struct be_adapter *adapter)
 			}
 		}
 
-		en_flags = cap_flags & (BE_IF_FLAGS_UNTAGGED |
-					BE_IF_FLAGS_BROADCAST |
-					BE_IF_FLAGS_MULTICAST |
-					BE_IF_FLAGS_PASS_L3L4_ERRORS);
+		/* PF should enable IF flags during proxy if_create call */
+		en_flags = cap_flags & BE_VF_IF_EN_FLAGS;
 		status = be_cmd_if_create(adapter, cap_flags, en_flags,
 					  &vf_cfg->if_handle, vf + 1);
 		if (status)
-- 
2.4.1
