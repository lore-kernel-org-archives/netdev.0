From: "manfred.schlaegl@gmx.at" <manfred.schlaegl@gmx.at>
Subject: [PATCH] can: fix loss of frames due to wrong assumption in raw_rcv
Date: Sat, 20 Jun 2015 18:24:09 +0200
Message-ID: <558593A9.2040105@gmx.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Manfred Schlaegl <manfred.schlaegl@ginzinger.com>
To: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've detected a massive loss of can frames on i.MX6 using flexcan
driver with 4.1-rc8 and tracked this down to following commit:
514ac99c64b22d83b52dfee3b8becaa69a92bc4a - "can: fix multiple delivery
of a single CAN frame for overlapping CAN filters"

514ac99c64b22d83b52dfee3b8becaa69a92bc4a introduces a frame equality
check. Since the sk_buff pointer is not sufficient to do this (buffers
are reused), the check also compares time stamps.
In short: pointer+time stamp was assumed as unique key to a specific
frame.
The problem with this is, that the time stamp is an optional property
and not set per default.
In our case (flexcan) the time stamp is always zero, so the equality
check is reduced to equality of buffer pointers, resulting in a lot of
dropped frames.

Possible solutions I thought of:
 1. Every driver has to set a time stamp
    (possibly error prone and hard to enforce?)
 2. Change the equality check
 3. Fulfil the requirements of the equality check by setting a
    time stamp per default.

This patch fixes the problem with solution 3. A time stamp is set at
time of allocation in alloc_can_skb.
The time stamp may be overridden later, but the function of the equality
check is ensured.

I'm not really deep in linux network subsystem, so there may exists
more elegant solutions for the problem.

Signed-off-by: Manfred Schlaegl <manfred.schlaegl@gmx.at>
---
 drivers/net/can/dev.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index b0f6924..282e2e7 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -575,6 +575,7 @@ struct sk_buff *alloc_can_skb(struct net_device
*dev, struct can_frame **cf)
 	if (unlikely(!skb))
 		return NULL;
 +	__net_timestamp(skb);
 	skb->protocol = htons(ETH_P_CAN);
 	skb->pkt_type = PACKET_BROADCAST;
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
-- 
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-can" in
