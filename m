From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: RE: [PATCH 1/7] : e1000 Fix possible causing oops of net_rx_action
Date: Thu, 13 Dec 2007 19:18:56 +0900
Message-ID: <000701c83d71$95536b10$9c94fea9@jason>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jesse.brandeburg@intel.com>, <jgarzik@pobox.com>,
	<shemminger@linux-foundation.org>,
	"'David Miller'" <davem@davemloft.net>
To: "'Kok, Auke'" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.191]:26090 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754549AbXLMKTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 05:19:07 -0500
Received: by rv-out-0910.google.com with SMTP id k20so518377rvb.1
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 02:19:07 -0800 (PST)
References: 
In-Reply-To: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2007/12/12, Joonwoo Park <joonwpark81@gmail.com>:
> [NETDEV]: e1000 Fix possible causing oops of net_rx_action
> returning work_done == weight as true after calling netif_rx_complete will cause oops in net_rx_action.
> 

I tried two types of patches for oops and ifconfig down hang for e1000 first.
Just blowing netif_running up is not best solution I think, it makes ifconfig down hang at least for e1000.
I would like to listen to the others suggestions courteously, please enlighten me :-)

The first:
- if !netif_running, stop receiving process, up to 64 (e1000) packets in the queue would be dropped.
---
 drivers/net/e1000/e1000_main.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 4f37506..664312b 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3938,12 +3938,12 @@ e1000_clean(struct napi_struct *napi, int budget)
 		spin_unlock(&adapter->tx_queue_lock);
 	}
 
-	adapter->clean_rx(adapter, &adapter->rx_ring[0],
-	                  &work_done, budget);
+	if (likely(netif_running(poll_dev)))
+		adapter->clean_rx(adapter, &adapter->rx_ring[0],
+	                  	&work_done, budget);
 
 	/* If no Tx and not enough Rx work done, exit the polling mode */
-	if ((!tx_cleaned && (work_done == 0)) ||
-	   !netif_running(poll_dev)) {
+	if ((!tx_cleaned && (work_done == 0))) {
 quit_polling:
 		if (likely(adapter->itr_setting & 3))
 			e1000_set_itr(adapter);
---

The second:
- if !netif_running, receive up to weight - 1 packets, one packets in the queue can be dropped.
---
 drivers/net/e1000/e1000_main.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 4f37506..8e53c5b 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3919,7 +3919,7 @@ e1000_clean(struct napi_struct *napi, int budget)
 {
 	struct e1000_adapter *adapter = container_of(napi, struct e1000_adapter, napi);
 	struct net_device *poll_dev = adapter->netdev;
-	int tx_cleaned = 0, work_done = 0;
+	int tx_cleaned = 0, work_done = 0, running;
 
 	/* Must NOT use netdev_priv macro here. */
 	adapter = poll_dev->priv;
@@ -3938,12 +3938,13 @@ e1000_clean(struct napi_struct *napi, int budget)
 		spin_unlock(&adapter->tx_queue_lock);
 	}
 
+	running = netif_running(poll_dev);
+
 	adapter->clean_rx(adapter, &adapter->rx_ring[0],
-	                  &work_done, budget);
+	                  &work_done, budget - !running);
 
 	/* If no Tx and not enough Rx work done, exit the polling mode */
-	if ((!tx_cleaned && (work_done == 0)) ||
-	   !netif_running(poll_dev)) {
+	if ((!tx_cleaned && (work_done == 0)) || !running) {
 quit_polling:
 		if (likely(adapter->itr_setting & 3))
 			e1000_set_itr(adapter);
---


Thanks,
Joonwoo

