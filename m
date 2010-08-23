From: Anton Blanchard <anton@samba.org>
Subject: [patch 08/20] ibmveth: Dont overallocate buffers
Date: Mon, 23 Aug 2010 10:09:38 +1000
Message-ID: <20100823001239.041525926@samba.org>
References: <20100823000930.546065833@samba.org>
Cc: netdev@vger.kernel.org
To: brking@linux.vnet.ibm.com, santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51826 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751673Ab0HWA2M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Aug 2010 20:28:12 -0400
Content-Disposition: inline; filename=veth_page_4k
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We were allocating a page, even though we always want 4k. Use kmalloc
instead of get_zeroed_page.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig/drivers/net/ibmveth.c	2010-08-23 08:52:30.633730198 +1000
+++ net-next-2.6/drivers/net/ibmveth.c	2010-08-23 08:52:31.003703934 +1000
@@ -473,7 +473,7 @@ static void ibmveth_cleanup(struct ibmve
 					DMA_BIDIRECTIONAL);
 			adapter->buffer_list_dma = DMA_ERROR_CODE;
 		}
-		free_page((unsigned long)adapter->buffer_list_addr);
+		kfree(adapter->buffer_list_addr);
 		adapter->buffer_list_addr = NULL;
 	}
 
@@ -483,7 +483,7 @@ static void ibmveth_cleanup(struct ibmve
 					DMA_BIDIRECTIONAL);
 			adapter->filter_list_dma = DMA_ERROR_CODE;
 		}
-		free_page((unsigned long)adapter->filter_list_addr);
+		kfree(adapter->filter_list_addr);
 		adapter->filter_list_addr = NULL;
 	}
 
@@ -560,8 +560,8 @@ static int ibmveth_open(struct net_devic
 	for(i = 0; i<IbmVethNumBufferPools; i++)
 		rxq_entries += adapter->rx_buff_pool[i].size;
 
-	adapter->buffer_list_addr = (void*) get_zeroed_page(GFP_KERNEL);
-	adapter->filter_list_addr = (void*) get_zeroed_page(GFP_KERNEL);
+	adapter->buffer_list_addr = kzalloc(4096, GFP_KERNEL);
+	adapter->filter_list_addr = kzalloc(4096, GFP_KERNEL);
 
 	if(!adapter->buffer_list_addr || !adapter->filter_list_addr) {
 		ibmveth_error_printk("unable to allocate filter or buffer list pages\n");


