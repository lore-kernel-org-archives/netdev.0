From: Salam Noureddine <noureddine@aristanetworks.com>
Subject: [PATCH 1/1] forcedeth: add MII ioctls support
Date: Wed, 11 Dec 2013 22:18:09 -0800
Message-ID: <1386829089-24477-1-git-send-email-noureddine@aristanetworks.com>
Cc: Salam Noureddine <noureddine@aristanetworks.com>
To: "David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Patrick McHardy <kaber@trash.net>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Peter Zijlstra <peterz@infradead.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:42494 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751165Ab3LLGS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 01:18:27 -0500
Received: by mail-pb0-f44.google.com with SMTP id rq2so11404396pbb.17
        for <netdev@vger.kernel.org>; Wed, 11 Dec 2013 22:18:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Salam Noureddine <noureddine@aristanetworks.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |   34 +++++++++++++++++++++++++++++++
 1 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 2d045be..0d8c88a 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -5558,6 +5558,38 @@ static int nv_close(struct net_device *dev)
 	return 0;
 }
 
+static int nv_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
+{
+	int ret = 0;
+	u32 val;
+	struct fe_priv *np = netdev_priv(dev);
+	struct mii_ioctl_data *data = (struct mii_ioctl_data *) &req->ifr_data;
+
+	switch (cmd) {
+	case SIOCGMIIPHY:
+		data->phy_id = np->phyaddr;
+		break;
+	case SIOCGMIIREG:
+		spin_lock_irq(&np->lock);
+		val = mii_rw(dev, np->phyaddr, data->reg_num & 0x1f, MII_READ);
+		spin_unlock_irq(&np->lock);
+		data->val_out = val;
+		break;
+	case SIOCSMIIREG:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+		spin_lock_irq(&np->lock);
+		ret = mii_rw(dev, np->phyaddr, data->reg_num & 0x1f,
+			     data->val_in);
+		spin_unlock_irq(&np->lock);
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return ret;
+}
+
 static const struct net_device_ops nv_netdev_ops = {
 	.ndo_open		= nv_open,
 	.ndo_stop		= nv_close,
@@ -5568,6 +5600,7 @@ static const struct net_device_ops nv_netdev_ops = {
 	.ndo_fix_features	= nv_fix_features,
 	.ndo_set_features	= nv_set_features,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_do_ioctl		= nv_ioctl,
 	.ndo_set_mac_address	= nv_set_mac_address,
 	.ndo_set_rx_mode	= nv_set_multicast,
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -5585,6 +5618,7 @@ static const struct net_device_ops nv_netdev_ops_optimized = {
 	.ndo_fix_features	= nv_fix_features,
 	.ndo_set_features	= nv_set_features,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_do_ioctl		= nv_ioctl,
 	.ndo_set_mac_address	= nv_set_mac_address,
 	.ndo_set_rx_mode	= nv_set_multicast,
 #ifdef CONFIG_NET_POLL_CONTROLLER
-- 
1.7.4.4
