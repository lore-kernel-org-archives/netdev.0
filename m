From: akpm@linux-foundation.org
Subject: [patch for 2.6.25? 3/3] skge napi->poll() locking bug
Date: Thu, 27 Mar 2008 00:45:14 -0700
Message-ID: <200803270745.m2R7jEUA024166@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	mitov@issp.bas.bg, davem@davemloft.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:53081 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755016AbYC0Hpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 03:45:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marin Mitov <mitov@issp.bas.bg>

According to: Documentation/networking/netdevices.txt:

<cite>
napi->poll:
..........
	Context: softirq
	         will be called with interrupts disabled by netconsole.
</cite>

napi->poll() could be called either with interrupts enabled
(in softirq context) or disabled (by netconsole), so the irq flag
should be preserved.

Inspired by Ingo's resent forcedeth patch :-)

Signed-off-by: Marin Mitov <mitov@issp.bas.bg>
Acked-by: David S. Miller <davem@davemloft.net>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/skge.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff -puN drivers/net/skge.c~skge-napi-poll-locking-bug drivers/net/skge.c
--- a/drivers/net/skge.c~skge-napi-poll-locking-bug
+++ a/drivers/net/skge.c
@@ -3199,12 +3199,14 @@ static int skge_poll(struct napi_struct 
 	skge_write8(hw, Q_ADDR(rxqaddr[skge->port], Q_CSR), CSR_START);
 
 	if (work_done < to_do) {
-		spin_lock_irq(&hw->hw_lock);
+		unsigned long flags;
+
+		spin_lock_irqsave(&hw->hw_lock, flags);
 		__netif_rx_complete(dev, napi);
 		hw->intr_mask |= napimask[skge->port];
 		skge_write32(hw, B0_IMSK, hw->intr_mask);
 		skge_read32(hw, B0_IMSK);
-		spin_unlock_irq(&hw->hw_lock);
+		spin_unlock_irqrestore(&hw->hw_lock, flags);
 	}
 
 	return work_done;
_
