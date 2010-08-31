From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build warnings after merge of the net tree
Date: Mon, 30 Aug 2010 21:56:41 -0700 (PDT)
Message-ID: <20100830.215641.71568585.davem@davemloft.net>
References: <20100831115508.078eb2fa.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, peppe.cavallaro@st.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100831115508.078eb2fa.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 31 Aug 2010 11:55:08 +1000

> Hi all,
> 
> After merging the net tree, today's linux-next build (x86_64
> allmodconfig) produced these warnings:
> 
> In file included from drivers/net/stmmac/stmmac_ethtool.c:30:
> drivers/net/stmmac/stmmac.h:111: warning: 'struct platform_device' declared inside parameter list
> drivers/net/stmmac/stmmac.h:111: warning: its scope is only this definition or declaration, which is probably not what you want
 ...

I've checked the following into net-next-2.6 to combat-this (see,
proactively fixing warnings in code I'm more or less responsible for
instead of letting the issue rot for 2 months :-):

--------------------
stmmac: Fix build warnings.

In file included from drivers/net/stmmac/stmmac_ethtool.c:30:
drivers/net/stmmac/stmmac.h:111: warning: 'struct platform_device' declared inside parameter list
drivers/net/stmmac/stmmac.h:111: warning: its scope is only this definition or declaration, which is probably not what you want
drivers/net/stmmac/stmmac_main.c: In function 'stmmac_dvr_probe':
drivers/net/stmmac/stmmac_main.c:1744: warning: cast from pointer to integer of different size
In file included from drivers/net/stmmac/stmmac_mdio.c:31:
drivers/net/stmmac/stmmac.h:111: warning: 'struct platform_device' declared inside parameter list
drivers/net/stmmac/stmmac.h:111: warning: its scope is only this definition or declaration, which is probably not what you want
drivers/net/stmmac/dwmac1000_core.c: In function 'dwmac1000_dump_regs':
drivers/net/stmmac/dwmac1000_core.c:56: warning: cast from pointer to integer of different size

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/stmmac/dwmac1000_core.c |    2 +-
 drivers/net/stmmac/stmmac.h         |    1 +
 drivers/net/stmmac/stmmac_main.c    |    4 ++--
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/stmmac/dwmac1000_core.c b/drivers/net/stmmac/dwmac1000_core.c
index 8bbfc0f..f1f4261 100644
--- a/drivers/net/stmmac/dwmac1000_core.c
+++ b/drivers/net/stmmac/dwmac1000_core.c
@@ -53,7 +53,7 @@ static void dwmac1000_core_init(void __iomem *ioaddr)
 static void dwmac1000_dump_regs(void __iomem *ioaddr)
 {
 	int i;
-	pr_info("\tDWMAC1000 regs (base addr = 0x%8x)\n", (unsigned int)ioaddr);
+	pr_info("\tDWMAC1000 regs (base addr = 0x%p)\n", ioaddr);
 
 	for (i = 0; i < 55; i++) {
 		int offset = i * 4;
diff --git a/drivers/net/stmmac/stmmac.h b/drivers/net/stmmac/stmmac.h
index cca53db..d0ddab0 100644
--- a/drivers/net/stmmac/stmmac.h
+++ b/drivers/net/stmmac/stmmac.h
@@ -21,6 +21,7 @@
 *******************************************************************************/
 
 #define DRV_MODULE_VERSION	"Apr_2010"
+#include <linux/platform_device.h>
 #include <linux/stmmac.h>
 
 #include "common.h"
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index c59c106..e3f002e 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1742,8 +1742,8 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 	priv->bsp_priv = plat_dat->bsp_priv;
 
 	pr_info("\t%s - (dev. name: %s - id: %d, IRQ #%d\n"
-	       "\tIO base addr: 0x%08x)\n", ndev->name, pdev->name,
-	       pdev->id, ndev->irq, (unsigned int)addr);
+	       "\tIO base addr: 0x%p)\n", ndev->name, pdev->name,
+	       pdev->id, ndev->irq, addr);
 
 	/* MDIO bus Registration */
 	pr_debug("\tMDIO bus (id: %d)...", priv->bus_id);
-- 
1.7.2.2
