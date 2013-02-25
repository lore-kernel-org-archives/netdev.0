From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-02-25
Date: Mon, 25 Feb 2013 15:17:49 -0500
Message-ID: <20130225201748.GC6455@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49923 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751535Ab3BYUaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 15:30:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

This is a batch of fixes intended for the 3.9 stream...

Avinash Patil gives us a mwifiex fix to prevent a system freeze when
that driver is unloaded.

Daniel Drake brings a patch to avoid dropping the carrier flag across a
suspend.  This prevents improper packet drops.

Wei Yongjun delivers a brcmfmac for a lock leak on an error path.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit ea5cdccc46d392b73d941c723630d37094e8e8ea:

  net/pasemi: Fix missing coding style (2013-02-24 21:22:47 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-davem

for you to fetch changes up to 6d6436fbcbc43febe2481d3488f3bb5271ec2eb0:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless into for-davem (2013-02-25 14:50:31 -0500)

----------------------------------------------------------------

Avinash Patil (1):
      mwifiex: fix system freeze while reloading driver

Daniel Drake (1):
      mwifiex: don't drop carrier flag over suspend

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Wei Yongjun (1):
      brcmfmac: fix missing unlock on error in brcmf_notify_vif_event()

 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c   |  4 +++-
 drivers/net/wireless/mwifiex/pcie.c                 | 21 ++-------------------
 drivers/net/wireless/mwifiex/sdio.c                 |  9 ---------
 3 files changed, 5 insertions(+), 29 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
index cecc3ef..2af9c0f 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
@@ -4615,8 +4615,10 @@ static s32 brcmf_notify_vif_event(struct brcmf_if *ifp,
 	switch (ifevent->action) {
 	case BRCMF_E_IF_ADD:
 		/* waiting process may have timed out */
-		if (!cfg->vif_event.vif)
+		if (!cfg->vif_event.vif) {
+			mutex_unlock(&event->vif_event_lock);
 			return -EBADF;
+		}
 
 		ifp->vif = vif;
 		vif->ifp = ifp;
diff --git a/drivers/net/wireless/mwifiex/pcie.c b/drivers/net/wireless/mwifiex/pcie.c
index 4b54bcf..35c7972 100644
--- a/drivers/net/wireless/mwifiex/pcie.c
+++ b/drivers/net/wireless/mwifiex/pcie.c
@@ -171,7 +171,7 @@ static int mwifiex_pcie_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct mwifiex_adapter *adapter;
 	struct pcie_service_card *card;
-	int hs_actived, i;
+	int hs_actived;
 
 	if (pdev) {
 		card = (struct pcie_service_card *) pci_get_drvdata(pdev);
@@ -191,9 +191,6 @@ static int mwifiex_pcie_suspend(struct pci_dev *pdev, pm_message_t state)
 	/* Indicate device suspended */
 	adapter->is_suspended = true;
 
-	for (i = 0; i < adapter->priv_num; i++)
-		netif_carrier_off(adapter->priv[i]->netdev);
-
 	return 0;
 }
 
@@ -209,7 +206,6 @@ static int mwifiex_pcie_resume(struct pci_dev *pdev)
 {
 	struct mwifiex_adapter *adapter;
 	struct pcie_service_card *card;
-	int i;
 
 	if (pdev) {
 		card = (struct pcie_service_card *) pci_get_drvdata(pdev);
@@ -231,10 +227,6 @@ static int mwifiex_pcie_resume(struct pci_dev *pdev)
 
 	adapter->is_suspended = false;
 
-	for (i = 0; i < adapter->priv_num; i++)
-		if (adapter->priv[i]->media_connected)
-			netif_carrier_on(adapter->priv[i]->netdev);
-
 	mwifiex_cancel_hs(mwifiex_get_priv(adapter, MWIFIEX_BSS_ROLE_STA),
 			  MWIFIEX_ASYNC_CMD);
 
@@ -916,17 +908,8 @@ static int mwifiex_pcie_delete_sleep_cookie_buf(struct mwifiex_adapter *adapter)
 static int mwifiex_clean_pcie_ring_buf(struct mwifiex_adapter *adapter)
 {
 	struct pcie_service_card *card = adapter->card;
-	const struct mwifiex_pcie_card_reg *reg = card->pcie.reg;
-	u32 rdptr;
-
-	/* Read the TX ring read pointer set by firmware */
-	if (mwifiex_read_reg(adapter, reg->tx_rdptr, &rdptr)) {
-		dev_err(adapter->dev,
-			"Flush TXBD: failed to read reg->tx_rdptr\n");
-		return -1;
-	}
 
-	if (!mwifiex_pcie_txbd_empty(card, rdptr)) {
+	if (!mwifiex_pcie_txbd_empty(card, card->txbd_rdptr)) {
 		card->txbd_flush = 1;
 		/* write pointer already set at last send
 		 * send dnld-rdy intr again, wait for completion.
diff --git a/drivers/net/wireless/mwifiex/sdio.c b/drivers/net/wireless/mwifiex/sdio.c
index e63f646..363ba31 100644
--- a/drivers/net/wireless/mwifiex/sdio.c
+++ b/drivers/net/wireless/mwifiex/sdio.c
@@ -161,7 +161,6 @@ static int mwifiex_sdio_suspend(struct device *dev)
 	struct sdio_mmc_card *card;
 	struct mwifiex_adapter *adapter;
 	mmc_pm_flag_t pm_flag = 0;
-	int i;
 	int ret = 0;
 
 	if (func) {
@@ -198,9 +197,6 @@ static int mwifiex_sdio_suspend(struct device *dev)
 	/* Indicate device suspended */
 	adapter->is_suspended = true;
 
-	for (i = 0; i < adapter->priv_num; i++)
-		netif_carrier_off(adapter->priv[i]->netdev);
-
 	return ret;
 }
 
@@ -220,7 +216,6 @@ static int mwifiex_sdio_resume(struct device *dev)
 	struct sdio_mmc_card *card;
 	struct mwifiex_adapter *adapter;
 	mmc_pm_flag_t pm_flag = 0;
-	int i;
 
 	if (func) {
 		pm_flag = sdio_get_host_pm_caps(func);
@@ -243,10 +238,6 @@ static int mwifiex_sdio_resume(struct device *dev)
 
 	adapter->is_suspended = false;
 
-	for (i = 0; i < adapter->priv_num; i++)
-		if (adapter->priv[i]->media_connected)
-			netif_carrier_on(adapter->priv[i]->netdev);
-
 	/* Disable Host Sleep */
 	mwifiex_cancel_hs(mwifiex_get_priv(adapter, MWIFIEX_BSS_ROLE_STA),
 			  MWIFIEX_ASYNC_CMD);
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
