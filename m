From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/3] tuntap: allow changing ethtool speed (v2)
Date: Wed, 24 Jul 2013 16:11:56 -0700
Message-ID: <20130724161156.4a8cf02b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Helmut Grohne <h.grohne@cygnusnetworks.de>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:57635 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752418Ab3GXXP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 19:15:26 -0400
Received: by mail-pd0-f179.google.com with SMTP id v10so770518pde.10
        for <netdev@vger.kernel.org>; Wed, 24 Jul 2013 16:15:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The data reported by the ethtool interface for tun/tap devices is
artificial. The default speed is 10Mbit. Virtual interfaces are often
faster than this nowadays, so the observed bandwidth may exceed the
available bandwidth. This patch allows an administrator to change the
available bandwidth as reported by ethtool.

Signed-off-by: Helmut Grohne <h.grohne@cygnusnetworks.de>
Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
v2 - allow setting duplex as well, fix patch formatting
     ignore other settings in set

 drivers/net/tun.c |   25 ++++++++++++++++++++++++-
 1 file changed, 24 insertions(+), 1 deletion(-)

--- a/drivers/net/tun.c	2013-07-24 11:24:55.543040360 -0700
+++ b/drivers/net/tun.c	2013-07-24 11:33:06.759433743 -0700
@@ -187,6 +187,8 @@ struct tun_struct {
 	struct list_head disabled;
 	void *security;
 	u32 flow_count;
+	u32 speed;
+	u8 duplex;
 };
 
 static inline u32 tun_hashfn(u32 rxhash)
@@ -1426,6 +1428,8 @@ static void tun_setup(struct net_device
 
 	tun->owner = INVALID_UID;
 	tun->group = INVALID_GID;
+	tun->speed = SPEED_10;
+	tun->duplex = DUPLEX_FULL;
 
 	dev->ethtool_ops = &tun_ethtool_ops;
 	dev->destructor = tun_free_netdev;
@@ -2229,10 +2233,12 @@ static struct miscdevice tun_miscdev = {
 
 static int tun_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
+	struct tun_struct *tun = netdev_priv(dev);
+
 	cmd->supported		= 0;
 	cmd->advertising	= 0;
-	ethtool_cmd_speed_set(cmd, SPEED_10);
-	cmd->duplex		= DUPLEX_FULL;
+	ethtool_cmd_speed_set(cmd, tun->speed);
+	cmd->duplex		= tun->duplex;
 	cmd->port		= PORT_TP;
 	cmd->phy_address	= 0;
 	cmd->transceiver	= XCVR_INTERNAL;
@@ -2242,6 +2248,21 @@ static int tun_get_settings(struct net_d
 	return 0;
 }
 
+static int tun_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct tun_struct *tun = netdev_priv(dev);
+
+	if (cmd->autoneg != AUTONEG_DISABLE)
+		return -EINVAL;
+
+	if (!(cmd->duplex == DUPLEX_FULL || cmd->duplex == DUPLEX_HALF))
+		return -EINVAL;
+
+	tun->speed = ethtool_cmd_speed(cmd);
+	tun->duplex = cmd->duplex;
+	return 0;
+}
+
 static void tun_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
 	struct tun_struct *tun = netdev_priv(dev);
@@ -2279,6 +2300,7 @@ static void tun_set_msglevel(struct net_
 
 static const struct ethtool_ops tun_ethtool_ops = {
 	.get_settings	= tun_get_settings,
+	.set_settings	= tun_set_settings,
 	.get_drvinfo	= tun_get_drvinfo,
 	.get_msglevel	= tun_get_msglevel,
 	.set_msglevel	= tun_set_msglevel,
