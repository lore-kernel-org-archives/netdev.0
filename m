From: Sebastian Haas <haas@ems-wuensche.com>
Subject: [PATCH] ems_usb: Fix byte order issues on big endian machines
Date: Wed, 04 Nov 2009 16:48:33 +0100
Message-ID: <20091104154833.18231.28984.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core@lists.berlios.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ems-wuensche.com ([81.169.132.244]:38380 "EHLO
	h559305.serverkompetenz.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755975AbZKDPse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 10:48:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CPC-USB is using a ARM7 core with little endian byte order. The "id" field
in can_msg needs byte order conversion from/to CPU byte order.

Signed-off-by: Sebastian Haas <haas@ems-wuensche.com>
---

 drivers/net/can/usb/ems_usb.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/usb/ems_usb.c b/drivers/net/can/usb/ems_usb.c
index 9012e0a..abdbd9c 100644
--- a/drivers/net/can/usb/ems_usb.c
+++ b/drivers/net/can/usb/ems_usb.c
@@ -319,7 +319,7 @@ static void ems_usb_rx_can_msg(struct ems_usb *dev, struct ems_cpc_msg *msg)
 
 	cf = (struct can_frame *)skb_put(skb, sizeof(struct can_frame));
 
-	cf->can_id = msg->msg.can_msg.id;
+	cf->can_id = le32_to_cpu(msg->msg.can_msg.id);
 	cf->can_dlc = min_t(u8, msg->msg.can_msg.length, 8);
 
 	if (msg->type == CPC_MSG_TYPE_EXT_CAN_FRAME
@@ -813,6 +813,9 @@ static netdev_tx_t ems_usb_start_xmit(struct sk_buff *skb, struct net_device *ne
 		msg->length = CPC_CAN_MSG_MIN_SIZE + cf->can_dlc;
 	}
 
+	/* Respect byte order */
+	msg->msg.can_msg.id = cpu_to_le32(msg->msg.can_msg.id);
+
 	for (i = 0; i < MAX_TX_URBS; i++) {
 		if (dev->tx_contexts[i].echo_index == MAX_TX_URBS) {
 			context = &dev->tx_contexts[i];

-- 
EMS Dr. Thomas Wuensche e.K.
Sonnenhang 3
85304 Ilmmuenster
HRA Neuburg a.d. Donau, HR-Nr. 70.106
Phone: +49-8441-490260
Fax  : +49-8441-81860
http://www.ems-wuensche.com
