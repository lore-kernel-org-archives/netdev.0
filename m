From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 11/18] e1000: add queue restart counter
Date: Wed, 01 Nov 2006 09:51:54 -0800
Message-ID: <20061101175153.2356.11454.stgit@gitlost.site>
References: <20061101175043.2356.13659.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:20240 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1946974AbWKARom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 12:44:42 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061101175043.2356.13659.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Add a netif_wake/start_queue counter to the ethtool statistics to indicated
to the user that their transmit ring could be too small for their workload.

Signed-off-by: Jesse brandeburg <jesse.brandeburg@intel.com>
Cc: Jamal Hadi <hadi@cyberus.ca>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000.h         |    1 +
 drivers/net/e1000/e1000_ethtool.c |    1 +
 drivers/net/e1000/e1000_main.c    |    5 ++++-
 3 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 3f0be02..896ea8a 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -265,6 +265,7 @@ struct e1000_adapter {
 
 	/* TX */
 	struct e1000_tx_ring *tx_ring;      /* One per active queue */
+	unsigned int restart_queue;
 	unsigned long tx_queue_len;
 	uint32_t txd_cmd;
 	uint32_t tx_int_delay;
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index dbac71b..da459f7 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -85,6 +85,7 @@ static const struct e1000_stats e1000_gs
 	{ "tx_single_coll_ok", E1000_STAT(stats.scc) },
 	{ "tx_multi_coll_ok", E1000_STAT(stats.mcc) },
 	{ "tx_timeout_count", E1000_STAT(tx_timeout_count) },
+	{ "tx_restart_queue", E1000_STAT(restart_queue) },
 	{ "rx_long_length_errors", E1000_STAT(stats.roc) },
 	{ "rx_short_length_errors", E1000_STAT(stats.ruc) },
 	{ "rx_align_errors", E1000_STAT(stats.algnerrc) },
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index f078f6b..99dd6b9 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2974,6 +2974,7 @@ static int __e1000_maybe_stop_tx(struct 
 
 	/* A reprieve! */
 	netif_start_queue(netdev);
+	++adapter->restart_queue;
 	return 0;
 }
 
@@ -3654,8 +3655,10 @@ e1000_clean_tx_irq(struct e1000_adapter 
 		 * sees the new next_to_clean.
 		 */
 		smp_mb();
-		if (netif_queue_stopped(netdev))
+		if (netif_queue_stopped(netdev)) {
 			netif_wake_queue(netdev);
+			++adapter->restart_queue;
+		}
 	}
 
 	if (adapter->detect_tx_hung) {



---
Auke Kok <auke-jan.h.kok@intel.com>
