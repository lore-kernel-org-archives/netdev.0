From: Huacai Chen <chenhc@lemote.com>
Subject: [PATCH RESEND] stmmac: Don't init ptp again when resume from suspend/hibernation
Date: Fri, 19 Dec 2014 22:38:18 +0800
Message-ID: <1418999898-10298-1-git-send-email-chenhc@lemote.com>
Cc: Srinivas Kandagatla <srinivas.kandagatla@st.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Huacai Chen <chenhc@lemote.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34150 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752298AbaLSOmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 09:42:38 -0500
Received: by mail-pa0-f53.google.com with SMTP id kq14so1315257pab.40
        for <netdev@vger.kernel.org>; Fri, 19 Dec 2014 06:42:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both stmmac_open() and stmmac_resume() call stmmac_hw_setup(), and
stmmac_hw_setup() call stmmac_init_ptp() unconditionally. However, only
stmmac_release() calls stmmac_release_ptp(). Since stmmac_suspend()
doesn't call stmmac_release_ptp(), stmmac_resume() also needn't call
stmmac_init_ptp().

This patch also fix a "scheduling while atomic" problem when resume
from suspend/hibernation. Because stmmac_init_ptp() will trigger
scheduling while stmmac_resume() hold a spinlock.

Callgraph of "scheduling while atomic":
stmmac_resume() --> stmmac_hw_setup() --> stmmac_init_ptp() -->
stmmac_ptp_register() --> ptp_clock_register() --> device_create() -->
device_create_groups_vargs() --> device_add() --> devtmpfs_create_node()
--> wait_for_common() --> schedule_timeout() --> __schedule()

Signed-off-by: Huacai Chen <chenhc@lemote.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 118a427..8c6b7c1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1671,7 +1671,7 @@ static void stmmac_init_tx_coalesce(struct stmmac_priv *priv)
  *  0 on success and an appropriate (-)ve integer as defined in errno.h
  *  file on failure.
  */
-static int stmmac_hw_setup(struct net_device *dev)
+static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 	int ret;
@@ -1708,9 +1708,11 @@ static int stmmac_hw_setup(struct net_device *dev)
 
 	stmmac_mmc_setup(priv);
 
-	ret = stmmac_init_ptp(priv);
-	if (ret && ret != -EOPNOTSUPP)
-		pr_warn("%s: failed PTP initialisation\n", __func__);
+	if (init_ptp) {
+		ret = stmmac_init_ptp(priv);
+		if (ret && ret != -EOPNOTSUPP)
+			pr_warn("%s: failed PTP initialisation\n", __func__);
+	}
 
 #ifdef CONFIG_DEBUG_FS
 	ret = stmmac_init_fs(dev);
@@ -1787,7 +1789,7 @@ static int stmmac_open(struct net_device *dev)
 		goto init_error;
 	}
 
-	ret = stmmac_hw_setup(dev);
+	ret = stmmac_hw_setup(dev, true);
 	if (ret < 0) {
 		pr_err("%s: Hw setup failed\n", __func__);
 		goto init_error;
@@ -3036,7 +3038,7 @@ int stmmac_resume(struct net_device *ndev)
 	netif_device_attach(ndev);
 
 	init_dma_desc_rings(ndev, GFP_ATOMIC);
-	stmmac_hw_setup(ndev);
+	stmmac_hw_setup(ndev, false);
 	stmmac_init_tx_coalesce(priv);
 
 	napi_enable(&priv->napi);
-- 
1.7.7.3
