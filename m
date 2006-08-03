From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH] d80211: more correct WE support on master interface
Date: Thu, 3 Aug 2006 14:03:04 +0200
Message-ID: <20060803140304.24157844@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:37795 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932380AbWHCMDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 08:03:06 -0400
To: NetDev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Master interface needs to have different WE support than virtual interfaces.
The current situation leads to Oopses and other strange behaviours because
of calling WE functions that shouldn't be supported on master interface.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---
Larry, this should fix both problems you reported.

 net/d80211/ieee80211.c       |    2 +-
 net/d80211/ieee80211_i.h     |    1 +
 net/d80211/ieee80211_ioctl.c |   22 ++++++++++++++++++++++
 3 files changed, 24 insertions(+), 1 deletion(-)

--- dscape.orig/net/d80211/ieee80211.c
+++ dscape/net/d80211/ieee80211.c
@@ -4379,7 +4379,7 @@ struct net_device *ieee80211_alloc_hw(si
 
 	mdev->hard_start_xmit = ieee80211_master_start_xmit;
 	mdev->wireless_handlers =
-		(struct iw_handler_def *) &ieee80211_iw_handler_def;
+		(struct iw_handler_def *) &ieee80211_iw_master_handler_def;
         mdev->do_ioctl = ieee80211_ioctl;
 	mdev->change_mtu = ieee80211_change_mtu;
         mdev->tx_timeout = ieee80211_tx_timeout;
--- dscape.orig/net/d80211/ieee80211_i.h
+++ dscape/net/d80211/ieee80211_i.h
@@ -569,6 +569,7 @@ void ieee80211_if_mgmt_setup(struct net_
 /* ieee80211_ioctl.c */
 int ieee80211_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 extern const struct iw_handler_def ieee80211_iw_handler_def;
+extern const struct iw_handler_def ieee80211_iw_master_handler_def;
 
 /* Set hw encryption from ieee80211 */
 int ieee80211_set_hw_encryption(struct net_device *dev,
--- dscape.orig/net/d80211/ieee80211_ioctl.c
+++ dscape/net/d80211/ieee80211_ioctl.c
@@ -3129,3 +3129,25 @@ const struct iw_handler_def ieee80211_iw
 	.private	= (iw_handler *) ieee80211_private_handler,
 	.private_args	= (struct iw_priv_args *) ieee80211_ioctl_priv,
 };
+
+/* Wireless handlers for master interface */
+
+static const iw_handler ieee80211_master_handler[] =
+{
+	[SIOCGIWNAME  - SIOCIWFIRST] = (iw_handler) ieee80211_ioctl_giwname,
+	[SIOCSIWFREQ  - SIOCIWFIRST] = (iw_handler) ieee80211_ioctl_siwfreq,
+	[SIOCGIWFREQ  - SIOCIWFIRST] = (iw_handler) ieee80211_ioctl_giwfreq,
+	[SIOCGIWRANGE - SIOCIWFIRST] = (iw_handler) ieee80211_ioctl_giwrange,
+	[SIOCSIWRTS   - SIOCIWFIRST] = (iw_handler) ieee80211_ioctl_siwrts,
+	[SIOCGIWRTS   - SIOCIWFIRST] = (iw_handler) ieee80211_ioctl_giwrts,
+	[SIOCSIWFRAG  - SIOCIWFIRST] = (iw_handler) ieee80211_ioctl_siwfrag,
+	[SIOCGIWFRAG  - SIOCIWFIRST] = (iw_handler) ieee80211_ioctl_giwfrag,
+	[SIOCSIWRETRY - SIOCIWFIRST] = (iw_handler) ieee80211_ioctl_siwretry,
+	[SIOCGIWRETRY - SIOCIWFIRST] = (iw_handler) ieee80211_ioctl_giwretry,
+};
+
+const struct iw_handler_def ieee80211_iw_master_handler_def =
+{
+	.num_standard	= sizeof(ieee80211_master_handler) / sizeof(iw_handler),
+	.standard	= ieee80211_master_handler,
+};


-- 
Jiri Benc
SUSE Labs
