From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] cxgb3: avoid needless buffer copy for firmware
Date: Tue, 16 Jun 2015 15:36:17 -0700
Message-ID: <20150616223617.GA17958@www.outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Santosh Raspatur <santosh@chelsio.com>, netdev@vger.kernel.org,
	Alexander Gordeev <agordeev@redhat.com>,
	Joe Perches <joe@perches.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There's no reason to perform a buffer copy for the firmware name. This
also avoids a (currently impossible with current callers) NULL dereference
if there was no matching firmware.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index b96e4bfcac41..8f7aa53a4c4b 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -1025,19 +1025,19 @@ int t3_get_edc_fw(struct cphy *phy, int edc_idx, int size)
 {
 	struct adapter *adapter = phy->adapter;
 	const struct firmware *fw;
-	char buf[64];
+	const char *fw_name;
 	u32 csum;
 	const __be32 *p;
 	u16 *cache = phy->phy_cache;
-	int i, ret;
-
-	snprintf(buf, sizeof(buf), get_edc_fw_name(edc_idx));
+	int i, ret = -EINVAL;
 
-	ret = request_firmware(&fw, buf, &adapter->pdev->dev);
+	fw_name = get_edc_fw_name(edc_idx);
+	if (fw_name)
+		ret = request_firmware(&fw, fw_name, &adapter->pdev->dev);
 	if (ret < 0) {
 		dev_err(&adapter->pdev->dev,
 			"could not upgrade firmware: unable to load %s\n",
-			buf);
+			fw_name);
 		return ret;
 	}
 
-- 
1.9.1


-- 
Kees Cook
Chrome OS Security
