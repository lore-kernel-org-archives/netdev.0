From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/4] i40e: Add and use pf_<level>
Date: Fri, 30 Aug 2013 16:06:08 -0700
Message-ID: <e0160b137c7c8697ec828c0b58dd8bfc39e3239b.1377903831.git.joe@perches.com>
References: <cover.1377903831.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org,
	John Ronciak <john.ronciak@intel.com>, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1377903831.git.joe@perches.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Convert dev_<level>(&pf->pdev->dev to a macro to
simplify and possibly reduce the size of logging messages.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h             |    9 +
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     | 1510 +++++++++-----------
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |   40 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  585 ++++----
 drivers/net/ethernet/intel/i40e/i40e_sysfs.c       |   13 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  215 ++-
 6 files changed, 998 insertions(+), 1374 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 6de5e63..f1fe336 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -563,4 +563,13 @@ struct i40e_mac_filter *i40e_find_mac(struct i40e_vsi *vsi, u8 *macaddr,
 				      bool is_vf, bool is_netdev);
 void i40e_vlan_stripping_enable(struct i40e_vsi *vsi);
 
+/* i40e_pf message logging */
+
+#define pf_err(pf, fmt, ...)						\
+	dev_err(&(pf)->pdev->dev, fmt, ##__VA_ARGS__)
+#define pf_warn(pf, fmt, ...)						\
+	dev_warn(&(pf)->pdev->dev, fmt, ##__VA_ARGS__)
+#define pf_info(pf, fmt, ...)						\
+	dev_info(&(pf)->pdev->dev, fmt, ##__VA_ARGS__)
+
 #endif /* _I40E_H_ */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index e61ed67..d8b1963 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -45,7 +45,7 @@ static struct i40e_vsi *i40e_dbg_find_vsi(struct i40e_pf *pf, int seid)
 	int i;
 
 	if (seid < 0)
-		dev_info(&pf->pdev->dev, "%s: %d: bad seid\n", __func__, seid);
+		pf_info(pf, "%s: %d: bad seid\n", __func__, seid);
 	else
 		for (i = 0; i < pf->hw.func_caps.num_vsis; i++)
 			if (pf->vsi[i] && (pf->vsi[i]->seid == seid))
@@ -65,7 +65,7 @@ static struct i40e_veb *i40e_dbg_find_veb(struct i40e_pf *pf, int seid)
 
 	if ((seid < I40E_BASE_VEB_SEID) ||
 	    (seid > (I40E_BASE_VEB_SEID + I40E_MAX_VEB)))
-		dev_info(&pf->pdev->dev, "%s: %d: bad seid\n", __func__, seid);
+		pf_info(pf, "%s: %d: bad seid\n", __func__, seid);
 	else
 		for (i = 0; i < I40E_MAX_VEB; i++)
 			if (pf->veb[i] && pf->veb[i]->seid == seid)
@@ -133,9 +133,8 @@ static int i40e_dbg_prep_dump_buf(struct i40e_pf *pf, int buflen)
 		i40e_dbg_dump_buf = kzalloc(buflen, GFP_KERNEL);
 		if (i40e_dbg_dump_buf != NULL) {
 			i40e_dbg_dump_buffer_len = buflen;
-			dev_info(&pf->pdev->dev,
-				 "%s: i40e_dbg_dump_buffer_len = %d\n",
-				 __func__, (int)i40e_dbg_dump_buffer_len);
+			pf_info(pf, "%s: i40e_dbg_dump_buffer_len = %d\n",
+				__func__, (int)i40e_dbg_dump_buffer_len);
 		}
 	}
 
@@ -181,8 +180,8 @@ static ssize_t i40e_dbg_dump_write(struct file *filp,
 	/* decode the SEID given to be dumped */
 	ret = kstrtol(dump_request_buf, 0, &seid);
 	if (ret < 0) {
-		dev_info(&pf->pdev->dev, "%s: bad seid value '%s'\n",
-			 __func__, dump_request_buf);
+		pf_info(pf, "%s: bad seid value '%s'\n",
+			__func__, dump_request_buf);
 	} else if (seid == 0) {
 		seid_found = true;
 
@@ -190,7 +189,7 @@ static ssize_t i40e_dbg_dump_write(struct file *filp,
 		i40e_dbg_dump_buffer_len = 0;
 		i40e_dbg_dump_data_len = 0;
 		i40e_dbg_dump_buf = NULL;
-		dev_info(&pf->pdev->dev, "%s: debug buffer freed\n", __func__);
+		pf_info(pf, "%s: debug buffer freed\n", __func__);
 
 	} else if (seid == pf->pf_seid || seid == 1) {
 		seid_found = true;
@@ -217,9 +216,8 @@ static ssize_t i40e_dbg_dump_write(struct file *filp,
 			p += len;
 
 			i40e_dbg_dump_data_len = buflen;
-			dev_info(&pf->pdev->dev,
-				 "%s: PF seid %ld dumped %d bytes\n",
-				 __func__, seid, (int)i40e_dbg_dump_data_len);
+			pf_info(pf, "%s: PF seid %ld dumped %d bytes\n",
+				__func__, seid, (int)i40e_dbg_dump_data_len);
 		}
 	} else if (seid >= I40E_BASE_VSI_SEID) {
 		struct i40e_vsi *vsi = NULL;
@@ -280,9 +278,8 @@ static ssize_t i40e_dbg_dump_write(struct file *filp,
 			}
 
 			i40e_dbg_dump_data_len = buflen;
-			dev_info(&pf->pdev->dev,
-				 "%s: VSI seid %ld dumped %d bytes\n",
-				 __func__, seid, (int)i40e_dbg_dump_data_len);
+			pf_info(pf, "%s: VSI seid %ld dumped %d bytes\n",
+				__func__, seid, (int)i40e_dbg_dump_data_len);
 		}
 		mutex_unlock(&pf->switch_mutex);
 	} else if (seid >= I40E_BASE_VEB_SEID) {
@@ -300,17 +297,15 @@ static ssize_t i40e_dbg_dump_write(struct file *filp,
 			seid_found = true;
 			memcpy(i40e_dbg_dump_buf, veb, buflen);
 			i40e_dbg_dump_data_len = buflen;
-			dev_info(&pf->pdev->dev,
-				 "%s: VEB seid %ld dumped %d bytes\n",
-				 __func__, seid, (int)i40e_dbg_dump_data_len);
+			pf_info(pf, "%s: VEB seid %ld dumped %d bytes\n",
+				__func__, seid, (int)i40e_dbg_dump_data_len);
 		}
 		mutex_unlock(&pf->switch_mutex);
 	}
 
 write_exit:
 	if (!seid_found)
-		dev_info(&pf->pdev->dev, "%s: unknown seid %ld\n",
-			 __func__, seid);
+		pf_info(pf, "%s: unknown seid %ld\n", __func__, seid);
 
 	return count;
 }
@@ -385,336 +380,262 @@ static void i40e_dbg_dump_vsi_seid(struct i40e_pf *pf, int seid)
 
 	vsi = i40e_dbg_find_vsi(pf, seid);
 	if (!vsi) {
-		dev_info(&pf->pdev->dev,
-			 "%s: dump %d: seid not found\n", __func__, seid);
+		pf_info(pf, "%s: dump %d: seid not found\n", __func__, seid);
 		return;
 	}
-	dev_info(&pf->pdev->dev,
-		 "%s: vsi seid %d\n", __func__, seid);
+	pf_info(pf, "%s: vsi seid %d\n", __func__, seid);
 	if (vsi->netdev)
-		dev_info(&pf->pdev->dev,
-			 "    netdev: name = %s\n",
-			vsi->netdev->name);
+		pf_info(pf, "    netdev: name = %s\n", vsi->netdev->name);
 	if (vsi->active_vlans)
-		dev_info(&pf->pdev->dev,
-			 "    vlgrp: & = %p\n", vsi->active_vlans);
-	dev_info(&pf->pdev->dev,
-		 "    netdev_registered = %i, current_netdev_flags = 0x%04x, state = %li flags = 0x%08lx\n",
-		 vsi->netdev_registered,
-		 vsi->current_netdev_flags, vsi->state, vsi->flags);
+		pf_info(pf, "    vlgrp: & = %p\n", vsi->active_vlans);
+	pf_info(pf, "    netdev_registered = %i, current_netdev_flags = 0x%04x, state = %li flags = 0x%08lx\n",
+		vsi->netdev_registered,
+		vsi->current_netdev_flags, vsi->state, vsi->flags);
 	list_for_each_entry(f, &vsi->mac_filter_list, list) {
-		dev_info(&pf->pdev->dev,
-			 "    mac_filter_list: %pM vid=%d, is_netdev=%d is_vf=%d counter=%d\n",
-			 f->macaddr, f->vlan, f->is_netdev, f->is_vf,
-			 f->counter);
+		pf_info(pf, "    mac_filter_list: %pM vid=%d, is_netdev=%d is_vf=%d counter=%d\n",
+			f->macaddr, f->vlan, f->is_netdev, f->is_vf,
+			f->counter);
 	}
 	nstat = i40e_get_vsi_stats_struct(vsi);
-	dev_info(&pf->pdev->dev,
-		 "    net_stats: rx_packets = %lu, rx_bytes = %lu, rx_errors = %lu, rx_dropped = %lu\n",
-		 (long unsigned int)nstat->rx_packets,
-		 (long unsigned int)nstat->rx_bytes,
-		 (long unsigned int)nstat->rx_errors,
-		 (long unsigned int)nstat->rx_dropped);
-	dev_info(&pf->pdev->dev,
-		 "    net_stats: tx_packets = %lu, tx_bytes = %lu, tx_errors = %lu, tx_dropped = %lu\n",
-		 (long unsigned int)nstat->tx_packets,
-		 (long unsigned int)nstat->tx_bytes,
-		 (long unsigned int)nstat->tx_errors,
-		 (long unsigned int)nstat->tx_dropped);
-	dev_info(&pf->pdev->dev,
-		 "    net_stats: multicast = %lu, collisions = %lu\n",
-		 (long unsigned int)nstat->multicast,
-		 (long unsigned int)nstat->collisions);
-	dev_info(&pf->pdev->dev,
-		 "    net_stats: rx_length_errors = %lu, rx_over_errors = %lu, rx_crc_errors = %lu\n",
-		 (long unsigned int)nstat->rx_length_errors,
-		 (long unsigned int)nstat->rx_over_errors,
-		 (long unsigned int)nstat->rx_crc_errors);
-	dev_info(&pf->pdev->dev,
-		 "    net_stats: rx_frame_errors = %lu, rx_fifo_errors = %lu, rx_missed_errors = %lu\n",
-		 (long unsigned int)nstat->rx_frame_errors,
-		 (long unsigned int)nstat->rx_fifo_errors,
-		 (long unsigned int)nstat->rx_missed_errors);
-	dev_info(&pf->pdev->dev,
-		 "    net_stats: tx_aborted_errors = %lu, tx_carrier_errors = %lu, tx_fifo_errors = %lu\n",
-		 (long unsigned int)nstat->tx_aborted_errors,
-		 (long unsigned int)nstat->tx_carrier_errors,
-		 (long unsigned int)nstat->tx_fifo_errors);
-	dev_info(&pf->pdev->dev,
-		 "    net_stats: tx_heartbeat_errors = %lu, tx_window_errors = %lu\n",
-		 (long unsigned int)nstat->tx_heartbeat_errors,
-		 (long unsigned int)nstat->tx_window_errors);
-	dev_info(&pf->pdev->dev,
-		 "    net_stats: rx_compressed = %lu, tx_compressed = %lu\n",
-		 (long unsigned int)nstat->rx_compressed,
-		 (long unsigned int)nstat->tx_compressed);
-	dev_info(&pf->pdev->dev,
-		 "    net_stats_offsets: rx_packets = %lu, rx_bytes = %lu, rx_errors = %lu, rx_dropped = %lu\n",
-		 (long unsigned int)vsi->net_stats_offsets.rx_packets,
-		 (long unsigned int)vsi->net_stats_offsets.rx_bytes,
-		 (long unsigned int)vsi->net_stats_offsets.rx_errors,
-		 (long unsigned int)vsi->net_stats_offsets.rx_dropped);
-	dev_info(&pf->pdev->dev,
-		 "    net_stats_offsets: tx_packets = %lu, tx_bytes = %lu, tx_errors = %lu, tx_dropped = %lu\n",
-		 (long unsigned int)vsi->net_stats_offsets.tx_packets,
-		 (long unsigned int)vsi->net_stats_offsets.tx_bytes,
-		 (long unsigned int)vsi->net_stats_offsets.tx_errors,
-		 (long unsigned int)vsi->net_stats_offsets.tx_dropped);
-	dev_info(&pf->pdev->dev,
-		 "    net_stats_offsets: multicast = %lu, collisions = %lu\n",
-		 (long unsigned int)vsi->net_stats_offsets.multicast,
-		 (long unsigned int)vsi->net_stats_offsets.collisions);
-	dev_info(&pf->pdev->dev,
-		 "    net_stats_offsets: rx_length_errors = %lu, rx_over_errors = %lu, rx_crc_errors = %lu\n",
-		 (long unsigned int)vsi->net_stats_offsets.rx_length_errors,
-		 (long unsigned int)vsi->net_stats_offsets.rx_over_errors,
-		 (long unsigned int)vsi->net_stats_offsets.rx_crc_errors);
-	dev_info(&pf->pdev->dev,
-		 "    net_stats_offsets: rx_frame_errors = %lu, rx_fifo_errors = %lu, rx_missed_errors = %lu\n",
-		 (long unsigned int)vsi->net_stats_offsets.rx_frame_errors,
-		 (long unsigned int)vsi->net_stats_offsets.rx_fifo_errors,
-		 (long unsigned int)vsi->net_stats_offsets.rx_missed_errors);
-	dev_info(&pf->pdev->dev,
-		 "    net_stats_offsets: tx_aborted_errors = %lu, tx_carrier_errors = %lu, tx_fifo_errors = %lu\n",
-		 (long unsigned int)vsi->net_stats_offsets.tx_aborted_errors,
-		 (long unsigned int)vsi->net_stats_offsets.tx_carrier_errors,
-		 (long unsigned int)vsi->net_stats_offsets.tx_fifo_errors);
-	dev_info(&pf->pdev->dev,
-		 "    net_stats_offsets: tx_heartbeat_errors = %lu, tx_window_errors = %lu\n",
-		 (long unsigned int)vsi->net_stats_offsets.tx_heartbeat_errors,
-		 (long unsigned int)vsi->net_stats_offsets.tx_window_errors);
-	dev_info(&pf->pdev->dev,
-		 "    net_stats_offsets: rx_compressed = %lu, tx_compressed = %lu\n",
-		 (long unsigned int)vsi->net_stats_offsets.rx_compressed,
-		 (long unsigned int)vsi->net_stats_offsets.tx_compressed);
-	dev_info(&pf->pdev->dev,
-		 "    tx_restart = %d, tx_busy = %d, rx_buf_failed = %d, rx_page_failed = %d\n",
-		 vsi->tx_restart, vsi->tx_busy,
-		 vsi->rx_buf_failed, vsi->rx_page_failed);
+	pf_info(pf, "    net_stats: rx_packets = %lu, rx_bytes = %lu, rx_errors = %lu, rx_dropped = %lu\n",
+		(long unsigned int)nstat->rx_packets,
+		(long unsigned int)nstat->rx_bytes,
+		(long unsigned int)nstat->rx_errors,
+		(long unsigned int)nstat->rx_dropped);
+	pf_info(pf, "    net_stats: tx_packets = %lu, tx_bytes = %lu, tx_errors = %lu, tx_dropped = %lu\n",
+		(long unsigned int)nstat->tx_packets,
+		(long unsigned int)nstat->tx_bytes,
+		(long unsigned int)nstat->tx_errors,
+		(long unsigned int)nstat->tx_dropped);
+	pf_info(pf, "    net_stats: multicast = %lu, collisions = %lu\n",
+		(long unsigned int)nstat->multicast,
+		(long unsigned int)nstat->collisions);
+	pf_info(pf, "    net_stats: rx_length_errors = %lu, rx_over_errors = %lu, rx_crc_errors = %lu\n",
+		(long unsigned int)nstat->rx_length_errors,
+		(long unsigned int)nstat->rx_over_errors,
+		(long unsigned int)nstat->rx_crc_errors);
+	pf_info(pf, "    net_stats: rx_frame_errors = %lu, rx_fifo_errors = %lu, rx_missed_errors = %lu\n",
+		(long unsigned int)nstat->rx_frame_errors,
+		(long unsigned int)nstat->rx_fifo_errors,
+		(long unsigned int)nstat->rx_missed_errors);
+	pf_info(pf, "    net_stats: tx_aborted_errors = %lu, tx_carrier_errors = %lu, tx_fifo_errors = %lu\n",
+		(long unsigned int)nstat->tx_aborted_errors,
+		(long unsigned int)nstat->tx_carrier_errors,
+		(long unsigned int)nstat->tx_fifo_errors);
+	pf_info(pf, "    net_stats: tx_heartbeat_errors = %lu, tx_window_errors = %lu\n",
+		(long unsigned int)nstat->tx_heartbeat_errors,
+		(long unsigned int)nstat->tx_window_errors);
+	pf_info(pf, "    net_stats: rx_compressed = %lu, tx_compressed = %lu\n",
+		(long unsigned int)nstat->rx_compressed,
+		(long unsigned int)nstat->tx_compressed);
+	pf_info(pf, "    net_stats_offsets: rx_packets = %lu, rx_bytes = %lu, rx_errors = %lu, rx_dropped = %lu\n",
+		(long unsigned int)vsi->net_stats_offsets.rx_packets,
+		(long unsigned int)vsi->net_stats_offsets.rx_bytes,
+		(long unsigned int)vsi->net_stats_offsets.rx_errors,
+		(long unsigned int)vsi->net_stats_offsets.rx_dropped);
+	pf_info(pf, "    net_stats_offsets: tx_packets = %lu, tx_bytes = %lu, tx_errors = %lu, tx_dropped = %lu\n",
+		(long unsigned int)vsi->net_stats_offsets.tx_packets,
+		(long unsigned int)vsi->net_stats_offsets.tx_bytes,
+		(long unsigned int)vsi->net_stats_offsets.tx_errors,
+		(long unsigned int)vsi->net_stats_offsets.tx_dropped);
+	pf_info(pf, "    net_stats_offsets: multicast = %lu, collisions = %lu\n",
+		(long unsigned int)vsi->net_stats_offsets.multicast,
+		(long unsigned int)vsi->net_stats_offsets.collisions);
+	pf_info(pf, "    net_stats_offsets: rx_length_errors = %lu, rx_over_errors = %lu, rx_crc_errors = %lu\n",
+		(long unsigned int)vsi->net_stats_offsets.rx_length_errors,
+		(long unsigned int)vsi->net_stats_offsets.rx_over_errors,
+		(long unsigned int)vsi->net_stats_offsets.rx_crc_errors);
+	pf_info(pf, "    net_stats_offsets: rx_frame_errors = %lu, rx_fifo_errors = %lu, rx_missed_errors = %lu\n",
+		(long unsigned int)vsi->net_stats_offsets.rx_frame_errors,
+		(long unsigned int)vsi->net_stats_offsets.rx_fifo_errors,
+		(long unsigned int)vsi->net_stats_offsets.rx_missed_errors);
+	pf_info(pf, "    net_stats_offsets: tx_aborted_errors = %lu, tx_carrier_errors = %lu, tx_fifo_errors = %lu\n",
+		(long unsigned int)vsi->net_stats_offsets.tx_aborted_errors,
+		(long unsigned int)vsi->net_stats_offsets.tx_carrier_errors,
+		(long unsigned int)vsi->net_stats_offsets.tx_fifo_errors);
+	pf_info(pf, "    net_stats_offsets: tx_heartbeat_errors = %lu, tx_window_errors = %lu\n",
+		(long unsigned int)vsi->net_stats_offsets.tx_heartbeat_errors,
+		(long unsigned int)vsi->net_stats_offsets.tx_window_errors);
+	pf_info(pf, "    net_stats_offsets: rx_compressed = %lu, tx_compressed = %lu\n",
+		(long unsigned int)vsi->net_stats_offsets.rx_compressed,
+		(long unsigned int)vsi->net_stats_offsets.tx_compressed);
+	pf_info(pf, "    tx_restart = %d, tx_busy = %d, rx_buf_failed = %d, rx_page_failed = %d\n",
+		vsi->tx_restart, vsi->tx_busy,
+		vsi->rx_buf_failed, vsi->rx_page_failed);
 	if (vsi->rx_rings) {
 		for (i = 0; i < vsi->num_queue_pairs; i++) {
-			dev_info(&pf->pdev->dev,
-				 "    rx_rings[%i]: desc = %p\n",
-				 i, vsi->rx_rings[i].desc);
-			dev_info(&pf->pdev->dev,
-				 "    rx_rings[%i]: dev = %p, netdev = %p, rx_bi = %p\n",
-				 i, vsi->rx_rings[i].dev,
-				 vsi->rx_rings[i].netdev,
-				 vsi->rx_rings[i].rx_bi);
-			dev_info(&pf->pdev->dev,
-				 "    rx_rings[%i]: state = %li, queue_index = %d, reg_idx = %d\n",
-				 i, vsi->rx_rings[i].state,
-				 vsi->rx_rings[i].queue_index,
-				 vsi->rx_rings[i].reg_idx);
-			dev_info(&pf->pdev->dev,
-				 "    rx_rings[%i]: rx_hdr_len = %d, rx_buf_len = %d, dtype = %d\n",
-				 i, vsi->rx_rings[i].rx_hdr_len,
-				 vsi->rx_rings[i].rx_buf_len,
-				 vsi->rx_rings[i].dtype);
-			dev_info(&pf->pdev->dev,
-				 "    rx_rings[%i]: hsplit = %d, next_to_use = %d, next_to_clean = %d, ring_active = %i\n",
-				 i, vsi->rx_rings[i].hsplit,
-				 vsi->rx_rings[i].next_to_use,
-				 vsi->rx_rings[i].next_to_clean,
-				 vsi->rx_rings[i].ring_active);
-			dev_info(&pf->pdev->dev,
-				 "    rx_rings[%i]: rx_stats: packets = %lld, bytes = %lld, non_eop_descs = %lld\n",
-				 i, vsi->rx_rings[i].rx_stats.packets,
-				 vsi->rx_rings[i].rx_stats.bytes,
-				 vsi->rx_rings[i].rx_stats.non_eop_descs);
-			dev_info(&pf->pdev->dev,
-				 "    rx_rings[%i]: rx_stats: alloc_rx_page_failed = %lld, alloc_rx_buff_failed = %lld\n",
-				 i,
-				 vsi->rx_rings[i].rx_stats.alloc_rx_page_failed,
-				 vsi->rx_rings[i].rx_stats.alloc_rx_buff_failed);
-			dev_info(&pf->pdev->dev,
-				 "    rx_rings[%i]: size = %i, dma = 0x%08lx\n",
-				 i, vsi->rx_rings[i].size,
-				 (long unsigned int)vsi->rx_rings[i].dma);
-			dev_info(&pf->pdev->dev,
-				 "    rx_rings[%i]: vsi = %p, q_vector = %p\n",
-				 i, vsi->rx_rings[i].vsi,
-				 vsi->rx_rings[i].q_vector);
+			pf_info(pf, "    rx_rings[%i]: desc = %p\n",
+				i, vsi->rx_rings[i].desc);
+			pf_info(pf, "    rx_rings[%i]: dev = %p, netdev = %p, rx_bi = %p\n",
+				i, vsi->rx_rings[i].dev,
+				vsi->rx_rings[i].netdev,
+				vsi->rx_rings[i].rx_bi);
+			pf_info(pf, "    rx_rings[%i]: state = %li, queue_index = %d, reg_idx = %d\n",
+				i, vsi->rx_rings[i].state,
+				vsi->rx_rings[i].queue_index,
+				vsi->rx_rings[i].reg_idx);
+			pf_info(pf, "    rx_rings[%i]: rx_hdr_len = %d, rx_buf_len = %d, dtype = %d\n",
+				i, vsi->rx_rings[i].rx_hdr_len,
+				vsi->rx_rings[i].rx_buf_len,
+				vsi->rx_rings[i].dtype);
+			pf_info(pf, "    rx_rings[%i]: hsplit = %d, next_to_use = %d, next_to_clean = %d, ring_active = %i\n",
+				i, vsi->rx_rings[i].hsplit,
+				vsi->rx_rings[i].next_to_use,
+				vsi->rx_rings[i].next_to_clean,
+				vsi->rx_rings[i].ring_active);
+			pf_info(pf, "    rx_rings[%i]: rx_stats: packets = %lld, bytes = %lld, non_eop_descs = %lld\n",
+				i, vsi->rx_rings[i].rx_stats.packets,
+				vsi->rx_rings[i].rx_stats.bytes,
+				vsi->rx_rings[i].rx_stats.non_eop_descs);
+			pf_info(pf, "    rx_rings[%i]: rx_stats: alloc_rx_page_failed = %lld, alloc_rx_buff_failed = %lld\n",
+				i,
+				vsi->rx_rings[i].rx_stats.alloc_rx_page_failed,
+				vsi->rx_rings[i].rx_stats.alloc_rx_buff_failed);
+			pf_info(pf, "    rx_rings[%i]: size = %i, dma = 0x%08lx\n",
+				i, vsi->rx_rings[i].size,
+				(long unsigned int)vsi->rx_rings[i].dma);
+			pf_info(pf, "    rx_rings[%i]: vsi = %p, q_vector = %p\n",
+				i, vsi->rx_rings[i].vsi,
+				vsi->rx_rings[i].q_vector);
 		}
 	}
 	if (vsi->tx_rings) {
 		for (i = 0; i < vsi->num_queue_pairs; i++) {
-			dev_info(&pf->pdev->dev,
-				 "    tx_rings[%i]: desc = %p\n",
-				 i, vsi->tx_rings[i].desc);
-			dev_info(&pf->pdev->dev,
-				 "    tx_rings[%i]: dev = %p, netdev = %p, tx_bi = %p\n",
-				 i, vsi->tx_rings[i].dev,
-				 vsi->tx_rings[i].netdev,
-				 vsi->tx_rings[i].tx_bi);
-			dev_info(&pf->pdev->dev,
-				 "    tx_rings[%i]: state = %li, queue_index = %d, reg_idx = %d\n",
-				 i, vsi->tx_rings[i].state,
-				 vsi->tx_rings[i].queue_index,
-				 vsi->tx_rings[i].reg_idx);
-			dev_info(&pf->pdev->dev,
-				 "    tx_rings[%i]: dtype = %d\n",
-				 i, vsi->tx_rings[i].dtype);
-			dev_info(&pf->pdev->dev,
-				 "    tx_rings[%i]: hsplit = %d, next_to_use = %d, next_to_clean = %d, ring_active = %i\n",
-				 i, vsi->tx_rings[i].hsplit,
-				 vsi->tx_rings[i].next_to_use,
-				 vsi->tx_rings[i].next_to_clean,
-				 vsi->tx_rings[i].ring_active);
-			dev_info(&pf->pdev->dev,
-				 "    tx_rings[%i]: tx_stats: packets = %lld, bytes = %lld, restart_queue = %lld\n",
-				 i, vsi->tx_rings[i].tx_stats.packets,
-				 vsi->tx_rings[i].tx_stats.bytes,
-				 vsi->tx_rings[i].tx_stats.restart_queue);
-			dev_info(&pf->pdev->dev,
-				 "    tx_rings[%i]: tx_stats: tx_busy = %lld, completed = %lld, tx_done_old = %lld\n",
-				 i,
-				 vsi->tx_rings[i].tx_stats.tx_busy,
-				 vsi->tx_rings[i].tx_stats.completed,
-				 vsi->tx_rings[i].tx_stats.tx_done_old);
-			dev_info(&pf->pdev->dev,
-				 "    tx_rings[%i]: size = %i, dma = 0x%08lx\n",
-				 i, vsi->tx_rings[i].size,
-				 (long unsigned int)vsi->tx_rings[i].dma);
-			dev_info(&pf->pdev->dev,
-				 "    tx_rings[%i]: vsi = %p, q_vector = %p\n",
-				 i, vsi->tx_rings[i].vsi,
-				 vsi->tx_rings[i].q_vector);
-			dev_info(&pf->pdev->dev,
-				 "    tx_rings[%i]: DCB tc = %d\n",
-				 i, vsi->tx_rings[i].dcb_tc);
+			pf_info(pf, "    tx_rings[%i]: desc = %p\n",
+				i, vsi->tx_rings[i].desc);
+			pf_info(pf, "    tx_rings[%i]: dev = %p, netdev = %p, tx_bi = %p\n",
+				i, vsi->tx_rings[i].dev,
+				vsi->tx_rings[i].netdev,
+				vsi->tx_rings[i].tx_bi);
+			pf_info(pf, "    tx_rings[%i]: state = %li, queue_index = %d, reg_idx = %d\n",
+				i, vsi->tx_rings[i].state,
+				vsi->tx_rings[i].queue_index,
+				vsi->tx_rings[i].reg_idx);
+			pf_info(pf, "    tx_rings[%i]: dtype = %d\n",
+				i, vsi->tx_rings[i].dtype);
+			pf_info(pf, "    tx_rings[%i]: hsplit = %d, next_to_use = %d, next_to_clean = %d, ring_active = %i\n",
+				i, vsi->tx_rings[i].hsplit,
+				vsi->tx_rings[i].next_to_use,
+				vsi->tx_rings[i].next_to_clean,
+				vsi->tx_rings[i].ring_active);
+			pf_info(pf, "    tx_rings[%i]: tx_stats: packets = %lld, bytes = %lld, restart_queue = %lld\n",
+				i, vsi->tx_rings[i].tx_stats.packets,
+				vsi->tx_rings[i].tx_stats.bytes,
+				vsi->tx_rings[i].tx_stats.restart_queue);
+			pf_info(pf, "    tx_rings[%i]: tx_stats: tx_busy = %lld, completed = %lld, tx_done_old = %lld\n",
+				i,
+				vsi->tx_rings[i].tx_stats.tx_busy,
+				vsi->tx_rings[i].tx_stats.completed,
+				vsi->tx_rings[i].tx_stats.tx_done_old);
+			pf_info(pf, "    tx_rings[%i]: size = %i, dma = 0x%08lx\n",
+				i, vsi->tx_rings[i].size,
+				(long unsigned int)vsi->tx_rings[i].dma);
+			pf_info(pf, "    tx_rings[%i]: vsi = %p, q_vector = %p\n",
+				i, vsi->tx_rings[i].vsi,
+				vsi->tx_rings[i].q_vector);
+			pf_info(pf, "    tx_rings[%i]: DCB tc = %d\n",
+				i, vsi->tx_rings[i].dcb_tc);
 		}
 	}
-	dev_info(&pf->pdev->dev,
-		 "    work_limit = %d, rx_itr_setting = %d (%s), tx_itr_setting = %d (%s)\n",
-		 vsi->work_limit, vsi->rx_itr_setting,
-		 ITR_IS_DYNAMIC(vsi->rx_itr_setting) ? "dynamic" : "fixed",
-		 vsi->tx_itr_setting,
-		 ITR_IS_DYNAMIC(vsi->tx_itr_setting) ? "dynamic" : "fixed");
-	dev_info(&pf->pdev->dev,
-		 "    max_frame = %d, rx_hdr_len = %d, rx_buf_len = %d dtype = %d\n",
-		 vsi->max_frame, vsi->rx_hdr_len, vsi->rx_buf_len, vsi->dtype);
+	pf_info(pf, "    work_limit = %d, rx_itr_setting = %d (%s), tx_itr_setting = %d (%s)\n",
+		vsi->work_limit, vsi->rx_itr_setting,
+		ITR_IS_DYNAMIC(vsi->rx_itr_setting) ? "dynamic" : "fixed",
+		vsi->tx_itr_setting,
+		ITR_IS_DYNAMIC(vsi->tx_itr_setting) ? "dynamic" : "fixed");
+	pf_info(pf, "    max_frame = %d, rx_hdr_len = %d, rx_buf_len = %d dtype = %d\n",
+		vsi->max_frame, vsi->rx_hdr_len, vsi->rx_buf_len, vsi->dtype);
 	if (vsi->q_vectors) {
 		for (i = 0; i < vsi->num_q_vectors; i++) {
-			dev_info(&pf->pdev->dev,
-				 "    q_vectors[%i]: base index = %ld\n",
-				 i, ((long int)*vsi->q_vectors[i].rx.ring-
-				     (long int)*vsi->q_vectors[0].rx.ring)/
-				 sizeof(struct i40e_ring));
+			pf_info(pf, "    q_vectors[%i]: base index = %ld\n",
+				i, ((long int)*vsi->q_vectors[i].rx.ring-
+				    (long int)*vsi->q_vectors[0].rx.ring)/
+				sizeof(struct i40e_ring));
 		}
 	}
-	dev_info(&pf->pdev->dev,
-		 "    num_q_vectors = %i, base_vector = %i\n",
-		 vsi->num_q_vectors, vsi->base_vector);
-	dev_info(&pf->pdev->dev,
-		 "    seid = %d, id = %d, uplink_seid = %d\n",
-		 vsi->seid, vsi->id, vsi->uplink_seid);
-	dev_info(&pf->pdev->dev,
-		 "    base_queue = %d, num_queue_pairs = %d, num_desc = %d\n",
-		 vsi->base_queue, vsi->num_queue_pairs, vsi->num_desc);
-	dev_info(&pf->pdev->dev,
-		 "    type = %i\n",
-		 vsi->type);
-	dev_info(&pf->pdev->dev,
-		 "    info: valid_sections = 0x%04x, switch_id = 0x%04x\n",
-		 vsi->info.valid_sections, vsi->info.switch_id);
-	dev_info(&pf->pdev->dev,
-		 "    info: sw_reserved[] = 0x%02x 0x%02x\n",
-		 vsi->info.sw_reserved[0], vsi->info.sw_reserved[1]);
-	dev_info(&pf->pdev->dev,
-		 "    info: sec_flags = 0x%02x, sec_reserved = 0x%02x\n",
-		 vsi->info.sec_flags, vsi->info.sec_reserved);
-	dev_info(&pf->pdev->dev,
-		 "    info: pvid = 0x%04x, fcoe_pvid = 0x%04x, port_vlan_flags = 0x%02x\n",
-		 vsi->info.pvid, vsi->info.fcoe_pvid, vsi->info.port_vlan_flags);
-	dev_info(&pf->pdev->dev,
-		 "    info: pvlan_reserved[] = 0x%02x 0x%02x 0x%02x\n",
-		 vsi->info.pvlan_reserved[0], vsi->info.pvlan_reserved[1],
-		 vsi->info.pvlan_reserved[2]);
-	dev_info(&pf->pdev->dev,
-		 "    info: ingress_table = 0x%08x, egress_table = 0x%08x\n",
-		 vsi->info.ingress_table, vsi->info.egress_table);
-	dev_info(&pf->pdev->dev,
-		 "    info: cas_pv_stag = 0x%04x, cas_pv_flags= 0x%02x, cas_pv_reserved = 0x%02x\n",
-		 vsi->info.cas_pv_tag, vsi->info.cas_pv_flags,
-		 vsi->info.cas_pv_reserved);
-	dev_info(&pf->pdev->dev,
-		 "    info: queue_mapping[0..7 ] = 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x\n",
-		 vsi->info.queue_mapping[0], vsi->info.queue_mapping[1],
-		 vsi->info.queue_mapping[2], vsi->info.queue_mapping[3],
-		 vsi->info.queue_mapping[4], vsi->info.queue_mapping[5],
-		 vsi->info.queue_mapping[6], vsi->info.queue_mapping[7]);
-	dev_info(&pf->pdev->dev,
-		 "    info: queue_mapping[8..15] = 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x\n",
-		 vsi->info.queue_mapping[8], vsi->info.queue_mapping[9],
-		 vsi->info.queue_mapping[10], vsi->info.queue_mapping[11],
-		 vsi->info.queue_mapping[12], vsi->info.queue_mapping[13],
-		 vsi->info.queue_mapping[14], vsi->info.queue_mapping[15]);
-	dev_info(&pf->pdev->dev,
-		 "    info: tc_mapping[] = 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x\n",
-		 vsi->info.tc_mapping[0], vsi->info.tc_mapping[1],
-		 vsi->info.tc_mapping[2], vsi->info.tc_mapping[3],
-		 vsi->info.tc_mapping[4], vsi->info.tc_mapping[5],
-		 vsi->info.tc_mapping[6], vsi->info.tc_mapping[7]);
-	dev_info(&pf->pdev->dev,
-		 "    info: queueing_opt_flags = 0x%02x  queueing_opt_reserved[0..2] = 0x%02x 0x%02x 0x%02x\n",
-		 vsi->info.queueing_opt_flags,
-		 vsi->info.queueing_opt_reserved[0],
-		 vsi->info.queueing_opt_reserved[1],
-		 vsi->info.queueing_opt_reserved[2]);
-	dev_info(&pf->pdev->dev,
-		 "    info: up_enable_bits = 0x%02x\n",
-		 vsi->info.up_enable_bits);
-	dev_info(&pf->pdev->dev,
-		 "    info: sched_reserved = 0x%02x, outer_up_table = 0x%04x\n",
-		 vsi->info.sched_reserved, vsi->info.outer_up_table);
-	dev_info(&pf->pdev->dev,
-		 "    info: cmd_reserved[] = 0x%02x 0x%02x 0x%02x 0x0%02x 0x%02x 0x%02x 0x%02x 0x0%02x\n",
-		 vsi->info.cmd_reserved[0], vsi->info.cmd_reserved[1],
-		 vsi->info.cmd_reserved[2], vsi->info.cmd_reserved[3],
-		 vsi->info.cmd_reserved[4], vsi->info.cmd_reserved[5],
-		 vsi->info.cmd_reserved[6], vsi->info.cmd_reserved[7]);
-	dev_info(&pf->pdev->dev,
-		 "    info: qs_handle[] = 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x\n",
-		 vsi->info.qs_handle[0], vsi->info.qs_handle[1],
-		 vsi->info.qs_handle[2], vsi->info.qs_handle[3],
-		 vsi->info.qs_handle[4], vsi->info.qs_handle[5],
-		 vsi->info.qs_handle[6], vsi->info.qs_handle[7]);
-	dev_info(&pf->pdev->dev,
-		 "    info: stat_counter_idx = 0x%04x, sched_id = 0x%04x\n",
-		 vsi->info.stat_counter_idx, vsi->info.sched_id);
-	dev_info(&pf->pdev->dev,
-		 "    info: resp_reserved[] = 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x\n",
-		 vsi->info.resp_reserved[0], vsi->info.resp_reserved[1],
-		 vsi->info.resp_reserved[2], vsi->info.resp_reserved[3],
-		 vsi->info.resp_reserved[4], vsi->info.resp_reserved[5],
-		 vsi->info.resp_reserved[6], vsi->info.resp_reserved[7],
-		 vsi->info.resp_reserved[8], vsi->info.resp_reserved[9],
-		 vsi->info.resp_reserved[10], vsi->info.resp_reserved[11]);
+	pf_info(pf, "    num_q_vectors = %i, base_vector = %i\n",
+		vsi->num_q_vectors, vsi->base_vector);
+	pf_info(pf, "    seid = %d, id = %d, uplink_seid = %d\n",
+		vsi->seid, vsi->id, vsi->uplink_seid);
+	pf_info(pf, "    base_queue = %d, num_queue_pairs = %d, num_desc = %d\n",
+		vsi->base_queue, vsi->num_queue_pairs, vsi->num_desc);
+	pf_info(pf, "    type = %i\n", vsi->type);
+	pf_info(pf, "    info: valid_sections = 0x%04x, switch_id = 0x%04x\n",
+		vsi->info.valid_sections, vsi->info.switch_id);
+	pf_info(pf, "    info: sw_reserved[] = 0x%02x 0x%02x\n",
+		vsi->info.sw_reserved[0], vsi->info.sw_reserved[1]);
+	pf_info(pf, "    info: sec_flags = 0x%02x, sec_reserved = 0x%02x\n",
+		vsi->info.sec_flags, vsi->info.sec_reserved);
+	pf_info(pf, "    info: pvid = 0x%04x, fcoe_pvid = 0x%04x, port_vlan_flags = 0x%02x\n",
+		vsi->info.pvid, vsi->info.fcoe_pvid, vsi->info.port_vlan_flags);
+	pf_info(pf, "    info: pvlan_reserved[] = 0x%02x 0x%02x 0x%02x\n",
+		vsi->info.pvlan_reserved[0], vsi->info.pvlan_reserved[1],
+		vsi->info.pvlan_reserved[2]);
+	pf_info(pf, "    info: ingress_table = 0x%08x, egress_table = 0x%08x\n",
+		vsi->info.ingress_table, vsi->info.egress_table);
+	pf_info(pf, "    info: cas_pv_stag = 0x%04x, cas_pv_flags= 0x%02x, cas_pv_reserved = 0x%02x\n",
+		vsi->info.cas_pv_tag, vsi->info.cas_pv_flags,
+		vsi->info.cas_pv_reserved);
+	pf_info(pf, "    info: queue_mapping[0..7 ] = 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x\n",
+		vsi->info.queue_mapping[0], vsi->info.queue_mapping[1],
+		vsi->info.queue_mapping[2], vsi->info.queue_mapping[3],
+		vsi->info.queue_mapping[4], vsi->info.queue_mapping[5],
+		vsi->info.queue_mapping[6], vsi->info.queue_mapping[7]);
+	pf_info(pf, "    info: queue_mapping[8..15] = 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x\n",
+		vsi->info.queue_mapping[8], vsi->info.queue_mapping[9],
+		vsi->info.queue_mapping[10], vsi->info.queue_mapping[11],
+		vsi->info.queue_mapping[12], vsi->info.queue_mapping[13],
+		vsi->info.queue_mapping[14], vsi->info.queue_mapping[15]);
+	pf_info(pf, "    info: tc_mapping[] = 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x\n",
+		vsi->info.tc_mapping[0], vsi->info.tc_mapping[1],
+		vsi->info.tc_mapping[2], vsi->info.tc_mapping[3],
+		vsi->info.tc_mapping[4], vsi->info.tc_mapping[5],
+		vsi->info.tc_mapping[6], vsi->info.tc_mapping[7]);
+	pf_info(pf, "    info: queueing_opt_flags = 0x%02x  queueing_opt_reserved[0..2] = 0x%02x 0x%02x 0x%02x\n",
+		vsi->info.queueing_opt_flags,
+		vsi->info.queueing_opt_reserved[0],
+		vsi->info.queueing_opt_reserved[1],
+		vsi->info.queueing_opt_reserved[2]);
+	pf_info(pf, "    info: up_enable_bits = 0x%02x\n",
+		vsi->info.up_enable_bits);
+	pf_info(pf, "    info: sched_reserved = 0x%02x, outer_up_table = 0x%04x\n",
+		vsi->info.sched_reserved, vsi->info.outer_up_table);
+	pf_info(pf, "    info: cmd_reserved[] = 0x%02x 0x%02x 0x%02x 0x0%02x 0x%02x 0x%02x 0x%02x 0x0%02x\n",
+		vsi->info.cmd_reserved[0], vsi->info.cmd_reserved[1],
+		vsi->info.cmd_reserved[2], vsi->info.cmd_reserved[3],
+		vsi->info.cmd_reserved[4], vsi->info.cmd_reserved[5],
+		vsi->info.cmd_reserved[6], vsi->info.cmd_reserved[7]);
+	pf_info(pf, "    info: qs_handle[] = 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x 0x%04x\n",
+		vsi->info.qs_handle[0], vsi->info.qs_handle[1],
+		vsi->info.qs_handle[2], vsi->info.qs_handle[3],
+		vsi->info.qs_handle[4], vsi->info.qs_handle[5],
+		vsi->info.qs_handle[6], vsi->info.qs_handle[7]);
+	pf_info(pf, "    info: stat_counter_idx = 0x%04x, sched_id = 0x%04x\n",
+		vsi->info.stat_counter_idx, vsi->info.sched_id);
+	pf_info(pf, "    info: resp_reserved[] = 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x\n",
+		vsi->info.resp_reserved[0], vsi->info.resp_reserved[1],
+		vsi->info.resp_reserved[2], vsi->info.resp_reserved[3],
+		vsi->info.resp_reserved[4], vsi->info.resp_reserved[5],
+		vsi->info.resp_reserved[6], vsi->info.resp_reserved[7],
+		vsi->info.resp_reserved[8], vsi->info.resp_reserved[9],
+		vsi->info.resp_reserved[10], vsi->info.resp_reserved[11]);
 	if (vsi->back)
-		dev_info(&pf->pdev->dev,
-			 "    pf = %p\n", vsi->back);
-	dev_info(&pf->pdev->dev,
-		 "    idx = %d\n", vsi->idx);
-	dev_info(&pf->pdev->dev,
-		 "    tc_config: numtc = %d, enabled_tc = 0x%x\n",
-		 vsi->tc_config.numtc, vsi->tc_config.enabled_tc);
+		pf_info(pf, "    pf = %p\n", vsi->back);
+	pf_info(pf, "    idx = %d\n", vsi->idx);
+	pf_info(pf, "    tc_config: numtc = %d, enabled_tc = 0x%x\n",
+		vsi->tc_config.numtc, vsi->tc_config.enabled_tc);
 	for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
-		dev_info(&pf->pdev->dev,
-			 "    tc_config: tc = %d, qoffset = %d, qcount = %d, netdev_tc = %d\n",
-			 i, vsi->tc_config.tc_info[i].qoffset,
-			 vsi->tc_config.tc_info[i].qcount,
-			 vsi->tc_config.tc_info[i].netdev_tc);
+		pf_info(pf, "    tc_config: tc = %d, qoffset = %d, qcount = %d, netdev_tc = %d\n",
+			i, vsi->tc_config.tc_info[i].qoffset,
+			vsi->tc_config.tc_info[i].qcount,
+			vsi->tc_config.tc_info[i].netdev_tc);
 	}
-	dev_info(&pf->pdev->dev,
-		 "    bw: bw_limit = %d, bw_max_quanta = %d\n",
-		 vsi->bw_limit, vsi->bw_max_quanta);
+	pf_info(pf, "    bw: bw_limit = %d, bw_max_quanta = %d\n",
+		vsi->bw_limit, vsi->bw_max_quanta);
 	for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
-		dev_info(&pf->pdev->dev,
-			 "    bw[%d]: ets_share_credits = %d, ets_limit_credits = %d, max_quanta = %d\n",
-			 i, vsi->bw_ets_share_credits[i],
-			 vsi->bw_ets_limit_credits[i],
-			 vsi->bw_ets_max_quanta[i]);
+		pf_info(pf, "    bw[%d]: ets_share_credits = %d, ets_limit_credits = %d, max_quanta = %d\n",
+			i, vsi->bw_ets_share_credits[i],
+			vsi->bw_ets_limit_credits[i],
+			vsi->bw_ets_max_quanta[i]);
 	}
 }
 
@@ -729,40 +650,36 @@ static void i40e_dbg_dump_aq_desc(struct i40e_pf *pf)
 	int i;
 
 	/* first the send (command) ring, then the receive (event) ring */
-	dev_info(&pf->pdev->dev, "%s: AdminQ Tx Ring\n", __func__);
+	pf_info(pf, "%s: AdminQ Tx Ring\n", __func__);
 	ring = &(hw->aq.asq);
 	for (i = 0; i < ring->count; i++) {
 		struct i40e_aq_desc *d = I40E_ADMINQ_DESC(*ring, i);
-		dev_info(&pf->pdev->dev,
-			 "   at[%02d] flags=0x%04x op=0x%04x dlen=0x%04x ret=0x%04x cookie_h=0x%08x cookie_l=0x%08x\n",
-			 i, d->flags, d->opcode, d->datalen, d->retval,
-			 d->cookie_high, d->cookie_low);
-		dev_info(&pf->pdev->dev,
-			 "            %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x\n",
-			 d->params.raw[0], d->params.raw[1], d->params.raw[2],
-			 d->params.raw[3], d->params.raw[4], d->params.raw[5],
-			 d->params.raw[6], d->params.raw[7], d->params.raw[8],
-			 d->params.raw[9], d->params.raw[10], d->params.raw[11],
-			 d->params.raw[12], d->params.raw[13], d->params.raw[14],
-			 d->params.raw[15]);
+		pf_info(pf, "   at[%02d] flags=0x%04x op=0x%04x dlen=0x%04x ret=0x%04x cookie_h=0x%08x cookie_l=0x%08x\n",
+			i, d->flags, d->opcode, d->datalen, d->retval,
+			d->cookie_high, d->cookie_low);
+		pf_info(pf, "            %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x\n",
+			d->params.raw[0], d->params.raw[1], d->params.raw[2],
+			d->params.raw[3], d->params.raw[4], d->params.raw[5],
+			d->params.raw[6], d->params.raw[7], d->params.raw[8],
+			d->params.raw[9], d->params.raw[10], d->params.raw[11],
+			d->params.raw[12], d->params.raw[13], d->params.raw[14],
+			d->params.raw[15]);
 	}
 
-	dev_info(&pf->pdev->dev, "%s: AdminQ Rx Ring\n", __func__);
+	pf_info(pf, "%s: AdminQ Rx Ring\n", __func__);
 	ring = &(hw->aq.arq);
 	for (i = 0; i < ring->count; i++) {
 		struct i40e_aq_desc *d = I40E_ADMINQ_DESC(*ring, i);
-		dev_info(&pf->pdev->dev,
-			 "   ar[%02d] flags=0x%04x op=0x%04x dlen=0x%04x ret=0x%04x cookie_h=0x%08x cookie_l=0x%08x\n",
-			 i, d->flags, d->opcode, d->datalen, d->retval,
-			 d->cookie_high, d->cookie_low);
-		dev_info(&pf->pdev->dev,
-			 "            %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x\n",
-			 d->params.raw[0], d->params.raw[1], d->params.raw[2],
-			 d->params.raw[3], d->params.raw[4], d->params.raw[5],
-			 d->params.raw[6], d->params.raw[7], d->params.raw[8],
-			 d->params.raw[9], d->params.raw[10], d->params.raw[11],
-			 d->params.raw[12], d->params.raw[13], d->params.raw[14],
-			 d->params.raw[15]);
+		pf_info(pf, "   ar[%02d] flags=0x%04x op=0x%04x dlen=0x%04x ret=0x%04x cookie_h=0x%08x cookie_l=0x%08x\n",
+			i, d->flags, d->opcode, d->datalen, d->retval,
+			d->cookie_high, d->cookie_low);
+		pf_info(pf, "            %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x\n",
+			d->params.raw[0], d->params.raw[1], d->params.raw[2],
+			d->params.raw[3], d->params.raw[4], d->params.raw[5],
+			d->params.raw[6], d->params.raw[7], d->params.raw[8],
+			d->params.raw[9], d->params.raw[10], d->params.raw[11],
+			d->params.raw[12], d->params.raw[13], d->params.raw[14],
+			d->params.raw[15]);
 	}
 }
 
@@ -785,29 +702,23 @@ static void i40e_dbg_dump_desc(int cnt, int vsi_seid, int ring_id, int desc_n,
 
 	vsi = i40e_dbg_find_vsi(pf, vsi_seid);
 	if (!vsi) {
-		dev_info(&pf->pdev->dev,
-			 "%s: vsi %d not found\n", __func__, vsi_seid);
+		pf_info(pf, "%s: vsi %d not found\n", __func__, vsi_seid);
 		if (is_rx_ring)
-			dev_info(&pf->pdev->dev,
-				 "%s: dump desc rx <vsi_seid> <ring_id> [<desc_n>]\n",
-				 __func__);
+			pf_info(pf, "%s: dump desc rx <vsi_seid> <ring_id> [<desc_n>]\n",
+				__func__);
 		else
-			dev_info(&pf->pdev->dev,
-				 "%s: dump desc tx <vsi_seid> <ring_id> [<desc_n>]\n",
-				 __func__);
+			pf_info(pf, "%s: dump desc tx <vsi_seid> <ring_id> [<desc_n>]\n",
+				__func__);
 		return;
 	}
 	if (ring_id >= vsi->num_queue_pairs || ring_id < 0) {
-		dev_info(&pf->pdev->dev,
-			 "%s: ring %d not found\n", __func__, ring_id);
+		pf_info(pf, "%s: ring %d not found\n", __func__, ring_id);
 		if (is_rx_ring)
-			dev_info(&pf->pdev->dev,
-				 "%s: dump desc rx <vsi_seid> <ring_id> [<desc_n>]\n",
-				 __func__);
+			pf_info(pf, "%s: dump desc rx <vsi_seid> <ring_id> [<desc_n>]\n",
+				__func__);
 		else
-			dev_info(&pf->pdev->dev,
-				 "%s: dump desc tx <vsi_seid> <ring_id> [<desc_n>]\n",
-				 __func__);
+			pf_info(pf, "%s: dump desc tx <vsi_seid> <ring_id> [<desc_n>]\n",
+				__func__);
 		return;
 	}
 	if (is_rx_ring)
@@ -815,8 +726,8 @@ static void i40e_dbg_dump_desc(int cnt, int vsi_seid, int ring_id, int desc_n,
 	else
 		ring = vsi->tx_rings[ring_id];
 	if (cnt == 2) {
-		dev_info(&pf->pdev->dev, "%s: vsi = %02i %s ring = %02i\n",
-			 __func__, vsi_seid, is_rx_ring ? "rx" : "tx", ring_id);
+		pf_info(pf, "%s: vsi = %02i %s ring = %02i\n",
+			__func__, vsi_seid, is_rx_ring ? "rx" : "tx", ring_id);
 		for (i = 0; i < ring.count; i++) {
 			if (is_rx_ring)
 				ds = I40E_RX_DESC(&ring, i);
@@ -825,21 +736,19 @@ static void i40e_dbg_dump_desc(int cnt, int vsi_seid, int ring_id, int desc_n,
 					I40E_TX_DESC(&ring, i);
 			if ((sizeof(union i40e_rx_desc) ==
 			    sizeof(union i40e_16byte_rx_desc)) || (!is_rx_ring))
-				dev_info(&pf->pdev->dev,
-					 "   d[%03i] = 0x%016llx 0x%016llx\n", i,
-					 ds->read.pkt_addr, ds->read.hdr_addr);
+				pf_info(pf, "   d[%03i] = 0x%016llx 0x%016llx\n",
+					i, ds->read.pkt_addr,
+					ds->read.hdr_addr);
 			else
-				dev_info(&pf->pdev->dev,
-					 "   d[%03i] = 0x%016llx 0x%016llx 0x%016llx 0x%016llx\n",
-					 i, ds->read.pkt_addr,
-					 ds->read.hdr_addr,
-					 ds->read.rsvd1, ds->read.rsvd2);
+				pf_info(pf, "   d[%03i] = 0x%016llx 0x%016llx 0x%016llx 0x%016llx\n",
+					i, ds->read.pkt_addr,
+					ds->read.hdr_addr,
+					ds->read.rsvd1, ds->read.rsvd2);
 		}
 	} else if (cnt == 3) {
 		if (desc_n >= ring.count || desc_n < 0) {
-			dev_info(&pf->pdev->dev,
-				 "%s: descriptor %d not found\n",
-				 __func__, desc_n);
+			pf_info(pf, "%s: descriptor %d not found\n",
+				__func__, desc_n);
 			return;
 		}
 		if (is_rx_ring)
@@ -848,26 +757,22 @@ static void i40e_dbg_dump_desc(int cnt, int vsi_seid, int ring_id, int desc_n,
 			ds = (union i40e_rx_desc *)I40E_TX_DESC(&ring, desc_n);
 		if ((sizeof(union i40e_rx_desc) ==
 		    sizeof(union i40e_16byte_rx_desc)) || (!is_rx_ring))
-			dev_info(&pf->pdev->dev,
-				 "%s: vsi = %02i %s ring = %02i d[%03i] = 0x%016llx 0x%016llx\n",
-				 __func__, vsi_seid,
-				 is_rx_ring ? "rx" : "tx", ring_id,
-				 desc_n, ds->read.pkt_addr, ds->read.hdr_addr);
+			pf_info(pf, "%s: vsi = %02i %s ring = %02i d[%03i] = 0x%016llx 0x%016llx\n",
+				__func__, vsi_seid,
+				is_rx_ring ? "rx" : "tx", ring_id,
+				desc_n, ds->read.pkt_addr, ds->read.hdr_addr);
 		else
-			dev_info(&pf->pdev->dev,
-				 "%s: vsi = %02i rx ring = %02i d[%03i] = 0x%016llx 0x%016llx 0x%016llx 0x%016llx\n",
-				 __func__, vsi_seid, ring_id,
-				 desc_n, ds->read.pkt_addr, ds->read.hdr_addr,
-				 ds->read.rsvd1, ds->read.rsvd2);
+			pf_info(pf, "%s: vsi = %02i rx ring = %02i d[%03i] = 0x%016llx 0x%016llx 0x%016llx 0x%016llx\n",
+				__func__, vsi_seid, ring_id,
+				desc_n, ds->read.pkt_addr, ds->read.hdr_addr,
+				ds->read.rsvd1, ds->read.rsvd2);
 	} else {
 		if (is_rx_ring)
-			dev_info(&pf->pdev->dev,
-				 "%s: dump desc rx <vsi_seid> <ring_id> [<desc_n>]\n",
-				 __func__);
+			pf_info(pf, "%s: dump desc rx <vsi_seid> <ring_id> [<desc_n>]\n",
+				__func__);
 		else
-			dev_info(&pf->pdev->dev,
-				 "%s: dump desc tx <vsi_seid> <ring_id> [<desc_n>]\n",
-				 __func__);
+			pf_info(pf, "%s: dump desc tx <vsi_seid> <ring_id> [<desc_n>]\n",
+				__func__);
 	}
 }
 
@@ -881,8 +786,8 @@ static void i40e_dbg_dump_vsi_no_seid(struct i40e_pf *pf)
 
 	for (i = 0; i < pf->hw.func_caps.num_vsis; i++)
 		if (pf->vsi[i])
-			dev_info(&pf->pdev->dev, "%s: dump vsi[%d]: %d\n",
-				 __func__, i, pf->vsi[i]->seid);
+			pf_info(pf, "%s: dump vsi[%d]: %d\n",
+				__func__, i, pf->vsi[i]->seid);
 }
 
 /**
@@ -893,23 +798,18 @@ static void i40e_dbg_dump_vsi_no_seid(struct i40e_pf *pf)
 static void i40e_dbg_dump_eth_stats(struct i40e_pf *pf,
 				    struct i40e_eth_stats *estats)
 {
-	dev_info(&pf->pdev->dev, "  ethstats:\n");
-	dev_info(&pf->pdev->dev,
-		 "    rx_bytes = \t%lld \trx_unicast = \t\t%lld \trx_multicast = \t%lld\n",
+	pf_info(pf, "  ethstats:\n");
+	pf_info(pf, "    rx_bytes = \t%lld \trx_unicast = \t\t%lld \trx_multicast = \t%lld\n",
 		estats->rx_bytes, estats->rx_unicast, estats->rx_multicast);
-	dev_info(&pf->pdev->dev,
-		 "    rx_broadcast = \t%lld \trx_discards = \t\t%lld \trx_errors = \t%lld\n",
-		 estats->rx_broadcast, estats->rx_discards, estats->rx_errors);
-	dev_info(&pf->pdev->dev,
-		 "    rx_missed = \t%lld \trx_unknown_protocol = \t%lld \ttx_bytes = \t%lld\n",
-		 estats->rx_missed, estats->rx_unknown_protocol,
-		 estats->tx_bytes);
-	dev_info(&pf->pdev->dev,
-		 "    tx_unicast = \t%lld \ttx_multicast = \t\t%lld \ttx_broadcast = \t%lld\n",
-		 estats->tx_unicast, estats->tx_multicast, estats->tx_broadcast);
-	dev_info(&pf->pdev->dev,
-		 "    tx_discards = \t%lld \ttx_errors = \t\t%lld\n",
-		 estats->tx_discards, estats->tx_errors);
+	pf_info(pf, "    rx_broadcast = \t%lld \trx_discards = \t\t%lld \trx_errors = \t%lld\n",
+		estats->rx_broadcast, estats->rx_discards, estats->rx_errors);
+	pf_info(pf, "    rx_missed = \t%lld \trx_unknown_protocol = \t%lld \ttx_bytes = \t%lld\n",
+		estats->rx_missed, estats->rx_unknown_protocol,
+		estats->tx_bytes);
+	pf_info(pf, "    tx_unicast = \t%lld \ttx_multicast = \t\t%lld \ttx_broadcast = \t%lld\n",
+		estats->tx_unicast, estats->tx_multicast, estats->tx_broadcast);
+	pf_info(pf, "    tx_discards = \t%lld \ttx_errors = \t\t%lld\n",
+		estats->tx_discards, estats->tx_errors);
 }
 
 /**
@@ -922,75 +822,61 @@ static void i40e_dbg_dump_stats(struct i40e_pf *pf,
 {
 	int i;
 
-	dev_info(&pf->pdev->dev, "  stats:\n");
-	dev_info(&pf->pdev->dev,
-		 "    crc_errors = \t\t%lld \tillegal_bytes = \t%lld \terror_bytes = \t\t%lld\n",
-		 stats->crc_errors, stats->illegal_bytes, stats->error_bytes);
-	dev_info(&pf->pdev->dev,
-		 "    mac_local_faults = \t%lld \tmac_remote_faults = \t%lld \trx_length_errors = \t%lld\n",
-		 stats->mac_local_faults, stats->mac_remote_faults,
-		 stats->rx_length_errors);
-	dev_info(&pf->pdev->dev,
-		 "    link_xon_rx = \t\t%lld \tlink_xoff_rx = \t\t%lld \tlink_xon_tx = \t\t%lld\n",
-		 stats->link_xon_rx, stats->link_xoff_rx, stats->link_xon_tx);
-	dev_info(&pf->pdev->dev,
-		 "    link_xoff_tx = \t\t%lld \trx_size_64 = \t\t%lld \trx_size_127 = \t\t%lld\n",
-		 stats->link_xoff_tx, stats->rx_size_64, stats->rx_size_127);
-	dev_info(&pf->pdev->dev,
-		 "    rx_size_255 = \t\t%lld \trx_size_511 = \t\t%lld \trx_size_1023 = \t\t%lld\n",
-		 stats->rx_size_255, stats->rx_size_511, stats->rx_size_1023);
-	dev_info(&pf->pdev->dev,
-		 "    rx_size_big = \t\t%lld \trx_undersize = \t\t%lld \trx_jabber = \t\t%lld\n",
-		 stats->rx_size_big, stats->rx_undersize, stats->rx_jabber);
-	dev_info(&pf->pdev->dev,
-		 "    rx_fragments = \t\t%lld \trx_oversize = \t\t%lld \ttx_size_64 = \t\t%lld\n",
-		 stats->rx_fragments, stats->rx_oversize, stats->tx_size_64);
-	dev_info(&pf->pdev->dev,
-		 "    tx_size_127 = \t\t%lld \ttx_size_255 = \t\t%lld \ttx_size_511 = \t\t%lld\n",
-		 stats->tx_size_127, stats->tx_size_255, stats->tx_size_511);
-	dev_info(&pf->pdev->dev,
-		 "    tx_size_1023 = \t\t%lld \ttx_size_big = \t\t%lld \tmac_short_packet_dropped = \t%lld\n",
-		 stats->tx_size_1023, stats->tx_size_big,
-		 stats->mac_short_packet_dropped);
+	pf_info(pf, "  stats:\n");
+	pf_info(pf, "    crc_errors = \t\t%lld \tillegal_bytes = \t%lld \terror_bytes = \t\t%lld\n",
+		stats->crc_errors, stats->illegal_bytes, stats->error_bytes);
+	pf_info(pf, "    mac_local_faults = \t%lld \tmac_remote_faults = \t%lld \trx_length_errors = \t%lld\n",
+		stats->mac_local_faults, stats->mac_remote_faults,
+		stats->rx_length_errors);
+	pf_info(pf, "    link_xon_rx = \t\t%lld \tlink_xoff_rx = \t\t%lld \tlink_xon_tx = \t\t%lld\n",
+		stats->link_xon_rx, stats->link_xoff_rx, stats->link_xon_tx);
+	pf_info(pf, "    link_xoff_tx = \t\t%lld \trx_size_64 = \t\t%lld \trx_size_127 = \t\t%lld\n",
+		stats->link_xoff_tx, stats->rx_size_64, stats->rx_size_127);
+	pf_info(pf, "    rx_size_255 = \t\t%lld \trx_size_511 = \t\t%lld \trx_size_1023 = \t\t%lld\n",
+		stats->rx_size_255, stats->rx_size_511, stats->rx_size_1023);
+	pf_info(pf, "    rx_size_big = \t\t%lld \trx_undersize = \t\t%lld \trx_jabber = \t\t%lld\n",
+		stats->rx_size_big, stats->rx_undersize, stats->rx_jabber);
+	pf_info(pf, "    rx_fragments = \t\t%lld \trx_oversize = \t\t%lld \ttx_size_64 = \t\t%lld\n",
+		stats->rx_fragments, stats->rx_oversize, stats->tx_size_64);
+	pf_info(pf, "    tx_size_127 = \t\t%lld \ttx_size_255 = \t\t%lld \ttx_size_511 = \t\t%lld\n",
+		stats->tx_size_127, stats->tx_size_255, stats->tx_size_511);
+	pf_info(pf, "    tx_size_1023 = \t\t%lld \ttx_size_big = \t\t%lld \tmac_short_packet_dropped = \t%lld\n",
+		stats->tx_size_1023, stats->tx_size_big,
+		stats->mac_short_packet_dropped);
 	for (i = 0; i < 8; i += 4) {
-		dev_info(&pf->pdev->dev,
-			 "    priority_xon_rx[%d] = \t%lld \t[%d] = \t%lld \t[%d] = \t%lld \t[%d] = \t%lld\n",
-			 i, stats->priority_xon_rx[i],
-			 i+1, stats->priority_xon_rx[i+1],
-			 i+2, stats->priority_xon_rx[i+2],
-			 i+3, stats->priority_xon_rx[i+3]);
+		pf_info(pf, "    priority_xon_rx[%d] = \t%lld \t[%d] = \t%lld \t[%d] = \t%lld \t[%d] = \t%lld\n",
+			i, stats->priority_xon_rx[i],
+			i+1, stats->priority_xon_rx[i+1],
+			i+2, stats->priority_xon_rx[i+2],
+			i+3, stats->priority_xon_rx[i+3]);
 	}
 	for (i = 0; i < 8; i += 4) {
-		dev_info(&pf->pdev->dev,
-			 "    priority_xoff_rx[%d] = \t%lld \t[%d] = \t%lld \t[%d] = \t%lld \t[%d] = \t%lld\n",
-			 i, stats->priority_xoff_rx[i],
-			 i+1, stats->priority_xoff_rx[i+1],
-			 i+2, stats->priority_xoff_rx[i+2],
-			 i+3, stats->priority_xoff_rx[i+3]);
+		pf_info(pf, "    priority_xoff_rx[%d] = \t%lld \t[%d] = \t%lld \t[%d] = \t%lld \t[%d] = \t%lld\n",
+			i, stats->priority_xoff_rx[i],
+			i+1, stats->priority_xoff_rx[i+1],
+			i+2, stats->priority_xoff_rx[i+2],
+			i+3, stats->priority_xoff_rx[i+3]);
 	}
 	for (i = 0; i < 8; i += 4) {
-		dev_info(&pf->pdev->dev,
-			 "    priority_xon_tx[%d] = \t%lld \t[%d] = \t%lld \t[%d] = \t%lld \t[%d] = \t%lld\n",
-			 i, stats->priority_xon_tx[i],
-			 i+1, stats->priority_xon_tx[i+1],
-			 i+2, stats->priority_xon_tx[i+2],
-			 i+3, stats->priority_xon_rx[i+3]);
+		pf_info(pf, "    priority_xon_tx[%d] = \t%lld \t[%d] = \t%lld \t[%d] = \t%lld \t[%d] = \t%lld\n",
+			i, stats->priority_xon_tx[i],
+			i+1, stats->priority_xon_tx[i+1],
+			i+2, stats->priority_xon_tx[i+2],
+			i+3, stats->priority_xon_rx[i+3]);
 	}
 	for (i = 0; i < 8; i += 4) {
-		dev_info(&pf->pdev->dev,
-			 "    priority_xoff_tx[%d] = \t%lld \t[%d] = \t%lld \t[%d] = \t%lld \t[%d] = \t%lld\n",
-			 i, stats->priority_xoff_tx[i],
-			 i+1, stats->priority_xoff_tx[i+1],
-			 i+2, stats->priority_xoff_tx[i+2],
-			 i+3, stats->priority_xoff_tx[i+3]);
+		pf_info(pf, "    priority_xoff_tx[%d] = \t%lld \t[%d] = \t%lld \t[%d] = \t%lld \t[%d] = \t%lld\n",
+			i, stats->priority_xoff_tx[i],
+			i+1, stats->priority_xoff_tx[i+1],
+			i+2, stats->priority_xoff_tx[i+2],
+			i+3, stats->priority_xoff_tx[i+3]);
 	}
 	for (i = 0; i < 8; i += 4) {
-		dev_info(&pf->pdev->dev,
-			 "    priority_xon_2_xoff[%d] = \t%lld \t[%d] = \t%lld \t[%d] = \t%lld \t[%d] = \t%lld\n",
-			 i, stats->priority_xon_2_xoff[i],
-			 i+1, stats->priority_xon_2_xoff[i+1],
-			 i+2, stats->priority_xon_2_xoff[i+2],
-			 i+3, stats->priority_xon_2_xoff[i+3]);
+		pf_info(pf, "    priority_xon_2_xoff[%d] = \t%lld \t[%d] = \t%lld \t[%d] = \t%lld \t[%d] = \t%lld\n",
+			i, stats->priority_xon_2_xoff[i],
+			i+1, stats->priority_xon_2_xoff[i+1],
+			i+2, stats->priority_xon_2_xoff[i+2],
+			i+3, stats->priority_xon_2_xoff[i+3]);
 	}
 
 	i40e_dbg_dump_eth_stats(pf, &stats->eth);
@@ -1007,20 +893,18 @@ static void i40e_dbg_dump_veb_seid(struct i40e_pf *pf, int seid)
 
 	if ((seid < I40E_BASE_VEB_SEID) ||
 	    (seid >= (I40E_MAX_VEB + I40E_BASE_VEB_SEID))) {
-		dev_info(&pf->pdev->dev, "%s: %d: bad seid\n", __func__, seid);
+		pf_info(pf, "%s: %d: bad seid\n", __func__, seid);
 		return;
 	}
 
 	veb = i40e_dbg_find_veb(pf, seid);
 	if (!veb) {
-		dev_info(&pf->pdev->dev,
-			 "%s: %d: can't find veb\n", __func__, seid);
+		pf_info(pf, "%s: %d: can't find veb\n", __func__, seid);
 		return;
 	}
-	dev_info(&pf->pdev->dev,
-		 "veb idx=%d,%d stats_ic=%d  seid=%d uplink=%d\n",
-		 veb->idx, veb->veb_idx, veb->stats_idx, veb->seid,
-		 veb->uplink_seid);
+	pf_info(pf, "veb idx=%d,%d stats_ic=%d  seid=%d uplink=%d\n",
+		veb->idx, veb->veb_idx, veb->stats_idx, veb->seid,
+		veb->uplink_seid);
 	i40e_dbg_dump_eth_stats(pf, &veb->stats);
 }
 
@@ -1088,32 +972,28 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			/* default to PF VSI */
 			vsi_seid = pf->vsi[pf->lan_vsi]->seid;
 		} else if (vsi_seid < 0) {
-			dev_info(&pf->pdev->dev,
-				 "%s: add VSI %d: bad vsi seid\n",
-				 __func__, vsi_seid);
+			pf_info(pf, "%s: add VSI %d: bad vsi seid\n",
+				__func__, vsi_seid);
 			goto command_write_done;
 		}
 
 		vsi = i40e_vsi_setup(pf, I40E_VSI_VMDQ2, vsi_seid, 0);
 		if (vsi)
-			dev_info(&pf->pdev->dev, "%s: added VSI %d to relay %d\n",
-				 __func__, vsi->seid, vsi->uplink_seid);
+			pf_info(pf, "%s: added VSI %d to relay %d\n",
+				__func__, vsi->seid, vsi->uplink_seid);
 		else
-			dev_info(&pf->pdev->dev, "%s: '%s' failed\n",
-				 __func__, cmd_buf);
+			pf_info(pf, "%s: '%s' failed\n", __func__, cmd_buf);
 
 	} else if (strncmp(cmd_buf, "del vsi", 7) == 0) {
 		sscanf(&cmd_buf[7], "%i", &vsi_seid);
 		vsi = i40e_dbg_find_vsi(pf, vsi_seid);
 		if (!vsi) {
-			dev_info(&pf->pdev->dev,
-				 "%s: del VSI %d: seid not found\n",
-				 __func__, vsi_seid);
+			pf_info(pf, "%s: del VSI %d: seid not found\n",
+				__func__, vsi_seid);
 			goto command_write_done;
 		}
 
-		dev_info(&pf->pdev->dev, "%s: deleting VSI %d\n",
-			 __func__, vsi_seid);
+		pf_info(pf, "%s: deleting VSI %d\n", __func__, vsi_seid);
 		i40e_vsi_release(vsi);
 
 	} else if (strncmp(cmd_buf, "add relay", 9) == 0) {
@@ -1122,22 +1002,19 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 
 		cnt = sscanf(&cmd_buf[9], "%i %i", &uplink_seid, &vsi_seid);
 		if (cnt != 2) {
-			dev_info(&pf->pdev->dev,
-				 "%s: add relay: bad command string, cnt=%d\n",
-				 __func__, cnt);
+			pf_info(pf, "%s: add relay: bad command string, cnt=%d\n",
+				__func__, cnt);
 			goto command_write_done;
 		} else if (uplink_seid < 0) {
-			dev_info(&pf->pdev->dev,
-				 "%s: add relay %d: bad uplink seid\n",
-				 __func__, uplink_seid);
+			pf_info(pf, "%s: add relay %d: bad uplink seid\n",
+				__func__, uplink_seid);
 			goto command_write_done;
 		}
 
 		vsi = i40e_dbg_find_vsi(pf, vsi_seid);
 		if (!vsi) {
-			dev_info(&pf->pdev->dev,
-				 "%s: add relay: vsi VSI %d not found\n",
-				 __func__, vsi_seid);
+			pf_info(pf, "%s: add relay: vsi VSI %d not found\n",
+				__func__, vsi_seid);
 			goto command_write_done;
 		}
 
@@ -1146,33 +1023,29 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 				break;
 		if (i >= I40E_MAX_VEB && uplink_seid != 0 &&
 		    uplink_seid != pf->mac_seid) {
-			dev_info(&pf->pdev->dev,
-				 "%s: add relay: relay uplink %d not found\n",
-				 __func__, uplink_seid);
+			pf_info(pf, "%s: add relay: relay uplink %d not found\n",
+				__func__, uplink_seid);
 			goto command_write_done;
 		}
 
 		veb = i40e_veb_setup(pf, 0, uplink_seid, vsi_seid,
 				     vsi->tc_config.enabled_tc);
 		if (veb)
-			dev_info(&pf->pdev->dev, "%s: added relay %d\n",
-				 __func__, veb->seid);
+			pf_info(pf, "%s: added relay %d\n",
+				__func__, veb->seid);
 		else
-			dev_info(&pf->pdev->dev, "%s: add relay failed\n",
-				 __func__);
+			pf_info(pf, "%s: add relay failed\n", __func__);
 
 	} else if (strncmp(cmd_buf, "del relay", 9) == 0) {
 		int i;
 		cnt = sscanf(&cmd_buf[9], "%i", &veb_seid);
 		if (cnt != 1) {
-			dev_info(&pf->pdev->dev,
-				 "%s: del relay: bad command string, cnt=%d\n",
-				 __func__, cnt);
+			pf_info(pf, "%s: del relay: bad command string, cnt=%d\n",
+				__func__, cnt);
 			goto command_write_done;
 		} else if (veb_seid < 0) {
-			dev_info(&pf->pdev->dev,
-				 "%s: del relay %d: bad relay seid\n",
-				 __func__, veb_seid);
+			pf_info(pf, "%s: del relay %d: bad relay seid\n",
+				__func__, veb_seid);
 			goto command_write_done;
 		}
 
@@ -1181,14 +1054,12 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			if (pf->veb[i] && pf->veb[i]->seid == veb_seid)
 				break;
 		if (i >= I40E_MAX_VEB) {
-			dev_info(&pf->pdev->dev,
-				 "%s: del relay: relay %d not found\n",
-				 __func__, veb_seid);
+			pf_info(pf, "%s: del relay: relay %d not found\n",
+				__func__, veb_seid);
 			goto command_write_done;
 		}
 
-		dev_info(&pf->pdev->dev, "%s: deleting relay %d\n",
-			 __func__, veb_seid);
+		pf_info(pf, "%s: deleting relay %d\n", __func__, veb_seid);
 		i40e_veb_release(pf->veb[i]);
 
 	} else if (strncmp(cmd_buf, "add macaddr", 11) == 0) {
@@ -1205,30 +1076,26 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		if (cnt == 7) {
 			vlan = 0;
 		} else if (cnt != 8) {
-			dev_info(&pf->pdev->dev,
-				 "%s: add macaddr: bad command string, cnt=%d\n",
-				 __func__, cnt);
+			pf_info(pf, "%s: add macaddr: bad command string, cnt=%d\n",
+				__func__, cnt);
 			goto command_write_done;
 		}
 
 		vsi = i40e_dbg_find_vsi(pf, vsi_seid);
 		if (!vsi) {
-			dev_info(&pf->pdev->dev,
-				 "%s: add macaddr: VSI %d not found\n",
-				 __func__, vsi_seid);
+			pf_info(pf, "%s: add macaddr: VSI %d not found\n",
+				__func__, vsi_seid);
 			goto command_write_done;
 		}
 
 		f = i40e_add_filter(vsi, ma, vlan, false, false);
 		ret = i40e_sync_vsi_filters(vsi);
 		if (f && !ret)
-			dev_info(&pf->pdev->dev,
-				 "%s: add macaddr: %pM vlan=%d added to VSI %d\n",
-				 __func__, ma, vlan, vsi_seid);
+			pf_info(pf, "%s: add macaddr: %pM vlan=%d added to VSI %d\n",
+				__func__, ma, vlan, vsi_seid);
 		else
-			dev_info(&pf->pdev->dev,
-				 "%s: add macaddr: %pM vlan=%d to VSI %d failed, f=%p ret=%d\n",
-				 __func__, ma, vlan, vsi_seid, f, ret);
+			pf_info(pf, "%s: add macaddr: %pM vlan=%d to VSI %d failed, f=%p ret=%d\n",
+				__func__, ma, vlan, vsi_seid, f, ret);
 
 	} else if (strncmp(cmd_buf, "del macaddr", 11) == 0) {
 		u8 ma[6];
@@ -1243,30 +1110,26 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		if (cnt == 7) {
 			vlan = 0;
 		} else if (cnt != 8) {
-			dev_info(&pf->pdev->dev,
-				 "%s: del macaddr: bad command string, cnt=%d\n",
-				 __func__, cnt);
+			pf_info(pf, "%s: del macaddr: bad command string, cnt=%d\n",
+				__func__, cnt);
 			goto command_write_done;
 		}
 
 		vsi = i40e_dbg_find_vsi(pf, vsi_seid);
 		if (!vsi) {
-			dev_info(&pf->pdev->dev,
-				 "%s: del macaddr: VSI %d not found\n",
-				 __func__, vsi_seid);
+			pf_info(pf, "%s: del macaddr: VSI %d not found\n",
+				__func__, vsi_seid);
 			goto command_write_done;
 		}
 
 		i40e_del_filter(vsi, ma, vlan, false, false);
 		ret = i40e_sync_vsi_filters(vsi);
 		if (!ret)
-			dev_info(&pf->pdev->dev,
-				 "%s: del macaddr: %pM vlan=%d removed from VSI %d\n",
-				 __func__, ma, vlan, vsi_seid);
+			pf_info(pf, "%s: del macaddr: %pM vlan=%d removed from VSI %d\n",
+				__func__, ma, vlan, vsi_seid);
 		else
-			dev_info(&pf->pdev->dev,
-				 "%s: del macaddr: %pM vlan=%d from VSI %d failed, ret=%d\n",
-				 __func__, ma, vlan, vsi_seid, ret);
+			pf_info(pf, "%s: del macaddr: %pM vlan=%d from VSI %d failed, ret=%d\n",
+				__func__, ma, vlan, vsi_seid, ret);
 
 	} else if (strncmp(cmd_buf, "add pvid", 8) == 0) {
 		int v;
@@ -1275,59 +1138,51 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 
 		cnt = sscanf(&cmd_buf[8], "%i %u", &vsi_seid, &v);
 		if (cnt != 2) {
-			dev_info(&pf->pdev->dev,
-				 "%s: add pvid: bad command string, cnt=%d\n",
-				 __func__, cnt);
+			pf_info(pf, "%s: add pvid: bad command string, cnt=%d\n",
+				__func__, cnt);
 			goto command_write_done;
 		}
 
 		vsi = i40e_dbg_find_vsi(pf, vsi_seid);
 		if (!vsi) {
-			dev_info(&pf->pdev->dev,
-				 "%s: add pvid: VSI %d not found\n",
-				 __func__, vsi_seid);
+			pf_info(pf, "%s: add pvid: VSI %d not found\n",
+				__func__, vsi_seid);
 			goto command_write_done;
 		}
 
 		vid = (unsigned)v;
 		ret = i40e_vsi_add_pvid(vsi, vid);
 		if (!ret)
-			dev_info(&pf->pdev->dev,
-				 "%s: add pvid: %d added to VSI %d\n",
-				 __func__, vid, vsi_seid);
+			pf_info(pf, "%s: add pvid: %d added to VSI %d\n",
+				__func__, vid, vsi_seid);
 		else
-			dev_info(&pf->pdev->dev,
-				 "%s: add pvid: %d to VSI %d failed, ret=%d\n",
-				 __func__, vid, vsi_seid, ret);
+			pf_info(pf, "%s: add pvid: %d to VSI %d failed, ret=%d\n",
+				__func__, vid, vsi_seid, ret);
 
 	} else if (strncmp(cmd_buf, "del pvid", 8) == 0) {
 		i40e_status ret;
 
 		cnt = sscanf(&cmd_buf[8], "%i", &vsi_seid);
 		if (cnt != 1) {
-			dev_info(&pf->pdev->dev,
-				 "%s: del pvid: bad command string, cnt=%d\n",
-				 __func__, cnt);
+			pf_info(pf, "%s: del pvid: bad command string, cnt=%d\n",
+				__func__, cnt);
 			goto command_write_done;
 		}
 
 		vsi = i40e_dbg_find_vsi(pf, vsi_seid);
 		if (!vsi) {
-			dev_info(&pf->pdev->dev,
-				 "%s: del pvid: VSI %d not found\n",
-				 __func__, vsi_seid);
+			pf_info(pf, "%s: del pvid: VSI %d not found\n",
+				__func__, vsi_seid);
 			goto command_write_done;
 		}
 
 		ret = i40e_vsi_remove_pvid(vsi);
 		if (!ret)
-			dev_info(&pf->pdev->dev,
-				 "%s: del pvid: removed from VSI %d\n",
-				 __func__, vsi_seid);
+			pf_info(pf, "%s: del pvid: removed from VSI %d\n",
+				__func__, vsi_seid);
 		else
-			dev_info(&pf->pdev->dev,
-				 "%s: del pvid: VSI %d failed, ret=%d\n",
-				 __func__, vsi_seid, ret);
+			pf_info(pf, "%s: del pvid: VSI %d failed, ret=%d\n",
+				__func__, vsi_seid, ret);
 
 	} else if (strncmp(cmd_buf, "dump", 4) == 0) {
 		if (strncmp(&cmd_buf[5], "switch", 6) == 0) {
@@ -1360,29 +1215,23 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			} else if (strncmp(&cmd_buf[10], "aq", 2) == 0) {
 				i40e_dbg_dump_aq_desc(pf);
 			} else {
-				dev_info(&pf->pdev->dev,
-					 "%s: dump desc tx <vsi_seid> <ring_id> [<desc_n>]\n",
-					 __func__);
-				dev_info(&pf->pdev->dev,
-					 "%s: dump desc rx <vsi_seid> <ring_id> [<desc_n>]\n",
-					 __func__);
-				dev_info(&pf->pdev->dev,
-					 "%s: dump desc aq\n", __func__);
+				pf_info(pf, "%s: dump desc tx <vsi_seid> <ring_id> [<desc_n>]\n",
+					__func__);
+				pf_info(pf, "%s: dump desc rx <vsi_seid> <ring_id> [<desc_n>]\n",
+					__func__);
+				pf_info(pf, "%s: dump desc aq\n", __func__);
 			}
 		} else if (strncmp(&cmd_buf[5], "stats", 5) == 0) {
-			dev_info(&pf->pdev->dev, "pf stats:\n");
+			pf_info(pf, "pf stats:\n");
 			i40e_dbg_dump_stats(pf, &pf->stats);
-			dev_info(&pf->pdev->dev, "pf stats_offsets:\n");
+			pf_info(pf, "pf stats_offsets:\n");
 			i40e_dbg_dump_stats(pf, &pf->stats_offsets);
 		} else if (strncmp(&cmd_buf[5], "reset stats", 11) == 0) {
-			dev_info(&pf->pdev->dev,
-				 "core reset count: %d\n", pf->corer_count);
-			dev_info(&pf->pdev->dev,
-				 "global reset count: %d\n", pf->globr_count);
-			dev_info(&pf->pdev->dev,
-				 "emp reset count: %d\n", pf->empr_count);
-			dev_info(&pf->pdev->dev,
-				 "pf reset count: %d\n", pf->pfr_count);
+			pf_info(pf, "core reset count: %d\n", pf->corer_count);
+			pf_info(pf, "global reset count: %d\n",
+				pf->globr_count);
+			pf_info(pf, "emp reset count: %d\n", pf->empr_count);
+			pf_info(pf, "pf reset count: %d\n", pf->pfr_count);
 		} else if (strncmp(&cmd_buf[5], "port", 4) == 0) {
 			struct i40e_aqc_query_port_ets_config_resp *bw_data;
 			struct i40e_dcbx_config *cfg =
@@ -1403,114 +1252,97 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 							    pf->mac_seid,
 							    bw_data, NULL);
 			if (ret) {
-				dev_info(&pf->pdev->dev,
-					 "%s: Query Port ETS Config AQ command failed =0x%x\n",
-					 __func__, pf->hw.aq.asq_last_status);
+				pf_info(pf, "%s: Query Port ETS Config AQ command failed =0x%x\n",
+					__func__, pf->hw.aq.asq_last_status);
 				kfree(bw_data);
 				bw_data = NULL;
 				goto command_write_done;
 			}
-			dev_info(&pf->pdev->dev,
-				 "%s: port bw: tc_valid=0x%x tc_strict_prio=0x%x, tc_bw_max=0x%04x,0x%04x\n",
-				 __func__, bw_data->tc_valid_bits,
-				 bw_data->tc_strict_priority_bits,
-				 le16_to_cpu(bw_data->tc_bw_max[0]),
-				 le16_to_cpu(bw_data->tc_bw_max[1]));
+			pf_info(pf, "%s: port bw: tc_valid=0x%x tc_strict_prio=0x%x, tc_bw_max=0x%04x,0x%04x\n",
+				__func__, bw_data->tc_valid_bits,
+				bw_data->tc_strict_priority_bits,
+				le16_to_cpu(bw_data->tc_bw_max[0]),
+				le16_to_cpu(bw_data->tc_bw_max[1]));
 			for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
-				dev_info(&pf->pdev->dev, "%s: port bw: tc_bw_share=%d tc_bw_limit=%d\n",
-					 __func__,
-					 bw_data->tc_bw_share_credits[i],
-					 le16_to_cpu(bw_data->tc_bw_limits[i]));
+				pf_info(pf, "%s: port bw: tc_bw_share=%d tc_bw_limit=%d\n",
+					__func__,
+					bw_data->tc_bw_share_credits[i],
+					le16_to_cpu(bw_data->tc_bw_limits[i]));
 			}
 
 			kfree(bw_data);
 			bw_data = NULL;
 
-			dev_info(&pf->pdev->dev,
-				 "%s: port ets_cfg: willing=%d cbs=%d, maxtcs=%d\n",
-				 __func__, cfg->etscfg.willing, cfg->etscfg.cbs,
-				 cfg->etscfg.maxtcs);
+			pf_info(pf, "%s: port ets_cfg: willing=%d cbs=%d, maxtcs=%d\n",
+				__func__, cfg->etscfg.willing, cfg->etscfg.cbs,
+				cfg->etscfg.maxtcs);
 			for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
-				dev_info(&pf->pdev->dev, "%s: port ets_cfg: %d prio_tc=%d tcbw=%d tctsa=%d\n",
-					 __func__, i,
-					 cfg->etscfg.prioritytable[i],
-					 cfg->etscfg.tcbwtable[i],
-					 cfg->etscfg.tsatable[i]);
+				pf_info(pf, "%s: port ets_cfg: %d prio_tc=%d tcbw=%d tctsa=%d\n",
+					__func__, i,
+					cfg->etscfg.prioritytable[i],
+					cfg->etscfg.tcbwtable[i],
+					cfg->etscfg.tsatable[i]);
 			}
 			for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
-				dev_info(&pf->pdev->dev, "%s: port ets_rec: %d prio_tc=%d tcbw=%d tctsa=%d\n",
-					 __func__, i,
-					 cfg->etsrec.prioritytable[i],
-					 cfg->etsrec.tcbwtable[i],
-					 cfg->etsrec.tsatable[i]);
+				pf_info(pf, "%s: port ets_rec: %d prio_tc=%d tcbw=%d tctsa=%d\n",
+					__func__, i,
+					cfg->etsrec.prioritytable[i],
+					cfg->etsrec.tcbwtable[i],
+					cfg->etsrec.tsatable[i]);
 			}
-			dev_info(&pf->pdev->dev,
-				 "%s: port pfc_cfg: willing=%d mbc=%d, pfccap=%d pfcenable=0x%x\n",
-				 __func__, cfg->pfc.willing, cfg->pfc.mbc,
-				 cfg->pfc.pfccap, cfg->pfc.pfcenable);
-			dev_info(&pf->pdev->dev,
-				 "%s: port app_table: num_apps=%d\n",
-				 __func__, cfg->numapps);
+			pf_info(pf, "%s: port pfc_cfg: willing=%d mbc=%d, pfccap=%d pfcenable=0x%x\n",
+				__func__, cfg->pfc.willing, cfg->pfc.mbc,
+				cfg->pfc.pfccap, cfg->pfc.pfcenable);
+			pf_info(pf, "%s: port app_table: num_apps=%d\n",
+				__func__, cfg->numapps);
 			for (i = 0; i < cfg->numapps; i++) {
-				dev_info(&pf->pdev->dev, "%s: port app_table: %d prio=%d selector=%d protocol=0x%x\n",
-					 __func__, i, cfg->app[i].priority,
-					 cfg->app[i].selector,
-					 cfg->app[i].protocolid);
+				pf_info(pf, "%s: port app_table: %d prio=%d selector=%d protocol=0x%x\n",
+					__func__, i, cfg->app[i].priority,
+					cfg->app[i].selector,
+					cfg->app[i].protocolid);
 			}
 			/* Peer TLV DCBX data */
-			dev_info(&pf->pdev->dev,
-				 "%s: remote port ets_cfg: willing=%d cbs=%d, maxtcs=%d\n",
-				 __func__, r_cfg->etscfg.willing,
-				 r_cfg->etscfg.cbs, r_cfg->etscfg.maxtcs);
+			pf_info(pf, "%s: remote port ets_cfg: willing=%d cbs=%d, maxtcs=%d\n",
+				__func__, r_cfg->etscfg.willing,
+				r_cfg->etscfg.cbs, r_cfg->etscfg.maxtcs);
 			for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
-				dev_info(&pf->pdev->dev, "%s: remote port ets_cfg: %d prio_tc=%d tcbw=%d tctsa=%d\n",
-					 __func__, i,
-					 r_cfg->etscfg.prioritytable[i],
-					 r_cfg->etscfg.tcbwtable[i],
-					 r_cfg->etscfg.tsatable[i]);
+				pf_info(pf, "%s: remote port ets_cfg: %d prio_tc=%d tcbw=%d tctsa=%d\n",
+					__func__, i,
+					r_cfg->etscfg.prioritytable[i],
+					r_cfg->etscfg.tcbwtable[i],
+					r_cfg->etscfg.tsatable[i]);
 			}
 			for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
-				dev_info(&pf->pdev->dev, "%s: remote port ets_rec: %d prio_tc=%d tcbw=%d tctsa=%d\n",
-					 __func__, i,
-					 r_cfg->etsrec.prioritytable[i],
-					 r_cfg->etsrec.tcbwtable[i],
-					 r_cfg->etsrec.tsatable[i]);
+				pf_info(pf, "%s: remote port ets_rec: %d prio_tc=%d tcbw=%d tctsa=%d\n",
+					__func__, i,
+					r_cfg->etsrec.prioritytable[i],
+					r_cfg->etsrec.tcbwtable[i],
+					r_cfg->etsrec.tsatable[i]);
 			}
-			dev_info(&pf->pdev->dev,
-				 "%s: remote port pfc_cfg: willing=%d mbc=%d, pfccap=%d pfcenable=0x%x\n",
-				 __func__, r_cfg->pfc.willing,
-				 r_cfg->pfc.mbc,
-				 r_cfg->pfc.pfccap,
-				 r_cfg->pfc.pfcenable);
-			dev_info(&pf->pdev->dev,
-				 "%s: remote port app_table: num_apps=%d\n",
-				 __func__, r_cfg->numapps);
+			pf_info(pf, "%s: remote port pfc_cfg: willing=%d mbc=%d, pfccap=%d pfcenable=0x%x\n",
+				__func__, r_cfg->pfc.willing,
+				r_cfg->pfc.mbc,
+				r_cfg->pfc.pfccap,
+				r_cfg->pfc.pfcenable);
+			pf_info(pf, "%s: remote port app_table: num_apps=%d\n",
+				__func__, r_cfg->numapps);
 			for (i = 0; i < r_cfg->numapps; i++) {
-				dev_info(&pf->pdev->dev, "%s: remote port app_table: %d prio=%d selector=%d protocol=0x%x\n",
-					 __func__, i,
-					 r_cfg->app[i].priority,
-					 r_cfg->app[i].selector,
-					 r_cfg->app[i].protocolid);
+				pf_info(pf, "%s: remote port app_table: %d prio=%d selector=%d protocol=0x%x\n",
+					__func__, i,
+					r_cfg->app[i].priority,
+					r_cfg->app[i].selector,
+					r_cfg->app[i].protocolid);
 			}
 		} else {
-			dev_info(&pf->pdev->dev,
-				 "%s: dump desc tx <vsi_seid> <ring_id> [<desc_n>], dump desc rx <vsi_seid> <ring_id> [<desc_n>],\n",
-				 __func__);
-			dev_info(&pf->pdev->dev,
-				 "%s: dump switch, dump vsi [seid] or\n",
-				 __func__);
-			dev_info(&pf->pdev->dev,
-				 "%s: dump stats\n",
-				 __func__);
-			dev_info(&pf->pdev->dev,
-				 "%s: dump reset stats\n",
-				 __func__);
-			dev_info(&pf->pdev->dev,
-				 "%s: dump port\n",
-				 __func__);
-			dev_info(&pf->pdev->dev,
-				 "%s: dump debug fwdata <cluster_id> <table_id> <index>\n",
-				 __func__);
+			pf_info(pf, "%s: dump desc tx <vsi_seid> <ring_id> [<desc_n>], dump desc rx <vsi_seid> <ring_id> [<desc_n>],\n",
+				__func__);
+			pf_info(pf, "%s: dump switch, dump vsi [seid] or\n",
+				__func__);
+			pf_info(pf, "%s: dump stats\n", __func__);
+			pf_info(pf, "%s: dump reset stats\n", __func__);
+			pf_info(pf, "%s: dump port\n", __func__);
+			pf_info(pf, "%s: dump debug fwdata <cluster_id> <table_id> <index>\n",
+				__func__);
 		}
 
 	} else if (strncmp(cmd_buf, "msg_enable", 10) == 0) {
@@ -1519,29 +1351,26 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		if (cnt) {
 			if (I40E_DEBUG_USER & level) {
 				pf->hw.debug_mask = level;
-				dev_info(&pf->pdev->dev,
-					 "%s: set hw.debug_mask = 0x%08x\n",
-					 __func__, pf->hw.debug_mask);
+				pf_info(pf, "%s: set hw.debug_mask = 0x%08x\n",
+					__func__, pf->hw.debug_mask);
 			}
 			pf->msg_enable = level;
-			dev_info(&pf->pdev->dev,
-				 "%s: set msg_enable = 0x%08x\n",
-				 __func__, pf->msg_enable);
+			pf_info(pf, "%s: set msg_enable = 0x%08x\n",
+				__func__, pf->msg_enable);
 		} else {
-			dev_info(&pf->pdev->dev,
-				 "%s: msg_enable = 0x%08x\n",
-				 __func__, pf->msg_enable);
+			pf_info(pf, "%s: msg_enable = 0x%08x\n",
+				__func__, pf->msg_enable);
 		}
 	} else if (strncmp(cmd_buf, "pfr", 3) == 0) {
-		dev_info(&pf->pdev->dev, "%s: forcing PFR\n", __func__);
+		pf_info(pf, "%s: forcing PFR\n", __func__);
 		i40e_do_reset(pf, (1 << __I40E_PF_RESET_REQUESTED));
 
 	} else if (strncmp(cmd_buf, "corer", 5) == 0) {
-		dev_info(&pf->pdev->dev, "%s: forcing CoreR\n", __func__);
+		pf_info(pf, "%s: forcing CoreR\n", __func__);
 		i40e_do_reset(pf, (1 << __I40E_CORE_RESET_REQUESTED));
 
 	} else if (strncmp(cmd_buf, "globr", 5) == 0) {
-		dev_info(&pf->pdev->dev, "%s: forcing GlobR\n", __func__);
+		pf_info(pf, "%s: forcing GlobR\n", __func__);
 		i40e_do_reset(pf, (1 << __I40E_GLOBAL_RESET_REQUESTED));
 
 	} else if (strncmp(cmd_buf, "read", 4) == 0) {
@@ -1549,40 +1378,39 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		u32 value;
 		cnt = sscanf(&cmd_buf[4], "%x", &address);
 		if (cnt != 1) {
-			dev_info(&pf->pdev->dev, "%s: read <reg>\n", __func__);
+			pf_info(pf, "%s: read <reg>\n", __func__);
 			goto command_write_done;
 		}
 
 		/* check the range on address */
 		if (address >= I40E_MAX_REGISTER) {
-			dev_info(&pf->pdev->dev, "%s: read reg address 0x%08x too large\n",
-				 __func__, address);
+			pf_info(pf, "%s: read reg address 0x%08x too large\n",
+				__func__, address);
 			goto command_write_done;
 		}
 
 		value = rd32(&pf->hw, address);
-		dev_info(&pf->pdev->dev, "%s: read: 0x%08x = 0x%08x\n",
-			 __func__, address, value);
+		pf_info(pf, "%s: read: 0x%08x = 0x%08x\n",
+			__func__, address, value);
 
 	} else if (strncmp(cmd_buf, "write", 5) == 0) {
 		u32 address, value;
 		cnt = sscanf(&cmd_buf[5], "%x %x", &address, &value);
 		if (cnt != 2) {
-			dev_info(&pf->pdev->dev, "%s: write <reg> <value>\n",
-				 __func__);
+			pf_info(pf, "%s: write <reg> <value>\n", __func__);
 			goto command_write_done;
 		}
 
 		/* check the range on address */
 		if (address >= I40E_MAX_REGISTER) {
-			dev_info(&pf->pdev->dev, "%s: write reg address 0x%08x too large\n",
-				 __func__, address);
+			pf_info(pf, "%s: write reg address 0x%08x too large\n",
+				__func__, address);
 			goto command_write_done;
 		}
 		wr32(&pf->hw, address, value);
 		value = rd32(&pf->hw, address);
-		dev_info(&pf->pdev->dev, "%s: write: 0x%08x = 0x%08x\n",
-			 __func__, address, value);
+		pf_info(pf, "%s: write: 0x%08x = 0x%08x\n",
+			__func__, address, value);
 	} else if (strncmp(cmd_buf, "clear_stats", 11) == 0) {
 		if (strncmp(&cmd_buf[12], "vsi", 3) == 0) {
 			cnt = sscanf(&cmd_buf[15], "%d", &vsi_seid);
@@ -1590,34 +1418,28 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 				int i;
 				for (i = 0; i < pf->hw.func_caps.num_vsis; i++)
 					i40e_vsi_reset_stats(pf->vsi[i]);
-				dev_info(&pf->pdev->dev,
-					 "%s: vsi clear stats called for all vsi's\n",
-					 __func__);
+				pf_info(pf, "%s: vsi clear stats called for all vsi's\n",
+					__func__);
 			} else if (cnt == 1) {
 				vsi = i40e_dbg_find_vsi(pf, vsi_seid);
 				if (!vsi) {
-					dev_info(&pf->pdev->dev,
-						 "%s: clear_stats vsi: bad vsi %d\n",
-						 __func__, vsi_seid);
+					pf_info(pf, "%s: clear_stats vsi: bad vsi %d\n",
+						__func__, vsi_seid);
 					goto command_write_done;
 				}
 				i40e_vsi_reset_stats(vsi);
-				dev_info(&pf->pdev->dev,
-					 "%s: vsi clear stats called for vsi %d\n",
-					 __func__, vsi_seid);
+				pf_info(pf, "%s: vsi clear stats called for vsi %d\n",
+					__func__, vsi_seid);
 			} else {
-				dev_info(&pf->pdev->dev,
-					 "%s: clear_stats vsi [seid]\n",
-					 __func__);
+				pf_info(pf, "%s: clear_stats vsi [seid]\n",
+					__func__);
 			}
 		} else if (strncmp(&cmd_buf[12], "pf", 2) == 0) {
 			i40e_pf_reset_stats(pf);
-			dev_info(&pf->pdev->dev,
-				 "%s: pf clear stats called\n", __func__);
+			pf_info(pf, "%s: pf clear stats called\n", __func__);
 		} else {
-			dev_info(&pf->pdev->dev,
-				 "%s: clear_stats vsi [seid] or clear_stats pf\n",
-				 __func__);
+			pf_info(pf, "%s: clear_stats vsi [seid] or clear_stats pf\n",
+				__func__);
 		}
 	} else if ((strncmp(cmd_buf, "add fd_filter", 13) == 0) ||
 		   (strncmp(cmd_buf, "rem fd_filter", 13) == 0)) {
@@ -1651,9 +1473,8 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			     &fd_data.fd_status, &fd_data.cnt_index,
 			     &fd_data.fd_id, &packet_len, asc_packet);
 		if (cnt != 10) {
-			dev_info(&pf->pdev->dev,
-				 "%s: program fd_filter: bad command string, cnt=%d\n",
-				 __func__, cnt);
+			pf_info(pf, "%s: program fd_filter: bad command string, cnt=%d\n",
+				__func__, cnt);
 			kfree(asc_packet);
 			asc_packet = NULL;
 			kfree(fd_data.raw_packet);
@@ -1668,8 +1489,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		packet_len = min_t(u16,
 				   packet_len, I40E_FDIR_MAX_RAW_PACKET_LOOKUP);
 
-		dev_info(&pf->pdev->dev,
-			 "%s: FD raw packet:\n", __func__);
+		pf_info(pf, "%s: FD raw packet:\n", __func__);
 		for (i = 0; i < packet_len; i++) {
 			sscanf(&asc_packet[j], "%2hhx ",
 			       &fd_data.raw_packet[i]);
@@ -1681,16 +1501,14 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 				print_buf++;
 			}
 		}
-		dev_info(&pf->pdev->dev, "%s\n", print_buf_start);
+		pf_info(pf, "%s\n", print_buf_start);
 		ret = i40e_program_fdir_filter(&fd_data, pf, add);
 		if (!ret) {
-			dev_info(&pf->pdev->dev,
-				 "%s: Filter command send Status : Success\n",
-				 __func__);
+			pf_info(pf, "%s: Filter command send Status : Success\n",
+				__func__);
 		} else {
-			dev_info(&pf->pdev->dev,
-				 "%s: Filter command send failed %d\n",
-				 __func__, ret);
+			pf_info(pf, "%s: Filter command send failed %d\n",
+				__func__, ret);
 		}
 		kfree(fd_data.raw_packet);
 		fd_data.raw_packet = NULL;
@@ -1701,18 +1519,16 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			int ret;
 			ret = i40e_aq_stop_lldp(&pf->hw, false, NULL);
 			if (ret) {
-				dev_info(&pf->pdev->dev,
-					 "%s: Stop LLDP AQ command failed =0x%x\n",
-					 __func__, pf->hw.aq.asq_last_status);
+				pf_info(pf, "%s: Stop LLDP AQ command failed =0x%x\n",
+					__func__, pf->hw.aq.asq_last_status);
 				goto command_write_done;
 			}
 		} else if (strncmp(&cmd_buf[5], "start", 5) == 0) {
 			int ret;
 			ret = i40e_aq_start_lldp(&pf->hw, NULL);
 			if (ret) {
-				dev_info(&pf->pdev->dev,
-					 "%s: Start LLDP AQ command failed =0x%x\n",
-					 __func__, pf->hw.aq.asq_last_status);
+				pf_info(pf, "%s: Start LLDP AQ command failed =0x%x\n",
+					__func__, pf->hw.aq.asq_last_status);
 				goto command_write_done;
 			}
 		} else if (strncmp(&cmd_buf[5],
@@ -1729,16 +1545,14 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 						   buff, I40E_LLDPDU_SIZE,
 						   &llen, &rlen, NULL);
 			if (ret) {
-				dev_info(&pf->pdev->dev,
-					 "%s: Get LLDP MIB (local) AQ command failed =0x%x\n",
-					 __func__, pf->hw.aq.asq_last_status);
+				pf_info(pf, "%s: Get LLDP MIB (local) AQ command failed =0x%x\n",
+					__func__, pf->hw.aq.asq_last_status);
 				kfree(buff);
 				buff = NULL;
 				goto command_write_done;
 			}
-			dev_info(&pf->pdev->dev,
-				 "%s: Get LLDP MIB (local) AQ buffer written back:\n",
-				 __func__);
+			pf_info(pf, "%s: Get LLDP MIB (local) AQ buffer written back:\n",
+				__func__);
 			for (i = 0; i < I40E_LLDPDU_SIZE; i++) {
 				snprintf(print_buf, 3, "%02x ", buff[i]);
 				print_buf += 3;
@@ -1747,7 +1561,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 					print_buf++;
 				}
 			}
-			dev_info(&pf->pdev->dev, "%s\n", print_buf_start);
+			pf_info(pf, "%s\n", print_buf_start);
 			kfree(buff);
 			buff = NULL;
 		} else if (strncmp(&cmd_buf[5], "get remote", 10) == 0) {
@@ -1764,16 +1578,14 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 					buff, I40E_LLDPDU_SIZE,
 					&llen, &rlen, NULL);
 			if (ret) {
-				dev_info(&pf->pdev->dev,
-					 "%s: Get LLDP MIB (remote) AQ command failed =0x%x\n",
-					 __func__, pf->hw.aq.asq_last_status);
+				pf_info(pf, "%s: Get LLDP MIB (remote) AQ command failed =0x%x\n",
+					__func__, pf->hw.aq.asq_last_status);
 				kfree(buff);
 				buff = NULL;
 				goto command_write_done;
 			}
-			dev_info(&pf->pdev->dev,
-				 "%s: Get LLDP MIB (remote) AQ buffer written back:\n",
-				 __func__);
+			pf_info(pf, "%s: Get LLDP MIB (remote) AQ buffer written back:\n",
+				__func__);
 			for (i = 0; i < I40E_LLDPDU_SIZE; i++) {
 				snprintf(print_buf, 3, "%02x ", buff[i]);
 				print_buf += 3;
@@ -1782,7 +1594,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 					print_buf++;
 				}
 			}
-			dev_info(&pf->pdev->dev, "%s\n", print_buf_start);
+			pf_info(pf, "%s\n", print_buf_start);
 			kfree(buff);
 			buff = NULL;
 		} else if (strncmp(&cmd_buf[5], "event on", 8) == 0) {
@@ -1790,9 +1602,8 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			ret = i40e_aq_cfg_lldp_mib_change_event(&pf->hw,
 								true, NULL);
 			if (ret) {
-				dev_info(&pf->pdev->dev,
-					 "%s: Config LLDP MIB Change Event (on) AQ command failed =0x%x\n",
-					 __func__, pf->hw.aq.asq_last_status);
+				pf_info(pf, "%s: Config LLDP MIB Change Event (on) AQ command failed =0x%x\n",
+					__func__, pf->hw.aq.asq_last_status);
 				goto command_write_done;
 			}
 		} else if (strncmp(&cmd_buf[5], "event off", 9) == 0) {
@@ -1800,9 +1611,8 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			ret = i40e_aq_cfg_lldp_mib_change_event(&pf->hw,
 								false, NULL);
 			if (ret) {
-				dev_info(&pf->pdev->dev,
-					 "%s: Config LLDP MIB Change Event (off) AQ command failed =0x%x\n",
-					 __func__, pf->hw.aq.asq_last_status);
+				pf_info(pf, "%s: Config LLDP MIB Change Event (off) AQ command failed =0x%x\n",
+					__func__, pf->hw.aq.asq_last_status);
 				goto command_write_done;
 			}
 		}
@@ -1825,9 +1635,8 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		} else if (cnt == 2) {
 			buffer_len = 0;
 		} else if (cnt > 3) {
-			dev_info(&pf->pdev->dev,
-				 "%s: nvm read: bad command string, cnt=%d\n",
-				 __func__, cnt);
+			pf_info(pf, "%s: nvm read: bad command string, cnt=%d\n",
+				__func__, cnt);
 			goto command_write_done;
 		}
 
@@ -1842,9 +1651,8 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 
 		ret = i40e_acquire_nvm(&pf->hw, I40E_RESOURCE_READ);
 		if (ret) {
-			dev_info(&pf->pdev->dev,
-				 "%s: Failed Acquiring NVM resource for read err=%d status=0x%x\n",
-				 __func__, ret, pf->hw.aq.asq_last_status);
+			pf_info(pf, "%s: Failed Acquiring NVM resource for read err=%d status=0x%x\n",
+				__func__, ret, pf->hw.aq.asq_last_status);
 			kfree(buff);
 			goto command_write_done;
 		}
@@ -1853,13 +1661,11 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 				       bytes, (u8 *)buff, true, NULL);
 		i40e_release_nvm(&pf->hw);
 		if (ret) {
-			dev_info(&pf->pdev->dev,
-				 "%s: Read NVM AQ failed err=%d status=0x%x\n",
-				 __func__, ret, pf->hw.aq.asq_last_status);
+			pf_info(pf, "%s: Read NVM AQ failed err=%d status=0x%x\n",
+				__func__, ret, pf->hw.aq.asq_last_status);
 		} else {
-			dev_info(&pf->pdev->dev,
-				 "%s: Read NVM module=0x%x offset=0x%x words=%d\n",
-				 __func__, module, offset, buffer_len);
+			pf_info(pf, "%s: Read NVM module=0x%x offset=0x%x words=%d\n",
+				__func__, module, offset, buffer_len);
 			for (i = 0; i < buffer_len; i++) {
 				if ((i % 16) == 0) {
 					snprintf(print_buf, 11, "\n0x%08x: ",
@@ -1869,71 +1675,53 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 				snprintf(print_buf, 5, "%04x ", buff[i]);
 				print_buf += 5;
 			}
-			dev_info(&pf->pdev->dev, "%s\n", print_buf_start);
+			pf_info(pf, "%s\n", print_buf_start);
 		}
 		kfree(buff);
 		buff = NULL;
 	} else {
-		dev_info(&pf->pdev->dev, "%s: unknown command '%s'\n",
-			 __func__, cmd_buf);
-		dev_info(&pf->pdev->dev,
-			 "%s: available commands\n", __func__);
-		dev_info(&pf->pdev->dev,
-			 "%s:   add vsi [relay_seid]\n", __func__);
-		dev_info(&pf->pdev->dev,
-			 "%s:   del vsi [vsi_seid]\n", __func__);
-		dev_info(&pf->pdev->dev,
-			 "%s:   add relay <uplink_seid> <vsi_seid>\n",
-			 __func__);
-		dev_info(&pf->pdev->dev,
-			 "%s:   del relay <relay_seid>\n", __func__);
-		dev_info(&pf->pdev->dev,
-			 "%s:   add macaddr <vsi_seid> <aa:bb:cc:dd:ee:ff> [vlan]\n",
-			 __func__);
-		dev_info(&pf->pdev->dev,
-			 "%s:   del macaddr <vsi_seid> <aa:bb:cc:dd:ee:ff> [vlan]\n",
-			 __func__);
-		dev_info(&pf->pdev->dev, "%s:   add pvid <vsi_seid> <vid>\n",
-			 __func__);
-		dev_info(&pf->pdev->dev, "%s:   del pvid <vsi_seid>\n",
-			 __func__);
-		dev_info(&pf->pdev->dev, "%s:   dump switch\n", __func__);
-		dev_info(&pf->pdev->dev, "%s:   dump vsi [seid]\n", __func__);
-		dev_info(&pf->pdev->dev,
-			 "%s:   dump desc tx <vsi_seid> <ring_id> [<desc_n>]\n",
-			 __func__);
-		dev_info(&pf->pdev->dev,
-			 "%s:   dump desc rx <vsi_seid> <ring_id> [<desc_n>]\n",
-			 __func__);
-		dev_info(&pf->pdev->dev, "%s:   dump desc aq\n", __func__);
-		dev_info(&pf->pdev->dev, "%s:   dump stats\n", __func__);
-		dev_info(&pf->pdev->dev, "%s:   dump reset stats\n", __func__);
-		dev_info(&pf->pdev->dev,
-			 "%s:   msg_enable [level]\n", __func__);
-		dev_info(&pf->pdev->dev, "%s:   read <reg>\n", __func__);
-		dev_info(&pf->pdev->dev,
-			 "%s:   write <reg> <value>\n", __func__);
-		dev_info(&pf->pdev->dev,
-			 "%s:   clear_stats vsi [seid]\n", __func__);
-		dev_info(&pf->pdev->dev, "%s:   clear_stats pf\n", __func__);
-		dev_info(&pf->pdev->dev, "%s:   pfr\n", __func__);
-		dev_info(&pf->pdev->dev, "%s:   corer\n", __func__);
-		dev_info(&pf->pdev->dev, "%s:   globr\n", __func__);
-		dev_info(&pf->pdev->dev,
-			 "%s:   add fd_filter <dest q_index> <flex_off> <pctype> <dest_vsi> <dest_ctl> <fd_status> <cnt_index> <fd_id> <packet_len> <packet>\n",
-			 __func__);
-		dev_info(&pf->pdev->dev,
-			 "%s:   rem fd_filter <dest q_index> <flex_off> <pctype> <dest_vsi> <dest_ctl> <fd_status> <cnt_index> <fd_id> <packet_len> <packet>\n",
-			 __func__);
-		dev_info(&pf->pdev->dev, "%s:   lldp start\n", __func__);
-		dev_info(&pf->pdev->dev, "%s:   lldp stop\n", __func__);
-		dev_info(&pf->pdev->dev, "%s:   lldp get local\n", __func__);
-		dev_info(&pf->pdev->dev, "%s:   lldp get remote\n", __func__);
-		dev_info(&pf->pdev->dev, "%s:   lldp event on\n", __func__);
-		dev_info(&pf->pdev->dev, "%s:   lldp event off\n", __func__);
-		dev_info(&pf->pdev->dev,
-			 "%s:   nvm read [module] [word_offset] [word_count]\n",
-			 __func__);
+		pf_info(pf, "%s: unknown command '%s'\n", __func__, cmd_buf);
+		pf_info(pf, "%s: available commands\n", __func__);
+		pf_info(pf, "%s:   add vsi [relay_seid]\n", __func__);
+		pf_info(pf, "%s:   del vsi [vsi_seid]\n", __func__);
+		pf_info(pf, "%s:   add relay <uplink_seid> <vsi_seid>\n",
+			__func__);
+		pf_info(pf, "%s:   del relay <relay_seid>\n", __func__);
+		pf_info(pf, "%s:   add macaddr <vsi_seid> <aa:bb:cc:dd:ee:ff> [vlan]\n",
+			__func__);
+		pf_info(pf, "%s:   del macaddr <vsi_seid> <aa:bb:cc:dd:ee:ff> [vlan]\n",
+			__func__);
+		pf_info(pf, "%s:   add pvid <vsi_seid> <vid>\n", __func__);
+		pf_info(pf, "%s:   del pvid <vsi_seid>\n", __func__);
+		pf_info(pf, "%s:   dump switch\n", __func__);
+		pf_info(pf, "%s:   dump vsi [seid]\n", __func__);
+		pf_info(pf, "%s:   dump desc tx <vsi_seid> <ring_id> [<desc_n>]\n",
+			__func__);
+		pf_info(pf, "%s:   dump desc rx <vsi_seid> <ring_id> [<desc_n>]\n",
+			__func__);
+		pf_info(pf, "%s:   dump desc aq\n", __func__);
+		pf_info(pf, "%s:   dump stats\n", __func__);
+		pf_info(pf, "%s:   dump reset stats\n", __func__);
+		pf_info(pf, "%s:   msg_enable [level]\n", __func__);
+		pf_info(pf, "%s:   read <reg>\n", __func__);
+		pf_info(pf, "%s:   write <reg> <value>\n", __func__);
+		pf_info(pf, "%s:   clear_stats vsi [seid]\n", __func__);
+		pf_info(pf, "%s:   clear_stats pf\n", __func__);
+		pf_info(pf, "%s:   pfr\n", __func__);
+		pf_info(pf, "%s:   corer\n", __func__);
+		pf_info(pf, "%s:   globr\n", __func__);
+		pf_info(pf, "%s:   add fd_filter <dest q_index> <flex_off> <pctype> <dest_vsi> <dest_ctl> <fd_status> <cnt_index> <fd_id> <packet_len> <packet>\n",
+			__func__);
+		pf_info(pf, "%s:   rem fd_filter <dest q_index> <flex_off> <pctype> <dest_vsi> <dest_ctl> <fd_status> <cnt_index> <fd_id> <packet_len> <packet>\n",
+			__func__);
+		pf_info(pf, "%s:   lldp start\n", __func__);
+		pf_info(pf, "%s:   lldp stop\n", __func__);
+		pf_info(pf, "%s:   lldp get local\n", __func__);
+		pf_info(pf, "%s:   lldp get remote\n", __func__);
+		pf_info(pf, "%s:   lldp event on\n", __func__);
+		pf_info(pf, "%s:   lldp event off\n", __func__);
+		pf_info(pf, "%s:   nvm read [module] [word_offset] [word_count]\n",
+			__func__);
 	}
 
 command_write_done:
@@ -2034,106 +1822,92 @@ static ssize_t i40e_dbg_netdev_ops_write(struct file *filp,
 	if (strncmp(i40e_dbg_netdev_ops_buf, "tx_timeout", 10) == 0) {
 		cnt = sscanf(&i40e_dbg_netdev_ops_buf[11], "%i", &vsi_seid);
 		if (cnt != 1) {
-			dev_info(&pf->pdev->dev,
-				 "%s: tx_timeout <vsi_seid>\n", __func__);
+			pf_info(pf, "%s: tx_timeout <vsi_seid>\n", __func__);
 			goto netdev_ops_write_done;
 		}
 		vsi = i40e_dbg_find_vsi(pf, vsi_seid);
 		if (!vsi) {
-			dev_info(&pf->pdev->dev,
-				 "%s: tx_timeout: VSI %d not found\n",
-				 __func__, vsi_seid);
+			pf_info(pf, "%s: tx_timeout: VSI %d not found\n",
+				__func__, vsi_seid);
 			goto netdev_ops_write_done;
 		}
 		if (rtnl_trylock()) {
 			vsi->netdev->netdev_ops->ndo_tx_timeout(vsi->netdev);
 			rtnl_unlock();
-			dev_info(&pf->pdev->dev, "%s: tx_timeout called\n",
-				 __func__);
+			pf_info(pf, "%s: tx_timeout called\n", __func__);
 		} else {
-			dev_info(&pf->pdev->dev, "%s: Could not acquire RTNL - please try again\n",
-				 __func__);
+			pf_info(pf, "%s: Could not acquire RTNL - please try again\n",
+				__func__);
 		}
 	} else if (strncmp(i40e_dbg_netdev_ops_buf, "change_mtu", 10) == 0) {
 		int mtu;
 		cnt = sscanf(&i40e_dbg_netdev_ops_buf[11], "%i %i",
 			     &vsi_seid, &mtu);
 		if (cnt != 2) {
-			dev_info(&pf->pdev->dev,
-				 "%s: change_mtu <vsi_seid> <mtu>\n", __func__);
+			pf_info(pf, "%s: change_mtu <vsi_seid> <mtu>\n",
+				__func__);
 			goto netdev_ops_write_done;
 		}
 		vsi = i40e_dbg_find_vsi(pf, vsi_seid);
 		if (!vsi) {
-			dev_info(&pf->pdev->dev,
-				 "%s: change_mtu: VSI %d not found\n",
-				 __func__, vsi_seid);
+			pf_info(pf, "%s: change_mtu: VSI %d not found\n",
+				__func__, vsi_seid);
 			goto netdev_ops_write_done;
 		}
 		if (rtnl_trylock()) {
 			vsi->netdev->netdev_ops->ndo_change_mtu(vsi->netdev,
 								mtu);
 			rtnl_unlock();
-			dev_info(&pf->pdev->dev, "%s: change_mtu called\n",
-				 __func__);
+			pf_info(pf, "%s: change_mtu called\n", __func__);
 		} else {
-			dev_info(&pf->pdev->dev, "%s: Could not acquire RTNL - please try again\n",
-				 __func__);
+			pf_info(pf, "%s: Could not acquire RTNL - please try again\n",
+				__func__);
 		}
 
 	} else if (strncmp(i40e_dbg_netdev_ops_buf, "set_rx_mode", 11) == 0) {
 		cnt = sscanf(&i40e_dbg_netdev_ops_buf[11], "%i", &vsi_seid);
 		if (cnt != 1) {
-			dev_info(&pf->pdev->dev,
-				 "%s: set_rx_mode <vsi_seid>\n", __func__);
+			pf_info(pf, "%s: set_rx_mode <vsi_seid>\n", __func__);
 			goto netdev_ops_write_done;
 		}
 		vsi = i40e_dbg_find_vsi(pf, vsi_seid);
 		if (!vsi) {
-			dev_info(&pf->pdev->dev,
-				 "%s: set_rx_mode: VSI %d not found\n",
-				 __func__, vsi_seid);
+			pf_info(pf, "%s: set_rx_mode: VSI %d not found\n",
+				__func__, vsi_seid);
 			goto netdev_ops_write_done;
 		}
 		if (rtnl_trylock()) {
 			vsi->netdev->netdev_ops->ndo_set_rx_mode(vsi->netdev);
 			rtnl_unlock();
-			dev_info(&pf->pdev->dev, "%s: set_rx_mode called\n",
-				 __func__);
+			pf_info(pf, "%s: set_rx_mode called\n", __func__);
 		} else {
-			dev_info(&pf->pdev->dev, "%s: Could not acquire RTNL - please try again\n",
-				 __func__);
+			pf_info(pf, "%s: Could not acquire RTNL - please try again\n",
+				__func__);
 		}
 
 	} else if (strncmp(i40e_dbg_netdev_ops_buf, "napi", 4) == 0) {
 		cnt = sscanf(&i40e_dbg_netdev_ops_buf[4], "%i", &vsi_seid);
 		if (cnt != 1) {
-			dev_info(&pf->pdev->dev,
-				 "%s: napi <vsi_seid>\n", __func__);
+			pf_info(pf, "%s: napi <vsi_seid>\n", __func__);
 			goto netdev_ops_write_done;
 		}
 		vsi = i40e_dbg_find_vsi(pf, vsi_seid);
 		if (!vsi) {
-			dev_info(&pf->pdev->dev, "%s: napi: VSI %d not found\n",
-				 __func__, vsi_seid);
+			pf_info(pf, "%s: napi: VSI %d not found\n",
+				__func__, vsi_seid);
 			goto netdev_ops_write_done;
 		}
 		for (i = 0; i < vsi->num_q_vectors; i++)
 			napi_schedule(&vsi->q_vectors[i].napi);
-		dev_info(&pf->pdev->dev, "%s: napi called\n", __func__);
+		pf_info(pf, "%s: napi called\n", __func__);
 	} else {
-		dev_info(&pf->pdev->dev, "%s: unknown command '%s'\n",
-			 __func__, i40e_dbg_netdev_ops_buf);
-		dev_info(&pf->pdev->dev,
-			 "%s: available commands\n", __func__);
-		dev_info(&pf->pdev->dev,
-			 "%s:    tx_timeout <vsi_seid>\n", __func__);
-		dev_info(&pf->pdev->dev,
-			 "%s:    change_mtu <vsi_seid> <mtu>\n", __func__);
-		dev_info(&pf->pdev->dev,
-			 "%s:    set_rx_mode <vsi_seid>\n", __func__);
-		dev_info(&pf->pdev->dev,
-			 "%s:    napi <vsi_seid>\n", __func__);
+		pf_info(pf, "%s: unknown command '%s'\n",
+			__func__, i40e_dbg_netdev_ops_buf);
+		pf_info(pf, "%s: available commands\n", __func__);
+		pf_info(pf, "%s:    tx_timeout <vsi_seid>\n", __func__);
+		pf_info(pf, "%s:    change_mtu <vsi_seid> <mtu>\n", __func__);
+		pf_info(pf, "%s:    set_rx_mode <vsi_seid>\n", __func__);
+		pf_info(pf, "%s:    napi <vsi_seid>\n", __func__);
 	}
 netdev_ops_write_done:
 	return count;
@@ -2164,8 +1938,8 @@ void i40e_dbg_pf_init(struct i40e_pf *pf)
 		pfile = debugfs_create_file("netdev_ops", 0600, pf->i40e_dbg_pf,
 					    pf, &i40e_dbg_netdev_ops_fops);
 	} else {
-		dev_info(&pf->pdev->dev,
-			 "%s: debugfs entry for %s failed\n", __func__, name);
+		pf_info(pf, "%s: debugfs entry for %s failed\n",
+			__func__, name);
 	}
 }
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index f66bc46..87093da 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1164,15 +1164,12 @@ static i40e_status i40e_add_del_fdir_udpv4(struct i40e_vsi *vsi,
 		ret = i40e_program_fdir_filter(fd_data, pf, add);
 
 		if (ret != I40E_SUCCESS) {
-			dev_info(&pf->pdev->dev,
-				 "%s: Filter command send failed for PCTYPE %d (ret = %d)\n",
+			pf_info(pf, "%s: Filter command send failed for PCTYPE %d (ret = %d)\n",
 				__func__, fd_data->pctype, ret);
 			err = true;
 		} else {
-			dev_info(&pf->pdev->dev,
-				 "%s: Filter OK for PCTYPE %d (ret = %d)\n",
-				 __func__,
-				fd_data->pctype, ret);
+			pf_info(pf, "%s: Filter OK for PCTYPE %d (ret = %d)\n",
+				__func__, fd_data->pctype, ret);
 		}
 	}
 
@@ -1210,13 +1207,12 @@ static i40e_status i40e_add_del_fdir_tcpv4(struct i40e_vsi *vsi,
 	ret = i40e_program_fdir_filter(fd_data, pf, add);
 
 	if (ret != I40E_SUCCESS) {
-		dev_info(&pf->pdev->dev,
-			 "%s: Filter command send failed for PCTYPE %d (ret = %d)\n",
-			 __func__, fd_data->pctype, ret);
+		pf_info(pf, "%s: Filter command send failed for PCTYPE %d (ret = %d)\n",
+			__func__, fd_data->pctype, ret);
 			err = true;
 	} else {
-		dev_info(&pf->pdev->dev, "%s: Filter OK for PCTYPE %d (ret = %d)\n",
-			 __func__, fd_data->pctype, ret);
+		pf_info(pf, "%s: Filter OK for PCTYPE %d (ret = %d)\n",
+			__func__, fd_data->pctype, ret);
 	}
 
 	ip->saddr = fsp->h_u.tcp_ip4_spec.ip4src;
@@ -1225,14 +1221,12 @@ static i40e_status i40e_add_del_fdir_tcpv4(struct i40e_vsi *vsi,
 	fd_data->pctype = I40E_FILTER_PCTYPE_NONF_IPV4_TCP;
 
 	if (ret != I40E_SUCCESS) {
-		dev_info(&pf->pdev->dev,
-			 "%s: Filter command send failed for PCTYPE %d (ret = %d)\n",
+		pf_info(pf, "%s: Filter command send failed for PCTYPE %d (ret = %d)\n",
 			__func__, fd_data->pctype, ret);
 			err = true;
 	} else {
-		dev_info(&pf->pdev->dev,
-			 "%s: Filter OK for PCTYPE %d (ret = %d)\n",
-			 __func__, fd_data->pctype, ret);
+		pf_info(pf, "%s: Filter OK for PCTYPE %d (ret = %d)\n",
+			__func__, fd_data->pctype, ret);
 	}
 
 	return err ? -EOPNOTSUPP : I40E_SUCCESS;
@@ -1288,14 +1282,12 @@ static i40e_status i40e_add_del_fdir_ipv4(struct i40e_vsi *vsi,
 		ret = i40e_program_fdir_filter(fd_data, pf, add);
 
 		if (ret != I40E_SUCCESS) {
-			dev_info(&pf->pdev->dev,
-				 "%s: Filter command send failed for PCTYPE %d (ret = %d)\n",
+			pf_info(pf, "%s: Filter command send failed for PCTYPE %d (ret = %d)\n",
 				__func__, fd_data->pctype, ret);
 				err = true;
 		} else {
-			dev_info(&pf->pdev->dev,
-				 "%s: Filter OK for PCTYPE %d (ret = %d)\n",
-				 __func__, fd_data->pctype, ret);
+			pf_info(pf, "%s: Filter OK for PCTYPE %d (ret = %d)\n",
+				__func__, fd_data->pctype, ret);
 		}
 	}
 
@@ -1336,8 +1328,7 @@ static int i40e_add_del_fdir_ethtool(struct i40e_vsi *vsi,
 				     GFP_KERNEL);
 
 	if (!fd_data.raw_packet) {
-		dev_info(&pf->pdev->dev,
-			 "%s: Could not allocate memory\n", __func__);
+		pf_info(pf, "%s: Could not allocate memory\n", __func__);
 		return -ENOMEM;
 	}
 
@@ -1380,8 +1371,7 @@ static int i40e_add_del_fdir_ethtool(struct i40e_vsi *vsi,
 		}
 		break;
 	default:
-		dev_info(&pf->pdev->dev, "%s: Could not specify spec type\n",
-			 __func__);
+		pf_info(pf, "%s: Could not specify spec type\n", __func__);
 		ret = -EINVAL;
 	}
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index b0f92f4..f3139f6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -188,9 +188,8 @@ static int i40e_get_lump(struct i40e_pf *pf, struct i40e_lump_tracking *pile,
 	int j = 0;
 
 	if (pile == NULL || needed == 0 || id >= I40E_PILE_VALID_BIT) {
-		dev_info(&pf->pdev->dev,
-			 "%s: param err: pile=%p needed=%d id=0x%04x\n",
-			 __func__, pile, needed, id);
+		pf_info(pf, "%s: param err: pile=%p needed=%d id=0x%04x\n",
+			__func__, pile, needed, id);
 		return I40E_ERR_PARAM;
 	}
 
@@ -1013,8 +1012,8 @@ i40e_status i40e_put_mac_in_vlan(struct i40e_vsi *vsi, u8 *macaddr,
 						is_vf, is_netdev);
 
 			if (NULL == add_f) {
-				dev_info(&vsi->back->pdev->dev, "%s: Could not add filter %d for %pM\n",
-					 __func__, f->vlan, f->macaddr);
+				pf_info(vsi->back, "%s: Could not add filter %d for %pM\n",
+					__func__, f->vlan, f->macaddr);
 				return -ENOMEM;
 			}
 		}
@@ -1219,9 +1218,8 @@ static void i40e_vsi_setup_queue_map(struct i40e_vsi *vsi,
 				numtc++;
 		}
 		if (!numtc) {
-			dev_warn(&pf->pdev->dev,
-				 "%s: DCB is enabled but no TC enabled, forcing TC0\n",
-				 __func__);
+			pf_warn(pf, "%s: DCB is enabled but no TC enabled, forcing TC0\n",
+				__func__);
 			numtc = 1;
 		}
 	} else {
@@ -1471,10 +1469,9 @@ i40e_status i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 				memset(del_list, 0, sizeof(*del_list));
 
 				if (ret != I40E_SUCCESS)
-					dev_info(&pf->pdev->dev,
-						 "%s: ignoring delete macvlan error, err %d, aq_err %d while flashing a full buffer\n",
-						 __func__, ret,
-						 pf->hw.aq.asq_last_status);
+					pf_info(pf, "%s: ignoring delete macvlan error, err %d, aq_err %d while flashing a full buffer\n",
+						__func__, ret,
+						pf->hw.aq.asq_last_status);
 			}
 		}
 		if (num_del) {
@@ -1483,10 +1480,9 @@ i40e_status i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 			num_del = 0;
 
 			if (ret != I40E_SUCCESS)
-				dev_info(&pf->pdev->dev,
-					 "%s: ignoring delete macvlan error, err %d, aq_err %d\n",
-					 __func__, ret,
-					 pf->hw.aq.asq_last_status);
+				pf_info(pf, "%s: ignoring delete macvlan error, err %d, aq_err %d\n",
+					__func__, ret,
+					pf->hw.aq.asq_last_status);
 		}
 
 		kfree(del_list);
@@ -1554,18 +1550,16 @@ i40e_status i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 		if (add_happened && (ret == I40E_SUCCESS)) {
 			/* do nothing */;
 		} else if (add_happened && (ret != I40E_SUCCESS)) {
-			dev_info(&pf->pdev->dev,
-				 "%s: add filter failed, err %d, aq_err %d\n",
-				 __func__, ret, pf->hw.aq.asq_last_status);
+			pf_info(pf, "%s: add filter failed, err %d, aq_err %d\n",
+				__func__, ret, pf->hw.aq.asq_last_status);
 			if ((pf->hw.aq.asq_last_status == I40E_AQ_RC_ENOSPC) &&
 			    !test_bit(__I40E_FILTER_OVERFLOW_PROMISC,
 				      &vsi->state)) {
 				promisc_forced_on = true;
 				set_bit(__I40E_FILTER_OVERFLOW_PROMISC,
 					&vsi->state);
-				dev_info(&pf->pdev->dev,
-					 "%s: promiscuous mode forced on\n",
-					 __func__);
+				pf_info(pf, "%s: promiscuous mode forced on\n",
+					__func__);
 			}
 		}
 	}
@@ -1579,9 +1573,8 @@ i40e_status i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 							    cur_multipromisc,
 							    NULL);
 		if (ret != I40E_SUCCESS)
-			dev_info(&pf->pdev->dev,
-				 "%s: set multi promisc failed, err %d, aq_err %d\n",
-				 __func__, ret, pf->hw.aq.asq_last_status);
+			pf_info(pf, "%s: set multi promisc failed, err %d, aq_err %d\n",
+				__func__, ret, pf->hw.aq.asq_last_status);
 	}
 	if ((changed_flags & IFF_PROMISC) || promisc_forced_on) {
 		bool cur_promisc;
@@ -1593,9 +1586,8 @@ i40e_status i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 							  cur_promisc,
 							  NULL);
 		if (ret != I40E_SUCCESS)
-			dev_info(&pf->pdev->dev,
-				 "%s: set uni promisc failed, err %d, aq_err %d\n",
-				 __func__, ret, pf->hw.aq.asq_last_status);
+			pf_info(pf, "%s: set uni promisc failed, err %d, aq_err %d\n",
+				__func__, ret, pf->hw.aq.asq_last_status);
 	}
 
 	clear_bit(__I40E_CONFIG_BUSY, &vsi->state);
@@ -1669,9 +1661,8 @@ void i40e_vlan_stripping_enable(struct i40e_vsi *vsi)
 	memcpy(&ctxt.info, &vsi->info, sizeof(vsi->info));
 	ret = i40e_aq_update_vsi_params(&vsi->back->hw, &ctxt, NULL);
 	if (ret != I40E_SUCCESS) {
-		dev_info(&vsi->back->pdev->dev,
-			 "%s: update vsi failed, aq_err=%d\n",
-			 __func__, vsi->back->hw.aq.asq_last_status);
+		pf_info(vsi->back, "%s: update vsi failed, aq_err=%d\n",
+			__func__, vsi->back->hw.aq.asq_last_status);
 	}
 }
 
@@ -1698,9 +1689,8 @@ void i40e_vlan_stripping_disable(struct i40e_vsi *vsi)
 	memcpy(&ctxt.info, &vsi->info, sizeof(vsi->info));
 	ret = i40e_aq_update_vsi_params(&vsi->back->hw, &ctxt, NULL);
 	if (ret != I40E_SUCCESS) {
-		dev_info(&vsi->back->pdev->dev,
-			 "%s: update vsi failed, aq_err=%d\n",
-			 __func__, vsi->back->hw.aq.asq_last_status);
+		pf_info(vsi->back, "%s: update vsi failed, aq_err=%d\n",
+			__func__, vsi->back->hw.aq.asq_last_status);
 	}
 }
 
@@ -1738,8 +1728,8 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 		add_f = i40e_add_filter(vsi, vsi->netdev->dev_addr, vid,
 					is_vf, is_netdev);
 		if (add_f == NULL) {
-			dev_info(&vsi->back->pdev->dev, "%s: Could not add vlan filter %d for %pM\n",
-				 __func__, vid, vsi->netdev->dev_addr);
+			pf_info(vsi->back, "%s: Could not add vlan filter %d for %pM\n",
+				__func__, vid, vsi->netdev->dev_addr);
 			return -ENOMEM;
 		}
 	}
@@ -1748,16 +1738,16 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 		add_f = i40e_add_filter(vsi, f->macaddr, vid,
 					is_vf, is_netdev);
 		if (add_f == NULL) {
-			dev_info(&vsi->back->pdev->dev, "%s: Could not add vlan filter %d for %pM\n",
-				 __func__, vid, f->macaddr);
+			pf_info(vsi->back, "%s: Could not add vlan filter %d for %pM\n",
+				__func__, vid, f->macaddr);
 			return -ENOMEM;
 		}
 	}
 
 	ret = i40e_sync_vsi_filters(vsi);
 	if (ret != I40E_SUCCESS) {
-		dev_info(&vsi->back->pdev->dev, "%s: Could not sync filters for vid %d\n",
-			 __func__, vid);
+		pf_info(vsi->back, "%s: Could not sync filters for vid %d\n",
+			__func__, vid);
 		return ret;
 	}
 
@@ -1776,8 +1766,8 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 			add_f = i40e_add_filter(vsi, vsi->netdev->dev_addr, 0,
 					    is_vf, is_netdev);
 			if (add_f == NULL) {
-				dev_info(&vsi->back->pdev->dev, "%s: Could not add filter 0 for %pM\n",
-					 __func__, vsi->netdev->dev_addr);
+				pf_info(vsi->back, "%s: Could not add filter 0 for %pM\n",
+					__func__, vsi->netdev->dev_addr);
 				return -ENOMEM;
 			}
 		}
@@ -1790,9 +1780,8 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 				add_f = i40e_add_filter(vsi, f->macaddr,
 					       0, is_vf, is_netdev);
 				if (add_f == NULL) {
-					dev_info(&vsi->back->pdev->dev,
-						 "%s: Could not add filter 0 for %pM\n",
-						 __func__, f->macaddr);
+					pf_info(vsi->back, "%s: Could not add filter 0 for %pM\n",
+						__func__, f->macaddr);
 					return -ENOMEM;
 				}
 			}
@@ -1827,8 +1816,7 @@ int i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
 
 	ret = i40e_sync_vsi_filters(vsi);
 	if (ret != I40E_SUCCESS) {
-		dev_info(&vsi->back->pdev->dev, "%s: Could not sync filters\n",
-			 __func__);
+		pf_info(vsi->back, "%s: Could not sync filters\n", __func__);
 		return ret;
 	}
 
@@ -1854,9 +1842,8 @@ int i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
 		f = i40e_add_filter(vsi, netdev->dev_addr, I40E_VLAN_ANY,
 				    is_vf, is_netdev);
 		if (f == NULL) {
-			dev_info(&vsi->back->pdev->dev, "%s: Could not add filter %d for %pM\n",
-				 __func__, I40E_VLAN_ANY,
-				 netdev->dev_addr);
+			pf_info(vsi->back, "%s: Could not add filter %d for %pM\n",
+				__func__, I40E_VLAN_ANY, netdev->dev_addr);
 			return -ENOMEM;
 		}
 	}
@@ -1867,8 +1854,8 @@ int i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
 			add_f = i40e_add_filter(vsi, f->macaddr, I40E_VLAN_ANY,
 					    is_vf, is_netdev);
 			if (add_f == NULL) {
-				dev_info(&vsi->back->pdev->dev, "%s: Could not add filter %d for %pM\n",
-					 __func__, I40E_VLAN_ANY, f->macaddr);
+				pf_info(vsi->back, "%s: Could not add filter %d for %pM\n",
+					__func__, I40E_VLAN_ANY, f->macaddr);
 				return -ENOMEM;
 			}
 		}
@@ -1968,9 +1955,8 @@ i40e_status i40e_vsi_add_pvid(struct i40e_vsi *vsi, u16 vid)
 	memcpy(&ctxt.info, &vsi->info, sizeof(vsi->info));
 	ret = i40e_aq_update_vsi_params(&vsi->back->hw, &ctxt, NULL);
 	if (ret != I40E_SUCCESS) {
-		dev_info(&vsi->back->pdev->dev,
-			 "%s: update vsi failed, aq_err=%d\n",
-			 __func__, vsi->back->hw.aq.asq_last_status);
+		pf_info(vsi->back, "%s: update vsi failed, aq_err=%d\n",
+			__func__, vsi->back->hw.aq.asq_last_status);
 	}
 
 	return ret;
@@ -2107,18 +2093,16 @@ static s32 i40e_configure_tx_ring(struct i40e_ring *ring)
 	/* clear the context in the HMC */
 	err = i40e_clear_lan_tx_queue_context(hw, pf_q);
 	if (err != I40E_SUCCESS) {
-		dev_info(&vsi->back->pdev->dev,
-			 "%s: Failed to clear LAN Tx queue context on Tx ring %d (pf_q %d), error: %d\n",
-			 __func__, ring->queue_index, pf_q, err);
+		pf_info(vsi->back, "%s: Failed to clear LAN Tx queue context on Tx ring %d (pf_q %d), error: %d\n",
+			__func__, ring->queue_index, pf_q, err);
 		return err;
 	}
 
 	/* set the context in the HMC */
 	err = i40e_set_lan_tx_queue_context(hw, pf_q, &tx_ctx);
 	if (err != I40E_SUCCESS) {
-		dev_info(&vsi->back->pdev->dev,
-			 "%s: Failed to set LAN Tx queue context on Tx ring %d (pf_q %d, error: %d\n",
-			 __func__, ring->queue_index, pf_q, err);
+		pf_info(vsi->back, "%s: Failed to set LAN Tx queue context on Tx ring %d (pf_q %d, error: %d\n",
+			__func__, ring->queue_index, pf_q, err);
 		return err;
 	}
 
@@ -2198,18 +2182,16 @@ static s32 i40e_configure_rx_ring(struct i40e_ring *ring)
 	/* clear the context in the HMC */
 	err = i40e_clear_lan_rx_queue_context(hw, pf_q);
 	if (err != I40E_SUCCESS) {
-		dev_info(&vsi->back->pdev->dev,
-			 "%s: Failed to clear LAN Rx queue context on Rx ring %d (pf_q %d), error: %d\n",
-			 __func__, ring->queue_index, pf_q, err);
+		pf_info(vsi->back, "%s: Failed to clear LAN Rx queue context on Rx ring %d (pf_q %d), error: %d\n",
+			__func__, ring->queue_index, pf_q, err);
 		return err;
 	}
 
 	/* set the context in the HMC */
 	err = i40e_set_lan_rx_queue_context(hw, pf_q, &rx_ctx);
 	if (err != I40E_SUCCESS) {
-		dev_info(&vsi->back->pdev->dev,
-			 "%s: Failed to set LAN Rx queue context on Rx ring %d (pf_q %d), error: %d\n",
-			 __func__, ring->queue_index, pf_q, err);
+		pf_info(vsi->back, "%s: Failed to set LAN Rx queue context on Rx ring %d (pf_q %d), error: %d\n",
+			__func__, ring->queue_index, pf_q, err);
 		return err;
 	}
 
@@ -2586,9 +2568,8 @@ static int i40e_vsi_request_irq_msix(struct i40e_vsi *vsi, char *basename)
 				  q_vector->name,
 				  q_vector);
 		if (err) {
-			dev_info(&pf->pdev->dev,
-				 "%s: request_irq failed, error: %d\n",
-				 __func__, err);
+			pf_info(pf, "%s: request_irq failed, error: %d\n",
+				__func__, err);
 			goto free_queue_irqs;
 		}
 		/* assign the mask for this irq */
@@ -2774,17 +2755,15 @@ static irqreturn_t i40e_intr(int irq, void *data)
 	 */
 	icr0_remaining = icr0 & ena_mask;
 	if (icr0_remaining) {
-		dev_info(&pf->pdev->dev,
-			 "%s: unhandled interrupt icr0=0x%08x\n",
-			 __func__, icr0_remaining);
+		pf_info(pf, "%s: unhandled interrupt icr0=0x%08x\n",
+			__func__, icr0_remaining);
 		if ((icr0_remaining & I40E_PFINT_ICR0_HMC_ERR_MASK) ||
 		    (icr0_remaining & I40E_PFINT_ICR0_PE_CRITERR_MASK) ||
 		    (icr0_remaining & I40E_PFINT_ICR0_PCI_EXCEPTION_MASK) ||
 		    (icr0_remaining & I40E_PFINT_ICR0_ECC_ERR_MASK) ||
 		    (icr0_remaining & I40E_PFINT_ICR0_MAL_DETECT_MASK)) {
-			dev_info(&pf->pdev->dev,
-				 "%s: error: device will be reset\n",
-				 __func__);
+			pf_info(pf, "%s: error: device will be reset\n",
+				__func__);
 			set_bit(__I40E_PF_RESET_REQUESTED, &pf->state);
 			i40e_service_event_schedule(pf);
 		}
@@ -2892,8 +2871,8 @@ static int i40e_vsi_request_irq(struct i40e_vsi *vsi, char *basename)
 				  basename, pf);
 
 	if (err) {
-		dev_info(&pf->pdev->dev, "%s: request_irq failed, Error %d\n",
-			 __func__, err);
+		pf_info(pf, "%s: request_irq failed, Error %d\n",
+			__func__, err);
 
 		/* place q_vectors and rings back into a known good state */
 		i40e_vsi_unmap_rings_to_vectors(vsi);
@@ -2956,17 +2935,15 @@ static int i40e_vsi_control_tx(struct i40e_vsi *vsi, bool enable)
 		if (enable) {
 			/* is STAT set ? */
 			if ((tx_reg & I40E_QTX_ENA_QENA_STAT_MASK)) {
-				dev_info(&pf->pdev->dev,
-					 "%s: Tx %d already enabled\n",
-					 __func__, i);
+				pf_info(pf, "%s: Tx %d already enabled\n",
+					__func__, i);
 				continue;
 			}
 		} else {
 			/* is !STAT set ? */
 			if (!(tx_reg & I40E_QTX_ENA_QENA_STAT_MASK)) {
-				dev_info(&pf->pdev->dev,
-					 "%s: Tx %d already disabled\n",
-					 __func__, i);
+				pf_info(pf, "%s: Tx %d already disabled\n",
+					__func__, i);
 				continue;
 			}
 		}
@@ -2994,9 +2971,8 @@ static int i40e_vsi_control_tx(struct i40e_vsi *vsi, bool enable)
 			udelay(10);
 		}
 		if (j >= 10) {
-			dev_info(&pf->pdev->dev,
-				 "%s: Tx ring %d %sable timeout\n",
-				 __func__, pf_q, (enable ? "en" : "dis"));
+			pf_info(pf, "%s: Tx ring %d %sable timeout\n",
+				__func__, pf_q, (enable ? "en" : "dis"));
 		}
 	}
 
@@ -3058,9 +3034,8 @@ static int i40e_vsi_control_rx(struct i40e_vsi *vsi, bool enable)
 			udelay(10);
 		}
 		if (j >= 10) {
-			dev_info(&pf->pdev->dev,
-				 "%s: Rx ring %d %sable timeout\n",
-				 __func__, pf_q, (enable ? "en" : "dis"));
+			pf_info(pf, "%s: Rx ring %d %sable timeout\n",
+				__func__, pf_q, (enable ? "en" : "dis"));
 			return I40E_ERR_TIMEOUT;
 		}
 	}
@@ -3499,9 +3474,8 @@ static s32 i40e_vsi_get_bw_info(struct i40e_vsi *vsi)
 	/* Get the VSI level BW configuration */
 	ret = i40e_aq_query_vsi_bw_config(hw, vsi->seid, &bw_config, NULL);
 	if (ret) {
-		dev_info(&pf->pdev->dev,
-			 "%s: couldn't get pf vsi bw config, err %d, aq_err %d\n",
-			 __func__, ret, pf->hw.aq.asq_last_status);
+		pf_info(pf, "%s: couldn't get pf vsi bw config, err %d, aq_err %d\n",
+			__func__, ret, pf->hw.aq.asq_last_status);
 		return ret;
 	}
 
@@ -3510,17 +3484,15 @@ static s32 i40e_vsi_get_bw_info(struct i40e_vsi *vsi)
 					       &bw_ets_config,
 					       NULL);
 	if (ret) {
-		dev_info(&pf->pdev->dev,
-			 "%s: couldn't get pf vsi ets bw config, err %d, aq_err %d\n",
-			 __func__, ret, pf->hw.aq.asq_last_status);
+		pf_info(pf, "%s: couldn't get pf vsi ets bw config, err %d, aq_err %d\n",
+			__func__, ret, pf->hw.aq.asq_last_status);
 		return ret;
 	}
 
 	if (bw_config.tc_valid_bits != bw_ets_config.tc_valid_bits) {
-		dev_info(&pf->pdev->dev,
-			 "%s: Enabled TCs mismatch from querying VSI BW info 0x%08x 0x%08x\n",
-			 __func__, bw_config.tc_valid_bits,
-			 bw_ets_config.tc_valid_bits);
+		pf_info(pf, "%s: Enabled TCs mismatch from querying VSI BW info 0x%08x 0x%08x\n",
+			__func__, bw_config.tc_valid_bits,
+			bw_ets_config.tc_valid_bits);
 		/* Still continuing */
 	}
 
@@ -3560,9 +3532,8 @@ static s32 i40e_vsi_configure_bw_alloc(struct i40e_vsi *vsi,
 	ret = i40e_aq_config_vsi_tc_bw(&vsi->back->hw, vsi->seid,
 				       &bw_data, NULL);
 	if (ret != I40E_SUCCESS) {
-		dev_info(&vsi->back->pdev->dev,
-			 "%s: AQ command Config VSI BW allocation per TC failed = %d\n",
-			 __func__, vsi->back->hw.aq.asq_last_status);
+		pf_info(vsi->back, "%s: AQ command Config VSI BW allocation per TC failed = %d\n",
+			__func__, vsi->back->hw.aq.asq_last_status);
 		return ret;
 	}
 
@@ -3676,9 +3647,8 @@ static s32 i40e_vsi_config_tc(struct i40e_vsi *vsi, u8 enabled_tc)
 
 	ret = i40e_vsi_configure_bw_alloc(vsi, enabled_tc, bw_share);
 	if (ret) {
-		dev_info(&vsi->back->pdev->dev,
-			 "%s: Failed configuring TC map %d for VSI %d\n",
-			 __func__,  enabled_tc, vsi->seid);
+		pf_info(vsi->back, "%s: Failed configuring TC map %d for VSI %d\n",
+			__func__,  enabled_tc, vsi->seid);
 		goto out;
 	}
 
@@ -3693,9 +3663,8 @@ static s32 i40e_vsi_config_tc(struct i40e_vsi *vsi, u8 enabled_tc)
 	/* Update the VSI after updating the VSI queue-mapping information */
 	ret = i40e_aq_update_vsi_params(&vsi->back->hw, &ctxt, NULL);
 	if (ret != I40E_SUCCESS) {
-		dev_info(&vsi->back->pdev->dev,
-			 "%s: update vsi failed, aq_err=%d\n",
-			 __func__, vsi->back->hw.aq.asq_last_status);
+		pf_info(vsi->back, "%s: update vsi failed, aq_err=%d\n",
+			__func__, vsi->back->hw.aq.asq_last_status);
 		goto out;
 	}
 	/* update the local VSI info with updated queue map */
@@ -3705,9 +3674,8 @@ static s32 i40e_vsi_config_tc(struct i40e_vsi *vsi, u8 enabled_tc)
 	/* Update current VSI BW information */
 	ret = i40e_vsi_get_bw_info(vsi);
 	if (ret != I40E_SUCCESS) {
-		dev_info(&vsi->back->pdev->dev,
-			 "%s: Failed updating vsi bw info, aq_err=%d\n",
-			 __func__, vsi->back->hw.aq.asq_last_status);
+		pf_info(vsi->back, "%s: Failed updating vsi bw info, aq_err=%d\n",
+			__func__, vsi->back->hw.aq.asq_last_status);
 		goto out;
 	}
 
@@ -4003,7 +3971,7 @@ void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags)
 		 * for the warning interrupt will deal with the shutdown
 		 * and recovery of the switch setup.
 		 */
-		dev_info(&pf->pdev->dev, "%s: GlobalR requested\n", __func__);
+		pf_info(pf, "%s: GlobalR requested\n", __func__);
 		val = rd32(&pf->hw, I40E_GLGEN_RTRIG);
 		val |= I40E_GLGEN_RTRIG_GLOBR_MASK;
 		wr32(&pf->hw, I40E_GLGEN_RTRIG, val);
@@ -4013,7 +3981,7 @@ void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags)
 		 *
 		 * Same as Global Reset, except does *not* include the MAC/PHY
 		 */
-		dev_info(&pf->pdev->dev, "%s: CoreR requested\n", __func__);
+		pf_info(pf, "%s: CoreR requested\n", __func__);
 		val = rd32(&pf->hw, I40E_GLGEN_RTRIG);
 		val |= I40E_GLGEN_RTRIG_CORER_MASK;
 		wr32(&pf->hw, I40E_GLGEN_RTRIG, val);
@@ -4028,15 +3996,14 @@ void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags)
 		 * the switch, since we need to do all the recovery as
 		 * for the Core Reset.
 		 */
-		dev_info(&pf->pdev->dev, "%s: PFR requested\n", __func__);
+		pf_info(pf, "%s: PFR requested\n", __func__);
 		i40e_handle_reset_warning(pf);
 
 	} else if (reset_flags & (1 << __I40E_REINIT_REQUESTED)) {
 		int v;
 
 		/* Find the VSI(s) that requested a re-init */
-		dev_info(&pf->pdev->dev,
-			 "%s: VSI reinit requested\n", __func__);
+		pf_info(pf, "%s: VSI reinit requested\n", __func__);
 		for (v = 0; v < pf->hw.func_caps.num_vsis; v++) {
 			struct i40e_vsi *vsi = pf->vsi[v];
 			if (vsi != NULL &&
@@ -4049,9 +4016,8 @@ void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags)
 		/* no further action needed, so return now */
 		return;
 	} else {
-		dev_info(&pf->pdev->dev,
-			 "%s: bad reset request 0x%08x\n",
-			 __func__, reset_flags);
+		pf_info(pf, "%s: bad reset request 0x%08x\n",
+			__func__, reset_flags);
 		return;
 	}
 }
@@ -4075,9 +4041,8 @@ static void i40e_handle_lan_overflow_event(struct i40e_pf *pf,
 	struct i40e_vf *vf;
 	u16 vf_id;
 
-	dev_info(&pf->pdev->dev,
-		 "%s: Rx Queue Number = %d QTX_CTL=0x%08x\n",
-		 __func__, queue, qtx_ctl);
+	pf_info(pf, "%s: Rx Queue Number = %d QTX_CTL=0x%08x\n",
+		__func__, queue, qtx_ctl);
 
 	/* Queue belongs to VF, find the VF and issue VF reset */
 	if (((qtx_ctl & I40E_QTX_CTL_PFVF_Q_MASK)
@@ -4396,12 +4361,10 @@ static void i40e_clean_adminq_subtask(struct i40e_pf *pf)
 	do {
 		ret = i40e_clean_arq_element(hw, &event, &pending);
 		if (ret == I40E_ERR_ADMIN_QUEUE_NO_WORK) {
-			dev_info(&pf->pdev->dev,
-				 "%s: No ARQ event found\n", __func__);
+			pf_info(pf, "%s: No ARQ event found\n", __func__);
 			break;
 		} else if (ret) {
-			dev_info(&pf->pdev->dev,
-				 "%s: ARQ event error %d\n", __func__, ret);
+			pf_info(pf, "%s: ARQ event error %d\n", __func__, ret);
 			break;
 		}
 
@@ -4419,26 +4382,22 @@ static void i40e_clean_adminq_subtask(struct i40e_pf *pf)
 					event.msg_size);
 			break;
 		case i40e_aqc_opc_lldp_update_mib:
-			dev_info(&pf->pdev->dev,
-				 "%s: ARQ: Update LLDP MIB event received\n",
-				 __func__);
+			pf_info(pf, "%s: ARQ: Update LLDP MIB event received\n",
+				__func__);
 			break;
 		case i40e_aqc_opc_event_lan_overflow:
-			dev_info(&pf->pdev->dev,
-				 "%s: ARQ LAN queue overflow event received\n",
-				 __func__);
+			pf_info(pf, "%s: ARQ LAN queue overflow event received\n",
+				__func__);
 			i40e_handle_lan_overflow_event(pf, &event);
 			break;
 		default:
-			dev_info(&pf->pdev->dev,
-				 "%s: ARQ Error: Unknown event %d received\n",
-				 __func__, event.desc.opcode);
+			pf_info(pf, "%s: ARQ Error: Unknown event %d received\n",
+				__func__, event.desc.opcode);
 			break;
 		}
 		if (pending != 0)
-			dev_info(&pf->pdev->dev,
-				 "%s: ARQ: Pending events %d\n",
-				 __func__, pending);
+			pf_info(pf, "%s: ARQ: Pending events %d\n",
+				__func__, pending);
 	} while (pending && (i++ < pf->adminq_work_limit));
 
 	clear_bit(__I40E_ADMINQ_EVENT_PENDING, &pf->state);
@@ -4477,9 +4436,8 @@ static s32 i40e_reconstitute_veb(struct i40e_veb *veb)
 		}
 	}
 	if (ctl_vsi == NULL) {
-		dev_info(&pf->pdev->dev,
-			 "%s: missing owner VSI for veb_idx %d\n",
-			 __func__, veb->idx);
+		pf_info(pf, "%s: missing owner VSI for veb_idx %d\n",
+			__func__, veb->idx);
 		ret = I40E_ERR_NO_AVAILABLE_VSI;
 		goto end_reconstitute;
 	}
@@ -4487,9 +4445,8 @@ static s32 i40e_reconstitute_veb(struct i40e_veb *veb)
 		ctl_vsi->uplink_seid = pf->vsi[pf->lan_vsi]->uplink_seid;
 	ret = i40e_add_vsi(ctl_vsi);
 	if (ret != I40E_SUCCESS) {
-		dev_info(&pf->pdev->dev,
-			 "%s: rebuild of owner VSI failed: %d\n",
-			 __func__, ret);
+		pf_info(pf, "%s: rebuild of owner VSI failed: %d\n",
+			__func__, ret);
 		goto end_reconstitute;
 	}
 	i40e_sys_add_vsi(ctl_vsi);
@@ -4510,9 +4467,8 @@ static s32 i40e_reconstitute_veb(struct i40e_veb *veb)
 			vsi->uplink_seid = veb->seid;
 			ret = i40e_add_vsi(vsi);
 			if (ret != I40E_SUCCESS) {
-				dev_info(&pf->pdev->dev,
-					 "%s: rebuild of vsi_idx %d failed: %d\n",
-					 __func__, v, ret);
+				pf_info(pf, "%s: rebuild of vsi_idx %d failed: %d\n",
+					__func__, v, ret);
 				goto end_reconstitute;
 			}
 			i40e_sys_add_vsi(vsi);
@@ -4563,23 +4519,21 @@ static i40e_status i40e_get_capabilities(struct i40e_pf *pf)
 			/* retry with a larger buffer */
 			buf_len = data_size;
 		} else if (pf->hw.aq.asq_last_status != I40E_AQ_RC_OK) {
-			dev_info(&pf->pdev->dev,
-				 "%s: capability discovery failed: aq=%d\n",
-				 __func__, pf->hw.aq.asq_last_status);
+			pf_info(pf, "%s: capability discovery failed: aq=%d\n",
+				__func__, pf->hw.aq.asq_last_status);
 			return err;
 		}
 	} while (err != I40E_SUCCESS);
 
 	if (pf->hw.debug_mask & I40E_DEBUG_USER)
-		dev_info(&pf->pdev->dev,
-			 "%s: pf=%d, num_vfs=%d, msix_pf=%d, msix_vf=%d, fd_g=%d, fd_b=%d, pf_max_q=%d num_vsi=%d\n",
-			 __func__, pf->hw.pf_id, pf->hw.func_caps.num_vfs,
-			 pf->hw.func_caps.num_msix_vectors,
-			 pf->hw.func_caps.num_msix_vectors_vf,
-			 pf->hw.func_caps.fd_filters_guaranteed,
-			 pf->hw.func_caps.fd_filters_best_effort,
-			 pf->hw.func_caps.num_tx_qp,
-			 pf->hw.func_caps.num_vsis);
+		pf_info(pf, "%s: pf=%d, num_vfs=%d, msix_pf=%d, msix_vf=%d, fd_g=%d, fd_b=%d, pf_max_q=%d num_vsi=%d\n",
+			__func__, pf->hw.pf_id, pf->hw.func_caps.num_vfs,
+			pf->hw.func_caps.num_msix_vectors,
+			pf->hw.func_caps.num_msix_vectors_vf,
+			pf->hw.func_caps.fd_filters_guaranteed,
+			pf->hw.func_caps.fd_filters_best_effort,
+			pf->hw.func_caps.num_tx_qp,
+			pf->hw.func_caps.num_vsis);
 
 	return I40E_SUCCESS;
 }
@@ -4607,8 +4561,7 @@ static void i40e_fdir_setup(struct i40e_pf *pf)
 	if (!vsi) {
 		vsi = i40e_vsi_setup(pf, I40E_VSI_FDIR, pf->mac_seid, 0);
 		if (!vsi) {
-			dev_info(&pf->pdev->dev,
-				 "%s: Couldn't create FDir VSI\n", __func__);
+			pf_info(pf, "%s: Couldn't create FDir VSI\n", __func__);
 			pf->flags &= ~I40E_FLAG_FDIR_ENABLED;
 			return;
 		}
@@ -4668,8 +4621,7 @@ static void i40e_handle_reset_warning(struct i40e_pf *pf)
 	if (test_and_set_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state))
 		return;
 
-	dev_info(&pf->pdev->dev,
-		 "%s: Tearing down internal switch for reset\n", __func__);
+	pf_info(pf, "%s: Tearing down internal switch for reset\n", __func__);
 
 	i40e_vc_notify_reset(pf);
 
@@ -4693,36 +4645,32 @@ static void i40e_handle_reset_warning(struct i40e_pf *pf)
 	 */
 	ret = i40e_pf_reset(hw);
 	if (ret != I40E_SUCCESS) {
-		dev_info(&pf->pdev->dev, "%s: PF reset failed, %d\n",
-			 __func__, ret);
+		pf_info(pf, "%s: PF reset failed, %d\n", __func__, ret);
 	}
 	pf->pfr_count++;
 
 	if (test_bit(__I40E_DOWN, &pf->state))
 		goto end_core_reset;
-	dev_info(&pf->pdev->dev, "%s: Rebuilding internal switch\n", __func__);
+	pf_info(pf, "%s: Rebuilding internal switch\n", __func__);
 
 	/* rebuild the basics for the AdminQ, HMC, and initial HW switch */
 	ret = i40e_init_adminq(&pf->hw);
 	if (ret != I40E_SUCCESS) {
-		dev_info(&pf->pdev->dev, "%s: Rebuild AdminQ failed, %d\n",
-			 __func__, ret);
+		pf_info(pf, "%s: Rebuild AdminQ failed, %d\n", __func__, ret);
 		goto end_core_reset;
 	}
 
 	ret = i40e_get_capabilities(pf);
 	if (ret) {
-		dev_info(&pf->pdev->dev,
-			 "%s: i40e_get_capabilities failed, %d\n",
-			 __func__, ret);
+		pf_info(pf, "%s: i40e_get_capabilities failed, %d\n",
+			__func__, ret);
 		goto end_core_reset;
 	}
 
 	/* call shutdown HMC */
 	ret = i40e_shutdown_lan_hmc(hw);
 	if (ret) {
-		dev_info(&pf->pdev->dev, "%s: shutdown_lan_hmc failed: %d\n",
-			 __func__, ret);
+		pf_info(pf, "%s: shutdown_lan_hmc failed: %d\n", __func__, ret);
 		goto end_core_reset;
 	}
 
@@ -4730,14 +4678,13 @@ static void i40e_handle_reset_warning(struct i40e_pf *pf)
 				hw->func_caps.num_rx_qp,
 				pf->fcoe_hmc_cntx_num, pf->fcoe_hmc_filt_num);
 	if (ret) {
-		dev_info(&pf->pdev->dev, "%s: init_lan_hmc failed: %d\n",
-			 __func__, ret);
+		pf_info(pf, "%s: init_lan_hmc failed: %d\n", __func__, ret);
 		goto end_core_reset;
 	}
 	ret = i40e_configure_lan_hmc(hw, I40E_HMC_MODEL_DIRECT_ONLY);
 	if (ret) {
-		dev_info(&pf->pdev->dev, "%s: configure_lan_hmc failed: %d\n",
-			 __func__, ret);
+		pf_info(pf, "%s: configure_lan_hmc failed: %d\n",
+			__func__, ret);
 		goto end_core_reset;
 	}
 
@@ -4754,8 +4701,7 @@ static void i40e_handle_reset_warning(struct i40e_pf *pf)
 	 * try to recover minimal use by getting the basic PF VSI working.
 	 */
 	if (pf->vsi[pf->lan_vsi]->uplink_seid != pf->mac_seid) {
-		dev_info(&pf->pdev->dev,
-			 "%s: attempting to rebuild switch\n", __func__);
+		pf_info(pf, "%s: attempting to rebuild switch\n", __func__);
 		/* find the one VEB connected to the MAC, and find orphans */
 		for (v = 0; v < I40E_MAX_VEB; v++) {
 			if (!pf->veb[v])
@@ -4775,30 +4721,26 @@ static void i40e_handle_reset_warning(struct i40e_pf *pf)
 				 * but try to keep going.
 				 */
 				if (pf->veb[v]->uplink_seid == pf->mac_seid) {
-					dev_info(&pf->pdev->dev,
-						 "%s: rebuild of switch failed: %d, will try to set up simple PF connection\n",
-						 __func__, ret);
+					pf_info(pf, "%s: rebuild of switch failed: %d, will try to set up simple PF connection\n",
+						__func__, ret);
 					pf->vsi[pf->lan_vsi]->uplink_seid
 								= pf->mac_seid;
 					break;
 				} else if (pf->veb[v]->uplink_seid == 0) {
-					dev_info(&pf->pdev->dev,
-						 "%s: rebuild of orphan VEB failed: %d\n",
-						 __func__, ret);
+					pf_info(pf, "%s: rebuild of orphan VEB failed: %d\n",
+						__func__, ret);
 				}
 			}
 		}
 	}
 
 	if (pf->vsi[pf->lan_vsi]->uplink_seid == pf->mac_seid) {
-		dev_info(&pf->pdev->dev,
-			 "%s: attempting to rebuild PF VSI\n", __func__);
+		pf_info(pf, "%s: attempting to rebuild PF VSI\n", __func__);
 		/* no VEB, so rebuild only the Main VSI */
 		ret = i40e_add_vsi(pf->vsi[pf->lan_vsi]);
 		if (ret != I40E_SUCCESS) {
-			dev_info(&pf->pdev->dev,
-				 "%s: rebuild of Main VSI failed: %d\n",
-				 __func__, ret);
+			pf_info(pf, "%s: rebuild of Main VSI failed: %d\n",
+				__func__, ret);
 			goto end_core_reset;
 		}
 		i40e_sys_add_vsi(pf->vsi[pf->lan_vsi]);
@@ -4818,7 +4760,7 @@ static void i40e_handle_reset_warning(struct i40e_pf *pf)
 	dv.subbuild_version = 0;
 	i40e_aq_send_driver_version(&pf->hw, &dv, NULL);
 
-	dev_info(&pf->pdev->dev, "%s: PF reset done\n", __func__);
+	pf_info(pf, "%s: PF reset done\n", __func__);
 
 end_core_reset:
 	clear_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state);
@@ -4850,9 +4792,8 @@ static i40e_status i40e_handle_mdd_event(struct i40e_pf *pf)
 				>> I40E_GL_MDET_TX_EVENT_SHIFT;
 		u8 queue = (reg & I40E_GL_MDET_TX_QUEUE_MASK)
 				>> I40E_GL_MDET_TX_QUEUE_SHIFT;
-		dev_info(&pf->pdev->dev,
-			 "%s: Malicious Driver Detection TX event 0x%02x on q %d of function 0x%02x\n",
-			 __func__, event, queue, func);
+		pf_info(pf, "%s: Malicious Driver Detection TX event 0x%02x on q %d of function 0x%02x\n",
+			__func__, event, queue, func);
 		wr32(hw, I40E_GL_MDET_TX, 0xffffffff);
 		mdd_detected = true;
 	}
@@ -4864,9 +4805,8 @@ static i40e_status i40e_handle_mdd_event(struct i40e_pf *pf)
 				>> I40E_GL_MDET_RX_EVENT_SHIFT;
 		u8 queue = (reg & I40E_GL_MDET_RX_QUEUE_MASK)
 				>> I40E_GL_MDET_RX_QUEUE_SHIFT;
-		dev_info(&pf->pdev->dev,
-			 "%s: Malicious Driver Detection RX event 0x%02x on q %d of function 0x%02x\n",
-			 __func__, event, queue, func);
+		pf_info(pf, "%s: Malicious Driver Detection RX event 0x%02x on q %d of function 0x%02x\n",
+			__func__, event, queue, func);
 		wr32(hw, I40E_GL_MDET_RX, 0xffffffff);
 		mdd_detected = true;
 	}
@@ -4878,25 +4818,21 @@ static i40e_status i40e_handle_mdd_event(struct i40e_pf *pf)
 		if (reg & I40E_VP_MDET_TX_VALID_MASK) {
 			wr32(hw, I40E_VP_MDET_TX(i), 0xFFFF);
 			vf->num_mdd_events++;
-			dev_info(&pf->pdev->dev, "%s: MDD TX event on VF %d\n",
-				 __func__, i);
+			pf_info(pf, "%s: MDD TX event on VF %d\n", __func__, i);
 		}
 
 		reg = rd32(hw, I40E_VP_MDET_RX(i));
 		if (reg & I40E_VP_MDET_RX_VALID_MASK) {
 			wr32(hw, I40E_VP_MDET_RX(i), 0xFFFF);
 			vf->num_mdd_events++;
-			dev_info(&pf->pdev->dev, "%s: MDD RX event on VF %d\n",
-				 __func__, i);
+			pf_info(pf, "%s: MDD RX event on VF %d\n", __func__, i);
 		}
 
 		if (vf->num_mdd_events > I40E_DEFAULT_NUM_MDD_EVENTS_ALLOWED) {
-			dev_info(&pf->pdev->dev,
-				 "%s: Too many MDD events on VF %d, disabled\n",
-				 __func__, i);
-			dev_info(&pf->pdev->dev,
-				 "%s: Use PF Control I/F to re-enable the VF\n",
-				 __func__);
+			pf_info(pf, "%s: Too many MDD events on VF %d, disabled\n",
+				__func__, i);
+			pf_info(pf, "%s: Use PF Control I/F to re-enable the VF\n",
+				__func__);
 			set_bit(I40E_VF_STAT_DISABLED, &vf->vf_states);
 		}
 	}
@@ -5089,19 +5025,18 @@ static s32 i40e_vsi_clear(struct i40e_vsi *vsi)
 
 	mutex_lock(&pf->switch_mutex);
 	if (!pf->vsi[vsi->idx]) {
-		dev_err(&pf->pdev->dev, "%s: pf->vsi[%d] is NULL, just free vsi[%d](%p,type %d)\n",
-			__func__, vsi->idx, vsi->idx, vsi, vsi->type);
+		pf_err(pf, "%s: pf->vsi[%d] is NULL, just free vsi[%d](%p,type %d)\n",
+		       __func__, vsi->idx, vsi->idx, vsi, vsi->type);
 		goto unlock_vsi;
 	}
 
 	if (pf->vsi[vsi->idx] != vsi) {
-		dev_err(&pf->pdev->dev,
-			"%s: pf->vsi[%d](%p, type %d) != vsi[%d](%p,type %d): no free!\n",
-			__func__,
-			pf->vsi[vsi->idx]->idx,
-			pf->vsi[vsi->idx],
-			pf->vsi[vsi->idx]->type,
-			vsi->idx, vsi, vsi->type);
+		pf_err(pf, "%s: pf->vsi[%d](%p, type %d) != vsi[%d](%p,type %d): no free!\n",
+		       __func__,
+		       pf->vsi[vsi->idx]->idx,
+		       pf->vsi[vsi->idx],
+		       pf->vsi[vsi->idx]->type,
+		       vsi->idx, vsi, vsi->type);
 		goto unlock_vsi;
 	}
 
@@ -5214,24 +5149,21 @@ static int i40e_reserve_msix_vectors(struct i40e_pf *pf, int vectors)
 			break;
 		} else if (err < 0) {
 			/* total failure */
-			dev_info(&pf->pdev->dev,
-				 "%s: MSI-X vector reservation failed: %d\n",
-				 __func__, err);
+			pf_info(pf, "%s: MSI-X vector reservation failed: %d\n",
+				__func__, err);
 			vectors = 0;
 			break;
 		} else {
 			/* err > 0 is the hint for retry */
-			dev_info(&pf->pdev->dev,
-				 "%s: MSI-X vectors wanted %d, retrying with %d\n",
-				 __func__, vectors, err);
+			pf_info(pf, "%s: MSI-X vectors wanted %d, retrying with %d\n",
+				__func__, vectors, err);
 			vectors = err;
 		}
 	}
 
 	if (vectors > 0 && vectors < I40E_MIN_MSIX) {
-		dev_info(&pf->pdev->dev,
-			 "%s: Couldn't get enough vectors, only %d available\n",
-			 __func__, vectors);
+		pf_info(pf, "%s: Couldn't get enough vectors, only %d available\n",
+			__func__, vectors);
 		vectors = 0;
 	}
 
@@ -5293,9 +5225,8 @@ static i40e_status i40e_init_msix(struct i40e_pf *pf)
 
 	} else if (vec == I40E_MIN_MSIX) {
 		/* Adjust for minimal MSIX use */
-		dev_info(&pf->pdev->dev,
-			 "%s: Features disabled, not enough MSIX vectors\n",
-			 __func__);
+		pf_info(pf, "%s: Features disabled, not enough MSIX vectors\n",
+			__func__);
 		pf->flags &= ~I40E_FLAG_VMDQ_ENABLED;
 		pf->num_vmdq_vsis = 0;
 		pf->num_vmdq_qps = 0;
@@ -5403,9 +5334,8 @@ static void i40e_init_interrupt_scheme(struct i40e_pf *pf)
 	    (pf->flags & I40E_FLAG_MSI_ENABLED)) {
 		err = pci_enable_msi(pf->pdev);
 		if (err) {
-			dev_info(&pf->pdev->dev,
-				 "%s: MSI init failed (%d), trying legacy.\n",
-				 __func__, err);
+			pf_info(pf, "%s: MSI init failed (%d), trying legacy.\n",
+				__func__, err);
 			pf->flags &= ~I40E_FLAG_MSI_ENABLED;
 		}
 	}
@@ -5437,9 +5367,8 @@ static int i40e_setup_misc_vector(struct i40e_pf *pf)
 		err = request_irq(pf->msix_entries[0].vector,
 				  i40e_intr, 0, pf->misc_int_name, pf);
 		if (err) {
-			dev_info(&pf->pdev->dev,
-				 "%s, request_irq for msix_misc failed: %d\n",
-				 __func__, err);
+			pf_info(pf, "%s, request_irq for msix_misc failed: %d\n",
+				__func__, err);
 			return I40E_ERR_CONFIG;
 		}
 	}
@@ -5565,11 +5494,9 @@ static int i40e_sw_init(struct i40e_pf *pf)
 		if ((pf->hw.func_caps.fd_filters_guaranteed > 0) ||
 		    (pf->hw.func_caps.fd_filters_best_effort > 0)) {
 			pf->flags |= I40E_FLAG_FDIR_ATR_ENABLED;
-			dev_info(&pf->pdev->dev,
-				 "Flow Director ATR mode Enabled\n");
+			pf_info(pf, "Flow Director ATR mode Enabled\n");
 			pf->flags |= I40E_FLAG_FDIR_ENABLED;
-			dev_info(&pf->pdev->dev,
-				 "Flow Director Side Band mode Enabled\n");
+			pf_info(pf, "Flow Director Side Band mode Enabled\n");
 			pf->fdir_pf_filter_count =
 					 pf->hw.func_caps.fd_filters_guaranteed;
 		}
@@ -5586,7 +5513,7 @@ static int i40e_sw_init(struct i40e_pf *pf)
 	/* MFP mode enabled */
 	if (pf->hw.func_caps.npar_enable || pf->hw.func_caps.mfp_mode_1) {
 		pf->flags |= I40E_FLAG_MFP_ENABLED;
-		dev_info(&pf->pdev->dev, "%s: MFP mode Enabled\n", __func__);
+		pf_info(pf, "%s: MFP mode Enabled\n", __func__);
 	}
 
 #ifdef CONFIG_PCI_IOV
@@ -5804,9 +5731,8 @@ static s32 i40e_add_vsi(struct i40e_vsi *vsi)
 		ret = i40e_aq_get_vsi_params(&pf->hw, &ctxt, NULL);
 		ctxt.flags = I40E_AQ_VSI_TYPE_PF;
 		if (ret) {
-			dev_info(&pf->pdev->dev,
-				 "%s: couldn't get pf vsi config, err %d, aq_err %d\n",
-				 __func__, ret, pf->hw.aq.asq_last_status);
+			pf_info(pf, "%s: couldn't get pf vsi config, err %d, aq_err %d\n",
+				__func__, ret, pf->hw.aq.asq_last_status);
 			return ret;
 		}
 		memcpy(&vsi->info, &ctxt.info, sizeof(ctxt.info));
@@ -5826,9 +5752,8 @@ static s32 i40e_add_vsi(struct i40e_vsi *vsi)
 			i40e_vsi_setup_queue_map(vsi, &ctxt, enabled_tc, false);
 			ret = i40e_aq_update_vsi_params(hw, &ctxt, NULL);
 			if (ret != I40E_SUCCESS) {
-				dev_info(&pf->pdev->dev,
-					 "%s: update vsi failed, aq_err=%d\n",
-					 __func__, pf->hw.aq.asq_last_status);
+				pf_info(pf, "%s: update vsi failed, aq_err=%d\n",
+					__func__, pf->hw.aq.asq_last_status);
 				goto err;
 			}
 			/* update the local VSI info queue map */
@@ -5841,10 +5766,9 @@ static s32 i40e_add_vsi(struct i40e_vsi *vsi)
 			 */
 			ret = i40e_vsi_config_tc(vsi, enabled_tc);
 			if (ret) {
-				dev_info(&pf->pdev->dev,
-					 "%s: failed to configure TCs for main VSI tc_map 0x%08x, err %d, aq_err %d\n",
-					 __func__, enabled_tc, ret,
-					 pf->hw.aq.asq_last_status);
+				pf_info(pf, "%s: failed to configure TCs for main VSI tc_map 0x%08x, err %d, aq_err %d\n",
+					__func__, enabled_tc, ret,
+					pf->hw.aq.asq_last_status);
 			}
 		}
 		break;
@@ -5905,9 +5829,8 @@ static s32 i40e_add_vsi(struct i40e_vsi *vsi)
 	if (vsi->type != I40E_VSI_MAIN) {
 		ret = i40e_aq_add_vsi(hw, &ctxt, NULL);
 		if (ret) {
-			dev_info(&vsi->back->pdev->dev,
-				 "%s: add vsi failed, aq_err=%d\n",
-				 __func__, vsi->back->hw.aq.asq_last_status);
+			pf_info(vsi->back, "%s: add vsi failed, aq_err=%d\n",
+				__func__, vsi->back->hw.aq.asq_last_status);
 			goto err;
 		}
 		memcpy(&vsi->info, &ctxt.info, sizeof(ctxt.info));
@@ -5929,9 +5852,8 @@ static s32 i40e_add_vsi(struct i40e_vsi *vsi)
 	/* Update VSI BW information */
 	ret = i40e_vsi_get_bw_info(vsi);
 	if (ret) {
-		dev_info(&pf->pdev->dev,
-			 "%s: couldn't get vsi bw info, err %d, aq_err %d\n",
-			 __func__, ret, pf->hw.aq.asq_last_status);
+		pf_info(pf, "%s: couldn't get vsi bw info, err %d, aq_err %d\n",
+			__func__, ret, pf->hw.aq.asq_last_status);
 		/* VSI is already added so not tearing that up */
 		ret = I40E_SUCCESS;
 	}
@@ -5961,13 +5883,13 @@ s32 i40e_vsi_release(struct i40e_vsi *vsi)
 
 	/* release of a VEB-owner or last VSI is not allowed */
 	if (vsi->flags & I40E_VSI_FLAG_VEB_OWNER) {
-		dev_info(&pf->pdev->dev, "%s: VSI %d has existing VEB %d\n",
-			 __func__, vsi->seid, vsi->uplink_seid);
+		pf_info(pf, "%s: VSI %d has existing VEB %d\n",
+			__func__, vsi->seid, vsi->uplink_seid);
 		return I40E_ERR_DEVICE_NOT_SUPPORTED;
 	}
 	if (vsi == pf->vsi[pf->lan_vsi] &&
 	    !test_bit(__I40E_DOWN, &pf->state)) {
-		dev_info(&pf->pdev->dev, "%s: Can't remove PF VSI\n", __func__);
+		pf_info(pf, "%s: Can't remove PF VSI\n", __func__);
 		return I40E_ERR_DEVICE_NOT_SUPPORTED;
 	}
 
@@ -6046,23 +5968,21 @@ static s32 i40e_vsi_setup_vectors(struct i40e_vsi *vsi)
 	struct i40e_pf *pf = vsi->back;
 
 	if (vsi->q_vectors) {
-		dev_info(&pf->pdev->dev, "%s: VSI %d has existing q_vectors\n",
-			 __func__, vsi->seid);
+		pf_info(pf, "%s: VSI %d has existing q_vectors\n",
+			__func__, vsi->seid);
 		return I40E_ERR_CONFIG;
 	}
 
 	if (vsi->base_vector) {
-		dev_info(&pf->pdev->dev,
-			 "%s: VSI %d has non-zero base vector %d\n",
-			 __func__, vsi->seid, vsi->base_vector);
+		pf_info(pf, "%s: VSI %d has non-zero base vector %d\n",
+			__func__, vsi->seid, vsi->base_vector);
 		return I40E_ERR_CONFIG;
 	}
 
 	ret = i40e_alloc_q_vectors(vsi);
 	if (ret != I40E_SUCCESS) {
-		dev_info(&pf->pdev->dev,
-			 "%s: failed to allocate %d q_vector for VSI %d, ret=%d\n",
-			 __func__, vsi->num_q_vectors, vsi->seid, ret);
+		pf_info(pf, "%s: failed to allocate %d q_vector for VSI %d, ret=%d\n",
+			__func__, vsi->num_q_vectors, vsi->seid, ret);
 		vsi->num_q_vectors = 0;
 		goto vector_setup_out;
 	}
@@ -6070,9 +5990,8 @@ static s32 i40e_vsi_setup_vectors(struct i40e_vsi *vsi)
 	vsi->base_vector = i40e_get_lump(pf, pf->irq_pile,
 					 vsi->num_q_vectors, vsi->idx);
 	if (vsi->base_vector < 0) {
-		dev_info(&pf->pdev->dev,
-			 "%s: failed to get q tracking for VSI %d, err=%d\n",
-			 __func__, vsi->seid, vsi->base_vector);
+		pf_info(pf, "%s: failed to get q tracking for VSI %d, err=%d\n",
+			__func__, vsi->seid, vsi->base_vector);
 		i40e_vsi_free_q_vectors(vsi);
 		ret = I40E_ERR_CONFIG;
 		goto vector_setup_out;
@@ -6131,8 +6050,8 @@ struct i40e_vsi *i40e_vsi_setup(struct i40e_pf *pf, u8 type,
 			}
 		}
 		if (!vsi) {
-			dev_info(&pf->pdev->dev, "%s: no such uplink_seid %d\n",
-				 __func__, uplink_seid);
+			pf_info(pf, "%s: no such uplink_seid %d\n",
+				__func__, uplink_seid);
 			return NULL;
 		}
 
@@ -6148,8 +6067,7 @@ struct i40e_vsi *i40e_vsi_setup(struct i40e_pf *pf, u8 type,
 				veb = pf->veb[i];
 		}
 		if (!veb) {
-			dev_info(&pf->pdev->dev, "%s: couldn't add VEB\n",
-				 __func__);
+			pf_info(pf, "%s: couldn't add VEB\n", __func__);
 			return NULL;
 		}
 
@@ -6172,8 +6090,8 @@ struct i40e_vsi *i40e_vsi_setup(struct i40e_pf *pf, u8 type,
 	/* assign it some queues */
 	ret = i40e_get_lump(pf, pf->qp_pile, vsi->alloc_queue_pairs, vsi->idx);
 	if (ret < 0) {
-		dev_info(&pf->pdev->dev, "%s: VSI %d get_lump failed %d\n",
-			 __func__, vsi->seid, ret);
+		pf_info(pf, "%s: VSI %d get_lump failed %d\n",
+			__func__, vsi->seid, ret);
 		goto err_vsi;
 	}
 	vsi->base_queue = ret;
@@ -6255,18 +6173,16 @@ static s32 i40e_veb_get_bw_info(struct i40e_veb *veb)
 	ret = i40e_aq_query_switch_comp_bw_config(hw, veb->seid,
 						  &bw_data, NULL);
 	if (ret != I40E_SUCCESS) {
-		dev_info(&pf->pdev->dev,
-			 "%s: query veb bw config failed, aq_err=%d\n",
-			 __func__, hw->aq.asq_last_status);
+		pf_info(pf, "%s: query veb bw config failed, aq_err=%d\n",
+			__func__, hw->aq.asq_last_status);
 		goto out;
 	}
 
 	ret = i40e_aq_query_switch_comp_ets_config(hw, veb->seid,
 						   &ets_data, NULL);
 	if (ret != I40E_SUCCESS) {
-		dev_info(&pf->pdev->dev,
-			 "%s: query veb bw ets config failed, aq_err=%d\n",
-			 __func__, hw->aq.asq_last_status);
+		pf_info(pf, "%s: query veb bw ets config failed, aq_err=%d\n",
+			__func__, hw->aq.asq_last_status);
 		goto out;
 	}
 
@@ -6421,9 +6337,8 @@ s32 i40e_veb_release(struct i40e_veb *veb)
 		}
 	}
 	if (n != 1) {
-		dev_info(&pf->pdev->dev,
-			 "%s: can't remove VEB %d with %d VSIs left\n",
-			 __func__, veb->seid, n);
+		pf_info(pf, "%s: can't remove VEB %d with %d VSIs left\n",
+			__func__, veb->seid, n);
 		return I40E_ERR_NOT_READY;
 	}
 
@@ -6464,9 +6379,8 @@ static s32 i40e_add_veb(struct i40e_veb *veb, struct i40e_vsi *vsi)
 	ret = i40e_aq_add_veb(&veb->pf->hw, veb->uplink_seid, vsi->seid,
 			      veb->enabled_tc, is_default, &veb->seid, NULL);
 	if (ret != I40E_SUCCESS) {
-		dev_info(&veb->pf->pdev->dev,
-			 "%s: couldn't add VEB, err %d, aq_err %d\n",
-			 __func__, ret, veb->pf->hw.aq.asq_last_status);
+		pf_info(veb->pf, "%s: couldn't add VEB, err %d, aq_err %d\n",
+			__func__, ret, veb->pf->hw.aq.asq_last_status);
 		return ret;
 	}
 
@@ -6474,16 +6388,14 @@ static s32 i40e_add_veb(struct i40e_veb *veb, struct i40e_vsi *vsi)
 	ret = i40e_aq_get_veb_parameters(&veb->pf->hw, veb->seid, NULL, NULL,
 					 &veb->stats_idx, NULL, NULL, NULL);
 	if (ret != I40E_SUCCESS) {
-		dev_info(&veb->pf->pdev->dev,
-			 "%s: couldn't get VEB statistics idx, err %d, aq_err %d\n",
-			 __func__, ret, veb->pf->hw.aq.asq_last_status);
+		pf_info(veb->pf, "%s: couldn't get VEB statistics idx, err %d, aq_err %d\n",
+			__func__, ret, veb->pf->hw.aq.asq_last_status);
 		return ret;
 	}
 	ret = i40e_veb_get_bw_info(veb);
 	if (ret != I40E_SUCCESS) {
-		dev_info(&veb->pf->pdev->dev,
-			 "%s: couldn't get VEB bw info, err %d, aq_err %d\n",
-			 __func__, ret, veb->pf->hw.aq.asq_last_status);
+		pf_info(veb->pf, "%s: couldn't get VEB bw info, err %d, aq_err %d\n",
+			__func__, ret, veb->pf->hw.aq.asq_last_status);
 		i40e_aq_delete_element(&veb->pf->hw, veb->seid, NULL);
 		return ret;
 	}
@@ -6527,9 +6439,8 @@ struct i40e_veb *i40e_veb_setup(struct i40e_pf *pf, u16 flags,
 	/* if one seid is 0, the other must be 0 to create a floating relay */
 	if ((uplink_seid == 0 || vsi_seid == 0) &&
 	    (uplink_seid + vsi_seid != 0)) {
-		dev_info(&pf->pdev->dev,
-			 "%s: one, not both seid's are 0: uplink=%d vsi=%d\n",
-			 __func__, uplink_seid, vsi_seid);
+		pf_info(pf, "%s: one, not both seid's are 0: uplink=%d vsi=%d\n",
+			__func__, uplink_seid, vsi_seid);
 		return NULL;
 	}
 
@@ -6538,8 +6449,7 @@ struct i40e_veb *i40e_veb_setup(struct i40e_pf *pf, u16 flags,
 		if (pf->vsi[vsi_idx] && pf->vsi[vsi_idx]->seid == vsi_seid)
 			break;
 	if (vsi_idx >= pf->hw.func_caps.num_vsis && vsi_seid != 0) {
-		dev_info(&pf->pdev->dev, "%s: vsi seid %d not found\n",
-			 __func__, vsi_seid);
+		pf_info(pf, "%s: vsi seid %d not found\n", __func__, vsi_seid);
 		return NULL;
 	}
 
@@ -6552,9 +6462,8 @@ struct i40e_veb *i40e_veb_setup(struct i40e_pf *pf, u16 flags,
 			}
 		}
 		if (!uplink_veb) {
-			dev_info(&pf->pdev->dev,
-				 "%s: uplink seid %d not found\n",
-				 __func__, uplink_seid);
+			pf_info(pf, "%s: uplink seid %d not found\n",
+				__func__, uplink_seid);
 			return NULL;
 		}
 	}
@@ -6611,17 +6520,15 @@ s32 i40e_fetch_switch_configuration(struct i40e_pf *pf, bool printconfig)
 						I40E_AQ_LARGE_BUF,
 						&next_seid, NULL);
 		if (ret) {
-			dev_info(&pf->pdev->dev,
-				 "%s: get switch config failed %d aq_err=%x\n",
-				 __func__, ret, pf->hw.aq.asq_last_status);
+			pf_info(pf, "%s: get switch config failed %d aq_err=%x\n",
+				__func__, ret, pf->hw.aq.asq_last_status);
 			kfree(aq_buf);
 			return ret;
 		}
 		if (printconfig)
-			dev_info(&pf->pdev->dev,
-				 "%s: header: %d reported %d total\n",
-				 __func__, sw_config->header.num_reported,
-				 sw_config->header.num_total);
+			pf_info(pf, "%s: header: %d reported %d total\n",
+				__func__, sw_config->header.num_reported,
+				sw_config->header.num_total);
 
 		if (sw_config->header.num_reported) {
 			int sz = sizeof(struct i40e_aqc_get_switch_config_resp)
@@ -6634,13 +6541,12 @@ s32 i40e_fetch_switch_configuration(struct i40e_pf *pf, bool printconfig)
 
 		for (i = 0; i < sw_config->header.num_reported; i++) {
 			if (printconfig)
-				dev_info(&pf->pdev->dev,
-					 "%s: type=%d seid=%d uplink=%d downlink=%d\n",
-					 __func__,
-					 sw_config->element[i].element_type,
-					 sw_config->element[i].seid,
-					 sw_config->element[i].uplink_seid,
-					 sw_config->element[i].downlink_seid);
+				pf_info(pf, "%s: type=%d seid=%d uplink=%d downlink=%d\n",
+					__func__,
+					sw_config->element[i].element_type,
+					sw_config->element[i].seid,
+					sw_config->element[i].uplink_seid,
+					sw_config->element[i].downlink_seid);
 
 			switch (sw_config->element[i].element_type) {
 			case I40E_SWITCH_ELEMENT_TYPE_MAC:
@@ -6686,10 +6592,9 @@ s32 i40e_fetch_switch_configuration(struct i40e_pf *pf, bool printconfig)
 				pf->pf_seid = sw_config->element[i].downlink_seid;
 				pf->main_vsi_seid = sw_config->element[i].seid;
 				if (printconfig)
-					dev_info(&pf->pdev->dev,
-						 "%s: pf_seid=%d main_vsi_seid=%d\n",
-						 __func__,
-						 pf->pf_seid, pf->main_vsi_seid);
+					pf_info(pf, "%s: pf_seid=%d main_vsi_seid=%d\n",
+						__func__,
+						pf->pf_seid, pf->main_vsi_seid);
 				break;
 			case I40E_SWITCH_ELEMENT_TYPE_PF:
 			case I40E_SWITCH_ELEMENT_TYPE_VF:
@@ -6700,11 +6605,10 @@ s32 i40e_fetch_switch_configuration(struct i40e_pf *pf, bool printconfig)
 				/* ignore these for now */
 				break;
 			default:
-				dev_info(&pf->pdev->dev,
-					 "%s: unknown element type=%d seid=%d\n",
-					 __func__,
-					 sw_config->element[i].element_type,
-					 sw_config->element[i].seid);
+				pf_info(pf, "%s: unknown element type=%d seid=%d\n",
+					__func__,
+					sw_config->element[i].element_type,
+					sw_config->element[i].seid);
 				break;
 			}
 		}
@@ -6727,9 +6631,8 @@ static s32 i40e_setup_pf_switch(struct i40e_pf *pf)
 	/* find out what's out there already */
 	ret = i40e_fetch_switch_configuration(pf, false);
 	if (ret) {
-		dev_info(&pf->pdev->dev,
-			 "%s: couldn't fetch switch config, err %d, aq_err %d\n",
-			 __func__, ret, pf->hw.aq.asq_last_status);
+		pf_info(pf, "%s: couldn't fetch switch config, err %d, aq_err %d\n",
+			__func__, ret, pf->hw.aq.asq_last_status);
 		return ret;
 	}
 	i40e_pf_reset_stats(pf);
@@ -6755,8 +6658,7 @@ static s32 i40e_setup_pf_switch(struct i40e_pf *pf)
 
 		vsi = i40e_vsi_setup(pf, I40E_VSI_MAIN, uplink_seid, 0);
 		if (vsi == NULL) {
-			dev_info(&pf->pdev->dev,
-				 "%s: setup of MAIN VSI failed\n", __func__);
+			pf_info(pf, "%s: setup of MAIN VSI failed\n", __func__);
 			i40e_fdir_teardown(pf);
 			return I40E_ERR_NOT_READY;
 		}
@@ -6778,8 +6680,8 @@ static s32 i40e_setup_pf_switch(struct i40e_pf *pf)
 	/* Setup static PF queue filter control settings */
 	ret = i40e_setup_pf_filter_control(pf);
 	if (ret) {
-		dev_info(&pf->pdev->dev, "%s: setup_pf_filter_control failed: %d\n",
-			 __func__, ret);
+		pf_info(pf, "%s: setup_pf_filter_control failed: %d\n",
+			__func__, ret);
 		/* Failure here should not stop continuing other steps */
 	}
 
@@ -6876,8 +6778,8 @@ pf->rss_size = num_tc0;                                        \
 
 		queues_left -= pf->rss_size;
 		if (queues_left < 0) {
-			dev_info(&pf->pdev->dev,
-				 "%s: not enough queues for DCB\n", __func__);
+			pf_info(pf, "%s: not enough queues for DCB\n",
+				__func__);
 			return I40E_ERR_CONFIG;
 		}
 
@@ -6892,9 +6794,8 @@ pf->rss_size = num_tc0;                                        \
 
 		queues_left -= pf->rss_size;
 		if (queues_left < 0) {
-			dev_info(&pf->pdev->dev,
-				 "%s: not enough queues for Flow Director\n",
-				 __func__);
+			pf_info(pf, "%s: not enough queues for Flow Director\n",
+				__func__);
 			return I40E_ERR_CONFIG;
 		}
 
@@ -6913,18 +6814,16 @@ pf->rss_size = num_tc0;                                        \
 		SET_RSS_SIZE;
 		queues_left -= pf->rss_size;
 		if (queues_left < 0) {
-			dev_info(&pf->pdev->dev,
-				 "%s: not enough queues for DCB and Flow Director\n",
-				 __func__);
+			pf_info(pf, "%s: not enough queues for DCB and Flow Director\n",
+				__func__);
 			return I40E_ERR_CONFIG;
 		}
 
 		pf->num_lan_qps = pf->rss_size + accum_tc_size;
 
 	} else {
-		dev_info(&pf->pdev->dev,
-			 "%s: Invalid configuration, flags=0x%08llx\n",
-			 __func__, pf->flags);
+		pf_info(pf, "%s: Invalid configuration, flags=0x%08llx\n",
+			__func__, pf->flags);
 		return I40E_ERR_CONFIG;
 	}
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_sysfs.c b/drivers/net/ethernet/intel/i40e/i40e_sysfs.c
index fe83333..0a672c0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_sysfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_sysfs.c
@@ -455,14 +455,13 @@ i40e_status i40e_sys_add_vsi(struct i40e_vsi *vsi)
 
 	ret = sysfs_create_group(vsi->kobj, &i40e_sys_vsi_attr_group);
 	if (ret < 0)
-		dev_info(&pf->pdev->dev, "%s: create_group failed: %d\n",
-			 __func__, ret);
+		pf_info(pf, "%s: create_group failed: %d\n", __func__, ret);
 	if (vsi->netdev) {
 		ret = sysfs_create_link(vsi->kobj,
 					&vsi->netdev->dev.kobj, "net");
 		if (ret < 0)
-			dev_info(&pf->pdev->dev, "%s: create_link failed: %d\n",
-				 __func__, ret);
+			pf_info(pf, "%s: create_link failed: %d\n",
+				__func__, ret);
 	}
 
 	return I40E_SUCCESS;
@@ -536,8 +535,7 @@ i40e_status i40e_sys_add_veb(struct i40e_veb *veb)
 
 	ret = sysfs_create_group(veb->kobj, &i40e_sys_veb_attr_group);
 	if (ret < 0)
-		dev_info(&pf->pdev->dev, "%s: create_group failed: %d\n",
-			 __func__, ret);
+		pf_info(pf, "%s: create_group failed: %d\n", __func__, ret);
 
 	return I40E_SUCCESS;
 }
@@ -579,8 +577,7 @@ static i40e_status i40e_sys_add_switch(struct i40e_pf *pf)
 	ret = sysfs_create_group(pf->switch_kobj,
 				 &i40e_sys_hw_switch_attr_group);
 	if (ret < 0)
-		dev_info(&pf->pdev->dev, "%s: create_group failed: %d\n",
-			 __func__, ret);
+		pf_info(pf, "%s: create_group failed: %d\n", __func__, ret);
 
 	i40e_sys_add_vsi(pf->vsi[pf->lan_vsi]);
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 441ae12..9580f00 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -371,18 +371,16 @@ static i40e_status i40e_config_vsi_tx_queue(struct i40e_vf *vf, u16 vsi_idx,
 	/* clear the context in the HMC */
 	ret = i40e_clear_lan_tx_queue_context(hw, pf_queue_id);
 	if (ret != I40E_SUCCESS) {
-		dev_err(&pf->pdev->dev,
-			"%s: Failed to clear LAN Tx queue context %d, error: %d\n",
-			__func__, pf_queue_id, ret);
+		pf_err(pf, "%s: Failed to clear LAN Tx queue context %d, error: %d\n",
+		       __func__, pf_queue_id, ret);
 		goto error_context;
 	}
 
 	/* set the context in the HMC */
 	ret = i40e_set_lan_tx_queue_context(hw, pf_queue_id, &tx_ctx);
 	if (ret != I40E_SUCCESS) {
-		dev_err(&pf->pdev->dev,
-			"%s: Failed to set LAN Tx queue context %d error: %d\n",
-			__func__, pf_queue_id, ret);
+		pf_err(pf, "%s: Failed to set LAN Tx queue context %d error: %d\n",
+		       __func__, pf_queue_id, ret);
 		goto error_context;
 	}
 
@@ -473,18 +471,16 @@ static i40e_status i40e_config_vsi_rx_queue(struct i40e_vf *vf, u16 vsi_idx,
 	/* clear the context in the HMC */
 	ret = i40e_clear_lan_rx_queue_context(hw, pf_queue_id);
 	if (ret != I40E_SUCCESS) {
-		dev_err(&pf->pdev->dev,
-			"%s: Failed to clear LAN Rx queue context %d, error: %d\n",
-			__func__, pf_queue_id, ret);
+		pf_err(pf, "%s: Failed to clear LAN Rx queue context %d, error: %d\n",
+		       __func__, pf_queue_id, ret);
 		goto error_context;
 	}
 
 	/* set the context in the HMC */
 	ret = i40e_set_lan_rx_queue_context(hw, pf_queue_id, &rx_ctx);
 	if (ret != I40E_SUCCESS)
-		dev_err(&pf->pdev->dev,
-			"%s: Failed to set LAN Rx queue context %d error: %d\n",
-			__func__, pf_queue_id, ret);
+		pf_err(pf, "%s: Failed to set LAN Rx queue context %d error: %d\n",
+		       __func__, pf_queue_id, ret);
 
 error_param:
 error_context:
@@ -510,31 +506,27 @@ static i40e_status i40e_alloc_vsi_res(struct i40e_vf *vf,
 	vsi = i40e_vsi_setup(pf, type, pf->vsi[pf->lan_vsi]->seid, vf->vf_id);
 
 	if (!vsi) {
-		dev_err(&pf->pdev->dev,
-			"%s: add vsi failed for vf %d, aq_err %d\n",
-			__func__, vf->vf_id, pf->hw.aq.asq_last_status);
+		pf_err(pf, "%s: add vsi failed for vf %d, aq_err %d\n",
+		       __func__, vf->vf_id, pf->hw.aq.asq_last_status);
 		goto error_alloc_vsi_res;
 	}
 	if (type == I40E_VSI_SRIOV) {
 		vf->lan_vsi_index = vsi->idx;
 		vf->lan_vsi_id = vsi->id;
-		dev_info(&pf->pdev->dev,
-			 "%s: LAN VSI index %d, VSI id %d\n",
-			 __func__, vsi->idx, vsi->id);
+		pf_info(pf, "%s: LAN VSI index %d, VSI id %d\n",
+			__func__, vsi->idx, vsi->id);
 		f = i40e_add_filter(vsi, vf->default_lan_addr.addr,
 				    0, true, false);
 	}
 	if (NULL == f) {
-		dev_err(&pf->pdev->dev,
-			"%s: Unable to add ucast filter\n", __func__);
+		pf_err(pf, "%s: Unable to add ucast filter\n", __func__);
 		ret = I40E_ERR_NO_MEMORY;
 		goto error_alloc_vsi_res;
 	}
 
 	/* program mac filter */
 	if (I40E_SUCCESS != i40e_sync_vsi_filters(vsi)) {
-		dev_err(&pf->pdev->dev,
-			"%s: Unable to program ucast filters\n", __func__);
+		pf_err(pf, "%s: Unable to program ucast filters\n", __func__);
 		ret = I40E_ERR_CONFIG;
 		goto error_alloc_vsi_res;
 	}
@@ -542,10 +534,9 @@ static i40e_status i40e_alloc_vsi_res(struct i40e_vf *vf,
 	/* accept bcast pkts. by default */
 	ret = i40e_aq_set_vsi_broadcast(hw, vsi->seid, true, NULL);
 	if (I40E_SUCCESS != ret)
-		dev_err(&pf->pdev->dev,
-			"%s: set vsi bcast failed for vf %d, vsi %d, aq_err %d\n",
-			__func__, vf->vf_id, vsi->idx,
-			pf->hw.aq.asq_last_status);
+		pf_err(pf, "%s: set vsi bcast failed for vf %d, vsi %d, aq_err %d\n",
+		       __func__, vf->vf_id, vsi->idx,
+		       pf->hw.aq.asq_last_status);
 
 error_alloc_vsi_res:
 	return ret;
@@ -601,8 +592,8 @@ i40e_status i40e_reset_vf(struct i40e_vf *vf, bool flr)
 	}
 
 	if (!rsd)
-		dev_err(&pf->pdev->dev, "%s: VF reset check timeout %d\n",
-			__func__, vf->vf_id);
+		pf_err(pf, "%s: VF reset check timeout %d\n",
+		       __func__, vf->vf_id);
 
 	/* fast disable qps */
 	for (j = 0; j < pf->vsi[vf->lan_vsi_index]->num_queue_pairs; j++) {
@@ -622,15 +613,13 @@ i40e_status i40e_reset_vf(struct i40e_vf *vf, bool flr)
 		ret = i40e_ctrl_vsi_tx_queue(vf, vf->lan_vsi_index, j,
 					     I40E_QUEUE_CTRL_FASTDISABLECHECK);
 		if (ret != I40E_SUCCESS)
-			dev_info(&pf->pdev->dev,
-				 "%s: Queue control check failed on Tx queue %d of VSI %d VF %d\n",
-				 __func__, vf->lan_vsi_index, j, vf->vf_id);
+			pf_info(pf, "%s: Queue control check failed on Tx queue %d of VSI %d VF %d\n",
+				__func__, vf->lan_vsi_index, j, vf->vf_id);
 		ret = i40e_ctrl_vsi_rx_queue(vf, vf->lan_vsi_index, j,
 					     I40E_QUEUE_CTRL_FASTDISABLECHECK);
 		if (ret != I40E_SUCCESS)
-			dev_info(&pf->pdev->dev,
-				 "%s: Queue control check failed on Rx queue %d of VSI %d VF %d\n",
-				 __func__, vf->lan_vsi_index, j, vf->vf_id);
+			pf_info(pf, "%s: Queue control check failed on Rx queue %d of VSI %d VF %d\n",
+				__func__, vf->lan_vsi_index, j, vf->vf_id);
 	}
 
 	/* clear the irq settings */
@@ -878,9 +867,8 @@ i40e_status i40e_free_vfs(struct i40e_pf *pf)
 	if (!i40e_vfs_are_assigned(pf))
 		pci_disable_sriov(pf->pdev);
 	else
-		dev_warn(&pf->pdev->dev,
-			 "%s: unable to disable SR-IOV because VFs are assigned.\n",
-			 __func__);
+		pf_warn(pf, "%s: unable to disable SR-IOV because VFs are assigned.\n",
+			__func__);
 
 	/* Re-enable interrupt 0. */
 	wr32(hw, I40E_PFINT_DYN_CTL0,
@@ -907,8 +895,8 @@ static i40e_status i40e_alloc_vfs(struct i40e_pf *pf, u16 num_alloc_vfs)
 
 	err = pci_enable_sriov(pf->pdev, num_alloc_vfs);
 	if (err) {
-		dev_err(&pf->pdev->dev, "%s: pci_enable_sriov failed with error %d!\n",
-			__func__, err);
+		pf_err(pf, "%s: pci_enable_sriov failed with error %d!\n",
+		       __func__, err);
 		pf->num_alloc_vfs = 0;
 		ret = I40E_ERR_CONFIG;
 		goto err_iov;
@@ -963,7 +951,7 @@ static int i40e_pci_sriov_enable(struct pci_dev *pdev, int num_vfs)
 	int pre_existing_vfs = pci_num_vf(pdev);
 	int err = 0;
 
-	dev_info(&pdev->dev, "%s: Allocating %d VFs.\n", __func__, num_vfs);
+	dev_info(&pdev->dev, "%s: Allocating %d VFs\n", __func__, num_vfs);
 	if (pre_existing_vfs && pre_existing_vfs != num_vfs)
 		err = i40e_free_vfs(pf);
 	else if (pre_existing_vfs && pre_existing_vfs == num_vfs)
@@ -1033,16 +1021,14 @@ static i40e_status i40e_vc_send_msg_to_vf(struct i40e_vf *vf,
 	/* single place to detect unsuccessful return values */
 	if (v_retval != I40E_SUCCESS) {
 		vf->num_invalid_msgs++;
-		dev_err(&pf->pdev->dev, "%s: Failed opcode %d Error: %d\n",
-			__func__, v_opcode, v_retval);
+		pf_err(pf, "%s: Failed opcode %d Error: %d\n",
+		       __func__, v_opcode, v_retval);
 		if (vf->num_invalid_msgs >
 		    I40E_DEFAULT_NUM_INVALID_MSGS_ALLOWED) {
-			dev_err(&pf->pdev->dev,
-				"%s: Number of invalid messages exceeded for VF %d\n",
-				__func__, vf->vf_id);
-			dev_err(&pf->pdev->dev,
-				"%s: Use PF Control I/F to enable the VF\n",
-				__func__);
+			pf_err(pf, "%s: Number of invalid messages exceeded for VF %d\n",
+			       __func__, vf->vf_id);
+			pf_err(pf, "%s: Use PF Control I/F to enable the VF\n",
+			       __func__);
 			set_bit(I40E_VF_STAT_DISABLED, &vf->vf_states);
 		}
 	} else {
@@ -1052,9 +1038,8 @@ static i40e_status i40e_vc_send_msg_to_vf(struct i40e_vf *vf,
 	ret = i40e_aq_send_msg_to_vf(hw, vf->vf_id, v_opcode, v_retval,
 				     msg, msglen, NULL);
 	if (I40E_SUCCESS != ret)
-		dev_err(&pf->pdev->dev,
-			"%s: Unable to send the message to VF %d aq_err %d\n",
-			__func__, vf->vf_id, pf->hw.aq.asq_last_status);
+		pf_err(pf, "%s: Unable to send the message to VF %d aq_err %d\n",
+		       __func__, vf->vf_id, pf->hw.aq.asq_last_status);
 
 	return ret;
 }
@@ -1433,9 +1418,8 @@ static i40e_status i40e_vc_enable_queues_msg(struct i40e_vf *vf,
 		ret = i40e_ctrl_vsi_rx_queue(vf, vsi_id, queue_id,
 					     I40E_QUEUE_CTRL_ENABLECHECK);
 		if (ret != I40E_SUCCESS) {
-			dev_err(&pf->pdev->dev,
-				"%s: Queue control check failed on RX queue %d of VSI %d VF %d\n",
-				__func__, queue_id, vsi_id, vf->vf_id);
+			pf_err(pf, "%s: Queue control check failed on RX queue %d of VSI %d VF %d\n",
+			       __func__, queue_id, vsi_id, vf->vf_id);
 		}
 		queue_id = find_next_bit(&tempmap, I40E_MAX_VSI_QP,
 					 queue_id + 1);
@@ -1447,9 +1431,8 @@ static i40e_status i40e_vc_enable_queues_msg(struct i40e_vf *vf,
 		ret = i40e_ctrl_vsi_tx_queue(vf, vsi_id, queue_id,
 					     I40E_QUEUE_CTRL_ENABLECHECK);
 		if (ret != I40E_SUCCESS) {
-			dev_err(&pf->pdev->dev,
-				"%s: Queue control check failed on TX queue %d of VSI %d VF %d\n",
-				__func__, queue_id, vsi_id, vf->vf_id);
+			pf_err(pf, "%s: Queue control check failed on TX queue %d of VSI %d VF %d\n",
+			       __func__, queue_id, vsi_id, vf->vf_id);
 		}
 		queue_id = find_next_bit(&tempmap, I40E_MAX_VSI_QP,
 					 queue_id + 1);
@@ -1536,9 +1519,8 @@ static i40e_status i40e_vc_disable_queues_msg(struct i40e_vf *vf,
 		ret = i40e_ctrl_vsi_rx_queue(vf, vsi_id, queue_id,
 					     I40E_QUEUE_CTRL_DISABLECHECK);
 		if (ret != I40E_SUCCESS) {
-			dev_err(&pf->pdev->dev,
-				"%s: Queue control check failed on RX queue %d of VSI %d VF %d\n",
-				__func__, queue_id, vsi_id, vf->vf_id);
+			pf_err(pf, "%s: Queue control check failed on RX queue %d of VSI %d VF %d\n",
+			       __func__, queue_id, vsi_id, vf->vf_id);
 		}
 		queue_id = find_next_bit(&tempmap, I40E_MAX_VSI_QP,
 					 queue_id + 1);
@@ -1550,9 +1532,8 @@ static i40e_status i40e_vc_disable_queues_msg(struct i40e_vf *vf,
 		ret = i40e_ctrl_vsi_tx_queue(vf, vsi_id, queue_id,
 					     I40E_QUEUE_CTRL_DISABLECHECK);
 		if (ret != I40E_SUCCESS) {
-			dev_err(&pf->pdev->dev,
-				"%s: Queue control check failed on TX queue %d of VSI %d VF %d\n",
-				__func__, queue_id, vsi_id, vf->vf_id);
+			pf_err(pf, "%s: Queue control check failed on TX queue %d of VSI %d VF %d\n",
+			       __func__, queue_id, vsi_id, vf->vf_id);
 		}
 		queue_id = find_next_bit(&tempmap, I40E_MAX_VSI_QP,
 					 queue_id + 1);
@@ -1640,8 +1621,8 @@ static i40e_status i40e_vc_add_mac_addr_msg(struct i40e_vf *vf,
 	for (i = 0; i < al->num_elements; i++) {
 		if (is_broadcast_ether_addr(al->list[i].addr) ||
 		    is_zero_ether_addr(al->list[i].addr)) {
-			dev_err(&pf->pdev->dev, "%s: invalid MAC addr %pMAC\n",
-				__func__, al->list[i].addr);
+			pf_err(pf, "%s: invalid MAC addr %pMAC\n",
+			       __func__, al->list[i].addr);
 			ret = I40E_ERR_PARAM;
 			goto error_param;
 		}
@@ -1662,8 +1643,7 @@ static i40e_status i40e_vc_add_mac_addr_msg(struct i40e_vf *vf,
 		}
 
 		if (ret != I40E_SUCCESS) {
-			dev_err(&pf->pdev->dev,
-				"%s: Unable to add MAC filter\n", __func__);
+			pf_err(pf, "%s: Unable to add MAC filter\n", __func__);
 			ret = I40E_ERR_PARAM;
 			goto error_param;
 		}
@@ -1672,8 +1652,7 @@ static i40e_status i40e_vc_add_mac_addr_msg(struct i40e_vf *vf,
 	/* program the updated filter list */
 	ret = i40e_sync_vsi_filters(vsi);
 	if (I40E_SUCCESS != ret)
-		dev_err(&pf->pdev->dev,
-			"%s: Unable to program MAC filters\n", __func__);
+		pf_err(pf, "%s: Unable to program MAC filters\n", __func__);
 
 error_param:
 	/* send the response to the vf */
@@ -1718,8 +1697,7 @@ static i40e_status i40e_vc_del_mac_addr_msg(struct i40e_vf *vf,
 	/* program the updated filter list */
 	ret = i40e_sync_vsi_filters(vsi);
 	if (I40E_SUCCESS != ret)
-		dev_err(&pf->pdev->dev,
-			"%s: Unable to program MAC filters\n", __func__);
+		pf_err(pf, "%s: Unable to program MAC filters\n", __func__);
 
 error_param:
 	/* send the response to the vf */
@@ -1758,9 +1736,8 @@ static i40e_status i40e_vc_add_vlan_msg(struct i40e_vf *vf, u8 *msg,
 	for (i = 0; i < vfl->num_elements; i++) {
 		if (vfl->vlan_id[i] > I40E_MAX_VLANID) {
 			ret = I40E_ERR_PARAM;
-			dev_err(&pf->pdev->dev,
-				"%s: invalid VLAN id %d\n",
-				__func__, vfl->vlan_id[i]);
+			pf_err(pf, "%s: invalid VLAN id %d\n",
+			       __func__, vfl->vlan_id[i]);
 			goto error_param;
 		}
 	}
@@ -1775,9 +1752,8 @@ static i40e_status i40e_vc_add_vlan_msg(struct i40e_vf *vf, u8 *msg,
 		/* add new VLAN filter */
 		ret = i40e_vsi_add_vlan(vsi, vfl->vlan_id[i]);
 		if (ret != I40E_SUCCESS) {
-			dev_err(&pf->pdev->dev,
-				"%s: Unable to add vlan filter %d, error %d\n",
-				__func__, vfl->vlan_id[i], ret);
+			pf_err(pf, "%s: Unable to add vlan filter %d, error %d\n",
+			       __func__, vfl->vlan_id[i], ret);
 			goto error_param;
 		}
 	}
@@ -1831,9 +1807,8 @@ static i40e_status i40e_vc_remove_vlan_msg(struct i40e_vf *vf, u8 *msg,
 	for (i = 0; i < vfl->num_elements; i++) {
 		ret = i40e_vsi_kill_vlan(vsi, vfl->vlan_id[i]);
 		if (I40E_SUCCESS != ret)
-			dev_err(&pf->pdev->dev,
-				"%s: Unable to delete vlan filter %d, error %d\n",
-				__func__, vfl->vlan_id[i], ret);
+			pf_err(pf, "%s: Unable to delete vlan filter %d, error %d\n",
+			       __func__, vfl->vlan_id[i], ret);
 	}
 
 error_param:
@@ -1997,8 +1972,7 @@ i40e_status i40e_vc_process_vf_msg(struct i40e_pf *pf, u16 vf_id,
 	ret = i40e_vc_validate_vf_msg(vf, v_opcode, v_retval, msg, msglen);
 
 	if (ret != I40E_SUCCESS) {
-		dev_err(&pf->pdev->dev, "%s: invalid message from vf %d\n",
-			__func__, vf_id);
+		pf_err(pf, "%s: invalid message from vf %d\n", __func__, vf_id);
 		return ret;
 	}
 	wr32(hw, I40E_VFGEN_RSTAT1(vf_id), I40E_VFR_VFACTIVE);
@@ -2048,9 +2022,8 @@ i40e_status i40e_vc_process_vf_msg(struct i40e_pf *pf, u16 vf_id,
 		break;
 	case I40E_VIRTCHNL_OP_UNKNOWN:
 	default:
-		dev_err(&pf->pdev->dev,
-			"%s: Unsupported opcode %d from vf %d\n",
-			__func__, v_opcode, vf_id);
+		pf_err(pf, "%s: Unsupported opcode %d from vf %d\n",
+		       __func__, v_opcode, vf_id);
 		ret = i40e_vc_send_resp_to_vf(vf, v_opcode,
 					      I40E_ERR_NOT_IMPLEMENTED);
 		break;
@@ -2089,22 +2062,19 @@ i40e_status i40e_vc_process_vflr_event(struct i40e_pf *pf)
 
 			ret = i40e_reset_vf(vf, true);
 			if (ret != I40E_SUCCESS)
-				dev_err(&pf->pdev->dev,
-					"%s: Unable to reset the VF %d\n",
-					__func__, vf_id);
+				pf_err(pf, "%s: Unable to reset the VF %d\n",
+				       __func__, vf_id);
 			/* free up vf resources to destroy vsi state */
 			ret = i40e_free_vf_res(vf);
 			if (ret != I40E_SUCCESS)
-				dev_err(&pf->pdev->dev,
-					"%s: Failed to free VF resources %d\n",
-					__func__, vf_id);
+				pf_err(pf, "%s: Failed to free VF resources %d\n",
+				       __func__, vf_id);
 
 			/* allocate new vf resources with the default state */
 			ret = i40e_alloc_vf_res(vf);
 			if (ret != I40E_SUCCESS)
-				dev_err(&pf->pdev->dev,
-					"%s: Unable to allocate VF resources %d\n",
-					__func__, vf_id);
+				pf_err(pf, "%s: Unable to allocate VF resources %d\n",
+				       __func__, vf_id);
 
 			ret = i40e_enable_vf_mappings(vf);
 		}
@@ -2220,8 +2190,7 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
 
 	/* validate the request */
 	if (vf_id >= pf->num_alloc_vfs) {
-		dev_err(&pf->pdev->dev,
-			"%s: Invalid VF Identifier %d\n", __func__, vf_id);
+		pf_err(pf, "%s: Invalid VF Identifier %d\n", __func__, vf_id);
 		ret = -EINVAL;
 		goto error_param;
 	}
@@ -2229,15 +2198,13 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
 	vf = &(pf->vf[vf_id]);
 	vsi = pf->vsi[vf->lan_vsi_index];
 	if (!test_bit(I40E_VF_STAT_INIT, &vf->vf_states)) {
-		dev_err(&pf->pdev->dev,
-			"%s: Uninitialized VF %d\n", __func__, vf_id);
+		pf_err(pf, "%s: Uninitialized VF %d\n", __func__, vf_id);
 		ret = -EINVAL;
 		goto error_param;
 	}
 
 	if (!is_valid_ether_addr(mac)) {
-		dev_err(&pf->pdev->dev,
-			"%s: Invalid ethernet address\n", __func__);
+		pf_err(pf, "%s: Invalid ethernet address\n", __func__);
 		ret = -EINVAL;
 		goto error_param;
 	}
@@ -2248,25 +2215,21 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
 	/* add the new mac address */
 	f = i40e_add_filter(vsi, mac, 0, true, false);
 	if (NULL == f) {
-		dev_err(&pf->pdev->dev,
-			"%s: Unable to add ucast filter\n", __func__);
+		pf_err(pf, "%s: Unable to add ucast filter\n", __func__);
 		ret = -ENOMEM;
 		goto error_param;
 	}
 
-	dev_info(&pf->pdev->dev, "%s: Setting MAC %pM on VF %d\n",
-		 __func__, mac, vf_id);
+	pf_info(pf, "%s: Setting MAC %pM on VF %d\n", __func__, mac, vf_id);
 	/* program mac filter */
 	if (I40E_SUCCESS != i40e_sync_vsi_filters(vsi)) {
-		dev_err(&pf->pdev->dev,
-			"%s: Unable to program ucast filters\n", __func__);
+		pf_err(pf, "%s: Unable to program ucast filters\n", __func__);
 		ret = -EIO;
 		goto error_param;
 	}
 	memcpy(vf->default_lan_addr.addr, mac, ETH_ALEN);
-	dev_info(&pf->pdev->dev,
-		 "%s: Reload the VF driver to make this change effective.\n",
-		 __func__);
+	pf_info(pf, "%s: Reload the VF driver to make this change effective\n",
+		__func__);
 	ret = 0;
 
 error_param:
@@ -2293,14 +2256,13 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
 
 	/* validate the request */
 	if (vf_id >= pf->num_alloc_vfs) {
-		dev_err(&pf->pdev->dev, "%s: Invalid VF Identifier %d\n",
-			__func__, vf_id);
+		pf_err(pf, "%s: Invalid VF Identifier %d\n", __func__, vf_id);
 		ret = -EINVAL;
 		goto error_pvid;
 	}
 
 	if ((vlan_id > I40E_MAX_VLANID) || (qos > 7)) {
-		dev_err(&pf->pdev->dev, "%s: Invalid Parameters\n", __func__);
+		pf_err(pf, "%s: Invalid Parameters\n", __func__);
 		ret = -EINVAL;
 		goto error_pvid;
 	}
@@ -2308,8 +2270,7 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
 	vf = &(pf->vf[vf_id]);
 	vsi = pf->vsi[vf->lan_vsi_index];
 	if (!test_bit(I40E_VF_STAT_INIT, &vf->vf_states)) {
-		dev_err(&pf->pdev->dev,
-			"%s: Uninitialized VF %d\n", __func__, vf_id);
+		pf_err(pf, "%s: Uninitialized VF %d\n", __func__, vf_id);
 		ret = -EINVAL;
 		goto error_pvid;
 	}
@@ -2318,9 +2279,8 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
 		/* kill old VLAN */
 		ret = i40e_vsi_kill_vlan(vsi, vsi->info.pvid & VLAN_VID_MASK);
 		if (ret != I40E_SUCCESS) {
-			dev_info(&vsi->back->pdev->dev,
-				 "%s: remove VLAN failed, ret=%d, aq_err=%d\n",
-				 __func__, ret, pf->hw.aq.asq_last_status);
+			pf_info(vsi->back, "%s: remove VLAN failed, ret=%d, aq_err=%d\n",
+				__func__, ret, pf->hw.aq.asq_last_status);
 		}
 	}
 	if (vlan_id || qos)
@@ -2330,24 +2290,21 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
 		i40e_vlan_stripping_disable(vsi);
 
 	if (vlan_id) {
-		dev_info(&pf->pdev->dev,
-			 "%s: Setting VLAN %d, QOS 0x%x on VF %d\n",
-			 __func__, vlan_id, qos, vf_id);
+		pf_info(pf, "%s: Setting VLAN %d, QOS 0x%x on VF %d\n",
+			__func__, vlan_id, qos, vf_id);
 
 		/* add new VLAN filter */
 		ret = i40e_vsi_add_vlan(vsi, vlan_id);
 		if (ret != I40E_SUCCESS) {
-			dev_info(&vsi->back->pdev->dev,
-				 "%s: add VLAN failed, ret=%d aq_err=%d\n",
-				 __func__, ret,
-				 vsi->back->hw.aq.asq_last_status);
+			pf_info(vsi->back, "%s: add VLAN failed, ret=%d aq_err=%d\n",
+				__func__, ret,
+				vsi->back->hw.aq.asq_last_status);
 			goto error_pvid;
 		}
 	}
 
 	if (ret != I40E_SUCCESS) {
-		dev_err(&pf->pdev->dev, "%s: Unable to update vsi context\n",
-			__func__);
+		pf_err(pf, "%s: Unable to update vsi context\n", __func__);
 		ret = -EIO;
 		goto error_pvid;
 	}
@@ -2390,8 +2347,7 @@ int i40e_ndo_get_vf_config(struct net_device *netdev,
 
 	/* validate the request */
 	if (vf_id >= pf->num_alloc_vfs) {
-		dev_err(&pf->pdev->dev,
-			"%s: Invalid VF Identifier %d\n", __func__, vf_id);
+		pf_err(pf, "%s: Invalid VF Identifier %d\n", __func__, vf_id);
 		ret = -EINVAL;
 		goto error_param;
 	}
@@ -2400,8 +2356,7 @@ int i40e_ndo_get_vf_config(struct net_device *netdev,
 	/* first vsi is always the LAN vsi */
 	vsi = pf->vsi[vf->lan_vsi_index];
 	if (!test_bit(I40E_VF_STAT_INIT, &vf->vf_states)) {
-		dev_err(&pf->pdev->dev,
-			"%s: Uninitialized VF %d\n", __func__, vf_id);
+		pf_err(pf, "%s: Uninitialized VF %d\n", __func__, vf_id);
 		ret = -EINVAL;
 		goto error_param;
 	}
-- 
1.8.1.2.459.gbcd45b4.dirty


------------------------------------------------------------------------------
Learn the latest--Visual Studio 2012, SharePoint 2013, SQL 2012, more!
Discover the easy way to master current and previous Microsoft technologies
and advance your career. Get an incredible 1,500+ hours of step-by-step
tutorial videos with LearnDevNow. Subscribe today and save!
http://pubads.g.doubleclick.net/gampad/clk?id=58040911&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
