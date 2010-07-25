From: "Andrew O. Shadoura" <andrew@beldisplaytech.com>
Subject: [PATCH] 3c59x: Add ethtool WOL support
Date: Sun, 25 Jul 2010 05:24:17 +0300
Message-ID: <201007250524.18911.andrew@beldisplaytech.com>
Reply-To: "Andrew O. Shadoura" <bugzilla@tut.by>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Netdev mailing list <netdev@vger.kernel.org>,
	Linux kernel mailing list <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps.beldisplaytech.com ([69.162.134.24]:33589 "EHLO
	vps.beldisplaytech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982Ab0GYCnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jul 2010 22:43:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds wrappers for ethtool to get or set wake-on-LAN 
setting without re-inserting the kernel module.

Signed-off-by: Andrew O. Shadoura <andrew@beldisplaytech.com>
---
Hello.

I've actually tested this patch on a machine with a network 
card that's idenfied by lsusb as "3c905C-TX/TX-M", and it seems 
to work.

---
diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index d75803e..a452dfe 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -2909,6 +2909,36 @@ static void vortex_get_drvinfo(struct net_device *dev,
 	}
 }
 
+static void vortex_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct vortex_private *vp = netdev_priv(dev);
+
+	spin_lock_irq(&vp->lock);
+	wol->supported = WAKE_MAGIC;
+
+	wol->wolopts = 0;
+	if (vp->enable_wol)
+		wol->wolopts |= WAKE_MAGIC;
+	spin_unlock_irq(&vp->lock);
+}
+
+static int vortex_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct vortex_private *vp = netdev_priv(dev);
+	if (wol->wolopts & ~WAKE_MAGIC)
+		return -EINVAL;
+
+	spin_lock_irq(&vp->lock);
+	if (wol->wolopts & WAKE_MAGIC)
+		vp->enable_wol = 1;
+	else
+		vp->enable_wol = 0;
+	acpi_set_WOL(dev);
+	spin_unlock_irq(&vp->lock);
+
+	return 0;
+}
+
 static const struct ethtool_ops vortex_ethtool_ops = {
 	.get_drvinfo		= vortex_get_drvinfo,
 	.get_strings            = vortex_get_strings,
@@ -2920,6 +2950,8 @@ static const struct ethtool_ops vortex_ethtool_ops = {
 	.set_settings           = vortex_set_settings,
 	.get_link               = ethtool_op_get_link,
 	.nway_reset             = vortex_nway_reset,
+	.get_wol                = vortex_get_wol,
+	.set_wol                = vortex_set_wol,
 };
 
 #ifdef CONFIG_PCI

-- 
WBR, Andrew
