From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Fix use after free by removing length arg from
 sk_data_ready callbacks.
Date: Fri, 11 Apr 2014 16:17:36 -0400 (EDT)
Message-ID: <20140411.161736.1142544015854500929.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, dborkman@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58873 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755008AbaDKURj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 16:17:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Several spots in the kernel perform a sequence like:

	skb_queue_tail(&sk->s_receive_queue, skb);
	sk->sk_data_ready(sk, skb->len);

But at the moment we place the SKB onto the socket receive queue it
can be consumed and freed up.  So this skb->len access is potentially
to freed up memory.

Furthermore, the skb->len can be modified by the consumer so it is
possible that the value isn't accurate.

And finally, no actual implementation of this callback actually uses
the length argument.  And since nobody actually cared about it's
value, lots of call sites pass arbitrary values in such as '0' and
even '1'.

So just remove the length argument from the callback, that way there
is no confusion whatsoever and all of these use-after-free cases get
fixed as a side effect.

Based upon a patch by Eric Dumazet and his suggestion to audit this
issue tree-wide.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/scsi/iscsi_tcp.c                                  |  2 +-
 drivers/scsi/iscsi_tcp.h                                  |  2 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd_lib-linux.c |  4 ++--
 drivers/target/iscsi/iscsi_target_core.h                  |  2 +-
 drivers/target/iscsi/iscsi_target_nego.c                  |  2 +-
 fs/dlm/lowcomms.c                                         |  2 +-
 fs/ncpfs/ncp_fs_sb.h                                      |  4 ++--
 fs/ncpfs/sock.c                                           |  4 ++--
 fs/ocfs2/cluster/tcp.c                                    | 15 +++++++--------
 fs/ocfs2/cluster/tcp_internal.h                           |  2 +-
 include/linux/sunrpc/svcsock.h                            |  2 +-
 include/net/sctp/sctp.h                                   |  2 +-
 include/net/sock.h                                        |  2 +-
 net/atm/clip.c                                            |  2 +-
 net/atm/lec.c                                             | 10 +++++-----
 net/atm/mpc.c                                             |  6 +++---
 net/atm/raw.c                                             |  2 +-
 net/atm/signaling.c                                       |  2 +-
 net/ax25/ax25_in.c                                        |  2 +-
 net/bluetooth/l2cap_sock.c                                |  6 +++---
 net/bluetooth/rfcomm/core.c                               |  4 ++--
 net/bluetooth/rfcomm/sock.c                               |  4 ++--
 net/bluetooth/sco.c                                       |  2 +-
 net/caif/caif_socket.c                                    |  4 +---
 net/ceph/messenger.c                                      |  2 +-
 net/core/skbuff.c                                         |  4 +---
 net/core/sock.c                                           |  4 ++--
 net/dccp/input.c                                          |  2 +-
 net/dccp/minisocks.c                                      |  2 +-
 net/decnet/dn_nsp_in.c                                    |  4 +---
 net/ipv4/tcp_input.c                                      | 10 +++++-----
 net/ipv4/tcp_ipv4.c                                       |  2 +-
 net/ipv4/tcp_minisocks.c                                  |  2 +-
 net/iucv/af_iucv.c                                        |  4 ++--
 net/key/af_key.c                                          |  2 +-
 net/netlink/af_netlink.c                                  |  4 ++--
 net/netrom/af_netrom.c                                    |  2 +-
 net/nfc/llcp_core.c                                       |  2 +-
 net/packet/af_packet.c                                    |  6 +++---
 net/phonet/pep-gprs.c                                     |  4 ++--
 net/phonet/pep.c                                          |  8 +++-----
 net/rds/tcp.h                                             |  4 ++--
 net/rds/tcp_listen.c                                      |  6 +++---
 net/rds/tcp_recv.c                                        |  8 ++++----
 net/rose/af_rose.c                                        |  2 +-
 net/rxrpc/ar-input.c                                      |  6 +++---
 net/rxrpc/ar-internal.h                                   |  2 +-
 net/sctp/socket.c                                         |  2 +-
 net/sctp/ulpqueue.c                                       |  4 ++--
 net/sunrpc/svcsock.c                                      | 12 ++++++------
 net/sunrpc/xprtsock.c                                     |  8 ++++----
 net/tipc/server.c                                         |  4 ++--
 net/tipc/socket.c                                         |  6 +++---
 net/unix/af_unix.c                                        |  6 +++---
 net/vmw_vsock/vmci_transport_notify.c                     |  2 +-
 net/vmw_vsock/vmci_transport_notify_qstate.c              |  4 ++--
 net/x25/af_x25.c                                          |  2 +-
 net/x25/x25_in.c                                          |  2 +-
 58 files changed, 112 insertions(+), 121 deletions(-)

diff --git a/drivers/scsi/iscsi_tcp.c b/drivers/scsi/iscsi_tcp.c
index bfb6d07..1185484 100644
--- a/drivers/scsi/iscsi_tcp.c
+++ b/drivers/scsi/iscsi_tcp.c
@@ -125,7 +125,7 @@ static inline int iscsi_sw_sk_state_check(struct sock *sk)
 	return 0;
 }
 
-static void iscsi_sw_tcp_data_ready(struct sock *sk, int flag)
+static void iscsi_sw_tcp_data_ready(struct sock *sk)
 {
 	struct iscsi_conn *conn;
 	struct iscsi_tcp_conn *tcp_conn;
diff --git a/drivers/scsi/iscsi_tcp.h b/drivers/scsi/iscsi_tcp.h
index 666fe09..f42ecb23 100644
--- a/drivers/scsi/iscsi_tcp.h
+++ b/drivers/scsi/iscsi_tcp.h
@@ -40,7 +40,7 @@ struct iscsi_sw_tcp_conn {
 
 	struct iscsi_sw_tcp_send out;
 	/* old values for socket callbacks */
-	void			(*old_data_ready)(struct sock *, int);
+	void			(*old_data_ready)(struct sock *);
 	void			(*old_state_change)(struct sock *);
 	void			(*old_write_space)(struct sock *);
 
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib-linux.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib-linux.c
index a54b506..a9b5898 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib-linux.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib-linux.c
@@ -655,7 +655,7 @@ extern void ksocknal_write_callback (ksock_conn_t *conn);
  * socket call back in Linux
  */
 static void
-ksocknal_data_ready (struct sock *sk, int n)
+ksocknal_data_ready (struct sock *sk)
 {
 	ksock_conn_t  *conn;
 
@@ -666,7 +666,7 @@ ksocknal_data_ready (struct sock *sk, int n)
 	conn = sk->sk_user_data;
 	if (conn == NULL) {	     /* raced with ksocknal_terminate_conn */
 		LASSERT (sk->sk_data_ready != &ksocknal_data_ready);
-		sk->sk_data_ready (sk, n);
+		sk->sk_data_ready (sk);
 	} else
 		ksocknal_read_callback(conn);
 
diff --git a/drivers/target/iscsi/iscsi_target_core.h b/drivers/target/iscsi/iscsi_target_core.h
index 48f7b3b..f452398 100644
--- a/drivers/target/iscsi/iscsi_target_core.h
+++ b/drivers/target/iscsi/iscsi_target_core.h
@@ -556,7 +556,7 @@ struct iscsi_conn {
 	struct completion	rx_half_close_comp;
 	/* socket used by this connection */
 	struct socket		*sock;
-	void			(*orig_data_ready)(struct sock *, int);
+	void			(*orig_data_ready)(struct sock *);
 	void			(*orig_state_change)(struct sock *);
 #define LOGIN_FLAGS_READ_ACTIVE		1
 #define LOGIN_FLAGS_CLOSED		2
diff --git a/drivers/target/iscsi/iscsi_target_nego.c b/drivers/target/iscsi/iscsi_target_nego.c
index 582ba84..75b6859 100644
--- a/drivers/target/iscsi/iscsi_target_nego.c
+++ b/drivers/target/iscsi/iscsi_target_nego.c
@@ -375,7 +375,7 @@ static int iscsi_target_do_tx_login_io(struct iscsi_conn *conn, struct iscsi_log
 	return 0;
 }
 
-static void iscsi_target_sk_data_ready(struct sock *sk, int count)
+static void iscsi_target_sk_data_ready(struct sock *sk)
 {
 	struct iscsi_conn *conn = sk->sk_user_data;
 	bool rc;
diff --git a/fs/dlm/lowcomms.c b/fs/dlm/lowcomms.c
index 3190ca9..1e5b453 100644
--- a/fs/dlm/lowcomms.c
+++ b/fs/dlm/lowcomms.c
@@ -424,7 +424,7 @@ int dlm_lowcomms_addr(int nodeid, struct sockaddr_storage *addr, int len)
 }
 
 /* Data available on socket or listen socket received a connect */
-static void lowcomms_data_ready(struct sock *sk, int count_unused)
+static void lowcomms_data_ready(struct sock *sk)
 {
 	struct connection *con = sock2con(sk);
 	if (con && !test_and_set_bit(CF_READ_PENDING, &con->flags))
diff --git a/fs/ncpfs/ncp_fs_sb.h b/fs/ncpfs/ncp_fs_sb.h
index b81e97a..fbb0881 100644
--- a/fs/ncpfs/ncp_fs_sb.h
+++ b/fs/ncpfs/ncp_fs_sb.h
@@ -111,7 +111,7 @@ struct ncp_server {
 
 	spinlock_t requests_lock;	/* Lock accesses to tx.requests, tx.creq and rcv.creq when STREAM mode */
 
-	void (*data_ready)(struct sock* sk, int len);
+	void (*data_ready)(struct sock* sk);
 	void (*error_report)(struct sock* sk);
 	void (*write_space)(struct sock* sk);	/* STREAM mode only */
 	struct {
@@ -153,7 +153,7 @@ extern void ncp_tcp_tx_proc(struct work_struct *work);
 extern void ncpdgram_rcv_proc(struct work_struct *work);
 extern void ncpdgram_timeout_proc(struct work_struct *work);
 extern void ncpdgram_timeout_call(unsigned long server);
-extern void ncp_tcp_data_ready(struct sock* sk, int len);
+extern void ncp_tcp_data_ready(struct sock* sk);
 extern void ncp_tcp_write_space(struct sock* sk);
 extern void ncp_tcp_error_report(struct sock* sk);
 
diff --git a/fs/ncpfs/sock.c b/fs/ncpfs/sock.c
index 3a15872..652da0d 100644
--- a/fs/ncpfs/sock.c
+++ b/fs/ncpfs/sock.c
@@ -96,11 +96,11 @@ static void ncp_req_put(struct ncp_request_reply *req)
 		kfree(req);
 }
 
-void ncp_tcp_data_ready(struct sock *sk, int len)
+void ncp_tcp_data_ready(struct sock *sk)
 {
 	struct ncp_server *server = sk->sk_user_data;
 
-	server->data_ready(sk, len);
+	server->data_ready(sk);
 	schedule_work(&server->rcv.tq);
 }
 
diff --git a/fs/ocfs2/cluster/tcp.c b/fs/ocfs2/cluster/tcp.c
index eb649d2..d857534 100644
--- a/fs/ocfs2/cluster/tcp.c
+++ b/fs/ocfs2/cluster/tcp.c
@@ -137,7 +137,7 @@ static int o2net_sys_err_translations[O2NET_ERR_MAX] =
 static void o2net_sc_connect_completed(struct work_struct *work);
 static void o2net_rx_until_empty(struct work_struct *work);
 static void o2net_shutdown_sc(struct work_struct *work);
-static void o2net_listen_data_ready(struct sock *sk, int bytes);
+static void o2net_listen_data_ready(struct sock *sk);
 static void o2net_sc_send_keep_req(struct work_struct *work);
 static void o2net_idle_timer(unsigned long data);
 static void o2net_sc_postpone_idle(struct o2net_sock_container *sc);
@@ -597,9 +597,9 @@ static void o2net_set_nn_state(struct o2net_node *nn,
 }
 
 /* see o2net_register_callbacks() */
-static void o2net_data_ready(struct sock *sk, int bytes)
+static void o2net_data_ready(struct sock *sk)
 {
-	void (*ready)(struct sock *sk, int bytes);
+	void (*ready)(struct sock *sk);
 
 	read_lock(&sk->sk_callback_lock);
 	if (sk->sk_user_data) {
@@ -613,7 +613,7 @@ static void o2net_data_ready(struct sock *sk, int bytes)
 	}
 	read_unlock(&sk->sk_callback_lock);
 
-	ready(sk, bytes);
+	ready(sk);
 }
 
 /* see o2net_register_callbacks() */
@@ -1953,9 +1953,9 @@ static void o2net_accept_many(struct work_struct *work)
 		cond_resched();
 }
 
-static void o2net_listen_data_ready(struct sock *sk, int bytes)
+static void o2net_listen_data_ready(struct sock *sk)
 {
-	void (*ready)(struct sock *sk, int bytes);
+	void (*ready)(struct sock *sk);
 
 	read_lock(&sk->sk_callback_lock);
 	ready = sk->sk_user_data;
@@ -1978,7 +1978,6 @@ static void o2net_listen_data_ready(struct sock *sk, int bytes)
 	 */
 
 	if (sk->sk_state == TCP_LISTEN) {
-		mlog(ML_TCP, "bytes: %d\n", bytes);
 		queue_work(o2net_wq, &o2net_listen_work);
 	} else {
 		ready = NULL;
@@ -1987,7 +1986,7 @@ static void o2net_listen_data_ready(struct sock *sk, int bytes)
 out:
 	read_unlock(&sk->sk_callback_lock);
 	if (ready != NULL)
-		ready(sk, bytes);
+		ready(sk);
 }
 
 static int o2net_open_listening_sock(__be32 addr, __be16 port)
diff --git a/fs/ocfs2/cluster/tcp_internal.h b/fs/ocfs2/cluster/tcp_internal.h
index 4cbcb65..dc02436 100644
--- a/fs/ocfs2/cluster/tcp_internal.h
+++ b/fs/ocfs2/cluster/tcp_internal.h
@@ -165,7 +165,7 @@ struct o2net_sock_container {
 
 	/* original handlers for the sockets */
 	void			(*sc_state_change)(struct sock *sk);
-	void			(*sc_data_ready)(struct sock *sk, int bytes);
+	void			(*sc_data_ready)(struct sock *sk);
 
 	u32			sc_msg_key;
 	u16			sc_msg_type;
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 62fd1b7..88f7e1a 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -22,7 +22,7 @@ struct svc_sock {
 
 	/* We keep the old state_change and data_ready CB's here */
 	void			(*sk_ostate)(struct sock *);
-	void			(*sk_odata)(struct sock *, int bytes);
+	void			(*sk_odata)(struct sock *);
 	void			(*sk_owspace)(struct sock *);
 
 	/* private TCP part */
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index a3353f4..8e4de46 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -101,7 +101,7 @@ void sctp_addr_wq_mgmt(struct net *, struct sctp_sockaddr_entry *, int);
 int sctp_backlog_rcv(struct sock *sk, struct sk_buff *skb);
 int sctp_inet_listen(struct socket *sock, int backlog);
 void sctp_write_space(struct sock *sk);
-void sctp_data_ready(struct sock *sk, int len);
+void sctp_data_ready(struct sock *sk);
 unsigned int sctp_poll(struct file *file, struct socket *sock,
 		poll_table *wait);
 void sctp_sock_rfree(struct sk_buff *skb);
diff --git a/include/net/sock.h b/include/net/sock.h
index 06a5668..8338a14 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -418,7 +418,7 @@ struct sock {
 	u32			sk_classid;
 	struct cg_proto		*sk_cgrp;
 	void			(*sk_state_change)(struct sock *sk);
-	void			(*sk_data_ready)(struct sock *sk, int bytes);
+	void			(*sk_data_ready)(struct sock *sk);
 	void			(*sk_write_space)(struct sock *sk);
 	void			(*sk_error_report)(struct sock *sk);
 	int			(*sk_backlog_rcv)(struct sock *sk,
diff --git a/net/atm/clip.c b/net/atm/clip.c
index 8215f7c..ba291ce 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -68,7 +68,7 @@ static int to_atmarpd(enum atmarp_ctrl_type type, int itf, __be32 ip)
 
 	sk = sk_atm(atmarpd);
 	skb_queue_tail(&sk->sk_receive_queue, skb);
-	sk->sk_data_ready(sk, skb->len);
+	sk->sk_data_ready(sk);
 	return 0;
 }
 
diff --git a/net/atm/lec.c b/net/atm/lec.c
index 5a2f602..4c5b8ba 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -152,7 +152,7 @@ static void lec_handle_bridge(struct sk_buff *skb, struct net_device *dev)
 		atm_force_charge(priv->lecd, skb2->truesize);
 		sk = sk_atm(priv->lecd);
 		skb_queue_tail(&sk->sk_receive_queue, skb2);
-		sk->sk_data_ready(sk, skb2->len);
+		sk->sk_data_ready(sk);
 	}
 }
 #endif /* defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE) */
@@ -447,7 +447,7 @@ static int lec_atm_send(struct atm_vcc *vcc, struct sk_buff *skb)
 			atm_force_charge(priv->lecd, skb2->truesize);
 			sk = sk_atm(priv->lecd);
 			skb_queue_tail(&sk->sk_receive_queue, skb2);
-			sk->sk_data_ready(sk, skb2->len);
+			sk->sk_data_ready(sk);
 		}
 	}
 #endif /* defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE) */
@@ -530,13 +530,13 @@ send_to_lecd(struct lec_priv *priv, atmlec_msg_type type,
 	atm_force_charge(priv->lecd, skb->truesize);
 	sk = sk_atm(priv->lecd);
 	skb_queue_tail(&sk->sk_receive_queue, skb);
-	sk->sk_data_ready(sk, skb->len);
+	sk->sk_data_ready(sk);
 
 	if (data != NULL) {
 		pr_debug("about to send %d bytes of data\n", data->len);
 		atm_force_charge(priv->lecd, data->truesize);
 		skb_queue_tail(&sk->sk_receive_queue, data);
-		sk->sk_data_ready(sk, skb->len);
+		sk->sk_data_ready(sk);
 	}
 
 	return 0;
@@ -616,7 +616,7 @@ static void lec_push(struct atm_vcc *vcc, struct sk_buff *skb)
 
 		pr_debug("%s: To daemon\n", dev->name);
 		skb_queue_tail(&sk->sk_receive_queue, skb);
-		sk->sk_data_ready(sk, skb->len);
+		sk->sk_data_ready(sk);
 	} else {		/* Data frame, queue to protocol handlers */
 		struct lec_arp_table *entry;
 		unsigned char *src, *dst;
diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index 91dc58f..e8e0e7a 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -706,7 +706,7 @@ static void mpc_push(struct atm_vcc *vcc, struct sk_buff *skb)
 		dprintk("(%s) control packet arrived\n", dev->name);
 		/* Pass control packets to daemon */
 		skb_queue_tail(&sk->sk_receive_queue, skb);
-		sk->sk_data_ready(sk, skb->len);
+		sk->sk_data_ready(sk);
 		return;
 	}
 
@@ -992,7 +992,7 @@ int msg_to_mpoad(struct k_message *mesg, struct mpoa_client *mpc)
 
 	sk = sk_atm(mpc->mpoad_vcc);
 	skb_queue_tail(&sk->sk_receive_queue, skb);
-	sk->sk_data_ready(sk, skb->len);
+	sk->sk_data_ready(sk);
 
 	return 0;
 }
@@ -1273,7 +1273,7 @@ static void purge_egress_shortcut(struct atm_vcc *vcc, eg_cache_entry *entry)
 
 	sk = sk_atm(vcc);
 	skb_queue_tail(&sk->sk_receive_queue, skb);
-	sk->sk_data_ready(sk, skb->len);
+	sk->sk_data_ready(sk);
 	dprintk("exiting\n");
 }
 
diff --git a/net/atm/raw.c b/net/atm/raw.c
index b4f7b9f..2e17e97 100644
--- a/net/atm/raw.c
+++ b/net/atm/raw.c
@@ -25,7 +25,7 @@ static void atm_push_raw(struct atm_vcc *vcc, struct sk_buff *skb)
 		struct sock *sk = sk_atm(vcc);
 
 		skb_queue_tail(&sk->sk_receive_queue, skb);
-		sk->sk_data_ready(sk, skb->len);
+		sk->sk_data_ready(sk);
 	}
 }
 
diff --git a/net/atm/signaling.c b/net/atm/signaling.c
index 4176887..523bce7 100644
--- a/net/atm/signaling.c
+++ b/net/atm/signaling.c
@@ -51,7 +51,7 @@ static void sigd_put_skb(struct sk_buff *skb)
 #endif
 	atm_force_charge(sigd, skb->truesize);
 	skb_queue_tail(&sk_atm(sigd)->sk_receive_queue, skb);
-	sk_atm(sigd)->sk_data_ready(sk_atm(sigd), skb->len);
+	sk_atm(sigd)->sk_data_ready(sk_atm(sigd));
 }
 
 static void modify_qos(struct atm_vcc *vcc, struct atmsvc_msg *msg)
diff --git a/net/ax25/ax25_in.c b/net/ax25/ax25_in.c
index 96f4cab3..7ed8ab7 100644
--- a/net/ax25/ax25_in.c
+++ b/net/ax25/ax25_in.c
@@ -422,7 +422,7 @@ static int ax25_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	if (sk) {
 		if (!sock_flag(sk, SOCK_DEAD))
-			sk->sk_data_ready(sk, skb->len);
+			sk->sk_data_ready(sk);
 		sock_put(sk);
 	} else {
 free:
diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index f59e00c..ef5e5b0 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -1271,7 +1271,7 @@ static void l2cap_sock_teardown_cb(struct l2cap_chan *chan, int err)
 
 		if (parent) {
 			bt_accept_unlink(sk);
-			parent->sk_data_ready(parent, 0);
+			parent->sk_data_ready(parent);
 		} else {
 			sk->sk_state_change(sk);
 		}
@@ -1327,7 +1327,7 @@ static void l2cap_sock_ready_cb(struct l2cap_chan *chan)
 	sk->sk_state_change(sk);
 
 	if (parent)
-		parent->sk_data_ready(parent, 0);
+		parent->sk_data_ready(parent);
 
 	release_sock(sk);
 }
@@ -1340,7 +1340,7 @@ static void l2cap_sock_defer_cb(struct l2cap_chan *chan)
 
 	parent = bt_sk(sk)->parent;
 	if (parent)
-		parent->sk_data_ready(parent, 0);
+		parent->sk_data_ready(parent);
 
 	release_sock(sk);
 }
diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index 633ccee..cf62026 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -186,9 +186,9 @@ static void rfcomm_l2state_change(struct sock *sk)
 	rfcomm_schedule();
 }
 
-static void rfcomm_l2data_ready(struct sock *sk, int bytes)
+static void rfcomm_l2data_ready(struct sock *sk)
 {
-	BT_DBG("%p bytes %d", sk, bytes);
+	BT_DBG("%p", sk);
 	rfcomm_schedule();
 }
 
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index eabd25a..c603a5e 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -54,7 +54,7 @@ static void rfcomm_sk_data_ready(struct rfcomm_dlc *d, struct sk_buff *skb)
 
 	atomic_add(skb->len, &sk->sk_rmem_alloc);
 	skb_queue_tail(&sk->sk_receive_queue, skb);
-	sk->sk_data_ready(sk, skb->len);
+	sk->sk_data_ready(sk);
 
 	if (atomic_read(&sk->sk_rmem_alloc) >= sk->sk_rcvbuf)
 		rfcomm_dlc_throttle(d);
@@ -84,7 +84,7 @@ static void rfcomm_sk_state_change(struct rfcomm_dlc *d, int err)
 			sock_set_flag(sk, SOCK_ZAPPED);
 			bt_accept_unlink(sk);
 		}
-		parent->sk_data_ready(parent, 0);
+		parent->sk_data_ready(parent);
 	} else {
 		if (d->state == BT_CONNECTED)
 			rfcomm_session_getaddr(d->session,
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index ab1e6fc..c06dbd3 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -1024,7 +1024,7 @@ static void sco_conn_ready(struct sco_conn *conn)
 			sk->sk_state = BT_CONNECTED;
 
 		/* Wake up parent */
-		parent->sk_data_ready(parent, 1);
+		parent->sk_data_ready(parent);
 
 		bh_unlock_sock(parent);
 
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index d6be3ed..e843709 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -124,7 +124,6 @@ static void caif_flow_ctrl(struct sock *sk, int mode)
 static int caif_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	int err;
-	int skb_len;
 	unsigned long flags;
 	struct sk_buff_head *list = &sk->sk_receive_queue;
 	struct caifsock *cf_sk = container_of(sk, struct caifsock, sk);
@@ -153,14 +152,13 @@ static int caif_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	 * may be freed by other threads of control pulling packets
 	 * from the queue.
 	 */
-	skb_len = skb->len;
 	spin_lock_irqsave(&list->lock, flags);
 	if (!sock_flag(sk, SOCK_DEAD))
 		__skb_queue_tail(list, skb);
 	spin_unlock_irqrestore(&list->lock, flags);
 
 	if (!sock_flag(sk, SOCK_DEAD))
-		sk->sk_data_ready(sk, skb_len);
+		sk->sk_data_ready(sk);
 	else
 		kfree_skb(skb);
 	return 0;
diff --git a/net/ceph/messenger.c b/net/ceph/messenger.c
index 4f55f9c..dac7f9b 100644
--- a/net/ceph/messenger.c
+++ b/net/ceph/messenger.c
@@ -383,7 +383,7 @@ static void con_sock_state_closed(struct ceph_connection *con)
  */
 
 /* data available on socket, or listen socket received a connect */
-static void ceph_sock_data_ready(struct sock *sk, int count_unused)
+static void ceph_sock_data_ready(struct sock *sk)
 {
 	struct ceph_connection *con = sk->sk_user_data;
 	if (atomic_read(&con->msgr->stopping)) {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 57e225c..1b62343 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3458,8 +3458,6 @@ static void sock_rmem_free(struct sk_buff *skb)
  */
 int sock_queue_err_skb(struct sock *sk, struct sk_buff *skb)
 {
-	int len = skb->len;
-
 	if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=
 	    (unsigned int)sk->sk_rcvbuf)
 		return -ENOMEM;
@@ -3474,7 +3472,7 @@ int sock_queue_err_skb(struct sock *sk, struct sk_buff *skb)
 
 	skb_queue_tail(&sk->sk_error_queue, skb);
 	if (!sock_flag(sk, SOCK_DEAD))
-		sk->sk_data_ready(sk, len);
+		sk->sk_data_ready(sk);
 	return 0;
 }
 EXPORT_SYMBOL(sock_queue_err_skb);
diff --git a/net/core/sock.c b/net/core/sock.c
index c0fc6bd..b4fff00 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -428,7 +428,7 @@ int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	spin_unlock_irqrestore(&list->lock, flags);
 
 	if (!sock_flag(sk, SOCK_DEAD))
-		sk->sk_data_ready(sk, skb_len);
+		sk->sk_data_ready(sk);
 	return 0;
 }
 EXPORT_SYMBOL(sock_queue_rcv_skb);
@@ -2196,7 +2196,7 @@ static void sock_def_error_report(struct sock *sk)
 	rcu_read_unlock();
 }
 
-static void sock_def_readable(struct sock *sk, int len)
+static void sock_def_readable(struct sock *sk)
 {
 	struct socket_wq *wq;
 
diff --git a/net/dccp/input.c b/net/dccp/input.c
index 14cdafa..3c8ec7d 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -28,7 +28,7 @@ static void dccp_enqueue_skb(struct sock *sk, struct sk_buff *skb)
 	__skb_pull(skb, dccp_hdr(skb)->dccph_doff * 4);
 	__skb_queue_tail(&sk->sk_receive_queue, skb);
 	skb_set_owner_r(skb, sk);
-	sk->sk_data_ready(sk, 0);
+	sk->sk_data_ready(sk);
 }
 
 static void dccp_fin(struct sock *sk, struct sk_buff *skb)
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 9e2f78b..c69eb9c 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -237,7 +237,7 @@ int dccp_child_process(struct sock *parent, struct sock *child,
 
 		/* Wakeup parent, send SIGIO */
 		if (state == DCCP_RESPOND && child->sk_state != state)
-			parent->sk_data_ready(parent, 0);
+			parent->sk_data_ready(parent);
 	} else {
 		/* Alas, it is possible again, because we do lookup
 		 * in main socket hash table and lock on listening
diff --git a/net/decnet/dn_nsp_in.c b/net/decnet/dn_nsp_in.c
index c344163..fe5f014 100644
--- a/net/decnet/dn_nsp_in.c
+++ b/net/decnet/dn_nsp_in.c
@@ -585,7 +585,6 @@ out:
 static __inline__ int dn_queue_skb(struct sock *sk, struct sk_buff *skb, int sig, struct sk_buff_head *queue)
 {
 	int err;
-	int skb_len;
 
 	/* Cast skb->rcvbuf to unsigned... It's pointless, but reduces
 	   number of warnings when compiling with -W --ANK
@@ -600,12 +599,11 @@ static __inline__ int dn_queue_skb(struct sock *sk, struct sk_buff *skb, int sig
 	if (err)
 		goto out;
 
-	skb_len = skb->len;
 	skb_set_owner_r(skb, sk);
 	skb_queue_tail(queue, skb);
 
 	if (!sock_flag(sk, SOCK_DEAD))
-		sk->sk_data_ready(sk, skb_len);
+		sk->sk_data_ready(sk);
 out:
 	return err;
 }
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index e1661f4..d6b46eb 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4413,7 +4413,7 @@ queue_and_out:
 		if (eaten > 0)
 			kfree_skb_partial(skb, fragstolen);
 		if (!sock_flag(sk, SOCK_DEAD))
-			sk->sk_data_ready(sk, 0);
+			sk->sk_data_ready(sk);
 		return;
 	}
 
@@ -4914,7 +4914,7 @@ static void tcp_urg(struct sock *sk, struct sk_buff *skb, const struct tcphdr *t
 				BUG();
 			tp->urg_data = TCP_URG_VALID | tmp;
 			if (!sock_flag(sk, SOCK_DEAD))
-				sk->sk_data_ready(sk, 0);
+				sk->sk_data_ready(sk);
 		}
 	}
 }
@@ -5000,11 +5000,11 @@ static bool tcp_dma_try_early_copy(struct sock *sk, struct sk_buff *skb,
 		    (tcp_flag_word(tcp_hdr(skb)) & TCP_FLAG_PSH) ||
 		    (atomic_read(&sk->sk_rmem_alloc) > (sk->sk_rcvbuf >> 1))) {
 			tp->ucopy.wakeup = 1;
-			sk->sk_data_ready(sk, 0);
+			sk->sk_data_ready(sk);
 		}
 	} else if (chunk > 0) {
 		tp->ucopy.wakeup = 1;
-		sk->sk_data_ready(sk, 0);
+		sk->sk_data_ready(sk);
 	}
 out:
 	return copied_early;
@@ -5275,7 +5275,7 @@ no_ack:
 #endif
 			if (eaten)
 				kfree_skb_partial(skb, fragstolen);
-			sk->sk_data_ready(sk, 0);
+			sk->sk_data_ready(sk);
 			return;
 		}
 	}
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 6379894..438f3b9 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1434,7 +1434,7 @@ static int tcp_v4_conn_req_fastopen(struct sock *sk,
 		tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
 		tp->syn_data_acked = 1;
 	}
-	sk->sk_data_ready(sk, 0);
+	sk->sk_data_ready(sk);
 	bh_unlock_sock(child);
 	sock_put(child);
 	WARN_ON(req->sk == NULL);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index ca788ad..05c1b15 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -745,7 +745,7 @@ int tcp_child_process(struct sock *parent, struct sock *child,
 					    skb->len);
 		/* Wakeup parent, send SIGIO */
 		if (state == TCP_SYN_RECV && child->sk_state != state)
-			parent->sk_data_ready(parent, 0);
+			parent->sk_data_ready(parent);
 	} else {
 		/* Alas, it is possible again, because we do lookup
 		 * in main socket hash table and lock on listening
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index a5e0311..01e77b0 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1757,7 +1757,7 @@ static int iucv_callback_connreq(struct iucv_path *path,
 
 	/* Wake up accept */
 	nsk->sk_state = IUCV_CONNECTED;
-	sk->sk_data_ready(sk, 1);
+	sk->sk_data_ready(sk);
 	err = 0;
 fail:
 	bh_unlock_sock(sk);
@@ -1968,7 +1968,7 @@ static int afiucv_hs_callback_syn(struct sock *sk, struct sk_buff *skb)
 	if (!err) {
 		iucv_accept_enqueue(sk, nsk);
 		nsk->sk_state = IUCV_CONNECTED;
-		sk->sk_data_ready(sk, 1);
+		sk->sk_data_ready(sk);
 	} else
 		iucv_sock_kill(nsk);
 	bh_unlock_sock(sk);
diff --git a/net/key/af_key.c b/net/key/af_key.c
index e72589a..f3c8307 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -205,7 +205,7 @@ static int pfkey_broadcast_one(struct sk_buff *skb, struct sk_buff **skb2,
 		if (atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf) {
 			skb_set_owner_r(*skb2, sk);
 			skb_queue_tail(&sk->sk_receive_queue, *skb2);
-			sk->sk_data_ready(sk, (*skb2)->len);
+			sk->sk_data_ready(sk);
 			*skb2 = NULL;
 			err = 0;
 		}
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index c2d585c..894cda0 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1653,7 +1653,7 @@ static int __netlink_sendskb(struct sock *sk, struct sk_buff *skb)
 	else
 #endif /* CONFIG_NETLINK_MMAP */
 		skb_queue_tail(&sk->sk_receive_queue, skb);
-	sk->sk_data_ready(sk, len);
+	sk->sk_data_ready(sk);
 	return len;
 }
 
@@ -2394,7 +2394,7 @@ out:
 	return err ? : copied;
 }
 
-static void netlink_data_ready(struct sock *sk, int len)
+static void netlink_data_ready(struct sock *sk)
 {
 	BUG();
 }
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index b74aa07..ede50d1 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -1011,7 +1011,7 @@ int nr_rx_frame(struct sk_buff *skb, struct net_device *dev)
 	skb_queue_head(&sk->sk_receive_queue, skb);
 
 	if (!sock_flag(sk, SOCK_DEAD))
-		sk->sk_data_ready(sk, skb->len);
+		sk->sk_data_ready(sk);
 
 	bh_unlock_sock(sk);
 
diff --git a/net/nfc/llcp_core.c b/net/nfc/llcp_core.c
index b486f12..b467195 100644
--- a/net/nfc/llcp_core.c
+++ b/net/nfc/llcp_core.c
@@ -976,7 +976,7 @@ static void nfc_llcp_recv_connect(struct nfc_llcp_local *local,
 	new_sk->sk_state = LLCP_CONNECTED;
 
 	/* Wake the listening processes */
-	parent->sk_data_ready(parent, 0);
+	parent->sk_data_ready(parent);
 
 	/* Send CC */
 	nfc_llcp_send_cc(new_sock);
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 72e0c71..b85c67c 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1848,7 +1848,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 	skb->dropcount = atomic_read(&sk->sk_drops);
 	__skb_queue_tail(&sk->sk_receive_queue, skb);
 	spin_unlock(&sk->sk_receive_queue.lock);
-	sk->sk_data_ready(sk, skb->len);
+	sk->sk_data_ready(sk);
 	return 0;
 
 drop_n_acct:
@@ -2054,7 +2054,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 	else
 		prb_clear_blk_fill_status(&po->rx_ring);
 
-	sk->sk_data_ready(sk, 0);
+	sk->sk_data_ready(sk);
 
 drop_n_restore:
 	if (skb_head != skb->data && skb_shared(skb)) {
@@ -2069,7 +2069,7 @@ ring_is_full:
 	po->stats.stats1.tp_drops++;
 	spin_unlock(&sk->sk_receive_queue.lock);
 
-	sk->sk_data_ready(sk, 0);
+	sk->sk_data_ready(sk);
 	kfree_skb(copy_skb);
 	goto drop_n_restore;
 }
diff --git a/net/phonet/pep-gprs.c b/net/phonet/pep-gprs.c
index a2fba7e..66dc65e 100644
--- a/net/phonet/pep-gprs.c
+++ b/net/phonet/pep-gprs.c
@@ -37,7 +37,7 @@
 struct gprs_dev {
 	struct sock		*sk;
 	void			(*old_state_change)(struct sock *);
-	void			(*old_data_ready)(struct sock *, int);
+	void			(*old_data_ready)(struct sock *);
 	void			(*old_write_space)(struct sock *);
 
 	struct net_device	*dev;
@@ -146,7 +146,7 @@ drop:
 	return err;
 }
 
-static void gprs_data_ready(struct sock *sk, int len)
+static void gprs_data_ready(struct sock *sk)
 {
 	struct gprs_dev *gp = sk->sk_user_data;
 	struct sk_buff *skb;
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index e774117..70a547e 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -462,10 +462,9 @@ out:
 queue:
 	skb->dev = NULL;
 	skb_set_owner_r(skb, sk);
-	err = skb->len;
 	skb_queue_tail(queue, skb);
 	if (!sock_flag(sk, SOCK_DEAD))
-		sk->sk_data_ready(sk, err);
+		sk->sk_data_ready(sk);
 	return NET_RX_SUCCESS;
 }
 
@@ -587,10 +586,9 @@ static int pipe_handler_do_rcv(struct sock *sk, struct sk_buff *skb)
 		pn->rx_credits--;
 		skb->dev = NULL;
 		skb_set_owner_r(skb, sk);
-		err = skb->len;
 		skb_queue_tail(&sk->sk_receive_queue, skb);
 		if (!sock_flag(sk, SOCK_DEAD))
-			sk->sk_data_ready(sk, err);
+			sk->sk_data_ready(sk);
 		return NET_RX_SUCCESS;
 
 	case PNS_PEP_CONNECT_RESP:
@@ -698,7 +696,7 @@ static int pep_do_rcv(struct sock *sk, struct sk_buff *skb)
 		skb_queue_head(&sk->sk_receive_queue, skb);
 		sk_acceptq_added(sk);
 		if (!sock_flag(sk, SOCK_DEAD))
-			sk->sk_data_ready(sk, 0);
+			sk->sk_data_ready(sk);
 		return NET_RX_SUCCESS;
 
 	case PNS_PEP_DISCONNECT_REQ:
diff --git a/net/rds/tcp.h b/net/rds/tcp.h
index 9cf2927..6563749 100644
--- a/net/rds/tcp.h
+++ b/net/rds/tcp.h
@@ -61,12 +61,12 @@ void rds_tcp_state_change(struct sock *sk);
 /* tcp_listen.c */
 int rds_tcp_listen_init(void);
 void rds_tcp_listen_stop(void);
-void rds_tcp_listen_data_ready(struct sock *sk, int bytes);
+void rds_tcp_listen_data_ready(struct sock *sk);
 
 /* tcp_recv.c */
 int rds_tcp_recv_init(void);
 void rds_tcp_recv_exit(void);
-void rds_tcp_data_ready(struct sock *sk, int bytes);
+void rds_tcp_data_ready(struct sock *sk);
 int rds_tcp_recv(struct rds_connection *conn);
 void rds_tcp_inc_free(struct rds_incoming *inc);
 int rds_tcp_inc_copy_to_user(struct rds_incoming *inc, struct iovec *iov,
diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index 7787537..4e638f8 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -108,9 +108,9 @@ static void rds_tcp_accept_worker(struct work_struct *work)
 		cond_resched();
 }
 
-void rds_tcp_listen_data_ready(struct sock *sk, int bytes)
+void rds_tcp_listen_data_ready(struct sock *sk)
 {
-	void (*ready)(struct sock *sk, int bytes);
+	void (*ready)(struct sock *sk);
 
 	rdsdebug("listen data ready sk %p\n", sk);
 
@@ -132,7 +132,7 @@ void rds_tcp_listen_data_ready(struct sock *sk, int bytes)
 
 out:
 	read_unlock(&sk->sk_callback_lock);
-	ready(sk, bytes);
+	ready(sk);
 }
 
 int rds_tcp_listen_init(void)
diff --git a/net/rds/tcp_recv.c b/net/rds/tcp_recv.c
index 4fac4f2..9ae6e0a 100644
--- a/net/rds/tcp_recv.c
+++ b/net/rds/tcp_recv.c
@@ -314,13 +314,13 @@ int rds_tcp_recv(struct rds_connection *conn)
 	return ret;
 }
 
-void rds_tcp_data_ready(struct sock *sk, int bytes)
+void rds_tcp_data_ready(struct sock *sk)
 {
-	void (*ready)(struct sock *sk, int bytes);
+	void (*ready)(struct sock *sk);
 	struct rds_connection *conn;
 	struct rds_tcp_connection *tc;
 
-	rdsdebug("data ready sk %p bytes %d\n", sk, bytes);
+	rdsdebug("data ready sk %p\n", sk);
 
 	read_lock(&sk->sk_callback_lock);
 	conn = sk->sk_user_data;
@@ -337,7 +337,7 @@ void rds_tcp_data_ready(struct sock *sk, int bytes)
 		queue_delayed_work(rds_wq, &conn->c_recv_w, 0);
 out:
 	read_unlock(&sk->sk_callback_lock);
-	ready(sk, bytes);
+	ready(sk);
 }
 
 int rds_tcp_recv_init(void)
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index c2cca2e..8451c8c 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1041,7 +1041,7 @@ int rose_rx_call_request(struct sk_buff *skb, struct net_device *dev, struct ros
 	rose_start_heartbeat(make);
 
 	if (!sock_flag(sk, SOCK_DEAD))
-		sk->sk_data_ready(sk, skb->len);
+		sk->sk_data_ready(sk);
 
 	return 1;
 }
diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
index 7374264..63b21e5 100644
--- a/net/rxrpc/ar-input.c
+++ b/net/rxrpc/ar-input.c
@@ -113,7 +113,7 @@ int rxrpc_queue_rcv_skb(struct rxrpc_call *call, struct sk_buff *skb,
 			spin_unlock_bh(&sk->sk_receive_queue.lock);
 
 			if (!sock_flag(sk, SOCK_DEAD))
-				sk->sk_data_ready(sk, skb_len);
+				sk->sk_data_ready(sk);
 		}
 		skb = NULL;
 	} else {
@@ -632,14 +632,14 @@ cant_find_conn:
  * handle data received on the local endpoint
  * - may be called in interrupt context
  */
-void rxrpc_data_ready(struct sock *sk, int count)
+void rxrpc_data_ready(struct sock *sk)
 {
 	struct rxrpc_skb_priv *sp;
 	struct rxrpc_local *local;
 	struct sk_buff *skb;
 	int ret;
 
-	_enter("%p, %d", sk, count);
+	_enter("%p", sk);
 
 	ASSERT(!irqs_disabled());
 
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index c831d44..ba9fd36 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -518,7 +518,7 @@ void rxrpc_UDP_error_handler(struct work_struct *);
  */
 extern const char *rxrpc_pkts[];
 
-void rxrpc_data_ready(struct sock *, int);
+void rxrpc_data_ready(struct sock *);
 int rxrpc_queue_rcv_skb(struct rxrpc_call *, struct sk_buff *, bool, bool);
 void rxrpc_fast_process_packet(struct rxrpc_call *, struct sk_buff *);
 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 270d5bd..e13519e 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6745,7 +6745,7 @@ do_nonblock:
 	goto out;
 }
 
-void sctp_data_ready(struct sock *sk, int len)
+void sctp_data_ready(struct sock *sk)
 {
 	struct socket_wq *wq;
 
diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index 5dc9411..7144eb6 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -259,7 +259,7 @@ int sctp_ulpq_tail_event(struct sctp_ulpq *ulpq, struct sctp_ulpevent *event)
 		sctp_ulpq_clear_pd(ulpq);
 
 	if (queue == &sk->sk_receive_queue)
-		sk->sk_data_ready(sk, 0);
+		sk->sk_data_ready(sk);
 	return 1;
 
 out_free:
@@ -1135,5 +1135,5 @@ void sctp_ulpq_abort_pd(struct sctp_ulpq *ulpq, gfp_t gfp)
 
 	/* If there is data waiting, send it up the socket now. */
 	if (sctp_ulpq_clear_pd(ulpq) || ev)
-		sk->sk_data_ready(sk, 0);
+		sk->sk_data_ready(sk);
 }
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index b6e59f0..c26ce95 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -60,7 +60,7 @@
 
 static struct svc_sock *svc_setup_socket(struct svc_serv *, struct socket *,
 					 int flags);
-static void		svc_udp_data_ready(struct sock *, int);
+static void		svc_udp_data_ready(struct sock *);
 static int		svc_udp_recvfrom(struct svc_rqst *);
 static int		svc_udp_sendto(struct svc_rqst *);
 static void		svc_sock_detach(struct svc_xprt *);
@@ -403,14 +403,14 @@ static void svc_sock_setbufsize(struct socket *sock, unsigned int snd,
 /*
  * INET callback when data has been received on the socket.
  */
-static void svc_udp_data_ready(struct sock *sk, int count)
+static void svc_udp_data_ready(struct sock *sk)
 {
 	struct svc_sock	*svsk = (struct svc_sock *)sk->sk_user_data;
 	wait_queue_head_t *wq = sk_sleep(sk);
 
 	if (svsk) {
-		dprintk("svc: socket %p(inet %p), count=%d, busy=%d\n",
-			svsk, sk, count,
+		dprintk("svc: socket %p(inet %p), busy=%d\n",
+			svsk, sk,
 			test_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags));
 		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 		svc_xprt_enqueue(&svsk->sk_xprt);
@@ -731,7 +731,7 @@ static void svc_udp_init(struct svc_sock *svsk, struct svc_serv *serv)
  * A data_ready event on a listening socket means there's a connection
  * pending. Do not use state_change as a substitute for it.
  */
-static void svc_tcp_listen_data_ready(struct sock *sk, int count_unused)
+static void svc_tcp_listen_data_ready(struct sock *sk)
 {
 	struct svc_sock	*svsk = (struct svc_sock *)sk->sk_user_data;
 	wait_queue_head_t *wq;
@@ -783,7 +783,7 @@ static void svc_tcp_state_change(struct sock *sk)
 		wake_up_interruptible_all(wq);
 }
 
-static void svc_tcp_data_ready(struct sock *sk, int count)
+static void svc_tcp_data_ready(struct sock *sk)
 {
 	struct svc_sock *svsk = (struct svc_sock *)sk->sk_user_data;
 	wait_queue_head_t *wq = sk_sleep(sk);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 966763d..96458d4 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -254,7 +254,7 @@ struct sock_xprt {
 	/*
 	 * Saved socket callback addresses
 	 */
-	void			(*old_data_ready)(struct sock *, int);
+	void			(*old_data_ready)(struct sock *);
 	void			(*old_state_change)(struct sock *);
 	void			(*old_write_space)(struct sock *);
 	void			(*old_error_report)(struct sock *);
@@ -946,7 +946,7 @@ static int xs_local_copy_to_xdr(struct xdr_buf *xdr, struct sk_buff *skb)
  *
  * Currently this assumes we can read the whole reply in a single gulp.
  */
-static void xs_local_data_ready(struct sock *sk, int len)
+static void xs_local_data_ready(struct sock *sk)
 {
 	struct rpc_task *task;
 	struct rpc_xprt *xprt;
@@ -1009,7 +1009,7 @@ static void xs_local_data_ready(struct sock *sk, int len)
  * @len: how much data to read
  *
  */
-static void xs_udp_data_ready(struct sock *sk, int len)
+static void xs_udp_data_ready(struct sock *sk)
 {
 	struct rpc_task *task;
 	struct rpc_xprt *xprt;
@@ -1432,7 +1432,7 @@ static int xs_tcp_data_recv(read_descriptor_t *rd_desc, struct sk_buff *skb, uns
  * @bytes: how much data to read
  *
  */
-static void xs_tcp_data_ready(struct sock *sk, int bytes)
+static void xs_tcp_data_ready(struct sock *sk)
 {
 	struct rpc_xprt *xprt;
 	read_descriptor_t rd_desc;
diff --git a/net/tipc/server.c b/net/tipc/server.c
index 646a930..a538a02 100644
--- a/net/tipc/server.c
+++ b/net/tipc/server.c
@@ -119,7 +119,7 @@ static struct tipc_conn *tipc_conn_lookup(struct tipc_server *s, int conid)
 	return con;
 }
 
-static void sock_data_ready(struct sock *sk, int unused)
+static void sock_data_ready(struct sock *sk)
 {
 	struct tipc_conn *con;
 
@@ -297,7 +297,7 @@ static int tipc_accept_from_sock(struct tipc_conn *con)
 	newcon->usr_data = s->tipc_conn_new(newcon->conid);
 
 	/* Wake up receive process in case of 'SYN+' message */
-	newsock->sk->sk_data_ready(newsock->sk, 0);
+	newsock->sk->sk_data_ready(newsock->sk);
 	return ret;
 }
 
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index adc12e2..3c02569 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -45,7 +45,7 @@
 #define CONN_TIMEOUT_DEFAULT	8000	/* default connect timeout = 8s */
 
 static int backlog_rcv(struct sock *sk, struct sk_buff *skb);
-static void tipc_data_ready(struct sock *sk, int len);
+static void tipc_data_ready(struct sock *sk);
 static void tipc_write_space(struct sock *sk);
 static int tipc_release(struct socket *sock);
 static int tipc_accept(struct socket *sock, struct socket *new_sock, int flags);
@@ -1248,7 +1248,7 @@ static void tipc_write_space(struct sock *sk)
  * @sk: socket
  * @len: the length of messages
  */
-static void tipc_data_ready(struct sock *sk, int len)
+static void tipc_data_ready(struct sock *sk)
 {
 	struct socket_wq *wq;
 
@@ -1410,7 +1410,7 @@ static u32 filter_rcv(struct sock *sk, struct sk_buff *buf)
 	__skb_queue_tail(&sk->sk_receive_queue, buf);
 	skb_set_owner_r(buf, sk);
 
-	sk->sk_data_ready(sk, 0);
+	sk->sk_data_ready(sk);
 	return TIPC_OK;
 }
 
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 94404f1..bb7e8ba 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1217,7 +1217,7 @@ restart:
 	__skb_queue_tail(&other->sk_receive_queue, skb);
 	spin_unlock(&other->sk_receive_queue.lock);
 	unix_state_unlock(other);
-	other->sk_data_ready(other, 0);
+	other->sk_data_ready(other);
 	sock_put(other);
 	return 0;
 
@@ -1600,7 +1600,7 @@ restart:
 	if (max_level > unix_sk(other)->recursion_level)
 		unix_sk(other)->recursion_level = max_level;
 	unix_state_unlock(other);
-	other->sk_data_ready(other, len);
+	other->sk_data_ready(other);
 	sock_put(other);
 	scm_destroy(siocb->scm);
 	return len;
@@ -1706,7 +1706,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		if (max_level > unix_sk(other)->recursion_level)
 			unix_sk(other)->recursion_level = max_level;
 		unix_state_unlock(other);
-		other->sk_data_ready(other, size);
+		other->sk_data_ready(other);
 		sent += size;
 	}
 
diff --git a/net/vmw_vsock/vmci_transport_notify.c b/net/vmw_vsock/vmci_transport_notify.c
index 9a73074..9b7f207 100644
--- a/net/vmw_vsock/vmci_transport_notify.c
+++ b/net/vmw_vsock/vmci_transport_notify.c
@@ -315,7 +315,7 @@ vmci_transport_handle_wrote(struct sock *sk,
 	struct vsock_sock *vsk = vsock_sk(sk);
 	PKT_FIELD(vsk, sent_waiting_read) = false;
 #endif
-	sk->sk_data_ready(sk, 0);
+	sk->sk_data_ready(sk);
 }
 
 static void vmci_transport_notify_pkt_socket_init(struct sock *sk)
diff --git a/net/vmw_vsock/vmci_transport_notify_qstate.c b/net/vmw_vsock/vmci_transport_notify_qstate.c
index 622bd7a..dc9c792 100644
--- a/net/vmw_vsock/vmci_transport_notify_qstate.c
+++ b/net/vmw_vsock/vmci_transport_notify_qstate.c
@@ -92,7 +92,7 @@ vmci_transport_handle_wrote(struct sock *sk,
 			    bool bottom_half,
 			    struct sockaddr_vm *dst, struct sockaddr_vm *src)
 {
-	sk->sk_data_ready(sk, 0);
+	sk->sk_data_ready(sk);
 }
 
 static void vsock_block_update_write_window(struct sock *sk)
@@ -290,7 +290,7 @@ vmci_transport_notify_pkt_recv_post_dequeue(
 		/* See the comment in
 		 * vmci_transport_notify_pkt_send_post_enqueue().
 		 */
-		sk->sk_data_ready(sk, 0);
+		sk->sk_data_ready(sk);
 	}
 
 	return err;
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 6177479..5ad4418 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1064,7 +1064,7 @@ int x25_rx_call_request(struct sk_buff *skb, struct x25_neigh *nb,
 	x25_start_heartbeat(make);
 
 	if (!sock_flag(sk, SOCK_DEAD))
-		sk->sk_data_ready(sk, skb->len);
+		sk->sk_data_ready(sk);
 	rc = 1;
 	sock_put(sk);
 out:
diff --git a/net/x25/x25_in.c b/net/x25/x25_in.c
index d1b0dc7..7ac5009 100644
--- a/net/x25/x25_in.c
+++ b/net/x25/x25_in.c
@@ -79,7 +79,7 @@ static int x25_queue_rx_frame(struct sock *sk, struct sk_buff *skb, int more)
 	skb_set_owner_r(skbn, sk);
 	skb_queue_tail(&sk->sk_receive_queue, skbn);
 	if (!sock_flag(sk, SOCK_DEAD))
-		sk->sk_data_ready(sk, skbn->len);
+		sk->sk_data_ready(sk);
 
 	return 0;
 }
-- 
1.7.11.7
