From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 9/10] spidernet: service TX later.
Date: Tue, 22 May 2007 18:47:25 -0500
Message-ID: <20070522234725.GH2147@austin.ibm.com>
References: <20070522230942.GT5921@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, Florin Malita <fmalita@gmail.com>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:42362 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755776AbXEVXra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2007 19:47:30 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l4MNhbHT011490
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 19:43:37 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4MNlQiN213620
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 17:47:26 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4MNlPff029724
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 17:47:26 -0600
Content-Disposition: inline
In-Reply-To: <20070522230942.GT5921@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


When entering the netdev poll routine, empty out the RX
chain first, before cleaning up the TX chain. This should
help avoid RX buffer overflows.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: netdev-2.6/drivers/net/spider_net.c
===================================================================
--- netdev-2.6.orig/drivers/net/spider_net.c	2007-05-22 18:03:39.000000000 -0500
+++ netdev-2.6/drivers/net/spider_net.c	2007-05-22 18:03:41.000000000 -0500
@@ -1212,7 +1212,6 @@ spider_net_poll(struct net_device *netde
 	int packets_to_do, packets_done = 0;
 	int no_more_packets = 0;
 
-	spider_net_cleanup_tx_ring(card);
 	packets_to_do = min(*budget, netdev->quota);
 
 	while (packets_to_do) {
@@ -1231,6 +1230,8 @@ spider_net_poll(struct net_device *netde
 	spider_net_refill_rx_chain(card);
 	spider_net_enable_rxdmac(card);
 
+	spider_net_cleanup_tx_ring(card);
+
 	/* if all packets are in the stack, enable interrupts and return 0 */
 	/* if not, return 1 */
 	if (no_more_packets) {
