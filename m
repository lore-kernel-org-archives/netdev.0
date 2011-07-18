From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 21/45] bna: Remove Reset Call Back
Date: Mon, 18 Jul 2011 01:22:41 -0700
Message-ID: <1310977385-5268-11-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:48234 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753425Ab1GRIX6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:23:58 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Remove call to reset_cbfn() from bfa_ioc_boot().
 - Call bfa_ioc_fail_notify() to notify other modules/driver after setting IOC
   sm state to fail_retry/fail.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_ioc.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index df26a8a..3e38cbb 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -392,12 +392,13 @@ bfa_ioc_sm_op(struct bfa_ioc *ioc, enum ioc_event event)
 		bfa_ioc_hb_stop(ioc);
 		/* !!! fall through !!! */
 	case IOC_E_HBFAIL:
-		bfa_ioc_fail_notify(ioc);
 		if (ioc->iocpf.auto_recover)
 			bfa_fsm_set_state(ioc, bfa_ioc_sm_fail_retry);
 		else
 			bfa_fsm_set_state(ioc, bfa_ioc_sm_fail);
 
+		bfa_ioc_fail_notify(ioc);
+
 		if (event != IOC_E_PFAILED)
 			bfa_iocpf_fail(ioc);
 		break;
@@ -758,6 +759,9 @@ bfa_iocpf_sm_enabling_entry(struct bfa_iocpf *iocpf)
 {
 	mod_timer(&(iocpf->ioc)->iocpf_timer, jiffies +
 		msecs_to_jiffies(BFA_IOC_TOV));
+	/**
+	 * Enable Interrupts before sending fw IOC ENABLE cmd.
+	 */
 	iocpf->ioc->cbfn->reset_cbfn(iocpf->ioc->bfa);
 	bfa_ioc_send_enable(iocpf->ioc);
 }
@@ -1697,10 +1701,6 @@ bfa_ioc_boot(struct bfa_ioc *ioc, enum bfi_fwboot_type boot_type,
 	bfa_ioc_msgflush(ioc);
 	bfa_ioc_download_fw(ioc, boot_type, boot_env);
 
-	/**
-	 * Enable interrupts just before starting LPU
-	 */
-	ioc->cbfn->reset_cbfn(ioc->bfa);
 	bfa_ioc_lpu_start(ioc);
 	bfa_ioc_poll_fwinit(ioc);
 }
-- 
1.7.1

