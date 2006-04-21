From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 0/17] d80211 patches
Date: Fri, 21 Apr 2006 22:52:10 +0200
Message-ID: <20060421225210.36a0225b@griffin.suse.cz>
References: <20060421220951.205579000.midnight@suse.cz>
	<200604212252.08325.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:4264 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932437AbWDUUwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:52:11 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200604212252.08325.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 21 Apr 2006 22:52:08 +0200, Michael Buesch wrote:
> Can you please send your hacky patch for the bcm43xx
> to me, so I can come up with a clean one?

Sure, actually I planned to do it in a few minutes :-)


 drivers/net/wireless/bcm43xx-d80211/bcm43xx.h      |    1 
 drivers/net/wireless/bcm43xx-d80211/bcm43xx_main.c |   45 +++++++++++++++++++--
 2 files changed, 42 insertions(+), 4 deletions(-)

--- dscape.orig/drivers/net/wireless/bcm43xx-d80211/bcm43xx.h
+++ dscape/drivers/net/wireless/bcm43xx-d80211/bcm43xx.h
@@ -721,6 +721,7 @@ struct bcm43xx_private {
 	/* Informational stuff. */
 	char nick[IW_ESSID_MAX_SIZE + 1];
 	u8 bssid[ETH_ALEN];
+	int interfaces;
 
 	/* encryption/decryption */
 	u16 security_offset;
--- dscape.orig/drivers/net/wireless/bcm43xx-d80211/bcm43xx_main.c
+++ dscape/drivers/net/wireless/bcm43xx-d80211/bcm43xx_main.c
@@ -4029,9 +4029,6 @@ static int bcm43xx_net_config(struct net
 	if (conf->channel != radio->channel)
 		bcm43xx_radio_selectchannel(bcm, conf->channel, 0);
 
-	if (conf->mode != bcm->iw_mode)
-		bcm43xx_set_iwmode(bcm, conf->mode);
-
 	if (conf->short_slot_time != bcm->short_slot) {
 		assert(phy->type == BCM43xx_PHYTYPE_G);
 		if (conf->short_slot_time)
@@ -4186,8 +4183,13 @@ static void bcm43xx_net_poll_controller(
 static int bcm43xx_net_open(struct net_device *net_dev)
 {
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
+	int res;
 
-	return bcm43xx_init_board(bcm);
+	res = bcm43xx_init_board(bcm);
+	if (!res)
+		return res;
+	bcm43xx_set_iwmode(bcm, bcm->iw_mode);
+	return 0;
 }
 
 static int bcm43xx_net_stop(struct net_device *net_dev)
@@ -4202,6 +4204,39 @@ static int bcm43xx_net_stop(struct net_d
 	return 0;
 }
 
+static int bcm43xx_add_interface(struct net_device *net_dev,
+				 struct ieee80211_if_init_conf *conf)
+{
+	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
+
+	if (bcm->interfaces > 0)
+		return -ENOBUFS;
+	if (conf->type == IEEE80211_IF_TYPE_MNTR) {
+		bcm->iw_mode = IW_MODE_MONITOR;
+	} else {
+		if (memcmp(bcm->net_dev->dev_addr, conf->mac_addr, ETH_ALEN) != 0)
+			return -EADDRNOTAVAIL;
+		if (conf->type == IEEE80211_IF_TYPE_STA)
+			bcm->iw_mode = IW_MODE_INFRA;
+		else if (conf->type == IEEE80211_IF_TYPE_IBSS)
+			bcm->iw_mode = IW_MODE_ADHOC;
+		else if (conf->type == IEEE80211_IF_TYPE_AP)
+			bcm->iw_mode = IW_MODE_MASTER;
+		else
+			return -EOPNOTSUPP;
+	}
+	bcm->interfaces++;
+	return 0;
+}
+
+static void bcm43xx_remove_interface(struct net_device *net_dev,
+				     struct ieee80211_if_init_conf *conf)
+{
+	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
+
+	bcm->interfaces--;
+}
+
 /* Initialization of struct net_device, just after allocation. */
 static void bcm43xx_netdev_setup(struct net_device *net_dev)
 {
@@ -4276,6 +4311,8 @@ static int __devinit bcm43xx_init_one(st
 	ieee->tx = bcm43xx_net_hard_start_xmit;
 	ieee->open = bcm43xx_net_open;
 	ieee->stop = bcm43xx_net_stop;
+	ieee->add_interface = bcm43xx_add_interface;
+	ieee->remove_interface = bcm43xx_remove_interface;
 	ieee->reset = bcm43xx_net_reset;
 	ieee->config = bcm43xx_net_config;
 //TODO	ieee->set_key = bcm43xx_net_set_key;




-- 
Jiri Benc
SUSE Labs
