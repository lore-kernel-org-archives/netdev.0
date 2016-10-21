From: <sudarsana.kalluru@cavium.com>
Subject: [PATCH net 5/7] qede: Reconfigure rss indirection direction table when rss count is updated
Date: Fri, 21 Oct 2016 04:43:43 -0400
Message-ID: <1477039425-31341-6-git-send-email-sudarsana.kalluru@cavium.com>
References: <1477039425-31341-1-git-send-email-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@cavium.com>,
        <Yuval.Mintz@cavium.com>, <manish.chopra@cavium.com>,
        Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:49038 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933879AbcJUJaB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 05:30:01 -0400
In-Reply-To: <1477039425-31341-1-git-send-email-sudarsana.kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>

Rx indirection table entries are in the range [0, (rss_count - 1)]. If
user reduces the rss count, the table entries may not be in the ccorrect
range. Need to reconfigure the table with new rss_count as a basis.

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index 7da184c..d47bdaa 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -822,6 +822,13 @@ static int qede_set_channels(struct net_device *dev,
 	edev->req_queues = count;
 	edev->req_num_tx = channels->tx_count;
 	edev->req_num_rx = channels->rx_count;
+	/* Reset the indirection table if rx queue count is updated */
+	if ((edev->req_queues - edev->req_num_tx) != QEDE_RSS_COUNT(edev)) {
+		edev->rss_params_inited &= ~QEDE_RSS_INDIR_INITED;
+		memset(&edev->rss_params.rss_ind_table, 0,
+		       sizeof(edev->rss_params.rss_ind_table));
+	}
+
 	if (netif_running(dev))
 		qede_reload(edev, NULL, NULL);
 
-- 
1.8.3.1
