From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2008-04-09
Date: Wed, 9 Apr 2008 13:55:21 -0400
Message-ID: <20080409175521.GA5574@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4595 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754417AbYDISCz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Apr 2008 14:02:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

This request includes everything from the pull request made on
2008-04-07, plus two fixes related to interrupts on the SSB bus and a
mac80211 fix for problems relating to associating with an 802.11b-only
AP after previously associating with an 802.11g AP.

Original pull request message (quoted below) still applies.  If for some
reason you only want the original set of patches, you can pull the
'master-2008-04-07' branch instead.

Thanks!

John

---

Dave,

Here is another batch of fixes intended for 2.6.25 if at all possible.
We are mostly down to a smattering of one-liners, but there is a little
fix that keeps b43legacy from crashing with certain bcm4303 hardware.

Let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit bfe87dbc7b4da5b05a1a78480e996787a500cc6f:
  David S. Miller (1):
        Merge branch 'upstream-davem' of master.kernel.org:/.../jgarzik/netdev-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Abhijeet Kolekar (1):
      iwlwifi: fix n-band association problem

Daniel Drake (1):
      ipw2200: set MAC address on radiotap interface

Daniel Wagner (1):
      rt61pci: rt61pci_beacon_update do not free skb twice

Holger Schurig (1):
      libertas: fix mode initialization problem

Johannes Berg (1):
      nl80211: fix STA AID bug

Larry Finger (1):
      ssb-pcicore: Fix IRQ TPS flag handling

Michael Buesch (1):
      ssb-mipscore: Fix interrupt vectors

Stefano Brivio (1):
      b43legacy: fix bcm4303 crash

Vladimir Koutny (1):
      mac80211: use short_preamble mode from capability if ERP IE not present

 drivers/net/wireless/ipw2200.c        |    1 +
 drivers/net/wireless/iwlwifi/Kconfig  |    1 -
 drivers/net/wireless/libertas/assoc.c |    2 +-
 drivers/net/wireless/rt2x00/rt61pci.c |    4 +--
 drivers/ssb/driver_mipscore.c         |   13 +++++----
 drivers/ssb/driver_pcicore.c          |    2 +-
 drivers/ssb/main.c                    |    6 ++++
 net/mac80211/ieee80211_sta.c          |   43 ++++++++++++++++++++++++++------
 net/wireless/nl80211.c                |    2 +-
 9 files changed, 53 insertions(+), 21 deletions(-)

diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index a56d9fc..b34c275 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -11576,6 +11576,7 @@ static int ipw_prom_alloc(struct ipw_priv *priv)
 	priv->prom_priv->priv = priv;
 
 	strcpy(priv->prom_net_dev->name, "rtap%d");
+	memcpy(priv->prom_net_dev->dev_addr, priv->mac_addr, ETH_ALEN);
 
 	priv->prom_net_dev->type = ARPHRD_IEEE80211_RADIOTAP;
 	priv->prom_net_dev->open = ipw_prom_open;
diff --git a/drivers/net/wireless/iwlwifi/Kconfig b/drivers/net/wireless/iwlwifi/Kconfig
index b79a35a..b54ff71 100644
--- a/drivers/net/wireless/iwlwifi/Kconfig
+++ b/drivers/net/wireless/iwlwifi/Kconfig
@@ -35,7 +35,6 @@ config IWL4965_HT
 	bool "Enable 802.11n HT features in iwl4965 driver"
 	depends on EXPERIMENTAL
 	depends on IWL4965 && IWL4965_QOS
-	depends on n
 	---help---
 	  This option enables IEEE 802.11n High Throughput features
 	  for the iwl4965 driver.
diff --git a/drivers/net/wireless/libertas/assoc.c b/drivers/net/wireless/libertas/assoc.c
index 87e145f..6a24ed6 100644
--- a/drivers/net/wireless/libertas/assoc.c
+++ b/drivers/net/wireless/libertas/assoc.c
@@ -541,7 +541,7 @@ void lbs_association_worker(struct work_struct *work)
 	}
 
 	if (find_any_ssid) {
-		u8 new_mode;
+		u8 new_mode = assoc_req->mode;
 
 		ret = lbs_find_best_network_ssid(priv, assoc_req->ssid,
 				&assoc_req->ssid_len, assoc_req->mode, &new_mode);
diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wireless/rt2x00/rt61pci.c
index 93ea212..45ead53 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/rt2x00/rt61pci.c
@@ -2399,10 +2399,8 @@ static int rt61pci_beacon_update(struct ieee80211_hw *hw, struct sk_buff *skb,
 	 * beacon frame.
 	 */
 	if (skb_headroom(skb) < TXD_DESC_SIZE) {
-		if (pskb_expand_head(skb, TXD_DESC_SIZE, 0, GFP_ATOMIC)) {
-			dev_kfree_skb(skb);
+		if (pskb_expand_head(skb, TXD_DESC_SIZE, 0, GFP_ATOMIC)) 
 			return -ENOMEM;
-		}
 	}
 
 	/*
diff --git a/drivers/ssb/driver_mipscore.c b/drivers/ssb/driver_mipscore.c
index 3d3dd32..a9e7eb4 100644
--- a/drivers/ssb/driver_mipscore.c
+++ b/drivers/ssb/driver_mipscore.c
@@ -109,12 +109,13 @@ static void set_irq(struct ssb_device *dev, unsigned int irq)
 		clear_irq(bus, oldirq);
 
 	/* assign the new one */
-	if (irq == 0)
-		ssb_write32(mdev, SSB_INTVEC, ((1 << irqflag) & ssb_read32(mdev, SSB_INTVEC)));
-
-	irqflag <<= ipsflag_irq_shift[irq];
-	irqflag |= (ssb_read32(mdev, SSB_IPSFLAG) & ~ipsflag_irq_mask[irq]);
-	ssb_write32(mdev, SSB_IPSFLAG, irqflag);
+	if (irq == 0) {
+		ssb_write32(mdev, SSB_INTVEC, ((1 << irqflag) | ssb_read32(mdev, SSB_INTVEC)));
+	} else {
+		irqflag <<= ipsflag_irq_shift[irq];
+		irqflag |= (ssb_read32(mdev, SSB_IPSFLAG) & ~ipsflag_irq_mask[irq]);
+		ssb_write32(mdev, SSB_IPSFLAG, irqflag);
+	}
 }
 
 static void ssb_mips_serial_init(struct ssb_mipscore *mcore)
diff --git a/drivers/ssb/driver_pcicore.c b/drivers/ssb/driver_pcicore.c
index 74b9a8a..5d777f2 100644
--- a/drivers/ssb/driver_pcicore.c
+++ b/drivers/ssb/driver_pcicore.c
@@ -551,7 +551,7 @@ int ssb_pcicore_dev_irqvecs_enable(struct ssb_pcicore *pc,
 		} else {
 			tmp = ssb_read32(dev, SSB_TPSFLAG);
 			tmp &= SSB_TPSFLAG_BPFLAG;
-			intvec |= tmp;
+			intvec |= (1 << tmp);
 		}
 		ssb_write32(pdev, SSB_INTVEC, intvec);
 	}
diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
index bedb2b4..72017bf 100644
--- a/drivers/ssb/main.c
+++ b/drivers/ssb/main.c
@@ -1044,6 +1044,12 @@ int ssb_bus_may_powerdown(struct ssb_bus *bus)
 		goto out;
 
 	cc = &bus->chipco;
+
+	if (!cc->dev)
+		goto out;
+	if (cc->dev->id.revision < 5)
+		goto out;
+
 	ssb_chipco_set_clockmode(cc, SSB_CLKMODE_SLOW);
 	err = ssb_pci_xtal(bus, SSB_GPIO_XTAL | SSB_GPIO_PLL, 0);
 	if (err)
diff --git a/net/mac80211/ieee80211_sta.c b/net/mac80211/ieee80211_sta.c
index e0c72d0..c170685 100644
--- a/net/mac80211/ieee80211_sta.c
+++ b/net/mac80211/ieee80211_sta.c
@@ -312,14 +312,12 @@ static void ieee80211_sta_wmm_params(struct net_device *dev,
 	}
 }
 
-
-static u32 ieee80211_handle_erp_ie(struct ieee80211_sub_if_data *sdata,
-				   u8 erp_value)
+static u32 ieee80211_handle_protect_preamb(struct ieee80211_sub_if_data *sdata,
+					   bool use_protection,
+					   bool use_short_preamble)
 {
 	struct ieee80211_bss_conf *bss_conf = &sdata->bss_conf;
 	struct ieee80211_if_sta *ifsta = &sdata->u.sta;
-	bool use_protection = (erp_value & WLAN_ERP_USE_PROTECTION) != 0;
-	bool use_short_preamble = (erp_value & WLAN_ERP_BARKER_PREAMBLE) == 0;
 	DECLARE_MAC_BUF(mac);
 	u32 changed = 0;
 
@@ -350,6 +348,32 @@ static u32 ieee80211_handle_erp_ie(struct ieee80211_sub_if_data *sdata,
 	return changed;
 }
 
+static u32 ieee80211_handle_erp_ie(struct ieee80211_sub_if_data *sdata,
+				   u8 erp_value)
+{
+	bool use_protection = (erp_value & WLAN_ERP_USE_PROTECTION) != 0;
+	bool use_short_preamble = (erp_value & WLAN_ERP_BARKER_PREAMBLE) == 0;
+
+	return ieee80211_handle_protect_preamb(sdata,
+			use_protection, use_short_preamble);
+}
+
+static u32 ieee80211_handle_bss_capability(struct ieee80211_sub_if_data *sdata,
+					   struct ieee80211_sta_bss *bss)
+{
+	u32 changed = 0;
+
+	if (bss->has_erp_value)
+		changed |= ieee80211_handle_erp_ie(sdata, bss->erp_value);
+	else {
+		u16 capab = bss->capability;
+		changed |= ieee80211_handle_protect_preamb(sdata, false,
+				(capab & WLAN_CAPABILITY_SHORT_PREAMBLE) != 0);
+	}
+
+	return changed;
+}
+
 int ieee80211_ht_cap_ie_to_ht_info(struct ieee80211_ht_cap *ht_cap_ie,
 				   struct ieee80211_ht_info *ht_info)
 {
@@ -468,9 +492,7 @@ static void ieee80211_set_associated(struct net_device *dev,
 					   local->hw.conf.channel,
 					   ifsta->ssid, ifsta->ssid_len);
 		if (bss) {
-			if (bss->has_erp_value)
-				changed |= ieee80211_handle_erp_ie(
-						sdata, bss->erp_value);
+			changed |= ieee80211_handle_bss_capability(sdata, bss);
 			ieee80211_rx_bss_put(dev, bss);
 		}
 
@@ -2116,6 +2138,11 @@ static void ieee80211_rx_mgmt_beacon(struct net_device *dev,
 
 	if (elems.erp_info && elems.erp_info_len >= 1)
 		changed |= ieee80211_handle_erp_ie(sdata, elems.erp_info[0]);
+	else {
+		u16 capab = le16_to_cpu(mgmt->u.beacon.capab_info);
+		changed |= ieee80211_handle_protect_preamb(sdata, false,
+				(capab & WLAN_CAPABILITY_SHORT_PREAMBLE) != 0);
+	}
 
 	if (elems.ht_cap_elem && elems.ht_info_elem &&
 	    elems.wmm_param && local->ops->conf_ht &&
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index e3a214f..f68a5c8 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -945,7 +945,7 @@ static int nl80211_new_station(struct sk_buff *skb, struct genl_info *info)
 		nla_len(info->attrs[NL80211_ATTR_STA_SUPPORTED_RATES]);
 	params.listen_interval =
 		nla_get_u16(info->attrs[NL80211_ATTR_STA_LISTEN_INTERVAL]);
-	params.listen_interval = nla_get_u16(info->attrs[NL80211_ATTR_STA_AID]);
+	params.aid = nla_get_u16(info->attrs[NL80211_ATTR_STA_AID]);
 
 	if (parse_station_flags(info->attrs[NL80211_ATTR_STA_FLAGS],
 				&params.station_flags))
-- 
John W. Linville
linville@tuxdriver.com
