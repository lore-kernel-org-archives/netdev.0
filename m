From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH v2 net-next 5/5] sunvnet: xoff not needed when removing port link
Date: Tue, 14 Mar 2017 10:24:43 -0700
Message-ID: <1489512283-422140-6-git-send-email-shannon.nelson@oracle.com>
References: <1489512283-422140-1-git-send-email-shannon.nelson@oracle.com>
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org,
        Shannon Nelson <shannon.nelson@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489512283-422140-1-git-send-email-shannon.nelson@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The sunvnet netdev is connected to the controlling ldom's vswitch
for network bridging.  However, for higher performance between ldoms,
there also is a channel between each client ldom.  These connections are
represented in the sunvnet driver by a queue for each ldom.  The driver
uses select_queue to tell the stack which queue to use by tracking the mac
addresses on the other end of each port.  When a connected ldom shuts down,
the driver receives an LDC_EVENT_RESET and the port is removed from the
driver, thus a queue with no ldom on the other end will never be selected
for Tx.

The driver was trying to reinforce the "don't use this queue" notion with
netif_tx_stop_queue() and netif_tx_wake_queue(), which really should only
be used to signal a Tx queue is full (aka XOFF).  This misuse of queue
state resulted in NETDEV WATCHDOG messages and lots of unnecessary calls
into the driver's tx_timeout handler.  Simply removing these takes care
of the problem.

Orabug: 25190537

Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet_common.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet_common.c b/drivers/net/ethernet/sun/sunvnet_common.c
index 0c35a9a..7febfb6 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.c
+++ b/drivers/net/ethernet/sun/sunvnet_common.c
@@ -1749,16 +1749,12 @@ void sunvnet_port_add_txq_common(struct vnet_port *port)
 	vp->nports++;
 	vp->q_used[smallest]++;
 	port->q_index = smallest;
-	netif_tx_wake_queue(netdev_get_tx_queue(VNET_PORT_TO_NET_DEVICE(port),
-						port->q_index));
 }
 EXPORT_SYMBOL_GPL(sunvnet_port_add_txq_common);
 
 void sunvnet_port_rm_txq_common(struct vnet_port *port)
 {
 	port->vp->nports--;
-	netif_tx_stop_queue(netdev_get_tx_queue(VNET_PORT_TO_NET_DEVICE(port),
-						port->q_index));
 	port->vp->q_used[port->q_index]--;
 	port->q_index = 0;
 }
-- 
1.7.1
