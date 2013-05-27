From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Subject: [PATCH 1/3] net: phy: prevent linking breakage
Date: Mon, 27 May 2013 18:18:42 +0200
Message-ID: <1369671524-14797-2-git-send-email-alexandre.belloni@free-electrons.com>
References: <1369671524-14797-1-git-send-email-alexandre.belloni@free-electrons.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Russell King <linux@arm.linux.org.uk>,
	Shawn Guo <shawn.guo@linaro.org>,
	Sascha Hauer <kernel@pengutronix.de>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:52929 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752547Ab3E0QTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 May 2013 12:19:17 -0400
In-Reply-To: <1369671524-14797-1-git-send-email-alexandre.belloni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

phy_register_fixup{,_for_uid,_for_id} are called from arch/, quite
often, there is no protection to check whether CONFIG_PHYLIB=y which is
the only case where this would work. Having phylib as a module or not
compiled at all will result in that kind of linking failure:

arch/arm/mach-at91/built-in.o: In function `ksz9021rn_phy_fixup':
:(.text+0x1174): undefined reference to `mdiobus_write'
:(.text+0x1188): undefined reference to `mdiobus_write'
:(.text+0x119c): undefined reference to `mdiobus_write'
:(.text+0x11b0): undefined reference to `mdiobus_write'
arch/arm/mach-at91/built-in.o: In function `sama5_dt_device_init':
:(.init.text+0x1e34): undefined reference to `phy_register_fixup_for_uid'

Signed-off-by: Alexandre Belloni <alexandre.belloni@free-electrons.com>
---
 drivers/net/phy/phy_device.c |  6 ++++++
 include/linux/phy.h          | 12 ++++++++++++
 2 files changed, 18 insertions(+)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 3657b4a..df36367 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -64,6 +64,11 @@ static int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 			     u32 flags, phy_interface_t interface);
 
 /*
+ *  phy_register_fixup{,_for_uid,_for_id} are called from arch/ so this won't
+ *  work unless phylib is compiled in the kernel.
+ */
+#ifdef CONFIG_PHYLIB
+/*
  * Creates a new phy_fixup and adds it to the list
  * @bus_id: A string which matches phydev->dev.bus_id (or PHY_ANY_ID)
  * @phy_uid: Used to match against phydev->phy_id (the UID of the PHY)
@@ -109,6 +114,7 @@ int phy_register_fixup_for_id(const char *bus_id,
 	return phy_register_fixup(bus_id, PHY_ANY_UID, 0xffffffff, run);
 }
 EXPORT_SYMBOL(phy_register_fixup_for_id);
+#endif /* CONFIG_PHYLIB */
 
 /*
  * Returns 1 if fixup matches phydev in bus_id and phy_uid.
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 9e11039..3f998a6 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -556,12 +556,24 @@ int phy_start_interrupts(struct phy_device *phydev);
 void phy_print_status(struct phy_device *phydev);
 void phy_device_free(struct phy_device *phydev);
 
+/*
+ *  phy_register_fixup{,_for_uid,_for_id} are called from arch/ so this won't
+ *  work unless phylib is compiled in the kernel.
+ *  Defining stubs allows to prevent linking errors.
+ */
+#ifdef CONFIG_PHYLIB
 int phy_register_fixup(const char *bus_id, u32 phy_uid, u32 phy_uid_mask,
 		int (*run)(struct phy_device *));
 int phy_register_fixup_for_id(const char *bus_id,
 		int (*run)(struct phy_device *));
 int phy_register_fixup_for_uid(u32 phy_uid, u32 phy_uid_mask,
 		int (*run)(struct phy_device *));
+#else
+#define phy_register_fixup(a, b, c, d) do { } while (0)
+#define phy_register_fixup_for_id(a, b) do { } while (0)
+#define phy_register_fixup_for_uid(a, b, c) do { } while (0)
+#endif /* CONFIG_PHYLIB */
+
 int phy_scan_fixups(struct phy_device *phydev);
 
 int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable);
-- 
1.8.1.2
