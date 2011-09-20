From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2011-09-20
Date: Tue, 20 Sep 2011 13:05:01 -0400
Message-ID: <20110920170501.GE7800@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47436 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751609Ab1ITRPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2011 13:15:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

This is a batch of fixes intended for 3.1.

Included is a set of Bluetooth fixes from Gustavo:

	This is probably my unique pull request for 3.1, it fixes
	an regression with the HCI_INQUIRY flag, it was not getting
	cleaned after scan. Fix by Oliver Neukum. Also support for
	two new apple devices and a simple fix the to btwilink driver.

Also included is an iwlagn patch revert to avoid some AP crashes, an
rt2800 patch to refactor some code that triggers a compiler bug, another
rt2800 patch to correct an endian bug, a b43 fix to restore beaconing in
ad-hoc mode, a regulatory enforcement fix for a problem that prevented
multiple regulatory domain changes from beacons, a fix to use the proper
rates in a probe request, and a fix for a deadlock that had crept into
ipw2200 after an earlier patch.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 9d037a777695993ec7437e5f451647dea7919d4c:

  Merge branch 'irq-fixes-for-linus' of git://tesla.tglx.de/git/linux-2.6-tip (2011-09-19 17:23:41 -0700)

are available in the git repository at:

  git://git.infradead.org/users/linville/wireless.git for-davem

Chen Ganir (1):
      Bluetooth: Fixed BT ST Channel reg order

Don Fry (1):
      iwlagn: workaround bug crashing some APs

John W. Linville (2):
      Merge branch 'for-3.1' of git://github.com/padovan/bluetooth-next
      Merge branch 'master' of ssh://infradead/~/public_git/wireless into for-davem

Jurgen Kramer (1):
      Bluetooth: add support for 2011 mac mini

Larry Finger (2):
      rt2800pci: Fix compiler error on PowerPC
      rtl2800usb: Fix incorrect storage of MAC address on big-endian platforms

Manual Munz (1):
      b43: Fix beacon problem in ad-hoc mode

Oliver Neukum (1):
      Bluetooth: Fix timeout on scanning for the second time

Pieter-Augustijn Van Malleghem (1):
      Bluetooth: Add MacBookAir4,1 support

Rajkumar Manoharan (2):
      wireless: Reset beacon_found while updating regulatory
      wireless: Fix rate mask for scan request

Stanislaw Gruszka (1):
      ipw2x00: fix rtnl mutex deadlock

 drivers/bluetooth/btusb.c               |    6 ++++
 drivers/bluetooth/btwilink.c            |   16 +++++-----
 drivers/net/wireless/b43/main.c         |    3 +-
 drivers/net/wireless/ipw2x00/ipw2100.c  |   21 +++++++++----
 drivers/net/wireless/ipw2x00/ipw2200.c  |   39 +++++++++++++++++--------
 drivers/net/wireless/iwlwifi/iwl-agn.c  |    5 +++
 drivers/net/wireless/rt2x00/rt2800lib.c |   47 +++++++++++++++++--------------
 net/bluetooth/hci_event.c               |   17 +++++------
 net/wireless/reg.c                      |    1 +
 net/wireless/sme.c                      |    2 +
 10 files changed, 98 insertions(+), 59 deletions(-)

diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index 3ef4760..9cbac6b 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -72,9 +72,15 @@ static struct usb_device_id btusb_table[] = {
 	/* Apple MacBookAir3,1, MacBookAir3,2 */
 	{ USB_DEVICE(0x05ac, 0x821b) },
 
+	/* Apple MacBookAir4,1 */
+	{ USB_DEVICE(0x05ac, 0x821f) },
+
 	/* Apple MacBookPro8,2 */
 	{ USB_DEVICE(0x05ac, 0x821a) },
 
+	/* Apple MacMini5,1 */
+	{ USB_DEVICE(0x05ac, 0x8281) },
+
 	/* AVM BlueFRITZ! USB v2.0 */
 	{ USB_DEVICE(0x057c, 0x3800) },
 
diff --git a/drivers/bluetooth/btwilink.c b/drivers/bluetooth/btwilink.c
index 65d27af..04d353f 100644
--- a/drivers/bluetooth/btwilink.c
+++ b/drivers/bluetooth/btwilink.c
@@ -125,6 +125,13 @@ static long st_receive(void *priv_data, struct sk_buff *skb)
 /* protocol structure registered with shared transport */
 static struct st_proto_s ti_st_proto[MAX_BT_CHNL_IDS] = {
 	{
+		.chnl_id = HCI_EVENT_PKT, /* HCI Events */
+		.hdr_len = sizeof(struct hci_event_hdr),
+		.offset_len_in_hdr = offsetof(struct hci_event_hdr, plen),
+		.len_size = 1, /* sizeof(plen) in struct hci_event_hdr */
+		.reserve = 8,
+	},
+	{
 		.chnl_id = HCI_ACLDATA_PKT, /* ACL */
 		.hdr_len = sizeof(struct hci_acl_hdr),
 		.offset_len_in_hdr = offsetof(struct hci_acl_hdr, dlen),
@@ -138,13 +145,6 @@ static struct st_proto_s ti_st_proto[MAX_BT_CHNL_IDS] = {
 		.len_size = 1, /* sizeof(dlen) in struct hci_sco_hdr */
 		.reserve = 8,
 	},
-	{
-		.chnl_id = HCI_EVENT_PKT, /* HCI Events */
-		.hdr_len = sizeof(struct hci_event_hdr),
-		.offset_len_in_hdr = offsetof(struct hci_event_hdr, plen),
-		.len_size = 1, /* sizeof(plen) in struct hci_event_hdr */
-		.reserve = 8,
-	},
 };
 
 /* Called from HCI core to initialize the device */
@@ -240,7 +240,7 @@ static int ti_st_close(struct hci_dev *hdev)
 	if (!test_and_clear_bit(HCI_RUNNING, &hdev->flags))
 		return 0;
 
-	for (i = 0; i < MAX_BT_CHNL_IDS; i++) {
+	for (i = MAX_BT_CHNL_IDS-1; i >= 0; i--) {
 		err = st_unregister(&ti_st_proto[i]);
 		if (err)
 			BT_ERR("st_unregister(%d) failed with error %d",
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 26f1ab8..e293a79 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -1632,7 +1632,8 @@ static void handle_irq_beacon(struct b43_wldev *dev)
 	u32 cmd, beacon0_valid, beacon1_valid;
 
 	if (!b43_is_mode(wl, NL80211_IFTYPE_AP) &&
-	    !b43_is_mode(wl, NL80211_IFTYPE_MESH_POINT))
+	    !b43_is_mode(wl, NL80211_IFTYPE_MESH_POINT) &&
+	    !b43_is_mode(wl, NL80211_IFTYPE_ADHOC))
 		return;
 
 	/* This is the bottom half of the asynchronous beacon update. */
diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index 3774dd0..ef9ad79 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -1903,15 +1903,17 @@ static void ipw2100_down(struct ipw2100_priv *priv)
 static int ipw2100_net_init(struct net_device *dev)
 {
 	struct ipw2100_priv *priv = libipw_priv(dev);
+
+	return ipw2100_up(priv, 1);
+}
+
+static int ipw2100_wdev_init(struct net_device *dev)
+{
+	struct ipw2100_priv *priv = libipw_priv(dev);
 	const struct libipw_geo *geo = libipw_get_geo(priv->ieee);
 	struct wireless_dev *wdev = &priv->ieee->wdev;
-	int ret;
 	int i;
 
-	ret = ipw2100_up(priv, 1);
-	if (ret)
-		return ret;
-
 	memcpy(wdev->wiphy->perm_addr, priv->mac_addr, ETH_ALEN);
 
 	/* fill-out priv->ieee->bg_band */
@@ -6350,9 +6352,13 @@ static int ipw2100_pci_init_one(struct pci_dev *pci_dev,
 		       "Error calling register_netdev.\n");
 		goto fail;
 	}
+	registered = 1;
+
+	err = ipw2100_wdev_init(dev);
+	if (err)
+		goto fail;
 
 	mutex_lock(&priv->action_mutex);
-	registered = 1;
 
 	IPW_DEBUG_INFO("%s: Bound to %s\n", dev->name, pci_name(pci_dev));
 
@@ -6389,7 +6395,8 @@ static int ipw2100_pci_init_one(struct pci_dev *pci_dev,
 
       fail_unlock:
 	mutex_unlock(&priv->action_mutex);
-
+	wiphy_unregister(priv->ieee->wdev.wiphy);
+	kfree(priv->ieee->bg_band.channels);
       fail:
 	if (dev) {
 		if (registered)
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 87813c3..4ffebed 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -11425,16 +11425,23 @@ static void ipw_bg_down(struct work_struct *work)
 /* Called by register_netdev() */
 static int ipw_net_init(struct net_device *dev)
 {
+	int rc = 0;
+	struct ipw_priv *priv = libipw_priv(dev);
+
+	mutex_lock(&priv->mutex);
+	if (ipw_up(priv))
+		rc = -EIO;
+	mutex_unlock(&priv->mutex);
+
+	return rc;
+}
+
+static int ipw_wdev_init(struct net_device *dev)
+{
 	int i, rc = 0;
 	struct ipw_priv *priv = libipw_priv(dev);
 	const struct libipw_geo *geo = libipw_get_geo(priv->ieee);
 	struct wireless_dev *wdev = &priv->ieee->wdev;
-	mutex_lock(&priv->mutex);
-
-	if (ipw_up(priv)) {
-		rc = -EIO;
-		goto out;
-	}
 
 	memcpy(wdev->wiphy->perm_addr, priv->mac_addr, ETH_ALEN);
 
@@ -11519,13 +11526,9 @@ static int ipw_net_init(struct net_device *dev)
 	set_wiphy_dev(wdev->wiphy, &priv->pci_dev->dev);
 
 	/* With that information in place, we can now register the wiphy... */
-	if (wiphy_register(wdev->wiphy)) {
+	if (wiphy_register(wdev->wiphy))
 		rc = -EIO;
-		goto out;
-	}
-
 out:
-	mutex_unlock(&priv->mutex);
 	return rc;
 }
 
@@ -11832,14 +11835,22 @@ static int __devinit ipw_pci_probe(struct pci_dev *pdev,
 		goto out_remove_sysfs;
 	}
 
+	err = ipw_wdev_init(net_dev);
+	if (err) {
+		IPW_ERROR("failed to register wireless device\n");
+		goto out_unregister_netdev;
+	}
+
 #ifdef CONFIG_IPW2200_PROMISCUOUS
 	if (rtap_iface) {
 	        err = ipw_prom_alloc(priv);
 		if (err) {
 			IPW_ERROR("Failed to register promiscuous network "
 				  "device (error %d).\n", err);
-			unregister_netdev(priv->net_dev);
-			goto out_remove_sysfs;
+			wiphy_unregister(priv->ieee->wdev.wiphy);
+			kfree(priv->ieee->a_band.channels);
+			kfree(priv->ieee->bg_band.channels);
+			goto out_unregister_netdev;
 		}
 	}
 #endif
@@ -11851,6 +11862,8 @@ static int __devinit ipw_pci_probe(struct pci_dev *pdev,
 
 	return 0;
 
+      out_unregister_netdev:
+	unregister_netdev(priv->net_dev);
       out_remove_sysfs:
 	sysfs_remove_group(&pdev->dev.kobj, &ipw_attribute_group);
       out_release_irq:
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index b0ae4de..f9c3cd9 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -2140,7 +2140,12 @@ static int iwl_mac_setup_register(struct iwl_priv *priv,
 		    IEEE80211_HW_SPECTRUM_MGMT |
 		    IEEE80211_HW_REPORTS_TX_ACK_STATUS;
 
+	/*
+	 * Including the following line will crash some AP's.  This
+	 * workaround removes the stimulus which causes the crash until
+	 * the AP software can be fixed.
 	hw->max_tx_aggregation_subframes = LINK_QUAL_AGG_FRAME_LIMIT_DEF;
+	 */
 
 	hw->flags |= IEEE80211_HW_SUPPORTS_PS |
 		     IEEE80211_HW_SUPPORTS_DYNAMIC_PS;
diff --git a/drivers/net/wireless/rt2x00/rt2800lib.c b/drivers/net/wireless/rt2x00/rt2800lib.c
index ef67f67..0019dfd 100644
--- a/drivers/net/wireless/rt2x00/rt2800lib.c
+++ b/drivers/net/wireless/rt2x00/rt2800lib.c
@@ -3697,14 +3697,15 @@ static void rt2800_efuse_read(struct rt2x00_dev *rt2x00dev, unsigned int i)
 	rt2800_regbusy_read(rt2x00dev, EFUSE_CTRL, EFUSE_CTRL_KICK, &reg);
 
 	/* Apparently the data is read from end to start */
-	rt2800_register_read_lock(rt2x00dev, EFUSE_DATA3,
-					(u32 *)&rt2x00dev->eeprom[i]);
-	rt2800_register_read_lock(rt2x00dev, EFUSE_DATA2,
-					(u32 *)&rt2x00dev->eeprom[i + 2]);
-	rt2800_register_read_lock(rt2x00dev, EFUSE_DATA1,
-					(u32 *)&rt2x00dev->eeprom[i + 4]);
-	rt2800_register_read_lock(rt2x00dev, EFUSE_DATA0,
-					(u32 *)&rt2x00dev->eeprom[i + 6]);
+	rt2800_register_read_lock(rt2x00dev, EFUSE_DATA3, &reg);
+	/* The returned value is in CPU order, but eeprom is le */
+	rt2x00dev->eeprom[i] = cpu_to_le32(reg);
+	rt2800_register_read_lock(rt2x00dev, EFUSE_DATA2, &reg);
+	*(u32 *)&rt2x00dev->eeprom[i + 2] = cpu_to_le32(reg);
+	rt2800_register_read_lock(rt2x00dev, EFUSE_DATA1, &reg);
+	*(u32 *)&rt2x00dev->eeprom[i + 4] = cpu_to_le32(reg);
+	rt2800_register_read_lock(rt2x00dev, EFUSE_DATA0, &reg);
+	*(u32 *)&rt2x00dev->eeprom[i + 6] = cpu_to_le32(reg);
 
 	mutex_unlock(&rt2x00dev->csr_mutex);
 }
@@ -3870,19 +3871,23 @@ int rt2800_init_eeprom(struct rt2x00_dev *rt2x00dev)
 		return -ENODEV;
 	}
 
-	if (!rt2x00_rf(rt2x00dev, RF2820) &&
-	    !rt2x00_rf(rt2x00dev, RF2850) &&
-	    !rt2x00_rf(rt2x00dev, RF2720) &&
-	    !rt2x00_rf(rt2x00dev, RF2750) &&
-	    !rt2x00_rf(rt2x00dev, RF3020) &&
-	    !rt2x00_rf(rt2x00dev, RF2020) &&
-	    !rt2x00_rf(rt2x00dev, RF3021) &&
-	    !rt2x00_rf(rt2x00dev, RF3022) &&
-	    !rt2x00_rf(rt2x00dev, RF3052) &&
-	    !rt2x00_rf(rt2x00dev, RF3320) &&
-	    !rt2x00_rf(rt2x00dev, RF5370) &&
-	    !rt2x00_rf(rt2x00dev, RF5390)) {
-		ERROR(rt2x00dev, "Invalid RF chipset detected.\n");
+	switch (rt2x00dev->chip.rf) {
+	case RF2820:
+	case RF2850:
+	case RF2720:
+	case RF2750:
+	case RF3020:
+	case RF2020:
+	case RF3021:
+	case RF3022:
+	case RF3052:
+	case RF3320:
+	case RF5370:
+	case RF5390:
+		break;
+	default:
+		ERROR(rt2x00dev, "Invalid RF chipset 0x%x detected.\n",
+		      rt2x00dev->chip.rf);
 		return -ENODEV;
 	}
 
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index a40170e..7ef4eb4 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -58,8 +58,8 @@ static void hci_cc_inquiry_cancel(struct hci_dev *hdev, struct sk_buff *skb)
 	if (status)
 		return;
 
-	if (test_bit(HCI_MGMT, &hdev->flags) &&
-				test_and_clear_bit(HCI_INQUIRY, &hdev->flags))
+	if (test_and_clear_bit(HCI_INQUIRY, &hdev->flags) &&
+			test_bit(HCI_MGMT, &hdev->flags))
 		mgmt_discovering(hdev->id, 0);
 
 	hci_req_complete(hdev, HCI_OP_INQUIRY_CANCEL, status);
@@ -76,8 +76,8 @@ static void hci_cc_exit_periodic_inq(struct hci_dev *hdev, struct sk_buff *skb)
 	if (status)
 		return;
 
-	if (test_bit(HCI_MGMT, &hdev->flags) &&
-				test_and_clear_bit(HCI_INQUIRY, &hdev->flags))
+	if (test_and_clear_bit(HCI_INQUIRY, &hdev->flags) &&
+				test_bit(HCI_MGMT, &hdev->flags))
 		mgmt_discovering(hdev->id, 0);
 
 	hci_conn_check_pending(hdev);
@@ -959,9 +959,8 @@ static inline void hci_cs_inquiry(struct hci_dev *hdev, __u8 status)
 		return;
 	}
 
-	if (test_bit(HCI_MGMT, &hdev->flags) &&
-					!test_and_set_bit(HCI_INQUIRY,
-							&hdev->flags))
+	if (!test_and_set_bit(HCI_INQUIRY, &hdev->flags) &&
+				test_bit(HCI_MGMT, &hdev->flags))
 		mgmt_discovering(hdev->id, 1);
 }
 
@@ -1340,8 +1339,8 @@ static inline void hci_inquiry_complete_evt(struct hci_dev *hdev, struct sk_buff
 
 	BT_DBG("%s status %d", hdev->name, status);
 
-	if (test_bit(HCI_MGMT, &hdev->flags) &&
-				test_and_clear_bit(HCI_INQUIRY, &hdev->flags))
+	if (test_and_clear_bit(HCI_INQUIRY, &hdev->flags) &&
+				test_bit(HCI_MGMT, &hdev->flags))
 		mgmt_discovering(hdev->id, 0);
 
 	hci_req_complete(hdev, HCI_OP_INQUIRY, status);
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 02751db..68a471b 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -852,6 +852,7 @@ static void handle_channel(struct wiphy *wiphy,
 		return;
 	}
 
+	chan->beacon_found = false;
 	chan->flags = flags | bw_flags | map_regdom_flags(reg_rule->flags);
 	chan->max_antenna_gain = min(chan->orig_mag,
 		(int) MBI_TO_DBI(power_rule->max_antenna_gain));
diff --git a/net/wireless/sme.c b/net/wireless/sme.c
index b7b6ff8..dec0fa2 100644
--- a/net/wireless/sme.c
+++ b/net/wireless/sme.c
@@ -118,6 +118,8 @@ static int cfg80211_conn_scan(struct wireless_dev *wdev)
 			     i++, j++)
 				request->channels[i] =
 					&wdev->wiphy->bands[band]->channels[j];
+			request->rates[band] =
+				(1 << wdev->wiphy->bands[band]->n_bitrates) - 1;
 		}
 	}
 	request->n_channels = n_channels;
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
