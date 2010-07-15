From: Robert Jennings <rcj@linux.vnet.ibm.com>
Subject: ibmveth: lost IRQ while closing/opening device leads to service
 loss
Date: Thu, 15 Jul 2010 15:21:21 -0500
Message-ID: <20100715202120.GA12770@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Santiago Leon <santil@linux.vnet.ibm.com>,
	Brian King <brking@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:51644 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934651Ab0GOUVX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jul 2010 16:21:23 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6FK5FfO003926
	for <netdev@vger.kernel.org>; Thu, 15 Jul 2010 16:05:15 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6FKLMXl046492
	for <netdev@vger.kernel.org>; Thu, 15 Jul 2010 16:21:22 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6FKLLUJ031764
	for <netdev@vger.kernel.org>; Thu, 15 Jul 2010 16:21:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The order of freeing the IRQ and freeing the device in firmware
in ibmveth_close can cause the adapter to become unusable after a
subsequent ibmveth_open.  Only a reboot of the OS will make the
network device usable again.  This is seen when cycling the adapter
up and down while there is network activity.

There is a window where an IRQ will be left unserviced (H_EOI will not
be called).  The solution is to make a VIO_IRQ_DISABLE h_call, free the
device with firmware, and then call free_irq.

Signed-off-by: Robert Jennings <rcj@linux.vnet.ibm.com>

---
 drivers/net/ibmveth.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: b/drivers/net/ibmveth.c
===================================================================
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -677,7 +677,7 @@ static int ibmveth_close(struct net_devi
 	if (!adapter->pool_config)
 		netif_stop_queue(netdev);
 
-	free_irq(netdev->irq, netdev);
+	h_vio_signal(adapter->vdev->unit_address, VIO_IRQ_DISABLE);
 
 	do {
 		lpar_rc = h_free_logical_lan(adapter->vdev->unit_address);
@@ -689,6 +689,8 @@ static int ibmveth_close(struct net_devi
 				     lpar_rc);
 	}
 
+	free_irq(netdev->irq, netdev);
+
 	adapter->rx_no_buffer = *(u64*)(((char*)adapter->buffer_list_addr) + 4096 - 8);
 
 	ibmveth_cleanup(adapter);

