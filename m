From: Stas Sergeev <stsp@list.ru>
Subject: [PATCH 1/2] add fixed_phy_update_state() - update state of fixed_phy
Date: Wed, 01 Apr 2015 20:30:31 +0300
Message-ID: <551C2B37.6000100@list.ru>
References: <551C2AB9.8020508@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp25.mail.ru ([94.100.181.180]:58430 "EHLO smtp25.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752570AbbDARal (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2015 13:30:41 -0400
In-Reply-To: <551C2AB9.8020508@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Currently fixed_phy uses a callback to periodically poll the link state.
This patch adds the fixed_phy_update_state() API.
It solves the following problems:
- On link state interrupt, MAC driver can't update status.
Instead it needs to provide the callback to periodically query
the HW about the link state. It is more efficient to update status
after interrupt.
- The callback needs to be unregistered before phy_disconnect(),
or otherwise it will be called with net_dev==NULL. phy_disconnect()
does not have enough info to unregister the callback automatically.
- The callback needs to be registered before of_phy_connect() to
avoid running with outdated state, but of_phy_connect() returns the
phy_device pointer, which is needed to register the callback. Registering
it before of_phy_connect() will therefore require a hack to get the
pointer earlier.

Overall, this addition makes the subsequent patch that implements
SGMII link status for mvneta, much cleaner.

CC: Florian Fainelli <f.fainelli@gmail.com>
CC: netdev@vger.kernel.org
CC: linux-kernel@vger.kernel.org

Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>
---
 drivers/net/phy/fixed_phy.c |   29 +++++++++++++++++++++++++++++
 include/linux/phy_fixed.h   |    9 +++++++++
 2 files changed, 38 insertions(+)

diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
index a08a3c7..1960b46 100644
--- a/drivers/net/phy/fixed_phy.c
+++ b/drivers/net/phy/fixed_phy.c
@@ -183,6 +183,35 @@ int fixed_phy_set_link_update(struct phy_device *phydev,
 }
 EXPORT_SYMBOL_GPL(fixed_phy_set_link_update);

+int fixed_phy_update_state(struct phy_device *phydev,
+			   const struct fixed_phy_status *status,
+			   const struct fixed_phy_status *changed)
+{
+	struct fixed_mdio_bus *fmb = &platform_fmb;
+	struct fixed_phy *fp;
+
+	if (!phydev || !phydev->bus)
+		return -EINVAL;
+
+	list_for_each_entry(fp, &fmb->phys, node) {
+		if (fp->addr == phydev->addr) {
+#define _UPD(x) if (changed->x) \
+	fp->status.x = status->x
+			_UPD(link);
+			_UPD(speed);
+			_UPD(duplex);
+			_UPD(pause);
+			_UPD(asym_pause);
+#undef _UPD
+			fixed_phy_update_regs(fp);
+			return 0;
+		}
+	}
+
+	return -ENOENT;
+}
+EXPORT_SYMBOL(fixed_phy_update_state);
+
 int fixed_phy_add(unsigned int irq, int phy_addr,
 		  struct fixed_phy_status *status)
 {
diff --git a/include/linux/phy_fixed.h b/include/linux/phy_fixed.h
index 7e75bfe..fe5732d 100644
--- a/include/linux/phy_fixed.h
+++ b/include/linux/phy_fixed.h
@@ -21,6 +21,9 @@ extern void fixed_phy_del(int phy_addr);
 extern int fixed_phy_set_link_update(struct phy_device *phydev,
 			int (*link_update)(struct net_device *,
 					   struct fixed_phy_status *));
+extern int fixed_phy_update_state(struct phy_device *phydev,
+			   const struct fixed_phy_status *status,
+			   const struct fixed_phy_status *changed);
 #else
 static inline int fixed_phy_add(unsigned int irq, int phy_id,
 				struct fixed_phy_status *status)
@@ -43,6 +46,12 @@ static inline int fixed_phy_set_link_update(struct phy_device *phydev,
 {
 	return -ENODEV;
 }
+static inline int fixed_phy_update_state(struct phy_device *phydev,
+			   const struct fixed_phy_status *status,
+			   const struct fixed_phy_status *changed)
+{
+	return -ENODEV;
+}
 #endif /* CONFIG_FIXED_PHY */

 #endif /* __PHY_FIXED_H */
-- 
1.7.9.5
