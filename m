From: Mark Asselstine <mark.asselstine@windriver.com>
Subject: [PATCH] Removal of debug code containing deprecated calls to cli()/sti()
Date: Fri, 18 Apr 2008 21:26:20 -0400
Message-ID: <1208568380-22219-1-git-send-email-mark.asselstine@windriver.com>
References: <20080418190729.GE20637@parisc-linux.org>
Cc: chas@cmf.nrl.navy.mil, netdev@vger.kernel.org,
	Mark Asselstine <mark.asselstine@windriver.com>
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:40451 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751026AbYDSB00 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Apr 2008 21:26:26 -0400
In-Reply-To: <20080418190729.GE20637@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Code within NS_DEBUG_SPINLOCKS contained deprecated cli()/sti() function calls.
NS_DEBUG_SPINLOCKS and the associated code seems to be of little use these days
so the strategy of removing this code rather then updating it to use spinlocks
has been taken.

Signed-off-by: Mark Asselstine <mark.asselstine@windriver.com>
---
 drivers/atm/nicstar.c |  117 ++++++++-----------------------------------------
 drivers/atm/nicstar.h |   12 -----
 2 files changed, 19 insertions(+), 110 deletions(-)

diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index 0c205b0..38c769f 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -125,85 +125,6 @@
 #define ATM_SKB(s) (&(s)->atm)
 #endif
 
-   /* Spinlock debugging stuff */
-#ifdef NS_DEBUG_SPINLOCKS /* See nicstar.h */
-#define ns_grab_int_lock(card,flags) \
- do { \
-    unsigned long nsdsf, nsdsf2; \
-    local_irq_save(flags); \
-    save_flags(nsdsf); cli();\
-    if (nsdsf & (1<<9)) printk ("nicstar.c: ints %sabled -> enabled.\n", \
-                                (flags)&(1<<9)?"en":"dis"); \
-    if (spin_is_locked(&(card)->int_lock) && \
-        (card)->cpu_int == smp_processor_id()) { \
-       printk("nicstar.c: line %d (cpu %d) int_lock already locked at line %d (cpu %d)\n", \
-              __LINE__, smp_processor_id(), (card)->has_int_lock, \
-              (card)->cpu_int); \
-       printk("nicstar.c: ints were %sabled.\n", ((flags)&(1<<9)?"en":"dis")); \
-    } \
-    if (spin_is_locked(&(card)->res_lock) && \
-        (card)->cpu_res == smp_processor_id()) { \
-       printk("nicstar.c: line %d (cpu %d) res_lock locked at line %d (cpu %d)(trying int)\n", \
-              __LINE__, smp_processor_id(), (card)->has_res_lock, \
-              (card)->cpu_res); \
-       printk("nicstar.c: ints were %sabled.\n", ((flags)&(1<<9)?"en":"dis")); \
-    } \
-    spin_lock_irq(&(card)->int_lock); \
-    (card)->has_int_lock = __LINE__; \
-    (card)->cpu_int = smp_processor_id(); \
-    restore_flags(nsdsf); } while (0)
-#define ns_grab_res_lock(card,flags) \
- do { \
-    unsigned long nsdsf, nsdsf2; \
-    local_irq_save(flags); \
-    save_flags(nsdsf); cli();\
-    if (nsdsf & (1<<9)) printk ("nicstar.c: ints %sabled -> enabled.\n", \
-                                (flags)&(1<<9)?"en":"dis"); \
-    if (spin_is_locked(&(card)->res_lock) && \
-        (card)->cpu_res == smp_processor_id()) { \
-       printk("nicstar.c: line %d (cpu %d) res_lock already locked at line %d (cpu %d)\n", \
-              __LINE__, smp_processor_id(), (card)->has_res_lock, \
-              (card)->cpu_res); \
-       printk("nicstar.c: ints were %sabled.\n", ((flags)&(1<<9)?"en":"dis")); \
-    } \
-    spin_lock_irq(&(card)->res_lock); \
-    (card)->has_res_lock = __LINE__; \
-    (card)->cpu_res = smp_processor_id(); \
-    restore_flags(nsdsf); } while (0)
-#define ns_grab_scq_lock(card,scq,flags) \
- do { \
-    unsigned long nsdsf, nsdsf2; \
-    local_irq_save(flags); \
-    save_flags(nsdsf); cli();\
-    if (nsdsf & (1<<9)) printk ("nicstar.c: ints %sabled -> enabled.\n", \
-                                (flags)&(1<<9)?"en":"dis"); \
-    if (spin_is_locked(&(scq)->lock) && \
-        (scq)->cpu_lock == smp_processor_id()) { \
-       printk("nicstar.c: line %d (cpu %d) this scq_lock already locked at line %d (cpu %d)\n", \
-              __LINE__, smp_processor_id(), (scq)->has_lock, \
-              (scq)->cpu_lock); \
-       printk("nicstar.c: ints were %sabled.\n", ((flags)&(1<<9)?"en":"dis")); \
-    } \
-    if (spin_is_locked(&(card)->res_lock) && \
-        (card)->cpu_res == smp_processor_id()) { \
-       printk("nicstar.c: line %d (cpu %d) res_lock locked at line %d (cpu %d)(trying scq)\n", \
-              __LINE__, smp_processor_id(), (card)->has_res_lock, \
-              (card)->cpu_res); \
-       printk("nicstar.c: ints were %sabled.\n", ((flags)&(1<<9)?"en":"dis")); \
-    } \
-    spin_lock_irq(&(scq)->lock); \
-    (scq)->has_lock = __LINE__; \
-    (scq)->cpu_lock = smp_processor_id(); \
-    restore_flags(nsdsf); } while (0)
-#else /* !NS_DEBUG_SPINLOCKS */
-#define ns_grab_int_lock(card,flags) \
-        spin_lock_irqsave(&(card)->int_lock,(flags))
-#define ns_grab_res_lock(card,flags) \
-        spin_lock_irqsave(&(card)->res_lock,(flags))
-#define ns_grab_scq_lock(card,scq,flags) \
-        spin_lock_irqsave(&(scq)->lock,flags)
-#endif /* NS_DEBUG_SPINLOCKS */
-
 
 /* Function declarations ******************************************************/
 
@@ -422,7 +343,7 @@ static u32 ns_read_sram(ns_dev *card, u32 sram_address)
    sram_address <<= 2;
    sram_address &= 0x0007FFFC;	/* address must be dword aligned */
    sram_address |= 0x50000000;	/* SRAM read command */
-   ns_grab_res_lock(card, flags);
+   spin_lock_irqsave(&card->res_lock, flags);
    while (CMD_BUSY(card));
    writel(sram_address, card->membase + CMD);
    while (CMD_BUSY(card));
@@ -440,7 +361,7 @@ static void ns_write_sram(ns_dev *card, u32 sram_address, u32 *value, int count)
    count--;	/* count range now is 0..3 instead of 1..4 */
    c = count;
    c <<= 2;	/* to use increments of 4 */
-   ns_grab_res_lock(card, flags);
+   spin_lock_irqsave(&card->res_lock, flags);
    while (CMD_BUSY(card));
    for (i = 0; i <= c; i += 4)
       writel(*(value++), card->membase + i);
@@ -1166,7 +1087,7 @@ static void push_rxbufs(ns_dev *card, struct sk_buff *skb)
             card->lbfqc += 2;
       }
 
-      ns_grab_res_lock(card, flags);
+      spin_lock_irqsave(&card->res_lock, flags);
 
       while (CMD_BUSY(card));
       writel(addr2, card->membase + DR3);
@@ -1206,7 +1127,7 @@ static irqreturn_t ns_irq_handler(int irq, void *dev_id)
 
    PRINTK("nicstar%d: NICStAR generated an interrupt\n", card->index);
 
-   ns_grab_int_lock(card, flags);
+   spin_lock_irqsave(&card->int_lock, flags);
    
    stat_r = readl(card->membase + STAT);
 
@@ -1585,7 +1506,7 @@ static void ns_close(struct atm_vcc *vcc)
       unsigned long flags;
       
       addr = NS_RCT + (vcc->vpi << card->vcibits | vcc->vci) * NS_RCT_ENTRY_SIZE;
-      ns_grab_res_lock(card, flags);
+      spin_lock_irqsave(&card->res_lock, flags);
       while(CMD_BUSY(card));
       writel(NS_CMD_CLOSE_CONNECTION | addr << 2, card->membase + CMD);
       spin_unlock_irqrestore(&card->res_lock, flags);
@@ -1607,7 +1528,7 @@ static void ns_close(struct atm_vcc *vcc)
 	                       NS_SKB(iovb)->iovcnt);
          NS_SKB(iovb)->iovcnt = 0;
          NS_SKB(iovb)->vcc = NULL;
-         ns_grab_int_lock(card, flags);
+         spin_lock_irqsave(&card->int_lock, flags);
          recycle_iov_buf(card, iovb);
          spin_unlock_irqrestore(&card->int_lock, flags);
          vc->rx_iov = NULL;
@@ -1629,7 +1550,7 @@ static void ns_close(struct atm_vcc *vcc)
 
       for (;;)
       {
-         ns_grab_scq_lock(card, scq, flags);
+         spin_lock_irqsave(&scq->lock, flags);
          scqep = scq->next;
          if (scqep == scq->base)
             scqep = scq->last;
@@ -1691,7 +1612,7 @@ static void ns_close(struct atm_vcc *vcc)
      unsigned long flags;
      scq_info *scq = card->scq0;
 
-     ns_grab_scq_lock(card, scq, flags);
+     spin_lock_irqsave(&scq->lock, flags);
 
      for(i = 0; i < scq->num_entries; i++) {
        if(scq->skb[i] && ATM_SKB(scq->skb[i])->vcc == vcc) {
@@ -1892,7 +1813,7 @@ static int push_scqe(ns_dev *card, vc_map *vc, scq_info *scq, ns_scqe *tbd,
    u32 data;
    int index;
    
-   ns_grab_scq_lock(card, scq, flags);
+   spin_lock_irqsave(&scq->lock, flags);
    while (scq->tail == scq->next)
    {
       if (in_interrupt()) {
@@ -1904,7 +1825,7 @@ static int push_scqe(ns_dev *card, vc_map *vc, scq_info *scq, ns_scqe *tbd,
       scq->full = 1;
       spin_unlock_irqrestore(&scq->lock, flags);
       interruptible_sleep_on_timeout(&scq->scqfull_waitq, SCQFULL_TIMEOUT);
-      ns_grab_scq_lock(card, scq, flags);
+      spin_lock_irqsave(&scq->lock, flags);
 
       if (scq->full) {
          spin_unlock_irqrestore(&scq->lock, flags);
@@ -1953,7 +1874,7 @@ static int push_scqe(ns_dev *card, vc_map *vc, scq_info *scq, ns_scqe *tbd,
          if (has_run++) break;
          spin_unlock_irqrestore(&scq->lock, flags);
          interruptible_sleep_on_timeout(&scq->scqfull_waitq, SCQFULL_TIMEOUT);
-         ns_grab_scq_lock(card, scq, flags);
+         spin_lock_irqsave(&scq->lock, flags);
       }
 
       if (!scq->full)
@@ -2090,7 +2011,7 @@ static void drain_scq(ns_dev *card, scq_info *scq, int pos)
       return;
    }
 
-   ns_grab_scq_lock(card, scq, flags);
+   spin_lock_irqsave(&scq->lock, flags);
    i = (int) (scq->tail - scq->base);
    if (++i == scq->num_entries)
       i = 0;
@@ -2898,7 +2819,7 @@ static int ns_ioctl(struct atm_dev *dev, unsigned int cmd, void __user *arg)
 	       {
                   struct sk_buff *hb;
 
-                  ns_grab_int_lock(card, flags);
+                  spin_lock_irqsave(&card->int_lock, flags);
 		  hb = skb_dequeue(&card->hbpool.queue);
 		  card->hbpool.count--;
                   spin_unlock_irqrestore(&card->int_lock, flags);
@@ -2917,7 +2838,7 @@ static int ns_ioctl(struct atm_dev *dev, unsigned int cmd, void __user *arg)
                   if (hb == NULL)
                      return -ENOMEM;
                   NS_SKB_CB(hb)->buf_type = BUF_NONE;
-                  ns_grab_int_lock(card, flags);
+                  spin_lock_irqsave(&card->int_lock, flags);
                   skb_queue_tail(&card->hbpool.queue, hb);
                   card->hbpool.count++;
                   spin_unlock_irqrestore(&card->int_lock, flags);
@@ -2929,7 +2850,7 @@ static int ns_ioctl(struct atm_dev *dev, unsigned int cmd, void __user *arg)
 	       {
 	          struct sk_buff *iovb;
 
-                  ns_grab_int_lock(card, flags);
+                  spin_lock_irqsave(&card->int_lock, flags);
 		  iovb = skb_dequeue(&card->iovpool.queue);
 		  card->iovpool.count--;
                   spin_unlock_irqrestore(&card->int_lock, flags);
@@ -2948,7 +2869,7 @@ static int ns_ioctl(struct atm_dev *dev, unsigned int cmd, void __user *arg)
                   if (iovb == NULL)
                      return -ENOMEM;
                   NS_SKB_CB(iovb)->buf_type = BUF_NONE;
-                  ns_grab_int_lock(card, flags);
+                  spin_lock_irqsave(&card->int_lock, flags);
                   skb_queue_tail(&card->iovpool.queue, iovb);
                   card->iovpool.count++;
                   spin_unlock_irqrestore(&card->int_lock, flags);
@@ -2995,7 +2916,7 @@ static void ns_poll(unsigned long arg)
       /* Probably it isn't worth spinning */
          continue;
       }
-      ns_grab_int_lock(card, flags);
+      spin_lock_irqsave(&card->int_lock, flags);
 
       stat_w = 0;
       stat_r = readl(card->membase + STAT);
@@ -3062,7 +2983,7 @@ static void ns_phy_put(struct atm_dev *dev, unsigned char value,
    unsigned long flags;
 
    card = dev->dev_data;
-   ns_grab_res_lock(card, flags);
+   spin_lock_irqsave(&card->res_lock, flags);
    while(CMD_BUSY(card));
    writel((unsigned long) value, card->membase + DR0);
    writel(NS_CMD_WRITE_UTILITY | 0x00000200 | (addr & 0x000000FF),
@@ -3079,7 +3000,7 @@ static unsigned char ns_phy_get(struct atm_dev *dev, unsigned long addr)
    unsigned long data;
 
    card = dev->dev_data;
-   ns_grab_res_lock(card, flags);
+   spin_lock_irqsave(&card->res_lock, flags);
    while(CMD_BUSY(card));
    writel(NS_CMD_READ_UTILITY | 0x00000200 | (addr & 0x000000FF),
           card->membase + CMD);
diff --git a/drivers/atm/nicstar.h b/drivers/atm/nicstar.h
index 5997bcb..6010e3d 100644
--- a/drivers/atm/nicstar.h
+++ b/drivers/atm/nicstar.h
@@ -28,8 +28,6 @@
 
 /* Options ********************************************************************/
 
-#undef NS_DEBUG_SPINLOCKS
-
 #define NS_MAX_CARDS 4		/* Maximum number of NICStAR based cards
 				   controlled by the device driver. Must
                                    be <= 5 */
@@ -721,10 +719,6 @@ typedef struct scq_info
    wait_queue_head_t scqfull_waitq;
    volatile char full;			/* SCQ full indicator */
    spinlock_t lock;			/* SCQ spinlock */
-#ifdef NS_DEBUG_SPINLOCKS
-   volatile long has_lock;
-   volatile int cpu_lock;
-#endif /* NS_DEBUG_SPINLOCKS */
 } scq_info;
 
 
@@ -810,12 +804,6 @@ typedef struct ns_dev
    unsigned intcnt;			/* Interrupt counter */
    spinlock_t int_lock;		/* Interrupt lock */
    spinlock_t res_lock;		/* Card resource lock */
-#ifdef NS_DEBUG_SPINLOCKS
-   volatile long has_int_lock;
-   volatile int cpu_int;
-   volatile long has_res_lock;
-   volatile int cpu_res;
-#endif /* NS_DEBUG_SPINLOCKS */
 } ns_dev;
 
 
-- 
1.5.4.3

