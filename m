From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Subject: [PATCH net-next] hv_netvsc: Set tx_table to equal weight after subchannels open
Date: Fri, 27 Oct 2017 12:36:38 -0700
Message-ID: <20171027193638.17823-1-haiyangz@exchange.microsoft.com>
Reply-To: haiyangz@microsoft.com
Cc: haiyangz@microsoft.com, kys@microsoft.com, sthemmin@microsoft.com,
        olaf@aepfle.de, vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>

In some cases, like internal vSwitch, the host doesn't provide
send indirection table updates. This patch sets the table to be
equal weight after subchannels are all open. Otherwise, all workload
will be on one TX channel.

As tested, this patch has largely increased the throughput over
internal vSwitch.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/rndis_filter.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index addf9f69c58c..0648eebda829 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -1114,6 +1114,9 @@ void rndis_set_subchannel(struct work_struct *w)
 	netif_set_real_num_tx_queues(ndev, nvdev->num_chn);
 	netif_set_real_num_rx_queues(ndev, nvdev->num_chn);
 
+	for (i = 0; i < VRSS_SEND_TAB_SIZE; i++)
+		ndev_ctx->tx_table[i] = i % nvdev->num_chn;
+
 	rtnl_unlock();
 	return;
 
-- 
2.14.1
