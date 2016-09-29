From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V2 for-next 6/8] net: hns: fix the bug of forwarding table
Date: Thu, 29 Sep 2016 18:09:14 +0100
Message-ID: <20160929170916.631972-7-salil.mehta@huawei.com>
References: <20160929170916.631972-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <xavier.huwei@huawei.com>, <oulijun@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <linux-rdma@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, Daode Huang <huangdaode@hisilicon.com>
To: <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:53853 "EHLO
        szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934461AbcI2RLa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 13:11:30 -0400
In-Reply-To: <20160929170916.631972-1-salil.mehta@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daode Huang <huangdaode@hisilicon.com>

As the sub queue id in the broadcast forwarding table is always
set to absolute queue 0 rather than the interface's relative queue 0,
this will cause the received broadcast packets loopback to rcb.
This patch sets the sub queue id to relative queue 0 of each port.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
PATCH V2: Addressed comments by David Miller
          Link: https://lkml.org/lkml/2016/9/28/390
PATCH V1: Initial Submit
---
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c |    8 ++++++--
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c |   13 ++++++++++---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h |    2 ++
 3 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index e0f9cdc..2d0cb60 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -207,6 +207,7 @@ static int hns_ae_set_multicast_one(struct hnae_handle *handle, void *addr)
 	int ret;
 	char *mac_addr = (char *)addr;
 	struct hns_mac_cb *mac_cb = hns_get_mac_cb(handle);
+	u8 port_num;
 
 	assert(mac_cb);
 
@@ -221,8 +222,11 @@ static int hns_ae_set_multicast_one(struct hnae_handle *handle, void *addr)
 		return ret;
 	}
 
-	ret = hns_mac_set_multi(mac_cb, DSAF_BASE_INNER_PORT_NUM,
-				mac_addr, true);
+	ret = hns_mac_get_inner_port_num(mac_cb, handle->vf_id, &port_num);
+	if (ret)
+		return ret;
+
+	ret = hns_mac_set_multi(mac_cb, port_num, mac_addr, true);
 	if (ret)
 		dev_err(handle->owner_dev,
 			"mac add mul_mac:%pM port%d  fail, ret = %#x!\n",
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index a68eef0..151fd6e 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -141,9 +141,10 @@ void hns_mac_adjust_link(struct hns_mac_cb *mac_cb, int speed, int duplex)
  *@port_num:port number
  *
  */
-static int hns_mac_get_inner_port_num(struct hns_mac_cb *mac_cb,
-				      u8 vmid, u8 *port_num)
+int hns_mac_get_inner_port_num(struct hns_mac_cb *mac_cb, u8 vmid, u8 *port_num)
 {
+	int q_num_per_vf, vf_num_per_port;
+	int vm_queue_id;
 	u8 tmp_port;
 
 	if (mac_cb->dsaf_dev->dsaf_mode <= DSAF_MODE_ENABLE) {
@@ -174,6 +175,12 @@ static int hns_mac_get_inner_port_num(struct hns_mac_cb *mac_cb,
 		return -EINVAL;
 	}
 
+	q_num_per_vf = mac_cb->dsaf_dev->rcb_common[0]->max_q_per_vf;
+	vf_num_per_port = mac_cb->dsaf_dev->rcb_common[0]->max_vfn;
+
+	vm_queue_id = vmid * q_num_per_vf +
+			vf_num_per_port * q_num_per_vf * mac_cb->mac_id;
+
 	switch (mac_cb->dsaf_dev->dsaf_mode) {
 	case DSAF_MODE_ENABLE_FIX:
 		tmp_port = 0;
@@ -193,7 +200,7 @@ static int hns_mac_get_inner_port_num(struct hns_mac_cb *mac_cb,
 	case DSAF_MODE_DISABLE_6PORT_2VM:
 	case DSAF_MODE_DISABLE_6PORT_4VM:
 	case DSAF_MODE_DISABLE_6PORT_16VM:
-		tmp_port = vmid;
+		tmp_port = vm_queue_id;
 		break;
 	default:
 		dev_err(mac_cb->dev, "dsaf mode invalid,%s mac%d!\n",
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
index 4cbdf14..d3a1f72 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
@@ -461,5 +461,7 @@ void hns_set_led_opt(struct hns_mac_cb *mac_cb);
 int hns_cpld_led_set_id(struct hns_mac_cb *mac_cb,
 			enum hnae_led_state status);
 void hns_mac_set_promisc(struct hns_mac_cb *mac_cb, u8 en);
+int hns_mac_get_inner_port_num(struct hns_mac_cb *mac_cb,
+			       u8 vmid, u8 *port_num);
 
 #endif /* _HNS_DSAF_MAC_H */
-- 
1.7.9.5
