From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] can: usb: PCAN-USB Pro: fix mem leaks in pcan_usb_pro_init() on error paths
Date: Mon, 16 Apr 2012 21:43:08 +0200
Message-ID: <1334605388-1549-2-git-send-email-mkl@pengutronix.de>
References: <1334605388-1549-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Jesper Juhl <jj@chaosbits.net>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1334605388-1549-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jj@chaosbits.net>

If either call to pcan_usb_pro_send_req() in
drivers/net/can/usb/peak_usb/pcan_usb_pro.c::pcan_usb_pro_init()
fails, we'll leak the memory we allocated to 'usb_if' with kzalloc()
when the 'usb_if' variable goes out of scope without having been
assigned to anything as we 'return err;'.
Fix this by adding appropriate kfree(usb_if) calls to the error paths.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
Acked-by: Stephane Grosjean <s.grosjean@peak-system.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/peak_usb/pcan_usb_pro.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_pro.c b/drivers/net/can/usb/peak_usb/pcan_usb_pro.c
index 5234586..629c4ba 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb_pro.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb_pro.c
@@ -875,6 +875,7 @@ static int pcan_usb_pro_init(struct peak_usb_device *dev)
 					    PCAN_USBPRO_INFO_FW,
 					    &fi, sizeof(fi));
 		if (err) {
+			kfree(usb_if);
 			dev_err(dev->netdev->dev.parent,
 				"unable to read %s firmware info (err %d)\n",
 				pcan_usb_pro.name, err);
@@ -885,6 +886,7 @@ static int pcan_usb_pro_init(struct peak_usb_device *dev)
 					    PCAN_USBPRO_INFO_BL,
 					    &bi, sizeof(bi));
 		if (err) {
+			kfree(usb_if);
 			dev_err(dev->netdev->dev.parent,
 				"unable to read %s bootloader info (err %d)\n",
 				pcan_usb_pro.name, err);
-- 
1.7.4.1

