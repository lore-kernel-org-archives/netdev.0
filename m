From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'fixes-jgarzik' branch of wireless-2.6
Date: Mon, 6 Aug 2007 16:14:41 -0400
Message-ID: <20070806201441.GJ6442@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4245 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760498AbXHFUgc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2007 16:36:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit d4ac2477fad0f2680e84ec12e387ce67682c5c13:
  Linus Torvalds (1):
        Linux 2.6.23-rc2

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-jgarzik

John W. Linville (1):
      Revert "[PATCH] bcm43xx: Fix deviation from specifications in set_baseband_attenuation"

Masakazu Mokuno (1):
      remove duplicated ioctl entries in compat_ioctl.c

Michael Buesch (1):
      softmac: Fix deadlock of wx_set_essid with assoc work

Michael Wu (1):
      rtl8187: ensure priv->hwaddr is always valid

Ulrich Kunitz (1):
      zd1211rw: fix filter for PSPOLL frames

 drivers/net/wireless/bcm43xx/bcm43xx_phy.c  |    2 +-
 drivers/net/wireless/rtl8187_dev.c          |    2 +-
 drivers/net/wireless/zd1211rw/zd_mac.c      |    2 +-
 fs/compat_ioctl.c                           |    3 ---
 net/ieee80211/softmac/ieee80211softmac_wx.c |   11 ++++++++---
 5 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_phy.c b/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
index d779199..b37f1e3 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
@@ -1638,7 +1638,7 @@ void bcm43xx_phy_set_baseband_attenuation(struct bcm43xx_private *bcm,
 		return;
 	}
 
-	if (phy->analog == 1) {
+	if (phy->analog > 1) {
 		value = bcm43xx_phy_read(bcm, 0x0060) & ~0x003C;
 		value |= (baseband_attenuation << 2) & 0x003C;
 	} else {
diff --git a/drivers/net/wireless/rtl8187_dev.c b/drivers/net/wireless/rtl8187_dev.c
index cea8589..e61c6d5 100644
--- a/drivers/net/wireless/rtl8187_dev.c
+++ b/drivers/net/wireless/rtl8187_dev.c
@@ -466,7 +466,7 @@ static int rtl8187_add_interface(struct ieee80211_hw *dev,
 		return -EOPNOTSUPP;
 	}
 
-	priv->hwaddr = conf->mac_addr;
+	priv->hwaddr = conf->mac_addr ? conf->mac_addr : dev->wiphy->perm_addr;
 
 	return 0;
 }
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index f6c487a..26869d1 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -822,7 +822,7 @@ static void cs_set_control(struct zd_mac *mac, struct zd_ctrlset *cs,
 		cs->control |= ZD_CS_MULTICAST;
 
 	/* PS-POLL */
-	if (stype == IEEE80211_STYPE_PSPOLL)
+	if (ftype == IEEE80211_FTYPE_CTL && stype == IEEE80211_STYPE_PSPOLL)
 		cs->control |= ZD_CS_PS_POLL_FRAME;
 
 	/* Unicast data frames over the threshold should have RTS */
diff --git a/fs/compat_ioctl.c b/fs/compat_ioctl.c
index 2bc1428..a6c9078 100644
--- a/fs/compat_ioctl.c
+++ b/fs/compat_ioctl.c
@@ -3161,12 +3161,9 @@ COMPATIBLE_IOCTL(SIOCSIWSENS)
 COMPATIBLE_IOCTL(SIOCGIWSENS)
 COMPATIBLE_IOCTL(SIOCSIWRANGE)
 COMPATIBLE_IOCTL(SIOCSIWPRIV)
-COMPATIBLE_IOCTL(SIOCGIWPRIV)
 COMPATIBLE_IOCTL(SIOCSIWSTATS)
-COMPATIBLE_IOCTL(SIOCGIWSTATS)
 COMPATIBLE_IOCTL(SIOCSIWAP)
 COMPATIBLE_IOCTL(SIOCGIWAP)
-COMPATIBLE_IOCTL(SIOCSIWSCAN)
 COMPATIBLE_IOCTL(SIOCSIWRATE)
 COMPATIBLE_IOCTL(SIOCGIWRATE)
 COMPATIBLE_IOCTL(SIOCSIWRTS)
diff --git a/net/ieee80211/softmac/ieee80211softmac_wx.c b/net/ieee80211/softmac/ieee80211softmac_wx.c
index f13937b..d054e92 100644
--- a/net/ieee80211/softmac/ieee80211softmac_wx.c
+++ b/net/ieee80211/softmac/ieee80211softmac_wx.c
@@ -74,8 +74,8 @@ ieee80211softmac_wx_set_essid(struct net_device *net_dev,
 	struct ieee80211softmac_auth_queue_item *authptr;
 	int length = 0;
 
+check_assoc_again:
 	mutex_lock(&sm->associnfo.mutex);
-
 	/* Check if we're already associating to this or another network
 	 * If it's another network, cancel and start over with our new network
 	 * If it's our network, ignore the change, we're already doing it!
@@ -98,13 +98,18 @@ ieee80211softmac_wx_set_essid(struct net_device *net_dev,
 				cancel_delayed_work(&authptr->work);
 			sm->associnfo.bssvalid = 0;
 			sm->associnfo.bssfixed = 0;
-			flush_scheduled_work();
 			sm->associnfo.associating = 0;
 			sm->associnfo.associated = 0;
+			/* We must unlock to avoid deadlocks with the assoc workqueue
+			 * on the associnfo.mutex */
+			mutex_unlock(&sm->associnfo.mutex);
+			flush_scheduled_work();
+			/* Avoid race! Check assoc status again. Maybe someone started an
+			 * association while we flushed. */
+			goto check_assoc_again;
 		}
 	}
 
-
 	sm->associnfo.static_essid = 0;
 	sm->associnfo.assoc_wait = 0;
 
-- 
John W. Linville
linville@tuxdriver.com
