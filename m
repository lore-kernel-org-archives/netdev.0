From: Hauke Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>
Subject: [PATCH] bcma: fix regression in pmu workaround reg masks
Date: Thu, 26 Jul 2012 11:15:51 +0200
Message-ID: <1343294151-5691-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, Hauke Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>,
	Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This fixes a regression introduced in:
commit b9562545ef0b13c0440ccd8d6dd4111fb77cb17a
Author: Hauke Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>
Date:   Sat Jun 30 01:44:41 2012 +0200

    bcma: complete workaround for BCMA43224 and BCM4313

The regression broke reading of the sprom from the chip and seamed to
cause a change of the pci id on a BCMA43224 device so that it is
rejected by brcmsmac. If this problem occurred, after applying this
patch, a cold boot is needed to make the device work again.

In the original patch the workaround set the intended bits in the chip
common core chip control registers, but the patch also unset all the
other bits in that register, because of a wrong mask. The original
patch was based on code from brcmsmac and there was an additional
inversing of the mask in the code setting these regs which was missing
here. Now the regs are set like brcmsmac did it before.

Signed-off-by: Hauke Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>
Reported-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Tested-by: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Cc: Rafa=C5=82 Mi=C5=82ecki <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/bcma/driver_chipcommon_pmu.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/bcma/driver_chipcommon_pmu.c b/drivers/bcma/driver=
_chipcommon_pmu.c
index 4432617..c9a4f46 100644
--- a/drivers/bcma/driver_chipcommon_pmu.c
+++ b/drivers/bcma/driver_chipcommon_pmu.c
@@ -110,7 +110,7 @@ void bcma_pmu_workarounds(struct bcma_drv_cc *cc)
 		/* enable 12 mA drive strenth for 4313 and set chipControl
 		   register bit 1 */
 		bcma_chipco_chipctl_maskset(cc, 0,
-					    BCMA_CCTRL_4313_12MA_LED_DRIVE,
+					    ~BCMA_CCTRL_4313_12MA_LED_DRIVE,
 					    BCMA_CCTRL_4313_12MA_LED_DRIVE);
 		break;
 	case BCMA_CHIP_ID_BCM4331:
@@ -124,14 +124,14 @@ void bcma_pmu_workarounds(struct bcma_drv_cc *cc)
 		   register bit 15 */
 		if (bus->chipinfo.rev =3D=3D 0) {
 			bcma_cc_maskset32(cc, BCMA_CC_CHIPCTL,
-					  BCMA_CCTRL_43224_GPIO_TOGGLE,
+					  ~BCMA_CCTRL_43224_GPIO_TOGGLE,
 					  BCMA_CCTRL_43224_GPIO_TOGGLE);
 			bcma_chipco_chipctl_maskset(cc, 0,
-						    BCMA_CCTRL_43224A0_12MA_LED_DRIVE,
+						    ~BCMA_CCTRL_43224A0_12MA_LED_DRIVE,
 						    BCMA_CCTRL_43224A0_12MA_LED_DRIVE);
 		} else {
 			bcma_chipco_chipctl_maskset(cc, 0,
-						    BCMA_CCTRL_43224B0_12MA_LED_DRIVE,
+						    ~BCMA_CCTRL_43224B0_12MA_LED_DRIVE,
 						    BCMA_CCTRL_43224B0_12MA_LED_DRIVE);
 		}
 		break;
--=20
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
