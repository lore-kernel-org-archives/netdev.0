From: Jiang Wang <Jiang.Wang@riverbed.com>
Subject: Re: [PATCH 1/2] e100: power down PHY if WOL is not
	enabled
Date: Fri, 16 Dec 2011 02:28:03 +0000
Message-ID: <CEE05A0D7856E14880AD5560634EBEA82AA789D1@365EXCH-MBX-P5.nbttech.com>
References: <1323830996-16388-1-git-send-email-Jiang.Wang@riverbed.com>
	<1323894636.2753.2.camel@bwh-desktop>
	<CEE05A0D7856E14880AD5560634EBEA82AA78720@365EXCH-MBX-P5.nbttech.com>
	<1323900468.2753.22.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Francis St. Amant" <Francis.St.Amant@riverbed.com>,
	Panchamukhi <Prasanna.Panchamukhi@riverbed.com>, Carolyn,
	"miles.ito@intel.com" <miles.ito@intel.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	John Ronciak <john.ronciak@intel.com>, Prasanna,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chaitanya Lala <Chaitanya.Lala@riverbed.com>, Peter
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1323900468.2753.22.camel@bwh-desktop>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Modified the patch.

>From 16c145e8c6b9fdaf94dfdc91211faba88359aaab Mon Sep 17 00:00:00 2001
From: Jiang Wang <Jiang.Wang@riverbed.com>
Date: Thu, 15 Dec 2011 17:08:32 -0800
Subject: [PATCH 1/2] e100: power down PHY if WOL is not enabled

Since the interface will not be used after being put down and WOL is disabled,
just power it off.
When bring up the interface, power on the PHY.

Signed-off-by: Jiang Wang <Jiang.Wang@riverbed.com>
---
 drivers/net/ethernet/intel/e100.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index 5a2fdf7..ca994da 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -1449,6 +1449,11 @@ static int e100_phy_init(struct nic *nic)
 		netif_printk(nic, hw, KERN_DEBUG, nic->netdev,
 			     "phy_addr = %d\n", nic->mii.phy_id);
 
+	/* Make sure power to the PHY is enabled */
+	phy_data = mdio_read(nic->netdev, nic->mii.phy_id, MII_BMCR);
+	phy_data &= ~BMCR_PDOWN;
+	mdio_write(nic->netdev, nic->mii.phy_id, MII_BMCR, phy_data);
+
 	/* Get phy ID */
 	id_lo = mdio_read(netdev, nic->mii.phy_id, MII_PHYSID1);
 	id_hi = mdio_read(netdev, nic->mii.phy_id, MII_PHYSID2);
@@ -2261,6 +2266,15 @@ static void e100_down(struct nic *nic)
 	napi_disable(&nic->napi);
 	netif_stop_queue(nic->netdev);
 	e100_hw_reset(nic);
+
+	/* If wake on LAN is not enabled, power down the PHY */
+	if (!(nic->flags & wol_magic)) {
+		uint16_t phy_data;
+		phy_data = mdio_read(nic->netdev, nic->mii.phy_id, MII_BMCR);
+		phy_data |= BMCR_PDOWN;
+		mdio_write(nic->netdev, nic->mii.phy_id, MII_BMCR, phy_data);
+	}
+
 	free_irq(nic->pdev->irq, nic->netdev);
 	del_timer_sync(&nic->watchdog);
 	netif_carrier_off(nic->netdev);
-- 
1.7.1


-------------------------------------
Jiang Wang
Member of Technical Staff
Riverbed Technology
Tel: (408) 522-5109
Email: Jiang.Wang@riverbed.com
www.riverbed.com


-----Original Message-----
From: Ben Hutchings [mailto:bhutchings@solarflare.com] 
Sent: Wednesday, December 14, 2011 2:08 PM
To: Jiang Wang
Cc: Jeff Kirsher; Jesse Brandeburg; Bruce Allan; Carolyn Wyborny; Don Skidmore; Greg Rose; Peter P Waskiewicz Jr; Alex Duyck; John Ronciak; e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Prasanna Panchamukhi; Chaitanya Lala; Francis St. Amant; miles.ito@intel.com
Subject: RE: [PATCH 1/2] e100: power down PHY if WOL is not enabled

On Wed, 2011-12-14 at 21:59 +0000, Jiang Wang wrote:
> Hi Ben,
> 
> Do you mean the WOL is enabled but PHY is powered off somehow? That 
> scenario should never happen. If WOL is enabled, there is no code to 
> power off PHY.
[...]

Initial conditions: interface up, WOL off, PHY on.

1. Bring interface down. PHY is turned off.
2. Turn WOL on.  PHY is still off, but needs to be on.

Ben.

--
Ben Hutchings, Staff Engineer, Solarflare Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

------------------------------------------------------------------------------
Learn Windows Azure Live!  Tuesday, Dec 13, 2011
Microsoft is holding a special Learn Windows Azure training event for 
developers. It will provide a great way to learn Windows Azure and what it 
provides. You can attend the event by watching it streamed LIVE online.  
Learn more at http://p.sf.net/sfu/ms-windowsazure
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
