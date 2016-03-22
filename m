From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH V2 net 08/10] net: hns: fix the bug about mtu setting
Date: Tue, 22 Mar 2016 16:06:29 +0800
Message-ID: <1458633991-64313-9-git-send-email-Yisen.Zhuang@huawei.com>
References: <1458633991-64313-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yankejian@huawei.com>, <huangdaode@hisilicon.com>,
	<salil.mehta@huawei.com>, <lisheng011@huawei.com>,
	<lipeng321@huawei.com>, <liguozhu@huawei.com>, <arnd@arndb.de>,
	<sergei.shtylyov@cogentembedded.com>, <xieqianqian@huawei.com>,
	<andrew@lunn.ch>, <ivecera@redhat.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:34691 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755926AbcCVHvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 03:51:38 -0400
In-Reply-To: <1458633991-64313-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kejian Yan <yankejian@huawei.com>

In chip V1, the maximum mtu value is 9600. But in chip V2, it is 9728.
And it is always configurates as 9600 before this patch.

Signed-off-by: Kejian Yan <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c | 4 +++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h | 1 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c | 3 +++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h | 2 ++
 4 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index 138737d..50237fb 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -467,8 +467,10 @@ int hns_mac_set_mtu(struct hns_mac_cb *mac_cb, u32 new_mtu)
 	struct mac_driver *drv = hns_mac_get_drv(mac_cb);
 	u32 buf_size = mac_cb->dsaf_dev->buf_size;
 	u32 new_frm = new_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
+	u32 max_frm = AE_IS_VER1(mac_cb->dsaf_dev->dsaf_ver) ?
+			MAC_MAX_MTU : MAC_MAX_MTU_V2;
 
-	if ((new_mtu < MAC_MIN_MTU) || (new_frm > MAC_MAX_MTU) ||
+	if ((new_mtu < MAC_MIN_MTU) || (new_frm > max_frm) ||
 	    (new_frm > HNS_RCB_RING_MAX_BD_PER_PKT * buf_size))
 		return -EINVAL;
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
index 0f60968..7b47701 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
@@ -26,6 +26,7 @@ struct dsaf_device;
 
 #define MAC_DEFAULT_MTU	(ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN + ETH_DATA_LEN)
 #define MAC_MAX_MTU		9600
+#define MAC_MAX_MTU_V2		9728
 #define MAC_MIN_MTU		68
 
 #define MAC_DEFAULT_PAUSE_TIME 0xff
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
index 06422c2..5b7ae5f 100644
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
