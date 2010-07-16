From: Robert Jennings <rcj@linux.vnet.ibm.com>
Subject: [PATCH] ibmveth: lost IRQ while closing/opening device leads to
 service loss
Date: Fri, 16 Jul 2010 09:57:25 -0500
Message-ID: <20100716145724.GA25385@linux.vnet.ibm.com>
References: <20100715202120.GA12770@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Santiago Leon <santil@linux.vnet.ibm.com>,
	Brian King <brking@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:35164 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965736Ab0GPO5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 10:57:36 -0400
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6GEr2ap001666
	for <netdev@vger.kernel.org>; Fri, 16 Jul 2010 08:53:02 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6GEvQED078108
	for <netdev@vger.kernel.org>; Fri, 16 Jul 2010 08:57:26 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6GEvP16005810
	for <netdev@vger.kernel.org>; Fri, 16 Jul 2010 08:57:25 -0600
Content-Disposition: inline
In-Reply-To: <20100715202120.GA12770@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The order of freeing the IRQ and freeing the device in firmware
in ibmveth_close can cause the adapter to become unusable after a
subsequent ibmveth_open.  Only a reboot of the OS will make the
network device usable again. This is seen when cycling the adapter
up and down while there is network activity.

There is a window where an IRQ will be left unserviced (H_EOI will not
be called).  The solution is to make a VIO_IRQ_DISABLE h_call, free the
device with firmware, and then call free_irq.

Signed-off-by: Robert Jennings <rcj@linux.vnet.ibm.com>

---
No changes to the patch, I realized I left out '[PATCH]' in the subject
and I didn't want any automated tools missing this fix.

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
