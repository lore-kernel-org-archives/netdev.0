From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-05-03
Date: Thu, 3 May 2012 13:37:49 -0400
Message-ID: <20120503173749.GQ9285__40387.8852994696$1336068177$gmane$org@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57442 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757944Ab2ECSCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 14:02:49 -0400
Received: from uucp by smtp.tuxdriver.com with local-rmail (Exim 4.63)
	(envelope-from <linville@tuxdriver.com>)
	id 1SQ0Ma-0006u0-9P
	for netdev@vger.kernel.org; Thu, 03 May 2012 14:02:48 -0400
Received: from linville-8530p.local (linville-8530p.local [127.0.0.1])
	by linville-8530p.local (8.14.4/8.14.4) with ESMTP id q43HuFac009838
	for <netdev@vger.kernel.org>; Thu, 3 May 2012 13:56:15 -0400
Received: (from linville@localhost)
	by linville-8530p.local (8.14.4/8.14.4/Submit) id q43HuE5I009836
	for netdev@vger.kernel.org; Thu, 3 May 2012 13:56:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 3c3052eac295678fd2765552c6a86d5441306cb4

Dave,

Here is another trio of fixes intended for 3.4.  The fix from Eric
Dumazet corrects skb truesize reporting in iwlwifi, avoiding a
potential exhaustion of kernel memory due to differet socket memory
accounting for these skb allocations.  The fix from Franky Lin avoids
a double unlock on a spinlock in brcmfmac.  Finally, Rajkumar Manoharan
reverts an earlier patch that created a minor regression in ath9k.

Please let me know if there are problems!

John

---

The following changes since commit 5a8887d39e1ba5ee2d4ccb94b14d6f2dce5ddfca:

  sungem: Fix WakeOnLan (2012-05-03 01:42:55 -0400)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-davem

Eric Dumazet (1):
      iwlwifi: fix skb truesize underestimation

Franky Lin (1):
      brcmfmac: fix a double spin_unlock_irqrestore issue in dpc

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Rajkumar Manoharan (1):
      Revert "ath9k_hw: Fix incorrect spur_freq_sd for AR9003"

 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |    4 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |    1 +
 drivers/net/wireless/iwlwifi/iwl-agn-rx.c          |   21 +++++++++++++------
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c   |    3 +-
 drivers/net/wireless/iwlwifi/iwl-trans.h           |    1 +
 5 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ar9003_phy.c b/drivers/net/wireless/ath/ath9k/ar9003_phy.c
index deb6cfb..600aca9 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_phy.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_phy.c
@@ -373,7 +373,7 @@ static void ar9003_hw_spur_ofdm_work(struct ath_hw *ah,
 			else
 				spur_subchannel_sd = 0;
 
-			spur_freq_sd = (freq_offset << 9) / 11;
+			spur_freq_sd = ((freq_offset + 10) << 9) / 11;
 
 		} else {
 			if (REG_READ_FIELD(ah, AR_PHY_GEN_CTRL,
@@ -382,7 +382,7 @@ static void ar9003_hw_spur_ofdm_work(struct ath_hw *ah,
 			else
 				spur_subchannel_sd = 1;
 
-			spur_freq_sd = (freq_offset << 9) / 11;
+			spur_freq_sd = ((freq_offset - 10) << 9) / 11;
 
 		}
 
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
index eb3829b..e2b34e1 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
@@ -2637,6 +2637,7 @@ static int brcmf_sdbrcm_dpc_thread(void *data)
 				/* after stopping the bus, exit thread */
 				brcmf_sdbrcm_bus_stop(bus->sdiodev->dev);
 				bus->dpc_tsk = NULL;
+				spin_lock_irqsave(&bus->dpc_tl_lock, flags);
 				break;
 			}
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-rx.c b/drivers/net/wireless/iwlwifi/iwl-agn-rx.c
index f4b84d1..2247460 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rx.c
@@ -773,8 +773,7 @@ static void iwlagn_pass_packet_to_mac80211(struct iwl_priv *priv,
 	struct sk_buff *skb;
 	__le16 fc = hdr->frame_control;
 	struct iwl_rxon_context *ctx;
-	struct page *p;
-	int offset;
+	unsigned int hdrlen, fraglen;
 
 	/* We only process data packets if the interface is open */
 	if (unlikely(!priv->is_open)) {
@@ -788,16 +787,24 @@ static void iwlagn_pass_packet_to_mac80211(struct iwl_priv *priv,
 	    iwlagn_set_decrypted_flag(priv, hdr, ampdu_status, stats))
 		return;
 
-	skb = dev_alloc_skb(128);
+	/* Dont use dev_alloc_skb(), we'll have enough headroom once
+	 * ieee80211_hdr pulled.
+	 */
+	skb = alloc_skb(128, GFP_ATOMIC);
 	if (!skb) {
-		IWL_ERR(priv, "dev_alloc_skb failed\n");
+		IWL_ERR(priv, "alloc_skb failed\n");
 		return;
 	}
+	hdrlen = min_t(unsigned int, len, skb_tailroom(skb));
+	memcpy(skb_put(skb, hdrlen), hdr, hdrlen);
+	fraglen = len - hdrlen;
 
-	offset = (void *)hdr - rxb_addr(rxb);
-	p = rxb_steal_page(rxb);
-	skb_add_rx_frag(skb, 0, p, offset, len, len);
+	if (fraglen) {
+		int offset = (void *)hdr + hdrlen - rxb_addr(rxb);
 
+		skb_add_rx_frag(skb, 0, rxb_steal_page(rxb), offset,
+				fraglen, rxb->truesize);
+	}
 	iwl_update_stats(priv, false, fc, len);
 
 	/*
diff --git a/drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c b/drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c
index 8b1a798..aa7aea1 100644
--- a/drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c
@@ -374,8 +374,9 @@ static void iwl_rx_handle_rxbuf(struct iwl_trans *trans,
 	if (WARN_ON(!rxb))
 		return;
 
+	rxcb.truesize = PAGE_SIZE << hw_params(trans).rx_page_order;
 	dma_unmap_page(trans->dev, rxb->page_dma,
-		       PAGE_SIZE << hw_params(trans).rx_page_order,
+		       rxcb.truesize,
 		       DMA_FROM_DEVICE);
 
 	rxcb._page = rxb->page;
diff --git a/drivers/net/wireless/iwlwifi/iwl-trans.h b/drivers/net/wireless/iwlwifi/iwl-trans.h
index 0c81cba..fdf9788 100644
--- a/drivers/net/wireless/iwlwifi/iwl-trans.h
+++ b/drivers/net/wireless/iwlwifi/iwl-trans.h
@@ -260,6 +260,7 @@ static inline void iwl_free_resp(struct iwl_host_cmd *cmd)
 
 struct iwl_rx_cmd_buffer {
 	struct page *_page;
+	unsigned int truesize;
 };
 
 static inline void *rxb_addr(struct iwl_rx_cmd_buffer *r)
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
