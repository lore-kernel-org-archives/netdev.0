From: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Subject: [PATCH 1/2] usbnet: Get EVENT_NO_RUNTIME_PM bit before it is cleared
Date: Mon, 24 Aug 2015 23:13:42 +0300
Message-ID: <1440447223-15945-2-git-send-email-eugene.shatokhin@rosalab.ru>
References: <55AD3A41.2040100@rosalab.ru>
 <1440447223-15945-1-git-send-email-eugene.shatokhin@rosalab.ru>
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
To: Oliver Neukum <oneukum@suse.de>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440447223-15945-1-git-send-email-eugene.shatokhin@rosalab.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is needed to check EVENT_NO_RUNTIME_PM bit of dev->flags in
usbnet_stop(), but its value should be read before it is cleared
when dev->flags is set to 0.

The problem was spotted and the fix was provided by
Oliver Neukum <oneukum@suse.de>.

Signed-off-by: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
---
 drivers/net/usb/usbnet.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 3c86b10..e049857 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -778,7 +778,7 @@ int usbnet_stop (struct net_device *net)
 {
 	struct usbnet		*dev = netdev_priv(net);
 	struct driver_info	*info = dev->driver_info;
-	int			retval, pm;
+	int			retval, pm, mpn;
 
 	clear_bit(EVENT_DEV_OPEN, &dev->flags);
 	netif_stop_queue (net);
@@ -809,6 +809,8 @@ int usbnet_stop (struct net_device *net)
 
 	usbnet_purge_paused_rxq(dev);
 
+	mpn = !test_and_clear_bit(EVENT_NO_RUNTIME_PM, &dev->flags);
+
 	/* deferred work (task, timer, softirq) must also stop.
 	 * can't flush_scheduled_work() until we drop rtnl (later),
 	 * else workers could deadlock; so make workers a NOP.
@@ -819,8 +821,7 @@ int usbnet_stop (struct net_device *net)
 	if (!pm)
 		usb_autopm_put_interface(dev->intf);
 
-	if (info->manage_power &&
-	    !test_and_clear_bit(EVENT_NO_RUNTIME_PM, &dev->flags))
+	if (info->manage_power && mpn)
 		info->manage_power(dev, 0);
 	else
 		usb_autopm_put_interface(dev->intf);
-- 
2.3.2
