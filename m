From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 03/10] bnxt_en: Implement ndo_bridge_{get|set}link methods.
Date: Mon, 24 Jul 2017 12:34:22 -0400
Message-ID: <1500914069-15724-4-git-send-email-michael.chan@broadcom.com>
References: <1500914069-15724-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:35589 "EHLO
        mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753747AbdGXQes (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 12:34:48 -0400
Received: by mail-qk0-f176.google.com with SMTP id d145so47866016qkc.2
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 09:34:47 -0700 (PDT)
In-Reply-To: <1500914069-15724-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To allow users to set the hardware bridging mode to VEB or VEPA.  Only
single function PF can change the bridging mode.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 67 +++++++++++++++++++++++++++++++
 1 file changed, 67 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index ec8a195..4acaeaf 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4919,6 +4919,26 @@ static void bnxt_hwrm_resource_free(struct bnxt *bp, bool close_path,
 	}
 }
 
+static int bnxt_hwrm_set_br_mode(struct bnxt *bp, u16 br_mode)
+{
+	struct hwrm_func_cfg_input req = {0};
+	int rc;
+
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_FUNC_CFG, -1, -1);
+	req.fid = cpu_to_le16(0xffff);
+	req.enables = cpu_to_le32(FUNC_CFG_REQ_ENABLES_EVB_MODE);
+	if (br_mode == BRIDGE_MODE_VEB)
+		req.evb_mode = FUNC_CFG_REQ_EVB_MODE_VEB;
+	else if (br_mode == BRIDGE_MODE_VEPA)
+		req.evb_mode = FUNC_CFG_REQ_EVB_MODE_VEPA;
+	else
+		return -EINVAL;
+	rc = hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+	if (rc)
+		rc = -EIO;
+	return rc;
+}
+
 static int bnxt_setup_vnic(struct bnxt *bp, u16 vnic_id)
 {
 	struct bnxt_vnic_info *vnic = &bp->vnic_info[vnic_id];
@@ -7432,6 +7452,51 @@ static void bnxt_udp_tunnel_del(struct net_device *dev,
 	schedule_work(&bp->sp_task);
 }
 
+static int bnxt_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
+			       struct net_device *dev, u32 filter_mask,
+			       int nlflags)
+{
+	struct bnxt *bp = netdev_priv(dev);
+
+	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, bp->br_mode, 0, 0,
+				       nlflags, filter_mask, NULL);
+}
+
+static int bnxt_bridge_setlink(struct net_device *dev, struct nlmsghdr *nlh,
+			       u16 flags)
+{
+	struct bnxt *bp = netdev_priv(dev);
+	struct nlattr *attr, *br_spec;
+	int rem, rc = 0;
+
+	if (bp->hwrm_spec_code < 0x10708 || !BNXT_SINGLE_PF(bp))
+		return -EOPNOTSUPP;
+
+	br_spec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_SPEC);
+	if (!br_spec)
+		return -EINVAL;
+
+	nla_for_each_nested(attr, br_spec, rem) {
+		u16 mode;
+
+		if (nla_type(attr) != IFLA_BRIDGE_MODE)
+			continue;
+
+		if (nla_len(attr) < sizeof(mode))
+			return -EINVAL;
+
+		mode = nla_get_u16(attr);
+		if (mode == bp->br_mode)
+			break;
+
+		rc = bnxt_hwrm_set_br_mode(bp, mode);
+		if (!rc)
+			bp->br_mode = mode;
+		break;
+	}
+	return rc;
+}
+
 static const struct net_device_ops bnxt_netdev_ops = {
 	.ndo_open		= bnxt_open,
 	.ndo_start_xmit		= bnxt_start_xmit,
@@ -7463,6 +7528,8 @@ static void bnxt_udp_tunnel_del(struct net_device *dev,
 	.ndo_udp_tunnel_add	= bnxt_udp_tunnel_add,
 	.ndo_udp_tunnel_del	= bnxt_udp_tunnel_del,
 	.ndo_xdp		= bnxt_xdp,
+	.ndo_bridge_getlink	= bnxt_bridge_getlink,
+	.ndo_bridge_setlink	= bnxt_bridge_setlink,
 };
 
 static void bnxt_remove_one(struct pci_dev *pdev)
-- 
1.8.3.1
