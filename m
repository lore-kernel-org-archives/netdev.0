From: yankejian <yankejian@huawei.com>
Subject: [PATCH net-next 2/2] net: hns: fixes a bug about timeout by pause frame
Date: Fri, 16 Oct 2015 17:03:20 +0800
Message-ID: <1444986200-39566-3-git-send-email-yankejian@huawei.com>
References: <1444986200-39566-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linuxarm@huawei.com>
To: <liguozhu@huawei.com>, <yisen.zhuang@huawei.com>,
	<huangdaode@hisilicon.com>, <lipeng321@huawei.com>,
	<yankejian@huawei.com>, <davem@davemloft.net>,
	<chenny.xu@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444986200-39566-1-git-send-email-yankejian@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: lisheng <lisheng011@huawei.com>

this patch fixes the bug triggered timeout sequence. when the connective
ports cannot accept the packets with higher speed, they will send out the
pause frame to the Soc's mac. At that time, the driver resets the relevant
of the Soc, then it causes the packets cannot be sent out immediately.
this patch fixes the issue.

Signed-off-by: yankejian <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: lisheng <lisheng011@huawei.com>
Signed-off-by: lipeng <lipeng321@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 6f9091c..302d3ae 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -1315,16 +1315,15 @@ static void hns_nic_reset_subtask(struct hns_nic_priv *priv)
 		return;
 
 	hns_nic_dump(priv);
-	netdev_err(priv->netdev, "Reset %s port\n",
-		   (type == HNAE_PORT_DEBUG ? "debug" : "business"));
+	netdev_info(priv->netdev, "Reset %s port\n",
+		    (type == HNAE_PORT_DEBUG ? "debug" : "business"));
 
 	rtnl_lock();
-	if (type == HNAE_PORT_DEBUG) {
+	/* put off any impending NetWatchDogTimeout */
+	priv->netdev->trans_start = jiffies;
+
+	if (type == HNAE_PORT_DEBUG)
 		hns_nic_net_reinit(priv->netdev);
-	} else {
-		hns_nic_net_down(priv->netdev);
-		hns_nic_net_reset(priv->netdev);
-	}
 	rtnl_unlock();
 }
 
-- 
1.9.1
