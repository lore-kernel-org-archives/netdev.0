From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Please pull bcm43xx-d80211 bugfixes
Date: Sat, 28 Oct 2006 17:41:43 +0200
Message-ID: <200610281741.44236.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jeff Williams <jeff-+Shh3Y/l6y5dz2imjWt+ww@public.gmane.org>,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi John,

Please
git pull http://bu3sch.de/git/wireless-dev.git for-linville

This will pull the following things since my last
pull request:

Michael Buesch:
      bcm43xx-d80211: Fix DMA engine TX buffer unmap crash.
      bcm43xx-d80211: Don't ignore return value of pci_enable_device()

 drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c  |    7 ++++++-
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |    6 ++++--
 2 files changed, 10 insertions(+), 3 deletions(-)


diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c
index ac7b734..24fc47d 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c
@@ -1102,6 +1102,7 @@ void bcm43xx_dma_handle_txstatus(struct 
 				 const struct bcm43xx_txstatus *status)
 {
 	const struct bcm43xx_dma_ops *ops;
+	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
 	struct bcm43xx_dmaring *ring;
 	struct bcm43xx_dmadesc_generic *desc;
 	struct bcm43xx_dmadesc_meta *meta;
@@ -1116,7 +1117,11 @@ void bcm43xx_dma_handle_txstatus(struct 
 		assert(slot >= 0 && slot < ring->nr_slots);
 		desc = ops->idx2desc(ring, slot, &meta);
 
-		unmap_descbuffer(ring, meta->dmaaddr, meta->skb->len, 1);
+		if (meta->skb)
+			unmap_descbuffer(ring, meta->dmaaddr, meta->skb->len, 1);
+		else
+			unmap_descbuffer(ring, meta->dmaaddr, phy->txhdr_size, 1);
+
 		if (meta->is_last_fragment) {
 			/* Call back to inform the ieee80211 subsystem about the
 			 * status of the transmission.
diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
index 1e857ca..813112e 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
@@ -4129,12 +4129,14 @@ static int bcm43xx_resume(struct pci_dev
 {
 	struct net_device *net_dev = pci_get_drvdata(pdev);
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
-	int err = 0;
+	int err;
 
 	dprintk(KERN_INFO PFX "Resuming...\n");
 
 	pci_set_power_state(pdev, 0);
-	pci_enable_device(pdev);
+	err = pci_enable_device(pdev);
+	if (err)
+		return err;
 	pci_restore_state(pdev);
 
 	bcm43xx_chipset_attach(bcm);


-- 
Greetings Michael.
