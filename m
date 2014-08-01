From: Oliver Neukum <oneukum@suse.de>
Subject: [PATCH] r8152: correct error returns
Date: Fri,  1 Aug 2014 15:56:10 +0200
Message-ID: <1406901370-6847-1-git-send-email-oneukum@suse.de>
Cc: Oliver Neukum <oneukum@suse.de>
To: davem@davemloft.net, netdev@vger.kernel.org, nic_swsd@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:55579 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753770AbaHAN4Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2014 09:56:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an autoresume fails the internal error codes of the PM
subsystem mustn't be leaked to user space. Replace them by EIO

Signed-off-by: Oliver Neukum <oneukum@suse.de>
---
 drivers/net/usb/r8152.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 87f7104..0e5b9f9 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2810,6 +2810,7 @@ static int rtl8152_open(struct net_device *netdev)
 	res = usb_autopm_get_interface(tp->intf);
 	if (res < 0) {
 		free_all_mem(tp);
+		res = -EIO;
 		goto out;
 	}
 
@@ -3116,8 +3117,10 @@ static int rtl8152_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	int ret;
 
 	ret = usb_autopm_get_interface(tp->intf);
-	if (ret < 0)
+	if (ret < 0) {
+		ret = -EIO;
 		goto out_set_wol;
+	}
 
 	__rtl_set_wol(tp, wol->wolopts);
 	tp->saved_wolopts = wol->wolopts & WAKE_ANY;
@@ -3169,8 +3172,10 @@ static int rtl8152_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	int ret;
 
 	ret = usb_autopm_get_interface(tp->intf);
-	if (ret < 0)
+	if (ret < 0) {
+		ret = -EIO;
 		goto out;
+	}
 
 	ret = rtl8152_set_speed(tp, cmd->autoneg, cmd->speed, cmd->duplex);
 
@@ -3267,8 +3272,10 @@ static int rtl8152_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
 		return -ENODEV;
 
 	res = usb_autopm_get_interface(tp->intf);
-	if (res < 0)
+	if (res < 0) {
+		res = -EIO;
 		goto out;
+	}
 
 	switch (cmd) {
 	case SIOCGMIIPHY:
-- 
1.8.4.5
