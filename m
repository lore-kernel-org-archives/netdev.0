From: Stas Sergeev <stsp@list.ru>
Subject: [PATCH 1/6] restructure of_phy_register_fixed_link() for further
 modifications
Date: Thu, 26 Mar 2015 18:58:41 +0300
Message-ID: <55142CB1.1080107@list.ru>
References: <55142C31.5050504@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Rami Rosen <rosenr@marvell.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback5.mail.ru ([94.100.181.253]:33677 "EHLO
	fallback5.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212AbbCZQKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 12:10:30 -0400
Received: from smtp13.mail.ru (smtp13.mail.ru [94.100.181.94])
	by fallback5.mail.ru (mPOP.Fallback_MX) with ESMTP id E6C827C83DC6
	for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 18:58:52 +0300 (MSK)
In-Reply-To: <55142C31.5050504@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-=-=-=-=-=-=-=-=-=# Don't remove this line #=-=-=-=-=-=-=-=-=-
Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>
---
 drivers/of/of_mdio.c |   32 ++++++++++++++++++--------------
 1 file changed, 18 insertions(+), 14 deletions(-)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 1bd4305..b3dc1e6 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -301,22 +301,26 @@ int of_phy_register_fixed_link(struct device_node *np)
                               "asym-pause");
         of_node_put(fixed_link_node);
         phy = fixed_phy_register(PHY_POLL, &status, np);
-        return IS_ERR(phy) ? PTR_ERR(phy) : 0;
-    }
-
-    /* Old binding */
-    fixed_link_prop = of_get_property(np, "fixed-link", &len);
-    if (fixed_link_prop && len == (5 * sizeof(__be32))) {
-        status.link = 1;
-        status.duplex = be32_to_cpu(fixed_link_prop[1]);
-        status.speed = be32_to_cpu(fixed_link_prop[2]);
-        status.pause = be32_to_cpu(fixed_link_prop[3]);
-        status.asym_pause = be32_to_cpu(fixed_link_prop[4]);
-        phy = fixed_phy_register(PHY_POLL, &status, np);
-        return IS_ERR(phy) ? PTR_ERR(phy) : 0;
+        if (IS_ERR(phy))
+            return PTR_ERR(phy);
+    } else {
+        /* Old binding */
+        fixed_link_prop = of_get_property(np, "fixed-link", &len);
+        if (fixed_link_prop && len == (5 * sizeof(__be32))) {
+            status.link = 1;
+            status.duplex = be32_to_cpu(fixed_link_prop[1]);
+            status.speed = be32_to_cpu(fixed_link_prop[2]);
+            status.pause = be32_to_cpu(fixed_link_prop[3]);
+            status.asym_pause = be32_to_cpu(fixed_link_prop[4]);
+            phy = fixed_phy_register(PHY_POLL, &status, np);
+            if (IS_ERR(phy))
+                return PTR_ERR(phy);
+        } else {
+            return -ENODEV;
+        }
     }
 
-    return -ENODEV;
+    return 0;
 }
 EXPORT_SYMBOL(of_phy_register_fixed_link);
 #endif
-- 
1.7.9.5
