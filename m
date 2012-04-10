From: Dan Williams <dan.j.williams@intel.com>
Subject: [GIT PULL] dmaengine fixes for 3.4-rc3
Date: Tue, 10 Apr 2012 13:08:43 -0700
Message-ID: <1334088527.21608.9.camel@ultramagnus.opencreations.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>, dave.jiang@intel.com,
	netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:44991 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753398Ab2DJUIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 16:08:52 -0400
Received: by obbun3 with SMTP id un3so215526obb.25
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 13:08:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit c16fa4f2ad19908a47c63d8fa436a1178438c7e7:

  Linux 3.3 (2012-03-18 16:15:34 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/djbw/dmaengine.git tags/dmaengine-fixes

for you to fetch changes up to a2bd1140a264b561e38d99e656cd843c2d840e86:

  netdma: adding alignment check for NETDMA ops (2012-04-05 15:27:12 -0700)

----------------------------------------------------------------
dmaengine-fixes for 3.4-rc3

1/ regression fix for Xen as it now trips over a broken assumption
   about the dma address size on 32-bit builds

2/ new quirk for netdma to ignore dma channels that cannot meet
   netdma alignment requirements

3/ fixes for two long standing issues in ioatdma (ring size overflow)
   and iop-adma (potential stack corruption)

----------------------------------------------------------------

These have all made an appearance in -next.

The item 3 fixes are not regressions, they are more than a few kernel
cycles old.  If -rc3 is too late for such things let me know and I'll
re-spin.

This is also my first attempt at a signed-tag pull request.

Dan Williams (1):
      ioat: fix size of 'completion' for Xen

Dave Jiang (3):
      ioat: ring size variables need to be 32bit to avoid overflow
      ioatdma: DMA copy alignment needed to address IOAT DMA silicon errata
      netdma: adding alignment check for NETDMA ops

Don Morris (1):
      iop-adma: Corrected array overflow in RAID6 Xscale(R) test.

 drivers/dma/dmaengine.c   |   14 +++++++++++++
 drivers/dma/ioat/dma.c    |   16 +++++++--------
 drivers/dma/ioat/dma.h    |    6 +++---
 drivers/dma/ioat/dma_v2.c |   12 +++++------
 drivers/dma/ioat/dma_v2.h |    4 ++--
 drivers/dma/ioat/dma_v3.c |   49 +++++++++++++++++++++++++++++++++++++++++----
 drivers/dma/iop-adma.c    |    4 ++--
 include/linux/dmaengine.h |    1 +
 net/ipv4/tcp.c            |    4 ++--
 net/ipv4/tcp_input.c      |    2 +-
 net/ipv4/tcp_ipv4.c       |    2 +-
 net/ipv6/tcp_ipv6.c       |    2 +-
 12 files changed, 86 insertions(+), 30 deletions(-)

commit a2bd1140a264b561e38d99e656cd843c2d840e86
Author: Dave Jiang <dave.jiang@intel.com>
Date:   Wed Apr 4 16:10:46 2012 -0700

    netdma: adding alignment check for NETDMA ops
    
    This is the fallout from adding memcpy alignment workaround for certain
    IOATDMA hardware. NetDMA will only use DMA engine that can handle byte align
    ops.
    
    Acked-by: David S. Miller <davem@davemloft.net>
    Signed-off-by: Dave Jiang <dave.jiang@intel.com>
    Signed-off-by: Dan Williams <dan.j.williams@intel.com>

commit f26df1a1a9452573af7b6cea9a4723593e838568
Author: Dave Jiang <dave.jiang@intel.com>
Date:   Wed Apr 4 16:10:41 2012 -0700

    ioatdma: DMA copy alignment needed to address IOAT DMA silicon errata
    
    Silicon errata where when RAID and legacy descriptors are mixed, the legacy
    (memcpy and friends) operation must have alignment of 64 bytes to avoid
    hanging. This effects Intel Xeon C55xx, C35xx, E5-2600.
    
    Signed-off-by: Dave Jiang <dave.jiang@intel.com>
    Signed-off-by: Dan Williams <dan.j.williams@intel.com>

commit 21b764e075e74f8af90da9f623aa3e2167484687
Author: Dave Jiang <dave.jiang@intel.com>
Date:   Wed Apr 4 16:10:35 2012 -0700

    ioat: ring size variables need to be 32bit to avoid overflow
    
    The alloc order can be up to 16 and 1 << 16 will over flow the 16bit
    integer. Change the appropriate variables to 16bit to avoid overflow.
    
    Reported-by: Jim Harris <james.r.harris@intel.com>
    Signed-off-by: Dave Jiang <dave.jiang@intel.com>
    Signed-off-by: Dan Williams <dan.j.williams@intel.com>

commit 3d9ea9e3af048ab6b8dced15248384e548ba05ea
Author: Don Morris <don.morris@hp.com>
Date:   Thu Mar 15 11:07:30 2012 -0700

    iop-adma: Corrected array overflow in RAID6 Xscale(R) test.
    
    Bug: cppcheck reported overflow in array assignment (for loop walks
    0 to IOP_ADMA_NUM_SRC_TEST+2, array size is IOP_ADMA_NUM_SRC_TEST).
    
    Reported as: https://bugzilla.kernel.org/show_bug.cgi?id=42677
    
    Test code pq_src array was grown by two elements to correspond with actual
    usage (IOP_ADMA_NUM_SRC_TEST+2), stack consumption was kept constant by
    modifying the pq_dest two element array which is only used when pq_src
    is referenced up to IOP_ADMA_NUM_SRC_TEST elements into the address
    of the new last two elements of the pq_src array. This is presumed to
    be the original intent but would be reliant on compilers always having
    pq_dest contiguous with the final element of pq_src.
    
    Note: This is a re-send of a request for review from two weeks ago.
    Looking for review (or shootdown), adding LKML to list for a wider
    audience. Thanks.
    
    Updated per review comments of Sergei Shtylyov <sshtylyov@mvista.com>
    
    Signed-off-by: Don Morris <don.morris@hp.com>
    Signed-off-by: Dan Williams <dan.j.williams@intel.com>

commit 275029353953c2117941ade84f02a2303912fad1
Author: Dan Williams <dan.j.williams@intel.com>
Date:   Fri Mar 23 13:36:42 2012 -0700

    ioat: fix size of 'completion' for Xen
    
    Starting with v3.2 Jonathan reports that Xen crashes loading the ioatdma
    driver.  A debug run shows:
    
      ioatdma 0000:00:16.4: desc[0]: (0x300cc7000->0x300cc7040) cookie: 0 flags: 0x2 ctl: 0x29 (op: 0 int_en: 1 compl: 1)
      ...
      ioatdma 0000:00:16.4: ioat_get_current_completion: phys_complete: 0xcc7000
    
    ...which shows that in this environment GFP_KERNEL memory may be backed
    by a 64-bit dma address.  This breaks the driver's assumption that an
    unsigned long should be able to contain the physical address for
    descriptor memory.  Switch to dma_addr_t which beyond being the right
    size, is the true type for the data i.e. an io-virtual address
    inidicating the engine's last processed descriptor.
    
    [stable: 3.2+]
    Cc: <stable@vger.kernel.org>
    Reported-by: Jonathan Nieder <jrnieder@gmail.com>
    Reported-by: William Dauchy <wdauchy@gmail.com>
    Tested-by: William Dauchy <wdauchy@gmail.com>
    Tested-by: Dave Jiang <dave.jiang@intel.com>
    Signed-off-by: Dan Williams <dan.j.williams@intel.com>

diff --git a/drivers/dma/dmaengine.c b/drivers/dma/dmaengine.c
index a6c6051..0f1ca74 100644
--- a/drivers/dma/dmaengine.c
+++ b/drivers/dma/dmaengine.c
@@ -332,6 +332,20 @@ struct dma_chan *dma_find_channel(enum dma_transaction_type tx_type)
 }
 EXPORT_SYMBOL(dma_find_channel);
 
+/*
+ * net_dma_find_channel - find a channel for net_dma
+ * net_dma has alignment requirements
+ */
+struct dma_chan *net_dma_find_channel(void)
+{
+	struct dma_chan *chan = dma_find_channel(DMA_MEMCPY);
+	if (chan && !is_dma_copy_aligned(chan->device, 1, 1, 1))
+		return NULL;
+
+	return chan;
+}
+EXPORT_SYMBOL(net_dma_find_channel);
+
 /**
  * dma_issue_pending_all - flush all pending operations across all channels
  */
diff --git a/drivers/dma/ioat/dma.c b/drivers/dma/ioat/dma.c
index a4d6cb0..6595180 100644
--- a/drivers/dma/ioat/dma.c
+++ b/drivers/dma/ioat/dma.c
@@ -548,9 +548,9 @@ void ioat_dma_unmap(struct ioat_chan_common *chan, enum dma_ctrl_flags flags,
 			   PCI_DMA_TODEVICE, flags, 0);
 }
 
-unsigned long ioat_get_current_completion(struct ioat_chan_common *chan)
+dma_addr_t ioat_get_current_completion(struct ioat_chan_common *chan)
 {
-	unsigned long phys_complete;
+	dma_addr_t phys_complete;
 	u64 completion;
 
 	completion = *chan->completion;
@@ -571,7 +571,7 @@ unsigned long ioat_get_current_completion(struct ioat_chan_common *chan)
 }
 
 bool ioat_cleanup_preamble(struct ioat_chan_common *chan,
-			   unsigned long *phys_complete)
+			   dma_addr_t *phys_complete)
 {
 	*phys_complete = ioat_get_current_completion(chan);
 	if (*phys_complete == chan->last_completion)
@@ -582,14 +582,14 @@ bool ioat_cleanup_preamble(struct ioat_chan_common *chan,
 	return true;
 }
 
-static void __cleanup(struct ioat_dma_chan *ioat, unsigned long phys_complete)
+static void __cleanup(struct ioat_dma_chan *ioat, dma_addr_t phys_complete)
 {
 	struct ioat_chan_common *chan = &ioat->base;
 	struct list_head *_desc, *n;
 	struct dma_async_tx_descriptor *tx;
 
-	dev_dbg(to_dev(chan), "%s: phys_complete: %lx\n",
-		 __func__, phys_complete);
+	dev_dbg(to_dev(chan), "%s: phys_complete: %llx\n",
+		 __func__, (unsigned long long) phys_complete);
 	list_for_each_safe(_desc, n, &ioat->used_desc) {
 		struct ioat_desc_sw *desc;
 
@@ -655,7 +655,7 @@ static void __cleanup(struct ioat_dma_chan *ioat, unsigned long phys_complete)
 static void ioat1_cleanup(struct ioat_dma_chan *ioat)
 {
 	struct ioat_chan_common *chan = &ioat->base;
-	unsigned long phys_complete;
+	dma_addr_t phys_complete;
 
 	prefetch(chan->completion);
 
@@ -701,7 +701,7 @@ static void ioat1_timer_event(unsigned long data)
 		mod_timer(&chan->timer, jiffies + COMPLETION_TIMEOUT);
 		spin_unlock_bh(&ioat->desc_lock);
 	} else if (test_bit(IOAT_COMPLETION_PENDING, &chan->state)) {
-		unsigned long phys_complete;
+		dma_addr_t phys_complete;
 
 		spin_lock_bh(&ioat->desc_lock);
 		/* if we haven't made progress and we have already
diff --git a/drivers/dma/ioat/dma.h b/drivers/dma/ioat/dma.h
index 5216c8a..8bebddd 100644
--- a/drivers/dma/ioat/dma.h
+++ b/drivers/dma/ioat/dma.h
@@ -88,7 +88,7 @@ struct ioatdma_device {
 struct ioat_chan_common {
 	struct dma_chan common;
 	void __iomem *reg_base;
-	unsigned long last_completion;
+	dma_addr_t last_completion;
 	spinlock_t cleanup_lock;
 	dma_cookie_t completed_cookie;
 	unsigned long state;
@@ -333,7 +333,7 @@ int __devinit ioat_dma_self_test(struct ioatdma_device *device);
 void __devexit ioat_dma_remove(struct ioatdma_device *device);
 struct dca_provider * __devinit ioat_dca_init(struct pci_dev *pdev,
 					      void __iomem *iobase);
-unsigned long ioat_get_current_completion(struct ioat_chan_common *chan);
+dma_addr_t ioat_get_current_completion(struct ioat_chan_common *chan);
 void ioat_init_channel(struct ioatdma_device *device,
 		       struct ioat_chan_common *chan, int idx);
 enum dma_status ioat_dma_tx_status(struct dma_chan *c, dma_cookie_t cookie,
@@ -341,7 +341,7 @@ enum dma_status ioat_dma_tx_status(struct dma_chan *c, dma_cookie_t cookie,
 void ioat_dma_unmap(struct ioat_chan_common *chan, enum dma_ctrl_flags flags,
 		    size_t len, struct ioat_dma_descriptor *hw);
 bool ioat_cleanup_preamble(struct ioat_chan_common *chan,
-			   unsigned long *phys_complete);
+			   dma_addr_t *phys_complete);
 void ioat_kobject_add(struct ioatdma_device *device, struct kobj_type *type);
 void ioat_kobject_del(struct ioatdma_device *device);
 extern const struct sysfs_ops ioat_sysfs_ops;
diff --git a/drivers/dma/ioat/dma_v2.c b/drivers/dma/ioat/dma_v2.c
index 5d65f83..143cb1b 100644
--- a/drivers/dma/ioat/dma_v2.c
+++ b/drivers/dma/ioat/dma_v2.c
@@ -126,7 +126,7 @@ static void ioat2_start_null_desc(struct ioat2_dma_chan *ioat)
 	spin_unlock_bh(&ioat->prep_lock);
 }
 
-static void __cleanup(struct ioat2_dma_chan *ioat, unsigned long phys_complete)
+static void __cleanup(struct ioat2_dma_chan *ioat, dma_addr_t phys_complete)
 {
 	struct ioat_chan_common *chan = &ioat->base;
 	struct dma_async_tx_descriptor *tx;
@@ -178,7 +178,7 @@ static void __cleanup(struct ioat2_dma_chan *ioat, unsigned long phys_complete)
 static void ioat2_cleanup(struct ioat2_dma_chan *ioat)
 {
 	struct ioat_chan_common *chan = &ioat->base;
-	unsigned long phys_complete;
+	dma_addr_t phys_complete;
 
 	spin_lock_bh(&chan->cleanup_lock);
 	if (ioat_cleanup_preamble(chan, &phys_complete))
@@ -259,7 +259,7 @@ int ioat2_reset_sync(struct ioat_chan_common *chan, unsigned long tmo)
 static void ioat2_restart_channel(struct ioat2_dma_chan *ioat)
 {
 	struct ioat_chan_common *chan = &ioat->base;
-	unsigned long phys_complete;
+	dma_addr_t phys_complete;
 
 	ioat2_quiesce(chan, 0);
 	if (ioat_cleanup_preamble(chan, &phys_complete))
@@ -274,7 +274,7 @@ void ioat2_timer_event(unsigned long data)
 	struct ioat_chan_common *chan = &ioat->base;
 
 	if (test_bit(IOAT_COMPLETION_PENDING, &chan->state)) {
-		unsigned long phys_complete;
+		dma_addr_t phys_complete;
 		u64 status;
 
 		status = ioat_chansts(chan);
@@ -575,9 +575,9 @@ bool reshape_ring(struct ioat2_dma_chan *ioat, int order)
 	 */
 	struct ioat_chan_common *chan = &ioat->base;
 	struct dma_chan *c = &chan->common;
-	const u16 curr_size = ioat2_ring_size(ioat);
+	const u32 curr_size = ioat2_ring_size(ioat);
 	const u16 active = ioat2_ring_active(ioat);
-	const u16 new_size = 1 << order;
+	const u32 new_size = 1 << order;
 	struct ioat_ring_ent **ring;
 	u16 i;
 
diff --git a/drivers/dma/ioat/dma_v2.h b/drivers/dma/ioat/dma_v2.h
index a2c413b..be2a55b 100644
--- a/drivers/dma/ioat/dma_v2.h
+++ b/drivers/dma/ioat/dma_v2.h
@@ -74,7 +74,7 @@ static inline struct ioat2_dma_chan *to_ioat2_chan(struct dma_chan *c)
 	return container_of(chan, struct ioat2_dma_chan, base);
 }
 
-static inline u16 ioat2_ring_size(struct ioat2_dma_chan *ioat)
+static inline u32 ioat2_ring_size(struct ioat2_dma_chan *ioat)
 {
 	return 1 << ioat->alloc_order;
 }
@@ -91,7 +91,7 @@ static inline u16 ioat2_ring_pending(struct ioat2_dma_chan *ioat)
 	return CIRC_CNT(ioat->head, ioat->issued, ioat2_ring_size(ioat));
 }
 
-static inline u16 ioat2_ring_space(struct ioat2_dma_chan *ioat)
+static inline u32 ioat2_ring_space(struct ioat2_dma_chan *ioat)
 {
 	return ioat2_ring_size(ioat) - ioat2_ring_active(ioat);
 }
diff --git a/drivers/dma/ioat/dma_v3.c b/drivers/dma/ioat/dma_v3.c
index f519c93..dfe925f 100644
--- a/drivers/dma/ioat/dma_v3.c
+++ b/drivers/dma/ioat/dma_v3.c
@@ -256,7 +256,7 @@ static bool desc_has_ext(struct ioat_ring_ent *desc)
  * The difference from the dma_v2.c __cleanup() is that this routine
  * handles extended descriptors and dma-unmapping raid operations.
  */
-static void __cleanup(struct ioat2_dma_chan *ioat, unsigned long phys_complete)
+static void __cleanup(struct ioat2_dma_chan *ioat, dma_addr_t phys_complete)
 {
 	struct ioat_chan_common *chan = &ioat->base;
 	struct ioat_ring_ent *desc;
@@ -314,7 +314,7 @@ static void __cleanup(struct ioat2_dma_chan *ioat, unsigned long phys_complete)
 static void ioat3_cleanup(struct ioat2_dma_chan *ioat)
 {
 	struct ioat_chan_common *chan = &ioat->base;
-	unsigned long phys_complete;
+	dma_addr_t phys_complete;
 
 	spin_lock_bh(&chan->cleanup_lock);
 	if (ioat_cleanup_preamble(chan, &phys_complete))
@@ -333,7 +333,7 @@ static void ioat3_cleanup_event(unsigned long data)
 static void ioat3_restart_channel(struct ioat2_dma_chan *ioat)
 {
 	struct ioat_chan_common *chan = &ioat->base;
-	unsigned long phys_complete;
+	dma_addr_t phys_complete;
 
 	ioat2_quiesce(chan, 0);
 	if (ioat_cleanup_preamble(chan, &phys_complete))
@@ -348,7 +348,7 @@ static void ioat3_timer_event(unsigned long data)
 	struct ioat_chan_common *chan = &ioat->base;
 
 	if (test_bit(IOAT_COMPLETION_PENDING, &chan->state)) {
-		unsigned long phys_complete;
+		dma_addr_t phys_complete;
 		u64 status;
 
 		status = ioat_chansts(chan);
@@ -1147,6 +1147,44 @@ static int ioat3_reset_hw(struct ioat_chan_common *chan)
 	return ioat2_reset_sync(chan, msecs_to_jiffies(200));
 }
 
+static bool is_jf_ioat(struct pci_dev *pdev)
+{
+	switch (pdev->device) {
+	case PCI_DEVICE_ID_INTEL_IOAT_JSF0:
+	case PCI_DEVICE_ID_INTEL_IOAT_JSF1:
+	case PCI_DEVICE_ID_INTEL_IOAT_JSF2:
+	case PCI_DEVICE_ID_INTEL_IOAT_JSF3:
+	case PCI_DEVICE_ID_INTEL_IOAT_JSF4:
+	case PCI_DEVICE_ID_INTEL_IOAT_JSF5:
+	case PCI_DEVICE_ID_INTEL_IOAT_JSF6:
+	case PCI_DEVICE_ID_INTEL_IOAT_JSF7:
+	case PCI_DEVICE_ID_INTEL_IOAT_JSF8:
+	case PCI_DEVICE_ID_INTEL_IOAT_JSF9:
+		return true;
+	default:
+		return false;
+	}
+}
+
+static bool is_snb_ioat(struct pci_dev *pdev)
+{
+	switch (pdev->device) {
+	case PCI_DEVICE_ID_INTEL_IOAT_SNB0:
+	case PCI_DEVICE_ID_INTEL_IOAT_SNB1:
+	case PCI_DEVICE_ID_INTEL_IOAT_SNB2:
+	case PCI_DEVICE_ID_INTEL_IOAT_SNB3:
+	case PCI_DEVICE_ID_INTEL_IOAT_SNB4:
+	case PCI_DEVICE_ID_INTEL_IOAT_SNB5:
+	case PCI_DEVICE_ID_INTEL_IOAT_SNB6:
+	case PCI_DEVICE_ID_INTEL_IOAT_SNB7:
+	case PCI_DEVICE_ID_INTEL_IOAT_SNB8:
+	case PCI_DEVICE_ID_INTEL_IOAT_SNB9:
+		return true;
+	default:
+		return false;
+	}
+}
+
 int __devinit ioat3_dma_probe(struct ioatdma_device *device, int dca)
 {
 	struct pci_dev *pdev = device->pdev;
@@ -1167,6 +1205,9 @@ int __devinit ioat3_dma_probe(struct ioatdma_device *device, int dca)
 	dma->device_alloc_chan_resources = ioat2_alloc_chan_resources;
 	dma->device_free_chan_resources = ioat2_free_chan_resources;
 
+	if (is_jf_ioat(pdev) || is_snb_ioat(pdev))
+		dma->copy_align = 6;
+
 	dma_cap_set(DMA_INTERRUPT, dma->cap_mask);
 	dma->device_prep_dma_interrupt = ioat3_prep_interrupt_lock;
 
diff --git a/drivers/dma/iop-adma.c b/drivers/dma/iop-adma.c
index 04be90b..9b1951d 100644
--- a/drivers/dma/iop-adma.c
+++ b/drivers/dma/iop-adma.c
@@ -1271,8 +1271,8 @@ iop_adma_pq_zero_sum_self_test(struct iop_adma_device *device)
 	struct page **pq_hw = &pq[IOP_ADMA_NUM_SRC_TEST+2];
 	/* address conversion buffers (dma_map / page_address) */
 	void *pq_sw[IOP_ADMA_NUM_SRC_TEST+2];
-	dma_addr_t pq_src[IOP_ADMA_NUM_SRC_TEST];
-	dma_addr_t pq_dest[2];
+	dma_addr_t pq_src[IOP_ADMA_NUM_SRC_TEST+2];
+	dma_addr_t *pq_dest = &pq_src[IOP_ADMA_NUM_SRC_TEST];
 
 	int i;
 	struct dma_async_tx_descriptor *tx;
diff --git a/include/linux/dmaengine.h b/include/linux/dmaengine.h
index 679b349..a5bb3ad 100644
--- a/include/linux/dmaengine.h
+++ b/include/linux/dmaengine.h
@@ -948,6 +948,7 @@ int dma_async_device_register(struct dma_device *device);
 void dma_async_device_unregister(struct dma_device *device);
 void dma_run_dependencies(struct dma_async_tx_descriptor *tx);
 struct dma_chan *dma_find_channel(enum dma_transaction_type tx_type);
+struct dma_chan *net_dma_find_channel(void);
 #define dma_request_channel(mask, x, y) __dma_request_channel(&(mask), x, y)
 
 /* --- Helper iov-locking functions --- */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 22ef5f9..8712c5d 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1450,7 +1450,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		if ((available < target) &&
 		    (len > sysctl_tcp_dma_copybreak) && !(flags & MSG_PEEK) &&
 		    !sysctl_tcp_low_latency &&
-		    dma_find_channel(DMA_MEMCPY)) {
+		    net_dma_find_channel()) {
 			preempt_enable_no_resched();
 			tp->ucopy.pinned_list =
 					dma_pin_iovec_pages(msg->msg_iov, len);
@@ -1665,7 +1665,7 @@ do_prequeue:
 		if (!(flags & MSG_TRUNC)) {
 #ifdef CONFIG_NET_DMA
 			if (!tp->ucopy.dma_chan && tp->ucopy.pinned_list)
-				tp->ucopy.dma_chan = dma_find_channel(DMA_MEMCPY);
+				tp->ucopy.dma_chan = net_dma_find_channel();
 
 			if (tp->ucopy.dma_chan) {
 				tp->ucopy.dma_cookie = dma_skb_copy_datagram_iovec(
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index b5e315f..27c676d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5190,7 +5190,7 @@ static int tcp_dma_try_early_copy(struct sock *sk, struct sk_buff *skb,
 		return 0;
 
 	if (!tp->ucopy.dma_chan && tp->ucopy.pinned_list)
-		tp->ucopy.dma_chan = dma_find_channel(DMA_MEMCPY);
+		tp->ucopy.dma_chan = net_dma_find_channel();
 
 	if (tp->ucopy.dma_chan && skb_csum_unnecessary(skb)) {
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index fd54c5f..3810b6f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1727,7 +1727,7 @@ process:
 #ifdef CONFIG_NET_DMA
 		struct tcp_sock *tp = tcp_sk(sk);
 		if (!tp->ucopy.dma_chan && tp->ucopy.pinned_list)
-			tp->ucopy.dma_chan = dma_find_channel(DMA_MEMCPY);
+			tp->ucopy.dma_chan = net_dma_find_channel();
 		if (tp->ucopy.dma_chan)
 			ret = tcp_v4_do_rcv(sk, skb);
 		else
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 3edd05a..fcb3e4f 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1755,7 +1755,7 @@ process:
 #ifdef CONFIG_NET_DMA
 		struct tcp_sock *tp = tcp_sk(sk);
 		if (!tp->ucopy.dma_chan && tp->ucopy.pinned_list)
-			tp->ucopy.dma_chan = dma_find_channel(DMA_MEMCPY);
+			tp->ucopy.dma_chan = net_dma_find_channel();
 		if (tp->ucopy.dma_chan)
 			ret = tcp_v6_do_rcv(sk, skb);
 		else
