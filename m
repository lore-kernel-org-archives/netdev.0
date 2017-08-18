From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net-next 1/3] net: hns3: Fixes the missing u64_stats_fetch_begin_irq in 64-bit stats fetch
Date: Fri, 18 Aug 2017 12:31:37 +0100
Message-ID: <20170818113139.153200-2-salil.mehta@huawei.com>
References: <20170818113139.153200-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <lipeng321@huawei.com>, <dan.carpenter@oracle.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
        <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170818113139.153200-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the missing u64_stats_fetch_begin_irq() while trying to
atomically do 64-bit RX/TX fetch. We did not get any error during test
as our SoC is 64-bit so all of these seq/lock operations results in NOOP.

As such, this seq lock supports has been added for the sake of completion
if this code ever runs on 32-bit platform and we are trying to do 64-bit
stats fetch.

Fixes: 76ad4f0ee747 ("net: hns3: Add support of HNS3 Ethernet Driver for
hip08 SoC")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
index 9589b7e..b12730a 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
@@ -1054,6 +1054,7 @@ hns3_nic_get_stats64(struct net_device *netdev, struct rtnl_link_stats64 *stats)
 		/* fetch the tx stats */
 		ring = priv->ring_data[idx].ring;
 		do {
+			start = u64_stats_fetch_begin_irq(&ring->syncp);
 			tx_bytes += ring->stats.tx_bytes;
 			tx_pkts += ring->stats.tx_pkts;
 		} while (u64_stats_fetch_retry_irq(&ring->syncp, start));
@@ -1061,6 +1062,7 @@ hns3_nic_get_stats64(struct net_device *netdev, struct rtnl_link_stats64 *stats)
 		/* fetch the rx stats */
 		ring = priv->ring_data[idx + queue_num].ring;
 		do {
+			start = u64_stats_fetch_begin_irq(&ring->syncp);
 			rx_bytes += ring->stats.rx_bytes;
 			rx_pkts += ring->stats.rx_pkts;
 		} while (u64_stats_fetch_retry_irq(&ring->syncp, start));
-- 
2.7.4
