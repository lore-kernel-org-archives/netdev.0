From: David Gibson <david@gibson.dropbear.id.au>
Subject: [PATCH 2/2] netxen: Add sanity checks for Rx buffers returning from hardware
Date: Tue, 17 Dec 2013 16:22:33 +1100
Message-ID: <1387257753-18676-3-git-send-email-david@gibson.dropbear.id.au>
References: <1387257753-18676-1-git-send-email-david@gibson.dropbear.id.au>
Cc: netdev@vger.kernel.org, snagarka@redhat.com, tcamuso@redhat.com,
	vdasgupt@redhat.com, David Gibson <david@gibson.dropbear.id.au>
To: manish.chopra@qlogic.com, sony.chacko@qlogic.com,
	rajesh.borundia@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:37646 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751050Ab3LQFUw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Dec 2013 00:20:52 -0500
In-Reply-To: <1387257753-18676-1-git-send-email-david@gibson.dropbear.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At Red Hat we've seen a couple of customer cases where the kernel has
crashed due to corruption of the Rx buffer free lists in the netxen driver.

>From the information we've had so far, we haven't been able to locate the
bug.  Our working theory is that due to either a driver, hardware or
firmware bug, we very occasionally process Rx descriptors which have the
wrong buffer ref_handle in them.  This is consistent with all the details
we've seen of the two crashes we've seen.

More specifically here's what we suspect happened:

Case 1:
  netxen_process_rcv_ring()
    netxen_process_rcv() on buffer X (correctly)
      list_add_tail(buffer X, sds_ring free list)

    netxen_process_rcv() on buffer Y (correctly)
      list_add_tail(buffer Y, sds_ring free list)

    netxen_process_rcv() on buffer X            <- wrong index
      list_add_tail(buffer X, sds_ring free list) <- list corrupted

    netxen_merge_rx_buffers()
      list_splice() sds_ring free list to rds_ring free_list

    netxen_post_rx_buffers_nodb()
      BUG on list_del() due to bad prev pointer in buffer X

Case 2:
  CPU0                      CPU1
  netxen_process_rcv_list() on sds_ring A
    netxen_process_rcv() on buffer X (correctly)
    list_add_tail(buffer X, sds_ring A free_list)

                            netxen_process_rcv_list() on sds_ring B
                              netxen_process_rcv() buffer X   <- wrong
                              list_add_tail(buffer X, sds_ring B list)
                            [...]
                              netxen_post_rx_buffers_nodb()
                                list_del(buffer X)   <- buf X poisoned

    for_each on sds_ring A free list <- crash due to dereferencing
                                        poisoned pointers in buffer X

Because the bug is triggered very rarely, and we have no known
reproducer, it's difficult to pin down exactly what's going wrong.
This patch tries to improve the situation by adding some (fairly cheap)
sanity checks when we process an Rx buffer to make sure it's not
already on someone's free list.

Signed-off-by: David Gibson <david@gibson.dropbear.id.au>
---
 .../net/ethernet/qlogic/netxen/netxen_nic_init.c   | 37 ++++++++++++++++++++++
 1 file changed, 37 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
index 68658b8..edbdf4b 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
@@ -1531,6 +1531,39 @@ no_skb:
 	return skb;
 }
 
+static int netxen_check_rx_buf(int index, struct netxen_rx_buffer *rxbuf)
+{
+	int ret = 0;
+
+	if ((rxbuf->list.next != LIST_POISON1)
+	    || (rxbuf->list.prev != LIST_POISON2)) {
+		printk(KERN_ERR "netxen: Rx buffer is already on free list "
+		       "(next=%p, prev=%p)\n", rxbuf->list.next,
+		       rxbuf->list.prev);
+		ret = -1;
+	}
+
+	if (rxbuf->ref_handle != index) {
+		printk(KERN_ERR "netxen: Rx buffer has bad ref_handle "
+		       "(%d instead of %d)\n", rxbuf->ref_handle, index);
+		ret = -1;
+	}
+
+	if (rxbuf->state != NETXEN_BUFFER_BUSY) {
+		printk(KERN_ERR "netxen: Rx buffer has bad state %d\n",
+		       rxbuf->state);
+		ret = -1;
+	}
+
+	if (!rxbuf->skb) {
+		printk(KERN_ERR "netxen: Rx buffer has no skb\n",
+		       rxbuf->skb);
+		ret = -1;
+	}
+
+	return ret;
+}
+
 static struct netxen_rx_buffer *
 netxen_process_rcv(struct netxen_adapter *adapter,
 		struct nx_host_sds_ring *sds_ring,
@@ -1553,6 +1586,8 @@ netxen_process_rcv(struct netxen_adapter *adapter,
 		return NULL;
 
 	buffer = &rds_ring->rx_buf_arr[index];
+	if (WARN_ON(netxen_check_rx_buf(index, buffer) != 0))
+		return NULL;
 
 	length = netxen_get_sts_totallength(sts_data0);
 	cksum  = netxen_get_sts_status(sts_data0);
@@ -1614,6 +1649,8 @@ netxen_process_lro(struct netxen_adapter *adapter,
 		return NULL;
 
 	buffer = &rds_ring->rx_buf_arr[index];
+	if (WARN_ON(netxen_check_rx_buf(index, buffer) != 0))
+		return NULL;
 
 	timestamp = netxen_get_lro_sts_timestamp(sts_data0);
 	lro_length = netxen_get_lro_sts_length(sts_data0);
-- 
1.8.3.1
