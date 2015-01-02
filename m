From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: [PATCH] qmi_wwan: Set random MAC on devices with buggy fw
Date: Fri,  2 Jan 2015 16:21:45 +0100
Message-ID: <1420212105-20278-1-git-send-email-kristian.evensen@gmail.com>
Cc: Kristian Evensen <kristian.evensen@gmail.com>
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org, bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:57920 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752046AbbABPVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 10:21:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kristian Evensen <kristian.evensen@gmail.com>

Some buggy firmwares export an incorrect MAC address (00:a0:c6:00:00:00). This
makes for example checking devices for random MAC addresses tricky, and you
might end up with multiple network interfaces with the same address.

This patch tries to fix, or at least improve, the situation by setting the MAC
address of devices with this firmware bug to a random address. I tested the
patch with two devices that has this firmware bug (Huawei E398 and E392), and
network traffic worked fine after changing the address.

Signed-off-by: Kristian Evensen <kristian.evensen@gmail.com>
---
 drivers/net/usb/qmi_wwan.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index db21af8..30a716f 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -56,6 +56,8 @@ struct qmi_wwan_state {
 /* default ethernet address used by the modem */
 static const u8 default_modem_addr[ETH_ALEN] = {0x02, 0x50, 0xf3};
 
+static const u8 buggy_fw_addr[ETH_ALEN] = {0x00, 0xa0, 0xc6, 0x00, 0x00, 0x00};
+
 /* Make up an ethernet header if the packet doesn't have one.
  *
  * A firmware bug common among several devices cause them to send raw
@@ -332,10 +334,12 @@ next_desc:
 		usb_driver_release_interface(driver, info->data);
 	}
 
-	/* Never use the same address on both ends of the link, even
-	 * if the buggy firmware told us to.
+	/* Never use the same address on both ends of the link, even if the
+	 * buggy firmware told us to. Or, if device is assigned the well-known
+	 * buggy firmware MAC address, replace it with a random address,
 	 */
-	if (ether_addr_equal(dev->net->dev_addr, default_modem_addr))
+	if (ether_addr_equal(dev->net->dev_addr, default_modem_addr) ||
+	    ether_addr_equal(dev->net->dev_addr, buggy_fw_addr))
 		eth_hw_addr_random(dev->net);
 
 	/* make MAC addr easily distinguishable from an IP header */
-- 
1.9.1
