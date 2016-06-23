From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH net-next 5/5] phy: improve safety of fixed-phy MII register
 reading
Date: Thu, 23 Jun 2016 14:50:25 +0100
Message-ID: <E1bG51V-0006lI-Uu@rmk-PC.armlinux.org.uk>
References: <20160623134936.GX1041@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:45614 "EHLO
	pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150AbcFWNu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 09:50:29 -0400
In-Reply-To: <20160623134936.GX1041@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no prevention of a concurrent call to both fixed_mdio_read()
and fixed_phy_update_state(), which can result in the state being
modified while it's being inspected.  Fix this by using a seqcount
to detect modifications, and memcpy()ing the state.

We remain slightly naughty here, calling link_update() and updating
the link status within the read-side loop - which would need rework
of the design to change.

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/phy/fixed_phy.c | 28 +++++++++++++++++++++-------
 1 file changed, 21 insertions(+), 7 deletions(-)

diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
index 0dfed86bdb5a..b376ada83598 100644
--- a/drivers/net/phy/fixed_phy.c
+++ b/drivers/net/phy/fixed_phy.c
@@ -23,6 +23,7 @@
 #include <linux/slab.h>
 #include <linux/of.h>
 #include <linux/gpio.h>
+#include <linux/seqlock.h>
 
 #include "swphy.h"
 
@@ -34,6 +35,7 @@ struct fixed_mdio_bus {
 struct fixed_phy {
 	int addr;
 	struct phy_device *phydev;
+	seqcount_t seqcount;
 	struct fixed_phy_status status;
 	int (*link_update)(struct net_device *, struct fixed_phy_status *);
 	struct list_head node;
@@ -58,13 +60,21 @@ static int fixed_mdio_read(struct mii_bus *bus, int phy_addr, int reg_num)
 
 	list_for_each_entry(fp, &fmb->phys, node) {
 		if (fp->addr == phy_addr) {
-			/* Issue callback if user registered it. */
-			if (fp->link_update) {
-				fp->link_update(fp->phydev->attached_dev,
-						&fp->status);
-				fixed_phy_update(fp);
-			}
-			return swphy_read_reg(reg_num, &fp->status);
+			struct fixed_phy_status state;
+			int s;
+
+			do {
+				s = read_seqcount_begin(&fp->seqcount);
+				/* Issue callback if user registered it. */
+				if (fp->link_update) {
+					fp->link_update(fp->phydev->attached_dev,
+							&fp->status);
+					fixed_phy_update(fp);
+				}
+				state = fp->status;
+			} while (read_seqcount_retry(&fp->seqcount, s));
+
+			return swphy_read_reg(reg_num, &state);
 		}
 	}
 
@@ -116,6 +126,7 @@ int fixed_phy_update_state(struct phy_device *phydev,
 
 	list_for_each_entry(fp, &fmb->phys, node) {
 		if (fp->addr == phydev->mdio.addr) {
+			write_seqcount_begin(&fp->seqcount);
 #define _UPD(x) if (changed->x) \
 	fp->status.x = status->x
 			_UPD(link);
@@ -125,6 +136,7 @@ int fixed_phy_update_state(struct phy_device *phydev,
 			_UPD(asym_pause);
 #undef _UPD
 			fixed_phy_update(fp);
+			write_seqcount_end(&fp->seqcount);
 			return 0;
 		}
 	}
@@ -149,6 +161,8 @@ int fixed_phy_add(unsigned int irq, int phy_addr,
 	if (!fp)
 		return -ENOMEM;
 
+	seqcount_init(&fp->seqcount);
+
 	if (irq != PHY_POLL)
 		fmb->mii_bus->irq[phy_addr] = irq;
 
-- 
2.1.0
