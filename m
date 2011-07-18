From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 24/45] bna: Mboxq Flush When Ioc Disabled
Date: Mon, 18 Jul 2011 01:22:44 -0700
Message-ID: <1310977385-5268-14-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:48242 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753522Ab1GRIYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:24:08 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - If there is a command pending in the mailbox, bfa_ioc_mbox_queue() enqueues
   the mailbox command to a pending command queue. Entries in this queue are
   not flushed when IOC is disabled. As a result, when IOC is re-enabled again,
   the stale entries in the pending command queue are posted to the mailbox.
   When these mailbox commands are processed by the FW and responses are sent,
   unexpected  events are received by other modules' FSMs (f.e. bfa_msgq) which
   have not posted any mailbox commands after IOC was enabled.
 - Flush the pending mailbox command queue when IOC is disabled. Rename
   bfa_ioc_mbox_hbfail to bfa_ioc_mbox_flush. Call bfa_ioc_mbox_flush
   from bfa_iocpf_sm_disabled_entry()

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_ioc.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index 33776da..a38f5cd 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -69,7 +69,7 @@ static void bfa_ioc_hb_monitor(struct bfa_ioc *ioc);
 static void bfa_ioc_hb_stop(struct bfa_ioc *ioc);
 static void bfa_ioc_reset(struct bfa_ioc *ioc, bool force);
 static void bfa_ioc_mbox_poll(struct bfa_ioc *ioc);
-static void bfa_ioc_mbox_hbfail(struct bfa_ioc *ioc);
+static void bfa_ioc_mbox_flush(struct bfa_ioc *ioc);
 static void bfa_ioc_recover(struct bfa_ioc *ioc);
 static void bfa_ioc_check_attr_wwns(struct bfa_ioc *ioc);
 static void bfa_ioc_event_notify(struct bfa_ioc *, enum bfa_ioc_event);
@@ -908,6 +908,7 @@ bfa_iocpf_sm_disabling_sync(struct bfa_iocpf *iocpf, enum iocpf_event event)
 static void
 bfa_iocpf_sm_disabled_entry(struct bfa_iocpf *iocpf)
 {
+	bfa_ioc_mbox_flush(iocpf->ioc);
 	bfa_ioc_pf_disabled(iocpf->ioc);
 }
 
@@ -1012,7 +1013,7 @@ bfa_iocpf_sm_fail_sync_entry(struct bfa_iocpf *iocpf)
 	/**
 	 * Flush any queued up mailbox requests.
 	 */
-	bfa_ioc_mbox_hbfail(iocpf->ioc);
+	bfa_ioc_mbox_flush(iocpf->ioc);
 	bfa_ioc_hw_sem_get(iocpf->ioc);
 }
 
@@ -1606,7 +1607,7 @@ bfa_ioc_mbox_poll(struct bfa_ioc *ioc)
  * Cleanup any pending requests.
  */
 static void
-bfa_ioc_mbox_hbfail(struct bfa_ioc *ioc)
+bfa_ioc_mbox_flush(struct bfa_ioc *ioc)
 {
 	struct bfa_ioc_mbox_mod *mod = &ioc->mbox_mod;
 	struct bfa_mbox_cmd *cmd;
-- 
1.7.1

