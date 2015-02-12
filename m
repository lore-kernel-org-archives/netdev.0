From: Tobias Waldekranz <tobias@waldekranz.com>
Subject: [PATCH 1/2] phylib: support reading the status of a fixed PHY
Date: Thu, 12 Feb 2015 15:12:55 +0100
Message-ID: <20150212141255.GA12318@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:46962 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755726AbbBLONK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 09:13:10 -0500
Received: by lams18 with SMTP id s18so10265860lam.13
        for <netdev@vger.kernel.org>; Thu, 12 Feb 2015 06:13:09 -0800 (PST)
Received: from gmail.com ([213.132.98.41])
        by mx.google.com with ESMTPSA id d5sm789958lab.27.2015.02.12.06.13.08
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 12 Feb 2015 06:13:08 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes it possible to check if a PHY is fixed or physical.

Signed-off-by: Tobias Waldekranz <tobias@waldekranz.com>
---
 drivers/net/phy/fixed_phy.c | 17 +++++++++++++++++
 include/linux/phy_fixed.h   |  9 +++++++++
 2 files changed, 26 insertions(+)

diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
index a08a3c7..5575345 100644
--- a/drivers/net/phy/fixed_phy.c
+++ b/drivers/net/phy/fixed_phy.c
@@ -156,6 +156,23 @@ static int fixed_mdio_write(struct mii_bus *bus, int phy_addr, int reg_num,
 	return 0;
 }
 
+const struct fixed_phy_status *fixed_phy_get_status(struct phy_device *phydev)
+{
+	struct fixed_mdio_bus *fmb = &platform_fmb;
+	struct fixed_phy *fp;
+
+	if (!phydev || !phydev->bus || phydev->bus->priv != fmb)
+		return NULL;
+
+	list_for_each_entry(fp, &fmb->phys, node) {
+		if (fp->addr == phydev->addr)
+			return &fp->status;
+	}
+
+	return NULL;
+}
+EXPORT_SYMBOL(fixed_phy_get_status);
+
 /*
  * If something weird is required to be done with link/speed,
  * network driver is able to assign a function to implement this.
diff --git a/include/linux/phy_fixed.h b/include/linux/phy_fixed.h
index 7e75bfe..e783b8d 100644
--- a/include/linux/phy_fixed.h
+++ b/include/linux/phy_fixed.h
@@ -12,6 +12,9 @@ struct fixed_phy_status {
 struct device_node;
 
 #if IS_ENABLED(CONFIG_FIXED_PHY)
+extern const struct fixed_phy_status *fixed_phy_get_status(
+	struct phy_device *phydev);
+
 extern int fixed_phy_add(unsigned int irq, int phy_id,
 			 struct fixed_phy_status *status);
 extern struct phy_device *fixed_phy_register(unsigned int irq,
@@ -22,6 +25,12 @@ extern int fixed_phy_set_link_update(struct phy_device *phydev,
 			int (*link_update)(struct net_device *,
 					   struct fixed_phy_status *));
 #else
+static inline const struct fixed_phy_status *fixed_phy_get_status(
+	struct phy_device *phydev)
+{
+	return NULL;
+};
+
 static inline int fixed_phy_add(unsigned int irq, int phy_id,
 				struct fixed_phy_status *status)
 {
-- 
1.8.4.357.g8d83871.dirty
