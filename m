From: Honggang Li <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH linux-next v2] mlx5: wrong page mask if CONFIG_ARCH_DMA_ADDR_T_64BIT enabled for 32Bit architectures
Date: Mon, 13 Apr 2015 17:21:58 +0800
Message-ID: <1428916918-24404-1-git-send-email-honli@redhat.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Honggang Li <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

If CONFIG_ARCH_DMA_ADDR_T_64BIT enabled for x86 systems and physical
memory is more than 4GB, dma_map_page may return a valid memory
address which greater than 0xffffffff. As a result, the mlx5 device page
allocator RB tree will be initialized with valid addresses greater than
0xfffffff.

However, (addr & PAGE_MASK) set the high four bytes to zeros. So, it's
impossible for the function, free_4k, to release the pages whose
addresses greater than 4GB. Memory leaks. And mlx5_ib module can't
release the pages when user try to remove the module, as a result,
system hang.

[root@rdma05 root]# dmesg  | grep addr | head
addr             = 3fe384000
addr & PAGE_MASK =  fe384000
[root@rdma05 root]# rmmod mlx5_ib   <---- hang on

---------------------- cosnole log -----------------
mlx5_ib 0000:04:00.0: irq 138 for MSI/MSI-X
  alloc irq_desc for 139 on node -1
  alloc kstat_irqs on node -1
mlx5_ib 0000:04:00.0: irq 139 for MSI/MSI-X
0000:04:00.0:free_4k:221:(pid 1519): page not found
0000:04:00.0:free_4k:221:(pid 1519): page not found
0000:04:00.0:free_4k:221:(pid 1519): page not found
0000:04:00.0:free_4k:221:(pid 1519): page not found
---------------------- cosnole log -----------------

Signed-off-by: Honggang Li <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
index df22383..595b507 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
@@ -211,26 +211,28 @@ static int alloc_4k(struct mlx5_core_dev *dev, u64 *addr)
 	return 0;
 }
 
+#define MLX5_U64_4K_PAGE_MASK ((~(u64)0U) << PAGE_SHIFT)
+
 static void free_4k(struct mlx5_core_dev *dev, u64 addr)
 {
 	struct fw_page *fwp;
 	int n;
 
-	fwp = find_fw_page(dev, addr & PAGE_MASK);
+	fwp = find_fw_page(dev, addr & MLX5_U64_4K_PAGE_MASK);
 	if (!fwp) {
 		mlx5_core_warn(dev, "page not found\n");
 		return;
 	}
 
-	n = (addr & ~PAGE_MASK) >> MLX5_ADAPTER_PAGE_SHIFT;
+	n = (addr & ~MLX5_U64_4K_PAGE_MASK) >> MLX5_ADAPTER_PAGE_SHIFT;
 	fwp->free_count++;
 	set_bit(n, &fwp->bitmask);
 	if (fwp->free_count == MLX5_NUM_4K_IN_PAGE) {
 		rb_erase(&fwp->rb_node, &dev->priv.page_root);
 		if (fwp->free_count != 1)
 			list_del(&fwp->list);
-		dma_unmap_page(&dev->pdev->dev, addr & PAGE_MASK, PAGE_SIZE,
-			       DMA_BIDIRECTIONAL);
+		dma_unmap_page(&dev->pdev->dev, addr & MLX5_U64_4K_PAGE_MASK,
+			       PAGE_SIZE, DMA_BIDIRECTIONAL);
 		__free_page(fwp->page);
 		kfree(fwp);
 	} else if (fwp->free_count == 1) {
@@ -241,7 +243,7 @@ static void free_4k(struct mlx5_core_dev *dev, u64 addr)
 static int alloc_system_page(struct mlx5_core_dev *dev, u16 func_id)
 {
 	struct page *page;
-	u64 addr;
+	u64 addr = 0;
 	int err;
 	int nid = dev_to_node(&dev->pdev->dev);
 
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
