From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 2/2] net: dsa: bcm_sf2: Do not rely on kexec_in_progress
Date: Fri, 21 Oct 2016 14:21:56 -0700
Message-ID: <1477084916-26327-3-git-send-email-f.fainelli@gmail.com>
References: <1477084916-26327-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
        ebiederm@xmission.com, kexec@lists.infradead.org,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35133 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935516AbcJUVWH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 17:22:07 -0400
In-Reply-To: <1477084916-26327-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After discussing with Eric, it turns out that, while using
kexec_in_progress is a nice optimization, which prevents us from always
powering on the integrated PHY, let's just turn it on in the shutdown
path.

This removes a dependency on kexec_in_progress which, according to Eric
should not be used by modules

Fixes: 2399d6143f85 ("net: dsa: bcm_sf2: Prevent GPHY shutdown for kexec'd kernels")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 077a24541584..e3ee27ce13dd 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -30,7 +30,6 @@
 #include <linux/etherdevice.h>
 #include <net/switchdev.h>
 #include <linux/platform_data/b53.h>
-#include <linux/kexec.h>
 
 #include "bcm_sf2.h"
 #include "bcm_sf2_regs.h"
@@ -1141,9 +1140,11 @@ static void bcm_sf2_sw_shutdown(struct platform_device *pdev)
 	/* For a kernel about to be kexec'd we want to keep the GPHY on for a
 	 * successful MDIO bus scan to occur. If we did turn off the GPHY
 	 * before (e.g: port_disable), this will also power it back on.
+	 *
+	 * Do not rely on kexec_in_progress, just power the PHY on.
 	 */
 	if (priv->hw_params.num_gphy == 1)
-		bcm_sf2_gphy_enable_set(priv->dev->ds, kexec_in_progress);
+		bcm_sf2_gphy_enable_set(priv->dev->ds, true);
 }
 
 #ifdef CONFIG_PM_SLEEP
-- 
2.7.4
