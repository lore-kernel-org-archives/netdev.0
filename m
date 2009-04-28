From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] fs_enet: Remove dead code
Date: Tue, 28 Apr 2009 02:06:39 -0700 (PDT)
Message-ID: <20090428.020639.161031049.davem@davemloft.net>
References: <1240436148-5456-1-git-send-email-galak@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: galak@kernel.crashing.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <1240436148-5456-1-git-send-email-galak@kernel.crashing.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

From: Kumar Gala <galak@kernel.crashing.org>
Date: Wed, 22 Apr 2009 16:35:48 -0500

> CONFIG_DUET doesn't exist anymore, remove all the code that exists to
> support it.
> 
> Signed-off-by: Kumar Gala <galak@kernel.crashing.org>

I took the liberty of simplifying fs_init() even further
when applying this.  It had become:

	int r = foo();
	if (r != 0)
		return r;
	return 0;

which is just plain:

	return foo();

fs_enet: Remove dead code

CONFIG_DUET doesn't exist anymore, remove all the code that exists to
support it.

[ Simplify fs_init() even further -DaveM ]

Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/fs_enet/fs_enet-main.c |   39 +-----------------------------------
 drivers/net/fs_enet/fs_enet.h      |    5 ----
 drivers/net/fs_enet/mac-fec.c      |   34 -------------------------------
 3 files changed, 1 insertions(+), 77 deletions(-)

diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index 9604aae..b892c3a 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -941,30 +941,6 @@ extern void fs_mii_disconnect(struct net_device *dev);
 
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
 #ifdef CONFIG_FS_ENET_HAS_FEC
 #define IS_FEC(match) ((match)->data == &fs_fec_ops)
 #else
@@ -1144,25 +1120,12 @@ static struct of_platform_driver fs_enet_driver = {
 
 static int __init fs_init(void)
 {
-	int r = setup_immap();
-	if (r != 0)
-		return r;
-
-	r = of_register_platform_driver(&fs_enet_driver);
-	if (r != 0)
-		goto out;
-
-	return 0;
-
-out:
-	cleanup_immap();
-	return r;
+	return of_register_platform_driver(&fs_enet_driver);
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
index 14e5753..ca7bcb8 100644
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
@@ -315,36 +311,6 @@ static void restart(struct net_device *dev)
 	FW(fecp, ievent, 0xffc0);
 	FW(fecp, ivec, (virq_to_hw(fep->interrupt) / 2) << 29);
 
-	/*
-	 * adjust to speed (only for DUET & RMII)
-	 */
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
-
 	FW(fecp, r_cntrl, FEC_RCNTRL_MII_MODE);	/* MII enable */
 	/*
 	 * adjust to duplex mode
-- 
1.6.2.4
