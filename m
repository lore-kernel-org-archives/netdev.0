From: Shannon Nelson <shannon.nelson@intel.com>
Subject: [PATCH] NET: [CORE] Re-enable irqs before pushing pending DMA requests
Date: Thu, 21 Jun 2007 09:34:55 -0700
Message-ID: <20070621163455.28160.35548.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:47217 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752763AbXFUQfH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jun 2007 12:35:07 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This moves the local_irq_enable() call in net_rx_action() to before
calling the CONFIG_NET_DMA's dma_async_memcpy_issue_pending() rather
than after.  This shortens the irq disabled window and allows for DMA
drivers that need to do their own irq hold.

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
---

 net/core/dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 2609062..ee051bb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2009,6 +2009,7 @@ static void net_rx_action(struct softirq_action *h)
 		}
 	}
 out:
+	local_irq_enable();
 #ifdef CONFIG_NET_DMA
 	/*
 	 * There may not be any more sk_buffs coming right now, so push
@@ -2022,7 +2023,6 @@ out:
 		rcu_read_unlock();
 	}
 #endif
-	local_irq_enable();
 	return;
 
 softnet_break:
