From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2.6.28] myri10ge: fix stop/go mmio ordering
Date: Thu, 30 Oct 2008 08:53:27 +0100
Message-ID: <490967F7.4030608@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1880 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752768AbYJ3Hvj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2008 03:51:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use mmiowb() to ensure "stop" and "go" commands are sent in order on ia64.

Signed-off-by: Brice Goglin <brice@myri.com>

--- linux-git/drivers/net/myri10ge/myri10ge.c	2008-10-30 08:15:37.000000000 +0100
+++ linux-tmp/drivers/net/myri10ge/myri10ge.c	2008-10-30 08:17:54.000000000 +0100
@@ -75,7 +75,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.4.3-1.374"
+#define MYRI10GE_VERSION_STR "1.4.3-1.375"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");
@@ -1393,6 +1393,7 @@
 		if (tx->req == tx->done) {
 			tx->queue_active = 0;
 			put_be32(htonl(1), tx->send_stop);
+			mmiowb();
 		}
 		__netif_tx_unlock(dev_queue);
 	}
@@ -2864,6 +2865,7 @@
 	if ((mgp->dev->real_num_tx_queues > 1) && tx->queue_active == 0) {
 		tx->queue_active = 1;
 		put_be32(htonl(1), tx->send_go);
+		mmiowb();
 	}
 	tx->pkt_start++;
 	if ((avail - count) < MXGEFW_MAX_SEND_DESC) {


