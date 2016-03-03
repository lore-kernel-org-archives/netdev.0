From: Kejian Yan <yankejian@huawei.com>
Subject: [PATCH net] net: hns: fix the fault about mtu setting
Date: Thu, 3 Mar 2016 20:04:16 +0800
Message-ID: <1457006656-236624-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <haifeng.wei@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
	<salil.mehta@huawei.com>, <liguozhu@huawei.com>,
	<huangdaode@hisilicon.com>, <arnd@arndb.de>,
	<andriy.shevchenko@linux.intel.com>, <andrew@lunn.ch>,
	<chenny.xu@huawei.com>, <ivecera@redhat.com>,
	<lisheng011@huawei.com>, <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:51624 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932275AbcCCLp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 06:45:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As the User Manual describes, maximum value are 9728 for service ports and
1500 for debug ports, not always 9600. So it needs to be configured to
right value for the different port. The max frame len of ppe needs to be
set to the right as well.

Signed-off-by: Kejian Yan <yankejian@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c | 7 ++++++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h | 2 ++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c | 3 +++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h | 2 ++
 4 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index 5ef0e96..65b8d91 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -467,8 +467,13 @@ int hns_mac_set_mtu(struct hns_mac_cb *mac_cb, u32 new_mtu)
 	struct mac_driver *drv = hns_mac_get_drv(mac_cb);
 	u32 buf_size = mac_cb->dsaf_dev->buf_size;
 	u32 new_frm = new_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
+	u32 max_frm = AE_IS_VER1(mac_cb->dsaf_dev->dsaf_ver) ?
+			MAC_MAX_MTU : MAC_MAX_MTU_V2;
 
-	if ((new_mtu < MAC_MIN_MTU) || (new_frm > MAC_MAX_MTU) ||
+	if (mac_cb->mac_type == HNAE_PORT_DEBUG)
+		max_frm = MAC_MAX_MTU_DBG;
+
+	if ((new_mtu < MAC_MIN_MTU) || (new_frm > max_frm) ||
 	    (new_frm > HNS_RCB_RING_MAX_BD_PER_PKT * buf_size))
 		return -EINVAL;
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
index 0b05219..fc51e3d 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
@@ -26,7 +26,9 @@ struct dsaf_device;
 
 #define MAC_DEFAULT_MTU	(ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN + ETH_DATA_LEN)
 #define MAC_MAX_MTU		9600
+#define MAC_MAX_MTU_V2		9728
 #define MAC_MIN_MTU		68
+#define MAC_MAX_MTU_DBG         MAC_DEFAULT_MTU
 
 #define MAC_DEFAULT_PAUSE_TIME 0xff
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
index f302ef9..7a61c57 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
@@ -343,6 +343,9 @@ static void hns_ppe_init_hw(struct hns_ppe_cb *ppe_cb)
 	if (!AE_IS_VER1(dsaf_dev->dsaf_ver)) {
 		hns_ppe_set_vlan_strip(ppe_cb, 0);
 
+		dsaf_write_dev(ppe_cb, PPE_CFG_MAX_FRAME_LEN_REG,
+			       HNS_PPEV2_MAX_FRAME_LEN);
+
 		/* set default RSS key in h/w */
 		hns_ppe_set_rss_key(ppe_cb, ppe_cb->rss_key);
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h
index 0f5cb69..e9c0ec2 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h
@@ -30,6 +30,8 @@
 #define HNS_PPEV2_RSS_KEY_SIZE 40 /* in bytes or 320 bits */
 #define HNS_PPEV2_RSS_KEY_NUM (HNS_PPEV2_RSS_KEY_SIZE / sizeof(u32))
 
+#define HNS_PPEV2_MAX_FRAME_LEN 0X980
+
 enum ppe_qid_mode {
 	PPE_QID_MODE0 = 0, /* fixed queue id mode */
 	PPE_QID_MODE1,	   /* switch:128VM non switch:6Port/4VM/4TC */
-- 
1.9.1
