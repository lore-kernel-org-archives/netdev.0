From: Michal Sojka <sojkam1@fel.cvut.cz>
Subject: Re: [PATCH v2 1/2] can: Decrease default size of CAN_RAW socket send queue
Date: Fri, 24 Jan 2014 11:51:25 +0100
Message-ID: <87sisdbqky.fsf@steelpick.2x.cz>
References: <1390379257-9040-1-git-send-email-sojkam1@fel.cvut.cz> <20140123.124108.891860564230946746.davem@davemloft.net> <52E18331.6050607@pengutronix.de> <20140123.144243.998328685775607324.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20140123.144243.998328685775607324.davem@davemloft.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 23 2014, David Miller wrote:
> From: Michal Sojka <sojkam1@fel.cvut.cz>
> Date: Wed, 22 Jan 2014 09:27:36 +0100
>
>> Since the length of the qdisc queue was set by default to 10
>> packets, this is exactly what was happening.
>
> This is your bug, set the qdisc limit to something more reasonable.

This is what that patch does. It increases qdisc limit from 10 to 100.

> What do you think UDP applications have to do on slow interfaces?
> If they care about overrunning the device queue and getting packet
> drops, they themselves set a smaller socket send buffer size.
>
> CAN is not special in this regard, please stop treating it as such.

CAN is different from UDP in that it cannot send big datagrams. So it
makes sense to change the default sk_sndbuf value. Otherwise, you're
right. I've checked that skb->truesize is the same for small UDP
datagrams and CAN frames.

What about the following?

----8<--------8<-----
Subject: [PATCH v3] can: Decrease default size of CAN_RAW socket send queue

This fixes the infamous ENOBUFS problem, which appears when an
application sends CAN frames faster than they leave the interface.

Packets for sending can be queued at queueing discipline. Qdisc queue
has two limits: maximum length and per-socket byte limit (SO_SNDBUF).
Only the later limit can cause the sender to block. If maximum queue
length limit is reached before the per-socket limit, the application
receives ENOBUFS and there is no way how it can wait for the queue to
become free again. Since the length of the qdisc queue was set by
default to 10 packets, this is exactly what was happening.

This patch decreases the default per-socket limit to the minimum value
(which corresponds to approximately 11 CAN frames) and increases the
length of the qdisc queue to 100 frames. This setting allows for at
least 9 CAN_RAW sockets to send simultaneously to the same CAN
interface without getting ENOBUFS errors.

The exact maximum number of CAN frames that fit into the per-socket
limit is: 1+floor(sk_sndbuf/skb->truesize). On my 32 bit PowerPC
system, skb->truesize = 448 and SOCK_MIN_SNDBUF = 4480. This gives the
limit of 1+floor(4480/448) = 11 CAN frames.

Changes since v2:
- Used SOCK_MIN_SNDBUF instead of a custom lower value.
- Dropped second patch that set SOCK_MIN_SNDBUF differently for
  AF_CAN.

Changes since v1:
- Improved the commit message, added some number from my system.

Signed-off-by: Michal Sojka <sojkam1@fel.cvut.cz>
---
 drivers/net/can/dev.c | 2 +-
 net/can/raw.c         | 3 +++
 2 files changed, 4 insertions(+), 1 deletion(-)

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
index fdda5f6..4293197 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -291,6 +291,9 @@ static int raw_init(struct sock *sk)
 {
 	struct raw_sock *ro = raw_sk(sk);
 
+	/* This limits the number of queued CAN frames to approximately 11 */
+	sk->sk_sndbuf = SOCK_MIN_SNDBUF;
+
 	ro->bound            = 0;
 	ro->ifindex          = 0;
 
-- 
1.8.5.2


