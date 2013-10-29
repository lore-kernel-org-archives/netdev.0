From: "Du, ChangbinX" <changbinx.du@intel.com>
Subject: [PATCH] net/cdc_ncm: fix null pointer panic at usbnet_link_change
Date: Tue, 29 Oct 2013 03:30:42 +0000
Message-ID: <0C18FE92A7765D4EB9EE5D38D86A563A019F450F@SHSMSX103.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "oliver@neukum.org" <oliver@neukum.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Du, Changbin" <changbinx.du@intel.com>

In cdc_ncm_bind() function, it call cdc_ncm_bind_common() to setup usb.
But cdc_ncm_bind_common() may meet error and cause usbnet_disconnect()
be called which calls free_netdev(net). Thus usbnet structure(alloced
with net_device structure) will be freed,too.
So we cannot call usbnet_link_change() if cdc_ncm_bind_common() return
error.

BUG: unable to handle kernel NULL pointer dereference at 00000078
EIP is at usbnet_link_change+0x1e/0x80
Call Trace:
 [<c24bc69a>] cdc_ncm_bind+0x3a/0x50
 [<c24b8d32>] usbnet_probe+0x282/0x7d0
 [<c2167f2c>] ? sysfs_new_dirent+0x6c/0x100
 [<c2821253>] ? mutex_lock+0x13/0x40
 [<c24bb278>] cdc_ncm_probe+0x8/0x10
 [<c24e0ef7>] usb_probe_interface+0x187/0x2c0
 [<c23caa8a>] ? driver_sysfs_add+0x6a/0x90
 [<c23cb290>] ? __driver_attach+0x90/0x90
 [<c23caf14>] driver_probe_device+0x74/0x360
 [<c24e07b1>] ? usb_match_id+0x41/0x60
 [<c24e081e>] ? usb_device_match+0x4e/0x90
 [<c23cb290>] ? __driver_attach+0x90/0x90
 [<c23cb2c9>] __device_attach+0x39/0x50
 [<c23c93f4>] bus_for_each_drv+0x34/0x70
 [<c23cae2b>] device_attach+0x7b/0x90
 [<c23cb290>] ? __driver_attach+0x90/0x90
 [<c23ca38f>] bus_probe_device+0x6f/0x90
 [<c23c8a08>] device_add+0x558/0x630
 [<c24e4821>] ? usb_create_ep_devs+0x71/0xd0
 [<c24dd0db>] ? create_intf_ep_devs+0x4b/0x70
 [<c24df2bf>] usb_set_configuration+0x4bf/0x800
 [<c23cb290>] ? __driver_attach+0x90/0x90
 [<c24e809b>] generic_probe+0x2b/0x90
 [<c24e105c>] usb_probe_device+0x2c/0x70
 [<c23caf14>] driver_probe_device+0x74/0x360

Signed-off-by: Du, Changbin <changbinx.du@intel.com>
---
 drivers/net/usb/cdc_ncm.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 43afde8..af37ecf 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -603,14 +603,15 @@ static int cdc_ncm_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	/* NCM data altsetting is always 1 */
 	ret = cdc_ncm_bind_common(dev, intf, 1);
-
-	/*
-	 * We should get an event when network connection is "connected" or
-	 * "disconnected". Set network connection in "disconnected" state
-	 * (carrier is OFF) during attach, so the IP network stack does not
-	 * start IPv6 negotiation and more.
-	 */
-	usbnet_link_change(dev, 0, 0);
+	if (!ret) {
+		/*
+		 * We should get an event when network connection is "connected"
+		 * or "disconnected". Set network connection in "disconnected"
+		 * state (carrier is OFF) during attach, so the IP network stack
+		 * does not start IPv6 negotiation and more.
+		 */
+		usbnet_link_change(dev, 0, 0);
+	}
 	return ret;
 }
 
-- 
1.8.3.2
