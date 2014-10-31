From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net] r8152: stop submitting intr for -EPROTO
Date: Fri, 31 Oct 2014 13:35:57 +0800
Message-ID: <1394712342-15778-74-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For Renesas USB 3.0 host controller, when unplugging the usb hub which
has the RTL8153 plugged, the driver would get -EPROTO for interrupt
transfer. There is high probability to get the information of "HC died;
cleaning up", if the driver continues to submit the interrupt transfer
before the disconnect() is called.

[ 1024.197678] r8152 9-1.4:1.0 eth0: intr status -71
[ 1024.213673] r8152 9-1.4:1.0 eth0: intr status -71
[ 1024.229668] r8152 9-1.4:1.0 eth0: intr status -71
[ 1024.245661] r8152 9-1.4:1.0 eth0: intr status -71
[ 1024.261653] r8152 9-1.4:1.0 eth0: intr status -71
[ 1024.277648] r8152 9-1.4:1.0 eth0: intr status -71
[ 1024.293642] r8152 9-1.4:1.0 eth0: intr status -71
[ 1024.309638] r8152 9-1.4:1.0 eth0: intr status -71
[ 1024.325633] r8152 9-1.4:1.0 eth0: intr status -71
[ 1024.341627] r8152 9-1.4:1.0 eth0: intr status -71
[ 1024.357621] r8152 9-1.4:1.0 eth0: intr status -71
[ 1024.373615] r8152 9-1.4:1.0 eth0: intr status -71
[ 1024.383097] usb 9-1: USB disconnect, device number 2
[ 1024.383103] usb 9-1.4: USB disconnect, device number 6
[ 1029.391010] xhci_hcd 0000:04:00.0: xHCI host not responding to stop endpoint command.
[ 1029.391016] xhci_hcd 0000:04:00.0: Assuming host is dying, halting host.
[ 1029.392551] xhci_hcd 0000:04:00.0: HC died; cleaning up
[ 1029.421480] usb 8-1: USB disconnect, device number 2

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index ca3c5d5..c6554c7 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1162,6 +1162,9 @@ static void intr_callback(struct urb *urb)
 	case -ESHUTDOWN:
 		netif_device_detach(tp->netdev);
 	case -ENOENT:
+	case -EPROTO:
+		netif_info(tp, intr, tp->netdev,
+			   "Stop submitting intr, status %d\n", status);
 		return;
 	case -EOVERFLOW:
 		netif_info(tp, intr, tp->netdev, "intr status -EOVERFLOW\n");
-- 
1.9.3
