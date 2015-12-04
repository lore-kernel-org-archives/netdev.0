From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH] net: qca_spi: fix transmit queue timeout handling
Date: Fri,  4 Dec 2015 16:29:10 +0100
Message-ID: <1449242950-19291-1-git-send-email-stefan.wahren@i2se.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stefan Wahren <stefan.wahren@i2se.com>,
	<stable@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In case of a tx queue timeout every transmit is blocked until the
QCA7000 resets himself and triggers a sync which makes the driver
flushs the tx ring. So avoid this blocking situation by triggering
the sync immediately after the timeout. Waking the queue doesn't
make sense in this situation.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
Cc: <stable@vger.kernel.org> # v3.18+
Fixes: 291ab06ecf67 ("net: qualcomm: new Ethernet over SPI driver for QCA7000")

---
 drivers/net/ethernet/qualcomm/qca_spi.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethernet/qualcomm/qca_spi.c
index ddb2c6c..689a4a5 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.c
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@ -736,9 +736,8 @@ qcaspi_netdev_tx_timeout(struct net_device *dev)
 	netdev_info(qca->net_dev, "Transmit timeout at %ld, latency %ld\n",
 		    jiffies, jiffies - dev->trans_start);
 	qca->net_dev->stats.tx_errors++;
-	/* wake the queue if there is room */
-	if (qcaspi_tx_ring_has_space(&qca->txr))
-		netif_wake_queue(dev);
+	/* Trigger tx queue flush and QCA7000 reset */
+	qca->sync = QCASPI_SYNC_UNKNOWN;
 }
 
 static int
-- 
2.1.4
