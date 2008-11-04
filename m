From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH 3/3] igb: Use device_set_wakeup_enable
Date: Tue, 4 Nov 2008 17:44:20 +0100
Message-ID: <200811041744.21236.rjw@sisk.pl>
References: <bug-11865-10286@http.bugzilla.kernel.org/>
	<200811040243.33386.rjw@sisk.pl> <200811041740.50426.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "jeff@garzik.org" <jeff@garzik.org>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"rogerx@sdf.lonestar.org" <rogerx@sdf.lonestar.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <200811041740.50426.rjw@sisk.pl>
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

Author: Rafael J. Wysocki <rjw@sisk.pl>
Subject: igb: Use device_set_wakeup_enable
 
Since dev->power.should_wakeup bit is used by the PCI core to
decide whether the device should wake up the system from sleep
states, set/unset this bit whenever WOL is enabled/disabled using
igb_set_wol().  Accordingly, use device_can_wakeup() for checking
if wake-up is supported by the device.

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 drivers/net/igb/igb_ethtool.c |    8 ++++++--
 drivers/net/igb/igb_main.c    |    1 +
 2 files changed, 7 insertions(+), 2 deletions(-)

Index: linux-2.6/drivers/net/igb/igb_ethtool.c
===================================================================
--- linux-2.6.orig/drivers/net/igb/igb_ethtool.c
+++ linux-2.6/drivers/net/igb/igb_ethtool.c
@@ -1776,7 +1776,8 @@ static void igb_get_wol(struct net_devic
 
 	/* this function will set ->supported = 0 and return 1 if wol is not
 	 * supported by this hardware */
-	if (igb_wol_exclusion(adapter, wol))
+	if (igb_wol_exclusion(adapter, wol) ||
+	    !device_can_wakeup(&adapter->pdev->dev))
 		return;
 
 	/* apply any specific unsupported masks here */
@@ -1805,7 +1806,8 @@ static int igb_set_wol(struct net_device
 	if (wol->wolopts & (WAKE_PHY | WAKE_ARP | WAKE_MAGICSECURE))
 		return -EOPNOTSUPP;
 
-	if (igb_wol_exclusion(adapter, wol))
+	if (igb_wol_exclusion(adapter, wol) ||
+	    !device_can_wakeup(&adapter->pdev->dev))
 		return wol->wolopts ? -EOPNOTSUPP : 0;
 
 	switch (hw->device_id) {
@@ -1825,6 +1827,8 @@ static int igb_set_wol(struct net_device
 	if (wol->wolopts & WAKE_MAGIC)
 		adapter->wol |= E1000_WUFC_MAG;
 
+	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
+
 	return 0;
 }
 
Index: linux-2.6/drivers/net/igb/igb_main.c
===================================================================
--- linux-2.6.orig/drivers/net/igb/igb_main.c
+++ linux-2.6/drivers/net/igb/igb_main.c
@@ -1244,6 +1244,7 @@ static int __devinit igb_probe(struct pc
 
 	/* initialize the wol settings based on the eeprom settings */
 	adapter->wol = adapter->eeprom_wol;
+	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
 
 	/* reset the hardware with the new settings */
 	igb_reset(adapter);

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
