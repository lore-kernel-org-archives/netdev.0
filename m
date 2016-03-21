From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net 01/10] net: hns: bug fix about ping6
Date: Mon, 21 Mar 2016 19:06:32 +0800
Message-ID: <1458558401-190165-2-git-send-email-Yisen.Zhuang@huawei.com>
References: <1458558401-190165-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yankejian@huawei.com>, <huangdaode@hisilicon.com>,
	<salil.mehta@huawei.com>, <lisheng011@huawei.com>,
	<lipeng321@huawei.com>, <liguozhu@huawei.com>, <arnd@arndb.de>,
	<xieqianqian@huawei.com>, <andrew@lunn.ch>, <ivecera@redhat.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458558401-190165-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kejian Yan <yankejian@huawei.com>

The current upstreaming code fails to ping other IPv6 net device, because
the enet receives the multicast packets with the src mac addr whick is the
same as its mac addr. These packets need to be dropped.

Signed-off-by: Kejian Yan <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 3f77ff7..9ad5da4 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -564,6 +564,7 @@ static int hns_nic_poll_rx_skb(struct hns_nic_ring_data *ring_data,
 	struct sk_buff *skb;
 	struct hnae_desc *desc;
 	struct hnae_desc_cb *desc_cb;
+	struct ethhdr *eh;
 	unsigned char *va;
 	int bnum, length, i;
 	int pull_len;
@@ -670,6 +671,14 @@ out_bnum_err:
 		return -EFAULT;
 	}
 
+	/* filter out multicast pkt with the same src mac as this port */
+	eh = (struct ethhdr *)skb->data;
+	if (unlikely(is_multicast_ether_addr(eh->h_dest) &&
+		     ether_addr_equal(ndev->dev_addr, eh->h_source))) {
+		dev_kfree_skb_any(skb);
+		return -EFAULT;
+	}
+
 	ring->stats.rx_pkts++;
 	ring->stats.rx_bytes += skb->len;
 
-- 
1.9.1
