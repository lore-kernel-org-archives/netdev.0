From: Santiago Leon <santil@us.ibm.com>
Subject: [PATCH 5/5] ibmveth: fix int rollover panic
Date: Tue, 03 Oct 2006 12:24:45 -0500
Message-ID: <20061003172445.14851.34984.sendpatchset@ltcml8p1.rchland.ibm.com>
References: <20061003172417.14851.63625.sendpatchset@ltcml8p1.rchland.ibm.com>
Cc: Santiago Leon <santil@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:1200 "EHLO e31.co.us.ibm.com")
	by vger.kernel.org with ESMTP id S1030455AbWJCS1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2006 14:27:33 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k93IRXVI018260
	for <netdev@vger.kernel.org>; Tue, 3 Oct 2006 14:27:33 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k93IRXxa320260
	for <netdev@vger.kernel.org>; Tue, 3 Oct 2006 12:27:33 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k93IRWQh027735
	for <netdev@vger.kernel.org>; Tue, 3 Oct 2006 12:27:33 -0600
To: netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20061003172417.14851.63625.sendpatchset@ltcml8p1.rchland.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santiago Leon <santil@us.ibm.com>

This patch fixes a nasty bug that has been sitting there since the very first versions of the driver, but is generating a panic because we changed the number of 2K buffers for 2.6.16.

The consumer_index and producer_index are u32's that get incremented on every buffer emptied and replenished respectively.  We use the {producer,consumer}_index mod'ed with the size of the pool to pick out an entry in the free_map.  The problem happens when the u32 rolls over and the number of the buffers in the pool is not a perfect divisor of 2^32.  i.e. if the number of 2K buffers is 0x300, before the consumer_index rolls over,  our index to the free map = 0xffffffff mod 0x300 = 0xff.  The next time a buffer is emptied, we want the index to the free map to be 0x100, but 0x0 mod 0x300 is 0x0.

This patch assigns the mod'ed result back to the consumer and producer indexes so that they never roll over.  The second chunk of the patch covers the unlikely case where the consumer_index has just been reset to 0x0 and the hypervisor is not able to accept that buffer.

Signed-off-by: Santiago Leon <santil@us.ibm.com>
---
 drivers/net/ibmveth.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -213,6 +213,7 @@ static void ibmveth_replenish_buffer_poo
 		}
 
 		free_index = pool->consumer_index++ % pool->size;
+		pool->consumer_index = free_index;
 		index = pool->free_map[free_index];
 
 		ibmveth_assert(index != IBM_VETH_INVALID_MAP);
@@ -238,7 +239,10 @@ static void ibmveth_replenish_buffer_poo
 		if(lpar_rc != H_SUCCESS) {
 			pool->free_map[free_index] = index;
 			pool->skbuff[index] = NULL;
-			pool->consumer_index--;
+			if (pool->consumer_index == 0)
+				pool->consumer_index = pool->size - 1;
+			else
+				pool->consumer_index--;
 			dma_unmap_single(&adapter->vdev->dev,
 					pool->dma_addr[index], pool->buff_size,
 					DMA_FROM_DEVICE);
@@ -326,6 +330,7 @@ static void ibmveth_remove_buffer_from_p
 			 DMA_FROM_DEVICE);
 
 	free_index = adapter->rx_buff_pool[pool].producer_index++ % adapter->rx_buff_pool[pool].size;
+	adapter->rx_buff_pool[pool].producer_index = free_index;
 	adapter->rx_buff_pool[pool].free_map[free_index] = index;
 
 	mb();
