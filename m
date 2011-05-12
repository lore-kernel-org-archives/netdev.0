From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCHv3 net-next-2.6 2/3] qlcnic: Take FW dump via ethtool
Date: Thu, 12 May 2011 15:48:34 -0700
Message-ID: <1305240515-29237-4-git-send-email-anirban.chakraborty@qlogic.com>
References: <1305240515-29237-1-git-send-email-anirban.chakraborty@qlogic.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.pathscale.com ([198.186.3.75]:58539 "HELO mx.mv.qlogic.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1752826Ab1ELWzB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 May 2011 18:55:01 -0400
In-Reply-To: <1305240515-29237-1-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver checks if the previous dump has been cleared before taking the dump.
It doesn't take the dump if it is not cleared.

Changes from v2:
Added lock to protect dump data structures from being mangled while
dumping or setting them via ethtool.

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_ethtool.c |   81 +++++++++++++++++++++++++++++++++++
 1 files changed, 81 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index c541461..9efc690 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -965,6 +965,84 @@ static void qlcnic_set_msglevel(struct net_device *netdev, u32 msglvl)
 	adapter->msg_enable = msglvl;
 }
 
+static int
+qlcnic_get_dump_flag(struct net_device *netdev, struct ethtool_dump *dump)
+{
+	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	struct qlcnic_fw_dump *fw_dump = &adapter->ahw->fw_dump;
+
+	dump->len = fw_dump->tmpl_hdr->size + fw_dump->size;
+	dump->flag = fw_dump->tmpl_hdr->drv_cap_mask;
+	dump->version = adapter->fw_version;
+	return 0;
+}
+
+static int
+qlcnic_get_dump_data(struct net_device *netdev, struct ethtool_dump *dump,
+			void *buffer)
+{
+	int i, copy_sz;
+	u32 *hdr_ptr, *data;
+	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	struct qlcnic_fw_dump *fw_dump = &adapter->ahw->fw_dump;
+
+	if (qlcnic_api_lock(adapter))
+		return -EIO;
+	if (!fw_dump->clr) {
+		netdev_info(netdev, "Dump not available\n");
+		qlcnic_api_unlock(adapter);
+		return -EINVAL;
+	}
+	/* Copy template header first */
+	copy_sz = fw_dump->tmpl_hdr->size;
+	hdr_ptr = (u32 *) fw_dump->tmpl_hdr;
+	data = (u32 *) buffer;
+	for (i = 0; i < copy_sz/sizeof(u32); i++)
+		*data++ = cpu_to_le32(*hdr_ptr++);
+
+	/* Copy captured dump data */
+	memcpy(buffer + copy_sz, fw_dump->data, fw_dump->size);
+	dump->len = copy_sz + fw_dump->size;
+	dump->flag = fw_dump->tmpl_hdr->drv_cap_mask;
+
+	/* Free dump area once data has been captured */
+	vfree(fw_dump->data);
+	fw_dump->data = NULL;
+	fw_dump->clr = 0;
+	qlcnic_api_unlock(adapter);
+
+	return 0;
+}
+
+static int
+qlcnic_set_dump(struct net_device *netdev, struct ethtool_dump *val)
+{
+	int ret = 0;
+	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	struct qlcnic_fw_dump *fw_dump = &adapter->ahw->fw_dump;
+
+	if (val->flag == QLCNIC_FORCE_FW_DUMP_KEY) {
+		netdev_info(netdev, "Forcing a FW dump\n");
+		qlcnic_dev_request_reset(adapter);
+	} else {
+		if (val->flag > QLCNIC_DUMP_MASK_MAX ||
+			val->flag < QLCNIC_DUMP_MASK_MIN) {
+				netdev_info(netdev,
+				"Invalid dump level: 0x%x\n", val->flag);
+				ret = -EINVAL;
+				goto out;
+		}
+		if (qlcnic_api_lock(adapter))
+			return -EIO;
+		fw_dump->tmpl_hdr->drv_cap_mask = val->flag & 0xff;
+		qlcnic_api_unlock(adapter);
+		netdev_info(netdev, "Driver mask changed to: 0x%x\n",
+			fw_dump->tmpl_hdr->drv_cap_mask);
+	}
+out:
+	return ret;
+}
+
 const struct ethtool_ops qlcnic_ethtool_ops = {
 	.get_settings = qlcnic_get_settings,
 	.set_settings = qlcnic_set_settings,
@@ -991,4 +1069,7 @@ const struct ethtool_ops qlcnic_ethtool_ops = {
 	.set_phys_id = qlcnic_set_led,
 	.set_msglevel = qlcnic_set_msglevel,
 	.get_msglevel = qlcnic_get_msglevel,
+	.get_dump_flag = qlcnic_get_dump_flag,
+	.get_dump_data = qlcnic_get_dump_data,
+	.set_dump = qlcnic_set_dump,
 };
-- 
1.7.4.1

