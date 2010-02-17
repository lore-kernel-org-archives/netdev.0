From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 2/3] qlge: Fix bonding mac address bug.
Date: Wed, 17 Feb 2010 08:41:22 -0800
Message-ID: <1266424883-25927-3-git-send-email-ron.mercer@qlogic.com>
References: <1266424883-25927-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:36599 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308Ab0BQQsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 11:48:31 -0500
In-Reply-To: <1266424883-25927-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use local copy of current mac address when initializing.  In bonding
testing we saw cases where dev_addr was out of data causing failover
errors.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |    2 ++
 drivers/net/qlge/qlge_main.c |    6 +++++-
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 57d135e..8b742b6 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -2139,6 +2139,8 @@ struct ql_adapter {
 	u16 device_id;
 	struct timer_list timer;
 	atomic_t lb_count;
+	/* Keep local copy of current mac address. */
+	char current_mac_addr[6];
 };
 
 /*
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 0541e77..c170349 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -463,7 +463,7 @@ static int ql_set_mac_addr(struct ql_adapter *qdev, int set)
 	char *addr;
 
 	if (set) {
-		addr = &qdev->ndev->dev_addr[0];
+		addr = &qdev->current_mac_addr[0];
 		netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
 			     "Set Mac addr %pM\n", addr);
 	} else {
@@ -4301,6 +4301,8 @@ static int qlge_set_mac_address(struct net_device *ndev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 	memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
+	/* Update local copy of current mac address. */
+	memcpy(qdev->current_mac_addr, ndev->dev_addr, ndev->addr_len);
 
 	status = ql_sem_spinlock(qdev, SEM_MAC_ADDR_MASK);
 	if (status)
@@ -4542,6 +4544,8 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 	}
 
 	memcpy(ndev->perm_addr, ndev->dev_addr, ndev->addr_len);
+	/* Keep local copy of current mac address. */
+	memcpy(qdev->current_mac_addr, ndev->dev_addr, ndev->addr_len);
 
 	/* Set up the default ring sizes. */
 	qdev->tx_ring_size = NUM_TX_RING_ENTRIES;
-- 
1.6.0.2

