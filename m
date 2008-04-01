From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2008-04-01
Date: Tue, 1 Apr 2008 16:15:30 -0400
Message-ID: <20080401201530.GA25094@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

A few more for 2.6.25...one of them isn't really a bug fix, but
it includes messages which might be useful for future debugging.
All of them are relatively minor, but I think it would be good to
have them now rather than later.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit f83f1768f833cb45bc93429fdc552252a4f55ac3:
  Joonwoo Park (1):
        [LLC]: skb allocation size for responses

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Jan Niehusmann (1):
      mac80211: trigger ieee80211_sta_work after opening interface

Michael Buesch (2):
      b43: Add DMA mapping failure messages
      b43: Fix PCMCIA IRQ routing

Vladimir Koutny (1):
      mac80211: correct use_short_preamble handling

 drivers/net/wireless/b43/dma.c    |    7 ++++++-
 drivers/net/wireless/b43/pcmcia.c |    6 ++++--
 net/mac80211/ieee80211.c          |   12 ++++++++++++
 net/mac80211/ieee80211_sta.c      |    9 ++++-----
 4 files changed, 26 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/b43/dma.c b/drivers/net/wireless/b43/dma.c
index cfbc1a2..948eb1f 100644
--- a/drivers/net/wireless/b43/dma.c
+++ b/drivers/net/wireless/b43/dma.c
@@ -619,6 +619,7 @@ static int setup_rx_descbuffer(struct b43_dmaring *ring,
 	}
 
 	if (b43_dma_mapping_error(ring, dmaaddr, ring->rx_buffersize, 0)) {
+		b43err(ring->dev->wl, "RX DMA buffer allocation failed\n");
 		dev_kfree_skb_any(skb);
 		return -EIO;
 	}
@@ -874,8 +875,12 @@ struct b43_dmaring *b43_setup_dmaring(struct b43_wldev *dev,
 						  DMA_TO_DEVICE);
 
 			if (b43_dma_mapping_error(ring, dma_test,
-						  b43_txhdr_size(dev), 1))
+						  b43_txhdr_size(dev), 1)) {
+
+				b43err(dev->wl,
+				       "TXHDR DMA allocation failed\n");
 				goto err_kfree_txhdr_cache;
+			}
 		}
 
 		dma_unmap_single(dev->dev->dev,
diff --git a/drivers/net/wireless/b43/pcmcia.c b/drivers/net/wireless/b43/pcmcia.c
index b79a6bd..371e4a1 100644
--- a/drivers/net/wireless/b43/pcmcia.c
+++ b/drivers/net/wireless/b43/pcmcia.c
@@ -91,6 +91,8 @@ static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
 
 	dev->conf.ConfigBase = parse.config.base;
 	dev->conf.Present = parse.config.rmask[0];
+	dev->conf.Attributes = CONF_ENABLE_IRQ;
+	dev->conf.IntType = INT_MEMORY_AND_IO;
 
 	dev->io.BasePort2 = 0;
 	dev->io.NumPorts2 = 0;
@@ -112,8 +114,8 @@ static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
 	if (res != CS_SUCCESS)
 		goto err_disable;
 
-	dev->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING | IRQ_FIRST_SHARED;
-	dev->irq.IRQInfo1 = IRQ_LEVEL_ID | IRQ_SHARE_ID;
+	dev->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
+	dev->irq.IRQInfo1 = IRQ_LEVEL_ID;
 	dev->irq.Handler = NULL; /* The handler is registered later. */
 	dev->irq.Instance = NULL;
 	res = pcmcia_request_irq(dev, &dev->irq);
diff --git a/net/mac80211/ieee80211.c b/net/mac80211/ieee80211.c
index 28bcdf9..8e58639 100644
--- a/net/mac80211/ieee80211.c
+++ b/net/mac80211/ieee80211.c
@@ -286,6 +286,18 @@ static int ieee80211_open(struct net_device *dev)
 	if (need_hw_reconfig)
 		ieee80211_hw_config(local);
 
+	/*
+	 * ieee80211_sta_work is disabled while network interface
+	 * is down. Therefore, some configuration changes may not
+	 * yet be effective. Trigger execution of ieee80211_sta_work
+	 * to fix this.
+	 */
+	if(sdata->vif.type == IEEE80211_IF_TYPE_STA ||
+	   sdata->vif.type == IEEE80211_IF_TYPE_IBSS) {
+		struct ieee80211_if_sta *ifsta = &sdata->u.sta;
+		queue_work(local->hw.workqueue, &ifsta->work);
+	}
+
 	netif_start_queue(dev);
 
 	return 0;
diff --git a/net/mac80211/ieee80211_sta.c b/net/mac80211/ieee80211_sta.c
index 9aeed53..e0c72d0 100644
--- a/net/mac80211/ieee80211_sta.c
+++ b/net/mac80211/ieee80211_sta.c
@@ -319,7 +319,7 @@ static u32 ieee80211_handle_erp_ie(struct ieee80211_sub_if_data *sdata,
 	struct ieee80211_bss_conf *bss_conf = &sdata->bss_conf;
 	struct ieee80211_if_sta *ifsta = &sdata->u.sta;
 	bool use_protection = (erp_value & WLAN_ERP_USE_PROTECTION) != 0;
-	bool preamble_mode = (erp_value & WLAN_ERP_BARKER_PREAMBLE) != 0;
+	bool use_short_preamble = (erp_value & WLAN_ERP_BARKER_PREAMBLE) == 0;
 	DECLARE_MAC_BUF(mac);
 	u32 changed = 0;
 
@@ -335,16 +335,15 @@ static u32 ieee80211_handle_erp_ie(struct ieee80211_sub_if_data *sdata,
 		changed |= BSS_CHANGED_ERP_CTS_PROT;
 	}
 
-	if (preamble_mode != bss_conf->use_short_preamble) {
+	if (use_short_preamble != bss_conf->use_short_preamble) {
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG "%s: switched to %s barker preamble"
 			       " (BSSID=%s)\n",
 			       sdata->dev->name,
-			       (preamble_mode == WLAN_ERP_PREAMBLE_SHORT) ?
-					"short" : "long",
+			       use_short_preamble ? "short" : "long",
 			       print_mac(mac, ifsta->bssid));
 		}
-		bss_conf->use_short_preamble = preamble_mode;
+		bss_conf->use_short_preamble = use_short_preamble;
 		changed |= BSS_CHANGED_ERP_PREAMBLE;
 	}
 
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
