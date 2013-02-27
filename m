From: Eliezer Tamir <eliezer.tamir@linux.jf.intel.com>
Subject: [RFC PATCH 4/5] ixgbe: add extra stats for ndo_ll_poll
Date: Wed, 27 Feb 2013 09:56:11 -0800
Message-ID: <20130227175611.10611.48152.stgit@gitlad.jf.intel.com>
References: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Dave Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add additional statistics to the ixgbe driver for ndo_ll_poll
Defined under LL_EXTENDED_STATS

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   14 ++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   40 ++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   13 +++++++
 3 files changed, 67 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 71e7a28..1b5cdd1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -52,6 +52,9 @@
 #include <linux/dca.h>
 #endif
 
+#ifdef CONFIG_INET_LL_RX_POLL
+#define LL_EXTENDED_STATS
+#endif  /* CONFIG_INET_LL_RX_POLL */
 /* common prefix used by pr_<> macros */
 #undef pr_fmt
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
@@ -182,6 +185,11 @@ struct ixgbe_rx_buffer {
 struct ixgbe_queue_stats {
 	u64 packets;
 	u64 bytes;
+#ifdef LL_EXTENDED_STATS
+	u64 yields;
+	u64 misses;
+	u64 cleaned;
+#endif  /* LL_EXTENDED_STATS */
 };
 
 struct ixgbe_tx_queue_stats {
@@ -389,6 +397,9 @@ static inline int ixgbe_qv_lock_napi(struct ixgbe_q_vector *q_vector)
 		WARN_ON(q_vector->state & IXGBE_QV_STATE_NAPI);
 		q_vector->state |= IXGBE_QV_STATE_NAPI_YIELD;
 		rc = false;
+#ifdef LL_EXTENDED_STATS
+		q_vector->tx.ring->stats.yields++;
+#endif
 	} else
 		/* we don't care if someone yielded */
 		q_vector->state = IXGBE_QV_STATE_NAPI;
@@ -419,6 +430,9 @@ static inline int ixgbe_qv_lock_poll(struct ixgbe_q_vector *q_vector)
 	if ((q_vector->state & IXGBE_QV_LOCKED)) {
 		q_vector->state |= IXGBE_QV_STATE_POLL_YIELD;
 		rc = false;
+#ifdef LL_EXTENDED_STATS
+		q_vector->rx.ring->stats.yields++;
+#endif
 	} else
 		/* preserve yield marks */
 		q_vector->state |= IXGBE_QV_STATE_POLL;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index f4d2e9e..de513b3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1055,6 +1055,12 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
 			data[i] = 0;
 			data[i+1] = 0;
 			i += 2;
+#ifdef LL_EXTENDED_STATS
+			data[i] = 0;
+			data[i+1] = 0;
+			data[i+2] = 0;
+			i += 3;
+#endif
 			continue;
 		}
 
@@ -1064,6 +1070,12 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
 			data[i+1] = ring->stats.bytes;
 		} while (u64_stats_fetch_retry_bh(&ring->syncp, start));
 		i += 2;
+#ifdef LL_EXTENDED_STATS
+		data[i] = ring->stats.yields;
+		data[i+1] = ring->stats.misses;
+		data[i+2] = ring->stats.cleaned;
+		i += 3;
+#endif
 	}
 	for (j = 0; j < IXGBE_NUM_RX_QUEUES; j++) {
 		ring = adapter->rx_ring[j];
@@ -1071,6 +1083,12 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
 			data[i] = 0;
 			data[i+1] = 0;
 			i += 2;
+#ifdef LL_EXTENDED_STATS
+			data[i] = 0;
+			data[i+1] = 0;
+			data[i+2] = 0;
+			i += 3;
+#endif
 			continue;
 		}
 
@@ -1080,6 +1098,12 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
 			data[i+1] = ring->stats.bytes;
 		} while (u64_stats_fetch_retry_bh(&ring->syncp, start));
 		i += 2;
+#ifdef LL_EXTENDED_STATS
+		data[i] = ring->stats.yields;
+		data[i+1] = ring->stats.misses;
+		data[i+2] = ring->stats.cleaned;
+		i += 3;
+#endif
 	}
 
 	for (j = 0; j < IXGBE_MAX_PACKET_BUFFERS; j++) {
@@ -1116,12 +1140,28 @@ static void ixgbe_get_strings(struct net_device *netdev, u32 stringset,
 			p += ETH_GSTRING_LEN;
 			sprintf(p, "tx_queue_%u_bytes", i);
 			p += ETH_GSTRING_LEN;
+#ifdef LL_EXTENDED_STATS
+			sprintf(p, "tx_q_%u_napi_yield", i);
+			p += ETH_GSTRING_LEN;
+			sprintf(p, "tx_q_%u_misses", i);
+			p += ETH_GSTRING_LEN;
+			sprintf(p, "tx_q_%u_cleaned", i);
+			p += ETH_GSTRING_LEN;
+#endif /* LL_EXTENDED_STATS */
 		}
 		for (i = 0; i < IXGBE_NUM_RX_QUEUES; i++) {
 			sprintf(p, "rx_queue_%u_packets", i);
 			p += ETH_GSTRING_LEN;
 			sprintf(p, "rx_queue_%u_bytes", i);
 			p += ETH_GSTRING_LEN;
+#ifdef LL_EXTENDED_STATS
+			sprintf(p, "rx_q_%u_ll_poll_yield", i);
+			p += ETH_GSTRING_LEN;
+			sprintf(p, "rx_q_%u_misses", i);
+			p += ETH_GSTRING_LEN;
+			sprintf(p, "rx_q_%u_cleaned", i);
+			p += ETH_GSTRING_LEN;
+#endif /* LL_EXTENDED_STATS */
 		}
 		for (i = 0; i < IXGBE_MAX_PACKET_BUFFERS; i++) {
 			sprintf(p, "tx_pb_%u_pxon", i);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 903bbc0..5248c63 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1971,6 +1971,12 @@ static int ixgbe_low_latency_recv(struct napi_struct *napi)
 
 	ixgbe_for_each_ring(ring, q_vector->rx) {
 		found = ixgbe_clean_rx_irq(q_vector, ring, 4);
+#ifdef LL_EXTENDED_STATS
+		if (found)
+			ring->stats.cleaned += found;
+		else
+			ring->stats.misses++;
+#endif
 		if (found)
 			break;
 	}
@@ -2523,6 +2529,13 @@ int ixgbe_poll(struct napi_struct *napi, int budget)
 	ixgbe_for_each_ring(ring, q_vector->tx)
 		clean_complete &= !!ixgbe_clean_tx_irq(q_vector, ring);
 
+#ifdef LL_EXTENDED_STATS
+	if (clean_complete)
+		q_vector->tx.ring->stats.cleaned++;
+	else
+		q_vector->tx.ring->stats.misses++;
+#endif
+
 	if (!ixgbe_qv_lock_napi(q_vector))
 		return budget;
 
