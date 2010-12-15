From: "Fenghua Yu" <fenghua.yu@intel.com>
Subject: [PATCH 3/3] drivers/net/ixgbe/ixgbe_main.c: get tx queue mapping specified in socket
Date: Wed, 15 Dec 2010 12:02:06 -0800
Message-ID: <e37daf1b95d0e61008c69298db5520d6b97acdba.1292405004.git.fenghua.yu@intel.com>
References: <cover.1292405004.git.fenghua.yu@intel.com>
Cc: "netdev" <netdev@vger.kernel.org>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Junchang Wang <junchangwang@gmail.com>,
	Xinan Tang <xinan.tang@intel.com>
To: "David S. Miller" <davem@davemloft.net>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"John Fastabend" <john.r.fastabend@intel.com>,
	"Xinan Tang" <xinan.tang@intel.com>,
	"Junchang Wang"
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1292405004.git.fenghua.yu@intel.com>
In-Reply-To: <cover.1292405004.git.fenghua.yu@intel.com>
References: <cover.1292405004.git.fenghua.yu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fenghua Yu <fenghua.yu@intel.com>

Instead of using calculated tx queue mapping, this patch selects tx queue mapping
which is specified in socket.

By doing this, tx queue mapping can be bigger than the number of cores and
stressfully use multiqueue TSS. Or application can specify some of cores/queues
to send packets and implement flexible load balance policies.

Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>
Signed-off-by: Junchang Wang <junchangwang@gmail.com>
Signed-off-by: Xinan Tang <xinan.tang@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index eee0b29..4d98928 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6255,7 +6255,14 @@ static int ixgbe_maybe_stop_tx(struct net_device *netdev,
 static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
-	int txq = smp_processor_id();
+	int txq;
+
+	txq = sk_tx_queue_get(skb->sk);
+
+	if (txq >= 0 && txq < dev->real_num_tx_queues)
+		return txq;
+
+	txq = smp_processor_id();
 #ifdef IXGBE_FCOE
 	__be16 protocol;
 
-- 
1.6.0.3
