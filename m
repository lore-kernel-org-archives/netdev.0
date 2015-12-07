From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH RFC 05/26] phy: improve safety of fixed-phy MII register
 reading
Date: Mon, 07 Dec 2015 17:37:37 +0000
Message-ID: <E1a5zjF-00074s-1E@rmk-PC.arm.linux.org.uk>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:60263 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756118AbbLGRhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 12:37:39 -0500
In-Reply-To: <20151207173553.GU8644@n2100.arm.linux.org.uk>
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

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/phy/fixed_phy.c | 28 +++++++++++++++++++++-------
 1 file changed, 21 insertions(+), 7 deletions(-)

diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
index 66555da2ef27..474cc39a5457 100644
--- a/drivers/net/phy/fixed_phy.c
+++ b/drivers/net/phy/fixed_phy.c
@@ -23,6 +23,7 @@
 #include <linux/slab.h>
 #include <linux/of.h>
 #include <linux/gpio.h>
+#include <linux/seqlock.h>
 
 #include "swphy.h"
 
@@ -35,6 +36,7 @@ struct fixed_mdio_bus {
 struct fixed_phy {
 	int addr;
 	struct phy_device *phydev;
+	seqcount_t seqcount;
 	struct fixed_phy_status status;
 	int (*link_update)(struct net_device *, struct fixed_phy_status *);
 	struct list_head node;
@@ -59,13 +61,21 @@ static int fixed_mdio_read(struct mii_bus *bus, int phy_addr, int reg_num)
 
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
 
@@ -117,6 +127,7 @@ int fixed_phy_update_state(struct phy_device *phydev,
 
 	list_for_each_entry(fp, &fmb->phys, node) {
 		if (fp->addr == phydev->addr) {
+			write_seqcount_begin(&fp->seqcount);
 #define _UPD(x) if (changed->x) \
 	fp->status.x = status->x
 			_UPD(link);
@@ -126,6 +137,7 @@ int fixed_phy_update_state(struct phy_device *phydev,
 			_UPD(asym_pause);
 #undef _UPD
 			fixed_phy_update(fp);
+			write_seqcount_end(&fp->seqcount);
 			return 0;
 		}
 	}
@@ -150,6 +162,8 @@ int fixed_phy_add(unsigned int irq, int phy_addr,
 	if (!fp)
 		return -ENOMEM;
 
+	seqcount_init(&fp->seqcount);
+
 	fmb->irqs[phy_addr] = irq;
 
 	fp->addr = phy_addr;
-- 
2.1.0
