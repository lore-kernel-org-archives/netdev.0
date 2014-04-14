From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH 2/2] be2net: Fix invocation of be_close() after be_clear()
Date: Mon, 14 Apr 2014 16:12:41 +0530
Message-ID: <1397472161-28685-3-git-send-email-sathya.perla@emulex.com>
References: <1397472161-28685-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:45468 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754419AbaDNKjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 06:39:10 -0400
In-Reply-To: <1397472161-28685-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

In the EEH error recovery path, when a permanent failure occurs,
we clean up adapter structure (i.e. destroy queues etc) by calling
be_clear() and return PCI_ERS_RESULT_DISCONNECT.
After this the stack tries to remove device from bus and calls
be_remove() which invokes netdev_unregister()->be_close().
be_close() operating on destroyed queues results in a
NULL dereference.

This patch fixes this problem by introducing a flag to keep track
of the setup state.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    1 +
 drivers/net/ethernet/emulex/benet/be_main.c |    8 ++++++++
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 8ccaa25..97db5a7 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -374,6 +374,7 @@ enum vf_state {
 #define BE_FLAGS_NAPI_ENABLED			(1 << 9)
 #define BE_FLAGS_QNQ_ASYNC_EVT_RCVD		(1 << 11)
 #define BE_FLAGS_VXLAN_OFFLOADS			(1 << 12)
+#define BE_FLAGS_SETUP_DONE			(1 << 13)
 
 #define BE_UC_PMAC_COUNT			30
 #define BE_VF_UC_PMAC_COUNT			2
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 80f754d..a186454 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2726,6 +2726,12 @@ static int be_close(struct net_device *netdev)
 	struct be_eq_obj *eqo;
 	int i;
 
+	/* This protection is needed as be_close() may be called even when the
+	 * adapter is in cleared state (after eeh perm failure)
+	 */
+	if (!(adapter->flags & BE_FLAGS_SETUP_DONE))
+		return 0;
+
 	be_roce_dev_close(adapter);
 
 	if (adapter->flags & BE_FLAGS_NAPI_ENABLED) {
@@ -3056,6 +3062,7 @@ static int be_clear(struct be_adapter *adapter)
 	be_clear_queues(adapter);
 
 	be_msix_disable(adapter);
+	adapter->flags &= ~BE_FLAGS_SETUP_DONE;
 	return 0;
 }
 
@@ -3560,6 +3567,7 @@ static int be_setup(struct be_adapter *adapter)
 		adapter->phy.fc_autoneg = 1;
 
 	be_schedule_worker(adapter);
+	adapter->flags |= BE_FLAGS_SETUP_DONE;
 	return 0;
 err:
 	be_clear(adapter);
-- 
1.7.1
