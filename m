From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Tue, 18 Aug 2015 14:25:06 -0700 (PDT)
Message-ID: <20150818.142506.1284308583301450628.davem@davemloft.net>
References: <20150818183917.457b2586@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, _govind@gmx.com, nalreddy@cisco.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20150818183917.457b2586@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 18 Aug 2015 18:39:17 +1000

> drivers/net/built-in.o: In function `.vnic_wq_devcmd2_alloc':
> (.text+0x49fe40): multiple definition of `.vnic_wq_devcmd2_alloc'
> drivers/scsi/built-in.o:(.text+0xb4318): first defined here
> drivers/net/built-in.o:(.opd+0x2af00): multiple definition of `vnic_wq_devcmd2_alloc'
> drivers/scsi/built-in.o:(.opd+0xad70): first defined here
> drivers/net/built-in.o: In function `.vnic_wq_init_start':
> (.text+0x49f9c0): multiple definition of `.vnic_wq_init_start'
> drivers/scsi/built-in.o:(.text+0xb3b58): first defined here
> drivers/net/built-in.o:(.opd+0x2ae88): multiple definition of `vnic_wq_init_start'
> drivers/scsi/built-in.o:(.opd+0xace0): first defined here

I've committed the following to fix this:

====================
[PATCH] enic: Fix namespace pollution causing build errors.

drivers/net/built-in.o: In function `.vnic_wq_devcmd2_alloc':
(.text+0x49fe40): multiple definition of `.vnic_wq_devcmd2_alloc'
drivers/scsi/built-in.o:(.text+0xb4318): first defined here
drivers/net/built-in.o:(.opd+0x2af00): multiple definition of `vnic_wq_devcmd2_alloc'
drivers/scsi/built-in.o:(.opd+0xad70): first defined here
drivers/net/built-in.o: In function `.vnic_wq_init_start':
(.text+0x49f9c0): multiple definition of `.vnic_wq_init_start'
drivers/scsi/built-in.o:(.text+0xb3b58): first defined here
drivers/net/built-in.o:(.opd+0x2ae88): multiple definition of `vnic_wq_init_start'
drivers/scsi/built-in.o:(.opd+0xace0): first defined here

Rename these to 'enic_*' to avoid the conflict with the functiosn of
the same name in the snic scsi driver.

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/cisco/enic/vnic_dev.c | 4 ++--
 drivers/net/ethernet/cisco/enic/vnic_wq.c  | 6 +++---
 drivers/net/ethernet/cisco/enic/vnic_wq.h  | 4 ++--
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.c b/drivers/net/ethernet/cisco/enic/vnic_dev.c
index 9f6c641..19a49a6 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_dev.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_dev.c
@@ -388,7 +388,7 @@ static int vnic_dev_init_devcmd2(struct vnic_dev *vdev)
 
 	vdev->devcmd2->color = 1;
 	vdev->devcmd2->result_size = DEVCMD2_RING_SIZE;
-	err = vnic_wq_devcmd2_alloc(vdev, &vdev->devcmd2->wq, DEVCMD2_RING_SIZE,
+	err = enic_wq_devcmd2_alloc(vdev, &vdev->devcmd2->wq, DEVCMD2_RING_SIZE,
 				    DEVCMD2_DESC_SIZE);
 	if (err)
 		goto err_free_devcmd2;
@@ -400,7 +400,7 @@ static int vnic_dev_init_devcmd2(struct vnic_dev *vdev)
 		return -ENODEV;
 	}
 
-	vnic_wq_init_start(&vdev->devcmd2->wq, 0, fetch_index, fetch_index, 0,
+	enic_wq_init_start(&vdev->devcmd2->wq, 0, fetch_index, fetch_index, 0,
 			   0);
 	vnic_wq_enable(&vdev->devcmd2->wq);
 
diff --git a/drivers/net/ethernet/cisco/enic/vnic_wq.c b/drivers/net/ethernet/cisco/enic/vnic_wq.c
index 627f3b1..05ad16a 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_wq.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_wq.c
@@ -114,7 +114,7 @@ int vnic_wq_alloc(struct vnic_dev *vdev, struct vnic_wq *wq, unsigned int index,
 	return 0;
 }
 
-int vnic_wq_devcmd2_alloc(struct vnic_dev *vdev, struct vnic_wq *wq,
+int enic_wq_devcmd2_alloc(struct vnic_dev *vdev, struct vnic_wq *wq,
 			  unsigned int desc_count, unsigned int desc_size)
 {
 	int err;
@@ -131,7 +131,7 @@ int vnic_wq_devcmd2_alloc(struct vnic_dev *vdev, struct vnic_wq *wq,
 	return err;
 }
 
-void vnic_wq_init_start(struct vnic_wq *wq, unsigned int cq_index,
+void enic_wq_init_start(struct vnic_wq *wq, unsigned int cq_index,
 			unsigned int fetch_index, unsigned int posted_index,
 			unsigned int error_interrupt_enable,
 			unsigned int error_interrupt_offset)
@@ -158,7 +158,7 @@ void vnic_wq_init(struct vnic_wq *wq, unsigned int cq_index,
 	unsigned int error_interrupt_enable,
 	unsigned int error_interrupt_offset)
 {
-	vnic_wq_init_start(wq, cq_index, 0, 0,
+	enic_wq_init_start(wq, cq_index, 0, 0,
 		error_interrupt_enable,
 		error_interrupt_offset);
 }
diff --git a/drivers/net/ethernet/cisco/enic/vnic_wq.h b/drivers/net/ethernet/cisco/enic/vnic_wq.h
index c9b25d3..8944af9 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_wq.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_wq.h
@@ -185,9 +185,9 @@ void vnic_wq_enable(struct vnic_wq *wq);
 int vnic_wq_disable(struct vnic_wq *wq);
 void vnic_wq_clean(struct vnic_wq *wq,
 	void (*buf_clean)(struct vnic_wq *wq, struct vnic_wq_buf *buf));
-int vnic_wq_devcmd2_alloc(struct vnic_dev *vdev, struct vnic_wq *wq,
+int enic_wq_devcmd2_alloc(struct vnic_dev *vdev, struct vnic_wq *wq,
 			  unsigned int desc_count, unsigned int desc_size);
-void vnic_wq_init_start(struct vnic_wq *wq, unsigned int cq_index,
+void enic_wq_init_start(struct vnic_wq *wq, unsigned int cq_index,
 			unsigned int fetch_index, unsigned int posted_index,
 			unsigned int error_interrupt_enable,
 			unsigned int error_interrupt_offset);
-- 
2.1.0
