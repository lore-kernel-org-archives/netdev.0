From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.30] wimax/i2400m: fix device crash: fix optimization in
	_roq_queue_update_ws
Date: Fri, 15 May 2009 12:07:33 -0700
Message-ID: <4e5b6d006b61b6b998e15da850d959520f811b4c.1242405228.git.inaky@linux.intel.com>
References: <cover.1242405228.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org,
	wimax@linuxwimax.org
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <cover.1242405228.git.inaky@linux.intel.com>
In-Reply-To: <cover.1242405228.git.inaky@linux.intel.com>
References: <cover.1242405228.git.inaky@linux.intel.com>
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

When the i2400m receives data and the device indicates there has to be
reordering, we keep an sliding window implementation to sort the
packets before sending them to the network stack.

One of the "operations" that the device indicates is "queue a packet
and update the window start". When the queue is empty, this is
equivalent to "deliver the packet and update the window start".

That case was optimized in i2400m_roq_queue_update_ws() so that we
would not pointlessly queue and dequeue a packet. However, when the
optimization was active, it wasn't updating the window start. That
caused the reorder management code to get confused later on with what
seemed to be wrong reorder requests from the device.

Thus the fix implemented is to do the right thing and update the
window start in both cases, when the queue is empty (and the
optimization is done) and when not.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/rx.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wimax/i2400m/rx.c b/drivers/net/wimax/i2400m/rx.c
index 02419bf..f9fc389 100644
--- a/drivers/net/wimax/i2400m/rx.c
+++ b/drivers/net/wimax/i2400m/rx.c
@@ -819,10 +819,9 @@ void i2400m_roq_queue_update_ws(struct i2400m *i2400m, struct i2400m_roq *roq,
 			roq_data = (struct i2400m_roq_data *) &skb->cb;
 			i2400m_net_erx(i2400m, skb, roq_data->cs);
 		}
-		else {
+		else
 			__i2400m_roq_queue(i2400m, roq, skb, sn, nsn);
-			__i2400m_roq_update_ws(i2400m, roq, sn + 1);
-		}
+		__i2400m_roq_update_ws(i2400m, roq, sn + 1);
 		i2400m_roq_log_add(i2400m, roq, I2400M_RO_TYPE_PACKET_WS,
 				   old_ws, len, sn, nsn, roq->ws);
 	}
-- 
1.6.2.3
