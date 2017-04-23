From: Maksim Salau <maksim.salau@gmail.com>
Subject: [PATCH v2] net: can: usb: gs_usb: Fix buffer on stack
Date: Sun, 23 Apr 2017 20:31:40 +0300
Message-ID: <20170423173140.5538-1-maksim.salau@gmail.com>
References: <CAOMZO5DLdR00FY01r2z=RvSrn4vNEZ+Z3OS0KWB95DGt=3fh2w@mail.gmail.com>
Cc: Maksim Salau <maksim.salau@gmail.com>
To: Wolfgang Grandegger <wg@grandegger.com>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Maximilian Schneider <max@schneidersoft.net>,
        Hubert Denkmair <hubert@denkmair.de>,
        Wolfram Sang <wsa-dev@sang-engineering.com>,
        Ethan Zonca <e@ethanzonca.com>, linux-can@vger.kernel.org,
        netdev@vger.kernel.org, Fabio Estevam <festevam@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <CAOMZO5DLdR00FY01r2z=RvSrn4vNEZ+Z3OS0KWB95DGt=3fh2w@mail.gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allocate buffers on HEAP instead of STACK for local structures
that are to be sent using usb_control_msg().

Signed-off-by: Maksim Salau <maksim.salau@gmail.com>
---
 Changes in v2:
   dropped redundant assignment.

 drivers/net/can/usb/gs_usb.c | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/can/usb/gs_usb.c b/drivers/net/can/usb/gs_usb.c
index 300349f..eecee7f 100644
--- a/drivers/net/can/usb/gs_usb.c
+++ b/drivers/net/can/usb/gs_usb.c
@@ -739,13 +739,18 @@ static const struct net_device_ops gs_usb_netdev_ops = {
 static int gs_usb_set_identify(struct net_device *netdev, bool do_identify)
 {
 	struct gs_can *dev = netdev_priv(netdev);
-	struct gs_identify_mode imode;
+	struct gs_identify_mode *imode;
 	int rc;
 
+	imode = kmalloc(sizeof(*imode), GFP_KERNEL);
+
+	if (!imode)
+		return -ENOMEM;
+
 	if (do_identify)
-		imode.mode = GS_CAN_IDENTIFY_ON;
+		imode->mode = GS_CAN_IDENTIFY_ON;
 	else
-		imode.mode = GS_CAN_IDENTIFY_OFF;
+		imode->mode = GS_CAN_IDENTIFY_OFF;
 
 	rc = usb_control_msg(interface_to_usbdev(dev->iface),
 			     usb_sndctrlpipe(interface_to_usbdev(dev->iface),
@@ -755,10 +760,12 @@ static int gs_usb_set_identify(struct net_device *netdev, bool do_identify)
 			     USB_RECIP_INTERFACE,
 			     dev->channel,
 			     0,
-			     &imode,
-			     sizeof(imode),
+			     imode,
+			     sizeof(*imode),
 			     100);
 
+	kfree(imode);
+
 	return (rc > 0) ? 0 : rc;
 }
 
-- 
2.9.3

