From: "Stam, Michel [FINT]" <M.Stam@fugro.nl>
Subject: RE: [PATCH] asix: Do full reset during ax88772_bind
Date: Fri, 7 Nov 2014 09:27:26 +0100
Message-ID: <C89EFD3CD56F64468D3D206D683A8D22039FFEDE@ldam-msx2.fugro-nl.local>
References: <1415288981-3862-1-git-send-email-ckeepax@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <jeffrey.t.kirsher@intel.com>, <emilgoode@gmail.com>,
	<linux-usb@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "Charles Keepax" <ckeepax@opensource.wolfsonmicro.com>,
	<davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1415288981-3862-1-git-send-email-ckeepax@opensource.wolfsonmicro.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please add;

Tested-by: Michel Stam  <m.stam@fugro.nl>

Kind regards,

Michel Stam

-----Original Message-----
From: Charles Keepax [mailto:ckeepax@opensource.wolfsonmicro.com] 
Sent: Thursday, November 06, 2014 16:50 PM
To: davem@davemloft.net
Cc: jeffrey.t.kirsher@intel.com; Stam, Michel [FINT];
emilgoode@gmail.com; linux-usb@vger.kernel.org; netdev@vger.kernel.org;
linux-kernel@vger.kernel.org
Subject: [PATCH] asix: Do full reset during ax88772_bind

commit 3cc81d85ee01 ("asix: Don't reset PHY on if_up for ASIX 88772")
causes the ethernet on Arndale to no longer function. This appears to be
because the Arndale ethernet requires a full reset before it will
function correctly, however simply reverting the above patch causes
problems with ethtool settings getting reset.

It seems the problem is that the ethernet is not properly reset during
bind, and indeed the code in ax88772_bind that resets the device is a
very small subset of the actual ax88772_reset function. This patch uses
ax88772_reset in place of the existing reset code in ax88772_bind which
removes some code duplication and fixes the ethernet on Arndale.

It is still possible that the original patch causes some issues with
suspend and resume but that seems like a separate issue and I haven't
had a chance to test that yet.

Signed-off-by: Charles Keepax <ckeepax@opensource.wolfsonmicro.com>
Tested-by: Riku Voipio <riku.voipio@linaro.org>
---

Hi,

I wasn't 100% sure which branch to base this off so I based it on Dave
Miller's net-next branch, which seemed logical.

Thanks,
Charles

 drivers/net/usb/asix_devices.c |   14 +-------------
 1 files changed, 1 insertions(+), 13 deletions(-)

diff --git a/drivers/net/usb/asix_devices.c
b/drivers/net/usb/asix_devices.c index 2c05f6c..816d511 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -465,19 +465,7 @@ static int ax88772_bind(struct usbnet *dev, struct
usb_interface *intf)
 		return ret;
 	}
 
-	ret = asix_sw_reset(dev, AX_SWRESET_IPPD | AX_SWRESET_PRL);
-	if (ret < 0)
-		return ret;
-
-	msleep(150);
-
-	ret = asix_sw_reset(dev, AX_SWRESET_CLEAR);
-	if (ret < 0)
-		return ret;
-
-	msleep(150);
-
-	ret = asix_sw_reset(dev, embd_phy ? AX_SWRESET_IPRL :
AX_SWRESET_PRTE);
+	ax88772_reset(dev);
 
 	/* Read PHYID register *AFTER* the PHY was reset properly */
 	phyid = asix_get_phyid(dev);
--
1.7.2.5
