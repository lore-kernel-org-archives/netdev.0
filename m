From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/net: ntb_netdev: Convert timers to use timer_setup()
Date: Mon, 30 Oct 2017 14:05:12 -0700
Message-ID: <20171030210512.GA9899@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jon Mason <jdmason@kudzu.us>, Dave Jiang <dave.jiang@intel.com>,
        Allen Hubbe <Allen.Hubbe@emc.com>, linux-ntb@googlegroups.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Jon Mason <jdmason@kudzu.us>
Cc: Dave Jiang <dave.jiang@intel.com>
Cc: Allen Hubbe <Allen.Hubbe@emc.com>
Cc: linux-ntb@googlegroups.com
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ntb_netdev.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ntb_netdev.c b/drivers/net/ntb_netdev.c
index 0250aa9ae2cb..9f6f7ccd44f7 100644
--- a/drivers/net/ntb_netdev.c
+++ b/drivers/net/ntb_netdev.c
@@ -230,10 +230,10 @@ static netdev_tx_t ntb_netdev_start_xmit(struct sk_buff *skb,
 	return NETDEV_TX_BUSY;
 }
 
-static void ntb_netdev_tx_timer(unsigned long data)
+static void ntb_netdev_tx_timer(struct timer_list *t)
 {
-	struct net_device *ndev = (struct net_device *)data;
-	struct ntb_netdev *dev = netdev_priv(ndev);
+	struct ntb_netdev *dev = from_timer(dev, t, tx_timer);
+	struct net_device *ndev = dev->ndev;
 
 	if (ntb_transport_tx_free_entry(dev->qp) < tx_stop) {
 		mod_timer(&dev->tx_timer, jiffies + msecs_to_jiffies(tx_time));
@@ -269,7 +269,7 @@ static int ntb_netdev_open(struct net_device *ndev)
 		}
 	}
 
-	setup_timer(&dev->tx_timer, ntb_netdev_tx_timer, (unsigned long)ndev);
+	timer_setup(&dev->tx_timer, ntb_netdev_tx_timer, 0);
 
 	netif_carrier_off(ndev);
 	ntb_transport_link_up(dev->qp);
-- 
2.7.4


-- 
Kees Cook
Pixel Security
