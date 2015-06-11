From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next v2 18/19] bna: fix timeout API argument type
Date: Thu, 11 Jun 2015 15:52:30 +0200
Message-ID: <1434030751-28835-19-git-send-email-ivecera@redhat.com>
References: <1434030751-28835-1-git-send-email-ivecera@redhat.com>
Cc: rasesh.mody@qlogic.com, joe@perches.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47410 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933588AbbFKNw3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 09:52:29 -0400
In-Reply-To: <1434030751-28835-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timeout functions are defined with 'void *' ptr argument. They should
be defined directly with 'struct bfa_ioc *' type to avoid type conversions.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bfa_ioc.c | 16 +++++-----------
 drivers/net/ethernet/brocade/bna/bfa_ioc.h |  8 ++++----
 drivers/net/ethernet/brocade/bna/bnad.c    |  8 ++++----
 3 files changed, 13 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.c b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
index 2c74beb..b009fd7 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
@@ -1895,10 +1895,8 @@ bfa_ioc_hwinit(struct bfa_ioc *ioc, bool force)
 }
 
 void
-bfa_nw_ioc_timeout(void *ioc_arg)
+bfa_nw_ioc_timeout(struct bfa_ioc *ioc)
 {
-	struct bfa_ioc *ioc = (struct bfa_ioc *) ioc_arg;
-
 	bfa_fsm_send_event(ioc, IOC_E_TIMEOUT);
 }
 
@@ -1963,10 +1961,9 @@ bfa_ioc_send_getattr(struct bfa_ioc *ioc)
 }
 
 void
-bfa_nw_ioc_hb_check(void *cbarg)
+bfa_nw_ioc_hb_check(struct bfa_ioc *ioc)
 {
-	struct bfa_ioc *ioc = cbarg;
-	u32	hb_count;
+	u32 hb_count;
 
 	hb_count = readl(ioc->ioc_regs.heartbeat);
 	if (ioc->hb_count == hb_count) {
@@ -2983,9 +2980,8 @@ bfa_iocpf_stop(struct bfa_ioc *ioc)
 }
 
 void
-bfa_nw_iocpf_timeout(void *ioc_arg)
+bfa_nw_iocpf_timeout(struct bfa_ioc *ioc)
 {
-	struct bfa_ioc  *ioc = (struct bfa_ioc *) ioc_arg;
 	enum bfa_iocpf_state iocpf_st;
 
 	iocpf_st = bfa_sm_to_state(iocpf_sm_table, ioc->iocpf.fsm);
@@ -2997,10 +2993,8 @@ bfa_nw_iocpf_timeout(void *ioc_arg)
 }
 
 void
-bfa_nw_iocpf_sem_timeout(void *ioc_arg)
+bfa_nw_iocpf_sem_timeout(struct bfa_ioc *ioc)
 {
-	struct bfa_ioc  *ioc = (struct bfa_ioc *) ioc_arg;
-
 	bfa_ioc_hw_sem_get(ioc);
 }
 
diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.h b/drivers/net/ethernet/brocade/bna/bfa_ioc.h
index b6ad2c5..2c0b4c0 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.h
@@ -304,10 +304,10 @@ int bfa_nw_ioc_debug_fwsave(struct bfa_ioc *ioc, void *trcdata, int *trclen);
 /*
  * Timeout APIs
  */
-void bfa_nw_ioc_timeout(void *ioc);
-void bfa_nw_ioc_hb_check(void *ioc);
-void bfa_nw_iocpf_timeout(void *ioc);
-void bfa_nw_iocpf_sem_timeout(void *ioc);
+void bfa_nw_ioc_timeout(struct bfa_ioc *ioc);
+void bfa_nw_ioc_hb_check(struct bfa_ioc *ioc);
+void bfa_nw_iocpf_timeout(struct bfa_ioc *ioc);
+void bfa_nw_iocpf_sem_timeout(struct bfa_ioc *ioc);
 
 /*
  * F/W Image Size & Chunk
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index fc97428..4542eb2 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -1703,7 +1703,7 @@ bnad_ioc_timeout(unsigned long data)
 	unsigned long flags;
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
-	bfa_nw_ioc_timeout((void *) &bnad->bna.ioceth.ioc);
+	bfa_nw_ioc_timeout(&bnad->bna.ioceth.ioc);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 }
 
@@ -1714,7 +1714,7 @@ bnad_ioc_hb_check(unsigned long data)
 	unsigned long flags;
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
-	bfa_nw_ioc_hb_check((void *) &bnad->bna.ioceth.ioc);
+	bfa_nw_ioc_hb_check(&bnad->bna.ioceth.ioc);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 }
 
@@ -1725,7 +1725,7 @@ bnad_iocpf_timeout(unsigned long data)
 	unsigned long flags;
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
-	bfa_nw_iocpf_timeout((void *) &bnad->bna.ioceth.ioc);
+	bfa_nw_iocpf_timeout(&bnad->bna.ioceth.ioc);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 }
 
@@ -1736,7 +1736,7 @@ bnad_iocpf_sem_timeout(unsigned long data)
 	unsigned long flags;
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
-	bfa_nw_iocpf_sem_timeout((void *) &bnad->bna.ioceth.ioc);
+	bfa_nw_iocpf_sem_timeout(&bnad->bna.ioceth.ioc);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 }
 
-- 
2.3.6
