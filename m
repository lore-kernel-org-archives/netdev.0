From: Petko Manolov <petkan@mip-labs.com>
Subject: [PATCH] Fixes buffer allocation size and the actual packet length;
Date: Tue, 26 Apr 2016 21:50:24 +0300
Message-ID: <1461696624-5373-2-git-send-email-petkan@mip-labs.com>
References: <1461696624-5373-1-git-send-email-petkan@mip-labs.com>
Cc: davem@davemloft.net, petkan@mip-labs.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lan.nucleusys.com ([92.247.61.126]:42250 "EHLO
	zztop.nucleusys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752395AbcDZSuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 14:50:40 -0400
In-Reply-To: <1461696624-5373-1-git-send-email-petkan@mip-labs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

usb_fill_bulk_urb() receives buffer length parameter 8 bytes larger
than what's allocated by alloc_skb(); This seems to be a problem with
older (pegasus usb-1.1) devices, which may silently return more data
than the maximal packet length.

Going through the chip's documentation i figured out the ethernet
packet is appended with 4 bytes of status data.  That's why we now
subtract 4 instead of 8 bytes from the reported packet length.

Reported-by: Lincoln Ramsay <a1291762@gmail.com>
Signed-off-by: Petko Manolov <petkan@mip-labs.com>
---
 drivers/net/usb/pegasus.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index f840802..780c217 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -497,7 +497,7 @@ static void read_bulk_callback(struct urb *urb)
 		pkt_len = buf[count - 3] << 8;
 		pkt_len += buf[count - 4];
 		pkt_len &= 0xfff;
-		pkt_len -= 8;
+		pkt_len -= 4;
 	}
 
 	/*
@@ -528,7 +528,7 @@ static void read_bulk_callback(struct urb *urb)
 goon:
 	usb_fill_bulk_urb(pegasus->rx_urb, pegasus->usb,
 			  usb_rcvbulkpipe(pegasus->usb, 1),
-			  pegasus->rx_skb->data, PEGASUS_MTU + 8,
+			  pegasus->rx_skb->data, PEGASUS_MTU,
 			  read_bulk_callback, pegasus);
 	rx_status = usb_submit_urb(pegasus->rx_urb, GFP_ATOMIC);
 	if (rx_status == -ENODEV)
@@ -569,7 +569,7 @@ static void rx_fixup(unsigned long data)
 	}
 	usb_fill_bulk_urb(pegasus->rx_urb, pegasus->usb,
 			  usb_rcvbulkpipe(pegasus->usb, 1),
-			  pegasus->rx_skb->data, PEGASUS_MTU + 8,
+			  pegasus->rx_skb->data, PEGASUS_MTU,
 			  read_bulk_callback, pegasus);
 try_again:
 	status = usb_submit_urb(pegasus->rx_urb, GFP_ATOMIC);
@@ -823,7 +823,7 @@ static int pegasus_open(struct net_device *net)
 
 	usb_fill_bulk_urb(pegasus->rx_urb, pegasus->usb,
 			  usb_rcvbulkpipe(pegasus->usb, 1),
-			  pegasus->rx_skb->data, PEGASUS_MTU + 8,
+			  pegasus->rx_skb->data, PEGASUS_MTU,
 			  read_bulk_callback, pegasus);
 	if ((res = usb_submit_urb(pegasus->rx_urb, GFP_KERNEL))) {
 		if (res == -ENODEV)
-- 
2.8.0.rc3
