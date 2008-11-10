From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2.6.28] myri10ge: fix stop/go ordering even more
Date: Mon, 10 Nov 2008 13:58:41 +0100
Message-ID: <49183001.5010405@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1951 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754724AbYKJNAE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Nov 2008 08:00:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The doorbell writes may be seen out of order by the firmware if they
are in WC memory since the tx spin(un)lock does not flush WC writes.
Hence if the "stop" is written on a different CPU than the "go", it
is possible that the stop will arrive after the go unless we add an
explicit memory barrier (and mmiowb() is not enough).

It fixes transmit hangs in multi tx queue mode.

Signed-off-by: Brice Goglin <brice@myri.com>

--- linux-git/drivers/net/myri10ge/myri10ge.c	2008-11-07 10:01:32.000000000 +0100
+++ linux-tmp/drivers/net/myri10ge/myri10ge.c	2008-11-07 13:58:07.000000000 +0100
@@ -75,7 +75,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.4.3-1.375"
+#define MYRI10GE_VERSION_STR "1.4.3-1.378"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");
@@ -1393,6 +1393,7 @@
 		if (tx->req == tx->done) {
 			tx->queue_active = 0;
 			put_be32(htonl(1), tx->send_stop);
+			mb();
 			mmiowb();
 		}
 		__netif_tx_unlock(dev_queue);
@@ -2865,6 +2866,7 @@
 	if ((mgp->dev->real_num_tx_queues > 1) && tx->queue_active == 0) {
 		tx->queue_active = 1;
 		put_be32(htonl(1), tx->send_go);
+		mb();
 		mmiowb();
 	}
 	tx->pkt_start++;


