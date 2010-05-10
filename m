From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 23/64] Bluetooth: Add timer to Acknowledge I-frames
Date: Mon, 10 May 2010 11:37:13 +0200
Message-ID: <c1b4f43be01c2a363be021485dd18cca33cfab8a.1273484097.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
 <fe1aff710756ac73c455d214845c74e304d0e966.1273484095.git.marcel@holtmann.org>
 <acce90d6a957812081b83ac4d1133e93a43569c6.1273484095.git.marcel@holtmann.org>
 <4f7ac1814ef6f0773e57ffd159a1dd57a3c80521.1273484095.git.marcel@holtmann.org>
 <0d861d8b8edd139a9b291cb262d08dec8dc3922d.1273484095.git.marcel@holtmann.org>
 <b9dbdbc1f4404cba2e64939c30c87d59c9796e4e.1273484095.git.marcel@holtmann.org>
 <c69163e9ed5048407cc84f439cbfecc53f6f7131.1273484095.git.marcel@holtmann.org>
 <faaebd192ec9c3febcab98149d1309199a5b886c.1273484095.git.marcel@holtmann.org>
 <7dffe4210233a2860c3f41477c40b3252edf2b7d.1273484095.git.marcel@holtmann.org>
 <d1daa091e8612f3aab14d28b5836375fafe155e1.1273484096.git.marcel@holtmann.org>
 <e8235c6bdd1c7ffbaa7eb8dcdbb46c51f1e5d72e.1273484096.git.marcel@holtmann.org>
 <d5392c8f1e9faef089bb7cb66c3314da8bddd1fe.1273484096.git.marcel@holtmann.org>
 <1d8f5d16913d74e428950ee02fe9ff7e6391c120.1273484096.git.marcel@holtmann.org>
 <277ffbe362823d18a17792fbd8e507010e666299.1273484096.git.marcel@holtmann.org>
 <36f2fd585f43199f006a3b5ff84e95815102cd31.1273484096.git.marcel@holtmann.org>
 <9e917af13d59182f95bbb5483dc0c4254dfb7944.1273484096.git.marcel@holtmann.org>
 <f0946ccfc7da403a46b7ff7cb2e3deffac108742.1273484096.git.marcel@holtmann.org>
 <73edaa9933219e25d6733b78d1e2c881025705e2.1273484096.git.marcel@holtmann.org>
 <e072745f4adb01b909bd08a0cfc8f79348f4d2c6.1273484096.git.marcel@holtmann.org>
 <99b0d4b7b09edeacf4542bced5c01239375b51a9.1273484096.git.marcel@holtmann.org>
 <6e3a59819fac19006fe4255b87928e5a12c54532.1273484096.git.marcel@holtmann.org>
 <8abb52ee00c4b3f857269eb6b7145991bab869bf.1273484096.git.marcel@holtmann.org>
 <05fbd89dd4153341717b33d9e8ae8bd29db6c1c8.1273484096.git.marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53431 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755765Ab0EJJix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 05:38:53 -0400
In-Reply-To: <05fbd89dd4153341717b33d9e8ae8bd29db6c1c8.1273484096.git.marcel@holtmann.org>
In-Reply-To: <cover.1273484094.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Gustavo F. Padovan <padovan@profusion.mobi>

We ack I-frames on each txWindow/5 I-frames received, but if the sender
stop to send I-frames and it's not a txWindow multiple we can leave som=
e
frames unacked.
So I added a timer to ack I-frames on this case. The timer expires in
200ms.

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Reviewed-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 include/net/bluetooth/l2cap.h |    4 ++++
 net/bluetooth/l2cap.c         |   15 +++++++++++++++
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/include/net/bluetooth/l2cap.h b/include/net/bluetooth/l2ca=
p.h
index d9c20c3..48f10f4 100644
--- a/include/net/bluetooth/l2cap.h
+++ b/include/net/bluetooth/l2cap.h
@@ -35,6 +35,7 @@
 #define L2CAP_DEFAULT_RETRANS_TO	1000    /* 1 second */
 #define L2CAP_DEFAULT_MONITOR_TO	12000   /* 12 seconds */
 #define L2CAP_DEFAULT_MAX_PDU_SIZE	672
+#define L2CAP_DEFAULT_ACK_TO		200
=20
 #define L2CAP_CONN_TIMEOUT	(40000) /* 40 seconds */
 #define L2CAP_INFO_TIMEOUT	(4000)  /*  4 seconds */
@@ -348,6 +349,7 @@ struct l2cap_pinfo {
=20
 	struct timer_list	retrans_timer;
 	struct timer_list	monitor_timer;
+	struct timer_list	ack_timer;
 	struct sk_buff_head	tx_queue;
 	struct sk_buff_head	srej_queue;
 	struct srej_list	srej_l;
@@ -382,6 +384,8 @@ struct l2cap_pinfo {
 		jiffies +  msecs_to_jiffies(L2CAP_DEFAULT_RETRANS_TO));
 #define __mod_monitor_timer() mod_timer(&l2cap_pi(sk)->monitor_timer, =
\
 		jiffies + msecs_to_jiffies(L2CAP_DEFAULT_MONITOR_TO));
+#define __mod_ack_timer() mod_timer(&l2cap_pi(sk)->ack_timer, \
+		jiffies + msecs_to_jiffies(L2CAP_DEFAULT_ACK_TO));
=20
 static inline int l2cap_tx_window_full(struct sock *sk)
 {
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index f386985..0300656 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -2235,6 +2235,15 @@ static void l2cap_add_conf_opt(void **ptr, u8 ty=
pe, u8 len, unsigned long val)
 	*ptr +=3D L2CAP_CONF_OPT_SIZE + len;
 }
=20
+static void l2cap_ack_timeout(unsigned long arg)
+{
+	struct sock *sk =3D (void *) arg;
+
+	bh_lock_sock(sk);
+	l2cap_send_ack(l2cap_pi(sk));
+	bh_unlock_sock(sk);
+}
+
 static inline void l2cap_ertm_init(struct sock *sk)
 {
 	l2cap_pi(sk)->expected_ack_seq =3D 0;
@@ -2247,6 +2256,8 @@ static inline void l2cap_ertm_init(struct sock *s=
k)
 			l2cap_retrans_timeout, (unsigned long) sk);
 	setup_timer(&l2cap_pi(sk)->monitor_timer,
 			l2cap_monitor_timeout, (unsigned long) sk);
+	setup_timer(&l2cap_pi(sk)->ack_timer,
+			l2cap_ack_timeout, (unsigned long) sk);
=20
 	__skb_queue_head_init(SREJ_QUEUE(sk));
 }
@@ -2975,6 +2986,7 @@ static inline int l2cap_disconnect_req(struct l2c=
ap_conn *conn, struct l2cap_cmd
 		skb_queue_purge(SREJ_QUEUE(sk));
 		del_timer(&l2cap_pi(sk)->retrans_timer);
 		del_timer(&l2cap_pi(sk)->monitor_timer);
+		del_timer(&l2cap_pi(sk)->ack_timer);
 	}
=20
 	l2cap_chan_del(sk, ECONNRESET);
@@ -3005,6 +3017,7 @@ static inline int l2cap_disconnect_rsp(struct l2c=
ap_conn *conn, struct l2cap_cmd
 		skb_queue_purge(SREJ_QUEUE(sk));
 		del_timer(&l2cap_pi(sk)->retrans_timer);
 		del_timer(&l2cap_pi(sk)->monitor_timer);
+		del_timer(&l2cap_pi(sk)->ack_timer);
 	}
=20
 	l2cap_chan_del(sk, 0);
@@ -3484,6 +3497,8 @@ expected:
 	if (err < 0)
 		return err;
=20
+	__mod_ack_timer();
+
 	pi->num_to_ack =3D (pi->num_to_ack + 1) % L2CAP_DEFAULT_NUM_TO_ACK;
 	if (pi->num_to_ack =3D=3D L2CAP_DEFAULT_NUM_TO_ACK - 1)
 		l2cap_send_ack(pi);
--=20
1.6.6.1

