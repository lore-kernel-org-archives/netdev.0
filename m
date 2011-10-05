From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH net] mscan: zero accidentally copied register content
Date: Wed, 05 Oct 2011 17:34:00 +0200
Message-ID: <4E8C78E8.3010605@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Andre Naujoks <nautsch@gmail.com>
To: Wolfgang Grandegger <wg@grandegger.com>,
	Wolfram Sang <w.sang@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:23865 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758049Ab1JEPeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 11:34:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to the 16 bit access to mscan registers there's too much data copied to
the zero initialized CAN frame when having an odd number of bytes to copy.
This patch clears the data byte read from the invalid register entry.

Reported-by: Andre Naujoks <nautsch@gmail.com>
Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

---

Hello Wolf[gang|ram],

from an error report from Andre Naujoks i tracked down the problem of
uninitialized data in (normally) initialized CAN frames to the mscan driver.

Regards,
Oliver


diff --git a/drivers/net/can/mscan/mscan.c b/drivers/net/can/mscan/mscan.c
index 92feac6..1b60fbe 100644
--- a/drivers/net/can/mscan/mscan.c
+++ b/drivers/net/can/mscan/mscan.c
@@ -327,20 +327,23 @@ static void mscan_get_rx_frame(struct net_device *dev, struct can_frame *frame)
 	frame->can_dlc = get_can_dlc(in_8(&regs->rx.dlr) & 0xf);
 
 	if (!(frame->can_id & CAN_RTR_FLAG)) {
 		void __iomem *data = &regs->rx.dsr1_0;
 		u16 *payload = (u16 *)frame->data;
 
 		for (i = 0; i < (frame->can_dlc + 1) / 2; i++) {
 			*payload++ = in_be16(data);
 			data += 2 + _MSCAN_RESERVED_DSR_SIZE;
 		}
+		/* zero accidentally copied register content at odd DLCs */
+		if (frame->can_dlc & 1)
+			frame->data[frame->can_dlc] = 0;
 	}
 
 	out_8(&regs->canrflg, MSCAN_RXF);
 }
 
 static void mscan_get_err_frame(struct net_device *dev, struct can_frame *frame,
 				u8 canrflg)
 {
 	struct mscan_priv *priv = netdev_priv(dev);
 	struct mscan_regs *regs = (struct mscan_regs *)priv->reg_base;
