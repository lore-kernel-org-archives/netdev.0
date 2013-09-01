From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] drivers/net: Convert uses of
 compare_ether_addr to ether_addr_equal
Date: Sun, 01 Sep 2013 11:51:23 -0700
Message-ID: <1378061483.1953.3.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, users@rt2x00.serialmonkey.com
To: netdev <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Use the new bool function ether_addr_equal to add
some clarity and reduce the likelihood for misuse
of compare_ether_addr for sorting.

Done via cocci script: (and a little typing)

$ cat compare_ether_addr.cocci
@@
expression a,b;
@@
-	!compare_ether_addr(a, b)
+	ether_addr_equal(a, b)

@@
expression a,b;
@@
-	compare_ether_addr(a, b)
+	!ether_addr_equal(a, b)

@@
expression a,b;
@@
-	!ether_addr_equal(a, b) == 0
+	ether_addr_equal(a, b)

@@
expression a,b;
@@
-	!ether_addr_equal(a, b) != 0
+	!ether_addr_equal(a, b)

@@
expression a,b;
@@
-	ether_addr_equal(a, b) == 0
+	!ether_addr_equal(a, b)

@@
expression a,b;
@@
-	ether_addr_equal(a, b) != 0
+	ether_addr_equal(a, b)

@@
expression a,b;
@@
-	!!ether_addr_equal(a, b)
+	ether_addr_equal(a, b)

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c    |  4 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c |  4 ++--
 drivers/net/ethernet/tile/tilegx.c                   |  2 +-
 drivers/net/usb/qmi_wwan.c                           |  2 +-
 drivers/net/vxlan.c                                  |  7 +++----
 drivers/net/wireless/ath/carl9170/rx.c               |  4 ++--
 drivers/net/wireless/rt2x00/rt2x00dev.c              |  4 ++--
 drivers/net/wireless/rtlwifi/base.c                  |  2 +-
 drivers/net/wireless/rtlwifi/ps.c                    |  2 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c         |  9 +++++----
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c         | 20 ++++++++++----------
 11 files changed, 30 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 1f5166a..59a62bb 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -488,8 +488,8 @@ static bool ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 		 * source pruning.
 		 */
 		if ((skb->pkt_type & (PACKET_BROADCAST | PACKET_MULTICAST)) &&
-		    !(compare_ether_addr(adapter->netdev->dev_addr,
-					eth_hdr(skb)->h_source))) {
+		    ether_addr_equal(adapter->netdev->dev_addr,
+				     eth_hdr(skb)->h_source)) {
 			dev_kfree_skb_irq(skb);
 			goto next_desc;
 		}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
index eb49cd6..f1261b1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
@@ -1639,14 +1639,14 @@ int qlcnic_sriov_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 	if (!is_valid_ether_addr(mac) || vf >= num_vfs)
 		return -EINVAL;
 
-	if (!compare_ether_addr(adapter->mac_addr, mac)) {
+	if (ether_addr_equal(adapter->mac_addr, mac)) {
 		netdev_err(netdev, "MAC address is already in use by the PF\n");
 		return -EINVAL;
 	}
 
 	for (i = 0; i < num_vfs; i++) {
 		vf_info = &sriov->vf_info[i];
-		if (!compare_ether_addr(vf_info->vp->mac, mac)) {
+		if (ether_addr_equal(vf_info->vp->mac, mac)) {
 			netdev_err(netdev,
 				   "MAC address is already in use by VF %d\n",
 				   i);
diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index 907b577..b05304e 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -544,7 +544,7 @@ static inline bool filter_packet(struct net_device *dev, void *buf)
 	/* Filter out packets that aren't for us. */
 	if (!(dev->flags & IFF_PROMISC) &&
 	    !is_multicast_ether_addr(buf) &&
-	    compare_ether_addr(dev->dev_addr, buf) != 0)
+	    !ether_addr_equal(dev->dev_addr, buf))
 		return true;
 
 	return false;
diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 606eba2..3a81315 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -323,7 +323,7 @@ next_desc:
 	/* Never use the same address on both ends of the link, even
 	 * if the buggy firmware told us to.
 	 */
-	if (!compare_ether_addr(dev->net->dev_addr, default_modem_addr))
+	if (ether_addr_equal(dev->net->dev_addr, default_modem_addr))
 		eth_hw_addr_random(dev->net);
 
 	/* make MAC addr easily distinguishable from an IP header */
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index c3dd6e4..92ae31d 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -371,7 +371,7 @@ static struct vxlan_fdb *__vxlan_find_mac(struct vxlan_dev *vxlan,
 	struct vxlan_fdb *f;
 
 	hlist_for_each_entry_rcu(f, head, hlist) {
-		if (compare_ether_addr(mac, f->eth_addr) == 0)
+		if (ether_addr_equal(mac, f->eth_addr))
 			return f;
 	}
 
@@ -903,8 +903,7 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	skb->protocol = eth_type_trans(skb, vxlan->dev);
 
 	/* Ignore packet loops (and multicast echo) */
-	if (compare_ether_addr(eth_hdr(skb)->h_source,
-			       vxlan->dev->dev_addr) == 0)
+	if (ether_addr_equal(eth_hdr(skb)->h_source, vxlan->dev->dev_addr))
 		goto drop;
 
 	if ((vxlan->flags & VXLAN_F_LEARN) &&
@@ -1054,7 +1053,7 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
 	if (n) {
 		bool diff;
 
-		diff = compare_ether_addr(eth_hdr(skb)->h_dest, n->ha) != 0;
+		diff = !ether_addr_equal(eth_hdr(skb)->h_dest, n->ha);
 		if (diff) {
 			memcpy(eth_hdr(skb)->h_source, eth_hdr(skb)->h_dest,
 				dev->addr_len);
diff --git a/drivers/net/wireless/ath/carl9170/rx.c b/drivers/net/wireless/ath/carl9170/rx.c
index 4684dd9..e935f61 100644
--- a/drivers/net/wireless/ath/carl9170/rx.c
+++ b/drivers/net/wireless/ath/carl9170/rx.c
@@ -602,8 +602,8 @@ static void carl9170_ba_check(struct ar9170 *ar, void *data, unsigned int len)
 
 		if (bar->start_seq_num == entry_bar->start_seq_num &&
 		    TID_CHECK(bar->control, entry_bar->control) &&
-		    compare_ether_addr(bar->ra, entry_bar->ta) == 0 &&
-		    compare_ether_addr(bar->ta, entry_bar->ra) == 0) {
+		    ether_addr_equal(bar->ra, entry_bar->ta) &&
+		    ether_addr_equal(bar->ta, entry_bar->ra)) {
 			struct ieee80211_tx_info *tx_info;
 
 			tx_info = IEEE80211_SKB_CB(entry_skb);
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless/rt2x00/rt2x00dev.c
index b16521e..712eea9 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -566,10 +566,10 @@ static void rt2x00lib_rxdone_check_ba(struct rt2x00_dev *rt2x00dev,
 
 #undef TID_CHECK
 
-		if (compare_ether_addr(ba->ra, entry->ta))
+		if (!ether_addr_equal(ba->ra, entry->ta))
 			continue;
 
-		if (compare_ether_addr(ba->ta, entry->ra))
+		if (!ether_addr_equal(ba->ta, entry->ra))
 			continue;
 
 		/* Mark BAR since we received the according BA */
diff --git a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtlwifi/base.c
index 7651f5a..8bb4a9a 100644
--- a/drivers/net/wireless/rtlwifi/base.c
+++ b/drivers/net/wireless/rtlwifi/base.c
@@ -1304,7 +1304,7 @@ void rtl_beacon_statistic(struct ieee80211_hw *hw, struct sk_buff *skb)
 		return;
 
 	/* and only beacons from the associated BSSID, please */
-	if (compare_ether_addr(hdr->addr3, rtlpriv->mac80211.bssid))
+	if (!ether_addr_equal(hdr->addr3, rtlpriv->mac80211.bssid))
 		return;
 
 	rtlpriv->link_info.bcn_rx_inperiod++;
diff --git a/drivers/net/wireless/rtlwifi/ps.c b/drivers/net/wireless/rtlwifi/ps.c
index 298b615..b593d24 100644
--- a/drivers/net/wireless/rtlwifi/ps.c
+++ b/drivers/net/wireless/rtlwifi/ps.c
@@ -923,7 +923,7 @@ void rtl_p2p_info(struct ieee80211_hw *hw, void *data, unsigned int len)
 		return;
 
 	/* and only beacons from the associated BSSID, please */
-	if (compare_ether_addr(hdr->addr3, rtlpriv->mac80211.bssid))
+	if (!ether_addr_equal(hdr->addr3, rtlpriv->mac80211.bssid))
 		return;
 
 	/* check if this really is a beacon */
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c b/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
index a8871d6..68685a8 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
@@ -305,13 +305,14 @@ static void _rtl88ee_translate_rx_signal_stuff(struct ieee80211_hw *hw,
 	psaddr = ieee80211_get_SA(hdr);
 	memcpy(pstatus->psaddr, psaddr, ETH_ALEN);
 
-	addr = (!compare_ether_addr(mac->bssid, (ufc & IEEE80211_FCTL_TODS) ?
-		hdr->addr1 : (ufc & IEEE80211_FCTL_FROMDS) ?
-		hdr->addr2 : hdr->addr3));
+	addr = ether_addr_equal(mac->bssid,
+				(ufc & IEEE80211_FCTL_TODS) ? hdr->addr1 :
+				(ufc & IEEE80211_FCTL_FROMDS) ? hdr->addr2 :
+				hdr->addr3);
 	match_bssid = ((IEEE80211_FTYPE_CTL != type) && (!pstatus->hwerror) &&
 		       (!pstatus->crc) && (!pstatus->icv)) && addr;
 
-	addr = (!compare_ether_addr(praddr, rtlefuse->dev_addr));
+	addr = ether_addr_equal(praddr, rtlefuse->dev_addr);
 	packet_toself = match_bssid && addr;
 
 	if (ieee80211_is_beacon(fc))
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c b/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
index c72758d..bcd82a1 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
@@ -255,16 +255,16 @@ static void _rtl8723ae_translate_rx_signal_stuff(struct ieee80211_hw *hw,
 	type = WLAN_FC_GET_TYPE(fc);
 	praddr = hdr->addr1;
 
-	packet_matchbssid = ((IEEE80211_FTYPE_CTL != type) &&
-			    (!compare_ether_addr(mac->bssid,
-			    (le16_to_cpu(fc) & IEEE80211_FCTL_TODS) ?
-			    hdr->addr1 : (le16_to_cpu(fc) &
-			    IEEE80211_FCTL_FROMDS) ?
-			    hdr->addr2 : hdr->addr3)) && (!pstatus->hwerror) &&
-			    (!pstatus->crc) && (!pstatus->icv));
-
-	packet_toself = packet_matchbssid &&
-	    (!compare_ether_addr(praddr, rtlefuse->dev_addr));
+	packet_matchbssid =
+		((IEEE80211_FTYPE_CTL != type) &&
+		 ether_addr_equal(mac->bssid,
+				  (le16_to_cpu(fc) & IEEE80211_FCTL_TODS) ? hdr->addr1 :
+				  (le16_to_cpu(fc) & IEEE80211_FCTL_FROMDS) ? hdr->addr2 :
+				  hdr->addr3) &&
+		 (!pstatus->hwerror) && (!pstatus->crc) && (!pstatus->icv));
+
+	packet_toself = (packet_matchbssid &&
+			 ether_addr_equal(praddr, rtlefuse->dev_addr));
 
 	if (ieee80211_is_beacon(fc))
 		packet_beacon = true;



------------------------------------------------------------------------------
Learn the latest--Visual Studio 2012, SharePoint 2013, SQL 2012, more!
Discover the easy way to master current and previous Microsoft technologies
and advance your career. Get an incredible 1,500+ hours of step-by-step
tutorial videos with LearnDevNow. Subscribe today and save!
http://pubads.g.doubleclick.net/gampad/clk?id=58040911&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
