From: Dan Carpenter <error27@gmail.com>
Subject: [patch -next] stmmac: handle allocation errors in setup functions
Date: Thu, 22 Jul 2010 13:16:48 +0200
Message-ID: <20100722111648.GD17585@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:63064 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759181Ab0GVLRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 07:17:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the allocations fail in either dwmac1000_setup() or dwmac100_setup()
then return NULL.  These are called from stmmac_mac_device_setup().  The 
check for NULL returns in stmmac_mac_device_setup() needed to be moved 
forward a couple lines.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/stmmac/dwmac1000_core.c b/drivers/net/stmmac/dwmac1000_core.c
index 917b4e1..2b2f5c8 100644
--- a/drivers/net/stmmac/dwmac1000_core.c
+++ b/drivers/net/stmmac/dwmac1000_core.c
@@ -220,6 +220,8 @@ struct mac_device_info *dwmac1000_setup(unsigned long ioaddr)
 		((uid & 0x0000ff00) >> 8), (uid & 0x000000ff));
 
 	mac = kzalloc(sizeof(const struct mac_device_info), GFP_KERNEL);
+	if (!mac)
+		return NULL;
 
 	mac->mac = &dwmac1000_ops;
 	mac->dma = &dwmac1000_dma_ops;
diff --git a/drivers/net/stmmac/dwmac100_core.c b/drivers/net/stmmac/dwmac100_core.c
index 6f270a0..2fb165f 100644
--- a/drivers/net/stmmac/dwmac100_core.c
+++ b/drivers/net/stmmac/dwmac100_core.c
@@ -179,6 +179,8 @@ struct mac_device_info *dwmac100_setup(unsigned long ioaddr)
 	struct mac_device_info *mac;
 
 	mac = kzalloc(sizeof(const struct mac_device_info), GFP_KERNEL);
+	if (!mac)
+		return NULL;
 
 	pr_info("\tDWMAC100\n");
 
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index acf0616..0bdd332 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1558,15 +1558,15 @@ static int stmmac_mac_device_setup(struct net_device *dev)
 	else
 		device = dwmac100_setup(ioaddr);
 
+	if (!device)
+		return -ENOMEM;
+
 	if (priv->enh_desc) {
 		device->desc = &enh_desc_ops;
 		pr_info("\tEnhanced descriptor structure\n");
 	} else
 		device->desc = &ndesc_ops;
 
-	if (!device)
-		return -ENOMEM;
-
 	priv->hw = device;
 
 	priv->wolenabled = priv->hw->pmt;	/* PMT supported */
