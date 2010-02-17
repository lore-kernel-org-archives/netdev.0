From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 3/3] qlge: Fix occasional loopback test failure.
Date: Wed, 17 Feb 2010 08:41:23 -0800
Message-ID: <1266424883-25927-4-git-send-email-ron.mercer@qlogic.com>
References: <1266424883-25927-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:36599 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751589Ab0BQQsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 11:48:32 -0500
In-Reply-To: <1266424883-25927-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On some servers we see the cleaning of the RX queue finish before all
the loopback packets are sent out.  This delay allows the queues to
settle before checking for successful completion.
Also, delay completion so link has time to come back up.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_ethtool.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge_ethtool.c b/drivers/net/qlge/qlge_ethtool.c
index 4f26afe..05b8bde 100644
--- a/drivers/net/qlge/qlge_ethtool.c
+++ b/drivers/net/qlge/qlge_ethtool.c
@@ -503,7 +503,8 @@ static int ql_run_loopback_test(struct ql_adapter *qdev)
 			return -EPIPE;
 		atomic_inc(&qdev->lb_count);
 	}
-
+	/* Give queue time to settle before testing results. */
+	msleep(2);
 	ql_clean_lb_rx_ring(&qdev->rx_ring[0], 128);
 	return atomic_read(&qdev->lb_count) ? -EIO : 0;
 }
@@ -536,6 +537,10 @@ static void ql_self_test(struct net_device *ndev,
 			data[0] = 0;
 		}
 		clear_bit(QL_SELFTEST, &qdev->flags);
+		/* Give link time to come up after
+		 * port configuration changes.
+		 */
+		msleep_interruptible(4 * 1000);
 	} else {
 		netif_err(qdev, drv, qdev->ndev,
 			  "is down, Loopback test will fail.\n");
-- 
1.6.0.2

