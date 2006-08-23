From: Jason Borg <jcborg@somanetworks.com>
Subject: [PATCH 2/5] smc911x: Early exit from isr with spinlock held
Date: Wed, 23 Aug 2006 15:16:18 -0400
Message-ID: <1156360579.15824.72.camel@borg.yyz.somanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: dustin@sensoria.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ldap.somanetworks.com ([216.126.67.42]:51615 "EHLO
	mail.somanetworks.com") by vger.kernel.org with ESMTP
	id S965122AbWHWTQX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 15:16:23 -0400
Received: from borg.yyz.somanetworks.com ([10.11.11.252])
          (envelope-sender <jcborg@somanetworks.com>)
          by mail.somanetworks.com (qmail-ldap-1.03) with SMTP
          for <netdev@vger.kernel.org>; 23 Aug 2006 19:16:19 -0000
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes an early return from the interrupt handler on a spurious 
interrupt without releasing a lock.

Signed-off-by: Jason Borg <jcborg@somanetworks.com>
---
Note, I thought I'd mention that I noticed a patch with this
same fix in 2.6.18-rc4-mm2.

diff -uprN linux-2.6.18-rc4-orig/drivers/net/smc911x.c linux-2.6.18-rc4/drivers/net/smc911x.c
--- linux-2.6.18-rc4-orig/drivers/net/smc911x.c	2006-08-22 15:39:24.200701014 -0400
+++ linux-2.6.18-rc4/drivers/net/smc911x.c	2006-08-22 15:39:54.778193514 -0400
@@ -1092,6 +1092,7 @@ static irqreturn_t smc911x_interrupt(int
 	/* Spurious interrupt check */
 	if ((SMC_GET_IRQ_CFG() & (INT_CFG_IRQ_INT_ | INT_CFG_IRQ_EN_)) !=
 		(INT_CFG_IRQ_INT_ | INT_CFG_IRQ_EN_)) {
+		spin_unlock_irqrestore(&lp->lock, flags);
 		return IRQ_NONE;
 	}
 


