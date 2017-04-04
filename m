From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 05/12] bnxt_en: Add ethtool set_wol method.
Date: Tue,  4 Apr 2017 18:14:10 -0400
Message-ID: <1491344057-12663-6-git-send-email-michael.chan@broadcom.com>
References: <1491344057-12663-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f175.google.com ([209.85.128.175]:36765 "EHLO
        mail-wr0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755174AbdDDWOp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 18:14:45 -0400
Received: by mail-wr0-f175.google.com with SMTP id w11so222691861wrc.3
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 15:14:44 -0700 (PDT)
In-Reply-To: <1491344057-12663-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And add functions to set and free magic packet filter.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 32 +++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  2 ++
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 26 ++++++++++++++++++
 3 files changed, 60 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 10a9cda..e432d0a 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5842,6 +5842,38 @@ static int bnxt_hwrm_port_led_qcaps(struct bnxt *bp)
 	return 0;
 }
 
+int bnxt_hwrm_alloc_wol_fltr(struct bnxt *bp)
+{
+	struct hwrm_wol_filter_alloc_input req = {0};
+	struct hwrm_wol_filter_alloc_output *resp = bp->hwrm_cmd_resp_addr;
+	int rc;
+
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_WOL_FILTER_ALLOC, -1, -1);
+	req.port_id = cpu_to_le16(bp->pf.port_id);
+	req.wol_type = WOL_FILTER_ALLOC_REQ_WOL_TYPE_MAGICPKT;
+	req.enables = cpu_to_le32(WOL_FILTER_ALLOC_REQ_ENABLES_MAC_ADDRESS);
+	memcpy(req.mac_address, bp->dev->dev_addr, ETH_ALEN);
+	mutex_lock(&bp->hwrm_cmd_lock);
+	rc = _hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+	if (!rc)
+		bp->wol_filter_id = resp->wol_filter_id;
+	mutex_unlock(&bp->hwrm_cmd_lock);
+	return rc;
+}
+
+int bnxt_hwrm_free_wol_fltr(struct bnxt *bp)
+{
+	struct hwrm_wol_filter_free_input req = {0};
+	int rc;
+
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_WOL_FILTER_FREE, -1, -1);
+	req.port_id = cpu_to_le16(bp->pf.port_id);
+	req.enables = cpu_to_le32(WOL_FILTER_FREE_REQ_ENABLES_WOL_FILTER_ID);
+	req.wol_filter_id = bp->wol_filter_id;
+	rc = hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+	return rc;
+}
+
 static u16 bnxt_hwrm_get_wol_fltrs(struct bnxt *bp, u16 handle)
 {
 	struct hwrm_wol_filter_qcfg_input req = {0};
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 02de812..aba25ba 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1242,6 +1242,8 @@ int bnxt_hwrm_func_rgtr_async_events(struct bnxt *bp, unsigned long *bmap,
 void bnxt_tx_enable(struct bnxt *bp);
 int bnxt_hwrm_set_pause(struct bnxt *);
 int bnxt_hwrm_set_link_setting(struct bnxt *, bool, bool);
+int bnxt_hwrm_alloc_wol_fltr(struct bnxt *bp);
+int bnxt_hwrm_free_wol_fltr(struct bnxt *bp);
 int bnxt_hwrm_fw_set_time(struct bnxt *);
 int bnxt_open_nic(struct bnxt *, bool, bool);
 int bnxt_close_nic(struct bnxt *, bool, bool);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 2b94704..84cd4ca 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -847,6 +847,31 @@ static void bnxt_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	}
 }
 
+static int bnxt_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct bnxt *bp = netdev_priv(dev);
+
+	if (wol->wolopts & ~WAKE_MAGIC)
+		return -EINVAL;
+
+	if (wol->wolopts & WAKE_MAGIC) {
+		if (!(bp->flags & BNXT_FLAG_WOL_CAP))
+			return -EINVAL;
+		if (!bp->wol) {
+			if (bnxt_hwrm_alloc_wol_fltr(bp))
+				return -EBUSY;
+			bp->wol = 1;
+		}
+	} else {
+		if (bp->wol) {
+			if (bnxt_hwrm_free_wol_fltr(bp))
+				return -EBUSY;
+			bp->wol = 0;
+		}
+	}
+	return 0;
+}
+
 u32 _bnxt_fw_to_ethtool_adv_spds(u16 fw_speeds, u8 fw_pause)
 {
 	u32 speed_mask = 0;
@@ -2150,6 +2175,7 @@ static int bnxt_set_phys_id(struct net_device *dev,
 	.set_pauseparam		= bnxt_set_pauseparam,
 	.get_drvinfo		= bnxt_get_drvinfo,
 	.get_wol		= bnxt_get_wol,
+	.set_wol		= bnxt_set_wol,
 	.get_coalesce		= bnxt_get_coalesce,
 	.set_coalesce		= bnxt_set_coalesce,
 	.get_msglevel		= bnxt_get_msglevel,
-- 
1.8.3.1
