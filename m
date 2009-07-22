From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] igb/e1000e/e1000/e100: make wol usable
Date: Tue, 21 Jul 2009 22:27:46 -0400
Message-ID: <20090722022745.GM8515@gospo.rdu.redhat.com>
References: <20090721210115.GL8515@gospo.rdu.redhat.com> <273D38FBE7C6FE46A1689FCD014A0B8B55D57764@azsmsx505.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"stable@kernel.org" <stable@kernel.org>
To: "Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:59914 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750804AbZGVC2w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2009 22:28:52 -0400
Content-Disposition: inline
In-Reply-To: <273D38FBE7C6FE46A1689FCD014A0B8B55D57764@azsmsx505.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 21, 2009 at 02:59:31PM -0700, Ronciak, John wrote:
> >-----Original Message-----
> >From: Andy Gospodarek [mailto:andy@greyhouse.net] 
> >Sent: Tuesday, July 21, 2009 2:01 PM
> >To: netdev@vger.kernel.org
> >Cc: Kirsher, Jeffrey T; Brandeburg, Jesse; Allan, Bruce W; 
> >Waskiewicz Jr, Peter P; Ronciak, John; stable@kernel.org
> >Subject: [PATCH] igb/e1000e/e1000/e100: make wol usable
> >
> >
> >It seems that the patches that intended to use the new calls to check
> >status and capabilities for WOL and fix it up:
> >
> >    commit bc79fc8409b3dccbde072e8113cc1fb3fd876fc5
> >    Author: Rafael J. Wysocki <rjw@sisk.pl>
> >    Date:   Wed Oct 29 14:22:18 2008 -0700
> >
> >        e100: adapt to the reworked PCI PM
> >
> >    commit e1b86d8479f90aadee57a3d07d8e61c815c202d9
> >    Author: Rafael J. Wysocki <rjw@sisk.pl>
> >    Date:   Fri Nov 7 20:30:37 2008 +0000
> >
> >        igb: Use device_set_wakeup_enable
> >
> >    commit de1264896c8012a261c1cba17e6a61199c276ad3
> >    Author: Rafael J. Wysocki <rjw@sisk.pl>
> >    Date:   Fri Nov 7 20:30:19 2008 +0000
> >
> >        e1000: Use device_set_wakeup_enable
> >
> >    commit 6ff68026f4757d68461b7fbeca5c944e1f5f8b44
> >    Author: Rafael J. Wysocki <rjw@sisk.pl>
> >    Date:   Wed Nov 12 09:52:32 2008 +0000
> >
> >        e1000e: Use device_set_wakeup_enable
> >
> >Unfortunately they left out some important bits.  This should make sure
> >the e100, igb, e1000e, and e1000-based devices can actually enable WOL
> >rather than their current state which is reported as not supported.
> >
> >This looks like it has been broken since 2.6.28.
> >
> >Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> >---
> >
> > e100.c             |    1 +
> > e1000/e1000_main.c |    1 +
> > e1000e/netdev.c    |    1 +
> > igb/igb_main.c     |    1 +
> > 4 files changed, 4 insertions(+)
> >
> >diff --git a/drivers/net/e100.c b/drivers/net/e100.c
> >index 569df19..8824952 100644
> >--- a/drivers/net/e100.c
> >+++ b/drivers/net/e100.c
> >@@ -2816,6 +2816,7 @@ static int __devinit e100_probe(struct 
> >pci_dev *pdev,
> > 	if ((nic->mac >= mac_82558_D101_A4) &&
> > 	   (nic->eeprom[eeprom_id] & eeprom_id_wol)) {
> > 		nic->flags |= wol_magic;
> >+		device_init_wakeup(&pdev->dev, true);
> > 		device_set_wakeup_enable(&pdev->dev, true);
> > 	}
> > 
> >diff --git a/drivers/net/e1000/e1000_main.c 
> >b/drivers/net/e1000/e1000_main.c
> >index d7df00c..229d874 100644
> >--- a/drivers/net/e1000/e1000_main.c
> >+++ b/drivers/net/e1000/e1000_main.c
> >@@ -1208,6 +1208,7 @@ static int __devinit e1000_probe(struct 
> >pci_dev *pdev,
> > 
> > 	/* initialize the wol settings based on the eeprom settings */
> > 	adapter->wol = adapter->eeprom_wol;
> >+	device_init_wakeup(&adapter->pdev->dev, adapter->wol);
> > 	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
> > 
> > 	/* print bus type/speed/width info */
> >diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
> >index 63415bb..5c2edaa 100644
> >--- a/drivers/net/e1000e/netdev.c
> >+++ b/drivers/net/e1000e/netdev.c
> >@@ -5196,6 +5196,7 @@ static int __devinit e1000_probe(struct 
> >pci_dev *pdev,
> > 
> > 	/* initialize the wol settings based on the eeprom settings */
> > 	adapter->wol = adapter->eeprom_wol;
> >+	device_init_wakeup(&adapter->pdev->dev, adapter->wol);
> > 	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
> > 
> > 	/* save off EEPROM version number */
> >diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
> >index adb09d3..8512a40 100644
> >--- a/drivers/net/igb/igb_main.c
> >+++ b/drivers/net/igb/igb_main.c
> >@@ -1475,6 +1475,7 @@ static int __devinit igb_probe(struct 
> >pci_dev *pdev,
> > 
> > 	/* initialize the wol settings based on the eeprom settings */
> > 	adapter->wol = adapter->eeprom_wol;
> >+	device_init_wakeup(&adapter->pdev->dev, adapter->wol);
> > 	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
> > 
> > 	/* reset the hardware with the new settings */
> Andy,
> 
> WoL not supported is reported back when WoL is disabled in the EEPROM.  So if this is happening to you, that system (or at least  that interface) has WoL disabled.  How are you testing this?
> 
> Cheers,
> John

John,

I'm not doing anything differently than what the eeprom is reporting as
support with these patches. In every one of the drivers above, the
enabling of ethtool first calls device_can_wakeup.  That inline function
is pretty simple and all it does is return the value of
dev->power.can_wakeup.  If never set, dev->power.can_wakeup is false and
wol status can never be set.

The proper way to set it would be to call dev_init_wakeup first (or
simply call it).  Take a look at the code and you will see what I'm
talking about.

Now that I'm looking at it again, this patch would probably be better
anyway:

Replace device_set_wakeup_enable calls with device_init_wakeup, so that
calls to device_can_wakeup in each drivers' code will not fail each
time.  The intent of the calls to device_can_wakeup were added to ensure
the device was enabled for WOL, but without the proper call to
device_init_wakeup, any call to device_can_wakeup will always return
false.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---

 e100.c             |    2 +-
 e1000/e1000_main.c |    2 +-
 e1000e/netdev.c    |    2 +-
 igb/igb_main.c     |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 569df19..1d82d25 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2816,7 +2816,7 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 	if ((nic->mac >= mac_82558_D101_A4) &&
 	   (nic->eeprom[eeprom_id] & eeprom_id_wol)) {
 		nic->flags |= wol_magic;
-		device_set_wakeup_enable(&pdev->dev, true);
+		device_init_wakeup(&pdev->dev, true);
 	}
 
 	/* ack any pending wake events, disable PME */
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index d7df00c..5f22a85 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1208,7 +1208,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	/* initialize the wol settings based on the eeprom settings */
 	adapter->wol = adapter->eeprom_wol;
-	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
+	device_init_wakeup(&adapter->pdev->dev, adapter->wol);
 
 	/* print bus type/speed/width info */
 	DPRINTK(PROBE, INFO, "(PCI%s:%s:%s) ",
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 63415bb..62de3ad 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -5196,7 +5196,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	/* initialize the wol settings based on the eeprom settings */
 	adapter->wol = adapter->eeprom_wol;
-	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
+	device_init_wakeup(&adapter->pdev->dev, adapter->wol);
 
 	/* save off EEPROM version number */
 	e1000_read_nvm(&adapter->hw, 5, 1, &adapter->eeprom_vers);
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index adb09d3..f761e67 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1475,7 +1475,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 
 	/* initialize the wol settings based on the eeprom settings */
 	adapter->wol = adapter->eeprom_wol;
-	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
+	device_init_wakeup(&adapter->pdev->dev, adapter->wol);
 
 	/* reset the hardware with the new settings */
 	igb_reset(adapter);




 

