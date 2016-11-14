From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: stmmac: Fix lack of link transition for fixed PHYs
Date: Sun, 13 Nov 2016 17:50:35 -0800
Message-ID: <20161114015036.6926-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 52f95bbfcf72 ("stmmac: fix adjust link call in case of a switch
is attached") added some logic to avoid polling the fixed PHY and
therefore invoking the adjust_link callback more than once, since this
is a fixed PHY and link events won't be generated.

This works fine the first time, because we start with phydev->irq =
PHY_POLL, so we call adjust_link, then we set phydev->irq =
PHY_IGNORE_INTERRUPT and we stop polling the PHY.

Now, if we called ndo_close(), which calls both phy_stop() and does an
explicit netif_carrier_off(), we end up with a link down. Upon calling
ndo_open() again, despite starting the PHY state machine, we have
PHY_IGNORE_INTERRUPT set, and we generate no link event at all, so the
link is permanently down.

52f95bbfcf72 ("stmmac: fix adjust link call in case of a switch is attached")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Alexandre, Peppe,

The original patch is already a hack, but since this is a bugfix, I took the
same approach that you did here to backport this to -stable kernels.

 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 10909c9c0033..03dbf8e89c4c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -882,6 +882,13 @@ static int stmmac_init_phy(struct net_device *dev)
 		return -ENODEV;
 	}
 
+	/* stmmac_adjust_link will change this to PHY_IGNORE_INTERRUPT to avoid
+	 * subsequent PHY polling, make sure we force a link transition if
+	 * we have a UP/DOWN/UP transition
+	 */
+	if (phydev->is_pseudo_fixed_link)
+		phydev->irq = PHY_POLL;
+
 	pr_debug("stmmac_init_phy:  %s: attached to PHY (UID 0x%x)"
 		 " Link = %d\n", dev->name, phydev->phy_id, phydev->link);
 
-- 
2.9.3
