From: Kumar Gala <galak@kernel.crashing.org>
Subject: [PATCH] fs_enet: Remove dead code
Date: Wed, 22 Apr 2009 16:19:30 -0500
Message-ID: <1240435170-5183-1-git-send-email-galak@kernel.crashing.org>
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:43645 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751932AbZDVVTj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Apr 2009 17:19:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_DUET doesn't exist anymore, remove all the code that exists to
support it.

Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
---
 drivers/net/fs_enet/fs_enet-main.c |   35 +----------------------------------
 drivers/net/fs_enet/fs_enet.h      |    5 -----
 drivers/net/fs_enet/mac-fec.c      |   30 ------------------------------
 3 files changed, 1 insertions(+), 69 deletions(-)

diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index a9cbc31..76cd206 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -938,30 +938,6 @@ extern void fs_mii_disconnect(struct net_device *dev);
 
 /**************************************************************************************/
 
-/* handy pointer to the immap */
-void __iomem *fs_enet_immap = NULL;
-
-static int setup_immap(void)
-{
-#ifdef CONFIG_CPM1
-	fs_enet_immap = ioremap(IMAP_ADDR, 0x4000);
-	WARN_ON(!fs_enet_immap);
-#elif defined(CONFIG_CPM2)
-	fs_enet_immap = cpm2_immr;
-#endif
-
-	return 0;
-}
-
-static void cleanup_immap(void)
-{
-#if defined(CONFIG_CPM1)
-	iounmap(fs_enet_immap);
-#endif
-}
-
-/**************************************************************************************/
-
 static int __devinit find_phy(struct device_node *np,
                               struct fs_platform_info *fpi)
 {
@@ -1191,25 +1167,16 @@ static struct of_platform_driver fs_enet_driver = {
 
 static int __init fs_init(void)
 {
-	int r = setup_immap();
+	int r = of_register_platform_driver(&fs_enet_driver);
 	if (r != 0)
 		return r;
 
-	r = of_register_platform_driver(&fs_enet_driver);
-	if (r != 0)
-		goto out;
-
 	return 0;
-
-out:
-	cleanup_immap();
-	return r;
 }
 
 static void __exit fs_cleanup(void)
 {
 	of_unregister_platform_driver(&fs_enet_driver);
-	cleanup_immap();
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/fs_enet/fs_enet.h b/drivers/net/fs_enet/fs_enet.h
index 85a4bab..ef01e09 100644
--- a/drivers/net/fs_enet/fs_enet.h
+++ b/drivers/net/fs_enet/fs_enet.h
@@ -194,9 +194,4 @@ extern const struct fs_ops fs_scc_ops;
 
 /*******************************************************************/
 
-/* handy pointer to the immap */
-extern void __iomem *fs_enet_immap;
-
-/*******************************************************************/
-
 #endif
diff --git a/drivers/net/fs_enet/mac-fec.c b/drivers/net/fs_enet/mac-fec.c
index 14e5753..7abe1fd 100644
--- a/drivers/net/fs_enet/mac-fec.c
+++ b/drivers/net/fs_enet/mac-fec.c
@@ -245,10 +245,6 @@ static void set_multicast_list(struct net_device *dev)
 
 static void restart(struct net_device *dev)
 {
-#ifdef CONFIG_DUET
-	immap_t *immap = fs_enet_immap;
-	u32 cptr;
-#endif
 	struct fs_enet_private *fep = netdev_priv(dev);
 	fec_t __iomem *fecp = fep->fec.fecp;
 	const struct fs_platform_info *fpi = fep->fpi;
@@ -318,32 +314,6 @@ static void restart(struct net_device *dev)
 	/*
 	 * adjust to speed (only for DUET & RMII)
 	 */
-#ifdef CONFIG_DUET
-	if (fpi->use_rmii) {
-		cptr = in_be32(&immap->im_cpm.cp_cptr);
-		switch (fs_get_fec_index(fpi->fs_no)) {
-		case 0:
-			cptr |= 0x100;
-			if (fep->speed == 10)
-				cptr |= 0x0000010;
-			else if (fep->speed == 100)
-				cptr &= ~0x0000010;
-			break;
-		case 1:
-			cptr |= 0x80;
-			if (fep->speed == 10)
-				cptr |= 0x0000008;
-			else if (fep->speed == 100)
-				cptr &= ~0x0000008;
-			break;
-		default:
-			BUG();	/* should never happen */
-			break;
-		}
-		out_be32(&immap->im_cpm.cp_cptr, cptr);
-	}
-#endif
-
 
 	FW(fecp, r_cntrl, FEC_RCNTRL_MII_MODE);	/* MII enable */
 	/*
-- 
1.6.0.6

