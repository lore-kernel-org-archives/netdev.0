From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 4/6] bnxt_en: Add support for ethtool -p.
Date: Tue, 10 Jan 2017 20:12:37 -0500
Message-ID: <1484097159-21575-5-git-send-email-michael.chan@broadcom.com>
References: <1484097159-21575-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34834 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760660AbdAKBM7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 20:12:59 -0500
Received: by mail-pf0-f176.google.com with SMTP id f144so46298555pfa.2
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 17:12:59 -0800 (PST)
In-Reply-To: <1484097159-21575-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add LED blinking code to support ethtool -p on the PF.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 40 +++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         | 17 +++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 44 ++++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h | 23 ++++++++++++
 4 files changed, 123 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index df2358b..2b46f9b 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5621,6 +5621,45 @@ static int bnxt_hwrm_shutdown_link(struct bnxt *bp)
 	return hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
 }
 
+static int bnxt_hwrm_port_led_qcaps(struct bnxt *bp)
+{
+	struct hwrm_port_led_qcaps_output *resp = bp->hwrm_cmd_resp_addr;
+	struct hwrm_port_led_qcaps_input req = {0};
+	struct bnxt_pf_info *pf = &bp->pf;
+	int rc;
+
+	if (BNXT_VF(bp) || bp->hwrm_spec_code < 0x10601)
+		return 0;
+
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_PORT_LED_QCAPS, -1, -1);
+	req.port_id = cpu_to_le16(pf->port_id);
+	mutex_lock(&bp->hwrm_cmd_lock);
+	rc = _hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+	if (rc) {
+		mutex_unlock(&bp->hwrm_cmd_lock);
+		return rc;
+	}
+	if (resp->num_leds > 0 && resp->num_leds < BNXT_MAX_LED) {
+		int i;
+
+		bp->num_leds = resp->num_leds;
+		memcpy(bp->leds, &resp->led0_id, sizeof(bp->leds[0]) *
+						 bp->num_leds);
+		for (i = 0; i < bp->num_leds; i++) {
+			struct bnxt_led_info *led = &bp->leds[i];
+			__le16 caps = led->led_state_caps;
+
+			if (!led->led_group_id ||
+			    !BNXT_LED_ALT_BLINK_CAP(caps)) {
+				bp->num_leds = 0;
+				break;
+			}
+		}
+	}
+	mutex_unlock(&bp->hwrm_cmd_lock);
+	return 0;
+}
+
 static bool bnxt_eee_config_ok(struct bnxt *bp)
 {
 	struct ethtool_eee *eee = &bp->eee;
@@ -7244,6 +7283,7 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	bnxt_hwrm_func_qcfg(bp);
+	bnxt_hwrm_port_led_qcaps(bp);
 
 	bnxt_set_tpa_flags(bp);
 	bnxt_set_ring_params(bp);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index f6b9b1c..52a1cc0 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -868,6 +868,20 @@ struct bnxt_queue_info {
 	u8	queue_profile;
 };
 
+#define BNXT_MAX_LED			4
+
+struct bnxt_led_info {
+	u8	led_id;
+	u8	led_type;
+	u8	led_group_id;
+	u8	unused;
+	__le16	led_state_caps;
+#define BNXT_LED_ALT_BLINK_CAP(x)	((x) &	\
+	cpu_to_le16(PORT_LED_QCAPS_RESP_LED0_STATE_CAPS_BLINK_ALT_SUPPORTED))
+
+	__le16	led_color_caps;
+};
+
 #define BNXT_GRCPF_REG_WINDOW_BASE_OUT	0x400
 #define BNXT_CAG_REG_LEGACY_INT_STATUS	0x4014
 #define BNXT_CAG_REG_BASE		0x300000
@@ -1123,6 +1137,9 @@ struct bnxt {
 	struct ethtool_eee	eee;
 	u32			lpi_tmr_lo;
 	u32			lpi_tmr_hi;
+
+	u8			num_leds;
+	struct bnxt_led_info	leds[BNXT_MAX_LED];
 };
 
 #define BNXT_RX_STATS_OFFSET(counter)			\
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index dd21be4..24818e1 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -2080,6 +2080,47 @@ static int bnxt_nway_reset(struct net_device *dev)
 	return rc;
 }
 
+static int bnxt_set_phys_id(struct net_device *dev,
+			    enum ethtool_phys_id_state state)
+{
+	struct hwrm_port_led_cfg_input req = {0};
+	struct bnxt *bp = netdev_priv(dev);
+	struct bnxt_pf_info *pf = &bp->pf;
+	struct bnxt_led_cfg *led_cfg;
+	u8 led_state;
+	__le16 duration;
+	int i, rc;
+
+	if (!bp->num_leds || BNXT_VF(bp))
+		return -EOPNOTSUPP;
+
+	if (state == ETHTOOL_ID_ACTIVE) {
+		led_state = PORT_LED_CFG_REQ_LED0_STATE_BLINKALT;
+		duration = cpu_to_le16(500);
+	} else if (state == ETHTOOL_ID_INACTIVE) {
+		led_state = PORT_LED_CFG_REQ_LED1_STATE_DEFAULT;
+		duration = cpu_to_le16(0);
+	} else {
+		return -EINVAL;
+	}
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_PORT_LED_CFG, -1, -1);
+	req.port_id = cpu_to_le16(pf->port_id);
+	req.num_leds = bp->num_leds;
+	led_cfg = (struct bnxt_led_cfg *)&req.led0_id;
+	for (i = 0; i < bp->num_leds; i++, led_cfg++) {
+		req.enables |= BNXT_LED_DFLT_ENABLES(i);
+		led_cfg->led_id = bp->leds[i].led_id;
+		led_cfg->led_state = led_state;
+		led_cfg->led_blink_on = duration;
+		led_cfg->led_blink_off = duration;
+		led_cfg->led_group_id = bp->leds[i].led_group_id;
+	}
+	rc = hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+	if (rc)
+		rc = -EIO;
+	return rc;
+}
+
 const struct ethtool_ops bnxt_ethtool_ops = {
 	.get_link_ksettings	= bnxt_get_link_ksettings,
 	.set_link_ksettings	= bnxt_set_link_ksettings,
@@ -2111,5 +2152,6 @@ static int bnxt_nway_reset(struct net_device *dev)
 	.set_eee		= bnxt_set_eee,
 	.get_module_info	= bnxt_get_module_info,
 	.get_module_eeprom	= bnxt_get_module_eeprom,
-	.nway_reset		= bnxt_nway_reset
+	.nway_reset		= bnxt_nway_reset,
+	.set_phys_id		= bnxt_set_phys_id,
 };
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h
index 3abc03b..ed1e555 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h
@@ -10,6 +10,29 @@
 #ifndef BNXT_ETHTOOL_H
 #define BNXT_ETHTOOL_H
 
+struct bnxt_led_cfg {
+	u8 led_id;
+	u8 led_state;
+	u8 led_color;
+	u8 unused;
+	__le16 led_blink_on;
+	__le16 led_blink_off;
+	u8 led_group_id;
+	u8 rsvd;
+};
+
+#define BNXT_LED_DFLT_ENA				\
+	(PORT_LED_CFG_REQ_ENABLES_LED0_ID |		\
+	 PORT_LED_CFG_REQ_ENABLES_LED0_STATE |		\
+	 PORT_LED_CFG_REQ_ENABLES_LED0_BLINK_ON |	\
+	 PORT_LED_CFG_REQ_ENABLES_LED0_BLINK_OFF |	\
+	 PORT_LED_CFG_REQ_ENABLES_LED0_GROUP_ID)
+
+#define BNXT_LED_DFLT_ENA_SHIFT	6
+
+#define BNXT_LED_DFLT_ENABLES(x)			\
+	cpu_to_le32(BNXT_LED_DFLT_ENA << (BNXT_LED_DFLT_ENA_SHIFT * (x)))
+
 extern const struct ethtool_ops bnxt_ethtool_ops;
 
 u32 _bnxt_fw_to_ethtool_adv_spds(u16, u8);
-- 
1.8.3.1
