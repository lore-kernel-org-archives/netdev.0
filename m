From: Petko Manolov <petkan@mip-labs.com>
Subject: [PATCH v3 1/2] pegasus: fixes URB buffer allocation size;
Date: Wed, 27 Apr 2016 14:24:49 +0300
Message-ID: <1461756290-27421-2-git-send-email-petkan@mip-labs.com>
References: <1461756290-27421-1-git-send-email-petkan@mip-labs.com>
Cc: davem@davemloft.net, a1291762@gmail.com, johannes@sipsolutions.net,
	Petko Manolov <petkan@mip-labs.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lan.nucleusys.com ([92.247.61.126]:42498 "EHLO
	zztop.nucleusys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751019AbcD0LY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 07:24:59 -0400
In-Reply-To: <1461756290-27421-1-git-send-email-petkan@mip-labs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

usb_fill_bulk_urb() receives buffer length parameter 8 bytes larger
than what's allocated by alloc_skb(); This seems to be a problem with
older (pegasus usb-1.1) devices, which may silently return more data
than the maximal packet length.

Reported-by: Lincoln Ramsay <a1291762@gmail.com>
Signed-off-by: Petko Manolov <petkan@mip-labs.com>
---
 drivers/net/usb/pegasus.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index f840802..f919e20 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
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
