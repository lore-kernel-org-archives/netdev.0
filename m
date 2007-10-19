From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH] sparc/xen/cxgb3: use irq_handler_t where appropriate
Date: Fri, 19 Oct 2007 03:33:03 -0400
Message-ID: <20071019073303.GA5728@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: David Miller <davem@davemloft.net>, jeremy@xensource.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:51162 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763538AbXJSHdF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 03:33:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


commit 21b1f26bf54a2ba1e4072db6dd01da128b1f66ef
Author: Jeff Garzik <jeff@garzik.org>
Date:   Fri Oct 19 03:12:20 2007 -0400

    [SPARC, XEN, NET/CXGB3] use irq_handler_t where appropriate
    
    Rather than hand-rolling our own prototype, make the code more
    future-proof by using the standard irq_handler_t typedef.
    
    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

 arch/sparc/kernel/irq.c     |    4 ++--
 arch/x86/xen/events.c       |    4 ++--
 drivers/net/cxgb3/adapter.h |    4 +---
 drivers/net/cxgb3/sge.c     |    2 +-
 4 files changed, 6 insertions(+), 8 deletions(-)

21b1f26bf54a2ba1e4072db6dd01da128b1f66ef
diff --git a/arch/sparc/kernel/irq.c b/arch/sparc/kernel/irq.c
index 722d67d..e1e24f3 100644
--- a/arch/sparc/kernel/irq.c
+++ b/arch/sparc/kernel/irq.c
@@ -479,7 +479,7 @@ EXPORT_SYMBOL(pdma_areasize);
 
 extern void floppy_hardint(void);
 
-static irqreturn_t (*floppy_irq_handler)(int irq, void *dev_id);
+static irq_handler_t floppy_irq_handler;
 
 void sparc_floppy_irq(int irq, void *dev_id, struct pt_regs *regs)
 {
@@ -500,7 +500,7 @@ void sparc_floppy_irq(int irq, void *dev_id, struct pt_regs *regs)
 }
 
 int sparc_floppy_request_irq(int irq, unsigned long flags,
-			     irqreturn_t (*irq_handler)(int irq, void *))
+			     irq_handler_t irq_handler)
 {
 	floppy_irq_handler = irq_handler;
 	return request_fast_irq(irq, floppy_hardint, flags, "floppy");
diff --git a/arch/x86/xen/events.c b/arch/x86/xen/events.c
index da1b173..6d1da58 100644
--- a/arch/x86/xen/events.c
+++ b/arch/x86/xen/events.c
@@ -383,7 +383,7 @@ static void unbind_from_irq(unsigned int irq)
 }
 
 int bind_evtchn_to_irqhandler(unsigned int evtchn,
-			      irqreturn_t (*handler)(int, void *),
+			      irq_handler_t handler,
 			      unsigned long irqflags,
 			      const char *devname, void *dev_id)
 {
@@ -402,7 +402,7 @@ int bind_evtchn_to_irqhandler(unsigned int evtchn,
 EXPORT_SYMBOL_GPL(bind_evtchn_to_irqhandler);
 
 int bind_virq_to_irqhandler(unsigned int virq, unsigned int cpu,
-			    irqreturn_t (*handler)(int, void *),
+			    irq_handler_t handler,
 			    unsigned long irqflags, const char *devname, void *dev_id)
 {
 	unsigned int irq;
diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index 0442617..3814cc6 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -46,8 +46,6 @@
 #include <asm/bitops.h>
 #include <asm/io.h>
 
-typedef irqreturn_t(*intr_handler_t) (int, void *);
-
 struct vlan_group;
 struct adapter;
 struct sge_qset;
@@ -270,7 +268,7 @@ void t3_sge_start(struct adapter *adap);
 void t3_sge_stop(struct adapter *adap);
 void t3_free_sge_resources(struct adapter *adap);
 void t3_sge_err_intr_handler(struct adapter *adapter);
-intr_handler_t t3_intr_handler(struct adapter *adap, int polling);
+irq_handler_t t3_intr_handler(struct adapter *adap, int polling);
 int t3_eth_xmit(struct sk_buff *skb, struct net_device *dev);
 int t3_mgmt_tx(struct adapter *adap, struct sk_buff *skb);
 void t3_update_qset_coalesce(struct sge_qset *qs, const struct qset_params *p);
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 994b5d6..c15e43a 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -2431,7 +2431,7 @@ static irqreturn_t t3b_intr_napi(int irq, void *cookie)
  *	(MSI-X, MSI, or legacy) and whether NAPI will be used to service the
  *	response queues.
  */
-intr_handler_t t3_intr_handler(struct adapter *adap, int polling)
+irq_handler_t t3_intr_handler(struct adapter *adap, int polling)
 {
 	if (adap->flags & USING_MSIX)
 		return polling ? t3_sge_intr_msix_napi : t3_sge_intr_msix;
