From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net-next 16/19] net: hns: fix bug that alloc skb fail lead to port unavailable
Date: Tue, 21 Jun 2016 11:56:36 +0800
Message-ID: <1466481399-70080-17-git-send-email-Yisen.Zhuang@huawei.com>
References: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <liguozhu@huawei.com>, <huangdaode@hisilicon.com>, <arnd@arndb.de>,
	<andriy.shevchenko@linux.intel.com>, <andrew@lunn.ch>,
	<geliangtang@163.com>, <ivecera@redhat.com>,
	<fengguang.wu@intel.com>, <charles.chenxin@huawei.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
	<salil.mehta@huawei.com>, <yankejian@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jun He <hjat2005@huawei.com>

When hns_nic_poll_rx_skb alloc skb fail, it will break receive cycle and
read new fbd_num to start new receive cycle. It recomputes cycle num is
fbd_num minus clean_count, actually this cycle num is too big because
it drop out receive cycle. It brings about the port unavailable.

So we will goto out when alloc skb fail to fix this bug.

Signed-off-by: Jun He <hjat2005@huawei.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index f49246d..c0ce37b 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -768,10 +768,10 @@ recv:
 			clean_count = 0;
 		}
 
-		/* poll one pkg*/
+		/* poll one pkt*/
 		err = hns_nic_poll_rx_skb(ring_data, &skb, &bnum);
 		if (unlikely(!skb)) /* this fault cannot be repaired */
-			break;
+			goto out;
 
 		recv_bds += bnum;
 		clean_count += bnum;
@@ -797,6 +797,7 @@ recv:
 		}
 	}
 
+out:
 	/* make all data has been write before submit */
 	if (clean_count > 0)
 		hns_nic_alloc_rx_buffers(ring_data, clean_count);
-- 
1.9.1
