From: akpm@linux-foundation.org
Subject: [patch 04/11] drivers/net/vioc/: possible cleanups
Date: Thu, 26 Apr 2007 00:23:16 -0700
Message-ID: <200704260723.l3Q7NHfL023829@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, bunk@stusta.de,
	schidambaram@fabric7.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:59610 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933331AbXDZHYP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 03:24:15 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>

- remove dead #ifdef EXPORT_SYMTAB code
- no "inline" functions in C files - gcc knows best whether or not to
  inline static functions
- move the vioc_ethtool_ops prototype to a header file
- make needlessly global code static
- #if 0 unused code
- vioc_irq.c: remove the unused vioc_driver_lock

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Cc: Sriram Chidambaram <schidambaram@fabric7.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/vioc/f7/sppapi.h      |    2 
 drivers/net/vioc/khash.h          |   10 ----
 drivers/net/vioc/spp.c            |   60 ++++++++++++++++++----------
 drivers/net/vioc/vioc_api.c       |    5 +-
 drivers/net/vioc/vioc_api.h       |    3 -
 drivers/net/vioc/vioc_driver.c    |    3 -
 drivers/net/vioc/vioc_ethtool.c   |    2 
 drivers/net/vioc/vioc_irq.c       |    9 ----
 drivers/net/vioc/vioc_provision.c |   16 ++++---
 drivers/net/vioc/vioc_receive.c   |    2 
 drivers/net/vioc/vioc_spp.c       |    6 +-
 drivers/net/vioc/vioc_transmit.c  |   40 ++++++++++--------
 12 files changed, 85 insertions(+), 73 deletions(-)

diff -puN drivers/net/vioc/f7/sppapi.h~drivers-net-vioc-possible-cleanups drivers/net/vioc/f7/sppapi.h
--- a/drivers/net/vioc/f7/sppapi.h~drivers-net-vioc-possible-cleanups
+++ a/drivers/net/vioc/f7/sppapi.h
@@ -234,7 +234,5 @@ extern int spp_msg_register(u32 key_faci
 
 extern void spp_msg_unregister(u32 key_facility);
 
-extern int read_spp_regbank32(int vioc, int bank, char *buffer);
-
 #endif /* _SPPAPI_H_ */
 
diff -puN drivers/net/vioc/khash.h~drivers-net-vioc-possible-cleanups drivers/net/vioc/khash.h
--- a/drivers/net/vioc/khash.h~drivers-net-vioc-possible-cleanups
+++ a/drivers/net/vioc/khash.h
@@ -52,14 +52,4 @@ struct hash_elem_t {
 };
 
 
-struct shash_t  *hashT_create(u32, size_t, size_t, u32(*)(unsigned char *, unsigned long), int(*)(void *, void *), unsigned int);
-int hashT_delete(struct shash_t * , void *);
-struct hash_elem_t *hashT_lookup(struct shash_t * , void *);
-struct hash_elem_t *hashT_add(struct shash_t *, void *);
-void hashT_destroy(struct shash_t *);
-/* Accesors */
-void **hashT_getkeys(struct shash_t *);
-size_t hashT_tablesize(struct shash_t *);
-size_t hashT_size(struct shash_t *);
-
 #endif
diff -puN drivers/net/vioc/spp.c~drivers-net-vioc-possible-cleanups drivers/net/vioc/spp.c
--- a/drivers/net/vioc/spp.c~drivers-net-vioc-possible-cleanups
+++ a/drivers/net/vioc/spp.c
@@ -50,6 +50,15 @@
   c -= a; c -= b; c ^= (b >> 15); \
 }
 
+static struct hash_elem_t *hashT_add(struct shash_t *htable, void *key);
+static struct shash_t *hashT_create(u32 sizehint, size_t keybuf_size,
+                                    size_t databuf_size,
+                                    u32(*hfunc) (unsigned char *,
+						 unsigned long),
+                                    int (*cfunc) (void *, void *),
+                                    unsigned int flags);
+static void hashT_destroy(struct shash_t *htable);
+static struct hash_elem_t *hashT_lookup(struct shash_t *htable, void *key);
 
 struct shash_t {
 	/* Common fields for all hash tables types */
@@ -65,7 +74,9 @@ struct shash_t {
 };
 
 struct hash_ops {
+#if 0
 	int (*delete) (struct shash_t *, void *);
+#endif  /*  0  */
 	struct hash_elem_t *(*lookup) (struct shash_t *, void *);
 	void (*destroy) (struct shash_t *);
 	struct hash_elem_t *(*add) (struct shash_t *, void *);
@@ -143,6 +154,7 @@ static u32 gethash(struct shash_t *htabl
 	return ((htable->hash_fn(key, len)) & (htable->tsize - 1));
 }
 
+#if 0
 /* Data associated to this key MUST be freed by the caller */
 static int ch_delete(struct shash_t *htable, void *key)
 {
@@ -181,6 +193,7 @@ static int ch_delete(struct shash_t *hta
 
 	return -1;
 }
+#endif  /*  0  */
 
 static void ch_destroy(struct shash_t *htable)
 {
@@ -232,16 +245,21 @@ static void **ch_getkeys(struct shash_t 
 }
 
 /* Accesors ******************************************************************/
-inline size_t hashT_tablesize(struct shash_t * htable)
+
+#if 0
+
+size_t hashT_tablesize(struct shash_t * htable)
 {
 	return htable->tsize;
 }
 
-inline size_t hashT_size(struct shash_t * htable)
+size_t hashT_size(struct shash_t * htable)
 {
 	return htable->nelems;
 }
 
+#endif  /*  0  */
+
 static struct hash_elem_t *ch_lookup(struct shash_t *htable, void *key)
 {
 	u32 idx;
@@ -330,15 +348,17 @@ static int key_compare(void *key_in, voi
 		return 1;
 }
 
-struct hash_ops ch_ops = {
+static struct hash_ops ch_ops = {
+#if 0
 	.delete = ch_delete,
+#endif  /*  0  */
 	.lookup = ch_lookup,
 	.destroy = ch_destroy,
 	.getkeys = ch_getkeys,
 	.add = ch_add
 };
 
-struct facility fTable[FACILITY_CNT];
+static struct facility fTable[FACILITY_CNT];
 
 int spp_init(void)
 {
@@ -511,7 +531,7 @@ void spp_msg_unregister(u32 key_facility
 	spin_unlock(&elem->lock);
 }
 
-
+#if 0
 int read_spp_regbank32(int vioc_idx, int bank, char *buffer)
 {
 	struct vioc_device *viocdev = vioc_viocdev(vioc_idx);
@@ -531,14 +551,14 @@ int read_spp_regbank32(int vioc_idx, int
 
 	return i;
 }
+#endif  /*  0  */
 
-struct shash_t *hashT_create(u32 sizehint,
-							size_t keybuf_size,
-							size_t databuf_size,
-							u32(*hfunc) (unsigned char *,
-							unsigned long),
-							int (*cfunc) (void *, void *),
-							unsigned int flags)
+static struct shash_t *hashT_create(u32 sizehint, size_t keybuf_size,
+                                    size_t databuf_size,
+                                    u32(*hfunc) (unsigned char *,
+                                                 unsigned long),
+                                    int (*cfunc) (void *, void *),
+                                    unsigned int flags)
 {
 	struct shash_t *htable;
 	u32 size = 0;		/* Table size */
@@ -591,36 +611,34 @@ struct shash_t *hashT_create(u32 sizehin
 	return htable;
 }
 
+#if 0
 int hashT_delete(struct shash_t *htable, void *key)
 {
 	return htable->h_ops->delete(htable, key);
 }
+#endif  /*  0  */
 
-struct hash_elem_t *hashT_add(struct shash_t *htable, void *key)
+static struct hash_elem_t *hashT_add(struct shash_t *htable, void *key)
 {
 	return htable->h_ops->add(htable, key);
 }
 
-struct hash_elem_t *hashT_lookup(struct shash_t *htable, void *key)
+static struct hash_elem_t *hashT_lookup(struct shash_t *htable, void *key)
 {
 	return htable->h_ops->lookup(htable, key);
 }
 
-void hashT_destroy(struct shash_t *htable)
+static void hashT_destroy(struct shash_t *htable)
 {
-
 	htable->h_ops->destroy(htable);
 
 	vfree(htable);
 }
 
+#if 0
 void **hashT_getkeys(struct shash_t *htable)
 {
 	return htable->h_ops->getkeys(htable);
 }
+#endif  /*  0  */
 
-#ifdef EXPORT_SYMTAB
-EXPORT_SYMBOL(spp_msg_register);
-EXPORT_SYMBOL(spp_msg_unregister);
-EXPORT_SYMBOL(read_spp_regbank32);
-#endif
diff -puN drivers/net/vioc/vioc_api.c~drivers-net-vioc-possible-cleanups drivers/net/vioc/vioc_api.c
--- a/drivers/net/vioc/vioc_api.c~drivers-net-vioc-possible-cleanups
+++ a/drivers/net/vioc/vioc_api.c
@@ -46,7 +46,8 @@
 #include "vioc_vnic.h"
 #include "vioc_api.h"
 
-int vioc_set_rx_intr_param(int viocdev_idx, int rx_intr_id, u32 timeout, u32 cntout)
+static int vioc_set_rx_intr_param(int viocdev_idx, int rx_intr_id,
+				  u32 timeout, u32 cntout)
 {
 	int ret = 0;
 	struct vioc_device *viocdev;
@@ -83,6 +84,7 @@ int vioc_get_vnic_mac(int viocdev_idx, u
 	return 0;
 }
 
+#if 0
 int vioc_set_vnic_mac(int viocdev_idx, u32 vnic_id, u8 * p)
 {
 	struct vioc_device *viocdev = vioc_viocdev(viocdev_idx);
@@ -101,6 +103,7 @@ int vioc_set_vnic_mac(int viocdev_idx, u
 
 	return 0;
 }
+#endif  /*  0  */
 
 int vioc_set_txq(int viocdev_idx, u32 vnic_id, u32 txq_id, dma_addr_t base,
 		 u32 num_elements)
diff -puN drivers/net/vioc/vioc_api.h~drivers-net-vioc-possible-cleanups drivers/net/vioc/vioc_api.h
--- a/drivers/net/vioc/vioc_api.h~drivers-net-vioc-possible-cleanups
+++ a/drivers/net/vioc/vioc_api.h
@@ -30,11 +30,12 @@
 #include <asm/io.h>
 #include "vioc_vnic.h"
 
+extern struct ethtool_ops vioc_ethtool_ops;
+
 extern int vioc_vnic_resources_set(int vioc_id, u32 vnic_id);
 extern void vioc_sw_reset(int vioc_id);
 extern u32 vioc_rrd(int vioc_id, int module_id, int vnic_id, int reg_addr);
 extern int vioc_rwr(int vioc_id, int module_id, int vnic_id, int reg_addr, u32 value);
-extern int vioc_set_vnic_mac(int vioc_id, u32 vnic_id, u8 * p);
 extern int vioc_get_vnic_mac(int vioc_id, u32 vnic_id, u8 * p);
 extern int vioc_set_txq(int vioc_id, u32 vnic_id, u32 txq_id, dma_addr_t base,
                 u32 num_elements);
diff -puN drivers/net/vioc/vioc_driver.c~drivers-net-vioc-possible-cleanups drivers/net/vioc/vioc_driver.c
--- a/drivers/net/vioc/vioc_driver.c~drivers-net-vioc-possible-cleanups
+++ a/drivers/net/vioc/vioc_driver.c
@@ -868,6 +868,3 @@ static void __exit vioc_module_exit(void
 module_init(vioc_module_init);
 module_exit(vioc_module_exit);
 
-#ifdef EXPORT_SYMTAB
-EXPORT_SYMBOL(vioc_viocdev);
-#endif				/* EXPORT_SYMTAB */
diff -puN drivers/net/vioc/vioc_ethtool.c~drivers-net-vioc-possible-cleanups drivers/net/vioc/vioc_ethtool.c
--- a/drivers/net/vioc/vioc_ethtool.c~drivers-net-vioc-possible-cleanups
+++ a/drivers/net/vioc/vioc_ethtool.c
@@ -155,7 +155,7 @@ static int vnic_get_settings(struct net_
 	return 0;
 }
 
-int vioc_trace;
+static int vioc_trace;
 
 static u32 vnic_get_msglevel(struct net_device *netdev)
 {
diff -puN drivers/net/vioc/vioc_irq.c~drivers-net-vioc-possible-cleanups drivers/net/vioc/vioc_irq.c
--- a/drivers/net/vioc/vioc_irq.c~drivers-net-vioc-possible-cleanups
+++ a/drivers/net/vioc/vioc_irq.c
@@ -55,9 +55,6 @@
 #define VIOC_INTERRUPTS_CNT    19	/* 16 Rx + 1 Tx + 1 BMC + 1 Error */
 #define VIOC_INTERRUPTS_CNT_PIN_IRQ    4	/* 2 Rx + 1 Tx + 1 BMC */
 
-#define VIOC_SLVAR(x) x spinlock_t vioc_driver_lock = SPIN_LOCK_UNLOCKED
-#define VIOC_CLI spin_lock_irq(&vioc_driver_lock)
-#define VIOC_STI spin_unlock_irq(&vioc_driver_lock)
 #define IRQRETURN return IRQ_HANDLED
 #define TX_IRQ_IDX			16
 #define BMC_IRQ_IDX			17
@@ -92,9 +89,7 @@ struct viocdev_intreq {
 };
 
 /* GLOBAL VIOC Interrupt table/structure */
-struct viocdev_intreq vioc_interrupts[VIOC_MAX_VIOCS];
-
-VIOC_SLVAR();
+static struct viocdev_intreq vioc_interrupts[VIOC_MAX_VIOCS];
 
 static irqreturn_t taskq_handler(int i, void *p)
 {
@@ -227,7 +222,7 @@ int vioc_irq_init(void)
 	return 0;
 }
 
-int get_pci_pin_irq(struct pci_dev *dev_in, int func)
+static int get_pci_pin_irq(struct pci_dev *dev_in, int func)
 {
 	struct pci_dev *dev = NULL;
 	unsigned int slot, fn, devfn;
diff -puN drivers/net/vioc/vioc_provision.c~drivers-net-vioc-possible-cleanups drivers/net/vioc/vioc_provision.c
--- a/drivers/net/vioc/vioc_provision.c~drivers-net-vioc-possible-cleanups
+++ a/drivers/net/vioc/vioc_provision.c
@@ -75,7 +75,7 @@ struct rxd_q_prov {
 
 */
 
-struct vnic_prov_def vnic_set_0 = {
+static struct vnic_prov_def vnic_set_0 = {
 	.rxd_ring[0].buf_size = RXDQ_SMALL_ALLOC_BUFSIZE,
 	.rxd_ring[0].entries = RXDQ_SMALL_ENTRIES,
 	.rxd_ring[0].id = 0,
@@ -92,7 +92,7 @@ struct vnic_prov_def vnic_set_0 = {
 	    0,.rxc_intr_id = 0
 };
 
-struct vnic_prov_def vnic_set_1 = {
+static struct vnic_prov_def vnic_set_1 = {
 	.rxd_ring[0].buf_size = RXDQ_SMALL_ALLOC_BUFSIZE,
 	.rxd_ring[0].entries = RXDQ_SMALL_ENTRIES,
 	.rxd_ring[0].id = 4,
@@ -109,7 +109,7 @@ struct vnic_prov_def vnic_set_1 = {
 	    1,.rxc_intr_id = 1
 };
 
-struct vnic_prov_def vnic_set_2 = {
+static struct vnic_prov_def vnic_set_2 = {
 	.rxd_ring[0].buf_size = RXDQ_SMALL_ALLOC_BUFSIZE,
 	.rxd_ring[0].entries = RXDQ_SMALL_ENTRIES,
 	.rxd_ring[0].id = 8,
@@ -126,7 +126,7 @@ struct vnic_prov_def vnic_set_2 = {
 	    2,.rxc_intr_id = 2
 };
 
-struct vnic_prov_def vnic_set_3 = {
+static struct vnic_prov_def vnic_set_3 = {
 	.rxd_ring[0].buf_size = RXDQ_SMALL_ALLOC_BUFSIZE,
 	.rxd_ring[0].entries = RXDQ_SMALL_ENTRIES,
 	.rxd_ring[0].id = 12,
@@ -143,6 +143,7 @@ struct vnic_prov_def vnic_set_3 = {
 	    3,.rxc_intr_id = 3
 };
 
+#if 0
 struct vnic_prov_def vnic_set_sim = {
 	.rxd_ring[0].buf_size = RXDQ_STD_ALLOC_BUFSIZE,
 	.rxd_ring[0].entries = 256,
@@ -158,8 +159,9 @@ struct vnic_prov_def vnic_set_sim = {
 	.rxd_ring[2].state = 1,
 	.tx_entries = 256,.rxc_entries = 256 * 3,.rxc_id = 0,.rxc_intr_id = 0
 };
+#endif  /*  0  */
 
-struct vnic_prov_def *vnic_prov_pmm_pin_irq[VIOC_MAX_VNICS] = {
+static struct vnic_prov_def *vnic_prov_pmm_pin_irq[VIOC_MAX_VNICS] = {
 	&vnic_set_0,
 	&vnic_set_1,
 	&vnic_set_0,
@@ -178,7 +180,7 @@ struct vnic_prov_def *vnic_prov_pmm_pin_
 	&vnic_set_1
 };
 
-struct vnic_prov_def *vnic_prov_pmm_msi_x[VIOC_MAX_VNICS] = {
+static struct vnic_prov_def *vnic_prov_pmm_msi_x[VIOC_MAX_VNICS] = {
 	&vnic_set_0,
 	&vnic_set_1,
 	&vnic_set_2,
@@ -197,6 +199,7 @@ struct vnic_prov_def *vnic_prov_pmm_msi_
 	&vnic_set_3
 };
 
+#if 0
 struct vnic_prov_def *vnic_prov_sim[VIOC_MAX_VNICS] = {
 	&vnic_set_sim,
 	&vnic_set_sim,
@@ -215,6 +218,7 @@ struct vnic_prov_def *vnic_prov_sim[VIOC
 	&vnic_set_sim,
 	&vnic_set_sim
 };
+#endif  /*  0  */
 
 struct vnic_prov_def **vioc_prov_get(int num_rx_irq)
 {
diff -puN drivers/net/vioc/vioc_receive.c~drivers-net-vioc-possible-cleanups drivers/net/vioc/vioc_receive.c
--- a/drivers/net/vioc/vioc_receive.c~drivers-net-vioc-possible-cleanups
+++ a/drivers/net/vioc/vioc_receive.c
@@ -58,7 +58,7 @@
  * one RxSet, no locking is needed on RxDQs or RxCQs.
  * Return true if we got a packet, false if the queue is empty.
  */
-int vioc_rx_pkt(struct vioc_device *viocdev, struct rxc *rxc, u32 sw_idx)
+static int vioc_rx_pkt(struct vioc_device *viocdev, struct rxc *rxc, u32 sw_idx)
 {
 	u32 rx_status;
 	u32 vnic_id;
diff -puN drivers/net/vioc/vioc_spp.c~drivers-net-vioc-possible-cleanups drivers/net/vioc/vioc_spp.c
--- a/drivers/net/vioc/vioc_spp.c~drivers-net-vioc-possible-cleanups
+++ a/drivers/net/vioc/vioc_spp.c
@@ -84,12 +84,12 @@
 
 static DECLARE_MUTEX(vnic_prov_sem);
 
-static inline void vnic_prov_get_sema(void)
+static void vnic_prov_get_sema(void)
 {
 	down(&vnic_prov_sem);
 }
 
-static inline void vnic_prov_put_sema(void)
+static void vnic_prov_put_sema(void)
 {
 	up(&vnic_prov_sem);
 }
@@ -290,7 +290,7 @@ void vioc_hb_to_bmc(int vioc_id)
 	vioc_reg_wr(1, viocdev->ba.virt, SPP_HB_SENSOR_REG);
 }
 
-void vioc_reset_rq_to_bmc(int vioc_id, u32 command)
+static void vioc_reset_rq_to_bmc(int vioc_id, u32 command)
 {
 	struct vioc_device *viocdev = vioc_viocdev(0);
 
diff -puN drivers/net/vioc/vioc_transmit.c~drivers-net-vioc-possible-cleanups drivers/net/vioc/vioc_transmit.c
--- a/drivers/net/vioc/vioc_transmit.c~drivers-net-vioc-possible-cleanups
+++ a/drivers/net/vioc/vioc_transmit.c
@@ -73,49 +73,52 @@
 #define TXQ0            0
 #define NOT_SET        -1
 
-static inline u32 vnic_rd_txd_ctl(struct txq *txq)
+static u32 vnic_rd_txd_ctl(struct txq *txq)
 {
 	return readl(txq->va_of_vreg_veng_txd_ctl);
 }
 
-static inline void vnic_ring_tx_bell(struct txq *txq)
+static void vnic_ring_tx_bell(struct txq *txq)
 {
 	writel(txq->shadow_VREG_VENG_TXD_CTL | VREG_VENG_TXD_CTL_QRING_MASK,
 	       txq->va_of_vreg_veng_txd_ctl);
 	txq->bells++;
 }
 
-static inline void vnic_reset_tx_ring_err(struct txq *txq)
+static void vnic_reset_tx_ring_err(struct txq *txq)
 {
 	writel(txq->shadow_VREG_VENG_TXD_CTL |
 	       (VREG_VENG_TXD_CTL_QENABLE_MASK | VREG_VENG_TXD_CTL_CLEARMASK),
 	       txq->va_of_vreg_veng_txd_ctl);
 }
 
-static inline void vnic_enable_tx_ring(struct txq *txq)
+static void vnic_enable_tx_ring(struct txq *txq)
 {
 	txq->shadow_VREG_VENG_TXD_CTL = VREG_VENG_TXD_CTL_QENABLE_MASK;
 	writel(txq->shadow_VREG_VENG_TXD_CTL, txq->va_of_vreg_veng_txd_ctl);
 }
 
-static inline void vnic_disable_tx_ring(struct txq *txq)
+static void vnic_disable_tx_ring(struct txq *txq)
 {
 	txq->shadow_VREG_VENG_TXD_CTL = 0;
 	writel(0, txq->va_of_vreg_veng_txd_ctl);
 }
 
-static inline void vnic_pause_tx_ring(struct txq *txq)
+#if 0
+
+static void vnic_pause_tx_ring(struct txq *txq)
 {
 	txq->shadow_VREG_VENG_TXD_CTL |= VREG_VENG_TXD_CTL_QPAUSE_MASK;
 	writel(txq->shadow_VREG_VENG_TXD_CTL, txq->va_of_vreg_veng_txd_ctl);
 }
 
-static inline void vnic_resume_tx_ring(struct txq *txq)
+static void vnic_resume_tx_ring(struct txq *txq)
 {
 	txq->shadow_VREG_VENG_TXD_CTL &= ~VREG_VENG_TXD_CTL_QPAUSE_MASK;
 	writel(txq->shadow_VREG_VENG_TXD_CTL, txq->va_of_vreg_veng_txd_ctl);
 }
 
+#endif  /*  0  */
 
 /* TxQ must be locked */
 static void vnic_reset_txq(struct vnic_device *vnicdev, struct txq *txq)
@@ -395,8 +398,9 @@ void vioc_tx_interrupt(struct work_struc
 	viocdev->vioc_stats.tx_tasklets++;
 	// read_unlock(&viocdev->lock);
 }
-void vnic_enqueue_tx_pkt(struct vnic_device *vnicdev, struct txq *txq,
-			 struct sk_buff *skb, struct vioc_prov *prov)
+
+static void vnic_enqueue_tx_pkt(struct vnic_device *vnicdev, struct txq *txq,
+				struct sk_buff *skb, struct vioc_prov *prov)
 {
 	int idx, sop_idx, eop_idx, f;
 	struct tx_pktBufDesc_Phys_w *txd;
@@ -512,8 +516,9 @@ void vnic_enqueue_tx_pkt(struct vnic_dev
 
 }
 
-void vnic_enqueue_tx_buffers(struct vnic_device *vnicdev, struct txq *txq,
-			     struct sk_buff *skb, struct vioc_prov *prov)
+static void vnic_enqueue_tx_buffers(struct vnic_device *vnicdev,
+				    struct txq *txq, struct sk_buff *skb,
+				    struct vioc_prov *prov)
 {
 	int len;
 	int idx;
@@ -586,7 +591,7 @@ void vnic_enqueue_tx_buffers(struct vnic
 	txq->next_to_use = idx;
 }
 
-static inline void init_f7_header(struct sk_buff *skb)
+static void init_f7_header(struct sk_buff *skb)
 {
 	struct vioc_f7pf_w *f7p;
 	unsigned char tag;
@@ -675,7 +680,7 @@ void vioc_tx_timer(unsigned long data)
  * not hold - add a tx_enabled flag to the vnic struct protected
  * by txq->lock.  Or just read-lock the VIOC.
  */
-int vnic_start_xmit(struct sk_buff *skb, struct net_device *netdev)
+static int vnic_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct vnic_device *vnicdev = netdev->priv;
 	struct txq *txq = &vnicdev->txq;
@@ -734,8 +739,9 @@ int vnic_start_xmit(struct sk_buff *skb,
  *      saddr=NULL      means use device source address
  *      daddr=NULL      means leave destination address (eg unresolved arp)
  */
-int vnic_eth_header(struct sk_buff *skb, struct net_device *dev,
-		    unsigned short type, void *daddr, void *saddr, unsigned len)
+static int vnic_eth_header(struct sk_buff *skb, struct net_device *dev,
+			   unsigned short type, void *daddr, void *saddr,
+			   unsigned len)
 {
 	struct ethhdr *eth = (struct ethhdr *)skb_push(skb, ETH_HLEN);
 
@@ -952,6 +958,7 @@ static void vnic_free_tx_resources(struc
 	vnicdev->txq.vbuf = NULL;
 }
 
+#if 0
 void vioc_reset_if_tx(struct net_device *netdev)
 {
 	struct vnic_device *vnicdev = netdev->priv;
@@ -959,8 +966,7 @@ void vioc_reset_if_tx(struct net_device 
 
 	vnic_reset_txq(vnicdev, txq);
 }
-
-extern struct ethtool_ops vioc_ethtool_ops;
+#endif  /*  0  */
 
 /**
  * vnic_uninit - Device Termination Routine
_
