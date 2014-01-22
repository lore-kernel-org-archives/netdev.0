From: Michal Sojka <sojkam1@fel.cvut.cz>
Subject: [PATCH v2 1/2] can: Decrease default size of CAN_RAW socket send queue
Date: Wed, 22 Jan 2014 09:27:36 +0100
Message-ID: <1390379257-9040-1-git-send-email-sojkam1@fel.cvut.cz>
Cc: netdev@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>,
	Michal Sojka <sojkam1@fel.cvut.cz>
To: linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes the infamous ENOBUFS problem, which appears when an
application sends CAN frames faster than they leave the interface.

Packets for sending can be queued at queueing discipline. Qdisc queue
has two limits: maximum length and per-socket byte limit (SO_SNDBUF).
Only the later limit can cause the sender to block. If maximum queue
length limit is reached before the per-socket limit, the application
receives ENOBUFS and there is no way how it can wait for the queue to
become free again. Since the length of the qdisc queue was set by
default to 10 packets, this is exactly what was happening.

This patch decreases the default per-socket limit to approximately 3
CAN frames and increases the length of the qdisc queue to 100 frames.
This setting allows for at least 33 CAN_RAW sockets to send
simultaneously to the same CAN interface without getting ENOBUFS
errors.

The exact maximum number of CAN frames that fit into the per-socket
limit is: 1+floor(sk_sndbuf/skb->truesize)

The calculation of the default sk_sndbuf value in the patch is only
approximate, because skb->truesize can be slightly greater than
SKB_TRUESIZE(). For example, for CAN frames on my 32 bit PowerPC
system, SKB_TRUESIZE() = 408, but skb->truesize = 448. Therefore, on
my system the per-socket limit allows 1+floor(3*408/448) =
1+floor(2.73) = 3 CAN frames to be queued.

Without this patch, the default per-socket limit is
/proc/sys/net/core/wmem_default, which is 163840 on my system. This
limit allows for queuing of 1+163840/448 = 366 CAN frames, which is
clearly more than the queue length (10 frames).

Since the per-socket limit is expressed in bytes, the number of queued
CANFD frames, which are bigger than CAN frames, may be lower. This is
not a big problem, because at least one frame could be always queued.

Changes since v1:
- Improved the commit message, added some number from my system.

Signed-off-by: Michal Sojka <sojkam1@fel.cvut.cz>
---
 drivers/net/can/dev.c | 2 +-
 net/can/raw.c         | 4 ++++
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index 1870c47..a0bce83 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -492,7 +492,7 @@ static void can_setup(struct net_device *dev)
 	dev->mtu = CAN_MTU;
 	dev->hard_header_len = 0;
 	dev->addr_len = 0;
-	dev->tx_queue_len = 10;
+	dev->tx_queue_len = 100;
 
 	/* New-style flags. */
 	dev->flags = IFF_NOARP;
diff --git a/net/can/raw.c b/net/can/raw.c
index fdda5f6..4ad0bb2 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -291,6 +291,10 @@ static int raw_init(struct sock *sk)
 {
 	struct raw_sock *ro = raw_sk(sk);
 
+	/* allow at most 3 frames to wait for transmission in socket queue */
+	sk->sk_sndbuf = 3 * SKB_TRUESIZE(sizeof(struct can_frame) +
+					 sizeof(struct can_skb_priv));
+
 	ro->bound            = 0;
 	ro->ifindex          = 0;
 
-- 
1.8.5.2

