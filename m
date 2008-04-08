From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2008-04-07
Date: Mon, 7 Apr 2008 23:06:51 -0400
Message-ID: <20080408030651.GA8849@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

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

Holger Schurig (1):
      libertas: fix mode initialization problem

Johannes Berg (1):
      nl80211: fix STA AID bug

Stefano Brivio (1):
      b43legacy: fix bcm4303 crash

 drivers/net/wireless/ipw2200.c        |    1 +
 drivers/net/wireless/iwlwifi/Kconfig  |    1 -
 drivers/net/wireless/libertas/assoc.c |    2 +-
 drivers/ssb/main.c                    |    6 ++++++
 net/wireless/nl80211.c                |    2 +-
 5 files changed, 9 insertions(+), 3 deletions(-)

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
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
