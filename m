From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream-davem' branch of wireless-2.6
Date: Tue, 6 Nov 2007 22:08:53 -0500
Message-ID: <20071107030853.GB30169@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4634 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754812AbXKGDJH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Nov 2007 22:09:07 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Here are a few for when you decide to open net-2.6.25... :-)

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/upstream-davem

---

The following changes since commit 2655e2cee2d77459fcb7e10228259e4ee0328697:
  Alan Cox (1):
        ata_piix: Add additional PCI identifier for 40 wire short cable

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-davem

Mattias Nissler (1):
      mac80211: Accept auto txpower setting

Michael Wu (1):
      ieee80211: Add IEEE80211_MAX_FRAME_LEN to linux/ieee80211.h

 include/linux/ieee80211.h      |   14 +++++++-------
 net/mac80211/ieee80211_ioctl.c |   21 +++++++++++++++++----
 2 files changed, 24 insertions(+), 11 deletions(-)

diff --git a/include/linux/ieee80211.h b/include/linux/ieee80211.h
index 30621c2..214821a 100644
--- a/include/linux/ieee80211.h
+++ b/include/linux/ieee80211.h
@@ -81,18 +81,18 @@
 
 
 /* miscellaneous IEEE 802.11 constants */
-#define IEEE80211_MAX_FRAG_THRESHOLD	2346
-#define IEEE80211_MAX_RTS_THRESHOLD	2347
+#define IEEE80211_MAX_FRAG_THRESHOLD	2352
+#define IEEE80211_MAX_RTS_THRESHOLD	2353
 #define IEEE80211_MAX_AID		2007
 #define IEEE80211_MAX_TIM_LEN		251
-#define IEEE80211_MAX_DATA_LEN		2304
 /* Maximum size for the MA-UNITDATA primitive, 802.11 standard section
    6.2.1.1.2.
 
-   The figure in section 7.1.2 suggests a body size of up to 2312
-   bytes is allowed, which is a bit confusing, I suspect this
-   represents the 2304 bytes of real data, plus a possible 8 bytes of
-   WEP IV and ICV. (this interpretation suggested by Ramiro Barreiro) */
+   802.11e clarifies the figure in section 7.1.2. The frame body is
+   up to 2304 octets long (maximum MSDU size) plus any crypt overhead. */
+#define IEEE80211_MAX_DATA_LEN		2304
+/* 30 byte 4 addr hdr, 2 byte QoS, 2304 byte MSDU, 12 byte crypt, 4 byte FCS */
+#define IEEE80211_MAX_FRAME_LEN		2352
 
 #define IEEE80211_MAX_SSID_LEN		32
 
diff --git a/net/mac80211/ieee80211_ioctl.c b/net/mac80211/ieee80211_ioctl.c
index 6caa3ec..6d67217 100644
--- a/net/mac80211/ieee80211_ioctl.c
+++ b/net/mac80211/ieee80211_ioctl.c
@@ -634,22 +634,35 @@ static int ieee80211_ioctl_siwtxpower(struct net_device *dev,
 {
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	bool need_reconfig = 0;
+	u8 new_power_level;
 
 	if ((data->txpower.flags & IW_TXPOW_TYPE) != IW_TXPOW_DBM)
 		return -EINVAL;
 	if (data->txpower.flags & IW_TXPOW_RANGE)
 		return -EINVAL;
-	if (!data->txpower.fixed)
-		return -EINVAL;
 
-	if (local->hw.conf.power_level != data->txpower.value) {
-		local->hw.conf.power_level = data->txpower.value;
+	if (data->txpower.fixed) {
+		new_power_level = data->txpower.value;
+	} else {
+		/* Automatic power level. Get the px power from the current
+		 * channel. */
+		struct ieee80211_channel* chan = local->oper_channel;
+		if (!chan)
+			return -EINVAL;
+
+		new_power_level = chan->power_level;
+	}
+
+	if (local->hw.conf.power_level != new_power_level) {
+		local->hw.conf.power_level = new_power_level;
 		need_reconfig = 1;
 	}
+
 	if (local->hw.conf.radio_enabled != !(data->txpower.disabled)) {
 		local->hw.conf.radio_enabled = !(data->txpower.disabled);
 		need_reconfig = 1;
 	}
+
 	if (need_reconfig) {
 		ieee80211_hw_config(local);
 		/* The return value of hw_config is not of big interest here,
-- 
John W. Linville
linville@tuxdriver.com
