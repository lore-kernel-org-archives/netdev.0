From: Niklas Cassel <niklas.cassel@axis.com>
Subject: [PATCH] net: stmmac: do not call phy_ethtool_ksettings_set from atomic context
Date: Tue, 6 Dec 2016 14:47:15 +0100
Message-ID: <1481032035-19018-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Niklas Cassel <niklass@axis.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bes.se.axis.com ([195.60.68.10]:48616 "EHLO bes.se.axis.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751668AbcLFNrc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Dec 2016 08:47:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Niklas Cassel <niklas.cassel@axis.com>

>From what I can tell, spin_lock(&priv->lock) is not needed, since the
phy_ethtool_ksettings_set call is not given the priv struct.

phy_start_aneg takes the phydev->lock. Calls to phy_adjust_link
from phy_state_machine also takes the phydev->lock.

[   13.718319] BUG: sleeping function called from invalid context at kernel/locking/mutex.c:97
[   13.726717] in_atomic(): 1, irqs_disabled(): 0, pid: 1307, name: ethtool
[   13.742115] Hardware name: Axis ARTPEC-6 Platform
[   13.746829] [<80110568>] (unwind_backtrace) from [<8010c2bc>] (show_stack+0x18/0x1c)
[   13.754575] [<8010c2bc>] (show_stack) from [<80433484>] (dump_stack+0x80/0xa0)
[   13.761801] [<80433484>] (dump_stack) from [<80145428>] (___might_sleep+0x108/0x170)
[   13.769554] [<80145428>] (___might_sleep) from [<806c9b50>] (mutex_lock+0x24/0x44)
[   13.777128] [<806c9b50>] (mutex_lock) from [<8050cbc0>] (phy_start_aneg+0x1c/0x13c)
[   13.784783] [<8050cbc0>] (phy_start_aneg) from [<8050d338>] (phy_ethtool_ksettings_set+0x98/0xd0)
[   13.793656] [<8050d338>] (phy_ethtool_ksettings_set) from [<80517adc>] (stmmac_ethtool_set_link_ksettings+0xa0/0xb4)
[   13.804184] [<80517adc>] (stmmac_ethtool_set_link_ksettings) from [<805c5138>] (ethtool_set_settings+0xd4/0x13c)
[   13.814358] [<805c5138>] (ethtool_set_settings) from [<805c9718>] (dev_ethtool+0x13c4/0x211c)
[   13.822882] [<805c9718>] (dev_ethtool) from [<805dc7c0>] (dev_ioctl+0x480/0x8e0)
[   13.830291] [<805dc7c0>] (dev_ioctl) from [<80260e34>] (do_vfs_ioctl+0x94/0xa00)
[   13.837699] [<80260e34>] (do_vfs_ioctl) from [<802617dc>] (SyS_ioctl+0x3c/0x60)
[   13.845011] [<802617dc>] (SyS_ioctl) from [<801088bc>] (__sys_trace_return+0x0/0x10)

Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index d5a8122b6033..6ab7e2bdcadd 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -406,9 +406,7 @@ stmmac_ethtool_set_link_ksettings(struct net_device *dev,
 		return 0;
 	}
 
-	spin_lock(&priv->lock);
 	rc = phy_ethtool_ksettings_set(phy, cmd);
-	spin_unlock(&priv->lock);
 
 	return rc;
 }
-- 
2.1.4
