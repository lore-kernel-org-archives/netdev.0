From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/4] i40e: pf_<level> remove "%s: " ...
	__func__
Date: Fri, 30 Aug 2013 16:06:09 -0700
Message-ID: <098f36c18bd5985eca11a66597879d1296d025d4.1377903831.git.joe@perches.com>
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

Remove the uses of "%s: " ..., __func__ from
the uses of pf_<level> and add it to the macros
instead.

This is preliminary to converting the macros
to functions and saving some text.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h             |   6 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     | 518 ++++++++++-----------
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  36 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 406 ++++++++--------
 drivers/net/ethernet/intel/i40e/i40e_sysfs.c       |   9 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 157 +++----
 6 files changed, 523 insertions(+), 609 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index f1fe336..a39d1c6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -566,10 +566,10 @@ void i40e_vlan_stripping_enable(struct i40e_vsi *vsi);
 /* i40e_pf message logging */
 
 #define pf_err(pf, fmt, ...)						\
-	dev_err(&(pf)->pdev->dev, fmt, ##__VA_ARGS__)
+	dev_err(&(pf)->pdev->dev, "%s: " fmt, __func__, ##__VA_ARGS__)
 #define pf_warn(pf, fmt, ...)						\
-	dev_warn(&(pf)->pdev->dev, fmt, ##__VA_ARGS__)
+	dev_warn(&(pf)->pdev->dev, "%s: " fmt, __func__, ##__VA_ARGS__)
 #define pf_info(pf, fmt, ...)						\
-	dev_info(&(pf)->pdev->dev, fmt, ##__VA_ARGS__)
+	dev_info(&(pf)->pdev->dev, "%s: " fmt, __func__, ##__VA_ARGS__)
 
 #endif /* _I40E_H_ */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index d8b1963..471e5af 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -45,7 +45,7 @@ static struct i40e_vsi *i40e_dbg_find_vsi(struct i40e_pf *pf, int seid)
 	int i;
 
 	if (seid < 0)
-		pf_info(pf, "%s: %d: bad seid\n", __func__, seid);
+		pf_info(pf, "%d: bad seid\n", seid);
 	else
 		for (i = 0; i < pf->hw.func_caps.num_vsis; i++)
 			if (pf->vsi[i] && (pf->vsi[i]->seid == seid))
@@ -65,7 +65,7 @@ static struct i40e_veb *i40e_dbg_find_veb(struct i40e_pf *pf, int seid)
 
 	if ((seid < I40E_BASE_VEB_SEID) ||
 	    (seid > (I40E_BASE_VEB_SEID + I40E_MAX_VEB)))
-		pf_info(pf, "%s: %d: bad seid\n", __func__, seid);
+		pf_info(pf, "%d: bad seid\n", seid);
 	else
 		for (i = 0; i < I40E_MAX_VEB; i++)
 			if (pf->veb[i] && pf->veb[i]->seid == seid)
@@ -133,8 +133,8 @@ static int i40e_dbg_prep_dump_buf(struct i40e_pf *pf, int buflen)
 		i40e_dbg_dump_buf = kzalloc(buflen, GFP_KERNEL);
 		if (i40e_dbg_dump_buf != NULL) {
 			i40e_dbg_dump_buffer_len = buflen;
-			pf_info(pf, "%s: i40e_dbg_dump_buffer_len = %d\n",
-				__func__, (int)i40e_dbg_dump_buffer_len);
+			pf_info(pf, "i40e_dbg_dump_buffer_len = %d\n",
+				(int)i40e_dbg_dump_buffer_len);
 		}
 	}
 
@@ -180,8 +180,7 @@ static ssize_t i40e_dbg_dump_write(struct file *filp,
 	/* decode the SEID given to be dumped */
 	ret = kstrtol(dump_request_buf, 0, &seid);
 	if (ret < 0) {
-		pf_info(pf, "%s: bad seid value '%s'\n",
-			__func__, dump_request_buf);
+		pf_info(pf, "bad seid value '%s'\n", dump_request_buf);
 	} else if (seid == 0) {
 		seid_found = true;
 
@@ -189,7 +188,7 @@ static ssize_t i40e_dbg_dump_write(struct file *filp,
 		i40e_dbg_dump_buffer_len = 0;
 		i40e_dbg_dump_data_len = 0;
 		i40e_dbg_dump_buf = NULL;
-		pf_info(pf, "%s: debug buffer freed\n", __func__);
+		pf_info(pf, "debug buffer freed\n");
 
 	} else if (seid == pf->pf_seid || seid == 1) {
 		seid_found = true;
@@ -216,8 +215,8 @@ static ssize_t i40e_dbg_dump_write(struct file *filp,
 			p += len;
 
 			i40e_dbg_dump_data_len = buflen;
-			pf_info(pf, "%s: PF seid %ld dumped %d bytes\n",
-				__func__, seid, (int)i40e_dbg_dump_data_len);
+			pf_info(pf, "PF seid %ld dumped %d bytes\n",
+				seid, (int)i40e_dbg_dump_data_len);
 		}
 	} else if (seid >= I40E_BASE_VSI_SEID) {
 		struct i40e_vsi *vsi = NULL;
@@ -278,8 +277,8 @@ static ssize_t i40e_dbg_dump_write(struct file *filp,
 			}
 
 			i40e_dbg_dump_data_len = buflen;
-			pf_info(pf, "%s: VSI seid %ld dumped %d bytes\n",
-				__func__, seid, (int)i40e_dbg_dump_data_len);
+			pf_info(pf, "VSI seid %ld dumped %d bytes\n",
+				seid, (int)i40e_dbg_dump_data_len);
 		}
 		mutex_unlock(&pf->switch_mutex);
 	} else if (seid >= I40E_BASE_VEB_SEID) {
@@ -297,15 +296,15 @@ static ssize_t i40e_dbg_dump_write(struct file *filp,
 			seid_found = true;
 			memcpy(i40e_dbg_dump_buf, veb, buflen);
 			i40e_dbg_dump_data_len = buflen;
-			pf_info(pf, "%s: VEB seid %ld dumped %d bytes\n",
-				__func__, seid, (int)i40e_dbg_dump_data_len);
+			pf_info(pf, "VEB seid %ld dumped %d bytes\n",
+				seid, (int)i40e_dbg_dump_data_len);
 		}
 		mutex_unlock(&pf->switch_mutex);
 	}
 
 write_exit:
 	if (!seid_found)
-		pf_info(pf, "%s: unknown seid %ld\n", __func__, seid);
+		pf_info(pf, "unknown seid %ld\n", seid);
 
 	return count;
 }
@@ -380,10 +379,10 @@ static void i40e_dbg_dump_vsi_seid(struct i40e_pf *pf, int seid)
 
 	vsi = i40e_dbg_find_vsi(pf, seid);
 	if (!vsi) {
-		pf_info(pf, "%s: dump %d: seid not found\n", __func__, seid);
+		pf_info(pf, "dump %d: seid not found\n", seid);
 		return;
 	}
-	pf_info(pf, "%s: vsi seid %d\n", __func__, seid);
+	pf_info(pf, "vsi seid %d\n", seid);
 	if (vsi->netdev)
 		pf_info(pf, "    netdev: name = %s\n", vsi->netdev->name);
 	if (vsi->active_vlans)
@@ -650,7 +649,7 @@ static void i40e_dbg_dump_aq_desc(struct i40e_pf *pf)
 	int i;
 
 	/* first the send (command) ring, then the receive (event) ring */
-	pf_info(pf, "%s: AdminQ Tx Ring\n", __func__);
+	pf_info(pf, "AdminQ Tx Ring\n");
 	ring = &(hw->aq.asq);
 	for (i = 0; i < ring->count; i++) {
 		struct i40e_aq_desc *d = I40E_ADMINQ_DESC(*ring, i);
@@ -666,7 +665,7 @@ static void i40e_dbg_dump_aq_desc(struct i40e_pf *pf)
 			d->params.raw[15]);
 	}
 
-	pf_info(pf, "%s: AdminQ Rx Ring\n", __func__);
+	pf_info(pf, "AdminQ Rx Ring\n");
 	ring = &(hw->aq.arq);
 	for (i = 0; i < ring->count; i++) {
 		struct i40e_aq_desc *d = I40E_ADMINQ_DESC(*ring, i);
@@ -702,23 +701,19 @@ static void i40e_dbg_dump_desc(int cnt, int vsi_seid, int ring_id, int desc_n,
 
 	vsi = i40e_dbg_find_vsi(pf, vsi_seid);
 	if (!vsi) {
-		pf_info(pf, "%s: vsi %d not found\n", __func__, vsi_seid);
+		pf_info(pf, "vsi %d not found\n", vsi_seid);
 		if (is_rx_ring)
-			pf_info(pf, "%s: dump desc rx <vsi_seid> <ring_id> [<desc_n>]\n",
-				__func__);
+			pf_info(pf, "dump desc rx <vsi_seid> <ring_id> [<desc_n>]\n");
 		else
-			pf_info(pf, "%s: dump desc tx <vsi_seid> <ring_id> [<desc_n>]\n",
-				__func__);
+			pf_info(pf, "dump desc tx <vsi_seid> <ring_id> [<desc_n>]\n");
 		return;
 	}
 	if (ring_id >= vsi->num_queue_pairs || ring_id < 0) {
-		pf_info(pf, "%s: ring %d not found\n", __func__, ring_id);
+		pf_info(pf, "ring %d not found\n", ring_id);
 		if (is_rx_ring)
-			pf_info(pf, "%s: dump desc rx <vsi_seid> <ring_id> [<desc_n>]\n",
-				__func__);
+			pf_info(pf, "dump desc rx <vsi_seid> <ring_id> [<desc_n>]\n");
 		else
-			pf_info(pf, "%s: dump desc tx <vsi_seid> <ring_id> [<desc_n>]\n",
-				__func__);
+			pf_info(pf, "dump desc tx <vsi_seid> <ring_id> [<desc_n>]\n");
 		return;
 	}
 	if (is_rx_ring)
@@ -726,8 +721,8 @@ static void i40e_dbg_dump_desc(int cnt, int vsi_seid, int ring_id, int desc_n,
 	else
 		ring = vsi->tx_rings[ring_id];
 	if (cnt == 2) {
-		pf_info(pf, "%s: vsi = %02i %s ring = %02i\n",
-			__func__, vsi_seid, is_rx_ring ? "rx" : "tx", ring_id);
+		pf_info(pf, "vsi = %02i %s ring = %02i\n",
+			vsi_seid, is_rx_ring ? "rx" : "tx", ring_id);
 		for (i = 0; i < ring.count; i++) {
 			if (is_rx_ring)
 				ds = I40E_RX_DESC(&ring, i);
@@ -747,8 +742,7 @@ static void i40e_dbg_dump_desc(int cnt, int vsi_seid, int ring_id, int desc_n,
 		}
 	} else if (cnt == 3) {
 		if (desc_n >= ring.count || desc_n < 0) {
-			pf_info(pf, "%s: descriptor %d not found\n",
-				__func__, desc_n);
+			pf_info(pf, "descriptor %d not found\n", desc_n);
 			return;
 		}
 		if (is_rx_ring)
@@ -757,22 +751,20 @@ static void i40e_dbg_dump_desc(int cnt, int vsi_seid, int ring_id, int desc_n,
 			ds = (union i40e_rx_desc *)I40E_TX_DESC(&ring, desc_n);
 		if ((sizeof(union i40e_rx_desc) ==
 		    sizeof(union i40e_16byte_rx_desc)) || (!is_rx_ring))
-			pf_info(pf, "%s: vsi = %02i %s ring = %02i d[%03i] = 0x%016llx 0x%016llx\n",
-				__func__, vsi_seid,
+			pf_info(pf, "vsi = %02i %s ring = %02i d[%03i] = 0x%016llx 0x%016llx\n",
+				vsi_seid,
 				is_rx_ring ? "rx" : "tx", ring_id,
 				desc_n, ds->read.pkt_addr, ds->read.hdr_addr);
 		else
-			pf_info(pf, "%s: vsi = %02i rx ring = %02i d[%03i] = 0x%016llx 0x%016llx 0x%016llx 0x%016llx\n",
-				__func__, vsi_seid, ring_id,
+			pf_info(pf, "vsi = %02i rx ring = %02i d[%03i] = 0x%016llx 0x%016llx 0x%016llx 0x%016llx\n",
+				vsi_seid, ring_id,
 				desc_n, ds->read.pkt_addr, ds->read.hdr_addr,
 				ds->read.rsvd1, ds->read.rsvd2);
 	} else {
 		if (is_rx_ring)
-			pf_info(pf, "%s: dump desc rx <vsi_seid> <ring_id> [<desc_n>]\n",
-				__func__);
+			pf_info(pf, "dump desc rx <vsi_seid> <ring_id> [<desc_n>]\n");
 		else
-			pf_info(pf, "%s: dump desc tx <vsi_seid> <ring_id> [<desc_n>]\n",
-				__func__);
+			pf_info(pf, "dump desc tx <vsi_seid> <ring_id> [<desc_n>]\n");
 	}
 }
 
@@ -786,8 +778,7 @@ static void i40e_dbg_dump_vsi_no_seid(struct i40e_pf *pf)
 
 	for (i = 0; i < pf->hw.func_caps.num_vsis; i++)
 		if (pf->vsi[i])
-			pf_info(pf, "%s: dump vsi[%d]: %d\n",
-				__func__, i, pf->vsi[i]->seid);
+			pf_info(pf, "dump vsi[%d]: %d\n", i, pf->vsi[i]->seid);
 }
 
 /**
@@ -893,13 +884,13 @@ static void i40e_dbg_dump_veb_seid(struct i40e_pf *pf, int seid)
 
 	if ((seid < I40E_BASE_VEB_SEID) ||
 	    (seid >= (I40E_MAX_VEB + I40E_BASE_VEB_SEID))) {
-		pf_info(pf, "%s: %d: bad seid\n", __func__, seid);
+		pf_info(pf, "%d: bad seid\n", seid);
 		return;
 	}
 
 	veb = i40e_dbg_find_veb(pf, seid);
 	if (!veb) {
-		pf_info(pf, "%s: %d: can't find veb\n", __func__, seid);
+		pf_info(pf, "%d: can't find veb\n", seid);
 		return;
 	}
 	pf_info(pf, "veb idx=%d,%d stats_ic=%d  seid=%d uplink=%d\n",
@@ -972,28 +963,26 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			/* default to PF VSI */
 			vsi_seid = pf->vsi[pf->lan_vsi]->seid;
 		} else if (vsi_seid < 0) {
-			pf_info(pf, "%s: add VSI %d: bad vsi seid\n",
-				__func__, vsi_seid);
+			pf_info(pf, "add VSI %d: bad vsi seid\n", vsi_seid);
 			goto command_write_done;
 		}
 
 		vsi = i40e_vsi_setup(pf, I40E_VSI_VMDQ2, vsi_seid, 0);
 		if (vsi)
-			pf_info(pf, "%s: added VSI %d to relay %d\n",
-				__func__, vsi->seid, vsi->uplink_seid);
+			pf_info(pf, "added VSI %d to relay %d\n",
+				vsi->seid, vsi->uplink_seid);
 		else
-			pf_info(pf, "%s: '%s' failed\n", __func__, cmd_buf);
+			pf_info(pf, "'%s' failed\n", cmd_buf);
 
 	} else if (strncmp(cmd_buf, "del vsi", 7) == 0) {
 		sscanf(&cmd_buf[7], "%i", &vsi_seid);
 		vsi = i40e_dbg_find_vsi(pf, vsi_seid);
 		if (!vsi) {
-			pf_info(pf, "%s: del VSI %d: seid not found\n",
-				__func__, vsi_seid);
+			pf_info(pf, "del VSI %d: seid not found\n", vsi_seid);
 			goto command_write_done;
 		}
 
-		pf_info(pf, "%s: deleting VSI %d\n", __func__, vsi_seid);
+		pf_info(pf, "deleting VSI %d\n", vsi_seid);
 		i40e_vsi_release(vsi);
 
 	} else if (strncmp(cmd_buf, "add relay", 9) == 0) {
@@ -1002,19 +991,19 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 
 		cnt = sscanf(&cmd_buf[9], "%i %i", &uplink_seid, &vsi_seid);
 		if (cnt != 2) {
-			pf_info(pf, "%s: add relay: bad command string, cnt=%d\n",
-				__func__, cnt);
+			pf_info(pf, "add relay: bad command string, cnt=%d\n",
+				cnt);
 			goto command_write_done;
 		} else if (uplink_seid < 0) {
-			pf_info(pf, "%s: add relay %d: bad uplink seid\n",
-				__func__, uplink_seid);
+			pf_info(pf, "add relay %d: bad uplink seid\n",
+				uplink_seid);
 			goto command_write_done;
 		}
 
 		vsi = i40e_dbg_find_vsi(pf, vsi_seid);
 		if (!vsi) {
-			pf_info(pf, "%s: add relay: vsi VSI %d not found\n",
-				__func__, vsi_seid);
+			pf_info(pf, "add relay: vsi VSI %d not found\n",
+				vsi_seid);
 			goto command_write_done;
 		}
 
@@ -1023,29 +1012,28 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 				break;
 		if (i >= I40E_MAX_VEB && uplink_seid != 0 &&
 		    uplink_seid != pf->mac_seid) {
-			pf_info(pf, "%s: add relay: relay uplink %d not found\n",
-				__func__, uplink_seid);
+			pf_info(pf, "add relay: relay uplink %d not found\n",
+				uplink_seid);
 			goto command_write_done;
 		}
 
 		veb = i40e_veb_setup(pf, 0, uplink_seid, vsi_seid,
 				     vsi->tc_config.enabled_tc);
 		if (veb)
-			pf_info(pf, "%s: added relay %d\n",
-				__func__, veb->seid);
+			pf_info(pf, "added relay %d\n", veb->seid);
 		else
-			pf_info(pf, "%s: add relay failed\n", __func__);
+			pf_info(pf, "add relay failed\n");
 
 	} else if (strncmp(cmd_buf, "del relay", 9) == 0) {
 		int i;
 		cnt = sscanf(&cmd_buf[9], "%i", &veb_seid);
 		if (cnt != 1) {
-			pf_info(pf, "%s: del relay: bad command string, cnt=%d\n",
-				__func__, cnt);
+			pf_info(pf, "del relay: bad command string, cnt=%d\n",
+				cnt);
 			goto command_write_done;
 		} else if (veb_seid < 0) {
-			pf_info(pf, "%s: del relay %d: bad relay seid\n",
-				__func__, veb_seid);
+			pf_info(pf, "del relay %d: bad relay seid\n",
+				veb_seid);
 			goto command_write_done;
 		}
 
@@ -1054,12 +1042,12 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			if (pf->veb[i] && pf->veb[i]->seid == veb_seid)
 				break;
 		if (i >= I40E_MAX_VEB) {
-			pf_info(pf, "%s: del relay: relay %d not found\n",
-				__func__, veb_seid);
+			pf_info(pf, "del relay: relay %d not found\n",
+				veb_seid);
 			goto command_write_done;
 		}
 
-		pf_info(pf, "%s: deleting relay %d\n", __func__, veb_seid);
+		pf_info(pf, "deleting relay %d\n", veb_seid);
 		i40e_veb_release(pf->veb[i]);
 
 	} else if (strncmp(cmd_buf, "add macaddr", 11) == 0) {
@@ -1076,26 +1064,26 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		if (cnt == 7) {
 			vlan = 0;
 		} else if (cnt != 8) {
-			pf_info(pf, "%s: add macaddr: bad command string, cnt=%d\n",
-				__func__, cnt);
+			pf_info(pf, "add macaddr: bad command string, cnt=%d\n",
+				cnt);
 			goto command_write_done;
 		}
 
 		vsi = i40e_dbg_find_vsi(pf, vsi_seid);
 		if (!vsi) {
-			pf_info(pf, "%s: add macaddr: VSI %d not found\n",
-				__func__, vsi_seid);
+			pf_info(pf, "add macaddr: VSI %d not found\n",
+				vsi_seid);
 			goto command_write_done;
 		}
 
 		f = i40e_add_filter(vsi, ma, vlan, false, false);
 		ret = i40e_sync_vsi_filters(vsi);
 		if (f && !ret)
-			pf_info(pf, "%s: add macaddr: %pM vlan=%d added to VSI %d\n",
-				__func__, ma, vlan, vsi_seid);
+			pf_info(pf, "add macaddr: %pM vlan=%d added to VSI %d\n",
+				ma, vlan, vsi_seid);
 		else
-			pf_info(pf, "%s: add macaddr: %pM vlan=%d to VSI %d failed, f=%p ret=%d\n",
-				__func__, ma, vlan, vsi_seid, f, ret);
+			pf_info(pf, "add macaddr: %pM vlan=%d to VSI %d failed, f=%p ret=%d\n",
+				ma, vlan, vsi_seid, f, ret);
 
 	} else if (strncmp(cmd_buf, "del macaddr", 11) == 0) {
 		u8 ma[6];
@@ -1110,26 +1098,26 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		if (cnt == 7) {
 			vlan = 0;
 		} else if (cnt != 8) {
-			pf_info(pf, "%s: del macaddr: bad command string, cnt=%d\n",
-				__func__, cnt);
+			pf_info(pf, "del macaddr: bad command string, cnt=%d\n",
+				cnt);
 			goto command_write_done;
 		}
 
 		vsi = i40e_dbg_find_vsi(pf, vsi_seid);
 		if (!vsi) {
-			pf_info(pf, "%s: del macaddr: VSI %d not found\n",
-				__func__, vsi_seid);
+			pf_info(pf, "del macaddr: VSI %d not found\n",
+				vsi_seid);
 			goto command_write_done;
 		}
 
 		i40e_del_filter(vsi, ma, vlan, false, false);
 		ret = i40e_sync_vsi_filters(vsi);
 		if (!ret)
-			pf_info(pf, "%s: del macaddr: %pM vlan=%d removed from VSI %d\n",
-				__func__, ma, vlan, vsi_seid);
+			pf_info(pf, "del macaddr: %pM vlan=%d removed from VSI %d\n",
+				ma, vlan, vsi_seid);
 		else
-			pf_info(pf, "%s: del macaddr: %pM vlan=%d from VSI %d failed, ret=%d\n",
-				__func__, ma, vlan, vsi_seid, ret);
+			pf_info(pf, "del macaddr: %pM vlan=%d from VSI %d failed, ret=%d\n",
+				ma, vlan, vsi_seid, ret);
 
 	} else if (strncmp(cmd_buf, "add pvid", 8) == 0) {
 		int v;
@@ -1138,51 +1126,50 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 
 		cnt = sscanf(&cmd_buf[8], "%i %u", &vsi_seid, &v);
 		if (cnt != 2) {
-			pf_info(pf, "%s: add pvid: bad command string, cnt=%d\n",
-				__func__, cnt);
+			pf_info(pf, "add pvid: bad command string, cnt=%d\n",
+				cnt);
 			goto command_write_done;
 		}
 
 		vsi = i40e_dbg_find_vsi(pf, vsi_seid);
 		if (!vsi) {
-			pf_info(pf, "%s: add pvid: VSI %d not found\n",
-				__func__, vsi_seid);
+			pf_info(pf, "add pvid: VSI %d not found\n",
+				vsi_seid);
 			goto command_write_done;
 		}
 
 		vid = (unsigned)v;
 		ret = i40e_vsi_add_pvid(vsi, vid);
 		if (!ret)
-			pf_info(pf, "%s: add pvid: %d added to VSI %d\n",
-				__func__, vid, vsi_seid);
+			pf_info(pf, "add pvid: %d added to VSI %d\n",
+				vid, vsi_seid);
 		else
-			pf_info(pf, "%s: add pvid: %d to VSI %d failed, ret=%d\n",
-				__func__, vid, vsi_seid, ret);
+			pf_info(pf, "add pvid: %d to VSI %d failed, ret=%d\n",
+				vid, vsi_seid, ret);
 
 	} else if (strncmp(cmd_buf, "del pvid", 8) == 0) {
 		i40e_status ret;
 
 		cnt = sscanf(&cmd_buf[8], "%i", &vsi_seid);
 		if (cnt != 1) {
-			pf_info(pf, "%s: del pvid: bad command string, cnt=%d\n",
-				__func__, cnt);
+			pf_info(pf, "del pvid: bad command string, cnt=%d\n",
+				cnt);
 			goto command_write_done;
 		}
 
 		vsi = i40e_dbg_find_vsi(pf, vsi_seid);
 		if (!vsi) {
-			pf_info(pf, "%s: del pvid: VSI %d not found\n",
-				__func__, vsi_seid);
+			pf_info(pf, "del pvid: VSI %d not found\n", vsi_seid);
 			goto command_write_done;
 		}
 
 		ret = i40e_vsi_remove_pvid(vsi);
 		if (!ret)
-			pf_info(pf, "%s: del pvid: removed from VSI %d\n",
-				__func__, vsi_seid);
+			pf_info(pf, "del pvid: removed from VSI %d\n",
+				vsi_seid);
 		else
-			pf_info(pf, "%s: del pvid: VSI %d failed, ret=%d\n",
-				__func__, vsi_seid, ret);
+			pf_info(pf, "del pvid: VSI %d failed, ret=%d\n",
+				vsi_seid, ret);
 
 	} else if (strncmp(cmd_buf, "dump", 4) == 0) {
 		if (strncmp(&cmd_buf[5], "switch", 6) == 0) {
@@ -1215,11 +1202,9 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			} else if (strncmp(&cmd_buf[10], "aq", 2) == 0) {
 				i40e_dbg_dump_aq_desc(pf);
 			} else {
-				pf_info(pf, "%s: dump desc tx <vsi_seid> <ring_id> [<desc_n>]\n",
-					__func__);
-				pf_info(pf, "%s: dump desc rx <vsi_seid> <ring_id> [<desc_n>]\n",
-					__func__);
-				pf_info(pf, "%s: dump desc aq\n", __func__);
+				pf_info(pf, "dump desc tx <vsi_seid> <ring_id> [<desc_n>]\n");
+				pf_info(pf, "dump desc rx <vsi_seid> <ring_id> [<desc_n>]\n");
+				pf_info(pf, "dump desc aq\n");
 			}
 		} else if (strncmp(&cmd_buf[5], "stats", 5) == 0) {
 			pf_info(pf, "pf stats:\n");
@@ -1252,20 +1237,19 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 							    pf->mac_seid,
 							    bw_data, NULL);
 			if (ret) {
-				pf_info(pf, "%s: Query Port ETS Config AQ command failed =0x%x\n",
-					__func__, pf->hw.aq.asq_last_status);
+				pf_info(pf, "Query Port ETS Config AQ command failed =0x%x\n",
+					pf->hw.aq.asq_last_status);
 				kfree(bw_data);
 				bw_data = NULL;
 				goto command_write_done;
 			}
-			pf_info(pf, "%s: port bw: tc_valid=0x%x tc_strict_prio=0x%x, tc_bw_max=0x%04x,0x%04x\n",
-				__func__, bw_data->tc_valid_bits,
+			pf_info(pf, "port bw: tc_valid=0x%x tc_strict_prio=0x%x, tc_bw_max=0x%04x,0x%04x\n",
+				bw_data->tc_valid_bits,
 				bw_data->tc_strict_priority_bits,
 				le16_to_cpu(bw_data->tc_bw_max[0]),
 				le16_to_cpu(bw_data->tc_bw_max[1]));
 			for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
-				pf_info(pf, "%s: port bw: tc_bw_share=%d tc_bw_limit=%d\n",
-					__func__,
+				pf_info(pf, "port bw: tc_bw_share=%d tc_bw_limit=%d\n",
 					bw_data->tc_bw_share_credits[i],
 					le16_to_cpu(bw_data->tc_bw_limits[i]));
 			}
@@ -1273,76 +1257,73 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			kfree(bw_data);
 			bw_data = NULL;
 
-			pf_info(pf, "%s: port ets_cfg: willing=%d cbs=%d, maxtcs=%d\n",
-				__func__, cfg->etscfg.willing, cfg->etscfg.cbs,
+			pf_info(pf, "port ets_cfg: willing=%d cbs=%d, maxtcs=%d\n",
+				cfg->etscfg.willing, cfg->etscfg.cbs,
 				cfg->etscfg.maxtcs);
 			for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
-				pf_info(pf, "%s: port ets_cfg: %d prio_tc=%d tcbw=%d tctsa=%d\n",
-					__func__, i,
+				pf_info(pf, "port ets_cfg: %d prio_tc=%d tcbw=%d tctsa=%d\n",
+					i,
 					cfg->etscfg.prioritytable[i],
 					cfg->etscfg.tcbwtable[i],
 					cfg->etscfg.tsatable[i]);
 			}
 			for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
-				pf_info(pf, "%s: port ets_rec: %d prio_tc=%d tcbw=%d tctsa=%d\n",
-					__func__, i,
+				pf_info(pf, "port ets_rec: %d prio_tc=%d tcbw=%d tctsa=%d\n",
+					i,
 					cfg->etsrec.prioritytable[i],
 					cfg->etsrec.tcbwtable[i],
 					cfg->etsrec.tsatable[i]);
 			}
-			pf_info(pf, "%s: port pfc_cfg: willing=%d mbc=%d, pfccap=%d pfcenable=0x%x\n",
-				__func__, cfg->pfc.willing, cfg->pfc.mbc,
+			pf_info(pf, "port pfc_cfg: willing=%d mbc=%d, pfccap=%d pfcenable=0x%x\n",
+				cfg->pfc.willing, cfg->pfc.mbc,
 				cfg->pfc.pfccap, cfg->pfc.pfcenable);
-			pf_info(pf, "%s: port app_table: num_apps=%d\n",
-				__func__, cfg->numapps);
+			pf_info(pf, "port app_table: num_apps=%d\n",
+				cfg->numapps);
 			for (i = 0; i < cfg->numapps; i++) {
-				pf_info(pf, "%s: port app_table: %d prio=%d selector=%d protocol=0x%x\n",
-					__func__, i, cfg->app[i].priority,
+				pf_info(pf, "port app_table: %d prio=%d selector=%d protocol=0x%x\n",
+					i, cfg->app[i].priority,
 					cfg->app[i].selector,
 					cfg->app[i].protocolid);
 			}
 			/* Peer TLV DCBX data */
-			pf_info(pf, "%s: remote port ets_cfg: willing=%d cbs=%d, maxtcs=%d\n",
-				__func__, r_cfg->etscfg.willing,
+			pf_info(pf, "remote port ets_cfg: willing=%d cbs=%d, maxtcs=%d\n",
+				r_cfg->etscfg.willing,
 				r_cfg->etscfg.cbs, r_cfg->etscfg.maxtcs);
 			for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
-				pf_info(pf, "%s: remote port ets_cfg: %d prio_tc=%d tcbw=%d tctsa=%d\n",
-					__func__, i,
+				pf_info(pf, "remote port ets_cfg: %d prio_tc=%d tcbw=%d tctsa=%d\n",
+					i,
 					r_cfg->etscfg.prioritytable[i],
 					r_cfg->etscfg.tcbwtable[i],
 					r_cfg->etscfg.tsatable[i]);
 			}
 			for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
-				pf_info(pf, "%s: remote port ets_rec: %d prio_tc=%d tcbw=%d tctsa=%d\n",
-					__func__, i,
+				pf_info(pf, "remote port ets_rec: %d prio_tc=%d tcbw=%d tctsa=%d\n",
+					i,
 					r_cfg->etsrec.prioritytable[i],
 					r_cfg->etsrec.tcbwtable[i],
 					r_cfg->etsrec.tsatable[i]);
 			}
-			pf_info(pf, "%s: remote port pfc_cfg: willing=%d mbc=%d, pfccap=%d pfcenable=0x%x\n",
-				__func__, r_cfg->pfc.willing,
+			pf_info(pf, "remote port pfc_cfg: willing=%d mbc=%d, pfccap=%d pfcenable=0x%x\n",
+				r_cfg->pfc.willing,
 				r_cfg->pfc.mbc,
 				r_cfg->pfc.pfccap,
 				r_cfg->pfc.pfcenable);
-			pf_info(pf, "%s: remote port app_table: num_apps=%d\n",
-				__func__, r_cfg->numapps);
+			pf_info(pf, "remote port app_table: num_apps=%d\n",
+				r_cfg->numapps);
 			for (i = 0; i < r_cfg->numapps; i++) {
-				pf_info(pf, "%s: remote port app_table: %d prio=%d selector=%d protocol=0x%x\n",
-					__func__, i,
+				pf_info(pf, "remote port app_table: %d prio=%d selector=%d protocol=0x%x\n",
+					i,
 					r_cfg->app[i].priority,
 					r_cfg->app[i].selector,
 					r_cfg->app[i].protocolid);
 			}
 		} else {
-			pf_info(pf, "%s: dump desc tx <vsi_seid> <ring_id> [<desc_n>], dump desc rx <vsi_seid> <ring_id> [<desc_n>],\n",
-				__func__);
-			pf_info(pf, "%s: dump switch, dump vsi [seid] or\n",
-				__func__);
-			pf_info(pf, "%s: dump stats\n", __func__);
-			pf_info(pf, "%s: dump reset stats\n", __func__);
-			pf_info(pf, "%s: dump port\n", __func__);
-			pf_info(pf, "%s: dump debug fwdata <cluster_id> <table_id> <index>\n",
-				__func__);
+			pf_info(pf, "dump desc tx <vsi_seid> <ring_id> [<desc_n>], dump desc rx <vsi_seid> <ring_id> [<desc_n>],\n");
+			pf_info(pf, "dump switch, dump vsi [seid] or\n");
+			pf_info(pf, "dump stats\n");
+			pf_info(pf, "dump reset stats\n");
+			pf_info(pf, "dump port\n");
+			pf_info(pf, "dump debug fwdata <cluster_id> <table_id> <index>\n");
 		}
 
 	} else if (strncmp(cmd_buf, "msg_enable", 10) == 0) {
@@ -1351,26 +1332,25 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		if (cnt) {
 			if (I40E_DEBUG_USER & level) {
 				pf->hw.debug_mask = level;
-				pf_info(pf, "%s: set hw.debug_mask = 0x%08x\n",
-					__func__, pf->hw.debug_mask);
+				pf_info(pf, "set hw.debug_mask = 0x%08x\n",
+					pf->hw.debug_mask);
 			}
 			pf->msg_enable = level;
-			pf_info(pf, "%s: set msg_enable = 0x%08x\n",
-				__func__, pf->msg_enable);
+			pf_info(pf, "set msg_enable = 0x%08x\n",
+				pf->msg_enable);
 		} else {
-			pf_info(pf, "%s: msg_enable = 0x%08x\n",
-				__func__, pf->msg_enable);
+			pf_info(pf, "msg_enable = 0x%08x\n", pf->msg_enable);
 		}
 	} else if (strncmp(cmd_buf, "pfr", 3) == 0) {
-		pf_info(pf, "%s: forcing PFR\n", __func__);
+		pf_info(pf, "forcing PFR\n");
 		i40e_do_reset(pf, (1 << __I40E_PF_RESET_REQUESTED));
 
 	} else if (strncmp(cmd_buf, "corer", 5) == 0) {
-		pf_info(pf, "%s: forcing CoreR\n", __func__);
+		pf_info(pf, "forcing CoreR\n");
 		i40e_do_reset(pf, (1 << __I40E_CORE_RESET_REQUESTED));
 
 	} else if (strncmp(cmd_buf, "globr", 5) == 0) {
-		pf_info(pf, "%s: forcing GlobR\n", __func__);
+		pf_info(pf, "forcing GlobR\n");
 		i40e_do_reset(pf, (1 << __I40E_GLOBAL_RESET_REQUESTED));
 
 	} else if (strncmp(cmd_buf, "read", 4) == 0) {
@@ -1378,39 +1358,37 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		u32 value;
 		cnt = sscanf(&cmd_buf[4], "%x", &address);
 		if (cnt != 1) {
-			pf_info(pf, "%s: read <reg>\n", __func__);
+			pf_info(pf, "read <reg>\n");
 			goto command_write_done;
 		}
 
 		/* check the range on address */
 		if (address >= I40E_MAX_REGISTER) {
-			pf_info(pf, "%s: read reg address 0x%08x too large\n",
-				__func__, address);
+			pf_info(pf, "read reg address 0x%08x too large\n",
+				address);
 			goto command_write_done;
 		}
 
 		value = rd32(&pf->hw, address);
-		pf_info(pf, "%s: read: 0x%08x = 0x%08x\n",
-			__func__, address, value);
+		pf_info(pf, "read: 0x%08x = 0x%08x\n", address, value);
 
 	} else if (strncmp(cmd_buf, "write", 5) == 0) {
 		u32 address, value;
 		cnt = sscanf(&cmd_buf[5], "%x %x", &address, &value);
 		if (cnt != 2) {
-			pf_info(pf, "%s: write <reg> <value>\n", __func__);
+			pf_info(pf, "write <reg> <value>\n");
 			goto command_write_done;
 		}
 
 		/* check the range on address */
 		if (address >= I40E_MAX_REGISTER) {
-			pf_info(pf, "%s: write reg address 0x%08x too large\n",
-				__func__, address);
+			pf_info(pf, "write reg address 0x%08x too large\n",
+				address);
 			goto command_write_done;
 		}
 		wr32(&pf->hw, address, value);
 		value = rd32(&pf->hw, address);
-		pf_info(pf, "%s: write: 0x%08x = 0x%08x\n",
-			__func__, address, value);
+		pf_info(pf, "write: 0x%08x = 0x%08x\n", address, value);
 	} else if (strncmp(cmd_buf, "clear_stats", 11) == 0) {
 		if (strncmp(&cmd_buf[12], "vsi", 3) == 0) {
 			cnt = sscanf(&cmd_buf[15], "%d", &vsi_seid);
@@ -1418,28 +1396,25 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 				int i;
 				for (i = 0; i < pf->hw.func_caps.num_vsis; i++)
 					i40e_vsi_reset_stats(pf->vsi[i]);
-				pf_info(pf, "%s: vsi clear stats called for all vsi's\n",
-					__func__);
+				pf_info(pf, "vsi clear stats called for all vsi's\n");
 			} else if (cnt == 1) {
 				vsi = i40e_dbg_find_vsi(pf, vsi_seid);
 				if (!vsi) {
-					pf_info(pf, "%s: clear_stats vsi: bad vsi %d\n",
-						__func__, vsi_seid);
+					pf_info(pf, "clear_stats vsi: bad vsi %d\n",
+						vsi_seid);
 					goto command_write_done;
 				}
 				i40e_vsi_reset_stats(vsi);
-				pf_info(pf, "%s: vsi clear stats called for vsi %d\n",
-					__func__, vsi_seid);
+				pf_info(pf, "vsi clear stats called for vsi %d\n",
+					vsi_seid);
 			} else {
-				pf_info(pf, "%s: clear_stats vsi [seid]\n",
-					__func__);
+				pf_info(pf, "clear_stats vsi [seid]\n");
 			}
 		} else if (strncmp(&cmd_buf[12], "pf", 2) == 0) {
 			i40e_pf_reset_stats(pf);
-			pf_info(pf, "%s: pf clear stats called\n", __func__);
+			pf_info(pf, "pf clear stats called\n");
 		} else {
-			pf_info(pf, "%s: clear_stats vsi [seid] or clear_stats pf\n",
-				__func__);
+			pf_info(pf, "clear_stats vsi [seid] or clear_stats pf\n");
 		}
 	} else if ((strncmp(cmd_buf, "add fd_filter", 13) == 0) ||
 		   (strncmp(cmd_buf, "rem fd_filter", 13) == 0)) {
@@ -1473,8 +1448,8 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			     &fd_data.fd_status, &fd_data.cnt_index,
 			     &fd_data.fd_id, &packet_len, asc_packet);
 		if (cnt != 10) {
-			pf_info(pf, "%s: program fd_filter: bad command string, cnt=%d\n",
-				__func__, cnt);
+			pf_info(pf, "program fd_filter: bad command string, cnt=%d\n",
+				cnt);
 			kfree(asc_packet);
 			asc_packet = NULL;
 			kfree(fd_data.raw_packet);
@@ -1489,7 +1464,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		packet_len = min_t(u16,
 				   packet_len, I40E_FDIR_MAX_RAW_PACKET_LOOKUP);
 
-		pf_info(pf, "%s: FD raw packet:\n", __func__);
+		pf_info(pf, "FD raw packet:\n");
 		for (i = 0; i < packet_len; i++) {
 			sscanf(&asc_packet[j], "%2hhx ",
 			       &fd_data.raw_packet[i]);
@@ -1504,11 +1479,9 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		pf_info(pf, "%s\n", print_buf_start);
 		ret = i40e_program_fdir_filter(&fd_data, pf, add);
 		if (!ret) {
-			pf_info(pf, "%s: Filter command send Status : Success\n",
-				__func__);
+			pf_info(pf, "Filter command send Status : Success\n");
 		} else {
-			pf_info(pf, "%s: Filter command send failed %d\n",
-				__func__, ret);
+			pf_info(pf, "Filter command send failed %d\n", ret);
 		}
 		kfree(fd_data.raw_packet);
 		fd_data.raw_packet = NULL;
@@ -1519,16 +1492,16 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			int ret;
 			ret = i40e_aq_stop_lldp(&pf->hw, false, NULL);
 			if (ret) {
-				pf_info(pf, "%s: Stop LLDP AQ command failed =0x%x\n",
-					__func__, pf->hw.aq.asq_last_status);
+				pf_info(pf, "Stop LLDP AQ command failed =0x%x\n",
+					pf->hw.aq.asq_last_status);
 				goto command_write_done;
 			}
 		} else if (strncmp(&cmd_buf[5], "start", 5) == 0) {
 			int ret;
 			ret = i40e_aq_start_lldp(&pf->hw, NULL);
 			if (ret) {
-				pf_info(pf, "%s: Start LLDP AQ command failed =0x%x\n",
-					__func__, pf->hw.aq.asq_last_status);
+				pf_info(pf, "Start LLDP AQ command failed =0x%x\n",
+					pf->hw.aq.asq_last_status);
 				goto command_write_done;
 			}
 		} else if (strncmp(&cmd_buf[5],
@@ -1545,14 +1518,13 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 						   buff, I40E_LLDPDU_SIZE,
 						   &llen, &rlen, NULL);
 			if (ret) {
-				pf_info(pf, "%s: Get LLDP MIB (local) AQ command failed =0x%x\n",
-					__func__, pf->hw.aq.asq_last_status);
+				pf_info(pf, "Get LLDP MIB (local) AQ command failed =0x%x\n",
+					pf->hw.aq.asq_last_status);
 				kfree(buff);
 				buff = NULL;
 				goto command_write_done;
 			}
-			pf_info(pf, "%s: Get LLDP MIB (local) AQ buffer written back:\n",
-				__func__);
+			pf_info(pf, "Get LLDP MIB (local) AQ buffer written back:\n");
 			for (i = 0; i < I40E_LLDPDU_SIZE; i++) {
 				snprintf(print_buf, 3, "%02x ", buff[i]);
 				print_buf += 3;
@@ -1578,14 +1550,13 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 					buff, I40E_LLDPDU_SIZE,
 					&llen, &rlen, NULL);
 			if (ret) {
-				pf_info(pf, "%s: Get LLDP MIB (remote) AQ command failed =0x%x\n",
-					__func__, pf->hw.aq.asq_last_status);
+				pf_info(pf, "Get LLDP MIB (remote) AQ command failed =0x%x\n",
+					pf->hw.aq.asq_last_status);
 				kfree(buff);
 				buff = NULL;
 				goto command_write_done;
 			}
-			pf_info(pf, "%s: Get LLDP MIB (remote) AQ buffer written back:\n",
-				__func__);
+			pf_info(pf, "Get LLDP MIB (remote) AQ buffer written back:\n");
 			for (i = 0; i < I40E_LLDPDU_SIZE; i++) {
 				snprintf(print_buf, 3, "%02x ", buff[i]);
 				print_buf += 3;
@@ -1602,8 +1573,8 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			ret = i40e_aq_cfg_lldp_mib_change_event(&pf->hw,
 								true, NULL);
 			if (ret) {
-				pf_info(pf, "%s: Config LLDP MIB Change Event (on) AQ command failed =0x%x\n",
-					__func__, pf->hw.aq.asq_last_status);
+				pf_info(pf, "Config LLDP MIB Change Event (on) AQ command failed =0x%x\n",
+					pf->hw.aq.asq_last_status);
 				goto command_write_done;
 			}
 		} else if (strncmp(&cmd_buf[5], "event off", 9) == 0) {
@@ -1611,8 +1582,8 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			ret = i40e_aq_cfg_lldp_mib_change_event(&pf->hw,
 								false, NULL);
 			if (ret) {
-				pf_info(pf, "%s: Config LLDP MIB Change Event (off) AQ command failed =0x%x\n",
-					__func__, pf->hw.aq.asq_last_status);
+				pf_info(pf, "Config LLDP MIB Change Event (off) AQ command failed =0x%x\n",
+					pf->hw.aq.asq_last_status);
 				goto command_write_done;
 			}
 		}
@@ -1635,8 +1606,8 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		} else if (cnt == 2) {
 			buffer_len = 0;
 		} else if (cnt > 3) {
-			pf_info(pf, "%s: nvm read: bad command string, cnt=%d\n",
-				__func__, cnt);
+			pf_info(pf, "nvm read: bad command string, cnt=%d\n",
+				cnt);
 			goto command_write_done;
 		}
 
@@ -1651,8 +1622,8 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 
 		ret = i40e_acquire_nvm(&pf->hw, I40E_RESOURCE_READ);
 		if (ret) {
-			pf_info(pf, "%s: Failed Acquiring NVM resource for read err=%d status=0x%x\n",
-				__func__, ret, pf->hw.aq.asq_last_status);
+			pf_info(pf, "Failed Acquiring NVM resource for read err=%d status=0x%x\n",
+				ret, pf->hw.aq.asq_last_status);
 			kfree(buff);
 			goto command_write_done;
 		}
@@ -1661,11 +1632,11 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 				       bytes, (u8 *)buff, true, NULL);
 		i40e_release_nvm(&pf->hw);
 		if (ret) {
-			pf_info(pf, "%s: Read NVM AQ failed err=%d status=0x%x\n",
-				__func__, ret, pf->hw.aq.asq_last_status);
+			pf_info(pf, "Read NVM AQ failed err=%d status=0x%x\n",
+				ret, pf->hw.aq.asq_last_status);
 		} else {
-			pf_info(pf, "%s: Read NVM module=0x%x offset=0x%x words=%d\n",
-				__func__, module, offset, buffer_len);
+			pf_info(pf, "Read NVM module=0x%x offset=0x%x words=%d\n",
+				module, offset, buffer_len);
 			for (i = 0; i < buffer_len; i++) {
 				if ((i % 16) == 0) {
 					snprintf(print_buf, 11, "\n0x%08x: ",
@@ -1680,48 +1651,40 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		kfree(buff);
 		buff = NULL;
 	} else {
-		pf_info(pf, "%s: unknown command '%s'\n", __func__, cmd_buf);
-		pf_info(pf, "%s: available commands\n", __func__);
-		pf_info(pf, "%s:   add vsi [relay_seid]\n", __func__);
-		pf_info(pf, "%s:   del vsi [vsi_seid]\n", __func__);
-		pf_info(pf, "%s:   add relay <uplink_seid> <vsi_seid>\n",
-			__func__);
-		pf_info(pf, "%s:   del relay <relay_seid>\n", __func__);
-		pf_info(pf, "%s:   add macaddr <vsi_seid> <aa:bb:cc:dd:ee:ff> [vlan]\n",
-			__func__);
-		pf_info(pf, "%s:   del macaddr <vsi_seid> <aa:bb:cc:dd:ee:ff> [vlan]\n",
-			__func__);
-		pf_info(pf, "%s:   add pvid <vsi_seid> <vid>\n", __func__);
-		pf_info(pf, "%s:   del pvid <vsi_seid>\n", __func__);
-		pf_info(pf, "%s:   dump switch\n", __func__);
-		pf_info(pf, "%s:   dump vsi [seid]\n", __func__);
-		pf_info(pf, "%s:   dump desc tx <vsi_seid> <ring_id> [<desc_n>]\n",
-			__func__);
-		pf_info(pf, "%s:   dump desc rx <vsi_seid> <ring_id> [<desc_n>]\n",
-			__func__);
-		pf_info(pf, "%s:   dump desc aq\n", __func__);
-		pf_info(pf, "%s:   dump stats\n", __func__);
-		pf_info(pf, "%s:   dump reset stats\n", __func__);
-		pf_info(pf, "%s:   msg_enable [level]\n", __func__);
-		pf_info(pf, "%s:   read <reg>\n", __func__);
-		pf_info(pf, "%s:   write <reg> <value>\n", __func__);
-		pf_info(pf, "%s:   clear_stats vsi [seid]\n", __func__);
-		pf_info(pf, "%s:   clear_stats pf\n", __func__);
-		pf_info(pf, "%s:   pfr\n", __func__);
-		pf_info(pf, "%s:   corer\n", __func__);
-		pf_info(pf, "%s:   globr\n", __func__);
-		pf_info(pf, "%s:   add fd_filter <dest q_index> <flex_off> <pctype> <dest_vsi> <dest_ctl> <fd_status> <cnt_index> <fd_id> <packet_len> <packet>\n",
-			__func__);
-		pf_info(pf, "%s:   rem fd_filter <dest q_index> <flex_off> <pctype> <dest_vsi> <dest_ctl> <fd_status> <cnt_index> <fd_id> <packet_len> <packet>\n",
-			__func__);
-		pf_info(pf, "%s:   lldp start\n", __func__);
-		pf_info(pf, "%s:   lldp stop\n", __func__);
-		pf_info(pf, "%s:   lldp get local\n", __func__);
-		pf_info(pf, "%s:   lldp get remote\n", __func__);
-		pf_info(pf, "%s:   lldp event on\n", __func__);
-		pf_info(pf, "%s:   lldp event off\n", __func__);
-		pf_info(pf, "%s:   nvm read [module] [word_offset] [word_count]\n",
-			__func__);
+		pf_info(pf, "unknown command '%s'\n", cmd_buf);
+		pf_info(pf, "available commands\n");
+		pf_info(pf, "  add vsi [relay_seid]\n");
+		pf_info(pf, "  del vsi [vsi_seid]\n");
+		pf_info(pf, "  add relay <uplink_seid> <vsi_seid>\n");
+		pf_info(pf, "  del relay <relay_seid>\n");
+		pf_info(pf, "  add macaddr <vsi_seid> <aa:bb:cc:dd:ee:ff> [vlan]\n");
+		pf_info(pf, "  del macaddr <vsi_seid> <aa:bb:cc:dd:ee:ff> [vlan]\n");
+		pf_info(pf, "  add pvid <vsi_seid> <vid>\n");
+		pf_info(pf, "  del pvid <vsi_seid>\n");
+		pf_info(pf, "  dump switch\n");
+		pf_info(pf, "  dump vsi [seid]\n");
+		pf_info(pf, "  dump desc tx <vsi_seid> <ring_id> [<desc_n>]\n");
+		pf_info(pf, "  dump desc rx <vsi_seid> <ring_id> [<desc_n>]\n");
+		pf_info(pf, "  dump desc aq\n");
+		pf_info(pf, "  dump stats\n");
+		pf_info(pf, "  dump reset stats\n");
+		pf_info(pf, "  msg_enable [level]\n");
+		pf_info(pf, "  read <reg>\n");
+		pf_info(pf, "  write <reg> <value>\n");
+		pf_info(pf, "  clear_stats vsi [seid]\n");
+		pf_info(pf, "  clear_stats pf\n");
+		pf_info(pf, "  pfr\n");
+		pf_info(pf, "  corer\n");
+		pf_info(pf, "  globr\n");
+		pf_info(pf, "  add fd_filter <dest q_index> <flex_off> <pctype> <dest_vsi> <dest_ctl> <fd_status> <cnt_index> <fd_id> <packet_len> <packet>\n");
+		pf_info(pf, "  rem fd_filter <dest q_index> <flex_off> <pctype> <dest_vsi> <dest_ctl> <fd_status> <cnt_index> <fd_id> <packet_len> <packet>\n");
+		pf_info(pf, "  lldp start\n");
+		pf_info(pf, "  lldp stop\n");
+		pf_info(pf, "  lldp get local\n");
+		pf_info(pf, "  lldp get remote\n");
+		pf_info(pf, "  lldp event on\n");
+		pf_info(pf, "  lldp event off\n");
+		pf_info(pf, "  nvm read [module] [word_offset] [word_count]\n");
 	}
 
 command_write_done:
@@ -1822,92 +1785,86 @@ static ssize_t i40e_dbg_netdev_ops_write(struct file *filp,
 	if (strncmp(i40e_dbg_netdev_ops_buf, "tx_timeout", 10) == 0) {
 		cnt = sscanf(&i40e_dbg_netdev_ops_buf[11], "%i", &vsi_seid);
 		if (cnt != 1) {
-			pf_info(pf, "%s: tx_timeout <vsi_seid>\n", __func__);
+			pf_info(pf, "tx_timeout <vsi_seid>\n");
 			goto netdev_ops_write_done;
 		}
 		vsi = i40e_dbg_find_vsi(pf, vsi_seid);
 		if (!vsi) {
-			pf_info(pf, "%s: tx_timeout: VSI %d not found\n",
-				__func__, vsi_seid);
+			pf_info(pf, "tx_timeout: VSI %d not found\n",
+				vsi_seid);
 			goto netdev_ops_write_done;
 		}
 		if (rtnl_trylock()) {
 			vsi->netdev->netdev_ops->ndo_tx_timeout(vsi->netdev);
 			rtnl_unlock();
-			pf_info(pf, "%s: tx_timeout called\n", __func__);
+			pf_info(pf, "tx_timeout called\n");
 		} else {
-			pf_info(pf, "%s: Could not acquire RTNL - please try again\n",
-				__func__);
+			pf_info(pf, "Could not acquire RTNL - please try again\n");
 		}
 	} else if (strncmp(i40e_dbg_netdev_ops_buf, "change_mtu", 10) == 0) {
 		int mtu;
 		cnt = sscanf(&i40e_dbg_netdev_ops_buf[11], "%i %i",
 			     &vsi_seid, &mtu);
 		if (cnt != 2) {
-			pf_info(pf, "%s: change_mtu <vsi_seid> <mtu>\n",
-				__func__);
+			pf_info(pf, "change_mtu <vsi_seid> <mtu>\n");
 			goto netdev_ops_write_done;
 		}
 		vsi = i40e_dbg_find_vsi(pf, vsi_seid);
 		if (!vsi) {
-			pf_info(pf, "%s: change_mtu: VSI %d not found\n",
-				__func__, vsi_seid);
+			pf_info(pf, "change_mtu: VSI %d not found\n",
+				vsi_seid);
 			goto netdev_ops_write_done;
 		}
 		if (rtnl_trylock()) {
 			vsi->netdev->netdev_ops->ndo_change_mtu(vsi->netdev,
 								mtu);
 			rtnl_unlock();
-			pf_info(pf, "%s: change_mtu called\n", __func__);
+			pf_info(pf, "change_mtu called\n");
 		} else {
-			pf_info(pf, "%s: Could not acquire RTNL - please try again\n",
-				__func__);
+			pf_info(pf, "Could not acquire RTNL - please try again\n");
 		}
 
 	} else if (strncmp(i40e_dbg_netdev_ops_buf, "set_rx_mode", 11) == 0) {
 		cnt = sscanf(&i40e_dbg_netdev_ops_buf[11], "%i", &vsi_seid);
 		if (cnt != 1) {
-			pf_info(pf, "%s: set_rx_mode <vsi_seid>\n", __func__);
+			pf_info(pf, "set_rx_mode <vsi_seid>\n");
 			goto netdev_ops_write_done;
 		}
 		vsi = i40e_dbg_find_vsi(pf, vsi_seid);
 		if (!vsi) {
-			pf_info(pf, "%s: set_rx_mode: VSI %d not found\n",
-				__func__, vsi_seid);
+			pf_info(pf, "set_rx_mode: VSI %d not found\n",
+				vsi_seid);
 			goto netdev_ops_write_done;
 		}
 		if (rtnl_trylock()) {
 			vsi->netdev->netdev_ops->ndo_set_rx_mode(vsi->netdev);
 			rtnl_unlock();
-			pf_info(pf, "%s: set_rx_mode called\n", __func__);
+			pf_info(pf, "set_rx_mode called\n");
 		} else {
-			pf_info(pf, "%s: Could not acquire RTNL - please try again\n",
-				__func__);
+			pf_info(pf, "Could not acquire RTNL - please try again\n");
 		}
 
 	} else if (strncmp(i40e_dbg_netdev_ops_buf, "napi", 4) == 0) {
 		cnt = sscanf(&i40e_dbg_netdev_ops_buf[4], "%i", &vsi_seid);
 		if (cnt != 1) {
-			pf_info(pf, "%s: napi <vsi_seid>\n", __func__);
+			pf_info(pf, "napi <vsi_seid>\n");
 			goto netdev_ops_write_done;
 		}
 		vsi = i40e_dbg_find_vsi(pf, vsi_seid);
 		if (!vsi) {
-			pf_info(pf, "%s: napi: VSI %d not found\n",
-				__func__, vsi_seid);
+			pf_info(pf, "napi: VSI %d not found\n", vsi_seid);
 			goto netdev_ops_write_done;
 		}
 		for (i = 0; i < vsi->num_q_vectors; i++)
 			napi_schedule(&vsi->q_vectors[i].napi);
-		pf_info(pf, "%s: napi called\n", __func__);
+		pf_info(pf, "napi called\n");
 	} else {
-		pf_info(pf, "%s: unknown command '%s'\n",
-			__func__, i40e_dbg_netdev_ops_buf);
-		pf_info(pf, "%s: available commands\n", __func__);
-		pf_info(pf, "%s:    tx_timeout <vsi_seid>\n", __func__);
-		pf_info(pf, "%s:    change_mtu <vsi_seid> <mtu>\n", __func__);
-		pf_info(pf, "%s:    set_rx_mode <vsi_seid>\n", __func__);
-		pf_info(pf, "%s:    napi <vsi_seid>\n", __func__);
+		pf_info(pf, "unknown command '%s'\n", i40e_dbg_netdev_ops_buf);
+		pf_info(pf, "available commands\n");
+		pf_info(pf, "   tx_timeout <vsi_seid>\n");
+		pf_info(pf, "   change_mtu <vsi_seid> <mtu>\n");
+		pf_info(pf, "   set_rx_mode <vsi_seid>\n");
+		pf_info(pf, "   napi <vsi_seid>\n");
 	}
 netdev_ops_write_done:
 	return count;
@@ -1938,8 +1895,7 @@ void i40e_dbg_pf_init(struct i40e_pf *pf)
 		pfile = debugfs_create_file("netdev_ops", 0600, pf->i40e_dbg_pf,
 					    pf, &i40e_dbg_netdev_ops_fops);
 	} else {
-		pf_info(pf, "%s: debugfs entry for %s failed\n",
-			__func__, name);
+		pf_info(pf, "debugfs entry for %s failed\n", name);
 	}
 }
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 87093da..8f94423 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1164,12 +1164,12 @@ static i40e_status i40e_add_del_fdir_udpv4(struct i40e_vsi *vsi,
 		ret = i40e_program_fdir_filter(fd_data, pf, add);
 
 		if (ret != I40E_SUCCESS) {
-			pf_info(pf, "%s: Filter command send failed for PCTYPE %d (ret = %d)\n",
-				__func__, fd_data->pctype, ret);
+			pf_info(pf, "Filter command send failed for PCTYPE %d (ret = %d)\n",
+				fd_data->pctype, ret);
 			err = true;
 		} else {
-			pf_info(pf, "%s: Filter OK for PCTYPE %d (ret = %d)\n",
-				__func__, fd_data->pctype, ret);
+			pf_info(pf, "Filter OK for PCTYPE %d (ret = %d)\n",
+				fd_data->pctype, ret);
 		}
 	}
 
@@ -1207,12 +1207,12 @@ static i40e_status i40e_add_del_fdir_tcpv4(struct i40e_vsi *vsi,
 	ret = i40e_program_fdir_filter(fd_data, pf, add);
 
 	if (ret != I40E_SUCCESS) {
-		pf_info(pf, "%s: Filter command send failed for PCTYPE %d (ret = %d)\n",
-			__func__, fd_data->pctype, ret);
+		pf_info(pf, "Filter command send failed for PCTYPE %d (ret = %d)\n",
+			fd_data->pctype, ret);
 			err = true;
 	} else {
-		pf_info(pf, "%s: Filter OK for PCTYPE %d (ret = %d)\n",
-			__func__, fd_data->pctype, ret);
+		pf_info(pf, "Filter OK for PCTYPE %d (ret = %d)\n",
+			fd_data->pctype, ret);
 	}
 
 	ip->saddr = fsp->h_u.tcp_ip4_spec.ip4src;
@@ -1221,12 +1221,12 @@ static i40e_status i40e_add_del_fdir_tcpv4(struct i40e_vsi *vsi,
 	fd_data->pctype = I40E_FILTER_PCTYPE_NONF_IPV4_TCP;
 
 	if (ret != I40E_SUCCESS) {
-		pf_info(pf, "%s: Filter command send failed for PCTYPE %d (ret = %d)\n",
-			__func__, fd_data->pctype, ret);
+		pf_info(pf, "Filter command send failed for PCTYPE %d (ret = %d)\n",
+			fd_data->pctype, ret);
 			err = true;
 	} else {
-		pf_info(pf, "%s: Filter OK for PCTYPE %d (ret = %d)\n",
-			__func__, fd_data->pctype, ret);
+		pf_info(pf, "Filter OK for PCTYPE %d (ret = %d)\n",
+			fd_data->pctype, ret);
 	}
 
 	return err ? -EOPNOTSUPP : I40E_SUCCESS;
@@ -1282,12 +1282,12 @@ static i40e_status i40e_add_del_fdir_ipv4(struct i40e_vsi *vsi,
 		ret = i40e_program_fdir_filter(fd_data, pf, add);
 
 		if (ret != I40E_SUCCESS) {
-			pf_info(pf, "%s: Filter command send failed for PCTYPE %d (ret = %d)\n",
-				__func__, fd_data->pctype, ret);
+			pf_info(pf, "Filter command send failed for PCTYPE %d (ret = %d)\n",
+				fd_data->pctype, ret);
 				err = true;
 		} else {
-			pf_info(pf, "%s: Filter OK for PCTYPE %d (ret = %d)\n",
-				__func__, fd_data->pctype, ret);
+			pf_info(pf, "Filter OK for PCTYPE %d (ret = %d)\n",
+				fd_data->pctype, ret);
 		}
 	}
 
@@ -1328,7 +1328,7 @@ static int i40e_add_del_fdir_ethtool(struct i40e_vsi *vsi,
 				     GFP_KERNEL);
 
 	if (!fd_data.raw_packet) {
-		pf_info(pf, "%s: Could not allocate memory\n", __func__);
+		pf_info(pf, "Could not allocate memory\n");
 		return -ENOMEM;
 	}
 
@@ -1371,7 +1371,7 @@ static int i40e_add_del_fdir_ethtool(struct i40e_vsi *vsi,
 		}
 		break;
 	default:
-		pf_info(pf, "%s: Could not specify spec type\n", __func__);
+		pf_info(pf, "Could not specify spec type\n");
 		ret = -EINVAL;
 	}
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index f3139f6..d1f6744 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -188,8 +188,8 @@ static int i40e_get_lump(struct i40e_pf *pf, struct i40e_lump_tracking *pile,
 	int j = 0;
 
 	if (pile == NULL || needed == 0 || id >= I40E_PILE_VALID_BIT) {
-		pf_info(pf, "%s: param err: pile=%p needed=%d id=0x%04x\n",
-			__func__, pile, needed, id);
+		pf_info(pf, "param err: pile=%p needed=%d id=0x%04x\n",
+			pile, needed, id);
 		return I40E_ERR_PARAM;
 	}
 
@@ -1012,8 +1012,8 @@ i40e_status i40e_put_mac_in_vlan(struct i40e_vsi *vsi, u8 *macaddr,
 						is_vf, is_netdev);
 
 			if (NULL == add_f) {
-				pf_info(vsi->back, "%s: Could not add filter %d for %pM\n",
-					__func__, f->vlan, f->macaddr);
+				pf_info(vsi->back, "Could not add filter %d for %pM\n",
+					f->vlan, f->macaddr);
 				return -ENOMEM;
 			}
 		}
@@ -1218,8 +1218,7 @@ static void i40e_vsi_setup_queue_map(struct i40e_vsi *vsi,
 				numtc++;
 		}
 		if (!numtc) {
-			pf_warn(pf, "%s: DCB is enabled but no TC enabled, forcing TC0\n",
-				__func__);
+			pf_warn(pf, "DCB is enabled but no TC enabled, forcing TC0\n");
 			numtc = 1;
 		}
 	} else {
@@ -1469,9 +1468,8 @@ i40e_status i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 				memset(del_list, 0, sizeof(*del_list));
 
 				if (ret != I40E_SUCCESS)
-					pf_info(pf, "%s: ignoring delete macvlan error, err %d, aq_err %d while flashing a full buffer\n",
-						__func__, ret,
-						pf->hw.aq.asq_last_status);
+					pf_info(pf, "ignoring delete macvlan error, err %d, aq_err %d while flashing a full buffer\n",
+						ret, pf->hw.aq.asq_last_status);
 			}
 		}
 		if (num_del) {
@@ -1480,9 +1478,8 @@ i40e_status i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 			num_del = 0;
 
 			if (ret != I40E_SUCCESS)
-				pf_info(pf, "%s: ignoring delete macvlan error, err %d, aq_err %d\n",
-					__func__, ret,
-					pf->hw.aq.asq_last_status);
+				pf_info(pf, "ignoring delete macvlan error, err %d, aq_err %d\n",
+					ret, pf->hw.aq.asq_last_status);
 		}
 
 		kfree(del_list);
@@ -1550,16 +1547,15 @@ i40e_status i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 		if (add_happened && (ret == I40E_SUCCESS)) {
 			/* do nothing */;
 		} else if (add_happened && (ret != I40E_SUCCESS)) {
-			pf_info(pf, "%s: add filter failed, err %d, aq_err %d\n",
-				__func__, ret, pf->hw.aq.asq_last_status);
+			pf_info(pf, "add filter failed, err %d, aq_err %d\n",
+				ret, pf->hw.aq.asq_last_status);
 			if ((pf->hw.aq.asq_last_status == I40E_AQ_RC_ENOSPC) &&
 			    !test_bit(__I40E_FILTER_OVERFLOW_PROMISC,
 				      &vsi->state)) {
 				promisc_forced_on = true;
 				set_bit(__I40E_FILTER_OVERFLOW_PROMISC,
 					&vsi->state);
-				pf_info(pf, "%s: promiscuous mode forced on\n",
-					__func__);
+				pf_info(pf, "promiscuous mode forced on\n");
 			}
 		}
 	}
@@ -1573,8 +1569,8 @@ i40e_status i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 							    cur_multipromisc,
 							    NULL);
 		if (ret != I40E_SUCCESS)
-			pf_info(pf, "%s: set multi promisc failed, err %d, aq_err %d\n",
-				__func__, ret, pf->hw.aq.asq_last_status);
+			pf_info(pf, "set multi promisc failed, err %d, aq_err %d\n",
+				ret, pf->hw.aq.asq_last_status);
 	}
 	if ((changed_flags & IFF_PROMISC) || promisc_forced_on) {
 		bool cur_promisc;
@@ -1586,8 +1582,8 @@ i40e_status i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 							  cur_promisc,
 							  NULL);
 		if (ret != I40E_SUCCESS)
-			pf_info(pf, "%s: set uni promisc failed, err %d, aq_err %d\n",
-				__func__, ret, pf->hw.aq.asq_last_status);
+			pf_info(pf, "set uni promisc failed, err %d, aq_err %d\n",
+				ret, pf->hw.aq.asq_last_status);
 	}
 
 	clear_bit(__I40E_CONFIG_BUSY, &vsi->state);
@@ -1661,8 +1657,8 @@ void i40e_vlan_stripping_enable(struct i40e_vsi *vsi)
 	memcpy(&ctxt.info, &vsi->info, sizeof(vsi->info));
 	ret = i40e_aq_update_vsi_params(&vsi->back->hw, &ctxt, NULL);
 	if (ret != I40E_SUCCESS) {
-		pf_info(vsi->back, "%s: update vsi failed, aq_err=%d\n",
-			__func__, vsi->back->hw.aq.asq_last_status);
+		pf_info(vsi->back, "update vsi failed, aq_err=%d\n",
+			vsi->back->hw.aq.asq_last_status);
 	}
 }
 
@@ -1689,8 +1685,8 @@ void i40e_vlan_stripping_disable(struct i40e_vsi *vsi)
 	memcpy(&ctxt.info, &vsi->info, sizeof(vsi->info));
 	ret = i40e_aq_update_vsi_params(&vsi->back->hw, &ctxt, NULL);
 	if (ret != I40E_SUCCESS) {
-		pf_info(vsi->back, "%s: update vsi failed, aq_err=%d\n",
-			__func__, vsi->back->hw.aq.asq_last_status);
+		pf_info(vsi->back, "update vsi failed, aq_err=%d\n",
+			vsi->back->hw.aq.asq_last_status);
 	}
 }
 
@@ -1728,8 +1724,8 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 		add_f = i40e_add_filter(vsi, vsi->netdev->dev_addr, vid,
 					is_vf, is_netdev);
 		if (add_f == NULL) {
-			pf_info(vsi->back, "%s: Could not add vlan filter %d for %pM\n",
-				__func__, vid, vsi->netdev->dev_addr);
+			pf_info(vsi->back, "Could not add vlan filter %d for %pM\n",
+				vid, vsi->netdev->dev_addr);
 			return -ENOMEM;
 		}
 	}
@@ -1738,16 +1734,15 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 		add_f = i40e_add_filter(vsi, f->macaddr, vid,
 					is_vf, is_netdev);
 		if (add_f == NULL) {
-			pf_info(vsi->back, "%s: Could not add vlan filter %d for %pM\n",
-				__func__, vid, f->macaddr);
+			pf_info(vsi->back, "Could not add vlan filter %d for %pM\n",
+				vid, f->macaddr);
 			return -ENOMEM;
 		}
 	}
 
 	ret = i40e_sync_vsi_filters(vsi);
 	if (ret != I40E_SUCCESS) {
-		pf_info(vsi->back, "%s: Could not sync filters for vid %d\n",
-			__func__, vid);
+		pf_info(vsi->back, "Could not sync filters for vid %d\n", vid);
 		return ret;
 	}
 
@@ -1766,8 +1761,8 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 			add_f = i40e_add_filter(vsi, vsi->netdev->dev_addr, 0,
 					    is_vf, is_netdev);
 			if (add_f == NULL) {
-				pf_info(vsi->back, "%s: Could not add filter 0 for %pM\n",
-					__func__, vsi->netdev->dev_addr);
+				pf_info(vsi->back, "Could not add filter 0 for %pM\n",
+					vsi->netdev->dev_addr);
 				return -ENOMEM;
 			}
 		}
@@ -1780,8 +1775,8 @@ int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
 				add_f = i40e_add_filter(vsi, f->macaddr,
 					       0, is_vf, is_netdev);
 				if (add_f == NULL) {
-					pf_info(vsi->back, "%s: Could not add filter 0 for %pM\n",
-						__func__, f->macaddr);
+					pf_info(vsi->back, "Could not add filter 0 for %pM\n",
+						f->macaddr);
 					return -ENOMEM;
 				}
 			}
@@ -1816,7 +1811,7 @@ int i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
 
 	ret = i40e_sync_vsi_filters(vsi);
 	if (ret != I40E_SUCCESS) {
-		pf_info(vsi->back, "%s: Could not sync filters\n", __func__);
+		pf_info(vsi->back, "Could not sync filters\n");
 		return ret;
 	}
 
@@ -1842,8 +1837,8 @@ int i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
 		f = i40e_add_filter(vsi, netdev->dev_addr, I40E_VLAN_ANY,
 				    is_vf, is_netdev);
 		if (f == NULL) {
-			pf_info(vsi->back, "%s: Could not add filter %d for %pM\n",
-				__func__, I40E_VLAN_ANY, netdev->dev_addr);
+			pf_info(vsi->back, "Could not add filter %d for %pM\n",
+				I40E_VLAN_ANY, netdev->dev_addr);
 			return -ENOMEM;
 		}
 	}
@@ -1854,8 +1849,8 @@ int i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
 			add_f = i40e_add_filter(vsi, f->macaddr, I40E_VLAN_ANY,
 					    is_vf, is_netdev);
 			if (add_f == NULL) {
-				pf_info(vsi->back, "%s: Could not add filter %d for %pM\n",
-					__func__, I40E_VLAN_ANY, f->macaddr);
+				pf_info(vsi->back, "Could not add filter %d for %pM\n",
+					I40E_VLAN_ANY, f->macaddr);
 				return -ENOMEM;
 			}
 		}
@@ -1955,8 +1950,8 @@ i40e_status i40e_vsi_add_pvid(struct i40e_vsi *vsi, u16 vid)
 	memcpy(&ctxt.info, &vsi->info, sizeof(vsi->info));
 	ret = i40e_aq_update_vsi_params(&vsi->back->hw, &ctxt, NULL);
 	if (ret != I40E_SUCCESS) {
-		pf_info(vsi->back, "%s: update vsi failed, aq_err=%d\n",
-			__func__, vsi->back->hw.aq.asq_last_status);
+		pf_info(vsi->back, "update vsi failed, aq_err=%d\n",
+			vsi->back->hw.aq.asq_last_status);
 	}
 
 	return ret;
@@ -2093,16 +2088,16 @@ static s32 i40e_configure_tx_ring(struct i40e_ring *ring)
 	/* clear the context in the HMC */
 	err = i40e_clear_lan_tx_queue_context(hw, pf_q);
 	if (err != I40E_SUCCESS) {
-		pf_info(vsi->back, "%s: Failed to clear LAN Tx queue context on Tx ring %d (pf_q %d), error: %d\n",
-			__func__, ring->queue_index, pf_q, err);
+		pf_info(vsi->back, "Failed to clear LAN Tx queue context on Tx ring %d (pf_q %d), error: %d\n",
+			ring->queue_index, pf_q, err);
 		return err;
 	}
 
 	/* set the context in the HMC */
 	err = i40e_set_lan_tx_queue_context(hw, pf_q, &tx_ctx);
 	if (err != I40E_SUCCESS) {
-		pf_info(vsi->back, "%s: Failed to set LAN Tx queue context on Tx ring %d (pf_q %d, error: %d\n",
-			__func__, ring->queue_index, pf_q, err);
+		pf_info(vsi->back, "Failed to set LAN Tx queue context on Tx ring %d (pf_q %d, error: %d\n",
+			ring->queue_index, pf_q, err);
 		return err;
 	}
 
@@ -2182,16 +2177,16 @@ static s32 i40e_configure_rx_ring(struct i40e_ring *ring)
 	/* clear the context in the HMC */
 	err = i40e_clear_lan_rx_queue_context(hw, pf_q);
 	if (err != I40E_SUCCESS) {
-		pf_info(vsi->back, "%s: Failed to clear LAN Rx queue context on Rx ring %d (pf_q %d), error: %d\n",
-			__func__, ring->queue_index, pf_q, err);
+		pf_info(vsi->back, "Failed to clear LAN Rx queue context on Rx ring %d (pf_q %d), error: %d\n",
+			ring->queue_index, pf_q, err);
 		return err;
 	}
 
 	/* set the context in the HMC */
 	err = i40e_set_lan_rx_queue_context(hw, pf_q, &rx_ctx);
 	if (err != I40E_SUCCESS) {
-		pf_info(vsi->back, "%s: Failed to set LAN Rx queue context on Rx ring %d (pf_q %d), error: %d\n",
-			__func__, ring->queue_index, pf_q, err);
+		pf_info(vsi->back, "Failed to set LAN Rx queue context on Rx ring %d (pf_q %d), error: %d\n",
+			ring->queue_index, pf_q, err);
 		return err;
 	}
 
@@ -2568,8 +2563,7 @@ static int i40e_vsi_request_irq_msix(struct i40e_vsi *vsi, char *basename)
 				  q_vector->name,
 				  q_vector);
 		if (err) {
-			pf_info(pf, "%s: request_irq failed, error: %d\n",
-				__func__, err);
+			pf_info(pf, "request_irq failed, error: %d\n", err);
 			goto free_queue_irqs;
 		}
 		/* assign the mask for this irq */
@@ -2755,15 +2749,14 @@ static irqreturn_t i40e_intr(int irq, void *data)
 	 */
 	icr0_remaining = icr0 & ena_mask;
 	if (icr0_remaining) {
-		pf_info(pf, "%s: unhandled interrupt icr0=0x%08x\n",
-			__func__, icr0_remaining);
+		pf_info(pf, "unhandled interrupt icr0=0x%08x\n",
+			icr0_remaining);
 		if ((icr0_remaining & I40E_PFINT_ICR0_HMC_ERR_MASK) ||
 		    (icr0_remaining & I40E_PFINT_ICR0_PE_CRITERR_MASK) ||
 		    (icr0_remaining & I40E_PFINT_ICR0_PCI_EXCEPTION_MASK) ||
 		    (icr0_remaining & I40E_PFINT_ICR0_ECC_ERR_MASK) ||
 		    (icr0_remaining & I40E_PFINT_ICR0_MAL_DETECT_MASK)) {
-			pf_info(pf, "%s: error: device will be reset\n",
-				__func__);
+			pf_info(pf, "error: device will be reset\n");
 			set_bit(__I40E_PF_RESET_REQUESTED, &pf->state);
 			i40e_service_event_schedule(pf);
 		}
@@ -2871,8 +2864,7 @@ static int i40e_vsi_request_irq(struct i40e_vsi *vsi, char *basename)
 				  basename, pf);
 
 	if (err) {
-		pf_info(pf, "%s: request_irq failed, Error %d\n",
-			__func__, err);
+		pf_info(pf, "request_irq failed, Error %d\n", err);
 
 		/* place q_vectors and rings back into a known good state */
 		i40e_vsi_unmap_rings_to_vectors(vsi);
@@ -2935,15 +2927,13 @@ static int i40e_vsi_control_tx(struct i40e_vsi *vsi, bool enable)
 		if (enable) {
 			/* is STAT set ? */
 			if ((tx_reg & I40E_QTX_ENA_QENA_STAT_MASK)) {
-				pf_info(pf, "%s: Tx %d already enabled\n",
-					__func__, i);
+				pf_info(pf, "Tx %d already enabled\n", i);
 				continue;
 			}
 		} else {
 			/* is !STAT set ? */
 			if (!(tx_reg & I40E_QTX_ENA_QENA_STAT_MASK)) {
-				pf_info(pf, "%s: Tx %d already disabled\n",
-					__func__, i);
+				pf_info(pf, "Tx %d already disabled\n", i);
 				continue;
 			}
 		}
@@ -2971,8 +2961,8 @@ static int i40e_vsi_control_tx(struct i40e_vsi *vsi, bool enable)
 			udelay(10);
 		}
 		if (j >= 10) {
-			pf_info(pf, "%s: Tx ring %d %sable timeout\n",
-				__func__, pf_q, (enable ? "en" : "dis"));
+			pf_info(pf, "Tx ring %d %sable timeout\n",
+				pf_q, (enable ? "en" : "dis"));
 		}
 	}
 
@@ -3034,8 +3024,8 @@ static int i40e_vsi_control_rx(struct i40e_vsi *vsi, bool enable)
 			udelay(10);
 		}
 		if (j >= 10) {
-			pf_info(pf, "%s: Rx ring %d %sable timeout\n",
-				__func__, pf_q, (enable ? "en" : "dis"));
+			pf_info(pf, "Rx ring %d %sable timeout\n",
+				pf_q, (enable ? "en" : "dis"));
 			return I40E_ERR_TIMEOUT;
 		}
 	}
@@ -3474,8 +3464,8 @@ static s32 i40e_vsi_get_bw_info(struct i40e_vsi *vsi)
 	/* Get the VSI level BW configuration */
 	ret = i40e_aq_query_vsi_bw_config(hw, vsi->seid, &bw_config, NULL);
 	if (ret) {
-		pf_info(pf, "%s: couldn't get pf vsi bw config, err %d, aq_err %d\n",
-			__func__, ret, pf->hw.aq.asq_last_status);
+		pf_info(pf, "couldn't get pf vsi bw config, err %d, aq_err %d\n",
+			ret, pf->hw.aq.asq_last_status);
 		return ret;
 	}
 
@@ -3484,14 +3474,14 @@ static s32 i40e_vsi_get_bw_info(struct i40e_vsi *vsi)
 					       &bw_ets_config,
 					       NULL);
 	if (ret) {
-		pf_info(pf, "%s: couldn't get pf vsi ets bw config, err %d, aq_err %d\n",
-			__func__, ret, pf->hw.aq.asq_last_status);
+		pf_info(pf, "couldn't get pf vsi ets bw config, err %d, aq_err %d\n",
+			ret, pf->hw.aq.asq_last_status);
 		return ret;
 	}
 
 	if (bw_config.tc_valid_bits != bw_ets_config.tc_valid_bits) {
-		pf_info(pf, "%s: Enabled TCs mismatch from querying VSI BW info 0x%08x 0x%08x\n",
-			__func__, bw_config.tc_valid_bits,
+		pf_info(pf, "Enabled TCs mismatch from querying VSI BW info 0x%08x 0x%08x\n",
+			bw_config.tc_valid_bits,
 			bw_ets_config.tc_valid_bits);
 		/* Still continuing */
 	}
@@ -3532,8 +3522,8 @@ static s32 i40e_vsi_configure_bw_alloc(struct i40e_vsi *vsi,
 	ret = i40e_aq_config_vsi_tc_bw(&vsi->back->hw, vsi->seid,
 				       &bw_data, NULL);
 	if (ret != I40E_SUCCESS) {
-		pf_info(vsi->back, "%s: AQ command Config VSI BW allocation per TC failed = %d\n",
-			__func__, vsi->back->hw.aq.asq_last_status);
+		pf_info(vsi->back, "AQ command Config VSI BW allocation per TC failed = %d\n",
+			vsi->back->hw.aq.asq_last_status);
 		return ret;
 	}
 
@@ -3647,8 +3637,8 @@ static s32 i40e_vsi_config_tc(struct i40e_vsi *vsi, u8 enabled_tc)
 
 	ret = i40e_vsi_configure_bw_alloc(vsi, enabled_tc, bw_share);
 	if (ret) {
-		pf_info(vsi->back, "%s: Failed configuring TC map %d for VSI %d\n",
-			__func__,  enabled_tc, vsi->seid);
+		pf_info(vsi->back, "Failed configuring TC map %d for VSI %d\n",
+			enabled_tc, vsi->seid);
 		goto out;
 	}
 
@@ -3663,8 +3653,8 @@ static s32 i40e_vsi_config_tc(struct i40e_vsi *vsi, u8 enabled_tc)
 	/* Update the VSI after updating the VSI queue-mapping information */
 	ret = i40e_aq_update_vsi_params(&vsi->back->hw, &ctxt, NULL);
 	if (ret != I40E_SUCCESS) {
-		pf_info(vsi->back, "%s: update vsi failed, aq_err=%d\n",
-			__func__, vsi->back->hw.aq.asq_last_status);
+		pf_info(vsi->back, "update vsi failed, aq_err=%d\n",
+			vsi->back->hw.aq.asq_last_status);
 		goto out;
 	}
 	/* update the local VSI info with updated queue map */
@@ -3674,8 +3664,8 @@ static s32 i40e_vsi_config_tc(struct i40e_vsi *vsi, u8 enabled_tc)
 	/* Update current VSI BW information */
 	ret = i40e_vsi_get_bw_info(vsi);
 	if (ret != I40E_SUCCESS) {
-		pf_info(vsi->back, "%s: Failed updating vsi bw info, aq_err=%d\n",
-			__func__, vsi->back->hw.aq.asq_last_status);
+		pf_info(vsi->back, "Failed updating vsi bw info, aq_err=%d\n",
+			vsi->back->hw.aq.asq_last_status);
 		goto out;
 	}
 
@@ -3971,7 +3961,7 @@ void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags)
 		 * for the warning interrupt will deal with the shutdown
 		 * and recovery of the switch setup.
 		 */
-		pf_info(pf, "%s: GlobalR requested\n", __func__);
+		pf_info(pf, "GlobalR requested\n");
 		val = rd32(&pf->hw, I40E_GLGEN_RTRIG);
 		val |= I40E_GLGEN_RTRIG_GLOBR_MASK;
 		wr32(&pf->hw, I40E_GLGEN_RTRIG, val);
@@ -3981,7 +3971,7 @@ void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags)
 		 *
 		 * Same as Global Reset, except does *not* include the MAC/PHY
 		 */
-		pf_info(pf, "%s: CoreR requested\n", __func__);
+		pf_info(pf, "CoreR requested\n");
 		val = rd32(&pf->hw, I40E_GLGEN_RTRIG);
 		val |= I40E_GLGEN_RTRIG_CORER_MASK;
 		wr32(&pf->hw, I40E_GLGEN_RTRIG, val);
@@ -3996,14 +3986,14 @@ void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags)
 		 * the switch, since we need to do all the recovery as
 		 * for the Core Reset.
 		 */
-		pf_info(pf, "%s: PFR requested\n", __func__);
+		pf_info(pf, "PFR requested\n");
 		i40e_handle_reset_warning(pf);
 
 	} else if (reset_flags & (1 << __I40E_REINIT_REQUESTED)) {
 		int v;
 
 		/* Find the VSI(s) that requested a re-init */
-		pf_info(pf, "%s: VSI reinit requested\n", __func__);
+		pf_info(pf, "VSI reinit requested\n");
 		for (v = 0; v < pf->hw.func_caps.num_vsis; v++) {
 			struct i40e_vsi *vsi = pf->vsi[v];
 			if (vsi != NULL &&
@@ -4016,8 +4006,7 @@ void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags)
 		/* no further action needed, so return now */
 		return;
 	} else {
-		pf_info(pf, "%s: bad reset request 0x%08x\n",
-			__func__, reset_flags);
+		pf_info(pf, "bad reset request 0x%08x\n", reset_flags);
 		return;
 	}
 }
@@ -4041,8 +4030,7 @@ static void i40e_handle_lan_overflow_event(struct i40e_pf *pf,
 	struct i40e_vf *vf;
 	u16 vf_id;
 
-	pf_info(pf, "%s: Rx Queue Number = %d QTX_CTL=0x%08x\n",
-		__func__, queue, qtx_ctl);
+	pf_info(pf, "Rx Queue Number = %d QTX_CTL=0x%08x\n", queue, qtx_ctl);
 
 	/* Queue belongs to VF, find the VF and issue VF reset */
 	if (((qtx_ctl & I40E_QTX_CTL_PFVF_Q_MASK)
@@ -4361,10 +4349,10 @@ static void i40e_clean_adminq_subtask(struct i40e_pf *pf)
 	do {
 		ret = i40e_clean_arq_element(hw, &event, &pending);
 		if (ret == I40E_ERR_ADMIN_QUEUE_NO_WORK) {
-			pf_info(pf, "%s: No ARQ event found\n", __func__);
+			pf_info(pf, "No ARQ event found\n");
 			break;
 		} else if (ret) {
-			pf_info(pf, "%s: ARQ event error %d\n", __func__, ret);
+			pf_info(pf, "ARQ event error %d\n", ret);
 			break;
 		}
 
@@ -4382,22 +4370,19 @@ static void i40e_clean_adminq_subtask(struct i40e_pf *pf)
 					event.msg_size);
 			break;
 		case i40e_aqc_opc_lldp_update_mib:
-			pf_info(pf, "%s: ARQ: Update LLDP MIB event received\n",
-				__func__);
+			pf_info(pf, "ARQ: Update LLDP MIB event received\n");
 			break;
 		case i40e_aqc_opc_event_lan_overflow:
-			pf_info(pf, "%s: ARQ LAN queue overflow event received\n",
-				__func__);
+			pf_info(pf, "ARQ LAN queue overflow event received\n");
 			i40e_handle_lan_overflow_event(pf, &event);
 			break;
 		default:
-			pf_info(pf, "%s: ARQ Error: Unknown event %d received\n",
-				__func__, event.desc.opcode);
+			pf_info(pf, "ARQ Error: Unknown event %d received\n",
+				event.desc.opcode);
 			break;
 		}
 		if (pending != 0)
-			pf_info(pf, "%s: ARQ: Pending events %d\n",
-				__func__, pending);
+			pf_info(pf, "ARQ: Pending events %d\n", pending);
 	} while (pending && (i++ < pf->adminq_work_limit));
 
 	clear_bit(__I40E_ADMINQ_EVENT_PENDING, &pf->state);
@@ -4436,8 +4421,7 @@ static s32 i40e_reconstitute_veb(struct i40e_veb *veb)
 		}
 	}
 	if (ctl_vsi == NULL) {
-		pf_info(pf, "%s: missing owner VSI for veb_idx %d\n",
-			__func__, veb->idx);
+		pf_info(pf, "missing owner VSI for veb_idx %d\n", veb->idx);
 		ret = I40E_ERR_NO_AVAILABLE_VSI;
 		goto end_reconstitute;
 	}
@@ -4445,8 +4429,7 @@ static s32 i40e_reconstitute_veb(struct i40e_veb *veb)
 		ctl_vsi->uplink_seid = pf->vsi[pf->lan_vsi]->uplink_seid;
 	ret = i40e_add_vsi(ctl_vsi);
 	if (ret != I40E_SUCCESS) {
-		pf_info(pf, "%s: rebuild of owner VSI failed: %d\n",
-			__func__, ret);
+		pf_info(pf, "rebuild of owner VSI failed: %d\n", ret);
 		goto end_reconstitute;
 	}
 	i40e_sys_add_vsi(ctl_vsi);
@@ -4467,8 +4450,8 @@ static s32 i40e_reconstitute_veb(struct i40e_veb *veb)
 			vsi->uplink_seid = veb->seid;
 			ret = i40e_add_vsi(vsi);
 			if (ret != I40E_SUCCESS) {
-				pf_info(pf, "%s: rebuild of vsi_idx %d failed: %d\n",
-					__func__, v, ret);
+				pf_info(pf, "rebuild of vsi_idx %d failed: %d\n",
+					v, ret);
 				goto end_reconstitute;
 			}
 			i40e_sys_add_vsi(vsi);
@@ -4519,15 +4502,15 @@ static i40e_status i40e_get_capabilities(struct i40e_pf *pf)
 			/* retry with a larger buffer */
 			buf_len = data_size;
 		} else if (pf->hw.aq.asq_last_status != I40E_AQ_RC_OK) {
-			pf_info(pf, "%s: capability discovery failed: aq=%d\n",
-				__func__, pf->hw.aq.asq_last_status);
+			pf_info(pf, "capability discovery failed: aq=%d\n",
+				pf->hw.aq.asq_last_status);
 			return err;
 		}
 	} while (err != I40E_SUCCESS);
 
 	if (pf->hw.debug_mask & I40E_DEBUG_USER)
-		pf_info(pf, "%s: pf=%d, num_vfs=%d, msix_pf=%d, msix_vf=%d, fd_g=%d, fd_b=%d, pf_max_q=%d num_vsi=%d\n",
-			__func__, pf->hw.pf_id, pf->hw.func_caps.num_vfs,
+		pf_info(pf, "pf=%d, num_vfs=%d, msix_pf=%d, msix_vf=%d, fd_g=%d, fd_b=%d, pf_max_q=%d num_vsi=%d\n",
+			pf->hw.pf_id, pf->hw.func_caps.num_vfs,
 			pf->hw.func_caps.num_msix_vectors,
 			pf->hw.func_caps.num_msix_vectors_vf,
 			pf->hw.func_caps.fd_filters_guaranteed,
@@ -4561,7 +4544,7 @@ static void i40e_fdir_setup(struct i40e_pf *pf)
 	if (!vsi) {
 		vsi = i40e_vsi_setup(pf, I40E_VSI_FDIR, pf->mac_seid, 0);
 		if (!vsi) {
-			pf_info(pf, "%s: Couldn't create FDir VSI\n", __func__);
+			pf_info(pf, "Couldn't create FDir VSI\n");
 			pf->flags &= ~I40E_FLAG_FDIR_ENABLED;
 			return;
 		}
@@ -4621,7 +4604,7 @@ static void i40e_handle_reset_warning(struct i40e_pf *pf)
 	if (test_and_set_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state))
 		return;
 
-	pf_info(pf, "%s: Tearing down internal switch for reset\n", __func__);
+	pf_info(pf, "Tearing down internal switch for reset\n");
 
 	i40e_vc_notify_reset(pf);
 
@@ -4645,32 +4628,31 @@ static void i40e_handle_reset_warning(struct i40e_pf *pf)
 	 */
 	ret = i40e_pf_reset(hw);
 	if (ret != I40E_SUCCESS) {
-		pf_info(pf, "%s: PF reset failed, %d\n", __func__, ret);
+		pf_info(pf, "PF reset failed, %d\n", ret);
 	}
 	pf->pfr_count++;
 
 	if (test_bit(__I40E_DOWN, &pf->state))
 		goto end_core_reset;
-	pf_info(pf, "%s: Rebuilding internal switch\n", __func__);
+	pf_info(pf, "Rebuilding internal switch\n");
 
 	/* rebuild the basics for the AdminQ, HMC, and initial HW switch */
 	ret = i40e_init_adminq(&pf->hw);
 	if (ret != I40E_SUCCESS) {
-		pf_info(pf, "%s: Rebuild AdminQ failed, %d\n", __func__, ret);
+		pf_info(pf, "Rebuild AdminQ failed, %d\n", ret);
 		goto end_core_reset;
 	}
 
 	ret = i40e_get_capabilities(pf);
 	if (ret) {
-		pf_info(pf, "%s: i40e_get_capabilities failed, %d\n",
-			__func__, ret);
+		pf_info(pf, "i40e_get_capabilities failed, %d\n", ret);
 		goto end_core_reset;
 	}
 
 	/* call shutdown HMC */
 	ret = i40e_shutdown_lan_hmc(hw);
 	if (ret) {
-		pf_info(pf, "%s: shutdown_lan_hmc failed: %d\n", __func__, ret);
+		pf_info(pf, "shutdown_lan_hmc failed: %d\n", ret);
 		goto end_core_reset;
 	}
 
@@ -4678,13 +4660,12 @@ static void i40e_handle_reset_warning(struct i40e_pf *pf)
 				hw->func_caps.num_rx_qp,
 				pf->fcoe_hmc_cntx_num, pf->fcoe_hmc_filt_num);
 	if (ret) {
-		pf_info(pf, "%s: init_lan_hmc failed: %d\n", __func__, ret);
+		pf_info(pf, "init_lan_hmc failed: %d\n", ret);
 		goto end_core_reset;
 	}
 	ret = i40e_configure_lan_hmc(hw, I40E_HMC_MODEL_DIRECT_ONLY);
 	if (ret) {
-		pf_info(pf, "%s: configure_lan_hmc failed: %d\n",
-			__func__, ret);
+		pf_info(pf, "configure_lan_hmc failed: %d\n", ret);
 		goto end_core_reset;
 	}
 
@@ -4701,7 +4682,7 @@ static void i40e_handle_reset_warning(struct i40e_pf *pf)
 	 * try to recover minimal use by getting the basic PF VSI working.
 	 */
 	if (pf->vsi[pf->lan_vsi]->uplink_seid != pf->mac_seid) {
-		pf_info(pf, "%s: attempting to rebuild switch\n", __func__);
+		pf_info(pf, "attempting to rebuild switch\n");
 		/* find the one VEB connected to the MAC, and find orphans */
 		for (v = 0; v < I40E_MAX_VEB; v++) {
 			if (!pf->veb[v])
@@ -4721,26 +4702,25 @@ static void i40e_handle_reset_warning(struct i40e_pf *pf)
 				 * but try to keep going.
 				 */
 				if (pf->veb[v]->uplink_seid == pf->mac_seid) {
-					pf_info(pf, "%s: rebuild of switch failed: %d, will try to set up simple PF connection\n",
-						__func__, ret);
+					pf_info(pf, "rebuild of switch failed: %d, will try to set up simple PF connection\n",
+						ret);
 					pf->vsi[pf->lan_vsi]->uplink_seid
 								= pf->mac_seid;
 					break;
 				} else if (pf->veb[v]->uplink_seid == 0) {
-					pf_info(pf, "%s: rebuild of orphan VEB failed: %d\n",
-						__func__, ret);
+					pf_info(pf, "rebuild of orphan VEB failed: %d\n",
+						ret);
 				}
 			}
 		}
 	}
 
 	if (pf->vsi[pf->lan_vsi]->uplink_seid == pf->mac_seid) {
-		pf_info(pf, "%s: attempting to rebuild PF VSI\n", __func__);
+		pf_info(pf, "attempting to rebuild PF VSI\n");
 		/* no VEB, so rebuild only the Main VSI */
 		ret = i40e_add_vsi(pf->vsi[pf->lan_vsi]);
 		if (ret != I40E_SUCCESS) {
-			pf_info(pf, "%s: rebuild of Main VSI failed: %d\n",
-				__func__, ret);
+			pf_info(pf, "rebuild of Main VSI failed: %d\n", ret);
 			goto end_core_reset;
 		}
 		i40e_sys_add_vsi(pf->vsi[pf->lan_vsi]);
@@ -4760,7 +4740,7 @@ static void i40e_handle_reset_warning(struct i40e_pf *pf)
 	dv.subbuild_version = 0;
 	i40e_aq_send_driver_version(&pf->hw, &dv, NULL);
 
-	pf_info(pf, "%s: PF reset done\n", __func__);
+	pf_info(pf, "PF reset done\n");
 
 end_core_reset:
 	clear_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state);
@@ -4792,8 +4772,8 @@ static i40e_status i40e_handle_mdd_event(struct i40e_pf *pf)
 				>> I40E_GL_MDET_TX_EVENT_SHIFT;
 		u8 queue = (reg & I40E_GL_MDET_TX_QUEUE_MASK)
 				>> I40E_GL_MDET_TX_QUEUE_SHIFT;
-		pf_info(pf, "%s: Malicious Driver Detection TX event 0x%02x on q %d of function 0x%02x\n",
-			__func__, event, queue, func);
+		pf_info(pf, "Malicious Driver Detection TX event 0x%02x on q %d of function 0x%02x\n",
+			event, queue, func);
 		wr32(hw, I40E_GL_MDET_TX, 0xffffffff);
 		mdd_detected = true;
 	}
@@ -4805,8 +4785,8 @@ static i40e_status i40e_handle_mdd_event(struct i40e_pf *pf)
 				>> I40E_GL_MDET_RX_EVENT_SHIFT;
 		u8 queue = (reg & I40E_GL_MDET_RX_QUEUE_MASK)
 				>> I40E_GL_MDET_RX_QUEUE_SHIFT;
-		pf_info(pf, "%s: Malicious Driver Detection RX event 0x%02x on q %d of function 0x%02x\n",
-			__func__, event, queue, func);
+		pf_info(pf, "Malicious Driver Detection RX event 0x%02x on q %d of function 0x%02x\n",
+			event, queue, func);
 		wr32(hw, I40E_GL_MDET_RX, 0xffffffff);
 		mdd_detected = true;
 	}
@@ -4818,21 +4798,20 @@ static i40e_status i40e_handle_mdd_event(struct i40e_pf *pf)
 		if (reg & I40E_VP_MDET_TX_VALID_MASK) {
 			wr32(hw, I40E_VP_MDET_TX(i), 0xFFFF);
 			vf->num_mdd_events++;
-			pf_info(pf, "%s: MDD TX event on VF %d\n", __func__, i);
+			pf_info(pf, "MDD TX event on VF %d\n", i);
 		}
 
 		reg = rd32(hw, I40E_VP_MDET_RX(i));
 		if (reg & I40E_VP_MDET_RX_VALID_MASK) {
 			wr32(hw, I40E_VP_MDET_RX(i), 0xFFFF);
 			vf->num_mdd_events++;
-			pf_info(pf, "%s: MDD RX event on VF %d\n", __func__, i);
+			pf_info(pf, "MDD RX event on VF %d\n", i);
 		}
 
 		if (vf->num_mdd_events > I40E_DEFAULT_NUM_MDD_EVENTS_ALLOWED) {
-			pf_info(pf, "%s: Too many MDD events on VF %d, disabled\n",
-				__func__, i);
-			pf_info(pf, "%s: Use PF Control I/F to re-enable the VF\n",
-				__func__);
+			pf_info(pf, "Too many MDD events on VF %d, disabled\n",
+				i);
+			pf_info(pf, "Use PF Control I/F to re-enable the VF\n");
 			set_bit(I40E_VF_STAT_DISABLED, &vf->vf_states);
 		}
 	}
@@ -5025,14 +5004,13 @@ static s32 i40e_vsi_clear(struct i40e_vsi *vsi)
 
 	mutex_lock(&pf->switch_mutex);
 	if (!pf->vsi[vsi->idx]) {
-		pf_err(pf, "%s: pf->vsi[%d] is NULL, just free vsi[%d](%p,type %d)\n",
-		       __func__, vsi->idx, vsi->idx, vsi, vsi->type);
+		pf_err(pf, "pf->vsi[%d] is NULL, just free vsi[%d](%p,type %d)\n",
+		       vsi->idx, vsi->idx, vsi, vsi->type);
 		goto unlock_vsi;
 	}
 
 	if (pf->vsi[vsi->idx] != vsi) {
-		pf_err(pf, "%s: pf->vsi[%d](%p, type %d) != vsi[%d](%p,type %d): no free!\n",
-		       __func__,
+		pf_err(pf, "pf->vsi[%d](%p, type %d) != vsi[%d](%p,type %d): no free!\n",
 		       pf->vsi[vsi->idx]->idx,
 		       pf->vsi[vsi->idx],
 		       pf->vsi[vsi->idx]->type,
@@ -5149,21 +5127,21 @@ static int i40e_reserve_msix_vectors(struct i40e_pf *pf, int vectors)
 			break;
 		} else if (err < 0) {
 			/* total failure */
-			pf_info(pf, "%s: MSI-X vector reservation failed: %d\n",
-				__func__, err);
+			pf_info(pf, "MSI-X vector reservation failed: %d\n",
+				err);
 			vectors = 0;
 			break;
 		} else {
 			/* err > 0 is the hint for retry */
-			pf_info(pf, "%s: MSI-X vectors wanted %d, retrying with %d\n",
-				__func__, vectors, err);
+			pf_info(pf, "MSI-X vectors wanted %d, retrying with %d\n",
+				vectors, err);
 			vectors = err;
 		}
 	}
 
 	if (vectors > 0 && vectors < I40E_MIN_MSIX) {
-		pf_info(pf, "%s: Couldn't get enough vectors, only %d available\n",
-			__func__, vectors);
+		pf_info(pf, "Couldn't get enough vectors, only %d available\n",
+			vectors);
 		vectors = 0;
 	}
 
@@ -5225,8 +5203,7 @@ static i40e_status i40e_init_msix(struct i40e_pf *pf)
 
 	} else if (vec == I40E_MIN_MSIX) {
 		/* Adjust for minimal MSIX use */
-		pf_info(pf, "%s: Features disabled, not enough MSIX vectors\n",
-			__func__);
+		pf_info(pf, "Features disabled, not enough MSIX vectors\n");
 		pf->flags &= ~I40E_FLAG_VMDQ_ENABLED;
 		pf->num_vmdq_vsis = 0;
 		pf->num_vmdq_qps = 0;
@@ -5334,8 +5311,8 @@ static void i40e_init_interrupt_scheme(struct i40e_pf *pf)
 	    (pf->flags & I40E_FLAG_MSI_ENABLED)) {
 		err = pci_enable_msi(pf->pdev);
 		if (err) {
-			pf_info(pf, "%s: MSI init failed (%d), trying legacy.\n",
-				__func__, err);
+			pf_info(pf, "MSI init failed (%d), trying legacy\n",
+				err);
 			pf->flags &= ~I40E_FLAG_MSI_ENABLED;
 		}
 	}
@@ -5367,8 +5344,8 @@ static int i40e_setup_misc_vector(struct i40e_pf *pf)
 		err = request_irq(pf->msix_entries[0].vector,
 				  i40e_intr, 0, pf->misc_int_name, pf);
 		if (err) {
-			pf_info(pf, "%s, request_irq for msix_misc failed: %d\n",
-				__func__, err);
+			pf_info(pf, "request_irq for msix_misc failed: %d\n",
+				err);
 			return I40E_ERR_CONFIG;
 		}
 	}
@@ -5513,7 +5490,7 @@ static int i40e_sw_init(struct i40e_pf *pf)
 	/* MFP mode enabled */
 	if (pf->hw.func_caps.npar_enable || pf->hw.func_caps.mfp_mode_1) {
 		pf->flags |= I40E_FLAG_MFP_ENABLED;
-		pf_info(pf, "%s: MFP mode Enabled\n", __func__);
+		pf_info(pf, "MFP mode Enabled\n");
 	}
 
 #ifdef CONFIG_PCI_IOV
@@ -5731,8 +5708,8 @@ static s32 i40e_add_vsi(struct i40e_vsi *vsi)
 		ret = i40e_aq_get_vsi_params(&pf->hw, &ctxt, NULL);
 		ctxt.flags = I40E_AQ_VSI_TYPE_PF;
 		if (ret) {
-			pf_info(pf, "%s: couldn't get pf vsi config, err %d, aq_err %d\n",
-				__func__, ret, pf->hw.aq.asq_last_status);
+			pf_info(pf, "couldn't get pf vsi config, err %d, aq_err %d\n",
+				ret, pf->hw.aq.asq_last_status);
 			return ret;
 		}
 		memcpy(&vsi->info, &ctxt.info, sizeof(ctxt.info));
@@ -5752,8 +5729,8 @@ static s32 i40e_add_vsi(struct i40e_vsi *vsi)
 			i40e_vsi_setup_queue_map(vsi, &ctxt, enabled_tc, false);
 			ret = i40e_aq_update_vsi_params(hw, &ctxt, NULL);
 			if (ret != I40E_SUCCESS) {
-				pf_info(pf, "%s: update vsi failed, aq_err=%d\n",
-					__func__, pf->hw.aq.asq_last_status);
+				pf_info(pf, "update vsi failed, aq_err=%d\n",
+					pf->hw.aq.asq_last_status);
 				goto err;
 			}
 			/* update the local VSI info queue map */
@@ -5766,8 +5743,8 @@ static s32 i40e_add_vsi(struct i40e_vsi *vsi)
 			 */
 			ret = i40e_vsi_config_tc(vsi, enabled_tc);
 			if (ret) {
-				pf_info(pf, "%s: failed to configure TCs for main VSI tc_map 0x%08x, err %d, aq_err %d\n",
-					__func__, enabled_tc, ret,
+				pf_info(pf, "failed to configure TCs for main VSI tc_map 0x%08x, err %d, aq_err %d\n",
+					enabled_tc, ret,
 					pf->hw.aq.asq_last_status);
 			}
 		}
@@ -5829,8 +5806,8 @@ static s32 i40e_add_vsi(struct i40e_vsi *vsi)
 	if (vsi->type != I40E_VSI_MAIN) {
 		ret = i40e_aq_add_vsi(hw, &ctxt, NULL);
 		if (ret) {
-			pf_info(vsi->back, "%s: add vsi failed, aq_err=%d\n",
-				__func__, vsi->back->hw.aq.asq_last_status);
+			pf_info(vsi->back, "add vsi failed, aq_err=%d\n",
+				vsi->back->hw.aq.asq_last_status);
 			goto err;
 		}
 		memcpy(&vsi->info, &ctxt.info, sizeof(ctxt.info));
@@ -5852,8 +5829,8 @@ static s32 i40e_add_vsi(struct i40e_vsi *vsi)
 	/* Update VSI BW information */
 	ret = i40e_vsi_get_bw_info(vsi);
 	if (ret) {
-		pf_info(pf, "%s: couldn't get vsi bw info, err %d, aq_err %d\n",
-			__func__, ret, pf->hw.aq.asq_last_status);
+		pf_info(pf, "couldn't get vsi bw info, err %d, aq_err %d\n",
+			ret, pf->hw.aq.asq_last_status);
 		/* VSI is already added so not tearing that up */
 		ret = I40E_SUCCESS;
 	}
@@ -5883,13 +5860,13 @@ s32 i40e_vsi_release(struct i40e_vsi *vsi)
 
 	/* release of a VEB-owner or last VSI is not allowed */
 	if (vsi->flags & I40E_VSI_FLAG_VEB_OWNER) {
-		pf_info(pf, "%s: VSI %d has existing VEB %d\n",
-			__func__, vsi->seid, vsi->uplink_seid);
+		pf_info(pf, "VSI %d has existing VEB %d\n",
+			vsi->seid, vsi->uplink_seid);
 		return I40E_ERR_DEVICE_NOT_SUPPORTED;
 	}
 	if (vsi == pf->vsi[pf->lan_vsi] &&
 	    !test_bit(__I40E_DOWN, &pf->state)) {
-		pf_info(pf, "%s: Can't remove PF VSI\n", __func__);
+		pf_info(pf, "Can't remove PF VSI\n");
 		return I40E_ERR_DEVICE_NOT_SUPPORTED;
 	}
 
@@ -5968,21 +5945,20 @@ static s32 i40e_vsi_setup_vectors(struct i40e_vsi *vsi)
 	struct i40e_pf *pf = vsi->back;
 
 	if (vsi->q_vectors) {
-		pf_info(pf, "%s: VSI %d has existing q_vectors\n",
-			__func__, vsi->seid);
+		pf_info(pf, "VSI %d has existing q_vectors\n", vsi->seid);
 		return I40E_ERR_CONFIG;
 	}
 
 	if (vsi->base_vector) {
-		pf_info(pf, "%s: VSI %d has non-zero base vector %d\n",
-			__func__, vsi->seid, vsi->base_vector);
+		pf_info(pf, "VSI %d has non-zero base vector %d\n",
+			vsi->seid, vsi->base_vector);
 		return I40E_ERR_CONFIG;
 	}
 
 	ret = i40e_alloc_q_vectors(vsi);
 	if (ret != I40E_SUCCESS) {
-		pf_info(pf, "%s: failed to allocate %d q_vector for VSI %d, ret=%d\n",
-			__func__, vsi->num_q_vectors, vsi->seid, ret);
+		pf_info(pf, "failed to allocate %d q_vector for VSI %d, ret=%d\n",
+			vsi->num_q_vectors, vsi->seid, ret);
 		vsi->num_q_vectors = 0;
 		goto vector_setup_out;
 	}
@@ -5990,8 +5966,8 @@ static s32 i40e_vsi_setup_vectors(struct i40e_vsi *vsi)
 	vsi->base_vector = i40e_get_lump(pf, pf->irq_pile,
 					 vsi->num_q_vectors, vsi->idx);
 	if (vsi->base_vector < 0) {
-		pf_info(pf, "%s: failed to get q tracking for VSI %d, err=%d\n",
-			__func__, vsi->seid, vsi->base_vector);
+		pf_info(pf, "failed to get q tracking for VSI %d, err=%d\n",
+			vsi->seid, vsi->base_vector);
 		i40e_vsi_free_q_vectors(vsi);
 		ret = I40E_ERR_CONFIG;
 		goto vector_setup_out;
@@ -6050,8 +6026,7 @@ struct i40e_vsi *i40e_vsi_setup(struct i40e_pf *pf, u8 type,
 			}
 		}
 		if (!vsi) {
-			pf_info(pf, "%s: no such uplink_seid %d\n",
-				__func__, uplink_seid);
+			pf_info(pf, "no such uplink_seid %d\n", uplink_seid);
 			return NULL;
 		}
 
@@ -6067,7 +6042,7 @@ struct i40e_vsi *i40e_vsi_setup(struct i40e_pf *pf, u8 type,
 				veb = pf->veb[i];
 		}
 		if (!veb) {
-			pf_info(pf, "%s: couldn't add VEB\n", __func__);
+			pf_info(pf, "couldn't add VEB\n");
 			return NULL;
 		}
 
@@ -6090,8 +6065,7 @@ struct i40e_vsi *i40e_vsi_setup(struct i40e_pf *pf, u8 type,
 	/* assign it some queues */
 	ret = i40e_get_lump(pf, pf->qp_pile, vsi->alloc_queue_pairs, vsi->idx);
 	if (ret < 0) {
-		pf_info(pf, "%s: VSI %d get_lump failed %d\n",
-			__func__, vsi->seid, ret);
+		pf_info(pf, "VSI %d get_lump failed %d\n", vsi->seid, ret);
 		goto err_vsi;
 	}
 	vsi->base_queue = ret;
@@ -6173,16 +6147,16 @@ static s32 i40e_veb_get_bw_info(struct i40e_veb *veb)
 	ret = i40e_aq_query_switch_comp_bw_config(hw, veb->seid,
 						  &bw_data, NULL);
 	if (ret != I40E_SUCCESS) {
-		pf_info(pf, "%s: query veb bw config failed, aq_err=%d\n",
-			__func__, hw->aq.asq_last_status);
+		pf_info(pf, "query veb bw config failed, aq_err=%d\n",
+			hw->aq.asq_last_status);
 		goto out;
 	}
 
 	ret = i40e_aq_query_switch_comp_ets_config(hw, veb->seid,
 						   &ets_data, NULL);
 	if (ret != I40E_SUCCESS) {
-		pf_info(pf, "%s: query veb bw ets config failed, aq_err=%d\n",
-			__func__, hw->aq.asq_last_status);
+		pf_info(pf, "query veb bw ets config failed, aq_err=%d\n",
+			hw->aq.asq_last_status);
 		goto out;
 	}
 
@@ -6337,8 +6311,8 @@ s32 i40e_veb_release(struct i40e_veb *veb)
 		}
 	}
 	if (n != 1) {
-		pf_info(pf, "%s: can't remove VEB %d with %d VSIs left\n",
-			__func__, veb->seid, n);
+		pf_info(pf, "can't remove VEB %d with %d VSIs left\n",
+			veb->seid, n);
 		return I40E_ERR_NOT_READY;
 	}
 
@@ -6379,8 +6353,8 @@ static s32 i40e_add_veb(struct i40e_veb *veb, struct i40e_vsi *vsi)
 	ret = i40e_aq_add_veb(&veb->pf->hw, veb->uplink_seid, vsi->seid,
 			      veb->enabled_tc, is_default, &veb->seid, NULL);
 	if (ret != I40E_SUCCESS) {
-		pf_info(veb->pf, "%s: couldn't add VEB, err %d, aq_err %d\n",
-			__func__, ret, veb->pf->hw.aq.asq_last_status);
+		pf_info(veb->pf, "couldn't add VEB, err %d, aq_err %d\n",
+			ret, veb->pf->hw.aq.asq_last_status);
 		return ret;
 	}
 
@@ -6388,14 +6362,14 @@ static s32 i40e_add_veb(struct i40e_veb *veb, struct i40e_vsi *vsi)
 	ret = i40e_aq_get_veb_parameters(&veb->pf->hw, veb->seid, NULL, NULL,
 					 &veb->stats_idx, NULL, NULL, NULL);
 	if (ret != I40E_SUCCESS) {
-		pf_info(veb->pf, "%s: couldn't get VEB statistics idx, err %d, aq_err %d\n",
-			__func__, ret, veb->pf->hw.aq.asq_last_status);
+		pf_info(veb->pf, "couldn't get VEB statistics idx, err %d, aq_err %d\n",
+			ret, veb->pf->hw.aq.asq_last_status);
 		return ret;
 	}
 	ret = i40e_veb_get_bw_info(veb);
 	if (ret != I40E_SUCCESS) {
-		pf_info(veb->pf, "%s: couldn't get VEB bw info, err %d, aq_err %d\n",
-			__func__, ret, veb->pf->hw.aq.asq_last_status);
+		pf_info(veb->pf, "couldn't get VEB bw info, err %d, aq_err %d\n",
+			ret, veb->pf->hw.aq.asq_last_status);
 		i40e_aq_delete_element(&veb->pf->hw, veb->seid, NULL);
 		return ret;
 	}
@@ -6439,8 +6413,8 @@ struct i40e_veb *i40e_veb_setup(struct i40e_pf *pf, u16 flags,
 	/* if one seid is 0, the other must be 0 to create a floating relay */
 	if ((uplink_seid == 0 || vsi_seid == 0) &&
 	    (uplink_seid + vsi_seid != 0)) {
-		pf_info(pf, "%s: one, not both seid's are 0: uplink=%d vsi=%d\n",
-			__func__, uplink_seid, vsi_seid);
+		pf_info(pf, "one, not both seid's are 0: uplink=%d vsi=%d\n",
+			uplink_seid, vsi_seid);
 		return NULL;
 	}
 
@@ -6449,7 +6423,7 @@ struct i40e_veb *i40e_veb_setup(struct i40e_pf *pf, u16 flags,
 		if (pf->vsi[vsi_idx] && pf->vsi[vsi_idx]->seid == vsi_seid)
 			break;
 	if (vsi_idx >= pf->hw.func_caps.num_vsis && vsi_seid != 0) {
-		pf_info(pf, "%s: vsi seid %d not found\n", __func__, vsi_seid);
+		pf_info(pf, "vsi seid %d not found\n", vsi_seid);
 		return NULL;
 	}
 
@@ -6462,8 +6436,7 @@ struct i40e_veb *i40e_veb_setup(struct i40e_pf *pf, u16 flags,
 			}
 		}
 		if (!uplink_veb) {
-			pf_info(pf, "%s: uplink seid %d not found\n",
-				__func__, uplink_seid);
+			pf_info(pf, "uplink seid %d not found\n", uplink_seid);
 			return NULL;
 		}
 	}
@@ -6520,14 +6493,14 @@ s32 i40e_fetch_switch_configuration(struct i40e_pf *pf, bool printconfig)
 						I40E_AQ_LARGE_BUF,
 						&next_seid, NULL);
 		if (ret) {
-			pf_info(pf, "%s: get switch config failed %d aq_err=%x\n",
-				__func__, ret, pf->hw.aq.asq_last_status);
+			pf_info(pf, "get switch config failed %d aq_err=%x\n",
+				ret, pf->hw.aq.asq_last_status);
 			kfree(aq_buf);
 			return ret;
 		}
 		if (printconfig)
-			pf_info(pf, "%s: header: %d reported %d total\n",
-				__func__, sw_config->header.num_reported,
+			pf_info(pf, "header: %d reported %d total\n",
+				sw_config->header.num_reported,
 				sw_config->header.num_total);
 
 		if (sw_config->header.num_reported) {
@@ -6541,8 +6514,7 @@ s32 i40e_fetch_switch_configuration(struct i40e_pf *pf, bool printconfig)
 
 		for (i = 0; i < sw_config->header.num_reported; i++) {
 			if (printconfig)
-				pf_info(pf, "%s: type=%d seid=%d uplink=%d downlink=%d\n",
-					__func__,
+				pf_info(pf, "type=%d seid=%d uplink=%d downlink=%d\n",
 					sw_config->element[i].element_type,
 					sw_config->element[i].seid,
 					sw_config->element[i].uplink_seid,
@@ -6592,8 +6564,7 @@ s32 i40e_fetch_switch_configuration(struct i40e_pf *pf, bool printconfig)
 				pf->pf_seid = sw_config->element[i].downlink_seid;
 				pf->main_vsi_seid = sw_config->element[i].seid;
 				if (printconfig)
-					pf_info(pf, "%s: pf_seid=%d main_vsi_seid=%d\n",
-						__func__,
+					pf_info(pf, "pf_seid=%d main_vsi_seid=%d\n",
 						pf->pf_seid, pf->main_vsi_seid);
 				break;
 			case I40E_SWITCH_ELEMENT_TYPE_PF:
@@ -6605,8 +6576,7 @@ s32 i40e_fetch_switch_configuration(struct i40e_pf *pf, bool printconfig)
 				/* ignore these for now */
 				break;
 			default:
-				pf_info(pf, "%s: unknown element type=%d seid=%d\n",
-					__func__,
+				pf_info(pf, "unknown element type=%d seid=%d\n",
 					sw_config->element[i].element_type,
 					sw_config->element[i].seid);
 				break;
@@ -6631,8 +6601,8 @@ static s32 i40e_setup_pf_switch(struct i40e_pf *pf)
 	/* find out what's out there already */
 	ret = i40e_fetch_switch_configuration(pf, false);
 	if (ret) {
-		pf_info(pf, "%s: couldn't fetch switch config, err %d, aq_err %d\n",
-			__func__, ret, pf->hw.aq.asq_last_status);
+		pf_info(pf, "couldn't fetch switch config, err %d, aq_err %d\n",
+			ret, pf->hw.aq.asq_last_status);
 		return ret;
 	}
 	i40e_pf_reset_stats(pf);
@@ -6658,7 +6628,7 @@ static s32 i40e_setup_pf_switch(struct i40e_pf *pf)
 
 		vsi = i40e_vsi_setup(pf, I40E_VSI_MAIN, uplink_seid, 0);
 		if (vsi == NULL) {
-			pf_info(pf, "%s: setup of MAIN VSI failed\n", __func__);
+			pf_info(pf, "setup of MAIN VSI failed\n");
 			i40e_fdir_teardown(pf);
 			return I40E_ERR_NOT_READY;
 		}
@@ -6680,8 +6650,7 @@ static s32 i40e_setup_pf_switch(struct i40e_pf *pf)
 	/* Setup static PF queue filter control settings */
 	ret = i40e_setup_pf_filter_control(pf);
 	if (ret) {
-		pf_info(pf, "%s: setup_pf_filter_control failed: %d\n",
-			__func__, ret);
+		pf_info(pf, "setup_pf_filter_control failed: %d\n", ret);
 		/* Failure here should not stop continuing other steps */
 	}
 
@@ -6778,8 +6747,7 @@ pf->rss_size = num_tc0;                                        \
 
 		queues_left -= pf->rss_size;
 		if (queues_left < 0) {
-			pf_info(pf, "%s: not enough queues for DCB\n",
-				__func__);
+			pf_info(pf, "not enough queues for DCB\n");
 			return I40E_ERR_CONFIG;
 		}
 
@@ -6794,8 +6762,7 @@ pf->rss_size = num_tc0;                                        \
 
 		queues_left -= pf->rss_size;
 		if (queues_left < 0) {
-			pf_info(pf, "%s: not enough queues for Flow Director\n",
-				__func__);
+			pf_info(pf, "not enough queues for Flow Director\n");
 			return I40E_ERR_CONFIG;
 		}
 
@@ -6814,16 +6781,15 @@ pf->rss_size = num_tc0;                                        \
 		SET_RSS_SIZE;
 		queues_left -= pf->rss_size;
 		if (queues_left < 0) {
-			pf_info(pf, "%s: not enough queues for DCB and Flow Director\n",
-				__func__);
+			pf_info(pf, "not enough queues for DCB and Flow Director\n");
 			return I40E_ERR_CONFIG;
 		}
 
 		pf->num_lan_qps = pf->rss_size + accum_tc_size;
 
 	} else {
-		pf_info(pf, "%s: Invalid configuration, flags=0x%08llx\n",
-			__func__, pf->flags);
+		pf_info(pf, "Invalid configuration, flags=0x%08llx\n",
+			pf->flags);
 		return I40E_ERR_CONFIG;
 	}
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_sysfs.c b/drivers/net/ethernet/intel/i40e/i40e_sysfs.c
index 0a672c0..8b34409 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_sysfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_sysfs.c
@@ -455,13 +455,12 @@ i40e_status i40e_sys_add_vsi(struct i40e_vsi *vsi)
 
 	ret = sysfs_create_group(vsi->kobj, &i40e_sys_vsi_attr_group);
 	if (ret < 0)
-		pf_info(pf, "%s: create_group failed: %d\n", __func__, ret);
+		pf_info(pf, "create_group failed: %d\n", ret);
 	if (vsi->netdev) {
 		ret = sysfs_create_link(vsi->kobj,
 					&vsi->netdev->dev.kobj, "net");
 		if (ret < 0)
-			pf_info(pf, "%s: create_link failed: %d\n",
-				__func__, ret);
+			pf_info(pf, "create_link failed: %d\n", ret);
 	}
 
 	return I40E_SUCCESS;
@@ -535,7 +534,7 @@ i40e_status i40e_sys_add_veb(struct i40e_veb *veb)
 
 	ret = sysfs_create_group(veb->kobj, &i40e_sys_veb_attr_group);
 	if (ret < 0)
-		pf_info(pf, "%s: create_group failed: %d\n", __func__, ret);
+		pf_info(pf, "create_group failed: %d\n", ret);
 
 	return I40E_SUCCESS;
 }
@@ -577,7 +576,7 @@ static i40e_status i40e_sys_add_switch(struct i40e_pf *pf)
 	ret = sysfs_create_group(pf->switch_kobj,
 				 &i40e_sys_hw_switch_attr_group);
 	if (ret < 0)
-		pf_info(pf, "%s: create_group failed: %d\n", __func__, ret);
+		pf_info(pf, "create_group failed: %d\n", ret);
 
 	i40e_sys_add_vsi(pf->vsi[pf->lan_vsi]);
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 9580f00..080eb68 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -371,16 +371,16 @@ static i40e_status i40e_config_vsi_tx_queue(struct i40e_vf *vf, u16 vsi_idx,
 	/* clear the context in the HMC */
 	ret = i40e_clear_lan_tx_queue_context(hw, pf_queue_id);
 	if (ret != I40E_SUCCESS) {
-		pf_err(pf, "%s: Failed to clear LAN Tx queue context %d, error: %d\n",
-		       __func__, pf_queue_id, ret);
+		pf_err(pf, "Failed to clear LAN Tx queue context %d, error: %d\n",
+		       pf_queue_id, ret);
 		goto error_context;
 	}
 
 	/* set the context in the HMC */
 	ret = i40e_set_lan_tx_queue_context(hw, pf_queue_id, &tx_ctx);
 	if (ret != I40E_SUCCESS) {
-		pf_err(pf, "%s: Failed to set LAN Tx queue context %d error: %d\n",
-		       __func__, pf_queue_id, ret);
+		pf_err(pf, "Failed to set LAN Tx queue context %d error: %d\n",
+		       pf_queue_id, ret);
 		goto error_context;
 	}
 
@@ -471,16 +471,16 @@ static i40e_status i40e_config_vsi_rx_queue(struct i40e_vf *vf, u16 vsi_idx,
 	/* clear the context in the HMC */
 	ret = i40e_clear_lan_rx_queue_context(hw, pf_queue_id);
 	if (ret != I40E_SUCCESS) {
-		pf_err(pf, "%s: Failed to clear LAN Rx queue context %d, error: %d\n",
-		       __func__, pf_queue_id, ret);
+		pf_err(pf, "Failed to clear LAN Rx queue context %d, error: %d\n",
+		       pf_queue_id, ret);
 		goto error_context;
 	}
 
 	/* set the context in the HMC */
 	ret = i40e_set_lan_rx_queue_context(hw, pf_queue_id, &rx_ctx);
 	if (ret != I40E_SUCCESS)
-		pf_err(pf, "%s: Failed to set LAN Rx queue context %d error: %d\n",
-		       __func__, pf_queue_id, ret);
+		pf_err(pf, "Failed to set LAN Rx queue context %d error: %d\n",
+		       pf_queue_id, ret);
 
 error_param:
 error_context:
@@ -506,27 +506,26 @@ static i40e_status i40e_alloc_vsi_res(struct i40e_vf *vf,
 	vsi = i40e_vsi_setup(pf, type, pf->vsi[pf->lan_vsi]->seid, vf->vf_id);
 
 	if (!vsi) {
-		pf_err(pf, "%s: add vsi failed for vf %d, aq_err %d\n",
-		       __func__, vf->vf_id, pf->hw.aq.asq_last_status);
+		pf_err(pf, "add vsi failed for vf %d, aq_err %d\n",
+		       vf->vf_id, pf->hw.aq.asq_last_status);
 		goto error_alloc_vsi_res;
 	}
 	if (type == I40E_VSI_SRIOV) {
 		vf->lan_vsi_index = vsi->idx;
 		vf->lan_vsi_id = vsi->id;
-		pf_info(pf, "%s: LAN VSI index %d, VSI id %d\n",
-			__func__, vsi->idx, vsi->id);
+		pf_info(pf, "LAN VSI index %d, VSI id %d\n", vsi->idx, vsi->id);
 		f = i40e_add_filter(vsi, vf->default_lan_addr.addr,
 				    0, true, false);
 	}
 	if (NULL == f) {
-		pf_err(pf, "%s: Unable to add ucast filter\n", __func__);
+		pf_err(pf, "Unable to add ucast filter\n");
 		ret = I40E_ERR_NO_MEMORY;
 		goto error_alloc_vsi_res;
 	}
 
 	/* program mac filter */
 	if (I40E_SUCCESS != i40e_sync_vsi_filters(vsi)) {
-		pf_err(pf, "%s: Unable to program ucast filters\n", __func__);
+		pf_err(pf, "Unable to program ucast filters\n");
 		ret = I40E_ERR_CONFIG;
 		goto error_alloc_vsi_res;
 	}
@@ -534,8 +533,8 @@ static i40e_status i40e_alloc_vsi_res(struct i40e_vf *vf,
 	/* accept bcast pkts. by default */
 	ret = i40e_aq_set_vsi_broadcast(hw, vsi->seid, true, NULL);
 	if (I40E_SUCCESS != ret)
-		pf_err(pf, "%s: set vsi bcast failed for vf %d, vsi %d, aq_err %d\n",
-		       __func__, vf->vf_id, vsi->idx,
+		pf_err(pf, "set vsi bcast failed for vf %d, vsi %d, aq_err %d\n",
+		       vf->vf_id, vsi->idx,
 		       pf->hw.aq.asq_last_status);
 
 error_alloc_vsi_res:
@@ -592,8 +591,7 @@ i40e_status i40e_reset_vf(struct i40e_vf *vf, bool flr)
 	}
 
 	if (!rsd)
-		pf_err(pf, "%s: VF reset check timeout %d\n",
-		       __func__, vf->vf_id);
+		pf_err(pf, "VF reset check timeout %d\n", vf->vf_id);
 
 	/* fast disable qps */
 	for (j = 0; j < pf->vsi[vf->lan_vsi_index]->num_queue_pairs; j++) {
@@ -613,13 +611,13 @@ i40e_status i40e_reset_vf(struct i40e_vf *vf, bool flr)
 		ret = i40e_ctrl_vsi_tx_queue(vf, vf->lan_vsi_index, j,
 					     I40E_QUEUE_CTRL_FASTDISABLECHECK);
 		if (ret != I40E_SUCCESS)
-			pf_info(pf, "%s: Queue control check failed on Tx queue %d of VSI %d VF %d\n",
-				__func__, vf->lan_vsi_index, j, vf->vf_id);
+			pf_info(pf, "Queue control check failed on Tx queue %d of VSI %d VF %d\n",
+				vf->lan_vsi_index, j, vf->vf_id);
 		ret = i40e_ctrl_vsi_rx_queue(vf, vf->lan_vsi_index, j,
 					     I40E_QUEUE_CTRL_FASTDISABLECHECK);
 		if (ret != I40E_SUCCESS)
-			pf_info(pf, "%s: Queue control check failed on Rx queue %d of VSI %d VF %d\n",
-				__func__, vf->lan_vsi_index, j, vf->vf_id);
+			pf_info(pf, "Queue control check failed on Rx queue %d of VSI %d VF %d\n",
+				vf->lan_vsi_index, j, vf->vf_id);
 	}
 
 	/* clear the irq settings */
@@ -867,8 +865,7 @@ i40e_status i40e_free_vfs(struct i40e_pf *pf)
 	if (!i40e_vfs_are_assigned(pf))
 		pci_disable_sriov(pf->pdev);
 	else
-		pf_warn(pf, "%s: unable to disable SR-IOV because VFs are assigned.\n",
-			__func__);
+		pf_warn(pf, "unable to disable SR-IOV because VFs are assigned.\n");
 
 	/* Re-enable interrupt 0. */
 	wr32(hw, I40E_PFINT_DYN_CTL0,
@@ -895,8 +892,7 @@ static i40e_status i40e_alloc_vfs(struct i40e_pf *pf, u16 num_alloc_vfs)
 
 	err = pci_enable_sriov(pf->pdev, num_alloc_vfs);
 	if (err) {
-		pf_err(pf, "%s: pci_enable_sriov failed with error %d!\n",
-		       __func__, err);
+		pf_err(pf, "pci_enable_sriov failed with error %d!\n", err);
 		pf->num_alloc_vfs = 0;
 		ret = I40E_ERR_CONFIG;
 		goto err_iov;
@@ -1021,14 +1017,12 @@ static i40e_status i40e_vc_send_msg_to_vf(struct i40e_vf *vf,
 	/* single place to detect unsuccessful return values */
 	if (v_retval != I40E_SUCCESS) {
 		vf->num_invalid_msgs++;
-		pf_err(pf, "%s: Failed opcode %d Error: %d\n",
-		       __func__, v_opcode, v_retval);
+		pf_err(pf, "Failed opcode %d Error: %d\n", v_opcode, v_retval);
 		if (vf->num_invalid_msgs >
 		    I40E_DEFAULT_NUM_INVALID_MSGS_ALLOWED) {
-			pf_err(pf, "%s: Number of invalid messages exceeded for VF %d\n",
-			       __func__, vf->vf_id);
-			pf_err(pf, "%s: Use PF Control I/F to enable the VF\n",
-			       __func__);
+			pf_err(pf, "Number of invalid messages exceeded for VF %d\n",
+			       vf->vf_id);
+			pf_err(pf, "Use PF Control I/F to enable the VF\n");
 			set_bit(I40E_VF_STAT_DISABLED, &vf->vf_states);
 		}
 	} else {
@@ -1038,8 +1032,8 @@ static i40e_status i40e_vc_send_msg_to_vf(struct i40e_vf *vf,
 	ret = i40e_aq_send_msg_to_vf(hw, vf->vf_id, v_opcode, v_retval,
 				     msg, msglen, NULL);
 	if (I40E_SUCCESS != ret)
-		pf_err(pf, "%s: Unable to send the message to VF %d aq_err %d\n",
-		       __func__, vf->vf_id, pf->hw.aq.asq_last_status);
+		pf_err(pf, "Unable to send the message to VF %d aq_err %d\n",
+		       vf->vf_id, pf->hw.aq.asq_last_status);
 
 	return ret;
 }
@@ -1418,8 +1412,8 @@ static i40e_status i40e_vc_enable_queues_msg(struct i40e_vf *vf,
 		ret = i40e_ctrl_vsi_rx_queue(vf, vsi_id, queue_id,
 					     I40E_QUEUE_CTRL_ENABLECHECK);
 		if (ret != I40E_SUCCESS) {
-			pf_err(pf, "%s: Queue control check failed on RX queue %d of VSI %d VF %d\n",
-			       __func__, queue_id, vsi_id, vf->vf_id);
+			pf_err(pf, "Queue control check failed on RX queue %d of VSI %d VF %d\n",
+			       queue_id, vsi_id, vf->vf_id);
 		}
 		queue_id = find_next_bit(&tempmap, I40E_MAX_VSI_QP,
 					 queue_id + 1);
@@ -1431,8 +1425,8 @@ static i40e_status i40e_vc_enable_queues_msg(struct i40e_vf *vf,
 		ret = i40e_ctrl_vsi_tx_queue(vf, vsi_id, queue_id,
 					     I40E_QUEUE_CTRL_ENABLECHECK);
 		if (ret != I40E_SUCCESS) {
-			pf_err(pf, "%s: Queue control check failed on TX queue %d of VSI %d VF %d\n",
-			       __func__, queue_id, vsi_id, vf->vf_id);
+			pf_err(pf, "Queue control check failed on TX queue %d of VSI %d VF %d\n",
+			       queue_id, vsi_id, vf->vf_id);
 		}
 		queue_id = find_next_bit(&tempmap, I40E_MAX_VSI_QP,
 					 queue_id + 1);
@@ -1519,8 +1513,8 @@ static i40e_status i40e_vc_disable_queues_msg(struct i40e_vf *vf,
 		ret = i40e_ctrl_vsi_rx_queue(vf, vsi_id, queue_id,
 					     I40E_QUEUE_CTRL_DISABLECHECK);
 		if (ret != I40E_SUCCESS) {
-			pf_err(pf, "%s: Queue control check failed on RX queue %d of VSI %d VF %d\n",
-			       __func__, queue_id, vsi_id, vf->vf_id);
+			pf_err(pf, "Queue control check failed on RX queue %d of VSI %d VF %d\n",
+			       queue_id, vsi_id, vf->vf_id);
 		}
 		queue_id = find_next_bit(&tempmap, I40E_MAX_VSI_QP,
 					 queue_id + 1);
@@ -1532,8 +1526,8 @@ static i40e_status i40e_vc_disable_queues_msg(struct i40e_vf *vf,
 		ret = i40e_ctrl_vsi_tx_queue(vf, vsi_id, queue_id,
 					     I40E_QUEUE_CTRL_DISABLECHECK);
 		if (ret != I40E_SUCCESS) {
-			pf_err(pf, "%s: Queue control check failed on TX queue %d of VSI %d VF %d\n",
-			       __func__, queue_id, vsi_id, vf->vf_id);
+			pf_err(pf, "Queue control check failed on TX queue %d of VSI %d VF %d\n",
+			       queue_id, vsi_id, vf->vf_id);
 		}
 		queue_id = find_next_bit(&tempmap, I40E_MAX_VSI_QP,
 					 queue_id + 1);
@@ -1621,8 +1615,8 @@ static i40e_status i40e_vc_add_mac_addr_msg(struct i40e_vf *vf,
 	for (i = 0; i < al->num_elements; i++) {
 		if (is_broadcast_ether_addr(al->list[i].addr) ||
 		    is_zero_ether_addr(al->list[i].addr)) {
-			pf_err(pf, "%s: invalid MAC addr %pMAC\n",
-			       __func__, al->list[i].addr);
+			pf_err(pf, "invalid MAC addr %pMAC\n",
+			       al->list[i].addr);
 			ret = I40E_ERR_PARAM;
 			goto error_param;
 		}
@@ -1643,7 +1637,7 @@ static i40e_status i40e_vc_add_mac_addr_msg(struct i40e_vf *vf,
 		}
 
 		if (ret != I40E_SUCCESS) {
-			pf_err(pf, "%s: Unable to add MAC filter\n", __func__);
+			pf_err(pf, "Unable to add MAC filter\n");
 			ret = I40E_ERR_PARAM;
 			goto error_param;
 		}
@@ -1652,7 +1646,7 @@ static i40e_status i40e_vc_add_mac_addr_msg(struct i40e_vf *vf,
 	/* program the updated filter list */
 	ret = i40e_sync_vsi_filters(vsi);
 	if (I40E_SUCCESS != ret)
-		pf_err(pf, "%s: Unable to program MAC filters\n", __func__);
+		pf_err(pf, "Unable to program MAC filters\n");
 
 error_param:
 	/* send the response to the vf */
@@ -1697,7 +1691,7 @@ static i40e_status i40e_vc_del_mac_addr_msg(struct i40e_vf *vf,
 	/* program the updated filter list */
 	ret = i40e_sync_vsi_filters(vsi);
 	if (I40E_SUCCESS != ret)
-		pf_err(pf, "%s: Unable to program MAC filters\n", __func__);
+		pf_err(pf, "Unable to program MAC filters\n");
 
 error_param:
 	/* send the response to the vf */
@@ -1736,8 +1730,8 @@ static i40e_status i40e_vc_add_vlan_msg(struct i40e_vf *vf, u8 *msg,
 	for (i = 0; i < vfl->num_elements; i++) {
 		if (vfl->vlan_id[i] > I40E_MAX_VLANID) {
 			ret = I40E_ERR_PARAM;
-			pf_err(pf, "%s: invalid VLAN id %d\n",
-			       __func__, vfl->vlan_id[i]);
+			pf_err(pf, "invalid VLAN id %d\n",
+			       vfl->vlan_id[i]);
 			goto error_param;
 		}
 	}
@@ -1752,8 +1746,8 @@ static i40e_status i40e_vc_add_vlan_msg(struct i40e_vf *vf, u8 *msg,
 		/* add new VLAN filter */
 		ret = i40e_vsi_add_vlan(vsi, vfl->vlan_id[i]);
 		if (ret != I40E_SUCCESS) {
-			pf_err(pf, "%s: Unable to add vlan filter %d, error %d\n",
-			       __func__, vfl->vlan_id[i], ret);
+			pf_err(pf, "Unable to add vlan filter %d, error %d\n",
+			       vfl->vlan_id[i], ret);
 			goto error_param;
 		}
 	}
@@ -1807,8 +1801,8 @@ static i40e_status i40e_vc_remove_vlan_msg(struct i40e_vf *vf, u8 *msg,
 	for (i = 0; i < vfl->num_elements; i++) {
 		ret = i40e_vsi_kill_vlan(vsi, vfl->vlan_id[i]);
 		if (I40E_SUCCESS != ret)
-			pf_err(pf, "%s: Unable to delete vlan filter %d, error %d\n",
-			       __func__, vfl->vlan_id[i], ret);
+			pf_err(pf, "Unable to delete vlan filter %d, error %d\n",
+			       vfl->vlan_id[i], ret);
 	}
 
 error_param:
@@ -1972,7 +1966,7 @@ i40e_status i40e_vc_process_vf_msg(struct i40e_pf *pf, u16 vf_id,
 	ret = i40e_vc_validate_vf_msg(vf, v_opcode, v_retval, msg, msglen);
 
 	if (ret != I40E_SUCCESS) {
-		pf_err(pf, "%s: invalid message from vf %d\n", __func__, vf_id);
+		pf_err(pf, "invalid message from vf %d\n", vf_id);
 		return ret;
 	}
 	wr32(hw, I40E_VFGEN_RSTAT1(vf_id), I40E_VFR_VFACTIVE);
@@ -2022,8 +2016,8 @@ i40e_status i40e_vc_process_vf_msg(struct i40e_pf *pf, u16 vf_id,
 		break;
 	case I40E_VIRTCHNL_OP_UNKNOWN:
 	default:
-		pf_err(pf, "%s: Unsupported opcode %d from vf %d\n",
-		       __func__, v_opcode, vf_id);
+		pf_err(pf, "Unsupported opcode %d from vf %d\n",
+		       v_opcode, vf_id);
 		ret = i40e_vc_send_resp_to_vf(vf, v_opcode,
 					      I40E_ERR_NOT_IMPLEMENTED);
 		break;
@@ -2062,19 +2056,19 @@ i40e_status i40e_vc_process_vflr_event(struct i40e_pf *pf)
 
 			ret = i40e_reset_vf(vf, true);
 			if (ret != I40E_SUCCESS)
-				pf_err(pf, "%s: Unable to reset the VF %d\n",
-				       __func__, vf_id);
+				pf_err(pf, "Unable to reset the VF %d\n",
+				       vf_id);
 			/* free up vf resources to destroy vsi state */
 			ret = i40e_free_vf_res(vf);
 			if (ret != I40E_SUCCESS)
-				pf_err(pf, "%s: Failed to free VF resources %d\n",
-				       __func__, vf_id);
+				pf_err(pf, "Failed to free VF resources %d\n",
+				       vf_id);
 
 			/* allocate new vf resources with the default state */
 			ret = i40e_alloc_vf_res(vf);
 			if (ret != I40E_SUCCESS)
-				pf_err(pf, "%s: Unable to allocate VF resources %d\n",
-				       __func__, vf_id);
+				pf_err(pf, "Unable to allocate VF resources %d\n",
+				       vf_id);
 
 			ret = i40e_enable_vf_mappings(vf);
 		}
@@ -2190,7 +2184,7 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
 
 	/* validate the request */
 	if (vf_id >= pf->num_alloc_vfs) {
-		pf_err(pf, "%s: Invalid VF Identifier %d\n", __func__, vf_id);
+		pf_err(pf, "Invalid VF Identifier %d\n", vf_id);
 		ret = -EINVAL;
 		goto error_param;
 	}
@@ -2198,13 +2192,13 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
 	vf = &(pf->vf[vf_id]);
 	vsi = pf->vsi[vf->lan_vsi_index];
 	if (!test_bit(I40E_VF_STAT_INIT, &vf->vf_states)) {
-		pf_err(pf, "%s: Uninitialized VF %d\n", __func__, vf_id);
+		pf_err(pf, "Uninitialized VF %d\n", vf_id);
 		ret = -EINVAL;
 		goto error_param;
 	}
 
 	if (!is_valid_ether_addr(mac)) {
-		pf_err(pf, "%s: Invalid ethernet address\n", __func__);
+		pf_err(pf, "Invalid ethernet address\n");
 		ret = -EINVAL;
 		goto error_param;
 	}
@@ -2215,21 +2209,20 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
 	/* add the new mac address */
 	f = i40e_add_filter(vsi, mac, 0, true, false);
 	if (NULL == f) {
-		pf_err(pf, "%s: Unable to add ucast filter\n", __func__);
+		pf_err(pf, "Unable to add ucast filter\n");
 		ret = -ENOMEM;
 		goto error_param;
 	}
 
-	pf_info(pf, "%s: Setting MAC %pM on VF %d\n", __func__, mac, vf_id);
+	pf_info(pf, "Setting MAC %pM on VF %d\n", mac, vf_id);
 	/* program mac filter */
 	if (I40E_SUCCESS != i40e_sync_vsi_filters(vsi)) {
-		pf_err(pf, "%s: Unable to program ucast filters\n", __func__);
+		pf_err(pf, "Unable to program ucast filters\n");
 		ret = -EIO;
 		goto error_param;
 	}
 	memcpy(vf->default_lan_addr.addr, mac, ETH_ALEN);
-	pf_info(pf, "%s: Reload the VF driver to make this change effective\n",
-		__func__);
+	pf_info(pf, "Reload the VF driver to make this change effective\n");
 	ret = 0;
 
 error_param:
@@ -2256,13 +2249,13 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
 
 	/* validate the request */
 	if (vf_id >= pf->num_alloc_vfs) {
-		pf_err(pf, "%s: Invalid VF Identifier %d\n", __func__, vf_id);
+		pf_err(pf, "Invalid VF Identifier %d\n", vf_id);
 		ret = -EINVAL;
 		goto error_pvid;
 	}
 
 	if ((vlan_id > I40E_MAX_VLANID) || (qos > 7)) {
-		pf_err(pf, "%s: Invalid Parameters\n", __func__);
+		pf_err(pf, "Invalid Parameters\n");
 		ret = -EINVAL;
 		goto error_pvid;
 	}
@@ -2270,7 +2263,7 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
 	vf = &(pf->vf[vf_id]);
 	vsi = pf->vsi[vf->lan_vsi_index];
 	if (!test_bit(I40E_VF_STAT_INIT, &vf->vf_states)) {
-		pf_err(pf, "%s: Uninitialized VF %d\n", __func__, vf_id);
+		pf_err(pf, "Uninitialized VF %d\n", vf_id);
 		ret = -EINVAL;
 		goto error_pvid;
 	}
@@ -2279,8 +2272,8 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
 		/* kill old VLAN */
 		ret = i40e_vsi_kill_vlan(vsi, vsi->info.pvid & VLAN_VID_MASK);
 		if (ret != I40E_SUCCESS) {
-			pf_info(vsi->back, "%s: remove VLAN failed, ret=%d, aq_err=%d\n",
-				__func__, ret, pf->hw.aq.asq_last_status);
+			pf_info(vsi->back, "remove VLAN failed, ret=%d, aq_err=%d\n",
+				ret, pf->hw.aq.asq_last_status);
 		}
 	}
 	if (vlan_id || qos)
@@ -2290,21 +2283,21 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
 		i40e_vlan_stripping_disable(vsi);
 
 	if (vlan_id) {
-		pf_info(pf, "%s: Setting VLAN %d, QOS 0x%x on VF %d\n",
-			__func__, vlan_id, qos, vf_id);
+		pf_info(pf, "Setting VLAN %d, QOS 0x%x on VF %d\n",
+			vlan_id, qos, vf_id);
 
 		/* add new VLAN filter */
 		ret = i40e_vsi_add_vlan(vsi, vlan_id);
 		if (ret != I40E_SUCCESS) {
-			pf_info(vsi->back, "%s: add VLAN failed, ret=%d aq_err=%d\n",
-				__func__, ret,
+			pf_info(vsi->back, "add VLAN failed, ret=%d aq_err=%d\n",
+				ret,
 				vsi->back->hw.aq.asq_last_status);
 			goto error_pvid;
 		}
 	}
 
 	if (ret != I40E_SUCCESS) {
-		pf_err(pf, "%s: Unable to update vsi context\n", __func__);
+		pf_err(pf, "Unable to update vsi context\n");
 		ret = -EIO;
 		goto error_pvid;
 	}
@@ -2347,7 +2340,7 @@ int i40e_ndo_get_vf_config(struct net_device *netdev,
 
 	/* validate the request */
 	if (vf_id >= pf->num_alloc_vfs) {
-		pf_err(pf, "%s: Invalid VF Identifier %d\n", __func__, vf_id);
+		pf_err(pf, "Invalid VF Identifier %d\n", vf_id);
 		ret = -EINVAL;
 		goto error_param;
 	}
@@ -2356,7 +2349,7 @@ int i40e_ndo_get_vf_config(struct net_device *netdev,
 	/* first vsi is always the LAN vsi */
 	vsi = pf->vsi[vf->lan_vsi_index];
 	if (!test_bit(I40E_VF_STAT_INIT, &vf->vf_states)) {
-		pf_err(pf, "%s: Uninitialized VF %d\n", __func__, vf_id);
+		pf_err(pf, "Uninitialized VF %d\n", vf_id);
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
