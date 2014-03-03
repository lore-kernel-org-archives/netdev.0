From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 8/8] can: remove CAN FD compatibility for CAN 2.0 sockets
Date: Mon,  3 Mar 2014 14:54:35 +0100
Message-ID: <1393854875-8171-9-git-send-email-mkl@pengutronix.de>
References: <1393854875-8171-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Oliver Hartkopp <socketcan@hartkopp.net>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1393854875-8171-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oliver Hartkopp <socketcan@hartkopp.net>

In commit e2d265d3b587 (canfd: add support for CAN FD in CAN_RAW sockets)
CAN FD frames with a payload length up to 8 byte are passed to legacy
sockets where the CAN FD support was not enabled by the application.

After some discussions with developers at a fair this well meant feature
leads to confusion as no clean switch for CAN / CAN FD is provided to the
application programmer. Additionally a compatibility like this for legacy
CAN_RAW sockets requires some compatibility handling for the sending, e.g.
make CAN2.0 frames a CAN FD frame with BRS at transmission time (?!?).

This will become a mess when people start to develop applications with
real CAN FD hardware. This patch reverts the bad compatibility code
together with the documentation describing the removed feature.

Acked-by: Stephane Grosjean <s.grosjean@peak-system.com>
Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 Documentation/networking/can.txt |  6 ------
 net/can/raw.c                    | 26 +++++---------------------
 2 files changed, 5 insertions(+), 27 deletions(-)

diff --git a/Documentation/networking/can.txt b/Documentation/networking/can.txt
index f3089d4..0cbe6ec 100644
--- a/Documentation/networking/can.txt
+++ b/Documentation/networking/can.txt
@@ -554,12 +554,6 @@ solution for a couple of reasons:
   not specified in the struct can_frame and therefore it is only valid in
   CANFD_MTU sized CAN FD frames.
 
-  As long as the payload length is <=8 the received CAN frames from CAN FD
-  capable CAN devices can be received and read by legacy sockets too. When
-  user-generated CAN FD frames have a payload length <=8 these can be send
-  by legacy CAN network interfaces too. Sending CAN FD frames with payload
-  length > 8 to a legacy CAN network interface returns an -EMSGSIZE error.
-
   Implementation hint for new CAN applications:
 
   To build a CAN FD aware application use struct canfd_frame as basic CAN
diff --git a/net/can/raw.c b/net/can/raw.c
index 8be757c..081e81f 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -121,13 +121,9 @@ static void raw_rcv(struct sk_buff *oskb, void *data)
 	if (!ro->recv_own_msgs && oskb->sk == sk)
 		return;
 
-	/* do not pass frames with DLC > 8 to a legacy socket */
-	if (!ro->fd_frames) {
-		struct canfd_frame *cfd = (struct canfd_frame *)oskb->data;
-
-		if (unlikely(cfd->len > CAN_MAX_DLEN))
-			return;
-	}
+	/* do not pass non-CAN2.0 frames to a legacy socket */
+	if (!ro->fd_frames && oskb->len != CAN_MTU)
+		return;
 
 	/* clone the given skb to be able to enqueue it into the rcv queue */
 	skb = skb_clone(oskb, GFP_ATOMIC);
@@ -738,9 +734,7 @@ static int raw_recvmsg(struct kiocb *iocb, struct socket *sock,
 		       struct msghdr *msg, size_t size, int flags)
 {
 	struct sock *sk = sock->sk;
-	struct raw_sock *ro = raw_sk(sk);
 	struct sk_buff *skb;
-	int rxmtu;
 	int err = 0;
 	int noblock;
 
@@ -751,20 +745,10 @@ static int raw_recvmsg(struct kiocb *iocb, struct socket *sock,
 	if (!skb)
 		return err;
 
-	/*
-	 * when serving a legacy socket the DLC <= 8 is already checked inside
-	 * raw_rcv(). Now check if we need to pass a canfd_frame to a legacy
-	 * socket and cut the possible CANFD_MTU/CAN_MTU length to CAN_MTU
-	 */
-	if (!ro->fd_frames)
-		rxmtu = CAN_MTU;
-	else
-		rxmtu = skb->len;
-
-	if (size < rxmtu)
+	if (size < skb->len)
 		msg->msg_flags |= MSG_TRUNC;
 	else
-		size = rxmtu;
+		size = skb->len;
 
 	err = memcpy_toiovec(msg->msg_iov, skb->data, size);
 	if (err < 0) {
-- 
1.9.0

