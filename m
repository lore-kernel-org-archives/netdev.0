From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH net-next 1/3] ptp: Allow reassigning calibration pin function
Date: Wed, 25 Jun 2014 14:37:29 +0200
Message-ID: <1403699851-11178-2-git-send-email-stefan.sorensen@spectralink.com>
References: <1403699851-11178-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: davem@davemloft.net, richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213083164185.static.sonofon.dk ([213.83.164.185]:59229 "EHLO
	HORWDSPRD01.spectralink.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755444AbaFYMhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 08:37:40 -0400
In-Reply-To: <1403699851-11178-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ptp pin function programming does not allow calibration pin to chan=
ge
function. This is problematic on hardware that uses the default calibra=
tion
pin for other purposes.

Removing this limitation does not impact calibration if userspace does =
not
reprogram the calibration pin.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
---
 drivers/net/phy/dp83640.c | 6 +++++-
 drivers/ptp/ptp_chardev.c | 9 ++-------
 2 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 6a999e6..73fada9 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -594,7 +594,11 @@ static void recalibrate(struct dp83640_clock *cloc=
k)
 	u16 cal_gpio, cfg0, evnt, ptp_trig, trigger, val;
=20
 	trigger =3D CAL_TRIGGER;
-	cal_gpio =3D gpio_tab[CALIBRATE_GPIO];
+	cal_gpio =3D 1 + ptp_find_pin(clock->ptp_clock, PTP_PF_PHYSYNC, 0);
+	if (cal_gpio < 1) {
+		pr_err("PHY calibration pin not avaible - PHY is not calibrated.");
+		return;
+	}
=20
 	mutex_lock(&clock->extreg_lock);
=20
diff --git a/drivers/ptp/ptp_chardev.c b/drivers/ptp/ptp_chardev.c
index 419056d..f8a7609 100644
--- a/drivers/ptp/ptp_chardev.c
+++ b/drivers/ptp/ptp_chardev.c
@@ -86,17 +86,12 @@ int ptp_set_pinfunc(struct ptp_clock *ptp, unsigned=
 int pin,
 			return -EINVAL;
 		break;
 	case PTP_PF_PHYSYNC:
-		pr_err("sorry, cannot reassign the calibration pin\n");
-		return -EINVAL;
+		if (chan !=3D 0)
+			return -EINVAL;
 	default:
 		return -EINVAL;
 	}
=20
-	if (pin2->func =3D=3D PTP_PF_PHYSYNC) {
-		pr_err("sorry, cannot reprogram the calibration pin\n");
-		return -EINVAL;
-	}
-
 	if (info->verify(info, pin, func, chan)) {
 		pr_err("driver cannot use function %u on pin %u\n", func, chan);
 		return -EOPNOTSUPP;
--=20
1.9.3
