From: Andreas Mohr <andim2@users.sourceforge.net>
Subject: [PATCH] Make e100 suspend handler support PCI cards
	lacking PM	capability
Date: Sat, 13 Jun 2009 21:19:31 +0200
Message-ID: <20090613191931.GA31019@rhlx01.hs-esslingen.de>
References: <20081229102515.GA17171@rhlx01.hs-esslingen.de>
	<20081229091728.d869f1c1.akpm@linux-foundation.org>
	<9929d2390812291515y623d6a51yed1bef021ab6847e@mail.gmail.com>
	<20081230120756.GA5393@rhlx01.hs-esslingen.de>
	<20090228203757.GA18850@rhlx01.hs-esslingen.de>
	<9929d2390903010257p7c6fb367ga974767605033bc9@mail.gmail.com>
	<20090301212412.GA13210@rhlx01.hs-esslingen.de>
	<20090602214852.GA3095@rhlx01.hs-esslingen.de>
	<20090603060123.GA17558@rhlx01.hs-esslingen.de>
	<20090603063025.GA32600@rhlx01.hs-esslingen.de>
Reply-To: andi@lisas.de
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org
To: andi@lisas.de
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20090603063025.GA32600@rhlx01.hs-esslingen.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi all,

after having added non-MII PHY card support to e100, I noticed that
the suspend handler rejects power-management non-capable PCI cards,
causing a S2R request to immediately get back up to the desktop,
losing network access in the process (rtnl mutex deadlock).

ChangeLog:
Support PCI cards which are lacking power management capability
in the e100 suspend handler.


Frankly I was unsure how to best add this to the driver in a clean way.
Usually drivers use pci_set_power_state(..., pci_choose_state(...))
in order to avoid the rejection of an open-coded
pci_set_power_state(..., PCI_D3hot) in case of a non-PM card,
however pci_choose_state() depends on the _pm-internal_ pm_message_t type,
which was doable in .suspend directly but not at the other e100
driver locations where it was used.

Next attempt was to extend __e100_power_off() with a pci_power_t parameter,
however since __e100_power_off() is called by two locations,
that meant that I'd have to use pci_choose_state() at _both_ call sites.

Thus I simply resorted to do a brute-force yet most simple
pci_find_capability() check in the __e100_power_off() function.


Tested on 2.6.30-rc8 and suspending/resuming fine, checkpatch.pl:ed.
Patch against 2.6.30-rc8 with my original non-MII support patch applied.
(should apply fine in any case, I'd think).
Intended for testing in -mmotm or so.

Thanks!

Signed-off-by: Andreas Mohr <andi@lisas.de>


--- linux-2.6.30-rc8.e100/drivers/net/e100.c.my_patch_orig	2009-06-13 18:47:53.000000000 +0200
+++ linux-2.6.30-rc8.e100/drivers/net/e100.c	2009-06-13 20:27:46.000000000 +0200
@@ -2897,6 +2897,13 @@ static void __e100_shutdown(struct pci_d
 
 static int __e100_power_off(struct pci_dev *pdev, bool wake)
 {
+	/* some older devices don't support PCI PM
+	 * (e.g. mac_82557_D100_B combo card with 80c24 PHY)
+	 * - skip those! (they most likely won't support WoL either)
+	 */
+	if (!pci_find_capability(pdev, PCI_CAP_ID_PM))
+		return 0;
+
 	if (wake) {
 		return pci_prepare_to_sleep(pdev);
 	} else {

------------------------------------------------------------------------------
Crystal Reports - New Free Runtime and 30 Day Trial
Check out the new simplified licensing option that enables unlimited
royalty-free distribution of the report engine for externally facing 
server and web deployment.
http://p.sf.net/sfu/businessobjects
