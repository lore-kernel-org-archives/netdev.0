From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [RFC PATCH v3 1/2] can: fix multiple delivery of a single CAN frame for overlapping CAN filters
Date: Wed,  1 Apr 2015 07:50:28 +0200
Message-ID: <1427867429-3909-2-git-send-email-socketcan@hartkopp.net>
References: <1427867429-3909-1-git-send-email-socketcan@hartkopp.net>
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	Oliver Hartkopp <socketcan@hartkopp.net>
To: linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1427867429-3909-1-git-send-email-socketcan@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The CAN_RAW socket can set multiple CAN identifier specific filters that lead
to multiple filters in the af_can.c filter processing. These filters are
indenpendent from each other which leads to logical OR'ed filters when applied.

This patch makes sure that every CAN frame which is filtered for a specific
socket is only delivered once to the user space. This is independent from the
number of matching CAN filters of this socket.

As the raw_rcv() function is executed from NET_RX softirq the introduced
variables are implemented as per-CPU variables to avoid extensive locking at
CAN frame reception time.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
---
 net/can/raw.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/net/can/raw.c b/net/can/raw.c
index 00c13ef..8c75446 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -74,6 +74,11 @@ MODULE_ALIAS("can-proto-1");
  * storing the single filter in dfilter, to avoid using dynamic memory.
  */
 
+struct uniqframe {
+	const struct sk_buff *skb;
+	ktime_t tstamp;
+};
+
 struct raw_sock {
 	struct sock sk;
 	int bound;
@@ -86,6 +91,7 @@ struct raw_sock {
 	struct can_filter dfilter; /* default/single filter */
 	struct can_filter *filter; /* pointer to filter(s) */
 	can_err_mask_t err_mask;
+	struct uniqframe __percpu *uniq;
 };
 
 /*
@@ -123,6 +129,15 @@ static void raw_rcv(struct sk_buff *oskb, void *data)
 	if (!ro->fd_frames && oskb->len != CAN_MTU)
 		return;
 
+	/* eliminate multiple filter matches for the same skb */
+	if (this_cpu_ptr(ro->uniq)->skb == oskb &&
+	    ktime_equal(this_cpu_ptr(ro->uniq)->tstamp, oskb->tstamp)) {
+		return;
+	} else {
+		this_cpu_ptr(ro->uniq)->skb = oskb;
+		this_cpu_ptr(ro->uniq)->tstamp = oskb->tstamp;
+	}
+
 	/* clone the given skb to be able to enqueue it into the rcv queue */
 	skb = skb_clone(oskb, GFP_ATOMIC);
 	if (!skb)
@@ -297,6 +312,11 @@ static int raw_init(struct sock *sk)
 	ro->recv_own_msgs    = 0;
 	ro->fd_frames        = 0;
 
+	/* alloc_percpu provides zero'ed memory */
+	ro->uniq = alloc_percpu(struct uniqframe);
+	if (unlikely(!ro->uniq))
+		return -ENOMEM;
+
 	/* set notifier */
 	ro->notifier.notifier_call = raw_notifier;
 
@@ -339,6 +359,7 @@ static int raw_release(struct socket *sock)
 	ro->ifindex = 0;
 	ro->bound   = 0;
 	ro->count   = 0;
+	free_percpu(ro->uniq);
 
 	sock_orphan(sk);
 	sock->sk = NULL;
-- 
2.1.4

