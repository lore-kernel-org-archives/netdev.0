From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 11/15] spidernet: service TX later.
Date: Mon, 11 Jun 2007 13:59:21 -0500
Message-ID: <20070611185921.GK13741@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com> <1181265151.6026.1.camel@concordia.ozlabs.ibm.com> <20070608170608.GI7904@austin.ibm.com> <20070608172020.GA31089@havoc.gtf.org> <20070611181429.GA4397@austin.ibm.com> <20070611181702.GA13741@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Ellerman <michael@ellerman.id.au>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:37027 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751252AbXFKS7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 14:59:23 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5BIxM4V000445
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 14:59:23 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5BIxMOA200406
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 12:59:22 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5BIxL1R012225
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 12:59:22 -0600
Content-Disposition: inline
In-Reply-To: <20070611181702.GA13741@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



When entering the netdev poll routine, empty out the RX
chain first, before cleaning up the TX chain. This should
help avoid RX buffer overflows.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6.22-rc1/drivers/net/spider_net.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-06-11 11:53:21.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-06-11 11:53:24.000000000 -0500
@@ -1287,7 +1287,6 @@ spider_net_poll(struct net_device *netde
 	int packets_to_do, packets_done = 0;
 	int no_more_packets = 0;
 
-	spider_net_cleanup_tx_ring(card);
 	packets_to_do = min(*budget, netdev->quota);
 
 	while (packets_to_do) {
@@ -1312,6 +1311,8 @@ spider_net_poll(struct net_device *netde
 	spider_net_refill_rx_chain(card);
 	spider_net_enable_rxdmac(card);
 
+	spider_net_cleanup_tx_ring(card);
+
 	/* if all packets are in the stack, enable interrupts and return 0 */
 	/* if not, return 1 */
 	if (no_more_packets) {
