From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: Regression in 2.6.27-rc7: Wake On LAN with sky2 broken
Date: Thu, 25 Sep 2008 22:38:01 +0200
Message-ID: <200809252238.01656.rjw@sisk.pl>
References: <20080924080546.GA21108@x61> <20080925194253.GA2783@dose.home.local> <20080925200311.GA4582@dose.home.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tino Keitel <tino.keitel@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:56314 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755947AbYIYUc3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2008 16:32:29 -0400
In-Reply-To: <20080925200311.GA4582@dose.home.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, 25 of September 2008, Tino Keitel wrote:
> Hi,
> 
> I just found a method how I can enable WOL again:
> 
> echo enabled >
> /sys/devices/pci0000:00/0000:00:1c.0/0000:01:00.0/power/wakeup
> 
> This device is the NIC device, of cause.

I guess the box didn't hang during suspend with this setting?

If that's correct, please test the patch below.

> I already had another case (EHCI) where I needed to do this to be able
> to wake the computer up with the USB keyboard. It seems like 2.6.27
> behaves different here compared to 2.6.26, and things that worked with
> 2.6.26 need manual fixing to work again. Or did I make something wrong?

No, you didn't.

The behavior was changed by the PCI wake-up patches that fixed a couple of
problems and I'd like to fix all of the cases when the new behavior causes
issues like this to happen.

I'll send you a patch for the EHCI case later today.

Thanks,
Rafael

---
sky2: Fix WOL regression

Since dev->power.should_wakeup bit is used by the PCI core to
decide whether the device should wake up the system from sleep
states, set/unset this bit whenever WOL is enabled/disabled using
sky2_set_wol().

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---

 drivers/net/sky2.c |   34 ++++++++++------------------------
 1 file changed, 10 insertions(+), 24 deletions(-)

diff -puN drivers/net/sky2.c~skty2-adapt-to-the-reworked-pci-pm drivers/net/sky2.c
--- a/drivers/net/sky2.c~skty2-adapt-to-the-reworked-pci-pm
+++ a/drivers/net/sky2.c
@@ -3034,7 +3034,8 @@ static int sky2_set_wol(struct net_devic
 	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
 
-	if (wol->wolopts & ~sky2_wol_supported(sky2->hw))
+	if ((wol->wolopts & ~sky2_wol_supported(sky2->hw))
+	    || !device_can_wakeup(&hw->pdev->dev))
 		return -EOPNOTSUPP;
 
 	sky2->wol = wol->wolopts;
@@ -3045,6 +3046,8 @@ static int sky2_set_wol(struct net_devic
 		sky2_write32(hw, B0_CTST, sky2->wol
 			     ? Y2_HW_WOL_ON : Y2_HW_WOL_OFF);
 
+	device_set_wakeup_enable(&hw->pdev->dev, sky2->wol);
+
 	if (!netif_running(dev))
 		sky2_wol_init(sky2);
 	return 0;
@@ -4314,7 +4305,7 @@ static int __devinit sky2_probe(struct p
 		}
 	}
 
-	wol_default = pci_wake_enabled(pdev) ? WAKE_MAGIC : 0;
+	wol_default = device_may_wakeup(&pdev->dev) ? WAKE_MAGIC : 0;
 
 	err = -ENOMEM;
 	hw = kzalloc(sizeof(*hw), GFP_KERNEL);

