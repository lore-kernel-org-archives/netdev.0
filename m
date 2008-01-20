From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [PATCH 10/14] [rndis_host] Add rndis_early_init function pointer to
	'struct rndis_data'.
Date: Sun, 20 Jan 2008 02:14:38 +0200
Message-ID: <20080120001438.25718.96722.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bjd@jooz.net, dbrownell@users.sourceforge.net,
	netdev@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout3-sn2.hy.skanova.net ([81.228.8.111]:45268 "EHLO
	pne-smtpout3-sn2.hy.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753761AbYATAOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2008 19:14:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function pointer is for rndis minidrivers that need to do work on device right
after RNDIS_INIT. For example setting device specific configuration parameters
with OID_GEN_RNDIS_CONFIG_PARAMETER.

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
---

 drivers/net/usb/rndis_host.c |    6 ++++++
 drivers/net/usb/usbnet.h     |    3 +++
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index 1d6bf0a..22e5ca1 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -336,6 +336,12 @@ int generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf)
 		dev->hard_mtu, tmp, dev->rx_urb_size,
 		1 << le32_to_cpu(u.init_c->packet_alignment));
 
+	/* module has some device initialization code needs to be done right
+	 * after RNDIS_INIT */
+	if (dev->driver_info->rndis_early_init &&
+			dev->driver_info->rndis_early_init(dev) != 0)
+		goto halt_fail_and_release;
+
 	/* Get designated host ethernet address */
 	reply_len = ETH_ALEN;
 	retval = rndis_query(dev, intf, u.buf, OID_802_3_PERMANENT_ADDRESS,
diff --git a/drivers/net/usb/usbnet.h b/drivers/net/usb/usbnet.h
index 0b4bf09..2bc5f76 100644
--- a/drivers/net/usb/usbnet.h
+++ b/drivers/net/usb/usbnet.h
@@ -116,6 +116,9 @@ struct driver_info {
 	struct sk_buff	*(*tx_fixup)(struct usbnet *dev,
 				struct sk_buff *skb, gfp_t flags);
 
+	/* rndis minidriver early initialization code, can sleep */
+	int	(*rndis_early_init)(struct usbnet *dev);
+
 	/* for new devices, use the descriptor-reading code instead */
 	int		in;		/* rx endpoint */
 	int		out;		/* tx endpoint */

