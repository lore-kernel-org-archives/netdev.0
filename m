From: "Jouni Malinen" <jkm@devicescape.com>
Subject: net/d80211 and management interface (wmaster0ap)
Date: Tue, 2 May 2006 11:39:30 -0700
Message-ID: <20060502183930.GA28777@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-53.dex002.intermedia.net ([64.78.21.155]:22475 "EHLO
	dhost002-53.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S964962AbWEBSje (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 May 2006 14:39:34 -0400
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It looks like one of your patches in wireless-dev.git broke management
interface. I'm not completely sure about how this was supposed to work,
but are the low-level drivers now expected to accept
IEEE80211_IF_TYPE_MGMT in add_interface handler or should ieee80211.c be
modified to accept wmaster0ap to be set UP without asking the low-level
driver? The patch below does the former by modifying bcm43xx_main.c to
have a special case for IEEE80211_IF_TYPE_MGMT. This interface itself
does not require additional functionality from the low-level driver.

In addition to this, it looked like sending packets from wmaster0ap did
not work. The packets were being dropped since originating device
(wmaster0ap) did not match in is_ieee80211_device(). This function
seemed to use wireless_handlers pointer for recognizing interfaces which
(like to comment says) is not that nice. wireless_handlers were not set
for apdev, so the patch below adds it to make TX work through
wmaster0ap.

Does these match with your understanding of how the management interface
is supposed to work now after your patches went in?



Allow management interface (wmaster0ap) to be set UP with bcm43xx and
allow frames to be sent through it by making sure that
is_ieee80211_device(apdev) returns 1.

Signed-off-by: Jouni Malinen <jkm@devicescape.com>


Index: wireless-dev/net/d80211/ieee80211.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211.c
+++ wireless-dev/net/d80211/ieee80211.c
@@ -4115,6 +4115,8 @@ struct net_device *ieee80211_alloc_hw(si
 	ether_setup(apdev);
 	apdev->priv = local;
 	apdev->hard_start_xmit = ieee80211_mgmt_start_xmit;
+	apdev->wireless_handlers =
+		(struct iw_handler_def *) &ieee80211_iw_handler_def;
 	apdev->change_mtu = ieee80211_change_mtu_apdev;
 	apdev->get_stats = ieee80211_get_stats;
         apdev->open = ieee80211_open;
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
@@ -4195,6 +4195,9 @@ static int bcm43xx_add_interface(struct 
 {
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 
+	if (conf->type == IEEE80211_IF_TYPE_MGMT)
+		return 0;
+
 	if (bcm->interfaces > 0)
 		return -ENOBUFS;
 	if (conf->type == IEEE80211_IF_TYPE_MNTR) {

-- 
Jouni Malinen                                            PGP id EFC895FA
