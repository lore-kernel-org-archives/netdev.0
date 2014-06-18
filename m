From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH v2 1/3] net: phylib: add link_change_notify callback to phy device
Date: Wed, 18 Jun 2014 11:01:41 +0200
Message-ID: <1403082103-23709-2-git-send-email-zonque@gmail.com>
References: <1403082103-23709-1-git-send-email-zonque@gmail.com>
Cc: davem@davemloft.net, marek.belisko@gmail.com, ujhelyi.m@gmail.com,
	Daniel Mack <zonque@gmail.com>
To: netdev@vger.kernel.org, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:42533 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965346AbaFRJBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 05:01:55 -0400
Received: by mail-wi0-f174.google.com with SMTP id bs8so7202584wib.7
        for <netdev@vger.kernel.org>; Wed, 18 Jun 2014 02:01:54 -0700 (PDT)
In-Reply-To: <1403082103-23709-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a notify callback to inform phy drivers when the core is about to
do its link adjustment. No change for drivers that do not implement
this callback.

Signed-off-by: Daniel Mack <zonque@gmail.com>
---
 drivers/net/phy/phy.c | 3 +++
 include/linux/phy.h   | 9 +++++++++
 2 files changed, 12 insertions(+)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 3bc079a..f7c6181 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -720,6 +720,9 @@ void phy_state_machine(struct work_struct *work)
 
 	mutex_lock(&phydev->lock);
 
+	if (phydev->drv->link_change_notify)
+		phydev->drv->link_change_notify(phydev);
+
 	switch (phydev->state) {
 	case PHY_DOWN:
 	case PHY_STARTING:
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 51d15f6..54b8723 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -529,6 +529,15 @@ struct phy_driver {
 	/* See set_wol, but for checking whether Wake on LAN is enabled. */
 	void (*get_wol)(struct phy_device *dev, struct ethtool_wolinfo *wol);
 
+	/*
+	 * Called to inform a PHY device driver when the core is about to
+	 * change the link state. This callback is supposed to be used as
+	 * fixup hook for drivers that need to take action when the link
+	 * state changes. Drivers are by no means allowed to mess with the
+	 * PHY device structure in their implementations.
+	 */
+	void (*link_change_notify)(struct phy_device *dev);
+
 	struct device_driver driver;
 };
 #define to_phy_driver(d) container_of(d, struct phy_driver, driver)
-- 
1.9.3
