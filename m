From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH net-next 2/2] bnxt_en: define sriov_lock unconditionally
Date: Tue, 25 Jul 2017 17:29:52 +0200
Message-ID: <20170725153046.44726-2-arnd@arndb.de>
References: <20170725153046.44726-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Sathya Perla <sathya.perla@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Deepak Khungar <deepak.khungar@broadcom.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170725153046.44726-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The sriov_lock is used to serialize the sriov code with the vfr code.
However, when SRIOV is disabled, the lock is not there at all, leading
to a build error:

drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c: In function 'bnxt_dl_eswitch_mode_set':
drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c:410:16: error: 'struct bnxt' has no member named 'sriov_lock'

We can either provide the mutex in this configuration, too, or
disable both SRIOV and VFR together. This implements the first
approach, since it seems like a reasonable configuration for
guest kernels to have, and the extra lock will be harmless when
there is no contention.

Fixes: 4ab0c6a8ffd7 ("bnxt_en: add support to enable VF-representors")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h | 3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 82cbe1804821..9a9f5f394341 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -7949,8 +7949,8 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 #ifdef CONFIG_BNXT_SRIOV
 	init_waitqueue_head(&bp->sriov_cfg_wait);
-	mutex_init(&bp->sriov_lock);
 #endif
+	mutex_init(&bp->sriov_lock);
 	bp->gro_func = bnxt_gro_func_5730x;
 	if (BNXT_CHIP_P4_PLUS(bp))
 		bp->gro_func = bnxt_gro_func_5731x;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 2d84d5719b70..a31ef843977a 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1239,13 +1239,12 @@ struct bnxt {
 	wait_queue_head_t	sriov_cfg_wait;
 	bool			sriov_cfg;
 #define BNXT_SRIOV_CFG_WAIT_TMO	msecs_to_jiffies(10000)
-
+#endif
 	/* lock to protect VF-rep creation/cleanup via
 	 * multiple paths such as ->sriov_configure() and
 	 * devlink ->eswitch_mode_set()
 	 */
 	struct mutex		sriov_lock;
-#endif
 
 #define BNXT_NTP_FLTR_MAX_FLTR	4096
 #define BNXT_NTP_FLTR_HASH_SIZE	512
-- 
2.9.0
