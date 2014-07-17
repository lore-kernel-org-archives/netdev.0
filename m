From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH net-next v9 2/9] net: nl80211 - make rdev_add_virtual_intf take name_assign_type
Date: Thu, 17 Jul 2014 10:06:03 +0200
Message-ID: <1405584370-30054-3-git-send-email-teg@jklm.no>
References: <1405584370-30054-1-git-send-email-teg@jklm.no>
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	Tom Gundersen <teg@jklm.no>,
	Johannes Berg <johannes@sipsolutions.net>,
	John Linville <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405584370-30054-1-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pass the value down and set it at the same place the name itself is set.

Signed-off-by: Tom Gundersen <teg@jklm.no>
Cc: Johannes Berg <johannes@sipsolutions.net>
Cc: John Linville <linville@tuxdriver.com>
---
 drivers/net/wireless/ath/ath6kl/cfg80211.c            |  6 ++++--
 drivers/net/wireless/ath/ath6kl/cfg80211.h            |  1 +
 drivers/net/wireless/ath/ath6kl/core.c                |  4 ++--
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h         |  3 ++-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c   | 10 ++++++----
 drivers/net/wireless/brcm80211/brcmfmac/fweh.c        |  2 +-
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c         |  3 +++
 drivers/net/wireless/brcm80211/brcmfmac/p2p.h         |  1 +
 drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c |  4 +++-
 drivers/net/wireless/mwifiex/cfg80211.c               |  5 +++--
 drivers/net/wireless/mwifiex/main.c                   |  2 +-
 drivers/net/wireless/mwifiex/main.h                   |  1 +
 drivers/staging/rtl8723au/os_dep/ioctl_cfg80211.c     |  6 +++++-
 include/net/cfg80211.h                                |  1 +
 net/mac80211/cfg.c                                    |  3 ++-
 net/mac80211/ieee80211_i.h                            |  1 +
 net/mac80211/iface.c                                  |  3 ++-
 net/mac80211/main.c                                   |  2 +-
 net/wireless/nl80211.c                                |  3 ++-
 net/wireless/rdev-ops.h                               |  5 +++--
 20 files changed, 45 insertions(+), 21 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/cfg80211.c b/drivers/net/wireless/ath/ath6kl/cfg80211.c
index 1c4ce8e..3e0bc77 100644
--- a/drivers/net/wireless/ath/ath6kl/cfg80211.c
+++ b/drivers/net/wireless/ath/ath6kl/cfg80211.c
@@ -1494,6 +1494,7 @@ static int ath6kl_cfg80211_set_power_mgmt(struct wiphy *wiphy,
 
 static struct wireless_dev *ath6kl_cfg80211_add_iface(struct wiphy *wiphy,
 						      const char *name,
+						      unsigned char name_assign_type,
 						      enum nl80211_iftype type,
 						      u32 *flags,
 						      struct vif_params *params)
@@ -1512,7 +1513,7 @@ static struct wireless_dev *ath6kl_cfg80211_add_iface(struct wiphy *wiphy,
 		return ERR_PTR(-EINVAL);
 	}
 
-	wdev = ath6kl_interface_add(ar, name, type, if_idx, nw_type);
+	wdev = ath6kl_interface_add(ar, name, name_assign_type, type, if_idx, nw_type);
 	if (!wdev)
 		return ERR_PTR(-ENOMEM);
 
@@ -3630,13 +3631,14 @@ void ath6kl_cfg80211_vif_cleanup(struct ath6kl_vif *vif)
 }
 
 struct wireless_dev *ath6kl_interface_add(struct ath6kl *ar, const char *name,
+					  unsigned char name_assign_type,
 					  enum nl80211_iftype type,
 					  u8 fw_vif_idx, u8 nw_type)
 {
 	struct net_device *ndev;
 	struct ath6kl_vif *vif;
 
-	ndev = alloc_netdev(sizeof(*vif), name, NET_NAME_UNKNOWN, ether_setup);
+	ndev = alloc_netdev(sizeof(*vif), name, name_assign_type, ether_setup);
 	if (!ndev)
 		return NULL;
 
diff --git a/drivers/net/wireless/ath/ath6kl/cfg80211.h b/drivers/net/wireless/ath/ath6kl/cfg80211.h
index b59becd..5aa57a7 100644
--- a/drivers/net/wireless/ath/ath6kl/cfg80211.h
+++ b/drivers/net/wireless/ath/ath6kl/cfg80211.h
@@ -25,6 +25,7 @@ enum ath6kl_cfg_suspend_mode {
 };
 
 struct wireless_dev *ath6kl_interface_add(struct ath6kl *ar, const char *name,
+					  unsigned char name_assign_type,
 					  enum nl80211_iftype type,
 					  u8 fw_vif_idx, u8 nw_type);
 void ath6kl_cfg80211_ch_switch_notify(struct ath6kl_vif *vif, int freq,
diff --git a/drivers/net/wireless/ath/ath6kl/core.c b/drivers/net/wireless/ath/ath6kl/core.c
index b0b6520..997ef42 100644
--- a/drivers/net/wireless/ath/ath6kl/core.c
+++ b/drivers/net/wireless/ath/ath6kl/core.c
@@ -195,8 +195,8 @@ int ath6kl_core_init(struct ath6kl *ar, enum ath6kl_htc_type htc_type)
 	rtnl_lock();
 
 	/* Add an initial station interface */
-	wdev = ath6kl_interface_add(ar, "wlan%d", NL80211_IFTYPE_STATION, 0,
-				    INFRA_NETWORK);
+	wdev = ath6kl_interface_add(ar, "wlan%d", NET_NAME_ENUM,
+				    NL80211_IFTYPE_STATION, 0, INFRA_NETWORK);
 
 	rtnl_unlock();
 
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd.h b/drivers/net/wireless/brcm80211/brcmfmac/dhd.h
index a8998eb..4c27a78 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd.h
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd.h
@@ -171,7 +171,8 @@ char *brcmf_ifname(struct brcmf_pub *drvr, int idx);
 
 int brcmf_net_attach(struct brcmf_if *ifp, bool rtnl_locked);
 struct brcmf_if *brcmf_add_if(struct brcmf_pub *drvr, s32 bssidx, s32 ifidx,
-			      char *name, u8 *mac_addr);
+			      char *name, unsigned char name_assign_type,
+			      u8 *mac_addr);
 void brcmf_del_if(struct brcmf_pub *drvr, s32 bssidx);
 void brcmf_txflowblock_if(struct brcmf_if *ifp,
 			  enum brcmf_netif_stop_reason reason, bool state);
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c b/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
index 2699441..89845cb 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
@@ -773,7 +773,8 @@ fail:
 }
 
 struct brcmf_if *brcmf_add_if(struct brcmf_pub *drvr, s32 bssidx, s32 ifidx,
-			      char *name, u8 *mac_addr)
+			      char *name, unsigned char name_assign_type,
+			      u8 *mac_addr)
 {
 	struct brcmf_if *ifp;
 	struct net_device *ndev;
@@ -808,7 +809,7 @@ struct brcmf_if *brcmf_add_if(struct brcmf_pub *drvr, s32 bssidx, s32 ifidx,
 	} else {
 		brcmf_dbg(INFO, "allocate netdev interface\n");
 		/* Allocate netdev, including space for private structure */
-		ndev = alloc_netdev(sizeof(*ifp), name, NET_NAME_UNKNOWN,
+		ndev = alloc_netdev(sizeof(*ifp), name, name_assign_type,
 				    ether_setup);
 		if (!ndev)
 			return ERR_PTR(-ENOMEM);
@@ -918,12 +919,13 @@ int brcmf_bus_start(struct device *dev)
 	brcmf_dbg(TRACE, "\n");
 
 	/* add primary networking interface */
-	ifp = brcmf_add_if(drvr, 0, 0, "wlan%d", NULL);
+	ifp = brcmf_add_if(drvr, 0, 0, "wlan%d", NET_NAME_ENUM, NULL);
 	if (IS_ERR(ifp))
 		return PTR_ERR(ifp);
 
 	if (brcmf_p2p_enable)
-		p2p_ifp = brcmf_add_if(drvr, 1, 0, "p2p%d", NULL);
+		p2p_ifp = brcmf_add_if(drvr, 1, 0, "p2p%d", NET_NAME_ENUM,
+				       NULL);
 	else
 		p2p_ifp = NULL;
 	if (IS_ERR(p2p_ifp))
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/fweh.c b/drivers/net/wireless/brcm80211/brcmfmac/fweh.c
index fad77dd..f6990f2 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/fweh.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/fweh.c
@@ -201,7 +201,7 @@ static void brcmf_fweh_handle_if_event(struct brcmf_pub *drvr,
 		brcmf_dbg(EVENT, "adding %s (%pM)\n", emsg->ifname,
 			  emsg->addr);
 		ifp = brcmf_add_if(drvr, ifevent->bssidx, ifevent->ifidx,
-				   emsg->ifname, emsg->addr);
+				   emsg->ifname, NET_NAME_UNKNOWN, emsg->addr);
 		if (IS_ERR(ifp))
 			return;
 		brcmf_fws_add_interface(ifp);
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/p2p.c b/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
index 588fdbd..0c1e26a 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
@@ -2245,11 +2245,13 @@ static void brcmf_p2p_delete_p2pdev(struct brcmf_p2p_info *p2p,
  *
  * @wiphy: wiphy device of new interface.
  * @name: name of the new interface.
+ * @name_assign_type: origin of the interface name
  * @type: nl80211 interface type.
  * @flags: not used.
  * @params: contains mac address for P2P device.
  */
 struct wireless_dev *brcmf_p2p_add_vif(struct wiphy *wiphy, const char *name,
+				       unsigned char name_assign_type,
 				       enum nl80211_iftype type, u32 *flags,
 				       struct vif_params *params)
 {
@@ -2309,6 +2311,7 @@ struct wireless_dev *brcmf_p2p_add_vif(struct wiphy *wiphy, const char *name,
 	}
 
 	strncpy(ifp->ndev->name, name, sizeof(ifp->ndev->name) - 1);
+	ifp->ndev->name_assign_type = name_assign_type;
 	err = brcmf_net_attach(ifp, true);
 	if (err) {
 		brcmf_err("Registering netdevice failed\n");
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/p2p.h b/drivers/net/wireless/brcm80211/brcmfmac/p2p.h
index 6821b26..872f382 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/p2p.h
+++ b/drivers/net/wireless/brcm80211/brcmfmac/p2p.h
@@ -149,6 +149,7 @@ struct brcmf_p2p_info {
 s32 brcmf_p2p_attach(struct brcmf_cfg80211_info *cfg);
 void brcmf_p2p_detach(struct brcmf_p2p_info *p2p);
 struct wireless_dev *brcmf_p2p_add_vif(struct wiphy *wiphy, const char *name,
+				       unsigned char name_assign_type,
 				       enum nl80211_iftype type, u32 *flags,
 				       struct vif_params *params);
 int brcmf_p2p_del_vif(struct wiphy *wiphy, struct wireless_dev *wdev);
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
index 9682cf2..7d7dda4 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
@@ -566,6 +566,7 @@ static bool brcmf_is_ibssmode(struct brcmf_cfg80211_vif *vif)
 
 static struct wireless_dev *brcmf_cfg80211_add_iface(struct wiphy *wiphy,
 						     const char *name,
+						     unsigned char name_assign_type,
 						     enum nl80211_iftype type,
 						     u32 *flags,
 						     struct vif_params *params)
@@ -583,7 +584,8 @@ static struct wireless_dev *brcmf_cfg80211_add_iface(struct wiphy *wiphy,
 	case NL80211_IFTYPE_P2P_CLIENT:
 	case NL80211_IFTYPE_P2P_GO:
 	case NL80211_IFTYPE_P2P_DEVICE:
-		return brcmf_p2p_add_vif(wiphy, name, type, flags, params);
+		return brcmf_p2p_add_vif(wiphy, name, name_assign_type, type,
+					 flags, params);
 	case NL80211_IFTYPE_UNSPECIFIED:
 	default:
 		return ERR_PTR(-EINVAL);
diff --git a/drivers/net/wireless/mwifiex/cfg80211.c b/drivers/net/wireless/mwifiex/cfg80211.c
index ca87f92..fae2a4a 100644
--- a/drivers/net/wireless/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/mwifiex/cfg80211.c
@@ -2114,10 +2114,11 @@ mwifiex_setup_ht_caps(struct ieee80211_sta_ht_cap *ht_info,
 }
 
 /*
- *  create a new virtual interface with the given name
+ *  create a new virtual interface with the given name and name assign type
  */
 struct wireless_dev *mwifiex_add_virtual_intf(struct wiphy *wiphy,
 					      const char *name,
+					      unsigned char name_assign_type,
 					      enum nl80211_iftype type,
 					      u32 *flags,
 					      struct vif_params *params)
@@ -2232,7 +2233,7 @@ struct wireless_dev *mwifiex_add_virtual_intf(struct wiphy *wiphy,
 	}
 
 	dev = alloc_netdev_mqs(sizeof(struct mwifiex_private *), name,
-			       NET_NAME_UNKNOWN, ether_setup,
+			       name_assign_type, ether_setup,
 			       IEEE80211_NUM_ACS, 1);
 	if (!dev) {
 		wiphy_err(wiphy, "no memory available for netdevice\n");
diff --git a/drivers/net/wireless/mwifiex/main.c b/drivers/net/wireless/mwifiex/main.c
index 3e5194f..f1b7e1d 100644
--- a/drivers/net/wireless/mwifiex/main.c
+++ b/drivers/net/wireless/mwifiex/main.c
@@ -476,7 +476,7 @@ static void mwifiex_fw_dpc(const struct firmware *firmware, void *context)
 
 	rtnl_lock();
 	/* Create station interface by default */
-	wdev = mwifiex_add_virtual_intf(adapter->wiphy, "mlan%d",
+	wdev = mwifiex_add_virtual_intf(adapter->wiphy, "mlan%d", NET_NAME_ENUM,
 					NL80211_IFTYPE_STATION, NULL, NULL);
 	if (IS_ERR(wdev)) {
 		dev_err(adapter->dev, "cannot create default STA interface\n");
diff --git a/drivers/net/wireless/mwifiex/main.h b/drivers/net/wireless/mwifiex/main.h
index a2733b1..7e75ec45 100644
--- a/drivers/net/wireless/mwifiex/main.h
+++ b/drivers/net/wireless/mwifiex/main.h
@@ -1224,6 +1224,7 @@ u8 mwifiex_chan_type_to_sec_chan_offset(enum nl80211_channel_type chan_type);
 
 struct wireless_dev *mwifiex_add_virtual_intf(struct wiphy *wiphy,
 					      const char *name,
+					      unsigned char name_assign_type,
 					      enum nl80211_iftype type,
 					      u32 *flags,
 					      struct vif_params *params);
diff --git a/drivers/staging/rtl8723au/os_dep/ioctl_cfg80211.c b/drivers/staging/rtl8723au/os_dep/ioctl_cfg80211.c
index f0839f6..969bf40 100644
--- a/drivers/staging/rtl8723au/os_dep/ioctl_cfg80211.c
+++ b/drivers/staging/rtl8723au/os_dep/ioctl_cfg80211.c
@@ -2655,6 +2655,7 @@ static const struct net_device_ops rtw_cfg80211_monitor_if_ops = {
 };
 
 static int rtw_cfg80211_add_monitor_if(struct rtw_adapter *padapter, char *name,
+				       unsigned char name_assign_type,
 				       struct net_device **ndev)
 {
 	int ret = 0;
@@ -2687,6 +2688,7 @@ static int rtw_cfg80211_add_monitor_if(struct rtw_adapter *padapter, char *name,
 	mon_ndev->type = ARPHRD_IEEE80211_RADIOTAP;
 	strncpy(mon_ndev->name, name, IFNAMSIZ);
 	mon_ndev->name[IFNAMSIZ - 1] = 0;
+	mon_ndev->name_assign_type = name_assign_type;
 	mon_ndev->destructor = rtw_ndev_destructor;
 
 	mon_ndev->netdev_ops = &rtw_cfg80211_monitor_if_ops;
@@ -2729,6 +2731,7 @@ out:
 
 static struct wireless_dev *
 cfg80211_rtw_add_virtual_intf(struct wiphy *wiphy, const char *name,
+			      unsigned char name_assign_type,
 			      enum nl80211_iftype type, u32 *flags,
 			      struct vif_params *params)
 {
@@ -2748,7 +2751,8 @@ cfg80211_rtw_add_virtual_intf(struct wiphy *wiphy, const char *name,
 		break;
 	case NL80211_IFTYPE_MONITOR:
 		ret =
-		    rtw_cfg80211_add_monitor_if(padapter, (char *)name, &ndev);
+		    rtw_cfg80211_add_monitor_if(padapter, (char *)name,
+						name_assign_type, &ndev);
 		break;
 
 	case NL80211_IFTYPE_P2P_CLIENT:
diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index 0a080c4..26450ac 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -2321,6 +2321,7 @@ struct cfg80211_ops {
 
 	struct wireless_dev * (*add_virtual_intf)(struct wiphy *wiphy,
 						  const char *name,
+						  unsigned char name_assign_type,
 						  enum nl80211_iftype type,
 						  u32 *flags,
 						  struct vif_params *params);
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 927b4ea..1573258 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -22,6 +22,7 @@
 
 static struct wireless_dev *ieee80211_add_iface(struct wiphy *wiphy,
 						const char *name,
+						unsigned char name_assign_type,
 						enum nl80211_iftype type,
 						u32 *flags,
 						struct vif_params *params)
@@ -31,7 +32,7 @@ static struct wireless_dev *ieee80211_add_iface(struct wiphy *wiphy,
 	struct ieee80211_sub_if_data *sdata;
 	int err;
 
-	err = ieee80211_if_add(local, name, &wdev, type, params);
+	err = ieee80211_if_add(local, name, name_assign_type, &wdev, type, params);
 	if (err)
 		return ERR_PTR(err);
 
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 9e025e1..fdbd4472 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -1523,6 +1523,7 @@ int ieee80211_channel_switch(struct wiphy *wiphy, struct net_device *dev,
 int ieee80211_iface_init(void);
 void ieee80211_iface_exit(void);
 int ieee80211_if_add(struct ieee80211_local *local, const char *name,
+		     unsigned char name_assign_type,
 		     struct wireless_dev **new_wdev, enum nl80211_iftype type,
 		     struct vif_params *params);
 int ieee80211_if_change_type(struct ieee80211_sub_if_data *sdata,
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 4edfc7c..29ec67c 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -1597,6 +1597,7 @@ static void ieee80211_assign_perm_addr(struct ieee80211_local *local,
 }
 
 int ieee80211_if_add(struct ieee80211_local *local, const char *name,
+		     unsigned char name_assign_type,
 		     struct wireless_dev **new_wdev, enum nl80211_iftype type,
 		     struct vif_params *params)
 {
@@ -1625,7 +1626,7 @@ int ieee80211_if_add(struct ieee80211_local *local, const char *name,
 			txqs = IEEE80211_NUM_ACS;
 
 		ndev = alloc_netdev_mqs(sizeof(*sdata) + local->hw.vif_data_size,
-					name, NET_NAME_UNKNOWN,
+					name, name_assign_type,
 					ieee80211_if_setup, txqs, 1);
 		if (!ndev)
 			return -ENOMEM;
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index e0ab432..7929996 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -1019,7 +1019,7 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 
 	/* add one default STA interface if supported */
 	if (local->hw.wiphy->interface_modes & BIT(NL80211_IFTYPE_STATION)) {
-		result = ieee80211_if_add(local, "wlan%d", NULL,
+		result = ieee80211_if_add(local, "wlan%d", NET_NAME_ENUM, NULL,
 					  NL80211_IFTYPE_STATION, NULL);
 		if (result)
 			wiphy_warn(local->hw.wiphy,
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 082f5c6..18c5c1d 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -2613,7 +2613,8 @@ static int nl80211_new_interface(struct sk_buff *skb, struct genl_info *info)
 
 	wdev = rdev_add_virtual_intf(rdev,
 				nla_data(info->attrs[NL80211_ATTR_IFNAME]),
-				type, err ? NULL : &flags, &params);
+				NET_NAME_USER, type, err ? NULL : &flags,
+				&params);
 	if (IS_ERR(wdev)) {
 		nlmsg_free(msg);
 		return PTR_ERR(wdev);
diff --git a/net/wireless/rdev-ops.h b/net/wireless/rdev-ops.h
index 56c2240..8f28587 100644
--- a/net/wireless/rdev-ops.h
+++ b/net/wireless/rdev-ops.h
@@ -35,13 +35,14 @@ static inline void rdev_set_wakeup(struct cfg80211_registered_device *rdev,
 
 static inline struct wireless_dev
 *rdev_add_virtual_intf(struct cfg80211_registered_device *rdev, char *name,
+		       unsigned char name_assign_type,
 		       enum nl80211_iftype type, u32 *flags,
 		       struct vif_params *params)
 {
 	struct wireless_dev *ret;
 	trace_rdev_add_virtual_intf(&rdev->wiphy, name, type);
-	ret = rdev->ops->add_virtual_intf(&rdev->wiphy, name, type, flags,
-					  params);
+	ret = rdev->ops->add_virtual_intf(&rdev->wiphy, name, name_assign_type,
+					  type, flags, params);
 	trace_rdev_return_wdev(&rdev->wiphy, ret);
 	return ret;
 }
-- 
1.9.3
