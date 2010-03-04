From: David Dillow <dave@thedillows.org>
Subject: [PATCH] r8169: use correct barrier between cacheable and
 non-cacheable memory
Date: Wed, 03 Mar 2010 21:33:10 -0500
Message-ID: <1267669990.23829.8.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Paul Mackerras <paulus@samba.org>,
	Catalin Marinas <catalin.marinas@arm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:59852 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751887Ab0CDCdN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 21:33:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

r8169 needs certain writes to be visible to other CPUs or the NIC before
touching the hardware, but was using smp_wmb() which is only required to
order cacheable memory access. Switch to wmb() which is required to
order both cacheable and non-cacheable memory.

Noticed by Catalin Marinas and Paul Mackerras.

Signed-off-by: David Dillow <dave@thedillows.org>
---
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index dfc3573..9d3ebf3 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4270,7 +4270,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	tp->cur_tx += frags + 1;
 
-	smp_wmb();
+	wmb();
 
 	RTL_W8(TxPoll, NPQ);	/* set polling bit */
 
@@ -4621,7 +4621,7 @@ static int rtl8169_poll(struct napi_struct *napi, int budget)
 		 * until it does.
 		 */
 		tp->intr_mask = 0xffff;
-		smp_wmb();
+		wmb();
 		RTL_W16(IntrMask, tp->intr_event);
 	}
 


