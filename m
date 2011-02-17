From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 4/4] ixgbe: work around for DDP last buffer size
Date: Thu, 17 Feb 2011 01:35:10 -0800
Message-ID: <1297935310-23510-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1297935310-23510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Amir Hanania <amir.hanania@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:45687 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754063Ab1BQJfS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Feb 2011 04:35:18 -0500
In-Reply-To: <1297935310-23510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Hanania <amir.hanania@intel.com>

A HW limitation was recently discovered where the last buffer in a DDP offload
cannot be a full buffer size in length. Fix the issue with a work around by
adding another buffer with size = 1.

Signed-off-by: Amir Hanania <amir.hanania@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_fcoe.c |   51 +++++++++++++++++++++++++++++++++++++++-
 drivers/net/ixgbe/ixgbe_fcoe.h |    2 +
 2 files changed, 52 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index 8753980..c54a882 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -159,7 +159,7 @@ int ixgbe_fcoe_ddp_get(struct net_device *netdev, u16 xid,
 	struct scatterlist *sg;
 	unsigned int i, j, dmacount;
 	unsigned int len;
-	static const unsigned int bufflen = 4096;
+	static const unsigned int bufflen = IXGBE_FCBUFF_MIN;
 	unsigned int firstoff = 0;
 	unsigned int lastsize;
 	unsigned int thisoff = 0;
@@ -254,6 +254,24 @@ int ixgbe_fcoe_ddp_get(struct net_device *netdev, u16 xid,
 	/* only the last buffer may have non-full bufflen */
 	lastsize = thisoff + thislen;
 
+	/*
+	 * lastsize can not be buffer len.
+	 * If it is then adding another buffer with lastsize = 1.
+	 */
+	if (lastsize == bufflen) {
+		if (j >= IXGBE_BUFFCNT_MAX) {
+			e_err(drv, "xid=%x:%d,%d,%d:addr=%llx "
+				"not enough user buffers. We need an extra "
+				"buffer because lastsize is bufflen.\n",
+				xid, i, j, dmacount, (u64)addr);
+			goto out_noddp_free;
+		}
+
+		ddp->udl[j] = (u64)(fcoe->extra_ddp_buffer_dma);
+		j++;
+		lastsize = 1;
+	}
+
 	fcbuff = (IXGBE_FCBUFF_4KB << IXGBE_FCBUFF_BUFFSIZE_SHIFT);
 	fcbuff |= ((j & 0xff) << IXGBE_FCBUFF_BUFFCNT_SHIFT);
 	fcbuff |= (firstoff << IXGBE_FCBUFF_OFFSET_SHIFT);
@@ -532,6 +550,24 @@ void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter)
 			e_err(drv, "failed to allocated FCoE DDP pool\n");
 
 		spin_lock_init(&fcoe->lock);
+
+		/* Extra buffer to be shared by all DDPs for HW work around */
+		fcoe->extra_ddp_buffer = kmalloc(IXGBE_FCBUFF_MIN, GFP_ATOMIC);
+		if (fcoe->extra_ddp_buffer == NULL) {
+			e_err(drv, "failed to allocated extra DDP buffer\n");
+			goto out_extra_ddp_buffer_alloc;
+		}
+
+		fcoe->extra_ddp_buffer_dma =
+			dma_map_single(&adapter->pdev->dev,
+				       fcoe->extra_ddp_buffer,
+				       IXGBE_FCBUFF_MIN,
+				       DMA_FROM_DEVICE);
+		if (dma_mapping_error(&adapter->pdev->dev,
+				      fcoe->extra_ddp_buffer_dma)) {
+			e_err(drv, "failed to map extra DDP buffer\n");
+			goto out_extra_ddp_buffer_dma;
+		}
 	}
 
 	/* Enable L2 eth type filter for FCoE */
@@ -581,6 +617,14 @@ void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter)
 		}
 	}
 #endif
+
+	return;
+
+out_extra_ddp_buffer_dma:
+	kfree(fcoe->extra_ddp_buffer);
+out_extra_ddp_buffer_alloc:
+	pci_pool_destroy(fcoe->pool);
+	fcoe->pool = NULL;
 }
 
 /**
@@ -600,6 +644,11 @@ void ixgbe_cleanup_fcoe(struct ixgbe_adapter *adapter)
 	if (fcoe->pool) {
 		for (i = 0; i < IXGBE_FCOE_DDP_MAX; i++)
 			ixgbe_fcoe_ddp_put(adapter->netdev, i);
+		dma_unmap_single(&adapter->pdev->dev,
+				 fcoe->extra_ddp_buffer_dma,
+				 IXGBE_FCBUFF_MIN,
+				 DMA_FROM_DEVICE);
+		kfree(fcoe->extra_ddp_buffer);
 		pci_pool_destroy(fcoe->pool);
 		fcoe->pool = NULL;
 	}
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.h b/drivers/net/ixgbe/ixgbe_fcoe.h
index 4bc2c55..65cc8fb 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.h
+++ b/drivers/net/ixgbe/ixgbe_fcoe.h
@@ -70,6 +70,8 @@ struct ixgbe_fcoe {
 	spinlock_t lock;
 	struct pci_pool *pool;
 	struct ixgbe_fcoe_ddp ddp[IXGBE_FCOE_DDP_MAX];
+	unsigned char *extra_ddp_buffer;
+	dma_addr_t extra_ddp_buffer_dma;
 };
 
 #endif /* _IXGBE_FCOE_H */
-- 
1.7.4

