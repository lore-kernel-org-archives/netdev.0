From: Scott Feldman <scofeldm@cisco.com>
Subject: [PATCH] Consolidate shared code between enic and fnic drivers.
Date: Wed, 17 Jun 2009 22:05:04 -0700
Message-ID: <20090618050502.30610.69142.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: michaelc@cs.wisc.edu, gospo@redhat.com, abjoglek@cisco.com,
	jeykholt@cisco.com, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org
To: James.Bottomley@HansenPartnership.com, davem@davemloft.net
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Consolidate shared code between enic and fnic drivers.

[David/James, we need a little help with this one...this single patch
spans scsi and netdev, so we're not sure which tree/maintainer needs
to pick up the patch.  Please advise.  It's for 2.6.31.  The patch is
against linux-2.6.git.]

The Cisco enic 10G Ethernet driver and the fnic FCoE HBA driver share
much of the same hardware-access code because enic and fnic devices are
really two functions on a converged-I/O PCIe device.  This patch
consolidates the shared code into one shared module, thus eliminating
the code duplication.  No functional changes are made by the patch.

Why weren't these consolidated in the first place?  fnic went in late in
2.6.30 on the scsi branch (merge exception for new drivers), and it was
too late to modify enic which was already included in 2.6.28.

The changes are as follows:

  o a new module vnic which is shared between fnic and enic
  o vnic files reside in drivers/net/enic
  o fnic Makefile includes vnic files from drivers/net/enic

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Abhijeet Joglekar <abjoglek@cisco.com>
Signed-off-by: Joe Eykholt <jeykholt@cisco.com>
---
 drivers/net/Kconfig               |    4 
 drivers/net/enic/Makefile         |    8 
 drivers/net/enic/enic.h           |    2 
 drivers/net/enic/vnic_cq.c        |    4 
 drivers/net/enic/vnic_dev.c       |   42 ++
 drivers/net/enic/vnic_intr.c      |    4 
 drivers/net/enic/vnic_rq.c        |    8 
 drivers/net/enic/vnic_wq.c        |    7 
 drivers/scsi/Kconfig              |    1 
 drivers/scsi/fnic/Makefile        |    9 
 drivers/scsi/fnic/cq_desc.h       |   78 ----
 drivers/scsi/fnic/cq_enet_desc.h  |  167 ---------
 drivers/scsi/fnic/fnic.h          |    2 
 drivers/scsi/fnic/rq_enet_desc.h  |   58 ---
 drivers/scsi/fnic/vnic_cq.c       |   85 -----
 drivers/scsi/fnic/vnic_cq.h       |  121 ------
 drivers/scsi/fnic/vnic_dev.c      |  690 -------------------------------------
 drivers/scsi/fnic/vnic_dev.h      |  161 ---------
 drivers/scsi/fnic/vnic_devcmd.h   |  281 ---------------
 drivers/scsi/fnic/vnic_intr.c     |   60 ---
 drivers/scsi/fnic/vnic_intr.h     |  118 ------
 drivers/scsi/fnic/vnic_nic.h      |   69 ----
 drivers/scsi/fnic/vnic_resource.h |   61 ---
 drivers/scsi/fnic/vnic_rq.c       |  196 -----------
 drivers/scsi/fnic/vnic_rq.h       |  235 -------------
 drivers/scsi/fnic/vnic_stats.h    |   68 ----
 drivers/scsi/fnic/vnic_wq.c       |  182 ----------
 drivers/scsi/fnic/vnic_wq.h       |  175 ---------
 drivers/scsi/fnic/wq_enet_desc.h  |   96 -----
 29 files changed, 77 insertions(+), 2915 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 892a9e4..c3f4fc2 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2527,10 +2527,14 @@ config EHEA
 	  To compile the driver as a module, choose M here. The module
 	  will be called ehea.
 
+config CISCO_VNIC
+	tristate # No prompt here, this is a hidden option
+
 config ENIC
 	tristate "Cisco 10G Ethernet NIC support"
 	depends on PCI && INET
 	select INET_LRO
+	select CISCO_VNIC
 	help
 	  This enables the support for the Cisco 10G Ethernet card.
 
diff --git a/drivers/net/enic/Makefile b/drivers/net/enic/Makefile
index 391c3bc..d56c681 100644
--- a/drivers/net/enic/Makefile
+++ b/drivers/net/enic/Makefile
@@ -1,5 +1,5 @@
-obj-$(CONFIG_ENIC) := enic.o
-
-enic-y := enic_main.o vnic_cq.o vnic_intr.o vnic_wq.o \
-	enic_res.o vnic_dev.o vnic_rq.o
+obj-$(CONFIG_ENIC) += enic.o
+enic-y := enic_main.o enic_res.o
 
+obj-$(CONFIG_CISCO_VNIC) += vnic.o
+vnic-y := vnic_dev.o vnic_wq.o vnic_rq.o vnic_cq.o vnic_intr.o
diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index c26cea0..2c27e3d 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -33,7 +33,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco 10G Ethernet Driver"
-#define DRV_VERSION		"1.0.0.933"
+#define DRV_VERSION		"1.0.0.933-k1"
 #define DRV_COPYRIGHT		"Copyright 2008 Cisco Systems, Inc"
 #define PFX			DRV_NAME ": "
 
diff --git a/drivers/net/enic/vnic_cq.c b/drivers/net/enic/vnic_cq.c
index 020ae6c..df4c4f3 100644
--- a/drivers/net/enic/vnic_cq.c
+++ b/drivers/net/enic/vnic_cq.c
@@ -31,6 +31,7 @@ void vnic_cq_free(struct vnic_cq *cq)
 
 	cq->ctrl = NULL;
 }
+EXPORT_SYMBOL(vnic_cq_free);
 
 int vnic_cq_alloc(struct vnic_dev *vdev, struct vnic_cq *cq, unsigned int index,
 	unsigned int desc_count, unsigned int desc_size)
@@ -52,6 +53,7 @@ int vnic_cq_alloc(struct vnic_dev *vdev, struct vnic_cq *cq, unsigned int index,
 
 	return 0;
 }
+EXPORT_SYMBOL(vnic_cq_alloc);
 
 void vnic_cq_init(struct vnic_cq *cq, unsigned int flow_control_enable,
 	unsigned int color_enable, unsigned int cq_head, unsigned int cq_tail,
@@ -75,6 +77,7 @@ void vnic_cq_init(struct vnic_cq *cq, unsigned int flow_control_enable,
 	iowrite32(interrupt_offset, &cq->ctrl->interrupt_offset);
 	writeq(cq_message_addr, &cq->ctrl->cq_message_addr);
 }
+EXPORT_SYMBOL(vnic_cq_init);
 
 void vnic_cq_clean(struct vnic_cq *cq)
 {
@@ -87,3 +90,4 @@ void vnic_cq_clean(struct vnic_cq *cq)
 
 	vnic_dev_clear_desc_ring(&cq->ring);
 }
+EXPORT_SYMBOL(vnic_cq_clean);
diff --git a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
index e21b9d6..886aa50 100644
--- a/drivers/net/enic/vnic_dev.c
+++ b/drivers/net/enic/vnic_dev.c
@@ -65,6 +65,7 @@ void *vnic_dev_priv(struct vnic_dev *vdev)
 {
 	return vdev->priv;
 }
+EXPORT_SYMBOL(vnic_dev_priv);
 
 static int vnic_dev_discover_res(struct vnic_dev *vdev,
 	struct vnic_dev_bar *bar)
@@ -144,6 +145,7 @@ unsigned int vnic_dev_get_res_count(struct vnic_dev *vdev,
 {
 	return vdev->res[type].count;
 }
+EXPORT_SYMBOL(vnic_dev_get_res_count);
 
 void __iomem *vnic_dev_get_res(struct vnic_dev *vdev, enum vnic_res_type type,
 	unsigned int index)
@@ -162,6 +164,7 @@ void __iomem *vnic_dev_get_res(struct vnic_dev *vdev, enum vnic_res_type type,
 		return (char __iomem *)vdev->res[type].vaddr;
 	}
 }
+EXPORT_SYMBOL(vnic_dev_get_res);
 
 unsigned int vnic_dev_desc_ring_size(struct vnic_dev_ring *ring,
 	unsigned int desc_count, unsigned int desc_size)
@@ -189,11 +192,13 @@ unsigned int vnic_dev_desc_ring_size(struct vnic_dev_ring *ring,
 
 	return ring->size_unaligned;
 }
+EXPORT_SYMBOL(vnic_dev_desc_ring_size);
 
 void vnic_dev_clear_desc_ring(struct vnic_dev_ring *ring)
 {
 	memset(ring->descs, 0, ring->size);
 }
+EXPORT_SYMBOL(vnic_dev_clear_desc_ring);
 
 int vnic_dev_alloc_desc_ring(struct vnic_dev *vdev, struct vnic_dev_ring *ring,
 	unsigned int desc_count, unsigned int desc_size)
@@ -222,6 +227,7 @@ int vnic_dev_alloc_desc_ring(struct vnic_dev *vdev, struct vnic_dev_ring *ring,
 
 	return 0;
 }
+EXPORT_SYMBOL(vnic_dev_alloc_desc_ring);
 
 void vnic_dev_free_desc_ring(struct vnic_dev *vdev, struct vnic_dev_ring *ring)
 {
@@ -233,6 +239,7 @@ void vnic_dev_free_desc_ring(struct vnic_dev *vdev, struct vnic_dev_ring *ring)
 		ring->descs = NULL;
 	}
 }
+EXPORT_SYMBOL(vnic_dev_free_desc_ring);
 
 int vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 	u64 *a0, u64 *a1, int wait)
@@ -288,6 +295,7 @@ int vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 	printk(KERN_ERR "Timedout devcmd %d\n", _CMD_N(cmd));
 	return -ETIMEDOUT;
 }
+EXPORT_SYMBOL(vnic_dev_cmd);
 
 static int vnic_dev_capable(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd)
 {
@@ -324,6 +332,7 @@ int vnic_dev_fw_info(struct vnic_dev *vdev,
 
 	return err;
 }
+EXPORT_SYMBOL(vnic_dev_fw_info);
 
 int vnic_dev_spec(struct vnic_dev *vdev, unsigned int offset, unsigned int size,
 	void *value)
@@ -347,6 +356,7 @@ int vnic_dev_spec(struct vnic_dev *vdev, unsigned int offset, unsigned int size,
 
 	return err;
 }
+EXPORT_SYMBOL(vnic_dev_spec);
 
 int vnic_dev_stats_clear(struct vnic_dev *vdev)
 {
@@ -354,6 +364,7 @@ int vnic_dev_stats_clear(struct vnic_dev *vdev)
 	int wait = 1000;
 	return vnic_dev_cmd(vdev, CMD_STATS_CLEAR, &a0, &a1, wait);
 }
+EXPORT_SYMBOL(vnic_dev_stats_clear);
 
 int vnic_dev_stats_dump(struct vnic_dev *vdev, struct vnic_stats **stats)
 {
@@ -373,6 +384,7 @@ int vnic_dev_stats_dump(struct vnic_dev *vdev, struct vnic_stats **stats)
 
 	return vnic_dev_cmd(vdev, CMD_STATS_DUMP, &a0, &a1, wait);
 }
+EXPORT_SYMBOL(vnic_dev_stats_dump);
 
 int vnic_dev_close(struct vnic_dev *vdev)
 {
@@ -380,6 +392,7 @@ int vnic_dev_close(struct vnic_dev *vdev)
 	int wait = 1000;
 	return vnic_dev_cmd(vdev, CMD_CLOSE, &a0, &a1, wait);
 }
+EXPORT_SYMBOL(vnic_dev_close);
 
 int vnic_dev_enable(struct vnic_dev *vdev)
 {
@@ -387,6 +400,7 @@ int vnic_dev_enable(struct vnic_dev *vdev)
 	int wait = 1000;
 	return vnic_dev_cmd(vdev, CMD_ENABLE, &a0, &a1, wait);
 }
+EXPORT_SYMBOL(vnic_dev_enable);
 
 int vnic_dev_disable(struct vnic_dev *vdev)
 {
@@ -394,6 +408,7 @@ int vnic_dev_disable(struct vnic_dev *vdev)
 	int wait = 1000;
 	return vnic_dev_cmd(vdev, CMD_DISABLE, &a0, &a1, wait);
 }
+EXPORT_SYMBOL(vnic_dev_disable);
 
 int vnic_dev_open(struct vnic_dev *vdev, int arg)
 {
@@ -401,6 +416,7 @@ int vnic_dev_open(struct vnic_dev *vdev, int arg)
 	int wait = 1000;
 	return vnic_dev_cmd(vdev, CMD_OPEN, &a0, &a1, wait);
 }
+EXPORT_SYMBOL(vnic_dev_open);
 
 int vnic_dev_open_done(struct vnic_dev *vdev, int *done)
 {
@@ -418,6 +434,7 @@ int vnic_dev_open_done(struct vnic_dev *vdev, int *done)
 
 	return 0;
 }
+EXPORT_SYMBOL(vnic_dev_open_done);
 
 int vnic_dev_soft_reset(struct vnic_dev *vdev, int arg)
 {
@@ -425,6 +442,7 @@ int vnic_dev_soft_reset(struct vnic_dev *vdev, int arg)
 	int wait = 1000;
 	return vnic_dev_cmd(vdev, CMD_SOFT_RESET, &a0, &a1, wait);
 }
+EXPORT_SYMBOL(vnic_dev_soft_reset);
 
 int vnic_dev_soft_reset_done(struct vnic_dev *vdev, int *done)
 {
@@ -442,6 +460,7 @@ int vnic_dev_soft_reset_done(struct vnic_dev *vdev, int *done)
 
 	return 0;
 }
+EXPORT_SYMBOL(vnic_dev_soft_reset_done);
 
 int vnic_dev_hang_notify(struct vnic_dev *vdev)
 {
@@ -449,6 +468,7 @@ int vnic_dev_hang_notify(struct vnic_dev *vdev)
 	int wait = 1000;
 	return vnic_dev_cmd(vdev, CMD_HANG_NOTIFY, &a0, &a1, wait);
 }
+EXPORT_SYMBOL(vnic_dev_hang_notify);
 
 int vnic_dev_mac_addr(struct vnic_dev *vdev, u8 *mac_addr)
 {
@@ -468,6 +488,7 @@ int vnic_dev_mac_addr(struct vnic_dev *vdev, u8 *mac_addr)
 
 	return 0;
 }
+EXPORT_SYMBOL(vnic_dev_mac_addr);
 
 void vnic_dev_packet_filter(struct vnic_dev *vdev, int directed, int multicast,
 	int broadcast, int promisc, int allmulti)
@@ -486,6 +507,7 @@ void vnic_dev_packet_filter(struct vnic_dev *vdev, int directed, int multicast,
 	if (err)
 		printk(KERN_ERR "Can't set packet filter\n");
 }
+EXPORT_SYMBOL(vnic_dev_packet_filter);
 
 void vnic_dev_add_addr(struct vnic_dev *vdev, u8 *addr)
 {
@@ -501,6 +523,7 @@ void vnic_dev_add_addr(struct vnic_dev *vdev, u8 *addr)
 	if (err)
 		printk(KERN_ERR "Can't add addr [%pM], %d\n", addr, err);
 }
+EXPORT_SYMBOL(vnic_dev_add_addr);
 
 void vnic_dev_del_addr(struct vnic_dev *vdev, u8 *addr)
 {
@@ -516,6 +539,7 @@ void vnic_dev_del_addr(struct vnic_dev *vdev, u8 *addr)
 	if (err)
 		printk(KERN_ERR "Can't del addr [%pM], %d\n", addr, err);
 }
+EXPORT_SYMBOL(vnic_dev_del_addr);
 
 int vnic_dev_notify_set(struct vnic_dev *vdev, u16 intr)
 {
@@ -540,6 +564,7 @@ int vnic_dev_notify_set(struct vnic_dev *vdev, u16 intr)
 	vdev->notify_sz = (r == 0) ? (u32)a1 : 0;
 	return r;
 }
+EXPORT_SYMBOL(vnic_dev_notify_set);
 
 void vnic_dev_notify_unset(struct vnic_dev *vdev)
 {
@@ -553,6 +578,7 @@ void vnic_dev_notify_unset(struct vnic_dev *vdev)
 	vnic_dev_cmd(vdev, CMD_NOTIFY, &a0, &a1, wait);
 	vdev->notify_sz = 0;
 }
+EXPORT_SYMBOL(vnic_dev_notify_unset);
 
 static int vnic_dev_notify_ready(struct vnic_dev *vdev)
 {
@@ -594,6 +620,7 @@ int vnic_dev_init(struct vnic_dev *vdev, int arg)
 	}
 	return r;
 }
+EXPORT_SYMBOL(vnic_dev_init);
 
 int vnic_dev_link_status(struct vnic_dev *vdev)
 {
@@ -605,6 +632,7 @@ int vnic_dev_link_status(struct vnic_dev *vdev)
 
 	return vdev->notify_copy.link_state;
 }
+EXPORT_SYMBOL(vnic_dev_link_status);
 
 u32 vnic_dev_port_speed(struct vnic_dev *vdev)
 {
@@ -613,6 +641,7 @@ u32 vnic_dev_port_speed(struct vnic_dev *vdev)
 
 	return vdev->notify_copy.port_speed;
 }
+EXPORT_SYMBOL(vnic_dev_port_speed);
 
 u32 vnic_dev_msg_lvl(struct vnic_dev *vdev)
 {
@@ -621,6 +650,7 @@ u32 vnic_dev_msg_lvl(struct vnic_dev *vdev)
 
 	return vdev->notify_copy.msglvl;
 }
+EXPORT_SYMBOL(vnic_dev_msg_lvl);
 
 u32 vnic_dev_mtu(struct vnic_dev *vdev)
 {
@@ -629,6 +659,7 @@ u32 vnic_dev_mtu(struct vnic_dev *vdev)
 
 	return vdev->notify_copy.mtu;
 }
+EXPORT_SYMBOL(vnic_dev_mtu);
 
 u32 vnic_dev_link_down_cnt(struct vnic_dev *vdev)
 {
@@ -637,6 +668,7 @@ u32 vnic_dev_link_down_cnt(struct vnic_dev *vdev)
 
 	return vdev->notify_copy.link_down_cnt;
 }
+EXPORT_SYMBOL(vnic_dev_link_down_cnt);
 
 u32 vnic_dev_notify_status(struct vnic_dev *vdev)
 {
@@ -645,18 +677,21 @@ u32 vnic_dev_notify_status(struct vnic_dev *vdev)
 
 	return vdev->notify_copy.status;
 }
+EXPORT_SYMBOL(vnic_dev_notify_status);
 
 void vnic_dev_set_intr_mode(struct vnic_dev *vdev,
 	enum vnic_dev_intr_mode intr_mode)
 {
 	vdev->intr_mode = intr_mode;
 }
+EXPORT_SYMBOL(vnic_dev_set_intr_mode);
 
 enum vnic_dev_intr_mode vnic_dev_get_intr_mode(
 	struct vnic_dev *vdev)
 {
 	return vdev->intr_mode;
 }
+EXPORT_SYMBOL(vnic_dev_get_intr_mode);
 
 void vnic_dev_unregister(struct vnic_dev *vdev)
 {
@@ -682,6 +717,7 @@ void vnic_dev_unregister(struct vnic_dev *vdev)
 		kfree(vdev);
 	}
 }
+EXPORT_SYMBOL(vnic_dev_unregister);
 
 struct vnic_dev *vnic_dev_register(struct vnic_dev *vdev,
 	void *priv, struct pci_dev *pdev, struct vnic_dev_bar *bar)
@@ -713,5 +749,9 @@ err_out:
 	vnic_dev_unregister(vdev);
 	return NULL;
 }
+EXPORT_SYMBOL(vnic_dev_register);
 
-
+MODULE_DESCRIPTION("Cisco vNIC shared module");
+MODULE_AUTHOR("Scott Feldman <scofeldm@cisco.com>");
+MODULE_LICENSE("GPL");
+MODULE_VERSION("1.0");
diff --git a/drivers/net/enic/vnic_intr.c b/drivers/net/enic/vnic_intr.c
index ddc38f8..d9820fc 100644
--- a/drivers/net/enic/vnic_intr.c
+++ b/drivers/net/enic/vnic_intr.c
@@ -30,6 +30,7 @@ void vnic_intr_free(struct vnic_intr *intr)
 {
 	intr->ctrl = NULL;
 }
+EXPORT_SYMBOL(vnic_intr_free);
 
 int vnic_intr_alloc(struct vnic_dev *vdev, struct vnic_intr *intr,
 	unsigned int index)
@@ -46,6 +47,7 @@ int vnic_intr_alloc(struct vnic_dev *vdev, struct vnic_intr *intr,
 
 	return 0;
 }
+EXPORT_SYMBOL(vnic_intr_alloc);
 
 void vnic_intr_init(struct vnic_intr *intr, unsigned int coalescing_timer,
 	unsigned int coalescing_type, unsigned int mask_on_assertion)
@@ -55,8 +57,10 @@ void vnic_intr_init(struct vnic_intr *intr, unsigned int coalescing_timer,
 	iowrite32(mask_on_assertion, &intr->ctrl->mask_on_assertion);
 	iowrite32(0, &intr->ctrl->int_credits);
 }
+EXPORT_SYMBOL(vnic_intr_init);
 
 void vnic_intr_clean(struct vnic_intr *intr)
 {
 	iowrite32(0, &intr->ctrl->int_credits);
 }
+EXPORT_SYMBOL(vnic_intr_clean);
diff --git a/drivers/net/enic/vnic_rq.c b/drivers/net/enic/vnic_rq.c
index 9365e63..98742a3 100644
--- a/drivers/net/enic/vnic_rq.c
+++ b/drivers/net/enic/vnic_rq.c
@@ -83,6 +83,7 @@ void vnic_rq_free(struct vnic_rq *rq)
 
 	rq->ctrl = NULL;
 }
+EXPORT_SYMBOL(vnic_rq_free);
 
 int vnic_rq_alloc(struct vnic_dev *vdev, struct vnic_rq *rq, unsigned int index,
 	unsigned int desc_count, unsigned int desc_size)
@@ -112,6 +113,7 @@ int vnic_rq_alloc(struct vnic_dev *vdev, struct vnic_rq *rq, unsigned int index,
 
 	return 0;
 }
+EXPORT_SYMBOL(vnic_rq_alloc);
 
 void vnic_rq_init(struct vnic_rq *rq, unsigned int cq_index,
 	unsigned int error_interrupt_enable,
@@ -138,16 +140,19 @@ void vnic_rq_init(struct vnic_rq *rq, unsigned int cq_index,
 
 	rq->buf_index = 0;
 }
+EXPORT_SYMBOL(vnic_rq_init);
 
 unsigned int vnic_rq_error_status(struct vnic_rq *rq)
 {
 	return ioread32(&rq->ctrl->error_status);
 }
+EXPORT_SYMBOL(vnic_rq_error_status);
 
 void vnic_rq_enable(struct vnic_rq *rq)
 {
 	iowrite32(1, &rq->ctrl->enable);
 }
+EXPORT_SYMBOL(vnic_rq_enable);
 
 int vnic_rq_disable(struct vnic_rq *rq)
 {
@@ -166,6 +171,7 @@ int vnic_rq_disable(struct vnic_rq *rq)
 
 	return -ETIMEDOUT;
 }
+EXPORT_SYMBOL(vnic_rq_disable);
 
 void vnic_rq_clean(struct vnic_rq *rq,
 	void (*buf_clean)(struct vnic_rq *rq, struct vnic_rq_buf *buf))
@@ -196,4 +202,4 @@ void vnic_rq_clean(struct vnic_rq *rq,
 
 	vnic_dev_clear_desc_ring(&rq->ring);
 }
-
+EXPORT_SYMBOL(vnic_rq_clean);
diff --git a/drivers/net/enic/vnic_wq.c b/drivers/net/enic/vnic_wq.c
index a576d04..f6ef6d1 100644
--- a/drivers/net/enic/vnic_wq.c
+++ b/drivers/net/enic/vnic_wq.c
@@ -82,6 +82,7 @@ void vnic_wq_free(struct vnic_wq *wq)
 
 	wq->ctrl = NULL;
 }
+EXPORT_SYMBOL(vnic_wq_free);
 
 int vnic_wq_alloc(struct vnic_dev *vdev, struct vnic_wq *wq, unsigned int index,
 	unsigned int desc_count, unsigned int desc_size)
@@ -111,6 +112,7 @@ int vnic_wq_alloc(struct vnic_dev *vdev, struct vnic_wq *wq, unsigned int index,
 
 	return 0;
 }
+EXPORT_SYMBOL(vnic_wq_alloc);
 
 void vnic_wq_init(struct vnic_wq *wq, unsigned int cq_index,
 	unsigned int error_interrupt_enable,
@@ -128,16 +130,19 @@ void vnic_wq_init(struct vnic_wq *wq, unsigned int cq_index,
 	iowrite32(error_interrupt_offset, &wq->ctrl->error_interrupt_offset);
 	iowrite32(0, &wq->ctrl->error_status);
 }
+EXPORT_SYMBOL(vnic_wq_init);
 
 unsigned int vnic_wq_error_status(struct vnic_wq *wq)
 {
 	return ioread32(&wq->ctrl->error_status);
 }
+EXPORT_SYMBOL(vnic_wq_error_status);
 
 void vnic_wq_enable(struct vnic_wq *wq)
 {
 	iowrite32(1, &wq->ctrl->enable);
 }
+EXPORT_SYMBOL(vnic_wq_enable);
 
 int vnic_wq_disable(struct vnic_wq *wq)
 {
@@ -156,6 +161,7 @@ int vnic_wq_disable(struct vnic_wq *wq)
 
 	return -ETIMEDOUT;
 }
+EXPORT_SYMBOL(vnic_wq_disable);
 
 void vnic_wq_clean(struct vnic_wq *wq,
 	void (*buf_clean)(struct vnic_wq *wq, struct vnic_wq_buf *buf))
@@ -182,3 +188,4 @@ void vnic_wq_clean(struct vnic_wq *wq,
 
 	vnic_dev_clear_desc_ring(&wq->ring);
 }
+EXPORT_SYMBOL(vnic_wq_clean);
diff --git a/drivers/scsi/Kconfig b/drivers/scsi/Kconfig
index 6a19ed9..8e6a427 100644
--- a/drivers/scsi/Kconfig
+++ b/drivers/scsi/Kconfig
@@ -633,6 +633,7 @@ config FCOE_FNIC
 	tristate "Cisco FNIC Driver"
 	depends on PCI && X86
 	select LIBFC
+	select CISCO_VNIC
 	help
 	  This is support for the Cisco PCI-Express FCoE HBA.
 
diff --git a/drivers/scsi/fnic/Makefile b/drivers/scsi/fnic/Makefile
index 37c3440..155db2c 100644
--- a/drivers/scsi/fnic/Makefile
+++ b/drivers/scsi/fnic/Makefile
@@ -7,9 +7,6 @@ fnic-y	:= \
 	fnic_res.o \
 	fnic_fcs.o \
 	fnic_scsi.o \
-	vnic_cq.o \
-	vnic_dev.o \
-	vnic_intr.o \
-	vnic_rq.o \
-	vnic_wq_copy.o \
-	vnic_wq.o
+	vnic_wq_copy.o
+
+EXTRA_CFLAGS		+= -Idrivers/net/enic
diff --git a/drivers/scsi/fnic/cq_desc.h b/drivers/scsi/fnic/cq_desc.h
deleted file mode 100644
index d1225cf..0000000
--- a/drivers/scsi/fnic/cq_desc.h
+++ /dev/null
@@ -1,78 +0,0 @@
-/*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
- * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
- *
- * This program is free software; you may redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; version 2 of the License.
- *
- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
- * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
- * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
- * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
- * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
- * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
- * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
- * SOFTWARE.
- */
-#ifndef _CQ_DESC_H_
-#define _CQ_DESC_H_
-
-/*
- * Completion queue descriptor types
- */
-enum cq_desc_types {
-	CQ_DESC_TYPE_WQ_ENET = 0,
-	CQ_DESC_TYPE_DESC_COPY = 1,
-	CQ_DESC_TYPE_WQ_EXCH = 2,
-	CQ_DESC_TYPE_RQ_ENET = 3,
-	CQ_DESC_TYPE_RQ_FCP = 4,
-};
-
-/* Completion queue descriptor: 16B
- *
- * All completion queues have this basic layout.  The
- * type_specfic area is unique for each completion
- * queue type.
- */
-struct cq_desc {
-	__le16 completed_index;
-	__le16 q_number;
-	u8 type_specfic[11];
-	u8 type_color;
-};
-
-#define CQ_DESC_TYPE_BITS        4
-#define CQ_DESC_TYPE_MASK        ((1 << CQ_DESC_TYPE_BITS) - 1)
-#define CQ_DESC_COLOR_MASK       1
-#define CQ_DESC_COLOR_SHIFT      7
-#define CQ_DESC_Q_NUM_BITS       10
-#define CQ_DESC_Q_NUM_MASK       ((1 << CQ_DESC_Q_NUM_BITS) - 1)
-#define CQ_DESC_COMP_NDX_BITS    12
-#define CQ_DESC_COMP_NDX_MASK    ((1 << CQ_DESC_COMP_NDX_BITS) - 1)
-
-static inline void cq_desc_dec(const struct cq_desc *desc_arg,
-	u8 *type, u8 *color, u16 *q_number, u16 *completed_index)
-{
-	const struct cq_desc *desc = desc_arg;
-	const u8 type_color = desc->type_color;
-
-	*color = (type_color >> CQ_DESC_COLOR_SHIFT) & CQ_DESC_COLOR_MASK;
-
-	/*
-	 * Make sure color bit is read from desc *before* other fields
-	 * are read from desc.  Hardware guarantees color bit is last
-	 * bit (byte) written.  Adding the rmb() prevents the compiler
-	 * and/or CPU from reordering the reads which would potentially
-	 * result in reading stale values.
-	 */
-
-	rmb();
-
-	*type = type_color & CQ_DESC_TYPE_MASK;
-	*q_number = le16_to_cpu(desc->q_number) & CQ_DESC_Q_NUM_MASK;
-	*completed_index = le16_to_cpu(desc->completed_index) &
-		CQ_DESC_COMP_NDX_MASK;
-}
-
-#endif /* _CQ_DESC_H_ */
diff --git a/drivers/scsi/fnic/cq_enet_desc.h b/drivers/scsi/fnic/cq_enet_desc.h
deleted file mode 100644
index a9fa26f..0000000
--- a/drivers/scsi/fnic/cq_enet_desc.h
+++ /dev/null
@@ -1,167 +0,0 @@
-/*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
- * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
- *
- * This program is free software; you may redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; version 2 of the License.
- *
- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
- * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
- * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
- * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
- * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
- * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
- * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
- * SOFTWARE.
- */
-#ifndef _CQ_ENET_DESC_H_
-#define _CQ_ENET_DESC_H_
-
-#include "cq_desc.h"
-
-/* Ethernet completion queue descriptor: 16B */
-struct cq_enet_wq_desc {
-	__le16 completed_index;
-	__le16 q_number;
-	u8 reserved[11];
-	u8 type_color;
-};
-
-static inline void cq_enet_wq_desc_dec(struct cq_enet_wq_desc *desc,
-	u8 *type, u8 *color, u16 *q_number, u16 *completed_index)
-{
-	cq_desc_dec((struct cq_desc *)desc, type,
-		color, q_number, completed_index);
-}
-
-/* Completion queue descriptor: Ethernet receive queue, 16B */
-struct cq_enet_rq_desc {
-	__le16 completed_index_flags;
-	__le16 q_number_rss_type_flags;
-	__le32 rss_hash;
-	__le16 bytes_written_flags;
-	__le16 vlan;
-	__le16 checksum_fcoe;
-	u8 flags;
-	u8 type_color;
-};
-
-#define CQ_ENET_RQ_DESC_FLAGS_INGRESS_PORT          (0x1 << 12)
-#define CQ_ENET_RQ_DESC_FLAGS_FCOE                  (0x1 << 13)
-#define CQ_ENET_RQ_DESC_FLAGS_EOP                   (0x1 << 14)
-#define CQ_ENET_RQ_DESC_FLAGS_SOP                   (0x1 << 15)
-
-#define CQ_ENET_RQ_DESC_RSS_TYPE_BITS               4
-#define CQ_ENET_RQ_DESC_RSS_TYPE_MASK \
-	((1 << CQ_ENET_RQ_DESC_RSS_TYPE_BITS) - 1)
-#define CQ_ENET_RQ_DESC_RSS_TYPE_NONE               0
-#define CQ_ENET_RQ_DESC_RSS_TYPE_IPv4               1
-#define CQ_ENET_RQ_DESC_RSS_TYPE_TCP_IPv4           2
-#define CQ_ENET_RQ_DESC_RSS_TYPE_IPv6               3
-#define CQ_ENET_RQ_DESC_RSS_TYPE_TCP_IPv6           4
-#define CQ_ENET_RQ_DESC_RSS_TYPE_IPv6_EX            5
-#define CQ_ENET_RQ_DESC_RSS_TYPE_TCP_IPv6_EX        6
-
-#define CQ_ENET_RQ_DESC_FLAGS_CSUM_NOT_CALC         (0x1 << 14)
-
-#define CQ_ENET_RQ_DESC_BYTES_WRITTEN_BITS          14
-#define CQ_ENET_RQ_DESC_BYTES_WRITTEN_MASK \
-	((1 << CQ_ENET_RQ_DESC_BYTES_WRITTEN_BITS) - 1)
-#define CQ_ENET_RQ_DESC_FLAGS_TRUNCATED             (0x1 << 14)
-#define CQ_ENET_RQ_DESC_FLAGS_VLAN_STRIPPED         (0x1 << 15)
-
-#define CQ_ENET_RQ_DESC_FCOE_SOF_BITS               4
-#define CQ_ENET_RQ_DESC_FCOE_SOF_MASK \
-	((1 << CQ_ENET_RQ_DESC_FCOE_SOF_BITS) - 1)
-#define CQ_ENET_RQ_DESC_FCOE_EOF_BITS               8
-#define CQ_ENET_RQ_DESC_FCOE_EOF_MASK \
-	((1 << CQ_ENET_RQ_DESC_FCOE_EOF_BITS) - 1)
-#define CQ_ENET_RQ_DESC_FCOE_EOF_SHIFT              8
-
-#define CQ_ENET_RQ_DESC_FLAGS_TCP_UDP_CSUM_OK       (0x1 << 0)
-#define CQ_ENET_RQ_DESC_FCOE_FC_CRC_OK              (0x1 << 0)
-#define CQ_ENET_RQ_DESC_FLAGS_UDP                   (0x1 << 1)
-#define CQ_ENET_RQ_DESC_FCOE_ENC_ERROR              (0x1 << 1)
-#define CQ_ENET_RQ_DESC_FLAGS_TCP                   (0x1 << 2)
-#define CQ_ENET_RQ_DESC_FLAGS_IPV4_CSUM_OK          (0x1 << 3)
-#define CQ_ENET_RQ_DESC_FLAGS_IPV6                  (0x1 << 4)
-#define CQ_ENET_RQ_DESC_FLAGS_IPV4                  (0x1 << 5)
-#define CQ_ENET_RQ_DESC_FLAGS_IPV4_FRAGMENT         (0x1 << 6)
-#define CQ_ENET_RQ_DESC_FLAGS_FCS_OK                (0x1 << 7)
-
-static inline void cq_enet_rq_desc_dec(struct cq_enet_rq_desc *desc,
-	u8 *type, u8 *color, u16 *q_number, u16 *completed_index,
-	u8 *ingress_port, u8 *fcoe, u8 *eop, u8 *sop, u8 *rss_type,
-	u8 *csum_not_calc, u32 *rss_hash, u16 *bytes_written, u8 *packet_error,
-	u8 *vlan_stripped, u16 *vlan, u16 *checksum, u8 *fcoe_sof,
-	u8 *fcoe_fc_crc_ok, u8 *fcoe_enc_error, u8 *fcoe_eof,
-	u8 *tcp_udp_csum_ok, u8 *udp, u8 *tcp, u8 *ipv4_csum_ok,
-	u8 *ipv6, u8 *ipv4, u8 *ipv4_fragment, u8 *fcs_ok)
-{
-	u16 completed_index_flags = le16_to_cpu(desc->completed_index_flags);
-	u16 q_number_rss_type_flags =
-		le16_to_cpu(desc->q_number_rss_type_flags);
-	u16 bytes_written_flags = le16_to_cpu(desc->bytes_written_flags);
-
-	cq_desc_dec((struct cq_desc *)desc, type,
-		color, q_number, completed_index);
-
-	*ingress_port = (completed_index_flags &
-		CQ_ENET_RQ_DESC_FLAGS_INGRESS_PORT) ? 1 : 0;
-	*fcoe = (completed_index_flags & CQ_ENET_RQ_DESC_FLAGS_FCOE) ?
-		1 : 0;
-	*eop = (completed_index_flags & CQ_ENET_RQ_DESC_FLAGS_EOP) ?
-		1 : 0;
-	*sop = (completed_index_flags & CQ_ENET_RQ_DESC_FLAGS_SOP) ?
-		1 : 0;
-
-	*rss_type = (u8)((q_number_rss_type_flags >> CQ_DESC_Q_NUM_BITS) &
-		CQ_ENET_RQ_DESC_RSS_TYPE_MASK);
-	*csum_not_calc = (q_number_rss_type_flags &
-		CQ_ENET_RQ_DESC_FLAGS_CSUM_NOT_CALC) ? 1 : 0;
-
-	*rss_hash = le32_to_cpu(desc->rss_hash);
-
-	*bytes_written = bytes_written_flags &
-		CQ_ENET_RQ_DESC_BYTES_WRITTEN_MASK;
-	*packet_error = (bytes_written_flags &
-		CQ_ENET_RQ_DESC_FLAGS_TRUNCATED) ? 1 : 0;
-	*vlan_stripped = (bytes_written_flags &
-		CQ_ENET_RQ_DESC_FLAGS_VLAN_STRIPPED) ? 1 : 0;
-
-	*vlan = le16_to_cpu(desc->vlan);
-
-	if (*fcoe) {
-		*fcoe_sof = (u8)(le16_to_cpu(desc->checksum_fcoe) &
-			CQ_ENET_RQ_DESC_FCOE_SOF_MASK);
-		*fcoe_fc_crc_ok = (desc->flags &
-			CQ_ENET_RQ_DESC_FCOE_FC_CRC_OK) ? 1 : 0;
-		*fcoe_enc_error = (desc->flags &
-			CQ_ENET_RQ_DESC_FCOE_ENC_ERROR) ? 1 : 0;
-		*fcoe_eof = (u8)((desc->checksum_fcoe >>
-			CQ_ENET_RQ_DESC_FCOE_EOF_SHIFT) &
-			CQ_ENET_RQ_DESC_FCOE_EOF_MASK);
-		*checksum = 0;
-	} else {
-		*fcoe_sof = 0;
-		*fcoe_fc_crc_ok = 0;
-		*fcoe_enc_error = 0;
-		*fcoe_eof = 0;
-		*checksum = le16_to_cpu(desc->checksum_fcoe);
-	}
-
-	*tcp_udp_csum_ok =
-		(desc->flags & CQ_ENET_RQ_DESC_FLAGS_TCP_UDP_CSUM_OK) ? 1 : 0;
-	*udp = (desc->flags & CQ_ENET_RQ_DESC_FLAGS_UDP) ? 1 : 0;
-	*tcp = (desc->flags & CQ_ENET_RQ_DESC_FLAGS_TCP) ? 1 : 0;
-	*ipv4_csum_ok =
-		(desc->flags & CQ_ENET_RQ_DESC_FLAGS_IPV4_CSUM_OK) ? 1 : 0;
-	*ipv6 = (desc->flags & CQ_ENET_RQ_DESC_FLAGS_IPV6) ? 1 : 0;
-	*ipv4 = (desc->flags & CQ_ENET_RQ_DESC_FLAGS_IPV4) ? 1 : 0;
-	*ipv4_fragment =
-		(desc->flags & CQ_ENET_RQ_DESC_FLAGS_IPV4_FRAGMENT) ? 1 : 0;
-	*fcs_ok = (desc->flags & CQ_ENET_RQ_DESC_FLAGS_FCS_OK) ? 1 : 0;
-}
-
-#endif /* _CQ_ENET_DESC_H_ */
diff --git a/drivers/scsi/fnic/fnic.h b/drivers/scsi/fnic/fnic.h
index e4c0a3d..fb258df 100644
--- a/drivers/scsi/fnic/fnic.h
+++ b/drivers/scsi/fnic/fnic.h
@@ -35,7 +35,7 @@
 
 #define DRV_NAME		"fnic"
 #define DRV_DESCRIPTION		"Cisco FCoE HBA Driver"
-#define DRV_VERSION		"1.0.0.1121"
+#define DRV_VERSION		"1.0.0.1121-k1"
 #define PFX			DRV_NAME ": "
 #define DFX                     DRV_NAME "%d: "
 
diff --git a/drivers/scsi/fnic/rq_enet_desc.h b/drivers/scsi/fnic/rq_enet_desc.h
deleted file mode 100644
index 92e80ae..0000000
--- a/drivers/scsi/fnic/rq_enet_desc.h
+++ /dev/null
@@ -1,58 +0,0 @@
-/*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
- * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
- *
- * This program is free software; you may redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; version 2 of the License.
- *
- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
- * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
- * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
- * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
- * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
- * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
- * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
- * SOFTWARE.
- */
-#ifndef _RQ_ENET_DESC_H_
-#define _RQ_ENET_DESC_H_
-
-/* Ethernet receive queue descriptor: 16B */
-struct rq_enet_desc {
-	__le64 address;
-	__le16 length_type;
-	u8 reserved[6];
-};
-
-enum rq_enet_type_types {
-	RQ_ENET_TYPE_ONLY_SOP = 0,
-	RQ_ENET_TYPE_NOT_SOP = 1,
-	RQ_ENET_TYPE_RESV2 = 2,
-	RQ_ENET_TYPE_RESV3 = 3,
-};
-
-#define RQ_ENET_ADDR_BITS		64
-#define RQ_ENET_LEN_BITS		14
-#define RQ_ENET_LEN_MASK		((1 << RQ_ENET_LEN_BITS) - 1)
-#define RQ_ENET_TYPE_BITS		2
-#define RQ_ENET_TYPE_MASK		((1 << RQ_ENET_TYPE_BITS) - 1)
-
-static inline void rq_enet_desc_enc(struct rq_enet_desc *desc,
-	u64 address, u8 type, u16 length)
-{
-	desc->address = cpu_to_le64(address);
-	desc->length_type = cpu_to_le16((length & RQ_ENET_LEN_MASK) |
-		((type & RQ_ENET_TYPE_MASK) << RQ_ENET_LEN_BITS));
-}
-
-static inline void rq_enet_desc_dec(struct rq_enet_desc *desc,
-	u64 *address, u8 *type, u16 *length)
-{
-	*address = le64_to_cpu(desc->address);
-	*length = le16_to_cpu(desc->length_type) & RQ_ENET_LEN_MASK;
-	*type = (u8)((le16_to_cpu(desc->length_type) >> RQ_ENET_LEN_BITS) &
-		RQ_ENET_TYPE_MASK);
-}
-
-#endif /* _RQ_ENET_DESC_H_ */
diff --git a/drivers/scsi/fnic/vnic_cq.c b/drivers/scsi/fnic/vnic_cq.c
deleted file mode 100644
index c5db32e..0000000
--- a/drivers/scsi/fnic/vnic_cq.c
+++ /dev/null
@@ -1,85 +0,0 @@
-/*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
- * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
- *
- * This program is free software; you may redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; version 2 of the License.
- *
- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
- * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
- * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
- * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
- * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
- * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
- * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
- * SOFTWARE.
- */
-#include <linux/errno.h>
-#include <linux/types.h>
-#include <linux/pci.h>
-#include "vnic_dev.h"
-#include "vnic_cq.h"
-
-void vnic_cq_free(struct vnic_cq *cq)
-{
-	vnic_dev_free_desc_ring(cq->vdev, &cq->ring);
-
-	cq->ctrl = NULL;
-}
-
-int vnic_cq_alloc(struct vnic_dev *vdev, struct vnic_cq *cq, unsigned int index,
-	unsigned int desc_count, unsigned int desc_size)
-{
-	int err;
-
-	cq->index = index;
-	cq->vdev = vdev;
-
-	cq->ctrl = vnic_dev_get_res(vdev, RES_TYPE_CQ, index);
-	if (!cq->ctrl) {
-		printk(KERN_ERR "Failed to hook CQ[%d] resource\n", index);
-		return -EINVAL;
-	}
-
-	err = vnic_dev_alloc_desc_ring(vdev, &cq->ring, desc_count, desc_size);
-	if (err)
-		return err;
-
-	return 0;
-}
-
-void vnic_cq_init(struct vnic_cq *cq, unsigned int flow_control_enable,
-	unsigned int color_enable, unsigned int cq_head, unsigned int cq_tail,
-	unsigned int cq_tail_color, unsigned int interrupt_enable,
-	unsigned int cq_entry_enable, unsigned int cq_message_enable,
-	unsigned int interrupt_offset, u64 cq_message_addr)
-{
-	u64 paddr;
-
-	paddr = (u64)cq->ring.base_addr | VNIC_PADDR_TARGET;
-	writeq(paddr, &cq->ctrl->ring_base);
-	iowrite32(cq->ring.desc_count, &cq->ctrl->ring_size);
-	iowrite32(flow_control_enable, &cq->ctrl->flow_control_enable);
-	iowrite32(color_enable, &cq->ctrl->color_enable);
-	iowrite32(cq_head, &cq->ctrl->cq_head);
-	iowrite32(cq_tail, &cq->ctrl->cq_tail);
-	iowrite32(cq_tail_color, &cq->ctrl->cq_tail_color);
-	iowrite32(interrupt_enable, &cq->ctrl->interrupt_enable);
-	iowrite32(cq_entry_enable, &cq->ctrl->cq_entry_enable);
-	iowrite32(cq_message_enable, &cq->ctrl->cq_message_enable);
-	iowrite32(interrupt_offset, &cq->ctrl->interrupt_offset);
-	writeq(cq_message_addr, &cq->ctrl->cq_message_addr);
-}
-
-void vnic_cq_clean(struct vnic_cq *cq)
-{
-	cq->to_clean = 0;
-	cq->last_color = 0;
-
-	iowrite32(0, &cq->ctrl->cq_head);
-	iowrite32(0, &cq->ctrl->cq_tail);
-	iowrite32(1, &cq->ctrl->cq_tail_color);
-
-	vnic_dev_clear_desc_ring(&cq->ring);
-}
diff --git a/drivers/scsi/fnic/vnic_cq.h b/drivers/scsi/fnic/vnic_cq.h
deleted file mode 100644
index 4ede680..0000000
--- a/drivers/scsi/fnic/vnic_cq.h
+++ /dev/null
@@ -1,121 +0,0 @@
-/*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
- * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
- *
- * This program is free software; you may redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; version 2 of the License.
- *
- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
- * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
- * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
- * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
- * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
- * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
- * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
- * SOFTWARE.
- */
-#ifndef _VNIC_CQ_H_
-#define _VNIC_CQ_H_
-
-#include "cq_desc.h"
-#include "vnic_dev.h"
-
-/*
- * These defines avoid symbol clash between fnic and enic (Cisco 10G Eth
- * Driver) when both are built with CONFIG options =y
- */
-#define vnic_cq_service fnic_cq_service
-#define vnic_cq_free fnic_cq_free
-#define vnic_cq_alloc fnic_cq_alloc
-#define vnic_cq_init fnic_cq_init
-#define vnic_cq_clean fnic_cq_clean
-
-/* Completion queue control */
-struct vnic_cq_ctrl {
-	u64 ring_base;			/* 0x00 */
-	u32 ring_size;			/* 0x08 */
-	u32 pad0;
-	u32 flow_control_enable;	/* 0x10 */
-	u32 pad1;
-	u32 color_enable;		/* 0x18 */
-	u32 pad2;
-	u32 cq_head;			/* 0x20 */
-	u32 pad3;
-	u32 cq_tail;			/* 0x28 */
-	u32 pad4;
-	u32 cq_tail_color;		/* 0x30 */
-	u32 pad5;
-	u32 interrupt_enable;		/* 0x38 */
-	u32 pad6;
-	u32 cq_entry_enable;		/* 0x40 */
-	u32 pad7;
-	u32 cq_message_enable;		/* 0x48 */
-	u32 pad8;
-	u32 interrupt_offset;		/* 0x50 */
-	u32 pad9;
-	u64 cq_message_addr;		/* 0x58 */
-	u32 pad10;
-};
-
-struct vnic_cq {
-	unsigned int index;
-	struct vnic_dev *vdev;
-	struct vnic_cq_ctrl __iomem *ctrl;	/* memory-mapped */
-	struct vnic_dev_ring ring;
-	unsigned int to_clean;
-	unsigned int last_color;
-};
-
-static inline unsigned int vnic_cq_service(struct vnic_cq *cq,
-	unsigned int work_to_do,
-	int (*q_service)(struct vnic_dev *vdev, struct cq_desc *cq_desc,
-	u8 type, u16 q_number, u16 completed_index, void *opaque),
-	void *opaque)
-{
-	struct cq_desc *cq_desc;
-	unsigned int work_done = 0;
-	u16 q_number, completed_index;
-	u8 type, color;
-
-	cq_desc = (struct cq_desc *)((u8 *)cq->ring.descs +
-		cq->ring.desc_size * cq->to_clean);
-	cq_desc_dec(cq_desc, &type, &color,
-		&q_number, &completed_index);
-
-	while (color != cq->last_color) {
-
-		if ((*q_service)(cq->vdev, cq_desc, type,
-			q_number, completed_index, opaque))
-			break;
-
-		cq->to_clean++;
-		if (cq->to_clean == cq->ring.desc_count) {
-			cq->to_clean = 0;
-			cq->last_color = cq->last_color ? 0 : 1;
-		}
-
-		cq_desc = (struct cq_desc *)((u8 *)cq->ring.descs +
-			cq->ring.desc_size * cq->to_clean);
-		cq_desc_dec(cq_desc, &type, &color,
-			&q_number, &completed_index);
-
-		work_done++;
-		if (work_done >= work_to_do)
-			break;
-	}
-
-	return work_done;
-}
-
-void vnic_cq_free(struct vnic_cq *cq);
-int vnic_cq_alloc(struct vnic_dev *vdev, struct vnic_cq *cq, unsigned int index,
-	unsigned int desc_count, unsigned int desc_size);
-void vnic_cq_init(struct vnic_cq *cq, unsigned int flow_control_enable,
-	unsigned int color_enable, unsigned int cq_head, unsigned int cq_tail,
-	unsigned int cq_tail_color, unsigned int interrupt_enable,
-	unsigned int cq_entry_enable, unsigned int message_enable,
-	unsigned int interrupt_offset, u64 message_addr);
-void vnic_cq_clean(struct vnic_cq *cq);
-
-#endif /* _VNIC_CQ_H_ */
diff --git a/drivers/scsi/fnic/vnic_dev.c b/drivers/scsi/fnic/vnic_dev.c
deleted file mode 100644
index 5667706..0000000
--- a/drivers/scsi/fnic/vnic_dev.c
+++ /dev/null
@@ -1,690 +0,0 @@
-/*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
- * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
- *
- * This program is free software; you may redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; version 2 of the License.
- *
- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
- * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
- * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
- * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
- * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
- * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
- * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
- * SOFTWARE.
- */
-
-#include <linux/kernel.h>
-#include <linux/errno.h>
-#include <linux/types.h>
-#include <linux/pci.h>
-#include <linux/delay.h>
-#include <linux/if_ether.h>
-#include "vnic_resource.h"
-#include "vnic_devcmd.h"
-#include "vnic_dev.h"
-#include "vnic_stats.h"
-
-struct vnic_res {
-	void __iomem *vaddr;
-	unsigned int count;
-};
-
-struct vnic_dev {
-	void *priv;
-	struct pci_dev *pdev;
-	struct vnic_res res[RES_TYPE_MAX];
-	enum vnic_dev_intr_mode intr_mode;
-	struct vnic_devcmd __iomem *devcmd;
-	struct vnic_devcmd_notify *notify;
-	struct vnic_devcmd_notify notify_copy;
-	dma_addr_t notify_pa;
-	u32 *linkstatus;
-	dma_addr_t linkstatus_pa;
-	struct vnic_stats *stats;
-	dma_addr_t stats_pa;
-	struct vnic_devcmd_fw_info *fw_info;
-	dma_addr_t fw_info_pa;
-};
-
-#define VNIC_MAX_RES_HDR_SIZE \
-	(sizeof(struct vnic_resource_header) + \
-	sizeof(struct vnic_resource) * RES_TYPE_MAX)
-#define VNIC_RES_STRIDE	128
-
-void *vnic_dev_priv(struct vnic_dev *vdev)
-{
-	return vdev->priv;
-}
-
-static int vnic_dev_discover_res(struct vnic_dev *vdev,
-	struct vnic_dev_bar *bar)
-{
-	struct vnic_resource_header __iomem *rh;
-	struct vnic_resource __iomem *r;
-	u8 type;
-
-	if (bar->len < VNIC_MAX_RES_HDR_SIZE) {
-		printk(KERN_ERR "vNIC BAR0 res hdr length error\n");
-		return -EINVAL;
-	}
-
-	rh = bar->vaddr;
-	if (!rh) {
-		printk(KERN_ERR "vNIC BAR0 res hdr not mem-mapped\n");
-		return -EINVAL;
-	}
-
-	if (ioread32(&rh->magic) != VNIC_RES_MAGIC ||
-	    ioread32(&rh->version) != VNIC_RES_VERSION) {
-		printk(KERN_ERR "vNIC BAR0 res magic/version error "
-			"exp (%lx/%lx) curr (%x/%x)\n",
-			VNIC_RES_MAGIC, VNIC_RES_VERSION,
-			ioread32(&rh->magic), ioread32(&rh->version));
-		return -EINVAL;
-	}
-
-	r = (struct vnic_resource __iomem *)(rh + 1);
-
-	while ((type = ioread8(&r->type)) != RES_TYPE_EOL) {
-
-		u8 bar_num = ioread8(&r->bar);
-		u32 bar_offset = ioread32(&r->bar_offset);
-		u32 count = ioread32(&r->count);
-		u32 len;
-
-		r++;
-
-		if (bar_num != 0)  /* only mapping in BAR0 resources */
-			continue;
-
-		switch (type) {
-		case RES_TYPE_WQ:
-		case RES_TYPE_RQ:
-		case RES_TYPE_CQ:
-		case RES_TYPE_INTR_CTRL:
-			/* each count is stride bytes long */
-			len = count * VNIC_RES_STRIDE;
-			if (len + bar_offset > bar->len) {
-				printk(KERN_ERR "vNIC BAR0 resource %d "
-					"out-of-bounds, offset 0x%x + "
-					"size 0x%x > bar len 0x%lx\n",
-					type, bar_offset,
-					len,
-					bar->len);
-				return -EINVAL;
-			}
-			break;
-		case RES_TYPE_INTR_PBA_LEGACY:
-		case RES_TYPE_DEVCMD:
-			len = count;
-			break;
-		default:
-			continue;
-		}
-
-		vdev->res[type].count = count;
-		vdev->res[type].vaddr = (char __iomem *)bar->vaddr + bar_offset;
-	}
-
-	return 0;
-}
-
-unsigned int vnic_dev_get_res_count(struct vnic_dev *vdev,
-	enum vnic_res_type type)
-{
-	return vdev->res[type].count;
-}
-
-void __iomem *vnic_dev_get_res(struct vnic_dev *vdev, enum vnic_res_type type,
-	unsigned int index)
-{
-	if (!vdev->res[type].vaddr)
-		return NULL;
-
-	switch (type) {
-	case RES_TYPE_WQ:
-	case RES_TYPE_RQ:
-	case RES_TYPE_CQ:
-	case RES_TYPE_INTR_CTRL:
-		return (char __iomem *)vdev->res[type].vaddr +
-					index * VNIC_RES_STRIDE;
-	default:
-		return (char __iomem *)vdev->res[type].vaddr;
-	}
-}
-
-unsigned int vnic_dev_desc_ring_size(struct vnic_dev_ring *ring,
-				     unsigned int desc_count,
-				     unsigned int desc_size)
-{
-	/* The base address of the desc rings must be 512 byte aligned.
-	 * Descriptor count is aligned to groups of 32 descriptors.  A
-	 * count of 0 means the maximum 4096 descriptors.  Descriptor
-	 * size is aligned to 16 bytes.
-	 */
-
-	unsigned int count_align = 32;
-	unsigned int desc_align = 16;
-
-	ring->base_align = 512;
-
-	if (desc_count == 0)
-		desc_count = 4096;
-
-	ring->desc_count = ALIGN(desc_count, count_align);
-
-	ring->desc_size = ALIGN(desc_size, desc_align);
-
-	ring->size = ring->desc_count * ring->desc_size;
-	ring->size_unaligned = ring->size + ring->base_align;
-
-	return ring->size_unaligned;
-}
-
-void vnic_dev_clear_desc_ring(struct vnic_dev_ring *ring)
-{
-	memset(ring->descs, 0, ring->size);
-}
-
-int vnic_dev_alloc_desc_ring(struct vnic_dev *vdev, struct vnic_dev_ring *ring,
-	unsigned int desc_count, unsigned int desc_size)
-{
-	vnic_dev_desc_ring_size(ring, desc_count, desc_size);
-
-	ring->descs_unaligned = pci_alloc_consistent(vdev->pdev,
-		ring->size_unaligned,
-		&ring->base_addr_unaligned);
-
-	if (!ring->descs_unaligned) {
-		printk(KERN_ERR
-		  "Failed to allocate ring (size=%d), aborting\n",
-			(int)ring->size);
-		return -ENOMEM;
-	}
-
-	ring->base_addr = ALIGN(ring->base_addr_unaligned,
-		ring->base_align);
-	ring->descs = (u8 *)ring->descs_unaligned +
-		(ring->base_addr - ring->base_addr_unaligned);
-
-	vnic_dev_clear_desc_ring(ring);
-
-	ring->desc_avail = ring->desc_count - 1;
-
-	return 0;
-}
-
-void vnic_dev_free_desc_ring(struct vnic_dev *vdev, struct vnic_dev_ring *ring)
-{
-	if (ring->descs) {
-		pci_free_consistent(vdev->pdev,
-			ring->size_unaligned,
-			ring->descs_unaligned,
-			ring->base_addr_unaligned);
-		ring->descs = NULL;
-	}
-}
-
-int vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
-	u64 *a0, u64 *a1, int wait)
-{
-	struct vnic_devcmd __iomem *devcmd = vdev->devcmd;
-	int delay;
-	u32 status;
-	int dev_cmd_err[] = {
-		/* convert from fw's version of error.h to host's version */
-		0,	/* ERR_SUCCESS */
-		EINVAL,	/* ERR_EINVAL */
-		EFAULT,	/* ERR_EFAULT */
-		EPERM,	/* ERR_EPERM */
-		EBUSY,  /* ERR_EBUSY */
-	};
-	int err;
-
-	status = ioread32(&devcmd->status);
-	if (status & STAT_BUSY) {
-		printk(KERN_ERR "Busy devcmd %d\n", _CMD_N(cmd));
-		return -EBUSY;
-	}
-
-	if (_CMD_DIR(cmd) & _CMD_DIR_WRITE) {
-		writeq(*a0, &devcmd->args[0]);
-		writeq(*a1, &devcmd->args[1]);
-		wmb();
-	}
-
-	iowrite32(cmd, &devcmd->cmd);
-
-	if ((_CMD_FLAGS(cmd) & _CMD_FLAGS_NOWAIT))
-			return 0;
-
-	for (delay = 0; delay < wait; delay++) {
-
-		udelay(100);
-
-		status = ioread32(&devcmd->status);
-		if (!(status & STAT_BUSY)) {
-
-			if (status & STAT_ERROR) {
-				err = dev_cmd_err[(int)readq(&devcmd->args[0])];
-				printk(KERN_ERR "Error %d devcmd %d\n",
-					err, _CMD_N(cmd));
-				return -err;
-			}
-
-			if (_CMD_DIR(cmd) & _CMD_DIR_READ) {
-				rmb();
-				*a0 = readq(&devcmd->args[0]);
-				*a1 = readq(&devcmd->args[1]);
-			}
-
-			return 0;
-		}
-	}
-
-	printk(KERN_ERR "Timedout devcmd %d\n", _CMD_N(cmd));
-	return -ETIMEDOUT;
-}
-
-int vnic_dev_fw_info(struct vnic_dev *vdev,
-	struct vnic_devcmd_fw_info **fw_info)
-{
-	u64 a0, a1 = 0;
-	int wait = 1000;
-	int err = 0;
-
-	if (!vdev->fw_info) {
-		vdev->fw_info = pci_alloc_consistent(vdev->pdev,
-			sizeof(struct vnic_devcmd_fw_info),
-			&vdev->fw_info_pa);
-		if (!vdev->fw_info)
-			return -ENOMEM;
-
-		a0 = vdev->fw_info_pa;
-
-		/* only get fw_info once and cache it */
-		err = vnic_dev_cmd(vdev, CMD_MCPU_FW_INFO, &a0, &a1, wait);
-	}
-
-	*fw_info = vdev->fw_info;
-
-	return err;
-}
-
-int vnic_dev_spec(struct vnic_dev *vdev, unsigned int offset, unsigned int size,
-	void *value)
-{
-	u64 a0, a1;
-	int wait = 1000;
-	int err;
-
-	a0 = offset;
-	a1 = size;
-
-	err = vnic_dev_cmd(vdev, CMD_DEV_SPEC, &a0, &a1, wait);
-
-	switch (size) {
-	case 1:
-		*(u8 *)value = (u8)a0;
-		break;
-	case 2:
-		*(u16 *)value = (u16)a0;
-		break;
-	case 4:
-		*(u32 *)value = (u32)a0;
-		break;
-	case 8:
-		*(u64 *)value = a0;
-		break;
-	default:
-		BUG();
-		break;
-	}
-
-	return err;
-}
-
-int vnic_dev_stats_clear(struct vnic_dev *vdev)
-{
-	u64 a0 = 0, a1 = 0;
-	int wait = 1000;
-	return vnic_dev_cmd(vdev, CMD_STATS_CLEAR, &a0, &a1, wait);
-}
-
-int vnic_dev_stats_dump(struct vnic_dev *vdev, struct vnic_stats **stats)
-{
-	u64 a0, a1;
-	int wait = 1000;
-
-	if (!vdev->stats) {
-		vdev->stats = pci_alloc_consistent(vdev->pdev,
-			sizeof(struct vnic_stats), &vdev->stats_pa);
-		if (!vdev->stats)
-			return -ENOMEM;
-	}
-
-	*stats = vdev->stats;
-	a0 = vdev->stats_pa;
-	a1 = sizeof(struct vnic_stats);
-
-	return vnic_dev_cmd(vdev, CMD_STATS_DUMP, &a0, &a1, wait);
-}
-
-int vnic_dev_close(struct vnic_dev *vdev)
-{
-	u64 a0 = 0, a1 = 0;
-	int wait = 1000;
-	return vnic_dev_cmd(vdev, CMD_CLOSE, &a0, &a1, wait);
-}
-
-int vnic_dev_enable(struct vnic_dev *vdev)
-{
-	u64 a0 = 0, a1 = 0;
-	int wait = 1000;
-	return vnic_dev_cmd(vdev, CMD_ENABLE, &a0, &a1, wait);
-}
-
-int vnic_dev_disable(struct vnic_dev *vdev)
-{
-	u64 a0 = 0, a1 = 0;
-	int wait = 1000;
-	return vnic_dev_cmd(vdev, CMD_DISABLE, &a0, &a1, wait);
-}
-
-int vnic_dev_open(struct vnic_dev *vdev, int arg)
-{
-	u64 a0 = (u32)arg, a1 = 0;
-	int wait = 1000;
-	return vnic_dev_cmd(vdev, CMD_OPEN, &a0, &a1, wait);
-}
-
-int vnic_dev_open_done(struct vnic_dev *vdev, int *done)
-{
-	u64 a0 = 0, a1 = 0;
-	int wait = 1000;
-	int err;
-
-	*done = 0;
-
-	err = vnic_dev_cmd(vdev, CMD_OPEN_STATUS, &a0, &a1, wait);
-	if (err)
-		return err;
-
-	*done = (a0 == 0);
-
-	return 0;
-}
-
-int vnic_dev_soft_reset(struct vnic_dev *vdev, int arg)
-{
-	u64 a0 = (u32)arg, a1 = 0;
-	int wait = 1000;
-	return vnic_dev_cmd(vdev, CMD_SOFT_RESET, &a0, &a1, wait);
-}
-
-int vnic_dev_soft_reset_done(struct vnic_dev *vdev, int *done)
-{
-	u64 a0 = 0, a1 = 0;
-	int wait = 1000;
-	int err;
-
-	*done = 0;
-
-	err = vnic_dev_cmd(vdev, CMD_SOFT_RESET_STATUS, &a0, &a1, wait);
-	if (err)
-		return err;
-
-	*done = (a0 == 0);
-
-	return 0;
-}
-
-int vnic_dev_hang_notify(struct vnic_dev *vdev)
-{
-	u64 a0, a1;
-	int wait = 1000;
-	return vnic_dev_cmd(vdev, CMD_HANG_NOTIFY, &a0, &a1, wait);
-}
-
-int vnic_dev_mac_addr(struct vnic_dev *vdev, u8 *mac_addr)
-{
-	u64 a0, a1;
-	int wait = 1000;
-	int err, i;
-
-	for (i = 0; i < ETH_ALEN; i++)
-		mac_addr[i] = 0;
-
-	err = vnic_dev_cmd(vdev, CMD_MAC_ADDR, &a0, &a1, wait);
-	if (err)
-		return err;
-
-	for (i = 0; i < ETH_ALEN; i++)
-		mac_addr[i] = ((u8 *)&a0)[i];
-
-	return 0;
-}
-
-void vnic_dev_packet_filter(struct vnic_dev *vdev, int directed, int multicast,
-	int broadcast, int promisc, int allmulti)
-{
-	u64 a0, a1 = 0;
-	int wait = 1000;
-	int err;
-
-	a0 = (directed ? CMD_PFILTER_DIRECTED : 0) |
-	     (multicast ? CMD_PFILTER_MULTICAST : 0) |
-	     (broadcast ? CMD_PFILTER_BROADCAST : 0) |
-	     (promisc ? CMD_PFILTER_PROMISCUOUS : 0) |
-	     (allmulti ? CMD_PFILTER_ALL_MULTICAST : 0);
-
-	err = vnic_dev_cmd(vdev, CMD_PACKET_FILTER, &a0, &a1, wait);
-	if (err)
-		printk(KERN_ERR "Can't set packet filter\n");
-}
-
-void vnic_dev_add_addr(struct vnic_dev *vdev, u8 *addr)
-{
-	u64 a0 = 0, a1 = 0;
-	int wait = 1000;
-	int err;
-	int i;
-
-	for (i = 0; i < ETH_ALEN; i++)
-		((u8 *)&a0)[i] = addr[i];
-
-	err = vnic_dev_cmd(vdev, CMD_ADDR_ADD, &a0, &a1, wait);
-	if (err)
-		printk(KERN_ERR
-			"Can't add addr [%02x:%02x:%02x:%02x:%02x:%02x], %d\n",
-			addr[0], addr[1], addr[2], addr[3], addr[4], addr[5],
-			err);
-}
-
-void vnic_dev_del_addr(struct vnic_dev *vdev, u8 *addr)
-{
-	u64 a0 = 0, a1 = 0;
-	int wait = 1000;
-	int err;
-	int i;
-
-	for (i = 0; i < ETH_ALEN; i++)
-		((u8 *)&a0)[i] = addr[i];
-
-	err = vnic_dev_cmd(vdev, CMD_ADDR_DEL, &a0, &a1, wait);
-	if (err)
-		printk(KERN_ERR
-			"Can't del addr [%02x:%02x:%02x:%02x:%02x:%02x], %d\n",
-			addr[0], addr[1], addr[2], addr[3], addr[4], addr[5],
-			err);
-}
-
-int vnic_dev_notify_set(struct vnic_dev *vdev, u16 intr)
-{
-	u64 a0, a1;
-	int wait = 1000;
-
-	if (!vdev->notify) {
-		vdev->notify = pci_alloc_consistent(vdev->pdev,
-			sizeof(struct vnic_devcmd_notify),
-			&vdev->notify_pa);
-		if (!vdev->notify)
-			return -ENOMEM;
-	}
-
-	a0 = vdev->notify_pa;
-	a1 = ((u64)intr << 32) & 0x0000ffff00000000ULL;
-	a1 += sizeof(struct vnic_devcmd_notify);
-
-	return vnic_dev_cmd(vdev, CMD_NOTIFY, &a0, &a1, wait);
-}
-
-void vnic_dev_notify_unset(struct vnic_dev *vdev)
-{
-	u64 a0, a1;
-	int wait = 1000;
-
-	a0 = 0;  /* paddr = 0 to unset notify buffer */
-	a1 = 0x0000ffff00000000ULL; /* intr num = -1 to unreg for intr */
-	a1 += sizeof(struct vnic_devcmd_notify);
-
-	vnic_dev_cmd(vdev, CMD_NOTIFY, &a0, &a1, wait);
-}
-
-static int vnic_dev_notify_ready(struct vnic_dev *vdev)
-{
-	u32 *words;
-	unsigned int nwords = sizeof(struct vnic_devcmd_notify) / 4;
-	unsigned int i;
-	u32 csum;
-
-	if (!vdev->notify)
-		return 0;
-
-	do {
-		csum = 0;
-		memcpy(&vdev->notify_copy, vdev->notify,
-			sizeof(struct vnic_devcmd_notify));
-		words = (u32 *)&vdev->notify_copy;
-		for (i = 1; i < nwords; i++)
-			csum += words[i];
-	} while (csum != words[0]);
-
-	return 1;
-}
-
-int vnic_dev_init(struct vnic_dev *vdev, int arg)
-{
-	u64 a0 = (u32)arg, a1 = 0;
-	int wait = 1000;
-	return vnic_dev_cmd(vdev, CMD_INIT, &a0, &a1, wait);
-}
-
-int vnic_dev_link_status(struct vnic_dev *vdev)
-{
-	if (vdev->linkstatus)
-		return *vdev->linkstatus;
-
-	if (!vnic_dev_notify_ready(vdev))
-		return 0;
-
-	return vdev->notify_copy.link_state;
-}
-
-u32 vnic_dev_port_speed(struct vnic_dev *vdev)
-{
-	if (!vnic_dev_notify_ready(vdev))
-		return 0;
-
-	return vdev->notify_copy.port_speed;
-}
-
-u32 vnic_dev_msg_lvl(struct vnic_dev *vdev)
-{
-	if (!vnic_dev_notify_ready(vdev))
-		return 0;
-
-	return vdev->notify_copy.msglvl;
-}
-
-u32 vnic_dev_mtu(struct vnic_dev *vdev)
-{
-	if (!vnic_dev_notify_ready(vdev))
-		return 0;
-
-	return vdev->notify_copy.mtu;
-}
-
-u32 vnic_dev_link_down_cnt(struct vnic_dev *vdev)
-{
-	if (!vnic_dev_notify_ready(vdev))
-		return 0;
-
-	return vdev->notify_copy.link_down_cnt;
-}
-
-void vnic_dev_set_intr_mode(struct vnic_dev *vdev,
-	enum vnic_dev_intr_mode intr_mode)
-{
-	vdev->intr_mode = intr_mode;
-}
-
-enum vnic_dev_intr_mode vnic_dev_get_intr_mode(
-	struct vnic_dev *vdev)
-{
-	return vdev->intr_mode;
-}
-
-void vnic_dev_unregister(struct vnic_dev *vdev)
-{
-	if (vdev) {
-		if (vdev->notify)
-			pci_free_consistent(vdev->pdev,
-				sizeof(struct vnic_devcmd_notify),
-				vdev->notify,
-				vdev->notify_pa);
-		if (vdev->linkstatus)
-			pci_free_consistent(vdev->pdev,
-				sizeof(u32),
-				vdev->linkstatus,
-				vdev->linkstatus_pa);
-		if (vdev->stats)
-			pci_free_consistent(vdev->pdev,
-				sizeof(struct vnic_dev),
-				vdev->stats, vdev->stats_pa);
-		if (vdev->fw_info)
-			pci_free_consistent(vdev->pdev,
-				sizeof(struct vnic_devcmd_fw_info),
-				vdev->fw_info, vdev->fw_info_pa);
-		kfree(vdev);
-	}
-}
-
-struct vnic_dev *vnic_dev_register(struct vnic_dev *vdev,
-	void *priv, struct pci_dev *pdev, struct vnic_dev_bar *bar)
-{
-	if (!vdev) {
-		vdev = kzalloc(sizeof(struct vnic_dev), GFP_KERNEL);
-		if (!vdev)
-			return NULL;
-	}
-
-	vdev->priv = priv;
-	vdev->pdev = pdev;
-
-	if (vnic_dev_discover_res(vdev, bar))
-		goto err_out;
-
-	vdev->devcmd = vnic_dev_get_res(vdev, RES_TYPE_DEVCMD, 0);
-	if (!vdev->devcmd)
-		goto err_out;
-
-	return vdev;
-
-err_out:
-	vnic_dev_unregister(vdev);
-	return NULL;
-}
diff --git a/drivers/scsi/fnic/vnic_dev.h b/drivers/scsi/fnic/vnic_dev.h
deleted file mode 100644
index f9935a8..0000000
--- a/drivers/scsi/fnic/vnic_dev.h
+++ /dev/null
@@ -1,161 +0,0 @@
-/*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
- * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
- *
- * This program is free software; you may redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; version 2 of the License.
- *
- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
- * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
- * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
- * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
- * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
- * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
- * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
- * SOFTWARE.
- */
-#ifndef _VNIC_DEV_H_
-#define _VNIC_DEV_H_
-
-#include "vnic_resource.h"
-#include "vnic_devcmd.h"
-
-/*
- * These defines avoid symbol clash between fnic and enic (Cisco 10G Eth
- * Driver) when both are built with CONFIG options =y
- */
-#define vnic_dev_priv fnic_dev_priv
-#define vnic_dev_get_res_count fnic_dev_get_res_count
-#define vnic_dev_get_res fnic_dev_get_res
-#define vnic_dev_desc_ring_size fnic_dev_desc_ring_siz
-#define vnic_dev_clear_desc_ring fnic_dev_clear_desc_ring
-#define vnic_dev_alloc_desc_ring fnic_dev_alloc_desc_ring
-#define vnic_dev_free_desc_ring fnic_dev_free_desc_ring
-#define vnic_dev_cmd fnic_dev_cmd
-#define vnic_dev_fw_info fnic_dev_fw_info
-#define vnic_dev_spec fnic_dev_spec
-#define vnic_dev_stats_clear fnic_dev_stats_clear
-#define vnic_dev_stats_dump fnic_dev_stats_dump
-#define vnic_dev_hang_notify fnic_dev_hang_notify
-#define vnic_dev_packet_filter fnic_dev_packet_filter
-#define vnic_dev_add_addr fnic_dev_add_addr
-#define vnic_dev_del_addr fnic_dev_del_addr
-#define vnic_dev_mac_addr fnic_dev_mac_addr
-#define vnic_dev_notify_set fnic_dev_notify_set
-#define vnic_dev_notify_unset fnic_dev_notify_unset
-#define vnic_dev_link_status fnic_dev_link_status
-#define vnic_dev_port_speed fnic_dev_port_speed
-#define vnic_dev_msg_lvl fnic_dev_msg_lvl
-#define vnic_dev_mtu fnic_dev_mtu
-#define vnic_dev_link_down_cnt fnic_dev_link_down_cnt
-#define vnic_dev_close fnic_dev_close
-#define vnic_dev_enable fnic_dev_enable
-#define vnic_dev_disable fnic_dev_disable
-#define vnic_dev_open fnic_dev_open
-#define vnic_dev_open_done fnic_dev_open_done
-#define vnic_dev_init fnic_dev_init
-#define vnic_dev_soft_reset fnic_dev_soft_reset
-#define vnic_dev_soft_reset_done fnic_dev_soft_reset_done
-#define vnic_dev_set_intr_mode fnic_dev_set_intr_mode
-#define vnic_dev_get_intr_mode fnic_dev_get_intr_mode
-#define vnic_dev_unregister fnic_dev_unregister
-#define vnic_dev_register fnic_dev_register
-
-#ifndef VNIC_PADDR_TARGET
-#define VNIC_PADDR_TARGET	0x0000000000000000ULL
-#endif
-
-#ifndef readq
-static inline u64 readq(void __iomem *reg)
-{
-	return ((u64)readl(reg + 0x4UL) << 32) | (u64)readl(reg);
-}
-
-static inline void writeq(u64 val, void __iomem *reg)
-{
-	writel(val & 0xffffffff, reg);
-	writel(val >> 32, reg + 0x4UL);
-}
-#endif
-
-enum vnic_dev_intr_mode {
-	VNIC_DEV_INTR_MODE_UNKNOWN,
-	VNIC_DEV_INTR_MODE_INTX,
-	VNIC_DEV_INTR_MODE_MSI,
-	VNIC_DEV_INTR_MODE_MSIX,
-};
-
-struct vnic_dev_bar {
-	void __iomem *vaddr;
-	dma_addr_t bus_addr;
-	unsigned long len;
-};
-
-struct vnic_dev_ring {
-	void *descs;
-	size_t size;
-	dma_addr_t base_addr;
-	size_t base_align;
-	void *descs_unaligned;
-	size_t size_unaligned;
-	dma_addr_t base_addr_unaligned;
-	unsigned int desc_size;
-	unsigned int desc_count;
-	unsigned int desc_avail;
-};
-
-struct vnic_dev;
-struct vnic_stats;
-
-void *vnic_dev_priv(struct vnic_dev *vdev);
-unsigned int vnic_dev_get_res_count(struct vnic_dev *vdev,
-				    enum vnic_res_type type);
-void __iomem *vnic_dev_get_res(struct vnic_dev *vdev, enum vnic_res_type type,
-			       unsigned int index);
-unsigned int vnic_dev_desc_ring_size(struct vnic_dev_ring *ring,
-				     unsigned int desc_count,
-				     unsigned int desc_size);
-void vnic_dev_clear_desc_ring(struct vnic_dev_ring *ring);
-int vnic_dev_alloc_desc_ring(struct vnic_dev *vdev, struct vnic_dev_ring *ring,
-			     unsigned int desc_count, unsigned int desc_size);
-void vnic_dev_free_desc_ring(struct vnic_dev *vdev,
-			     struct vnic_dev_ring *ring);
-int vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
-		 u64 *a0, u64 *a1, int wait);
-int vnic_dev_fw_info(struct vnic_dev *vdev,
-		     struct vnic_devcmd_fw_info **fw_info);
-int vnic_dev_spec(struct vnic_dev *vdev, unsigned int offset,
-		  unsigned int size, void *value);
-int vnic_dev_stats_clear(struct vnic_dev *vdev);
-int vnic_dev_stats_dump(struct vnic_dev *vdev, struct vnic_stats **stats);
-int vnic_dev_hang_notify(struct vnic_dev *vdev);
-void vnic_dev_packet_filter(struct vnic_dev *vdev, int directed, int multicast,
-			    int broadcast, int promisc, int allmulti);
-void vnic_dev_add_addr(struct vnic_dev *vdev, u8 *addr);
-void vnic_dev_del_addr(struct vnic_dev *vdev, u8 *addr);
-int vnic_dev_mac_addr(struct vnic_dev *vdev, u8 *mac_addr);
-int vnic_dev_notify_set(struct vnic_dev *vdev, u16 intr);
-void vnic_dev_notify_unset(struct vnic_dev *vdev);
-int vnic_dev_link_status(struct vnic_dev *vdev);
-u32 vnic_dev_port_speed(struct vnic_dev *vdev);
-u32 vnic_dev_msg_lvl(struct vnic_dev *vdev);
-u32 vnic_dev_mtu(struct vnic_dev *vdev);
-u32 vnic_dev_link_down_cnt(struct vnic_dev *vdev);
-int vnic_dev_close(struct vnic_dev *vdev);
-int vnic_dev_enable(struct vnic_dev *vdev);
-int vnic_dev_disable(struct vnic_dev *vdev);
-int vnic_dev_open(struct vnic_dev *vdev, int arg);
-int vnic_dev_open_done(struct vnic_dev *vdev, int *done);
-int vnic_dev_init(struct vnic_dev *vdev, int arg);
-int vnic_dev_soft_reset(struct vnic_dev *vdev, int arg);
-int vnic_dev_soft_reset_done(struct vnic_dev *vdev, int *done);
-void vnic_dev_set_intr_mode(struct vnic_dev *vdev,
-			    enum vnic_dev_intr_mode intr_mode);
-enum vnic_dev_intr_mode vnic_dev_get_intr_mode(struct vnic_dev *vdev);
-void vnic_dev_unregister(struct vnic_dev *vdev);
-struct vnic_dev *vnic_dev_register(struct vnic_dev *vdev,
-				   void *priv, struct pci_dev *pdev,
-				   struct vnic_dev_bar *bar);
-
-#endif /* _VNIC_DEV_H_ */
diff --git a/drivers/scsi/fnic/vnic_devcmd.h b/drivers/scsi/fnic/vnic_devcmd.h
deleted file mode 100644
index d62b906..0000000
--- a/drivers/scsi/fnic/vnic_devcmd.h
+++ /dev/null
@@ -1,281 +0,0 @@
-/*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
- * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
- *
- * This program is free software; you may redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; version 2 of the License.
- *
- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
- * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
- * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
- * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
- * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
- * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
- * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
- * SOFTWARE.
- */
-#ifndef _VNIC_DEVCMD_H_
-#define _VNIC_DEVCMD_H_
-
-#define _CMD_NBITS      14
-#define _CMD_VTYPEBITS	10
-#define _CMD_FLAGSBITS  6
-#define _CMD_DIRBITS	2
-
-#define _CMD_NMASK      ((1 << _CMD_NBITS)-1)
-#define _CMD_VTYPEMASK  ((1 << _CMD_VTYPEBITS)-1)
-#define _CMD_FLAGSMASK  ((1 << _CMD_FLAGSBITS)-1)
-#define _CMD_DIRMASK    ((1 << _CMD_DIRBITS)-1)
-
-#define _CMD_NSHIFT     0
-#define _CMD_VTYPESHIFT (_CMD_NSHIFT+_CMD_NBITS)
-#define _CMD_FLAGSSHIFT (_CMD_VTYPESHIFT+_CMD_VTYPEBITS)
-#define _CMD_DIRSHIFT   (_CMD_FLAGSSHIFT+_CMD_FLAGSBITS)
-
-/*
- * Direction bits (from host perspective).
- */
-#define _CMD_DIR_NONE   0U
-#define _CMD_DIR_WRITE  1U
-#define _CMD_DIR_READ   2U
-#define _CMD_DIR_RW     (_CMD_DIR_WRITE | _CMD_DIR_READ)
-
-/*
- * Flag bits.
- */
-#define _CMD_FLAGS_NONE 0U
-#define _CMD_FLAGS_NOWAIT 1U
-
-/*
- * vNIC type bits.
- */
-#define _CMD_VTYPE_NONE  0U
-#define _CMD_VTYPE_ENET  1U
-#define _CMD_VTYPE_FC    2U
-#define _CMD_VTYPE_SCSI  4U
-#define _CMD_VTYPE_ALL   (_CMD_VTYPE_ENET | _CMD_VTYPE_FC | _CMD_VTYPE_SCSI)
-
-/*
- * Used to create cmds..
-*/
-#define _CMDCF(dir, flags, vtype, nr)  \
-	(((dir)   << _CMD_DIRSHIFT) | \
-	((flags) << _CMD_FLAGSSHIFT) | \
-	((vtype) << _CMD_VTYPESHIFT) | \
-	((nr)    << _CMD_NSHIFT))
-#define _CMDC(dir, vtype, nr)    _CMDCF(dir, 0, vtype, nr)
-#define _CMDCNW(dir, vtype, nr)  _CMDCF(dir, _CMD_FLAGS_NOWAIT, vtype, nr)
-
-/*
- * Used to decode cmds..
-*/
-#define _CMD_DIR(cmd)            (((cmd) >> _CMD_DIRSHIFT) & _CMD_DIRMASK)
-#define _CMD_FLAGS(cmd)          (((cmd) >> _CMD_FLAGSSHIFT) & _CMD_FLAGSMASK)
-#define _CMD_VTYPE(cmd)          (((cmd) >> _CMD_VTYPESHIFT) & _CMD_VTYPEMASK)
-#define _CMD_N(cmd)              (((cmd) >> _CMD_NSHIFT) & _CMD_NMASK)
-
-enum vnic_devcmd_cmd {
-	CMD_NONE                = _CMDC(_CMD_DIR_NONE, _CMD_VTYPE_NONE, 0),
-
-	/* mcpu fw info in mem: (u64)a0=paddr to struct vnic_devcmd_fw_info */
-	CMD_MCPU_FW_INFO        = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ALL, 1),
-
-	/* dev-specific block member:
-	 *    in: (u16)a0=offset,(u8)a1=size
-	 *    out: a0=value */
-	CMD_DEV_SPEC            = _CMDC(_CMD_DIR_RW, _CMD_VTYPE_ALL, 2),
-
-	/* stats clear */
-	CMD_STATS_CLEAR         = _CMDCNW(_CMD_DIR_NONE, _CMD_VTYPE_ALL, 3),
-
-	/* stats dump in mem: (u64)a0=paddr to stats area,
-	 *                    (u16)a1=sizeof stats area */
-	CMD_STATS_DUMP          = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ALL, 4),
-
-	/* set Rx packet filter: (u32)a0=filters (see CMD_PFILTER_*) */
-	CMD_PACKET_FILTER	= _CMDCNW(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 7),
-
-	/* hang detection notification */
-	CMD_HANG_NOTIFY         = _CMDC(_CMD_DIR_NONE, _CMD_VTYPE_ALL, 8),
-
-	/* MAC address in (u48)a0 */
-	CMD_MAC_ADDR            = _CMDC(_CMD_DIR_READ,
-					_CMD_VTYPE_ENET | _CMD_VTYPE_FC, 9),
-
-	/* disable/enable promisc mode: (u8)a0=0/1 */
-/***** XXX DEPRECATED *****/
-	CMD_PROMISC_MODE        = _CMDCNW(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 10),
-
-	/* disable/enable all-multi mode: (u8)a0=0/1 */
-/***** XXX DEPRECATED *****/
-	CMD_ALLMULTI_MODE       = _CMDCNW(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 11),
-
-	/* add addr from (u48)a0 */
-	CMD_ADDR_ADD            = _CMDCNW(_CMD_DIR_WRITE,
-					_CMD_VTYPE_ENET | _CMD_VTYPE_FC, 12),
-
-	/* del addr from (u48)a0 */
-	CMD_ADDR_DEL            = _CMDCNW(_CMD_DIR_WRITE,
-					_CMD_VTYPE_ENET | _CMD_VTYPE_FC, 13),
-
-	/* add VLAN id in (u16)a0 */
-	CMD_VLAN_ADD            = _CMDCNW(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 14),
-
-	/* del VLAN id in (u16)a0 */
-	CMD_VLAN_DEL            = _CMDCNW(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 15),
-
-	/* nic_cfg in (u32)a0 */
-	CMD_NIC_CFG             = _CMDCNW(_CMD_DIR_WRITE, _CMD_VTYPE_ALL, 16),
-
-	/* union vnic_rss_key in mem: (u64)a0=paddr, (u16)a1=len */
-	CMD_RSS_KEY             = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 17),
-
-	/* union vnic_rss_cpu in mem: (u64)a0=paddr, (u16)a1=len */
-	CMD_RSS_CPU             = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 18),
-
-	/* initiate softreset */
-	CMD_SOFT_RESET          = _CMDCNW(_CMD_DIR_NONE, _CMD_VTYPE_ALL, 19),
-
-	/* softreset status:
-	 *    out: a0=0 reset complete, a0=1 reset in progress */
-	CMD_SOFT_RESET_STATUS   = _CMDC(_CMD_DIR_READ, _CMD_VTYPE_ALL, 20),
-
-	/* set struct vnic_devcmd_notify buffer in mem:
-	 * in:
-	 *   (u64)a0=paddr to notify (set paddr=0 to unset)
-	 *   (u32)a1 & 0x00000000ffffffff=sizeof(struct vnic_devcmd_notify)
-	 *   (u16)a1 & 0x0000ffff00000000=intr num (-1 for no intr)
-	 * out:
-	 *   (u32)a1 = effective size
-	 */
-	CMD_NOTIFY              = _CMDC(_CMD_DIR_RW, _CMD_VTYPE_ALL, 21),
-
-	/* UNDI API: (u64)a0=paddr to s_PXENV_UNDI_ struct,
-	 *           (u8)a1=PXENV_UNDI_xxx */
-	CMD_UNDI                = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 22),
-
-	/* initiate open sequence (u32)a0=flags (see CMD_OPENF_*) */
-	CMD_OPEN		= _CMDCNW(_CMD_DIR_WRITE, _CMD_VTYPE_ALL, 23),
-
-	/* open status:
-	 *    out: a0=0 open complete, a0=1 open in progress */
-	CMD_OPEN_STATUS		= _CMDC(_CMD_DIR_READ, _CMD_VTYPE_ALL, 24),
-
-	/* close vnic */
-	CMD_CLOSE		= _CMDC(_CMD_DIR_NONE, _CMD_VTYPE_ALL, 25),
-
-	/* initialize virtual link: (u32)a0=flags (see CMD_INITF_*) */
-	CMD_INIT		= _CMDCNW(_CMD_DIR_READ, _CMD_VTYPE_ALL, 26),
-
-	/* variant of CMD_INIT, with provisioning info
-	 *     (u64)a0=paddr of vnic_devcmd_provinfo
-	 *     (u32)a1=sizeof provision info */
-	CMD_INIT_PROV_INFO	= _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 27),
-
-	/* enable virtual link */
-	CMD_ENABLE		= _CMDCNW(_CMD_DIR_WRITE, _CMD_VTYPE_ALL, 28),
-
-	/* disable virtual link */
-	CMD_DISABLE		= _CMDC(_CMD_DIR_NONE, _CMD_VTYPE_ALL, 29),
-
-	/* stats dump all vnics on uplink in mem: (u64)a0=paddr (u32)a1=uif */
-	CMD_STATS_DUMP_ALL	= _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ALL, 30),
-
-	/* init status:
-	 *    out: a0=0 init complete, a0=1 init in progress
-	 *         if a0=0, a1=errno */
-	CMD_INIT_STATUS		= _CMDC(_CMD_DIR_READ, _CMD_VTYPE_ALL, 31),
-
-	/* INT13 API: (u64)a0=paddr to vnic_int13_params struct
-	 *            (u8)a1=INT13_CMD_xxx */
-	CMD_INT13               = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_FC, 32),
-
-	/* logical uplink enable/disable: (u64)a0: 0/1=disable/enable */
-	CMD_LOGICAL_UPLINK      = _CMDCNW(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 33),
-
-	/* undo initialize of virtual link */
-	CMD_DEINIT		= _CMDCNW(_CMD_DIR_NONE, _CMD_VTYPE_ALL, 34),
-};
-
-/* flags for CMD_OPEN */
-#define CMD_OPENF_OPROM		0x1	/* open coming from option rom */
-
-/* flags for CMD_INIT */
-#define CMD_INITF_DEFAULT_MAC	0x1	/* init with default mac addr */
-
-/* flags for CMD_PACKET_FILTER */
-#define CMD_PFILTER_DIRECTED		0x01
-#define CMD_PFILTER_MULTICAST		0x02
-#define CMD_PFILTER_BROADCAST		0x04
-#define CMD_PFILTER_PROMISCUOUS		0x08
-#define CMD_PFILTER_ALL_MULTICAST	0x10
-
-enum vnic_devcmd_status {
-	STAT_NONE = 0,
-	STAT_BUSY = 1 << 0,	/* cmd in progress */
-	STAT_ERROR = 1 << 1,	/* last cmd caused error (code in a0) */
-};
-
-enum vnic_devcmd_error {
-	ERR_SUCCESS = 0,
-	ERR_EINVAL = 1,
-	ERR_EFAULT = 2,
-	ERR_EPERM = 3,
-	ERR_EBUSY = 4,
-	ERR_ECMDUNKNOWN = 5,
-	ERR_EBADSTATE = 6,
-	ERR_ENOMEM = 7,
-	ERR_ETIMEDOUT = 8,
-	ERR_ELINKDOWN = 9,
-};
-
-struct vnic_devcmd_fw_info {
-	char fw_version[32];
-	char fw_build[32];
-	char hw_version[32];
-	char hw_serial_number[32];
-};
-
-struct vnic_devcmd_notify {
-	u32 csum;		/* checksum over following words */
-
-	u32 link_state;		/* link up == 1 */
-	u32 port_speed;		/* effective port speed (rate limit) */
-	u32 mtu;		/* MTU */
-	u32 msglvl;		/* requested driver msg lvl */
-	u32 uif;		/* uplink interface */
-	u32 status;		/* status bits (see VNIC_STF_*) */
-	u32 error;		/* error code (see ERR_*) for first ERR */
-	u32 link_down_cnt;	/* running count of link down transitions */
-};
-#define VNIC_STF_FATAL_ERR	0x0001	/* fatal fw error */
-
-struct vnic_devcmd_provinfo {
-	u8 oui[3];
-	u8 type;
-	u8 data[0];
-};
-
-/*
- * Writing cmd register causes STAT_BUSY to get set in status register.
- * When cmd completes, STAT_BUSY will be cleared.
- *
- * If cmd completed successfully STAT_ERROR will be clear
- * and args registers contain cmd-specific results.
- *
- * If cmd error, STAT_ERROR will be set and args[0] contains error code.
- *
- * status register is read-only.  While STAT_BUSY is set,
- * all other register contents are read-only.
- */
-
-/* Make sizeof(vnic_devcmd) a power-of-2 for I/O BAR. */
-#define VNIC_DEVCMD_NARGS 15
-struct vnic_devcmd {
-	u32 status;			/* RO */
-	u32 cmd;			/* RW */
-	u64 args[VNIC_DEVCMD_NARGS];	/* RW cmd args (little-endian) */
-};
-
-#endif /* _VNIC_DEVCMD_H_ */
diff --git a/drivers/scsi/fnic/vnic_intr.c b/drivers/scsi/fnic/vnic_intr.c
deleted file mode 100644
index 4f4dc87..0000000
--- a/drivers/scsi/fnic/vnic_intr.c
+++ /dev/null
@@ -1,60 +0,0 @@
-/*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
- * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
- *
- * This program is free software; you may redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; version 2 of the License.
- *
- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
- * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
- * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
- * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
- * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
- * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
- * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
- * SOFTWARE.
- */
-
-#include <linux/kernel.h>
-#include <linux/errno.h>
-#include <linux/types.h>
-#include <linux/pci.h>
-#include <linux/delay.h>
-#include "vnic_dev.h"
-#include "vnic_intr.h"
-
-void vnic_intr_free(struct vnic_intr *intr)
-{
-	intr->ctrl = NULL;
-}
-
-int vnic_intr_alloc(struct vnic_dev *vdev, struct vnic_intr *intr,
-	unsigned int index)
-{
-	intr->index = index;
-	intr->vdev = vdev;
-
-	intr->ctrl = vnic_dev_get_res(vdev, RES_TYPE_INTR_CTRL, index);
-	if (!intr->ctrl) {
-		printk(KERN_ERR "Failed to hook INTR[%d].ctrl resource\n",
-			index);
-		return -EINVAL;
-	}
-
-	return 0;
-}
-
-void vnic_intr_init(struct vnic_intr *intr, unsigned int coalescing_timer,
-	unsigned int coalescing_type, unsigned int mask_on_assertion)
-{
-	iowrite32(coalescing_timer, &intr->ctrl->coalescing_timer);
-	iowrite32(coalescing_type, &intr->ctrl->coalescing_type);
-	iowrite32(mask_on_assertion, &intr->ctrl->mask_on_assertion);
-	iowrite32(0, &intr->ctrl->int_credits);
-}
-
-void vnic_intr_clean(struct vnic_intr *intr)
-{
-	iowrite32(0, &intr->ctrl->int_credits);
-}
diff --git a/drivers/scsi/fnic/vnic_intr.h b/drivers/scsi/fnic/vnic_intr.h
deleted file mode 100644
index d5fb40e..0000000
--- a/drivers/scsi/fnic/vnic_intr.h
+++ /dev/null
@@ -1,118 +0,0 @@
-/*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
- * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
- *
- * This program is free software; you may redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; version 2 of the License.
- *
- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
- * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
- * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
- * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
- * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
- * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
- * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
- * SOFTWARE.
- */
-#ifndef _VNIC_INTR_H_
-#define _VNIC_INTR_H_
-
-#include <linux/pci.h>
-#include "vnic_dev.h"
-
-/*
- * These defines avoid symbol clash between fnic and enic (Cisco 10G Eth
- * Driver) when both are built with CONFIG options =y
- */
-#define vnic_intr_unmask fnic_intr_unmask
-#define vnic_intr_mask fnic_intr_mask
-#define vnic_intr_return_credits fnic_intr_return_credits
-#define vnic_intr_credits fnic_intr_credits
-#define vnic_intr_return_all_credits fnic_intr_return_all_credits
-#define vnic_intr_legacy_pba fnic_intr_legacy_pba
-#define vnic_intr_free fnic_intr_free
-#define vnic_intr_alloc fnic_intr_alloc
-#define vnic_intr_init fnic_intr_init
-#define vnic_intr_clean fnic_intr_clean
-
-#define VNIC_INTR_TIMER_MAX		0xffff
-
-#define VNIC_INTR_TIMER_TYPE_ABS	0
-#define VNIC_INTR_TIMER_TYPE_QUIET	1
-
-/* Interrupt control */
-struct vnic_intr_ctrl {
-	u32 coalescing_timer;		/* 0x00 */
-	u32 pad0;
-	u32 coalescing_value;		/* 0x08 */
-	u32 pad1;
-	u32 coalescing_type;		/* 0x10 */
-	u32 pad2;
-	u32 mask_on_assertion;		/* 0x18 */
-	u32 pad3;
-	u32 mask;			/* 0x20 */
-	u32 pad4;
-	u32 int_credits;		/* 0x28 */
-	u32 pad5;
-	u32 int_credit_return;		/* 0x30 */
-	u32 pad6;
-};
-
-struct vnic_intr {
-	unsigned int index;
-	struct vnic_dev *vdev;
-	struct vnic_intr_ctrl __iomem *ctrl;	/* memory-mapped */
-};
-
-static inline void vnic_intr_unmask(struct vnic_intr *intr)
-{
-	iowrite32(0, &intr->ctrl->mask);
-}
-
-static inline void vnic_intr_mask(struct vnic_intr *intr)
-{
-	iowrite32(1, &intr->ctrl->mask);
-}
-
-static inline void vnic_intr_return_credits(struct vnic_intr *intr,
-	unsigned int credits, int unmask, int reset_timer)
-{
-#define VNIC_INTR_UNMASK_SHIFT		16
-#define VNIC_INTR_RESET_TIMER_SHIFT	17
-
-	u32 int_credit_return = (credits & 0xffff) |
-		(unmask ? (1 << VNIC_INTR_UNMASK_SHIFT) : 0) |
-		(reset_timer ? (1 << VNIC_INTR_RESET_TIMER_SHIFT) : 0);
-
-	iowrite32(int_credit_return, &intr->ctrl->int_credit_return);
-}
-
-static inline unsigned int vnic_intr_credits(struct vnic_intr *intr)
-{
-	return ioread32(&intr->ctrl->int_credits);
-}
-
-static inline void vnic_intr_return_all_credits(struct vnic_intr *intr)
-{
-	unsigned int credits = vnic_intr_credits(intr);
-	int unmask = 1;
-	int reset_timer = 1;
-
-	vnic_intr_return_credits(intr, credits, unmask, reset_timer);
-}
-
-static inline u32 vnic_intr_legacy_pba(u32 __iomem *legacy_pba)
-{
-	/* read PBA without clearing */
-	return ioread32(legacy_pba);
-}
-
-void vnic_intr_free(struct vnic_intr *intr);
-int vnic_intr_alloc(struct vnic_dev *vdev, struct vnic_intr *intr,
-	unsigned int index);
-void vnic_intr_init(struct vnic_intr *intr, unsigned int coalescing_timer,
-	unsigned int coalescing_type, unsigned int mask_on_assertion);
-void vnic_intr_clean(struct vnic_intr *intr);
-
-#endif /* _VNIC_INTR_H_ */
diff --git a/drivers/scsi/fnic/vnic_nic.h b/drivers/scsi/fnic/vnic_nic.h
deleted file mode 100644
index f15b83e..0000000
--- a/drivers/scsi/fnic/vnic_nic.h
+++ /dev/null
@@ -1,69 +0,0 @@
-/*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
- * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
- *
- * This program is free software; you may redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; version 2 of the License.
- *
- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
- * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
- * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
- * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
- * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
- * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
- * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
- * SOFTWARE.
- */
-#ifndef _VNIC_NIC_H_
-#define _VNIC_NIC_H_
-
-/*
- * These defines avoid symbol clash between fnic and enic (Cisco 10G Eth
- * Driver) when both are built with CONFIG options =y
- */
-#define vnic_set_nic_cfg fnic_set_nic_cfg
-
-#define NIC_CFG_RSS_DEFAULT_CPU_MASK_FIELD	0xffUL
-#define NIC_CFG_RSS_DEFAULT_CPU_SHIFT		0
-#define NIC_CFG_RSS_HASH_TYPE			(0xffUL << 8)
-#define NIC_CFG_RSS_HASH_TYPE_MASK_FIELD	0xffUL
-#define NIC_CFG_RSS_HASH_TYPE_SHIFT		8
-#define NIC_CFG_RSS_HASH_BITS			(7UL << 16)
-#define NIC_CFG_RSS_HASH_BITS_MASK_FIELD	7UL
-#define NIC_CFG_RSS_HASH_BITS_SHIFT		16
-#define NIC_CFG_RSS_BASE_CPU			(7UL << 19)
-#define NIC_CFG_RSS_BASE_CPU_MASK_FIELD		7UL
-#define NIC_CFG_RSS_BASE_CPU_SHIFT		19
-#define NIC_CFG_RSS_ENABLE			(1UL << 22)
-#define NIC_CFG_RSS_ENABLE_MASK_FIELD		1UL
-#define NIC_CFG_RSS_ENABLE_SHIFT		22
-#define NIC_CFG_TSO_IPID_SPLIT_EN		(1UL << 23)
-#define NIC_CFG_TSO_IPID_SPLIT_EN_MASK_FIELD	1UL
-#define NIC_CFG_TSO_IPID_SPLIT_EN_SHIFT		23
-#define NIC_CFG_IG_VLAN_STRIP_EN		(1UL << 24)
-#define NIC_CFG_IG_VLAN_STRIP_EN_MASK_FIELD	1UL
-#define NIC_CFG_IG_VLAN_STRIP_EN_SHIFT		24
-
-static inline void vnic_set_nic_cfg(u32 *nic_cfg,
-	u8 rss_default_cpu, u8 rss_hash_type,
-	u8 rss_hash_bits, u8 rss_base_cpu,
-	u8 rss_enable, u8 tso_ipid_split_en,
-	u8 ig_vlan_strip_en)
-{
-	*nic_cfg = (rss_default_cpu & NIC_CFG_RSS_DEFAULT_CPU_MASK_FIELD) |
-		((rss_hash_type & NIC_CFG_RSS_HASH_TYPE_MASK_FIELD)
-			<< NIC_CFG_RSS_HASH_TYPE_SHIFT) |
-		((rss_hash_bits & NIC_CFG_RSS_HASH_BITS_MASK_FIELD)
-			<< NIC_CFG_RSS_HASH_BITS_SHIFT) |
-		((rss_base_cpu & NIC_CFG_RSS_BASE_CPU_MASK_FIELD)
-			<< NIC_CFG_RSS_BASE_CPU_SHIFT) |
-		((rss_enable & NIC_CFG_RSS_ENABLE_MASK_FIELD)
-			<< NIC_CFG_RSS_ENABLE_SHIFT) |
-		((tso_ipid_split_en & NIC_CFG_TSO_IPID_SPLIT_EN_MASK_FIELD)
-			<< NIC_CFG_TSO_IPID_SPLIT_EN_SHIFT) |
-		((ig_vlan_strip_en & NIC_CFG_IG_VLAN_STRIP_EN_MASK_FIELD)
-			<< NIC_CFG_IG_VLAN_STRIP_EN_SHIFT);
-}
-
-#endif /* _VNIC_NIC_H_ */
diff --git a/drivers/scsi/fnic/vnic_resource.h b/drivers/scsi/fnic/vnic_resource.h
deleted file mode 100644
index 2d842f7..0000000
--- a/drivers/scsi/fnic/vnic_resource.h
+++ /dev/null
@@ -1,61 +0,0 @@
-/*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
- * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
- *
- * This program is free software; you may redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; version 2 of the License.
- *
- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
- * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
- * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
- * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
- * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
- * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
- * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
- * SOFTWARE.
- */
-#ifndef _VNIC_RESOURCE_H_
-#define _VNIC_RESOURCE_H_
-
-#define VNIC_RES_MAGIC		0x766E6963L	/* 'vnic' */
-#define VNIC_RES_VERSION	0x00000000L
-
-/* vNIC resource types */
-enum vnic_res_type {
-	RES_TYPE_EOL,			/* End-of-list */
-	RES_TYPE_WQ,			/* Work queues */
-	RES_TYPE_RQ,			/* Receive queues */
-	RES_TYPE_CQ,			/* Completion queues */
-	RES_TYPE_RSVD1,
-	RES_TYPE_NIC_CFG,		/* Enet NIC config registers */
-	RES_TYPE_RSVD2,
-	RES_TYPE_RSVD3,
-	RES_TYPE_RSVD4,
-	RES_TYPE_RSVD5,
-	RES_TYPE_INTR_CTRL,		/* Interrupt ctrl table */
-	RES_TYPE_INTR_TABLE,		/* MSI/MSI-X Interrupt table */
-	RES_TYPE_INTR_PBA,		/* MSI/MSI-X PBA table */
-	RES_TYPE_INTR_PBA_LEGACY,	/* Legacy intr status */
-	RES_TYPE_RSVD6,
-	RES_TYPE_RSVD7,
-	RES_TYPE_DEVCMD,		/* Device command region */
-	RES_TYPE_PASS_THRU_PAGE,	/* Pass-thru page */
-
-	RES_TYPE_MAX,			/* Count of resource types */
-};
-
-struct vnic_resource_header {
-	u32 magic;
-	u32 version;
-};
-
-struct vnic_resource {
-	u8 type;
-	u8 bar;
-	u8 pad[2];
-	u32 bar_offset;
-	u32 count;
-};
-
-#endif /* _VNIC_RESOURCE_H_ */
diff --git a/drivers/scsi/fnic/vnic_rq.c b/drivers/scsi/fnic/vnic_rq.c
deleted file mode 100644
index bedd0d2..0000000
--- a/drivers/scsi/fnic/vnic_rq.c
+++ /dev/null
@@ -1,196 +0,0 @@
-/*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
- * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
- *
- * This program is free software; you may redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; version 2 of the License.
- *
- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
- * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
- * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
- * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
- * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
- * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
- * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
- * SOFTWARE.
- */
-
-#include <linux/errno.h>
-#include <linux/types.h>
-#include <linux/pci.h>
-#include <linux/delay.h>
-#include "vnic_dev.h"
-#include "vnic_rq.h"
-
-static int vnic_rq_alloc_bufs(struct vnic_rq *rq)
-{
-	struct vnic_rq_buf *buf;
-	struct vnic_dev *vdev;
-	unsigned int i, j, count = rq->ring.desc_count;
-	unsigned int blks = VNIC_RQ_BUF_BLKS_NEEDED(count);
-
-	vdev = rq->vdev;
-
-	for (i = 0; i < blks; i++) {
-		rq->bufs[i] = kzalloc(VNIC_RQ_BUF_BLK_SZ, GFP_ATOMIC);
-		if (!rq->bufs[i]) {
-			printk(KERN_ERR "Failed to alloc rq_bufs\n");
-			return -ENOMEM;
-		}
-	}
-
-	for (i = 0; i < blks; i++) {
-		buf = rq->bufs[i];
-		for (j = 0; j < VNIC_RQ_BUF_BLK_ENTRIES; j++) {
-			buf->index = i * VNIC_RQ_BUF_BLK_ENTRIES + j;
-			buf->desc = (u8 *)rq->ring.descs +
-				rq->ring.desc_size * buf->index;
-			if (buf->index + 1 == count) {
-				buf->next = rq->bufs[0];
-				break;
-			} else if (j + 1 == VNIC_RQ_BUF_BLK_ENTRIES) {
-				buf->next = rq->bufs[i + 1];
-			} else {
-				buf->next = buf + 1;
-				buf++;
-			}
-		}
-	}
-
-	rq->to_use = rq->to_clean = rq->bufs[0];
-	rq->buf_index = 0;
-
-	return 0;
-}
-
-void vnic_rq_free(struct vnic_rq *rq)
-{
-	struct vnic_dev *vdev;
-	unsigned int i;
-
-	vdev = rq->vdev;
-
-	vnic_dev_free_desc_ring(vdev, &rq->ring);
-
-	for (i = 0; i < VNIC_RQ_BUF_BLKS_MAX; i++) {
-		kfree(rq->bufs[i]);
-		rq->bufs[i] = NULL;
-	}
-
-	rq->ctrl = NULL;
-}
-
-int vnic_rq_alloc(struct vnic_dev *vdev, struct vnic_rq *rq, unsigned int index,
-	unsigned int desc_count, unsigned int desc_size)
-{
-	int err;
-
-	rq->index = index;
-	rq->vdev = vdev;
-
-	rq->ctrl = vnic_dev_get_res(vdev, RES_TYPE_RQ, index);
-	if (!rq->ctrl) {
-		printk(KERN_ERR "Failed to hook RQ[%d] resource\n", index);
-		return -EINVAL;
-	}
-
-	vnic_rq_disable(rq);
-
-	err = vnic_dev_alloc_desc_ring(vdev, &rq->ring, desc_count, desc_size);
-	if (err)
-		return err;
-
-	err = vnic_rq_alloc_bufs(rq);
-	if (err) {
-		vnic_rq_free(rq);
-		return err;
-	}
-
-	return 0;
-}
-
-void vnic_rq_init(struct vnic_rq *rq, unsigned int cq_index,
-	unsigned int error_interrupt_enable,
-	unsigned int error_interrupt_offset)
-{
-	u64 paddr;
-	u32 fetch_index;
-
-	paddr = (u64)rq->ring.base_addr | VNIC_PADDR_TARGET;
-	writeq(paddr, &rq->ctrl->ring_base);
-	iowrite32(rq->ring.desc_count, &rq->ctrl->ring_size);
-	iowrite32(cq_index, &rq->ctrl->cq_index);
-	iowrite32(error_interrupt_enable, &rq->ctrl->error_interrupt_enable);
-	iowrite32(error_interrupt_offset, &rq->ctrl->error_interrupt_offset);
-	iowrite32(0, &rq->ctrl->dropped_packet_count);
-	iowrite32(0, &rq->ctrl->error_status);
-
-	/* Use current fetch_index as the ring starting point */
-	fetch_index = ioread32(&rq->ctrl->fetch_index);
-	rq->to_use = rq->to_clean =
-		&rq->bufs[fetch_index / VNIC_RQ_BUF_BLK_ENTRIES]
-			[fetch_index % VNIC_RQ_BUF_BLK_ENTRIES];
-	iowrite32(fetch_index, &rq->ctrl->posted_index);
-
-	rq->buf_index = 0;
-}
-
-unsigned int vnic_rq_error_status(struct vnic_rq *rq)
-{
-	return ioread32(&rq->ctrl->error_status);
-}
-
-void vnic_rq_enable(struct vnic_rq *rq)
-{
-	iowrite32(1, &rq->ctrl->enable);
-}
-
-int vnic_rq_disable(struct vnic_rq *rq)
-{
-	unsigned int wait;
-
-	iowrite32(0, &rq->ctrl->enable);
-
-	/* Wait for HW to ACK disable request */
-	for (wait = 0; wait < 100; wait++) {
-		if (!(ioread32(&rq->ctrl->running)))
-			return 0;
-		udelay(1);
-	}
-
-	printk(KERN_ERR "Failed to disable RQ[%d]\n", rq->index);
-
-	return -ETIMEDOUT;
-}
-
-void vnic_rq_clean(struct vnic_rq *rq,
-	void (*buf_clean)(struct vnic_rq *rq, struct vnic_rq_buf *buf))
-{
-	struct vnic_rq_buf *buf;
-	u32 fetch_index;
-
-	BUG_ON(ioread32(&rq->ctrl->enable));
-
-	buf = rq->to_clean;
-
-	while (vnic_rq_desc_used(rq) > 0) {
-
-		(*buf_clean)(rq, buf);
-
-		buf = rq->to_clean = buf->next;
-		rq->ring.desc_avail++;
-	}
-
-	/* Use current fetch_index as the ring starting point */
-	fetch_index = ioread32(&rq->ctrl->fetch_index);
-	rq->to_use = rq->to_clean =
-		&rq->bufs[fetch_index / VNIC_RQ_BUF_BLK_ENTRIES]
-			[fetch_index % VNIC_RQ_BUF_BLK_ENTRIES];
-	iowrite32(fetch_index, &rq->ctrl->posted_index);
-
-	rq->buf_index = 0;
-
-	vnic_dev_clear_desc_ring(&rq->ring);
-}
-
diff --git a/drivers/scsi/fnic/vnic_rq.h b/drivers/scsi/fnic/vnic_rq.h
deleted file mode 100644
index aebdfbd..0000000
--- a/drivers/scsi/fnic/vnic_rq.h
+++ /dev/null
@@ -1,235 +0,0 @@
-/*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
- * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
- *
- * This program is free software; you may redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; version 2 of the License.
- *
- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
- * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
- * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
- * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
- * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
- * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
- * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
- * SOFTWARE.
- */
-#ifndef _VNIC_RQ_H_
-#define _VNIC_RQ_H_
-
-#include <linux/pci.h>
-#include "vnic_dev.h"
-#include "vnic_cq.h"
-
-/*
- * These defines avoid symbol clash between fnic and enic (Cisco 10G Eth
- * Driver) when both are built with CONFIG options =y
- */
-#define vnic_rq_desc_avail fnic_rq_desc_avail
-#define vnic_rq_desc_used fnic_rq_desc_used
-#define vnic_rq_next_desc fnic_rq_next_desc
-#define vnic_rq_next_index fnic_rq_next_index
-#define vnic_rq_next_buf_index fnic_rq_next_buf_index
-#define vnic_rq_post fnic_rq_post
-#define vnic_rq_posting_soon fnic_rq_posting_soon
-#define vnic_rq_return_descs fnic_rq_return_descs
-#define vnic_rq_service fnic_rq_service
-#define vnic_rq_fill fnic_rq_fill
-#define vnic_rq_free fnic_rq_free
-#define vnic_rq_alloc fnic_rq_alloc
-#define vnic_rq_init fnic_rq_init
-#define vnic_rq_error_status fnic_rq_error_status
-#define vnic_rq_enable fnic_rq_enable
-#define vnic_rq_disable fnic_rq_disable
-#define vnic_rq_clean fnic_rq_clean
-
-/* Receive queue control */
-struct vnic_rq_ctrl {
-	u64 ring_base;			/* 0x00 */
-	u32 ring_size;			/* 0x08 */
-	u32 pad0;
-	u32 posted_index;		/* 0x10 */
-	u32 pad1;
-	u32 cq_index;			/* 0x18 */
-	u32 pad2;
-	u32 enable;			/* 0x20 */
-	u32 pad3;
-	u32 running;			/* 0x28 */
-	u32 pad4;
-	u32 fetch_index;		/* 0x30 */
-	u32 pad5;
-	u32 error_interrupt_enable;	/* 0x38 */
-	u32 pad6;
-	u32 error_interrupt_offset;	/* 0x40 */
-	u32 pad7;
-	u32 error_status;		/* 0x48 */
-	u32 pad8;
-	u32 dropped_packet_count;	/* 0x50 */
-	u32 pad9;
-	u32 dropped_packet_count_rc;	/* 0x58 */
-	u32 pad10;
-};
-
-/* Break the vnic_rq_buf allocations into blocks of 64 entries */
-#define VNIC_RQ_BUF_BLK_ENTRIES 64
-#define VNIC_RQ_BUF_BLK_SZ \
-	(VNIC_RQ_BUF_BLK_ENTRIES * sizeof(struct vnic_rq_buf))
-#define VNIC_RQ_BUF_BLKS_NEEDED(entries) \
-	DIV_ROUND_UP(entries, VNIC_RQ_BUF_BLK_ENTRIES)
-#define VNIC_RQ_BUF_BLKS_MAX VNIC_RQ_BUF_BLKS_NEEDED(4096)
-
-struct vnic_rq_buf {
-	struct vnic_rq_buf *next;
-	dma_addr_t dma_addr;
-	void *os_buf;
-	unsigned int os_buf_index;
-	unsigned int len;
-	unsigned int index;
-	void *desc;
-};
-
-struct vnic_rq {
-	unsigned int index;
-	struct vnic_dev *vdev;
-	struct vnic_rq_ctrl __iomem *ctrl;	/* memory-mapped */
-	struct vnic_dev_ring ring;
-	struct vnic_rq_buf *bufs[VNIC_RQ_BUF_BLKS_MAX];
-	struct vnic_rq_buf *to_use;
-	struct vnic_rq_buf *to_clean;
-	void *os_buf_head;
-	unsigned int buf_index;
-	unsigned int pkts_outstanding;
-};
-
-static inline unsigned int vnic_rq_desc_avail(struct vnic_rq *rq)
-{
-	/* how many does SW own? */
-	return rq->ring.desc_avail;
-}
-
-static inline unsigned int vnic_rq_desc_used(struct vnic_rq *rq)
-{
-	/* how many does HW own? */
-	return rq->ring.desc_count - rq->ring.desc_avail - 1;
-}
-
-static inline void *vnic_rq_next_desc(struct vnic_rq *rq)
-{
-	return rq->to_use->desc;
-}
-
-static inline unsigned int vnic_rq_next_index(struct vnic_rq *rq)
-{
-	return rq->to_use->index;
-}
-
-static inline unsigned int vnic_rq_next_buf_index(struct vnic_rq *rq)
-{
-	return rq->buf_index++;
-}
-
-static inline void vnic_rq_post(struct vnic_rq *rq,
-	void *os_buf, unsigned int os_buf_index,
-	dma_addr_t dma_addr, unsigned int len)
-{
-	struct vnic_rq_buf *buf = rq->to_use;
-
-	buf->os_buf = os_buf;
-	buf->os_buf_index = os_buf_index;
-	buf->dma_addr = dma_addr;
-	buf->len = len;
-
-	buf = buf->next;
-	rq->to_use = buf;
-	rq->ring.desc_avail--;
-
-	/* Move the posted_index every nth descriptor
-	 */
-
-#ifndef VNIC_RQ_RETURN_RATE
-#define VNIC_RQ_RETURN_RATE		0xf	/* keep 2^n - 1 */
-#endif
-
-	if ((buf->index & VNIC_RQ_RETURN_RATE) == 0) {
-		/* Adding write memory barrier prevents compiler and/or CPU
-		 * reordering, thus avoiding descriptor posting before
-		 * descriptor is initialized. Otherwise, hardware can read
-		 * stale descriptor fields.
-		 */
-		wmb();
-		iowrite32(buf->index, &rq->ctrl->posted_index);
-	}
-}
-
-static inline int vnic_rq_posting_soon(struct vnic_rq *rq)
-{
-	return (rq->to_use->index & VNIC_RQ_RETURN_RATE) == 0;
-}
-
-static inline void vnic_rq_return_descs(struct vnic_rq *rq, unsigned int count)
-{
-	rq->ring.desc_avail += count;
-}
-
-enum desc_return_options {
-	VNIC_RQ_RETURN_DESC,
-	VNIC_RQ_DEFER_RETURN_DESC,
-};
-
-static inline void vnic_rq_service(struct vnic_rq *rq,
-	struct cq_desc *cq_desc, u16 completed_index,
-	int desc_return, void (*buf_service)(struct vnic_rq *rq,
-	struct cq_desc *cq_desc, struct vnic_rq_buf *buf,
-	int skipped, void *opaque), void *opaque)
-{
-	struct vnic_rq_buf *buf;
-	int skipped;
-
-	buf = rq->to_clean;
-	while (1) {
-
-		skipped = (buf->index != completed_index);
-
-		(*buf_service)(rq, cq_desc, buf, skipped, opaque);
-
-		if (desc_return == VNIC_RQ_RETURN_DESC)
-			rq->ring.desc_avail++;
-
-		rq->to_clean = buf->next;
-
-		if (!skipped)
-			break;
-
-		buf = rq->to_clean;
-	}
-}
-
-static inline int vnic_rq_fill(struct vnic_rq *rq,
-	int (*buf_fill)(struct vnic_rq *rq))
-{
-	int err;
-
-	while (vnic_rq_desc_avail(rq) > 1) {
-
-		err = (*buf_fill)(rq);
-		if (err)
-			return err;
-	}
-
-	return 0;
-}
-
-void vnic_rq_free(struct vnic_rq *rq);
-int vnic_rq_alloc(struct vnic_dev *vdev, struct vnic_rq *rq, unsigned int index,
-	unsigned int desc_count, unsigned int desc_size);
-void vnic_rq_init(struct vnic_rq *rq, unsigned int cq_index,
-	unsigned int error_interrupt_enable,
-	unsigned int error_interrupt_offset);
-unsigned int vnic_rq_error_status(struct vnic_rq *rq);
-void vnic_rq_enable(struct vnic_rq *rq);
-int vnic_rq_disable(struct vnic_rq *rq);
-void vnic_rq_clean(struct vnic_rq *rq,
-	void (*buf_clean)(struct vnic_rq *rq, struct vnic_rq_buf *buf));
-
-#endif /* _VNIC_RQ_H_ */
diff --git a/drivers/scsi/fnic/vnic_stats.h b/drivers/scsi/fnic/vnic_stats.h
deleted file mode 100644
index 5372e23..0000000
--- a/drivers/scsi/fnic/vnic_stats.h
+++ /dev/null
@@ -1,68 +0,0 @@
-/*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
- * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
- *
- * This program is free software; you may redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; version 2 of the License.
- *
- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
- * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
- * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
- * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
- * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
- * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
- * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
- * SOFTWARE.
- */
-#ifndef _VNIC_STATS_H_
-#define _VNIC_STATS_H_
-
-/* Tx statistics */
-struct vnic_tx_stats {
-	u64 tx_frames_ok;
-	u64 tx_unicast_frames_ok;
-	u64 tx_multicast_frames_ok;
-	u64 tx_broadcast_frames_ok;
-	u64 tx_bytes_ok;
-	u64 tx_unicast_bytes_ok;
-	u64 tx_multicast_bytes_ok;
-	u64 tx_broadcast_bytes_ok;
-	u64 tx_drops;
-	u64 tx_errors;
-	u64 tx_tso;
-	u64 rsvd[16];
-};
-
-/* Rx statistics */
-struct vnic_rx_stats {
-	u64 rx_frames_ok;
-	u64 rx_frames_total;
-	u64 rx_unicast_frames_ok;
-	u64 rx_multicast_frames_ok;
-	u64 rx_broadcast_frames_ok;
-	u64 rx_bytes_ok;
-	u64 rx_unicast_bytes_ok;
-	u64 rx_multicast_bytes_ok;
-	u64 rx_broadcast_bytes_ok;
-	u64 rx_drop;
-	u64 rx_no_bufs;
-	u64 rx_errors;
-	u64 rx_rss;
-	u64 rx_crc_errors;
-	u64 rx_frames_64;
-	u64 rx_frames_127;
-	u64 rx_frames_255;
-	u64 rx_frames_511;
-	u64 rx_frames_1023;
-	u64 rx_frames_1518;
-	u64 rx_frames_to_max;
-	u64 rsvd[16];
-};
-
-struct vnic_stats {
-	struct vnic_tx_stats tx;
-	struct vnic_rx_stats rx;
-};
-
-#endif /* _VNIC_STATS_H_ */
diff --git a/drivers/scsi/fnic/vnic_wq.c b/drivers/scsi/fnic/vnic_wq.c
deleted file mode 100644
index 1f9ea79..0000000
--- a/drivers/scsi/fnic/vnic_wq.c
+++ /dev/null
@@ -1,182 +0,0 @@
-/*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
- * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
- *
- * This program is free software; you may redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; version 2 of the License.
- *
- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
- * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
- * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
- * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
- * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
- * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
- * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
- * SOFTWARE.
- */
-
-#include <linux/errno.h>
-#include <linux/types.h>
-#include <linux/pci.h>
-#include <linux/delay.h>
-#include "vnic_dev.h"
-#include "vnic_wq.h"
-
-static int vnic_wq_alloc_bufs(struct vnic_wq *wq)
-{
-	struct vnic_wq_buf *buf;
-	struct vnic_dev *vdev;
-	unsigned int i, j, count = wq->ring.desc_count;
-	unsigned int blks = VNIC_WQ_BUF_BLKS_NEEDED(count);
-
-	vdev = wq->vdev;
-
-	for (i = 0; i < blks; i++) {
-		wq->bufs[i] = kzalloc(VNIC_WQ_BUF_BLK_SZ, GFP_ATOMIC);
-		if (!wq->bufs[i]) {
-			printk(KERN_ERR "Failed to alloc wq_bufs\n");
-			return -ENOMEM;
-		}
-	}
-
-	for (i = 0; i < blks; i++) {
-		buf = wq->bufs[i];
-		for (j = 0; j < VNIC_WQ_BUF_BLK_ENTRIES; j++) {
-			buf->index = i * VNIC_WQ_BUF_BLK_ENTRIES + j;
-			buf->desc = (u8 *)wq->ring.descs +
-				wq->ring.desc_size * buf->index;
-			if (buf->index + 1 == count) {
-				buf->next = wq->bufs[0];
-				break;
-			} else if (j + 1 == VNIC_WQ_BUF_BLK_ENTRIES) {
-				buf->next = wq->bufs[i + 1];
-			} else {
-				buf->next = buf + 1;
-				buf++;
-			}
-		}
-	}
-
-	wq->to_use = wq->to_clean = wq->bufs[0];
-
-	return 0;
-}
-
-void vnic_wq_free(struct vnic_wq *wq)
-{
-	struct vnic_dev *vdev;
-	unsigned int i;
-
-	vdev = wq->vdev;
-
-	vnic_dev_free_desc_ring(vdev, &wq->ring);
-
-	for (i = 0; i < VNIC_WQ_BUF_BLKS_MAX; i++) {
-		kfree(wq->bufs[i]);
-		wq->bufs[i] = NULL;
-	}
-
-	wq->ctrl = NULL;
-
-}
-
-int vnic_wq_alloc(struct vnic_dev *vdev, struct vnic_wq *wq, unsigned int index,
-	unsigned int desc_count, unsigned int desc_size)
-{
-	int err;
-
-	wq->index = index;
-	wq->vdev = vdev;
-
-	wq->ctrl = vnic_dev_get_res(vdev, RES_TYPE_WQ, index);
-	if (!wq->ctrl) {
-		printk(KERN_ERR "Failed to hook WQ[%d] resource\n", index);
-		return -EINVAL;
-	}
-
-	vnic_wq_disable(wq);
-
-	err = vnic_dev_alloc_desc_ring(vdev, &wq->ring, desc_count, desc_size);
-	if (err)
-		return err;
-
-	err = vnic_wq_alloc_bufs(wq);
-	if (err) {
-		vnic_wq_free(wq);
-		return err;
-	}
-
-	return 0;
-}
-
-void vnic_wq_init(struct vnic_wq *wq, unsigned int cq_index,
-	unsigned int error_interrupt_enable,
-	unsigned int error_interrupt_offset)
-{
-	u64 paddr;
-
-	paddr = (u64)wq->ring.base_addr | VNIC_PADDR_TARGET;
-	writeq(paddr, &wq->ctrl->ring_base);
-	iowrite32(wq->ring.desc_count, &wq->ctrl->ring_size);
-	iowrite32(0, &wq->ctrl->fetch_index);
-	iowrite32(0, &wq->ctrl->posted_index);
-	iowrite32(cq_index, &wq->ctrl->cq_index);
-	iowrite32(error_interrupt_enable, &wq->ctrl->error_interrupt_enable);
-	iowrite32(error_interrupt_offset, &wq->ctrl->error_interrupt_offset);
-	iowrite32(0, &wq->ctrl->error_status);
-}
-
-unsigned int vnic_wq_error_status(struct vnic_wq *wq)
-{
-	return ioread32(&wq->ctrl->error_status);
-}
-
-void vnic_wq_enable(struct vnic_wq *wq)
-{
-	iowrite32(1, &wq->ctrl->enable);
-}
-
-int vnic_wq_disable(struct vnic_wq *wq)
-{
-	unsigned int wait;
-
-	iowrite32(0, &wq->ctrl->enable);
-
-	/* Wait for HW to ACK disable request */
-	for (wait = 0; wait < 100; wait++) {
-		if (!(ioread32(&wq->ctrl->running)))
-			return 0;
-		udelay(1);
-	}
-
-	printk(KERN_ERR "Failed to disable WQ[%d]\n", wq->index);
-
-	return -ETIMEDOUT;
-}
-
-void vnic_wq_clean(struct vnic_wq *wq,
-	void (*buf_clean)(struct vnic_wq *wq, struct vnic_wq_buf *buf))
-{
-	struct vnic_wq_buf *buf;
-
-	BUG_ON(ioread32(&wq->ctrl->enable));
-
-	buf = wq->to_clean;
-
-	while (vnic_wq_desc_used(wq) > 0) {
-
-		(*buf_clean)(wq, buf);
-
-		buf = wq->to_clean = buf->next;
-		wq->ring.desc_avail++;
-	}
-
-	wq->to_use = wq->to_clean = wq->bufs[0];
-
-	iowrite32(0, &wq->ctrl->fetch_index);
-	iowrite32(0, &wq->ctrl->posted_index);
-	iowrite32(0, &wq->ctrl->error_status);
-
-	vnic_dev_clear_desc_ring(&wq->ring);
-}
diff --git a/drivers/scsi/fnic/vnic_wq.h b/drivers/scsi/fnic/vnic_wq.h
deleted file mode 100644
index 5cd094f..0000000
--- a/drivers/scsi/fnic/vnic_wq.h
+++ /dev/null
@@ -1,175 +0,0 @@
-/*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
- * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
- *
- * This program is free software; you may redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; version 2 of the License.
- *
- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
- * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
- * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
- * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
- * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
- * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
- * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
- * SOFTWARE.
- */
-#ifndef _VNIC_WQ_H_
-#define _VNIC_WQ_H_
-
-#include <linux/pci.h>
-#include "vnic_dev.h"
-#include "vnic_cq.h"
-
-/*
- * These defines avoid symbol clash between fnic and enic (Cisco 10G Eth
- * Driver) when both are built with CONFIG options =y
- */
-#define vnic_wq_desc_avail fnic_wq_desc_avail
-#define vnic_wq_desc_used fnic_wq_desc_used
-#define vnic_wq_next_desc fni_cwq_next_desc
-#define vnic_wq_post fnic_wq_post
-#define vnic_wq_service fnic_wq_service
-#define vnic_wq_free fnic_wq_free
-#define vnic_wq_alloc fnic_wq_alloc
-#define vnic_wq_init fnic_wq_init
-#define vnic_wq_error_status fnic_wq_error_status
-#define vnic_wq_enable fnic_wq_enable
-#define vnic_wq_disable fnic_wq_disable
-#define vnic_wq_clean fnic_wq_clean
-
-/* Work queue control */
-struct vnic_wq_ctrl {
-	u64 ring_base;			/* 0x00 */
-	u32 ring_size;			/* 0x08 */
-	u32 pad0;
-	u32 posted_index;		/* 0x10 */
-	u32 pad1;
-	u32 cq_index;			/* 0x18 */
-	u32 pad2;
-	u32 enable;			/* 0x20 */
-	u32 pad3;
-	u32 running;			/* 0x28 */
-	u32 pad4;
-	u32 fetch_index;		/* 0x30 */
-	u32 pad5;
-	u32 dca_value;			/* 0x38 */
-	u32 pad6;
-	u32 error_interrupt_enable;	/* 0x40 */
-	u32 pad7;
-	u32 error_interrupt_offset;	/* 0x48 */
-	u32 pad8;
-	u32 error_status;		/* 0x50 */
-	u32 pad9;
-};
-
-struct vnic_wq_buf {
-	struct vnic_wq_buf *next;
-	dma_addr_t dma_addr;
-	void *os_buf;
-	unsigned int len;
-	unsigned int index;
-	int sop;
-	void *desc;
-};
-
-/* Break the vnic_wq_buf allocations into blocks of 64 entries */
-#define VNIC_WQ_BUF_BLK_ENTRIES 64
-#define VNIC_WQ_BUF_BLK_SZ \
-	(VNIC_WQ_BUF_BLK_ENTRIES * sizeof(struct vnic_wq_buf))
-#define VNIC_WQ_BUF_BLKS_NEEDED(entries) \
-	DIV_ROUND_UP(entries, VNIC_WQ_BUF_BLK_ENTRIES)
-#define VNIC_WQ_BUF_BLKS_MAX VNIC_WQ_BUF_BLKS_NEEDED(4096)
-
-struct vnic_wq {
-	unsigned int index;
-	struct vnic_dev *vdev;
-	struct vnic_wq_ctrl __iomem *ctrl;	/* memory-mapped */
-	struct vnic_dev_ring ring;
-	struct vnic_wq_buf *bufs[VNIC_WQ_BUF_BLKS_MAX];
-	struct vnic_wq_buf *to_use;
-	struct vnic_wq_buf *to_clean;
-	unsigned int pkts_outstanding;
-};
-
-static inline unsigned int vnic_wq_desc_avail(struct vnic_wq *wq)
-{
-	/* how many does SW own? */
-	return wq->ring.desc_avail;
-}
-
-static inline unsigned int vnic_wq_desc_used(struct vnic_wq *wq)
-{
-	/* how many does HW own? */
-	return wq->ring.desc_count - wq->ring.desc_avail - 1;
-}
-
-static inline void *vnic_wq_next_desc(struct vnic_wq *wq)
-{
-	return wq->to_use->desc;
-}
-
-static inline void vnic_wq_post(struct vnic_wq *wq,
-	void *os_buf, dma_addr_t dma_addr,
-	unsigned int len, int sop, int eop)
-{
-	struct vnic_wq_buf *buf = wq->to_use;
-
-	buf->sop = sop;
-	buf->os_buf = eop ? os_buf : NULL;
-	buf->dma_addr = dma_addr;
-	buf->len = len;
-
-	buf = buf->next;
-	if (eop) {
-		/* Adding write memory barrier prevents compiler and/or CPU
-		 * reordering, thus avoiding descriptor posting before
-		 * descriptor is initialized. Otherwise, hardware can read
-		 * stale descriptor fields.
-		 */
-		wmb();
-		iowrite32(buf->index, &wq->ctrl->posted_index);
-	}
-	wq->to_use = buf;
-
-	wq->ring.desc_avail--;
-}
-
-static inline void vnic_wq_service(struct vnic_wq *wq,
-	struct cq_desc *cq_desc, u16 completed_index,
-	void (*buf_service)(struct vnic_wq *wq,
-	struct cq_desc *cq_desc, struct vnic_wq_buf *buf, void *opaque),
-	void *opaque)
-{
-	struct vnic_wq_buf *buf;
-
-	buf = wq->to_clean;
-	while (1) {
-
-		(*buf_service)(wq, cq_desc, buf, opaque);
-
-		wq->ring.desc_avail++;
-
-		wq->to_clean = buf->next;
-
-		if (buf->index == completed_index)
-			break;
-
-		buf = wq->to_clean;
-	}
-}
-
-void vnic_wq_free(struct vnic_wq *wq);
-int vnic_wq_alloc(struct vnic_dev *vdev, struct vnic_wq *wq, unsigned int index,
-	unsigned int desc_count, unsigned int desc_size);
-void vnic_wq_init(struct vnic_wq *wq, unsigned int cq_index,
-	unsigned int error_interrupt_enable,
-	unsigned int error_interrupt_offset);
-unsigned int vnic_wq_error_status(struct vnic_wq *wq);
-void vnic_wq_enable(struct vnic_wq *wq);
-int vnic_wq_disable(struct vnic_wq *wq);
-void vnic_wq_clean(struct vnic_wq *wq,
-	void (*buf_clean)(struct vnic_wq *wq, struct vnic_wq_buf *buf));
-
-#endif /* _VNIC_WQ_H_ */
diff --git a/drivers/scsi/fnic/wq_enet_desc.h b/drivers/scsi/fnic/wq_enet_desc.h
deleted file mode 100644
index b121cba..0000000
--- a/drivers/scsi/fnic/wq_enet_desc.h
+++ /dev/null
@@ -1,96 +0,0 @@
-/*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
- * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
- *
- * This program is free software; you may redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; version 2 of the License.
- *
- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
- * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
- * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
- * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
- * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
- * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
- * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
- * SOFTWARE.
- */
-#ifndef _WQ_ENET_DESC_H_
-#define _WQ_ENET_DESC_H_
-
-/* Ethernet work queue descriptor: 16B */
-struct wq_enet_desc {
-	__le64 address;
-	__le16 length;
-	__le16 mss_loopback;
-	__le16 header_length_flags;
-	__le16 vlan_tag;
-};
-
-#define WQ_ENET_ADDR_BITS		64
-#define WQ_ENET_LEN_BITS		14
-#define WQ_ENET_LEN_MASK		((1 << WQ_ENET_LEN_BITS) - 1)
-#define WQ_ENET_MSS_BITS		14
-#define WQ_ENET_MSS_MASK		((1 << WQ_ENET_MSS_BITS) - 1)
-#define WQ_ENET_MSS_SHIFT		2
-#define WQ_ENET_LOOPBACK_SHIFT		1
-#define WQ_ENET_HDRLEN_BITS		10
-#define WQ_ENET_HDRLEN_MASK		((1 << WQ_ENET_HDRLEN_BITS) - 1)
-#define WQ_ENET_FLAGS_OM_BITS		2
-#define WQ_ENET_FLAGS_OM_MASK		((1 << WQ_ENET_FLAGS_OM_BITS) - 1)
-#define WQ_ENET_FLAGS_EOP_SHIFT		12
-#define WQ_ENET_FLAGS_CQ_ENTRY_SHIFT	13
-#define WQ_ENET_FLAGS_FCOE_ENCAP_SHIFT	14
-#define WQ_ENET_FLAGS_VLAN_TAG_INSERT_SHIFT	15
-
-#define WQ_ENET_OFFLOAD_MODE_CSUM	0
-#define WQ_ENET_OFFLOAD_MODE_RESERVED	1
-#define WQ_ENET_OFFLOAD_MODE_CSUM_L4	2
-#define WQ_ENET_OFFLOAD_MODE_TSO	3
-
-static inline void wq_enet_desc_enc(struct wq_enet_desc *desc,
-	u64 address, u16 length, u16 mss, u16 header_length,
-	u8 offload_mode, u8 eop, u8 cq_entry, u8 fcoe_encap,
-	u8 vlan_tag_insert, u16 vlan_tag, u8 loopback)
-{
-	desc->address = cpu_to_le64(address);
-	desc->length = cpu_to_le16(length & WQ_ENET_LEN_MASK);
-	desc->mss_loopback = cpu_to_le16((mss & WQ_ENET_MSS_MASK) <<
-		WQ_ENET_MSS_SHIFT | (loopback & 1) << WQ_ENET_LOOPBACK_SHIFT);
-	desc->header_length_flags = cpu_to_le16(
-		(header_length & WQ_ENET_HDRLEN_MASK) |
-		(offload_mode & WQ_ENET_FLAGS_OM_MASK) << WQ_ENET_HDRLEN_BITS |
-		(eop & 1) << WQ_ENET_FLAGS_EOP_SHIFT |
-		(cq_entry & 1) << WQ_ENET_FLAGS_CQ_ENTRY_SHIFT |
-		(fcoe_encap & 1) << WQ_ENET_FLAGS_FCOE_ENCAP_SHIFT |
-		(vlan_tag_insert & 1) << WQ_ENET_FLAGS_VLAN_TAG_INSERT_SHIFT);
-	desc->vlan_tag = cpu_to_le16(vlan_tag);
-}
-
-static inline void wq_enet_desc_dec(struct wq_enet_desc *desc,
-	u64 *address, u16 *length, u16 *mss, u16 *header_length,
-	u8 *offload_mode, u8 *eop, u8 *cq_entry, u8 *fcoe_encap,
-	u8 *vlan_tag_insert, u16 *vlan_tag, u8 *loopback)
-{
-	*address = le64_to_cpu(desc->address);
-	*length = le16_to_cpu(desc->length) & WQ_ENET_LEN_MASK;
-	*mss = (le16_to_cpu(desc->mss_loopback) >> WQ_ENET_MSS_SHIFT) &
-		WQ_ENET_MSS_MASK;
-	*loopback = (u8)((le16_to_cpu(desc->mss_loopback) >>
-		WQ_ENET_LOOPBACK_SHIFT) & 1);
-	*header_length = le16_to_cpu(desc->header_length_flags) &
-		WQ_ENET_HDRLEN_MASK;
-	*offload_mode = (u8)((le16_to_cpu(desc->header_length_flags) >>
-		WQ_ENET_HDRLEN_BITS) & WQ_ENET_FLAGS_OM_MASK);
-	*eop = (u8)((le16_to_cpu(desc->header_length_flags) >>
-		WQ_ENET_FLAGS_EOP_SHIFT) & 1);
-	*cq_entry = (u8)((le16_to_cpu(desc->header_length_flags) >>
-		WQ_ENET_FLAGS_CQ_ENTRY_SHIFT) & 1);
-	*fcoe_encap = (u8)((le16_to_cpu(desc->header_length_flags) >>
-		WQ_ENET_FLAGS_FCOE_ENCAP_SHIFT) & 1);
-	*vlan_tag_insert = (u8)((le16_to_cpu(desc->header_length_flags) >>
-		WQ_ENET_FLAGS_VLAN_TAG_INSERT_SHIFT) & 1);
-	*vlan_tag = le16_to_cpu(desc->vlan_tag);
-}
-
-#endif /* _WQ_ENET_DESC_H_ */

