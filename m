From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH] net: Fix new EMAC driver for NAPI changes
Date: Tue, 16 Oct 2007 15:40:50 +1000
Message-ID: <1192513250.19073.10.camel@pasglop>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Roland Dreier <rdreier@cisco.com>,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>
To: shemminger@linux.foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:36266 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759211AbXJPFlS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 01:41:18 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net: Fix new EMAC driver for NAPI changes

This fixes the new EMAC driver for the NAPI updates. The previous patch
by Roland Dreier (already applied) to do that doesn't actually work. This
applies on top of it makes it work on my test Ebony machine.

This patch depends on "net: Add __napi_sycnhronize() to sync with napi poll"
posted previously.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

The old EMAC driver does things a bit differently (doesn't do useful
locking :-) and seems to work with Roland patch. So I'm not going to
touch it unless somebody reports me that it has problems


Index: linux-work/drivers/net/ibm_newemac/mal.c
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/mal.c	2007-10-16 14:51:11.000000000 +1000
+++ linux-work/drivers/net/ibm_newemac/mal.c	2007-10-16 14:59:23.000000000 +1000
@@ -45,6 +45,8 @@ int __devinit mal_register_commac(struct
 		return -EBUSY;
 	}
 
+	if (list_empty(&mal->list))
+		napi_enable(&mal->napi);
 	mal->tx_chan_mask |= commac->tx_chan_mask;
 	mal->rx_chan_mask |= commac->rx_chan_mask;
 	list_add(&commac->list, &mal->list);
@@ -67,6 +69,8 @@ void __devexit mal_unregister_commac(str
 	mal->tx_chan_mask &= ~commac->tx_chan_mask;
 	mal->rx_chan_mask &= ~commac->rx_chan_mask;
 	list_del_init(&commac->list);
+	if (list_empty(&mal->list))
+		napi_disable(&mal->napi);
 
 	spin_unlock_irqrestore(&mal->lock, flags);
 }
@@ -182,7 +186,7 @@ static inline void mal_enable_eob_irq(st
 	set_mal_dcrn(mal, MAL_CFG, get_mal_dcrn(mal, MAL_CFG) | MAL_CFG_EOPIE);
 }
 
-/* synchronized by __LINK_STATE_RX_SCHED bit in ndev->state */
+/* synchronized by NAPI state */
 static inline void mal_disable_eob_irq(struct mal_instance *mal)
 {
 	// XXX might want to cache MAL_CFG as the DCR read can be slooooow
@@ -317,8 +321,8 @@ void mal_poll_disable(struct mal_instanc
 	while (test_and_set_bit(MAL_COMMAC_POLL_DISABLED, &commac->flags))
 		msleep(1);
 
-	/* Synchronize with the MAL NAPI poller. */
-	napi_disable(&mal->napi);
+	/* Synchronize with the MAL NAPI poller */
+	__napi_synchronize(&mal->napi);
 }
 
 void mal_poll_enable(struct mal_instance *mal, struct mal_commac *commac)
@@ -326,7 +330,12 @@ void mal_poll_enable(struct mal_instance
 	smp_wmb();
 	clear_bit(MAL_COMMAC_POLL_DISABLED, &commac->flags);
 
-	// XXX might want to kick a poll now...
+	/* Feels better to trigger a poll here to catch up with events that
+	 * may have happened on this channel while disabled. It will most
+	 * probably be delayed until the next interrupt but that's mostly a
+	 * non-issue in the context where this is called.
+	 */
+	napi_schedule(&mal->napi);
 }
 
 static int mal_poll(struct napi_struct *napi, int budget)
@@ -336,8 +345,7 @@ static int mal_poll(struct napi_struct *
 	int received = 0;
 	unsigned long flags;
 
-	MAL_DBG2(mal, "poll(%d) %d ->" NL, *budget,
-		 rx_work_limit);
+	MAL_DBG2(mal, "poll(%d)" NL, budget);
  again:
 	/* Process TX skbs */
 	list_for_each(l, &mal->poll_list) {
@@ -528,11 +536,12 @@ static int __devinit mal_probe(struct of
 	}
 
 	INIT_LIST_HEAD(&mal->poll_list);
-	mal->napi.weight = CONFIG_IBM_NEW_EMAC_POLL_WEIGHT;
-	mal->napi.poll = mal_poll;
 	INIT_LIST_HEAD(&mal->list);
 	spin_lock_init(&mal->lock);
 
+	netif_napi_add(NULL, &mal->napi, mal_poll,
+		       CONFIG_IBM_NEW_EMAC_POLL_WEIGHT);
+
 	/* Load power-on reset defaults */
 	mal_reset(mal);
 


