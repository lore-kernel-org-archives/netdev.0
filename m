From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/17) bluetooth -- size_t for send/recvmsg
Date: Fri, 9 Jan 2004 13:40:00 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040109134000.7201c3af@linux.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Maxim Krasnyansky <maxk@qualcomm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert bluetooth sendmsg/recvmsg from size as int to size_t.
Add check in HCI that sendmsg < max allowed frame size.

diff -Nru a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
--- a/include/net/bluetooth/bluetooth.h	Mon Dec  8 16:19:37 2003
+++ b/include/net/bluetooth/bluetooth.h	Mon Dec  8 16:19:37 2003
@@ -129,7 +129,7 @@
 struct sock *bt_sock_alloc(struct socket *sock, int proto, int pi_size, int prio);
 void bt_sock_link(struct bt_sock_list *l, struct sock *s);
 void bt_sock_unlink(struct bt_sock_list *l, struct sock *s);
-int  bt_sock_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg, int len, int flags);
+int  bt_sock_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg, size_t len, int flags);
 uint bt_sock_poll(struct file * file, struct socket *sock, poll_table *wait);
 int  bt_sock_wait_state(struct sock *sk, int state, unsigned long timeo);
 
diff -Nru a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
--- a/net/bluetooth/af_bluetooth.c	Mon Dec  8 16:19:37 2003
+++ b/net/bluetooth/af_bluetooth.c	Mon Dec  8 16:19:37 2003
@@ -201,12 +201,13 @@
 }
 
 int bt_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
-	struct msghdr *msg, int len, int flags)
+	struct msghdr *msg, size_t len, int flags)
 {
 	int noblock = flags & MSG_DONTWAIT;
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
-	int copied, err;
+	size_t copied;
+	int err;
 
 	BT_DBG("sock %p sk %p len %d", sock, sk, len);
 
diff -Nru a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
--- a/net/bluetooth/hci_sock.c	Mon Dec  8 16:19:37 2003
+++ b/net/bluetooth/hci_sock.c	Mon Dec  8 16:19:37 2003
@@ -319,7 +319,8 @@
         	put_cmsg(msg, SOL_HCI, HCI_CMSG_TSTAMP, sizeof(skb->stamp), &skb->stamp);
 }
  
-static int hci_sock_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg, int len, int flags)
+static int hci_sock_recvmsg(struct kiocb *iocb, struct socket *sock, 
+			    struct msghdr *msg, size_t len, int flags)
 {
 	int noblock = flags & MSG_DONTWAIT;
 	struct sock *sk = sock->sk;
@@ -355,7 +356,8 @@
 	return err ? : copied;
 }
 
-static int hci_sock_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg, int len)
+static int hci_sock_sendmsg(struct kiocb *iocb, struct socket *sock, 
+			    struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct hci_dev *hdev;
@@ -370,9 +372,9 @@
 	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_NOSIGNAL|MSG_ERRQUEUE))
 		return -EINVAL;
 
-	if (len < 4)
+	if (len < 4 || len > HCI_MAX_FRAME_SIZE)
 		return -EINVAL;
-	
+
 	lock_sock(sk);
 
 	if (!(hdev = hci_pi(sk)->hdev)) {
diff -Nru a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
--- a/net/bluetooth/l2cap.c	Mon Dec  8 16:19:37 2003
+++ b/net/bluetooth/l2cap.c	Mon Dec  8 16:19:37 2003
@@ -706,7 +706,8 @@
 	return err;
 }
 
-static int l2cap_sock_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg, int len)
+static int l2cap_sock_sendmsg(struct kiocb *iocb, struct socket *sock, 
+			      struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	int err = 0;
diff -Nru a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
--- a/net/bluetooth/rfcomm/sock.c	Mon Dec  8 16:19:37 2003
+++ b/net/bluetooth/rfcomm/sock.c	Mon Dec  8 16:19:37 2003
@@ -482,12 +482,12 @@
 }
 
 static int rfcomm_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
-			       struct msghdr *msg, int len)
+			       struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct rfcomm_dlc *d = rfcomm_pi(sk)->dlc;
 	struct sk_buff *skb;
-	int err, size;
+	int err;
 	int sent = 0;
 
 	if (msg->msg_flags & MSG_OOB)
@@ -501,7 +501,7 @@
 	lock_sock(sk);
 
 	while (len) {
-		size = min_t(uint, len, d->mtu);
+		size_t size = min(len, d->mtu);
 		
 		skb = sock_alloc_send_skb(sk, size + RFCOMM_SKB_RESERVE,
 				msg->msg_flags & MSG_DONTWAIT, &err);
@@ -556,10 +556,11 @@
 }
 
 static int rfcomm_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
-			       struct msghdr *msg, int size, int flags)
+			       struct msghdr *msg, size_t size, int flags)
 {
 	struct sock *sk = sock->sk;
-	int target, err = 0, copied = 0;
+	int err = 0;
+	size_t target, copied = 0;
 	long timeo;
 
 	if (flags & MSG_OOB)
diff -Nru a/net/bluetooth/sco.c b/net/bluetooth/sco.c
--- a/net/bluetooth/sco.c	Mon Dec  8 16:19:37 2003
+++ b/net/bluetooth/sco.c	Mon Dec  8 16:19:37 2003
@@ -630,7 +630,8 @@
 	return 0;
 }
 
-static int sco_sock_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg, int len)
+static int sco_sock_sendmsg(struct kiocb *iocb, struct socket *sock, 
+			    struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	int err = 0;
