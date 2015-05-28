From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net 3/3] bna: fix soft lock-up during firmware initialization failure
Date: Thu, 28 May 2015 23:10:08 +0200
Message-ID: <1432847408-5066-4-git-send-email-ivecera@redhat.com>
References: <1432847408-5066-1-git-send-email-ivecera@redhat.com>
Cc: Rasesh Mody <rasesh.mody@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55212 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754713AbbE1VKH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 17:10:07 -0400
In-Reply-To: <1432847408-5066-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bug in the driver initialization causes soft-lockup if firmware
initialization timeout is reached. Polling function bfa_ioc_poll_fwinit()
incorrectly calls bfa_nw_iocpf_timeout() when the timeout is reached.
The problem is that bfa_nw_iocpf_timeout() calls again
bfa_ioc_poll_fwinit()... etc. The bfa_ioc_poll_fwinit() should directly
send timeout event for iocpf and the same should be done if firmware
download into HW fails.

Cc: Rasesh Mody <rasesh.mody@qlogic.com>
Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bfa_ioc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.c b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
index 594a2ab..68f3c13 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
@@ -2414,7 +2414,7 @@ bfa_ioc_boot(struct bfa_ioc *ioc, enum bfi_fwboot_type boot_type,
 	if (status == BFA_STATUS_OK)
 		bfa_ioc_lpu_start(ioc);
 	else
-		bfa_nw_iocpf_timeout(ioc);
+		bfa_fsm_send_event(&ioc->iocpf, IOCPF_E_TIMEOUT);
 
 	return status;
 }
@@ -3029,7 +3029,7 @@ bfa_ioc_poll_fwinit(struct bfa_ioc *ioc)
 	}
 
 	if (ioc->iocpf.poll_time >= BFA_IOC_TOV) {
-		bfa_nw_iocpf_timeout(ioc);
+		bfa_fsm_send_event(&ioc->iocpf, IOCPF_E_TIMEOUT);
 	} else {
 		ioc->iocpf.poll_time += BFA_IOC_POLL_TOV;
 		mod_timer(&ioc->iocpf_timer, jiffies +
-- 
2.3.6
