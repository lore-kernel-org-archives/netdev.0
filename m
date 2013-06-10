From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH v10 net-next 6/6] ixgbe: add extra stats for
	ndo_ll_poll
Date: Mon, 10 Jun 2013 11:40:31 +0300
Message-ID: <20130610084030.6955.89381.stgit@ladj378.jer.intel.com>
References: <20130610083929.6955.87206.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Amir Vadai <amirv@mellanox.com>,
	linux-kernel@vger.kernel.org, Eliezer Tamir <eliezer@tamir.org.il>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Andi Kleen <andi@firstfloor.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <erdnetdev@gmail.com>, Eilon Greenstien <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130610083929.6955.87206.stgit@ladj378.jer.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Add additional statistics to the ixgbe driver for ndo_ll_poll
Defined under LL_EXTENDED_STATS

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   14 ++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   40 ++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |    6 +++
 3 files changed, 60 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index e9d9862..fb098b4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -54,6 +54,9 @@
 
 #include <net/ll_poll.h>
 
+#ifdef CONFIG_NET_LL_RX_POLL
+#define LL_EXTENDED_STATS
+#endif
 /* common prefix used by pr_<> macros */
 #undef pr_fmt
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
@@ -184,6 +187,11 @@ struct ixgbe_rx_buffer {
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
@@ -391,6 +399,9 @@ static inline bool ixgbe_qv_lock_napi(struct ixgbe_q_vector *q_vector)
 		WARN_ON(q_vector->state & IXGBE_QV_STATE_NAPI);
 		q_vector->state |= IXGBE_QV_STATE_NAPI_YIELD;
 		rc = false;
+#ifdef LL_EXTENDED_STATS
+		q_vector->tx.ring->stats.yields++;
+#endif
 	} else
 		/* we don't care if someone yielded */
 		q_vector->state = IXGBE_QV_STATE_NAPI;
@@ -421,6 +432,9 @@ static inline bool ixgbe_qv_lock_poll(struct ixgbe_q_vector *q_vector)
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
index d375472..24e2e7a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1054,6 +1054,12 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
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
 
@@ -1063,6 +1069,12 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
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
@@ -1070,6 +1082,12 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
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
 
@@ -1079,6 +1097,12 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
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
@@ -1115,12 +1139,28 @@ static void ixgbe_get_strings(struct net_device *netdev, u32 stringset,
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
index 9a7dc40..047ebaa 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2016,6 +2016,12 @@ static int ixgbe_low_latency_recv(struct napi_struct *napi)
 
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


------------------------------------------------------------------------------
How ServiceNow helps IT people transform IT departments:
1. A cloud service to automate IT design, transition and operations
2. Dashboards that offer high-level views of enterprise services
3. A single system of record for all IT processes
http://p.sf.net/sfu/servicenow-d2d-j
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
