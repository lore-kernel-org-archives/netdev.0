From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH] Net / e100: Fix suspend of devices that
	cannot be power managed
Date: Sun, 14 Jun 2009 21:46:46 +0200
Message-ID: <200906142146.47639.rjw@sisk.pl>
References: <20081229102515.GA17171@rhlx01.hs-esslingen.de>
	<200906141606.29754.rjw@sisk.pl>
	<20090614164604.GA19746@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org, andi@lisas.de
To: "Jeffrey Kirsher" <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20090614164604.GA19746@rhlx01.hs-esslingen.de>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Rafael J. Wysocki <rjw@sisk.pl>

If the adapter is not power-manageable using either ACPI, or the
native PCI PM interface, __e100_power_off() returns error code, which
causes every attempt to suspend to fail, although it should return 0
in such a case.  Fix this problem by ignoring the return value of
pci_set_power_state() in __e100_power_off().

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
Acked-by: Andreas Mohr <andi@lisas.de>
---
 drivers/net/e100.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

Index: linux-2.6/drivers/net/e100.c
===================================================================
--- linux-2.6.orig/drivers/net/e100.c
+++ linux-2.6/drivers/net/e100.c
@@ -2759,12 +2759,13 @@ static void __e100_shutdown(struct pci_d
 
 static int __e100_power_off(struct pci_dev *pdev, bool wake)
 {
-	if (wake) {
+	if (wake)
 		return pci_prepare_to_sleep(pdev);
-	} else {
-		pci_wake_from_d3(pdev, false);
-		return pci_set_power_state(pdev, PCI_D3hot);
-	}
+
+	pci_wake_from_d3(pdev, false);
+	pci_set_power_state(pdev, PCI_D3hot);
+
+	return 0;
 }
 
 #ifdef CONFIG_PM

------------------------------------------------------------------------------
Crystal Reports - New Free Runtime and 30 Day Trial
Check out the new simplified licensing option that enables unlimited
royalty-free distribution of the report engine for externally facing 
server and web deployment.
http://p.sf.net/sfu/businessobjects
