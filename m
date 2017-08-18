From: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next] net: hns3: Add support to change MTU in hardware & netdev
Date: Fri, 18 Aug 2017 12:35:58 +0100
Message-ID: <20170818113558.71928-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        <lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        <mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds the following support to the HNS3 driver:
1. Support to change the Maximum Transmission Unit of a
   netdevice and of a port in hardware .
2. Initializes the supported MTU range for the netdevice.

Signed-off-by: lipeng <lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 46 ++++++++++++++++++++++
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h |  1 +
 2 files changed, 47 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
index e731f87..8e3711e 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
@@ -1278,11 +1278,53 @@ static int hns3_ndo_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan,
 	return ret;
 }
 
+static int hns3_nic_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	struct hns3_nic_priv *priv = netdev_priv(netdev);
+	struct hnae3_handle *h = priv->ae_handle;
+	bool if_running = netif_running(netdev);
+	int ret;
+
+	/* no change in MTU */
+	if (new_mtu == netdev->mtu)
+		return 0;
+
+	if (!h->ae_algo->ops->set_mtu)
+		return -ENOTSUPP;
+
+	/* if this was called with netdev up then bring netdevice down */
+	if (if_running) {
+		(void)hns3_nic_net_stop(netdev);
+		msleep(100);
+	}
+
+	ret = h->ae_algo->ops->set_mtu(h, new_mtu);
+	if (ret) {
+		netdev_err(netdev, "failed to change MTU in hardware %d\n",
+			   ret);
+		return ret;
+	}
+
+	/* assign newly changed mtu to netdevice as well */
+	netdev->mtu = new_mtu;
+
+	/* if the netdev was running earlier, bring it up again */
+	if (if_running) {
+		if (hns3_nic_net_open(netdev)) {
+			netdev_err(netdev, "MTU, couldnt up netdev again\n");
+			ret = -EINVAL;
+		}
+	}
+
+	return ret;
+}
+
 static const struct net_device_ops hns3_nic_netdev_ops = {
 	.ndo_open		= hns3_nic_net_open,
 	.ndo_stop		= hns3_nic_net_stop,
 	.ndo_start_xmit		= hns3_nic_net_xmit,
 	.ndo_set_mac_address	= hns3_nic_net_set_mac_address,
+	.ndo_change_mtu		= hns3_nic_change_mtu,
 	.ndo_set_features	= hns3_nic_set_features,
 	.ndo_get_stats64	= hns3_nic_get_stats64,
 	.ndo_setup_tc		= hns3_nic_setup_tc,
@@ -2752,6 +2794,10 @@ static int hns3_client_init(struct hnae3_handle *handle)
 		goto out_reg_netdev_fail;
 	}
 
+	/* MTU range: 68 - 9706 */
+	netdev->min_mtu = ETH_MIN_MTU;
+	netdev->max_mtu = HNS3_MAX_MTU - (ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN);
+
 	return ret;
 
 out_reg_netdev_fail:
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h
index a6e8f15..7e87461 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h
@@ -76,6 +76,7 @@ enum hns3_nic_state {
 #define HNS3_RING_NAME_LEN			16
 #define HNS3_BUFFER_SIZE_2048			2048
 #define HNS3_RING_MAX_PENDING			32768
+#define HNS3_MAX_MTU				9728
 
 #define HNS3_BD_SIZE_512_TYPE			0
 #define HNS3_BD_SIZE_1024_TYPE			1
-- 
2.7.4


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
