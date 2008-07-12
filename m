From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 6/6] netxen: put back driver xmit lock
Date: Sat, 12 Jul 2008 12:25:20 -0700
Message-ID: <1215890720-29744-7-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:33987 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752802AbYGLTZW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jul 2008 15:25:22 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Was removed by a recent commit, but it's required while sending
management commands to new netxen firmware.

There's already discussion about pushing dev xmit lock into 
drivers.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    1 +
 drivers/net/netxen/netxen_nic_init.c |    4 ++--
 drivers/net/netxen/netxen_nic_main.c |    7 +++++++
 3 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 32016ae..b0036f9 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -913,6 +913,7 @@ struct netxen_adapter {
 	u32 curr_window;
 	u32 crb_win;
 	rwlock_t adapter_lock;
+	spinlock_t tx_lock;
 
 	uint64_t dma_mask;
 
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index d48d1a3..a08f00a 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1369,10 +1369,10 @@ int netxen_process_cmd_ring(struct netxen_adapter *adapter)
 		adapter->last_cmd_consumer = last_consumer;
 		smp_mb();
 		if (netif_queue_stopped(netdev) && netif_running(netdev)) {
-			netif_tx_lock(netdev);
+			spin_lock(&adapter->tx_lock);
 			netif_wake_queue(netdev);
 			smp_mb();
-			netif_tx_unlock(netdev);
+			spin_unlock(&adapter->tx_lock);
 		}
 	}
 	/*
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 57b1f83..6a399f0 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -588,6 +588,8 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_free_netdev;
 
 	rwlock_init(&adapter->adapter_lock);
+	spin_lock_init(&adapter->tx_lock);
+
 	adapter->ahw.qdr_sn_window = -1;
 	adapter->ahw.ddr_mn_window = -1;
 
@@ -1184,12 +1186,16 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		}
 	}
 
+	if (!spin_trylock_bh(&adapter->tx_lock))
+		return NETDEV_TX_LOCKED;
+
 	producer = adapter->cmd_producer;
 	smp_mb();
 	consumer = adapter->last_cmd_consumer;
 	if ((no_of_desc+2) > find_diff_among(producer, consumer, num_txd)) {
 		netif_stop_queue(netdev);
 		smp_mb();
+		spin_unlock_bh(&adapter->tx_lock);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1323,6 +1329,7 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	adapter->stats.xmitcalled++;
 	netdev->trans_start = jiffies;
 
+	spin_unlock_bh(&adapter->tx_lock);
 	return NETDEV_TX_OK;
 }
 
-- 
1.5.4.3

