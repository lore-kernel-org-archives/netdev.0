From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 10/16] can: c_can: Remove EOB exit
Date: Tue,  1 Apr 2014 23:42:24 +0200
Message-ID: <1396388550-23081-11-git-send-email-mkl@pengutronix.de>
References: <1396388550-23081-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Thomas Gleixner <tglx@linutronix.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1396388550-23081-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Gleixner <tglx@linutronix.de>

The rx_poll code has the following gem:

	if (msg_ctrl_save & IF_MCONT_EOB)
		return num_rx_pkts;

The EOB bit is the indicator for the hardware that this is the last
configured FIFO object. But this object can contain valid data, if we
manage to free up objects before the overrun case hits.

Now if the code exits due to the EOB bit set, then this buffer is
stale and the interrupt bit and NewDat bit of the buffer are still
set. Results in a nice interrupt storm unless we come into an overrun
situation where the MSGLST bit gets set.

     ksoftirqd/0-3     [000] ..s.    79.124101: c_can_poll: rx_poll: val: 00008001 pend 00008001
     ksoftirqd/0-3     [000] ..s.    79.124176: c_can_poll: rx_poll: val: 00008000 pend 00008000
     ksoftirqd/0-3     [000] ..s.    79.124187: c_can_poll: rx_poll: val: 00008002 pend 00008002
     ksoftirqd/0-3     [000] ..s.    79.124256: c_can_poll: rx_poll: val: 00008000 pend 00008000
     ksoftirqd/0-3     [000] ..s.    79.124267: c_can_poll: rx_poll: val: 00008000 pend 00008000

The amazing thing is that the check of the MSGLST (aka overrun bit)
used to be after the check of the EOB bit. That was "fixed" in commit
5d0f801a2c(can: c_can: Fix RX message handling, handle lost message
before EOB). But the author of this "fix" did not even understand that
the EOB check is broken as well.

Again a simple solution: Remove

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
[mkl: adjusted subject and commit message]
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index ef5f3b8..30a85aa 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -915,9 +915,6 @@ static int c_can_do_rx_poll(struct net_device *dev, int quota)
 				continue;
 			}
 
-			if (msg_ctrl_save & IF_MCONT_EOB)
-				return num_rx_pkts;
-
 			if (!(msg_ctrl_save & IF_MCONT_NEWDAT))
 				continue;
 
-- 
1.9.0.279.gdc9e3eb

