From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 01/14] Bluetooth: use list_for_each_entry*
Date: Fri, 18 Dec 2015 23:33:25 +0800
Message-ID: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use list_for_each_entry*() instead of list_for_each*() to simplify
the code.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 net/bluetooth/af_bluetooth.c | 12 ++++++------
 net/bluetooth/cmtp/capi.c    |  8 ++------
 net/bluetooth/hci_core.c     |  8 +++-----
 net/bluetooth/rfcomm/core.c  | 46 ++++++++++++++------------------------------
 4 files changed, 25 insertions(+), 49 deletions(-)

diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index cb4e8d4..955eda9 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -174,13 +174,13 @@ EXPORT_SYMBOL(bt_accept_unlink);
 
 struct sock *bt_accept_dequeue(struct sock *parent, struct socket *newsock)
 {
-	struct list_head *p, *n;
+	struct bt_sock *s, *n;
 	struct sock *sk;
 
 	BT_DBG("parent %p", parent);
 
-	list_for_each_safe(p, n, &bt_sk(parent)->accept_q) {
-		sk = (struct sock *) list_entry(p, struct bt_sock, accept_q);
+	list_for_each_entry_safe(s, n, &bt_sk(parent)->accept_q, accept_q) {
+		sk = (struct sock *)s;
 
 		lock_sock(sk);
 
@@ -388,11 +388,11 @@ EXPORT_SYMBOL(bt_sock_stream_recvmsg);
 
 static inline unsigned int bt_accept_poll(struct sock *parent)
 {
-	struct list_head *p, *n;
+	struct bt_sock *s, *n;
 	struct sock *sk;
 
-	list_for_each_safe(p, n, &bt_sk(parent)->accept_q) {
-		sk = (struct sock *) list_entry(p, struct bt_sock, accept_q);
+	list_for_each_entry_safe(s, n, &bt_sk(parent)->accept_q, accept_q) {
+		sk = (struct sock *)s;
 		if (sk->sk_state == BT_CONNECTED ||
 		    (test_bit(BT_SK_DEFER_SETUP, &bt_sk(parent)->flags) &&
 		     sk->sk_state == BT_CONNECT2))
diff --git a/net/bluetooth/cmtp/capi.c b/net/bluetooth/cmtp/capi.c
index 9a503387..46ac686 100644
--- a/net/bluetooth/cmtp/capi.c
+++ b/net/bluetooth/cmtp/capi.c
@@ -100,10 +100,8 @@ static void cmtp_application_del(struct cmtp_session *session, struct cmtp_appli
 static struct cmtp_application *cmtp_application_get(struct cmtp_session *session, int pattern, __u16 value)
 {
 	struct cmtp_application *app;
-	struct list_head *p;
 
-	list_for_each(p, &session->applications) {
-		app = list_entry(p, struct cmtp_application, list);
+	list_for_each_entry(app, &session->applications, list) {
 		switch (pattern) {
 		case CMTP_MSGNUM:
 			if (app->msgnum == value)
@@ -511,14 +509,12 @@ static int cmtp_proc_show(struct seq_file *m, void *v)
 	struct capi_ctr *ctrl = m->private;
 	struct cmtp_session *session = ctrl->driverdata;
 	struct cmtp_application *app;
-	struct list_head *p;
 
 	seq_printf(m, "%s\n\n", cmtp_procinfo(ctrl));
 	seq_printf(m, "addr %s\n", session->name);
 	seq_printf(m, "ctrl %d\n", session->num);
 
-	list_for_each(p, &session->applications) {
-		app = list_entry(p, struct cmtp_application, list);
+	list_for_each_entry(app, &session->applications, list) {
 		seq_printf(m, "appl %d -> %d\n", app->appl, app->mapping);
 	}
 
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 9fb443a..47bcef7 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -2713,12 +2713,10 @@ struct bdaddr_list *hci_bdaddr_list_lookup(struct list_head *bdaddr_list,
 
 void hci_bdaddr_list_clear(struct list_head *bdaddr_list)
 {
-	struct list_head *p, *n;
+	struct bdaddr_list *b, *n;
 
-	list_for_each_safe(p, n, bdaddr_list) {
-		struct bdaddr_list *b = list_entry(p, struct bdaddr_list, list);
-
-		list_del(p);
+	list_for_each_entry_safe(b, n, bdaddr_list, list) {
+		list_del(&b->list);
 		kfree(b);
 	}
 }
diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index 29709fb..f7eb02f 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -692,11 +692,9 @@ static struct rfcomm_session *rfcomm_session_del(struct rfcomm_session *s)
 
 static struct rfcomm_session *rfcomm_session_get(bdaddr_t *src, bdaddr_t *dst)
 {
-	struct rfcomm_session *s;
-	struct list_head *p, *n;
+	struct rfcomm_session *s, *n;
 	struct l2cap_chan *chan;
-	list_for_each_safe(p, n, &session_list) {
-		s = list_entry(p, struct rfcomm_session, list);
+	list_for_each_entry_safe(s, n, &session_list, list) {
 		chan = l2cap_pi(s->sock->sk)->chan;
 
 		if ((!bacmp(src, BDADDR_ANY) || !bacmp(&chan->src, src)) &&
@@ -709,16 +707,14 @@ static struct rfcomm_session *rfcomm_session_get(bdaddr_t *src, bdaddr_t *dst)
 static struct rfcomm_session *rfcomm_session_close(struct rfcomm_session *s,
 						   int err)
 {
-	struct rfcomm_dlc *d;
-	struct list_head *p, *n;
+	struct rfcomm_dlc *d, *n;
 
 	s->state = BT_CLOSED;
 
 	BT_DBG("session %p state %ld err %d", s, s->state, err);
 
 	/* Close all dlcs */
-	list_for_each_safe(p, n, &s->dlcs) {
-		d = list_entry(p, struct rfcomm_dlc, list);
+	list_for_each_entry_safe(d, n, &s->dlcs, list) {
 		d->state = BT_CLOSED;
 		__rfcomm_dlc_close(d, err);
 	}
@@ -1771,13 +1767,11 @@ static struct rfcomm_session *rfcomm_recv_frame(struct rfcomm_session *s,
 
 static void rfcomm_process_connect(struct rfcomm_session *s)
 {
-	struct rfcomm_dlc *d;
-	struct list_head *p, *n;
+	struct rfcomm_dlc *d, *n;
 
 	BT_DBG("session %p state %ld", s, s->state);
 
-	list_for_each_safe(p, n, &s->dlcs) {
-		d = list_entry(p, struct rfcomm_dlc, list);
+	list_for_each_entry_safe(d, n, &s->dlcs, list) {
 		if (d->state == BT_CONFIG) {
 			d->mtu = s->mtu;
 			if (rfcomm_check_security(d)) {
@@ -1843,14 +1837,11 @@ static int rfcomm_process_tx(struct rfcomm_dlc *d)
 
 static void rfcomm_process_dlcs(struct rfcomm_session *s)
 {
-	struct rfcomm_dlc *d;
-	struct list_head *p, *n;
+	struct rfcomm_dlc *d, *n;
 
 	BT_DBG("session %p state %ld", s, s->state);
 
-	list_for_each_safe(p, n, &s->dlcs) {
-		d = list_entry(p, struct rfcomm_dlc, list);
-
+	list_for_each_entry_safe(d, n, &s->dlcs, list) {
 		if (test_bit(RFCOMM_TIMED_OUT, &d->flags)) {
 			__rfcomm_dlc_close(d, ETIMEDOUT);
 			continue;
@@ -1985,14 +1976,11 @@ static struct rfcomm_session *rfcomm_check_connection(struct rfcomm_session *s)
 
 static void rfcomm_process_sessions(void)
 {
-	struct list_head *p, *n;
+	struct rfcomm_session *s, *n;
 
 	rfcomm_lock();
 
-	list_for_each_safe(p, n, &session_list) {
-		struct rfcomm_session *s;
-		s = list_entry(p, struct rfcomm_session, list);
-
+	list_for_each_entry_safe(s, n, &session_list, list) {
 		if (test_and_clear_bit(RFCOMM_TIMED_OUT, &s->flags)) {
 			s->state = BT_DISCONN;
 			rfcomm_send_disc(s, 0);
@@ -2075,15 +2063,12 @@ failed:
 
 static void rfcomm_kill_listener(void)
 {
-	struct rfcomm_session *s;
-	struct list_head *p, *n;
+	struct rfcomm_session *s, *n;
 
 	BT_DBG("");
 
-	list_for_each_safe(p, n, &session_list) {
-		s = list_entry(p, struct rfcomm_session, list);
+	list_for_each_entry_safe(s, n, &session_list, list)
 		rfcomm_session_del(s);
-	}
 }
 
 static int rfcomm_run(void *unused)
@@ -2113,8 +2098,7 @@ static int rfcomm_run(void *unused)
 static void rfcomm_security_cfm(struct hci_conn *conn, u8 status, u8 encrypt)
 {
 	struct rfcomm_session *s;
-	struct rfcomm_dlc *d;
-	struct list_head *p, *n;
+	struct rfcomm_dlc *d, *n;
 
 	BT_DBG("conn %p status 0x%02x encrypt 0x%02x", conn, status, encrypt);
 
@@ -2122,9 +2106,7 @@ static void rfcomm_security_cfm(struct hci_conn *conn, u8 status, u8 encrypt)
 	if (!s)
 		return;
 
-	list_for_each_safe(p, n, &s->dlcs) {
-		d = list_entry(p, struct rfcomm_dlc, list);
-
+	list_for_each_entry_safe(d, n, &s->dlcs, list) {
 		if (test_and_clear_bit(RFCOMM_SEC_PENDING, &d->flags)) {
 			rfcomm_dlc_clear_timer(d);
 			if (status || encrypt == 0x00) {
-- 
2.5.0
