From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] drivers: net: xgene: Simplify xgene_enet_setup_mss() to kill warning
Date: Fri, 24 Feb 2017 11:30:03 +0100
Message-ID: <1487932203-31799-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S . Miller" <davem@davemloft.net>,
        Iyappan Subramanian <isubramanian@apm.com>,
        Keyur Chudgar <kchudgar@apm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With gcc-4.1.2 and -Os:

    drivers/net/ethernet/apm/xgene/xgene_enet_main.c: In function ‘xgene_enet_start_xmit’:
    drivers/net/ethernet/apm/xgene/xgene_enet_main.c:297: warning: ‘mss_index’ may be used uninitialized in this function

Using a separate variable to track success may confuse the compiler.
Preinitialize mss_index with -EBUSY and check for negative error values
instead to kill the warning.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
Compile-tested only.

 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index d0d0d12b531fc683..e536301acfdec9fd 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -293,36 +293,29 @@ static int xgene_enet_tx_completion(struct xgene_enet_desc_ring *cp_ring,
 static int xgene_enet_setup_mss(struct net_device *ndev, u32 mss)
 {
 	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
-	bool mss_index_found = false;
-	int mss_index;
+	int mss_index = -EBUSY;
 	int i;
 
 	spin_lock(&pdata->mss_lock);
 
 	/* Reuse the slot if MSS matches */
-	for (i = 0; !mss_index_found && i < NUM_MSS_REG; i++) {
+	for (i = 0; mss_index < 0 && i < NUM_MSS_REG; i++) {
 		if (pdata->mss[i] == mss) {
 			pdata->mss_refcnt[i]++;
 			mss_index = i;
-			mss_index_found = true;
 		}
 	}
 
 	/* Overwrite the slot with ref_count = 0 */
-	for (i = 0; !mss_index_found && i < NUM_MSS_REG; i++) {
+	for (i = 0; mss_index < 0 && i < NUM_MSS_REG; i++) {
 		if (!pdata->mss_refcnt[i]) {
 			pdata->mss_refcnt[i]++;
 			pdata->mac_ops->set_mss(pdata, mss, i);
 			pdata->mss[i] = mss;
 			mss_index = i;
-			mss_index_found = true;
 		}
 	}
 
-	/* No slots with ref_count = 0 available, return busy */
-	if (!mss_index_found)
-		mss_index = -EBUSY;
-
 	spin_unlock(&pdata->mss_lock);
 
 	return mss_index;
-- 
2.7.4
