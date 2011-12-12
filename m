From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [PATCH net-next] can: cc770: store echo skb before starting the transfer
Date: Mon, 12 Dec 2011 16:07:16 +0100
Message-ID: <4EE618A4.80104@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-can@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On slow systems and high CAN bitrates, the error message
"can_put_echo_skb: BUG! echo_skb is occupied!" did show up because
can_put_echo_skb() was called after starting the transfer.

Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
---
 drivers/net/can/cc770/cc770.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/cc770/cc770.c b/drivers/net/can/cc770/cc770.c
index 7668967..c30f0e6 100644
--- a/drivers/net/can/cc770/cc770.c
+++ b/drivers/net/can/cc770/cc770.c
@@ -440,12 +440,14 @@ static netdev_tx_t cc770_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	for (i = 0; i < dlc; i++)
 		cc770_write_reg(priv, msgobj[mo].data[i], cf->data[i]);
 
+	/* Store echo skb before starting the transfer */
+	can_put_echo_skb(skb, dev, 0);
+
 	cc770_write_reg(priv, msgobj[mo].ctrl1,
 			RMTPND_RES | TXRQST_SET | CPUUPD_RES | NEWDAT_UNC);
 
 	stats->tx_bytes += dlc;
 
-	can_put_echo_skb(skb, dev, 0);
 
 	/*
 	 * HM: We had some cases of repeated IRQs so make sure the
-- 
1.7.4.1

