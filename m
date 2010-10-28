From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] virtio_net: Fix queue full check
Date: Thu, 28 Oct 2010 10:40:36 +0530
Message-ID: <20101028051036.25340.23442.sendpatchset@krkumar2.in.ibm.com>
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: rusty@rustcorp.com.au, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp06.au.ibm.com ([202.81.31.148]:40213 "EHLO
	e23smtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752824Ab0J1FKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 01:10:44 -0400
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp06.au.ibm.com (8.14.4/8.13.1) with ESMTP id o9S5AUmF010891
	for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 16:10:30 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o9S5AcH91138734
	for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 16:10:38 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o9S5AcwU020617
	for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 16:10:38 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I get many queue full errors being wrongly reported when running
parallel netperfs:

Oct 17 10:22:40 localhost kernel: net eth0: Unexpected TX queue failure: -28
Oct 17 10:28:22 localhost kernel: net eth0: Unexpected TX queue failure: -28
Oct 17 10:35:58 localhost kernel: net eth0: Unexpected TX queue failure: -28
Oct 17 10:41:06 localhost kernel: net eth0: Unexpected TX queue failure: -28

I initially changed the check from -ENOMEM to -ENOSPC, but
virtqueue_add_buf can return only -ENOSPC when it doesn't have
space for new request.  Patch removes redundant checks but
displays the failure errno.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 drivers/net/virtio_net.c |   15 ++++-----------
 1 file changed, 4 insertions(+), 11 deletions(-)

diff -ruNp org/drivers/net/virtio_net.c new/drivers/net/virtio_net.c
--- org/drivers/net/virtio_net.c	2010-10-11 10:20:02.000000000 +0530
+++ new/drivers/net/virtio_net.c	2010-10-21 17:37:45.000000000 +0530
@@ -570,17 +570,10 @@ static netdev_tx_t start_xmit(struct sk_
 
 	/* This can happen with OOM and indirect buffers. */
 	if (unlikely(capacity < 0)) {
-		if (net_ratelimit()) {
-			if (likely(capacity == -ENOMEM)) {
-				dev_warn(&dev->dev,
-					 "TX queue failure: out of memory\n");
-			} else {
-				dev->stats.tx_fifo_errors++;
-				dev_warn(&dev->dev,
-					 "Unexpected TX queue failure: %d\n",
-					 capacity);
-			}
-		}
+		if (net_ratelimit())
+			dev_warn(&dev->dev,
+				 "TX queue failure (%d): out of memory\n",
+				 capacity); 
 		dev->stats.tx_dropped++;
 		kfree_skb(skb);
 		return NETDEV_TX_OK;
