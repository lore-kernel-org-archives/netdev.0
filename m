From: Kristian Evensen <kristian.evensen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] rndis_host: Set random MAC for ZTE MF910
Date: Wed, 13 Jul 2016 18:39:05 +0200
Message-ID: <1468427945-11600-1-git-send-email-kristian.evensen@gmail.com>
Cc: Kristian Evensen <kristian.evensen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Kristian Evensen <kristian.evensen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

All ZTE MF910 mifis, at least on some revisions, export the same MAC
address (36:4b:50:b7:ef:da). Check for this MAC address and set a random
MAC if detected.

Also, changed the memcpy() to ether_addr_copy(), as pointed out by
checkpatch.

Signed-off-by: Kristian Evensen <kristian.evensen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/usb/rndis_host.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index 524a47a281..85bdbdf 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -295,6 +295,9 @@ static const struct net_device_ops rndis_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
+/* well-known buggy ZTE MF910 MAC address */
+static const u8 buggy_zte_addr[ETH_ALEN] = {0x36, 0x4b, 0x50, 0xb7, 0xef, 0xda};
+
 int
 generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
 {
@@ -428,7 +431,11 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
 		dev_err(&intf->dev, "rndis get ethaddr, %d\n", retval);
 		goto halt_fail_and_release;
 	}
-	memcpy(net->dev_addr, bp, ETH_ALEN);
+
+	if (ether_addr_equal(bp, buggy_zte_addr))
+		eth_hw_addr_random(net);
+	else
+		ether_addr_copy(net->dev_addr, bp);
 
 	/* set a nonzero filter to enable data transfers */
 	memset(u.set, 0, sizeof *u.set);
-- 
2.5.0

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
