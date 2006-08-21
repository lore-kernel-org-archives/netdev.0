From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 07/14] ipw2200: Fix ipw2200 QOS parameters endian issue
Date: Mon, 21 Aug 2006 11:37:58 +0800
Message-ID: <20060821033758.GA5380@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:59245 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S932585AbWHUDj5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 23:39:57 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jackie Wu <jackie.wu@intel.com>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/ipw2200.c |   52 ++++++++++++++++++++++++----------------
 1 files changed, 31 insertions(+), 21 deletions(-)

fc32e5f014ca92fd000ffefc02326e2ed3890e11
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 946d5b4..04efe69 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -2279,7 +2279,7 @@ static int ipw_send_scan_abort(struct ip
 static int ipw_set_sensitivity(struct ipw_priv *priv, u16 sens)
 {
 	struct ipw_sensitivity_calib calib = {
-		.beacon_rssi_raw = sens,
+		.beacon_rssi_raw = cpu_to_le16(sens),
 	};
 
 	return ipw_send_cmd_pdu(priv, IPW_CMD_SENSITIVITY_CALIB, sizeof(calib),
@@ -2345,6 +2345,7 @@ static int ipw_send_card_disable(struct 
 		return -1;
 	}
 
+	phy_off = cpu_to_le32(phy_off);
 	return ipw_send_cmd_pdu(priv, IPW_CMD_CARD_DISABLE, sizeof(phy_off),
 				&phy_off);
 }
@@ -2406,7 +2407,7 @@ static int ipw_set_tx_power(struct ipw_p
 static int ipw_send_rts_threshold(struct ipw_priv *priv, u16 rts)
 {
 	struct ipw_rts_threshold rts_threshold = {
-		.rts_threshold = rts,
+		.rts_threshold = cpu_to_le16(rts),
 	};
 
 	if (!priv) {
@@ -2421,7 +2422,7 @@ static int ipw_send_rts_threshold(struct
 static int ipw_send_frag_threshold(struct ipw_priv *priv, u16 frag)
 {
 	struct ipw_frag_threshold frag_threshold = {
-		.frag_threshold = frag,
+		.frag_threshold = cpu_to_le16(frag),
 	};
 
 	if (!priv) {
@@ -2456,6 +2457,7 @@ static int ipw_send_power_mode(struct ip
 		break;
 	}
 
+	param = cpu_to_le32(mode);
 	return ipw_send_cmd_pdu(priv, IPW_CMD_POWER_MODE, sizeof(param),
 				&param);
 }
@@ -5821,8 +5823,8 @@ static void ipw_send_tgi_tx_key(struct i
 	key.station_index = 0;	/* always 0 for BSS */
 	key.flags = 0;
 	/* 0 for new key; previous value of counter (after fatal error) */
-	key.tx_counter[0] = 0;
-	key.tx_counter[1] = 0;
+	key.tx_counter[0] = cpu_to_le32(0);
+	key.tx_counter[1] = cpu_to_le32(0);
 
 	ipw_send_cmd_pdu(priv, IPW_CMD_TGI_TX_KEY, sizeof(key), &key);
 }
@@ -6773,7 +6775,7 @@ static int ipw_qos_activate(struct ipw_p
 		burst_duration = ipw_qos_get_burst_duration(priv);
 		for (i = 0; i < QOS_QUEUE_NUM; i++)
 			qos_parameters[QOS_PARAM_SET_ACTIVE].tx_op_limit[i] =
-			    (u16) burst_duration;
+			    (u16)burst_duration;
 	} else if (priv->ieee->iw_mode == IW_MODE_ADHOC) {
 		if (type == IEEE_B) {
 			IPW_DEBUG_QOS("QoS activate IBSS nework mode %d\n",
@@ -6805,11 +6807,20 @@ static int ipw_qos_activate(struct ipw_p
 			burst_duration = ipw_qos_get_burst_duration(priv);
 			for (i = 0; i < QOS_QUEUE_NUM; i++)
 				qos_parameters[QOS_PARAM_SET_ACTIVE].
-				    tx_op_limit[i] = (u16) burst_duration;
+				    tx_op_limit[i] = (u16)burst_duration;
 		}
 	}
 
 	IPW_DEBUG_QOS("QoS sending IPW_CMD_QOS_PARAMETERS\n");
+	for (i = 0; i < 3; i++) {
+		int j;
+		for (j = 0; j < QOS_QUEUE_NUM; j++) {
+			qos_parameters[i].cw_min[j] = cpu_to_le16(qos_parameters[i].cw_min[j]);
+			qos_parameters[i].cw_max[j] = cpu_to_le16(qos_parameters[i].cw_max[j]);
+			qos_parameters[i].tx_op_limit[j] = cpu_to_le16(qos_parameters[i].tx_op_limit[j]);
+		}
+	}
+
 	err = ipw_send_qos_params_command(priv,
 					  (struct ieee80211_qos_parameters *)
 					  &(qos_parameters[0]));
@@ -7048,7 +7059,7 @@ static int ipw_qos_set_tx_queue_command(
 
 	if (priv->qos_data.qos_no_ack_mask & (1UL << tx_queue_id)) {
 		tfd->tx_flags &= ~DCT_FLAG_ACK_REQD;
-		tfd->tfd.tfd_26.mchdr.qos_ctrl |= CTRL_QOS_NO_ACK;
+		tfd->tfd.tfd_26.mchdr.qos_ctrl |= cpu_to_le16(CTRL_QOS_NO_ACK);
 	}
 	return 0;
 }
@@ -7791,17 +7802,17 @@ static void ipw_handle_promiscuous_rx(st
 	}
 
 	hdr = (void *)rxb->skb->data + IPW_RX_FRAME_SIZE;
-	if (ieee80211_is_management(hdr->frame_ctl)) {
+	if (ieee80211_is_management(le16_to_cpu(hdr->frame_ctl))) {
 		if (filter & IPW_PROM_NO_MGMT)
 			return;
 		if (filter & IPW_PROM_MGMT_HEADER_ONLY)
 			hdr_only = 1;
-	} else if (ieee80211_is_control(hdr->frame_ctl)) {
+	} else if (ieee80211_is_control(le16_to_cpu(hdr->frame_ctl))) {
 		if (filter & IPW_PROM_NO_CTL)
 			return;
 		if (filter & IPW_PROM_CTL_HEADER_ONLY)
 			hdr_only = 1;
-	} else if (ieee80211_is_data(hdr->frame_ctl)) {
+	} else if (ieee80211_is_data(le16_to_cpu(hdr->frame_ctl))) {
 		if (filter & IPW_PROM_NO_DATA)
 			return;
 		if (filter & IPW_PROM_DATA_HEADER_ONLY)
@@ -7819,7 +7830,7 @@ static void ipw_handle_promiscuous_rx(st
 	ipw_rt = (void *)skb->data;
 
 	if (hdr_only)
-		len = ieee80211_get_hdrlen(hdr->frame_ctl);
+		len = ieee80211_get_hdrlen(le16_to_cpu(hdr->frame_ctl));
 
 	memcpy(ipw_rt->payload, hdr, len);
 
@@ -8125,8 +8136,7 @@ static void ipw_rx(struct ipw_priv *priv
 		switch (pkt->header.message_type) {
 		case RX_FRAME_TYPE:	/* 802.11 frame */  {
 				struct ieee80211_rx_stats stats = {
-					.rssi =
-					    le16_to_cpu(pkt->u.frame.rssi_dbm) -
+					.rssi = pkt->u.frame.rssi_dbm -
 					    IPW_RSSI_TO_DBM,
 					.signal =
 					    le16_to_cpu(pkt->u.frame.rssi_dbm) -
@@ -10088,7 +10098,7 @@ static int ipw_tx_skb(struct ipw_priv *p
 		switch (priv->ieee->sec.level) {
 		case SEC_LEVEL_3:
 			tfd->u.data.tfd.tfd_24.mchdr.frame_ctl |=
-			    IEEE80211_FCTL_PROTECTED;
+			    cpu_to_le16(IEEE80211_FCTL_PROTECTED);
 			/* XXX: ACK flag must be set for CCMP even if it
 			 * is a multicast/broadcast packet, because CCMP
 			 * group communication encrypted by GTK is
@@ -10103,14 +10113,14 @@ static int ipw_tx_skb(struct ipw_priv *p
 			break;
 		case SEC_LEVEL_2:
 			tfd->u.data.tfd.tfd_24.mchdr.frame_ctl |=
-			    IEEE80211_FCTL_PROTECTED;
+			    cpu_to_le16(IEEE80211_FCTL_PROTECTED);
 			tfd->u.data.tx_flags &= ~DCT_FLAG_NO_WEP;
 			tfd->u.data.tx_flags_ext |= DCT_FLAG_EXT_SECURITY_TKIP;
 			tfd->u.data.key_index = DCT_WEP_INDEX_USE_IMMEDIATE;
 			break;
 		case SEC_LEVEL_1:
 			tfd->u.data.tfd.tfd_24.mchdr.frame_ctl |=
-			    IEEE80211_FCTL_PROTECTED;
+			    cpu_to_le16(IEEE80211_FCTL_PROTECTED);
 			tfd->u.data.key_index = priv->ieee->tx_keyidx;
 			if (priv->ieee->sec.key_sizes[priv->ieee->tx_keyidx] <=
 			    40)
@@ -10242,17 +10252,17 @@ static void ipw_handle_promiscuous_tx(st
 
 	/* Filtering of fragment chains is done agains the first fragment */
 	hdr = (void *)txb->fragments[0]->data;
-	if (ieee80211_is_management(hdr->frame_ctl)) {
+	if (ieee80211_is_management(le16_to_cpu(hdr->frame_ctl))) {
 		if (filter & IPW_PROM_NO_MGMT)
 			return;
 		if (filter & IPW_PROM_MGMT_HEADER_ONLY)
 			hdr_only = 1;
-	} else if (ieee80211_is_control(hdr->frame_ctl)) {
+	} else if (ieee80211_is_control(le16_to_cpu(hdr->frame_ctl))) {
 		if (filter & IPW_PROM_NO_CTL)
 			return;
 		if (filter & IPW_PROM_CTL_HEADER_ONLY)
 			hdr_only = 1;
-	} else if (ieee80211_is_data(hdr->frame_ctl)) {
+	} else if (ieee80211_is_data(le16_to_cpu(hdr->frame_ctl))) {
 		if (filter & IPW_PROM_NO_DATA)
 			return;
 		if (filter & IPW_PROM_DATA_HEADER_ONLY)
@@ -10267,7 +10277,7 @@ static void ipw_handle_promiscuous_tx(st
 
 		if (hdr_only) {
 			hdr = (void *)src->data;
-			len = ieee80211_get_hdrlen(hdr->frame_ctl);
+			len = ieee80211_get_hdrlen(le16_to_cpu(hdr->frame_ctl));
 		} else
 			len = src->len;
 
-- 
1.2.6
