From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 13/14] be2net: use adapter->flags to track SRIOV state
Date: Thu, 17 Jul 2014 16:20:31 +0530
Message-ID: <1405594232-30818-14-git-send-email-sathya.perla@emulex.com>
References: <1405594232-30818-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:9074 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755856AbaGQKss (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 06:48:48 -0400
In-Reply-To: <1405594232-30818-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

The driver so far used adapter->num_vfs value to check if SR-IOV is enabled
or not. But, the patch bec84e6("create optimal number of queues on SR-IOV
config") changed this logic. The adapter->num_vfs value is validated and set
much before SR-IOV is enabled. So, we now use an explicit flag to track
SR-IOV enabled state.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    4 +++-
 drivers/net/ethernet/emulex/benet/be_main.c |    3 +++
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 3e639e8..25cd3c9 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -372,6 +372,7 @@ enum vf_state {
 };
 
 #define BE_FLAGS_LINK_STATUS_INIT		1
+#define BE_FLAGS_SRIOV_ENABLED			(1 << 2)
 #define BE_FLAGS_WORKER_SCHEDULED		(1 << 3)
 #define BE_FLAGS_VLAN_PROMISC			(1 << 4)
 #define BE_FLAGS_MCAST_PROMISC			(1 << 5)
@@ -525,7 +526,8 @@ struct be_adapter {
 
 #define be_physfn(adapter)		(!adapter->virtfn)
 #define be_virtfn(adapter)		(adapter->virtfn)
-#define sriov_enabled(adapter)		(adapter->num_vfs > 0)
+#define sriov_enabled(adapter)		(adapter->flags &	\
+					 BE_FLAGS_SRIOV_ENABLED)
 
 #define for_all_vfs(adapter, vf_cfg, i)					\
 	for (i = 0, vf_cfg = &adapter->vf_cfg[i]; i < adapter->num_vfs;	\
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 427e0d7..9f82c01 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3049,6 +3049,7 @@ static void be_vf_clear(struct be_adapter *adapter)
 done:
 	kfree(adapter->vf_cfg);
 	adapter->num_vfs = 0;
+	adapter->flags &= ~BE_FLAGS_SRIOV_ENABLED;
 }
 
 static void be_clear_queues(struct be_adapter *adapter)
@@ -3241,6 +3242,8 @@ static int be_vf_setup(struct be_adapter *adapter)
 			goto err;
 		}
 	}
+
+	adapter->flags |= BE_FLAGS_SRIOV_ENABLED;
 	return 0;
 err:
 	dev_err(dev, "VF setup failed\n");
-- 
1.7.1
