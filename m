From: Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>
Subject: [PATCH 1/2] Bluetooth: notify userspace of security level change
Date: Sun, 13 May 2012 03:20:07 -0300
Message-ID: <1336890007-10646-1-git-send-email-gustavo@padovan.org>
References: <1336849910-29064-2-git-send-email-gustavo@padovan.org>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1336849910-29064-2-git-send-email-gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

It fixes L2CAP socket based security level elevation during a
connection. The HID profile needs this (for keyboards) and it is the only
way to achieve the security level elevation when using the management
interface to talk to the kernel (hence the management enabling patch
being the one that exposes this issue).

It enables the userspace a security level change when the socket is
already connected and create a way to notify the socket the result of the
request. At the moment of the request the socket is made non writable, if
the request fails the connections closes, otherwise the socket is made
writable again, POLL_OUT is emmited.

Signed-off-by: Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>
Acked-by: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Signed-off-by: Johan Hedberg <johan.hedberg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 include/net/bluetooth/bluetooth.h |    1 +
 net/bluetooth/af_bluetooth.c      |    2 +-
 net/bluetooth/hci_event.c         |    7 +++++++
 net/bluetooth/l2cap_core.c        |    5 +++++
 net/bluetooth/l2cap_sock.c        |   12 ++++++++----
 5 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
index 262ebd1..a65910b 100644
--- a/include/net/bluetooth/bluetooth.h
+++ b/include/net/bluetooth/bluetooth.h
@@ -191,6 +191,7 @@ struct bt_sock {
 	struct list_head accept_q;
 	struct sock *parent;
 	u32 defer_setup;
+	bool suspended;
 };
 
 struct bt_sock_list {
diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index 72eb187..6fb68a9 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -450,7 +450,7 @@ unsigned int bt_sock_poll(struct file *file, struct socket *sock, poll_table *wa
 			sk->sk_state == BT_CONFIG)
 		return mask;
 
-	if (sock_writeable(sk))
+	if (!bt_sk(sk)->suspended && sock_writeable(sk))
 		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
 	else
 		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index 7f87a70..ff38cc6 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -2040,6 +2040,12 @@ static inline void hci_encrypt_change_evt(struct hci_dev *hdev, struct sk_buff *
 
 		clear_bit(HCI_CONN_ENCRYPT_PEND, &conn->flags);
 
+		if (ev->status && conn->state == BT_CONNECTED) {
+			hci_acl_disconn(conn, 0x13);
+			hci_conn_put(conn);
+			goto unlock;
+		}
+
 		if (conn->state == BT_CONFIG) {
 			if (!ev->status)
 				conn->state = BT_CONNECTED;
@@ -2050,6 +2056,7 @@ static inline void hci_encrypt_change_evt(struct hci_dev *hdev, struct sk_buff *
 			hci_encrypt_cfm(conn, ev->status, ev->encrypt);
 	}
 
+unlock:
 	hci_dev_unlock(hdev);
 }
 
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index 38d934a..c073533 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -4590,6 +4590,11 @@ int l2cap_security_cfm(struct hci_conn *hcon, u8 status, u8 encrypt)
 
 		if (!status && (chan->state == BT_CONNECTED ||
 						chan->state == BT_CONFIG)) {
+			struct sock *sk = chan->sk;
+
+			bt_sk(sk)->suspended = false;
+			sk->sk_state_change(sk);
+
 			l2cap_check_encryption(chan, encrypt);
 			l2cap_chan_unlock(chan);
 			continue;
diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index 29122ed..04e7c17 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -592,10 +592,14 @@ static int l2cap_sock_setsockopt(struct socket *sock, int level, int optname, ch
 			sk->sk_state = BT_CONFIG;
 			chan->state = BT_CONFIG;
 
-		/* or for ACL link, under defer_setup time */
-		} else if (sk->sk_state == BT_CONNECT2 &&
-					bt_sk(sk)->defer_setup) {
-			err = l2cap_chan_check_security(chan);
+		/* or for ACL link */
+		} else if ((sk->sk_state == BT_CONNECT2 &&
+			   bt_sk(sk)->defer_setup) ||
+			   sk->sk_state == BT_CONNECTED) {
+			if (!l2cap_chan_check_security(chan))
+				bt_sk(sk)->suspended = true;
+			else
+				sk->sk_state_change(sk);
 		} else {
 			err = -EINVAL;
 		}
-- 
1.7.10.1
