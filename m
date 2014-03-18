From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 06/12] can: c_can: Remove braindamaged EOB exit
Date: Tue, 18 Mar 2014 17:19:11 -0000
Message-ID: <20140318171127.186186948@linutronix.de>
References: <20140318171007.528610837@linutronix.de>
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Markus Pargmann <mpa@pengutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=can-c-can-fix-eob-handling.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

Again a simple solution: Remove the brainfart.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 drivers/net/can/c_can/c_can.c |    3 ---
 1 file changed, 3 deletions(-)

Index: linux/drivers/net/can/c_can/c_can.c
===================================================================
--- linux.orig/drivers/net/can/c_can/c_can.c
+++ linux/drivers/net/can/c_can/c_can.c
@@ -906,9 +906,6 @@ static int c_can_do_rx_poll(struct net_d
 				continue;
 			}
 
-			if (msg_ctrl_save & IF_MCONT_EOB)
-				return num_rx_pkts;
-
 			if (!(msg_ctrl_save & IF_MCONT_NEWDAT))
 				continue;
 
