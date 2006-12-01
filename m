From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/5] sky2: receive error handling fix
Date: Fri, 01 Dec 2006 14:29:33 -0800
Message-ID: <20061201223217.701523945@osdl.org>
References: <20061201222931.730523290@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:30649 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1162131AbWLAWew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Dec 2006 17:34:52 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-rcv-err.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If sky2 detects out of memory, or gets a bad frame, it reuses the same receive
buffer, but forgets to poke the hardware. This could lead to the receiver
getting stuck if there were lots of errors.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


---
 drivers/net/sky2.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- netdev-2.6.orig/drivers/net/sky2.c	2006-12-01 14:19:32.000000000 -0800
+++ netdev-2.6/drivers/net/sky2.c	2006-12-01 14:23:21.000000000 -0800
@@ -2065,7 +2065,7 @@
 		case OP_RXSTAT:
 			skb = sky2_receive(dev, length, status);
 			if (!skb)
-				break;
+				goto force_update;
 
 			skb->protocol = eth_type_trans(skb, dev);
 			dev->last_rx = jiffies;
@@ -2081,8 +2081,8 @@
 
 			/* Update receiver after 16 frames */
 			if (++buf_write[le->link] == RX_BUF_WRITE) {
-				sky2_put_idx(hw, rxqaddr[le->link],
-					     sky2->rx_put);
+force_update:
+				sky2_put_idx(hw, rxqaddr[le->link], sky2->rx_put);
 				buf_write[le->link] = 0;
 			}
 

--
Stephen Hemminger <shemminger@osdl.org>

