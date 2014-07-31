From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next] sunvnet: ldc_connect() should not return EINVAL
 when handshake is in progress.
Date: Thu, 31 Jul 2014 10:31:26 -0400
Message-ID: <20140731143126.GA7979@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, karl.volz@oracle.com,
	sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:22216 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751412AbaGaObg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 10:31:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The LDC handshake could have been asynchronously triggered
after ldc_bind() enables the ldc_rx() receive interrupt-handler 
(and thus intercepts incoming control packets)
and before vio_port_up() calls ldc_connect(). If that is the case,
ldc_connect() should return 0 and let the state-machine
progress.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Acked-by: Karl Volz <karl.volz@oracle.com>
---
 arch/sparc/kernel/ldc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/sparc/kernel/ldc.c b/arch/sparc/kernel/ldc.c
index e01d75d..66dacd5 100644
--- a/arch/sparc/kernel/ldc.c
+++ b/arch/sparc/kernel/ldc.c
@@ -1336,7 +1336,7 @@ int ldc_connect(struct ldc_channel *lp)
 	if (!(lp->flags & LDC_FLAG_ALLOCED_QUEUES) ||
 	    !(lp->flags & LDC_FLAG_REGISTERED_QUEUES) ||
 	    lp->hs_state != LDC_HS_OPEN)
-		err = -EINVAL;
+		err = ((lp->hs_state > LDC_HS_OPEN) ? 0 : -EINVAL);
 	else
 		err = start_handshake(lp);
 
-- 
1.8.4.2
