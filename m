From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH v3.6 19/19] wireless: slight optimization of addr compare
Date: Wed, 8 Jan 2014 10:54:26 +0800
Message-ID: <52CCBDE2.6010506@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "John W. Linville" <linville@tuxdriver.com>,
	<linux-wireless@vger.kernel.org>, Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:43485 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755322AbaAHCy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 21:54:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use possibly more efficient ether_addr_equal or
ether_addr_equal_unaligned instead of memcmp.

Cc: John W. Linville <linville@tuxdriver.com>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Weilong Chen <chenweilong@huawei.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/wireless/adm8211.c                | 2 +-
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c | 7 +++----
 drivers/net/wireless/hostap/hostap_80211_rx.c | 8 ++++----
 drivers/net/wireless/prism54/isl_ioctl.c      | 3 ++-
 drivers/net/wireless/ti/wl1251/main.c         | 2 +-
 drivers/net/wireless/wl3501_cs.c              | 4 ++--
 6 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
index cfce83e..1d40c69 100644
--- a/drivers/net/wireless/adm8211.c
+++ b/drivers/net/wireless/adm8211.c
@@ -1314,7 +1314,7 @@ static void adm8211_bss_info_changed(struct ieee80211_hw *dev,
 	if (!(changes & BSS_CHANGED_BSSID))
 		return;
 
-	if (memcmp(conf->bssid, priv->bssid, ETH_ALEN)) {
+	if (!ether_addr_equal(conf->bssid, priv->bssid)) {
 		adm8211_set_bssid(dev, conf->bssid);
 		memcpy(priv->bssid, conf->bssid, ETH_ALEN);
 	}
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/p2p.c b/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
index d318036..185af8a 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
@@ -1243,7 +1243,7 @@ bool brcmf_p2p_scan_finding_common_channel(struct brcmf_cfg80211_info *cfg,
 					    IEEE80211_P2P_ATTR_DEVICE_ID,
 					    p2p_dev_addr, sizeof(p2p_dev_addr));
 	if ((err >= 0) &&
-	    (!memcmp(p2p_dev_addr, afx_hdl->tx_dst_addr, ETH_ALEN))) {
+	    (ether_addr_equal(p2p_dev_addr, afx_hdl->tx_dst_addr))) {
 		if (!bi->ctl_ch) {
 			ch.chspec = le16_to_cpu(bi->chanspec);
 			cfg->d11inf.decchspec(&ch);
@@ -1380,8 +1380,7 @@ int brcmf_p2p_notify_action_frame_rx(struct brcmf_if *ifp,
 		    (brcmf_p2p_gon_req_collision(p2p, (u8 *)e->addr))) {
 			if (test_bit(BRCMF_P2P_STATUS_FINDING_COMMON_CHANNEL,
 				     &p2p->status) &&
-			    (memcmp(afx_hdl->tx_dst_addr, e->addr,
-				    ETH_ALEN) == 0)) {
+			    (ether_addr_equal(afx_hdl->tx_dst_addr, e->addr))) {
 				afx_hdl->peer_chan = ch.chnum;
 				brcmf_dbg(INFO, "GON request: Peer found, channel=%d\n",
 					  afx_hdl->peer_chan);
@@ -1865,7 +1864,7 @@ s32 brcmf_p2p_notify_rx_mgmt_p2p_probereq(struct brcmf_if *ifp,
 	cfg->d11inf.decchspec(&ch);
 
 	if (test_bit(BRCMF_P2P_STATUS_FINDING_COMMON_CHANNEL, &p2p->status) &&
-	    (memcmp(afx_hdl->tx_dst_addr, e->addr, ETH_ALEN) == 0)) {
+	    (ether_addr_equal(afx_hdl->tx_dst_addr, e->addr))) {
 		afx_hdl->peer_chan = ch.chnum;
 		brcmf_dbg(INFO, "PROBE REQUEST: Peer found, channel=%d\n",
 			  afx_hdl->peer_chan);
diff --git a/drivers/net/wireless/hostap/hostap_80211_rx.c b/drivers/net/wireless/hostap/hostap_80211_rx.c
index d39e3e2..599f30f 100644
--- a/drivers/net/wireless/hostap/hostap_80211_rx.c
+++ b/drivers/net/wireless/hostap/hostap_80211_rx.c
@@ -563,7 +563,7 @@ hostap_rx_frame_wds(local_info_t *local, struct ieee80211_hdr *hdr, u16 fc,
 
 	/* Possible WDS frame: either IEEE 802.11 compliant (if FromDS)
 	 * or own non-standard frame with 4th address after payload */
-	if (memcmp(hdr->addr1, local->dev->dev_addr, ETH_ALEN) != 0 &&
+	if (!ether_addr_equal(hdr->addr1, local->dev->dev_addr) &&
 	    (hdr->addr1[0] != 0xff || hdr->addr1[1] != 0xff ||
 	     hdr->addr1[2] != 0xff || hdr->addr1[3] != 0xff ||
 	     hdr->addr1[4] != 0xff || hdr->addr1[5] != 0xff)) {
@@ -622,12 +622,12 @@ static int hostap_is_eapol_frame(local_info_t *local, struct sk_buff *skb)
 	/* check that the frame is unicast frame to us */
 	if ((fc & (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS)) ==
 	    IEEE80211_FCTL_TODS &&
-	    memcmp(hdr->addr1, dev->dev_addr, ETH_ALEN) == 0 &&
-	    memcmp(hdr->addr3, dev->dev_addr, ETH_ALEN) == 0) {
+	    ether_addr_equal(hdr->addr1, dev->dev_addr) &&
+	    ether_addr_equal(hdr->addr3, dev->dev_addr)) {
 		/* ToDS frame with own addr BSSID and DA */
 	} else if ((fc & (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS)) ==
 		   IEEE80211_FCTL_FROMDS &&
-		   memcmp(hdr->addr1, dev->dev_addr, ETH_ALEN) == 0) {
+		   ether_addr_equal(hdr->addr1, dev->dev_addr)) {
 		/* FromDS frame with own addr as DA */
 	} else
 		return 0;
diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
index df784fe..78fa64d 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.c
+++ b/drivers/net/wireless/prism54/isl_ioctl.c
@@ -24,6 +24,7 @@
 #include <linux/if_arp.h>
 #include <linux/slab.h>
 #include <linux/pci.h>
+#include <linux/etherdevice.h>
 
 #include <asm/uaccess.h>
 
@@ -1860,7 +1861,7 @@ prism54_del_mac(struct net_device *ndev, struct iw_request_info *info,
 	if (mutex_lock_interruptible(&acl->lock))
 		return -ERESTARTSYS;
 	list_for_each_entry(entry, &acl->mac_list, _list) {
-		if (memcmp(entry->addr, addr->sa_data, ETH_ALEN) == 0) {
+		if (ether_addr_equal(entry->addr, addr->sa_data)) {
 			list_del(&entry->_list);
 			acl->size--;
 			kfree(entry);
diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wireless/ti/wl1251/main.c
index 3291ffa..b8a360b 100644
--- a/drivers/net/wireless/ti/wl1251/main.c
+++ b/drivers/net/wireless/ti/wl1251/main.c
@@ -521,7 +521,7 @@ static int wl1251_op_add_interface(struct ieee80211_hw *hw,
 		goto out;
 	}
 
-	if (memcmp(wl->mac_addr, vif->addr, ETH_ALEN)) {
+	if (!ether_addr_equal_unaligned(wl->mac_addr, vif->addr)) {
 		memcpy(wl->mac_addr, vif->addr, ETH_ALEN);
 		SET_IEEE80211_PERM_ADDR(wl->hw, wl->mac_addr);
 		ret = wl1251_acx_station_id(wl);
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index 38d2089..1477d7f 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -44,6 +44,7 @@
 #include <linux/string.h>
 #include <linux/wireless.h>
 #include <linux/ieee80211.h>
+#include <linux/etherdevice.h>
 
 #include <net/iw_handler.h>
 
@@ -673,8 +674,7 @@ static void wl3501_mgmt_scan_confirm(struct wl3501_card *this, u16 addr)
 				matchflag = 1;
 			if (matchflag) {
 				for (i = 0; i < this->bss_cnt; i++) {
-					if (!memcmp(this->bss_set[i].bssid,
-						    sig.bssid, ETH_ALEN)) {
+					if (ether_addr_equal_unaligned(this->bss_set[i].bssid, sig.bssid)) {
 						matchflag = 0;
 						break;
 					}
-- 
1.8.0
