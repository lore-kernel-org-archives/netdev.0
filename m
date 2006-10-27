From: "Steve Wise" <swise@opengridcomputing.com>
Subject: [PATCH 2.6.19-rc3 1/2] amso1100 - Use
 dma_alloc_coherent instead of kmalloc/dma_map_single.
Date: Fri, 27 Oct 2006 15:58:19 -0500
Message-ID: <20061027205819.8511.85102.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: rdreier@cisco.com
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org


The Ammasso driver needs to use dma_alloc_coherent() for 
allocating memory that will be used by the HW for dma.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/amso1100/c2_alloc.c |   13 +++----
 drivers/infiniband/hw/amso1100/c2_cq.c    |   14 ++------
 drivers/infiniband/hw/amso1100/c2_rnic.c  |   52 ++++++++++++-----------------
 3 files changed, 31 insertions(+), 48 deletions(-)

diff --git a/drivers/infiniband/hw/amso1100/c2_alloc.c b/drivers/infiniband/hw/amso1100/c2_alloc.c
index 028a60b..1d30ef7 100644
--- a/drivers/infiniband/hw/amso1100/c2_alloc.c
+++ b/drivers/infiniband/hw/amso1100/c2_alloc.c
@@ -42,13 +42,14 @@ static int c2_alloc_mqsp_chunk(struct c2
 {
 	int i;
 	struct sp_chunk *new_head;
+	dma_addr_t dma_addr;
 
-	new_head = (struct sp_chunk *) __get_free_page(gfp_mask);
+	new_head = dma_alloc_coherent(&c2dev->pcidev->dev, PAGE_SIZE, 
+				      &dma_addr, gfp_mask); 
 	if (new_head == NULL)
 		return -ENOMEM;
 
-	new_head->dma_addr = dma_map_single(c2dev->ibdev.dma_device, new_head,
-					    PAGE_SIZE, DMA_FROM_DEVICE);
+	new_head->dma_addr = dma_addr;
 	pci_unmap_addr_set(new_head, mapping, new_head->dma_addr);
 
 	new_head->next = NULL;
@@ -80,10 +81,8 @@ void c2_free_mqsp_pool(struct c2_dev *c2
 
 	while (root) {
 		next = root->next;
-		dma_unmap_single(c2dev->ibdev.dma_device,
-				 pci_unmap_addr(root, mapping), PAGE_SIZE,
-			         DMA_FROM_DEVICE);
-		__free_page((struct page *) root);
+		dma_free_coherent(&c2dev->pcidev->dev, PAGE_SIZE, root, 
+				  pci_unmap_addr(root, mapping));
 		root = next;
 	}
 }
diff --git a/drivers/infiniband/hw/amso1100/c2_cq.c b/drivers/infiniband/hw/amso1100/c2_cq.c
index 9d7bcc5..9b7af81 100644
--- a/drivers/infiniband/hw/amso1100/c2_cq.c
+++ b/drivers/infiniband/hw/amso1100/c2_cq.c
@@ -246,11 +246,8 @@ int c2_arm_cq(struct ib_cq *ibcq, enum i
 
 static void c2_free_cq_buf(struct c2_dev *c2dev, struct c2_mq *mq)
 {
-
-	dma_unmap_single(c2dev->ibdev.dma_device, pci_unmap_addr(mq, mapping),
-			 mq->q_size * mq->msg_size, DMA_FROM_DEVICE);
-	free_pages((unsigned long) mq->msg_pool.host,
-		   get_order(mq->q_size * mq->msg_size));
+	dma_free_coherent(&c2dev->pcidev->dev, mq->q_size * mq->msg_size,
+			  mq->msg_pool.host, pci_unmap_addr(mq, mapping));
 }
 
 static int c2_alloc_cq_buf(struct c2_dev *c2dev, struct c2_mq *mq, int q_size,
@@ -258,8 +255,8 @@ static int c2_alloc_cq_buf(struct c2_dev
 {
 	unsigned long pool_start;
 
-	pool_start = __get_free_pages(GFP_KERNEL,
-				      get_order(q_size * msg_size));
+	pool_start = dma_alloc_coherent(&c2dev->pcidev->dev, q_size * msg_size,
+					&mq->host_dma, GFP_KERNEL);
 	if (!pool_start)
 		return -ENOMEM;
 
@@ -271,9 +268,6 @@ static int c2_alloc_cq_buf(struct c2_dev
 		       NULL,	/* peer (currently unknown) */
 		       C2_MQ_HOST_TARGET);
 
-	mq->host_dma = dma_map_single(c2dev->ibdev.dma_device,
-				      (void *)pool_start,
-				      q_size * msg_size, DMA_FROM_DEVICE);
 	pci_unmap_addr_set(mq, mapping, mq->host_dma);
 
 	return 0;
diff --git a/drivers/infiniband/hw/amso1100/c2_rnic.c b/drivers/infiniband/hw/amso1100/c2_rnic.c
index 30409e1..6d82464 100644
--- a/drivers/infiniband/hw/amso1100/c2_rnic.c
+++ b/drivers/infiniband/hw/amso1100/c2_rnic.c
@@ -517,14 +517,12 @@ int c2_rnic_init(struct c2_dev *c2dev)
 	/* Initialize the Verbs Reply Queue */
 	qsize = be32_to_cpu(readl(mmio_regs + C2_REGS_Q1_QSIZE));
 	msgsize = be32_to_cpu(readl(mmio_regs + C2_REGS_Q1_MSGSIZE));
-	q1_pages = kmalloc(qsize * msgsize, GFP_KERNEL);
+	q1_pages = dma_alloc_coherent(&c2dev->pcidev->dev, qsize * msgsize,
+				      &c2dev->rep_vq.host_dma, GFP_KERNEL);
 	if (!q1_pages) {
 		err = -ENOMEM;
 		goto bail1;
 	}
-	c2dev->rep_vq.host_dma = dma_map_single(c2dev->ibdev.dma_device,
-					        (void *)q1_pages, qsize * msgsize,
-				      		DMA_FROM_DEVICE);
 	pci_unmap_addr_set(&c2dev->rep_vq, mapping, c2dev->rep_vq.host_dma);
 	pr_debug("%s rep_vq va %p dma %llx\n", __FUNCTION__, q1_pages,
 		 (unsigned long long) c2dev->rep_vq.host_dma);
@@ -540,14 +538,12 @@ int c2_rnic_init(struct c2_dev *c2dev)
 	/* Initialize the Asynchronus Event Queue */
 	qsize = be32_to_cpu(readl(mmio_regs + C2_REGS_Q2_QSIZE));
 	msgsize = be32_to_cpu(readl(mmio_regs + C2_REGS_Q2_MSGSIZE));
-	q2_pages = kmalloc(qsize * msgsize, GFP_KERNEL);
+	q2_pages = dma_alloc_coherent(&c2dev->pcidev->dev, qsize * msgsize,
+				      &c2dev->aeq.host_dma, GFP_KERNEL);
 	if (!q2_pages) {
 		err = -ENOMEM;
 		goto bail2;
 	}
-	c2dev->aeq.host_dma = dma_map_single(c2dev->ibdev.dma_device,
-					        (void *)q2_pages, qsize * msgsize,
-				      		DMA_FROM_DEVICE);
 	pci_unmap_addr_set(&c2dev->aeq, mapping, c2dev->aeq.host_dma);
 	pr_debug("%s aeq va %p dma %llx\n", __FUNCTION__, q1_pages,
 		 (unsigned long long) c2dev->rep_vq.host_dma);
@@ -597,17 +593,13 @@ int c2_rnic_init(struct c2_dev *c2dev)
       bail4:
 	vq_term(c2dev);
       bail3:
-	dma_unmap_single(c2dev->ibdev.dma_device,
-			 pci_unmap_addr(&c2dev->aeq, mapping),
-			 c2dev->aeq.q_size * c2dev->aeq.msg_size,
-		  	 DMA_FROM_DEVICE);
-	kfree(q2_pages);
+	dma_free_coherent(&c2dev->pcidev->dev, 
+			  c2dev->aeq.q_size * c2dev->aeq.msg_size,
+			  q2_pages, pci_unmap_addr(&c2dev->aeq, mapping));
       bail2:
-	dma_unmap_single(c2dev->ibdev.dma_device,
-			 pci_unmap_addr(&c2dev->rep_vq, mapping),
-			 c2dev->rep_vq.q_size * c2dev->rep_vq.msg_size,
-		  	 DMA_FROM_DEVICE);
-	kfree(q1_pages);
+	dma_free_coherent(&c2dev->pcidev->dev, 
+			  c2dev->rep_vq.q_size * c2dev->rep_vq.msg_size,
+			  q1_pages, pci_unmap_addr(&c2dev->rep_vq, mapping));
       bail1:
 	c2_free_mqsp_pool(c2dev, c2dev->kern_mqsp_pool);
       bail0:
@@ -640,19 +632,17 @@ void c2_rnic_term(struct c2_dev *c2dev)
 	/* Free the verbs request allocator */
 	vq_term(c2dev);
 
-	/* Unmap and free the asynchronus event queue */
-	dma_unmap_single(c2dev->ibdev.dma_device,
-			 pci_unmap_addr(&c2dev->aeq, mapping),
-			 c2dev->aeq.q_size * c2dev->aeq.msg_size,
-		  	 DMA_FROM_DEVICE);
-	kfree(c2dev->aeq.msg_pool.host);
-
-	/* Unmap and free the verbs reply queue */
-	dma_unmap_single(c2dev->ibdev.dma_device,
-			 pci_unmap_addr(&c2dev->rep_vq, mapping),
-			 c2dev->rep_vq.q_size * c2dev->rep_vq.msg_size,
-		  	 DMA_FROM_DEVICE);
-	kfree(c2dev->rep_vq.msg_pool.host);
+	/* Free the asynchronus event queue */
+	dma_free_coherent(&c2dev->pcidev->dev, 
+			  c2dev->aeq.q_size * c2dev->aeq.msg_size,
+			  c2dev->aeq.msg_pool.host,
+			  pci_unmap_addr(&c2dev->aeq, mapping));
+
+	/* Free the verbs reply queue */
+	dma_free_coherent(&c2dev->pcidev->dev, 
+			  c2dev->rep_vq.q_size * c2dev->rep_vq.msg_size,
+			  c2dev->rep_vq.msg_pool.host,
+			  pci_unmap_addr(&c2dev->rep_vq, mapping));
 
 	/* Free the MQ shared pointer pool */
 	c2_free_mqsp_pool(c2dev, c2dev->kern_mqsp_pool);
