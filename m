From: Santiago Leon <santil@us.ibm.com>
Subject: [PATCH 1/5] ibmveth: Harden driver initilisation
Date: Tue, 03 Oct 2006 12:24:23 -0500
Message-ID: <20061003172423.14851.80630.sendpatchset@ltcml8p1.rchland.ibm.com>
References: <20061003172417.14851.63625.sendpatchset@ltcml8p1.rchland.ibm.com>
Cc: Santiago Leon <santil@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:18095 "EHLO
	e31.co.us.ibm.com") by vger.kernel.org with ESMTP id S1030451AbWJCS1W
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 14:27:22 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k93IRKld017623
	for <netdev@vger.kernel.org>; Tue, 3 Oct 2006 14:27:20 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k93IRBUd324794
	for <netdev@vger.kernel.org>; Tue, 3 Oct 2006 12:27:11 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k93IRAFv025516
	for <netdev@vger.kernel.org>; Tue, 3 Oct 2006 12:27:11 -0600
To: netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20061003172417.14851.63625.sendpatchset@ltcml8p1.rchland.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Ellerman <michael@ellerman.id.au>

Hi Jeff,

This patch has been floating around for a while now, Santi originally sent it in March: http://www.spinics.net/lists/netdev/msg00471.html
 
You replied saying you thought it was "bonkers", I think I explained why it wasn't, perhaps you disagree.

I'm resending it now in the hope you can either give us more info on your objections, or merge it.

After a kexec the ibmveth driver will fail when trying to register with the Hypervisor because the previous kernel has not unregistered.

So if the registration fails, we unregister and then try again.

We don't unconditionally unregister, because we don't want to disturb the regular code path for 99% of users.

Signed-off-by: Michael Ellerman <michael@ellerman.id.au>
Acked-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Santiago Leon <santil@us.ibm.com>
---
 drivers/net/ibmveth.c |   32 ++++++++++++++++++++++++++------
 1 file changed, 26 insertions(+), 6 deletions(-)

diff -urNp a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
--- a/drivers/net/ibmveth.c	2006-07-12 10:45:09.787235496 -0500
+++ b/drivers/net/ibmveth.c	2006-07-12 10:43:20.655186616 -0500
@@ -437,6 +437,31 @@ static void ibmveth_cleanup(struct ibmve
 						 &adapter->rx_buff_pool[i]);
 }
 
+static int ibmveth_register_logical_lan(struct ibmveth_adapter *adapter,
+        union ibmveth_buf_desc rxq_desc, u64 mac_address)
+{
+	int rc, try_again = 1;
+
+	/* After a kexec the adapter will still be open, so our attempt to
+	* open it will fail. So if we get a failure we free the adapter and
+	* try again, but only once. */
+retry:
+	rc = h_register_logical_lan(adapter->vdev->unit_address,
+				    adapter->buffer_list_dma, rxq_desc.desc,
+				    adapter->filter_list_dma, mac_address);
+
+	if (rc != H_SUCCESS && try_again) {
+		do {
+			rc = h_free_logical_lan(adapter->vdev->unit_address);
+		} while (H_IS_LONG_BUSY(rc) || (rc == H_BUSY));
+
+		try_again = 0;
+		goto retry;
+	}
+
+	return rc;
+}
+
 static int ibmveth_open(struct net_device *netdev)
 {
 	struct ibmveth_adapter *adapter = netdev->priv;
@@ -502,12 +527,7 @@ static int ibmveth_open(struct net_devic
 	ibmveth_debug_printk("filter list @ 0x%p\n", adapter->filter_list_addr);
 	ibmveth_debug_printk("receive q   @ 0x%p\n", adapter->rx_queue.queue_addr);
 
-
-	lpar_rc = h_register_logical_lan(adapter->vdev->unit_address,
-					 adapter->buffer_list_dma,
-					 rxq_desc.desc,
-					 adapter->filter_list_dma,
-					 mac_address);
+	lpar_rc = ibmveth_register_logical_lan(adapter, rxq_desc, mac_address);
 
 	if(lpar_rc != H_SUCCESS) {
 		ibmveth_error_printk("h_register_logical_lan failed with %ld\n", lpar_rc);
