From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH] bluetooth: never linger on process exit
Date: Tue, 15 Jul 2014 12:25:28 +0400
Message-ID: <1405412728-4706-1-git-send-email-vdavydov@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the current process is exiting, lingering on socket close will make
it unkillable, so we should avoid it.

Reproducer:

  #include <sys/types.h>
  #include <sys/socket.h>

  #define BTPROTO_L2CAP   0
  #define BTPROTO_SCO     2
  #define BTPROTO_RFCOMM  3

  int main()
  {
          int fd;
          struct linger ling;

          fd = socket(PF_BLUETOOTH, SOCK_STREAM, BTPROTO_RFCOMM);
          //or: fd = socket(PF_BLUETOOTH, SOCK_DGRAM, BTPROTO_L2CAP);
          //or: fd = socket(PF_BLUETOOTH, SOCK_SEQPACKET, BTPROTO_SCO);

          ling.l_onoff = 1;
          ling.l_linger = 1000000000;
          setsockopt(fd, SOL_SOCKET, SO_LINGER, &ling, sizeof(ling));

          return 0;
  }

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Marcel Holtmann <marcel@holtmann.org>
Cc: Gustavo Padovan <gustavo@padovan.org>
Cc: Johan Hedberg <johan.hedberg@gmail.com>
---
 net/bluetooth/l2cap_sock.c  |    3 ++-
 net/bluetooth/rfcomm/sock.c |    3 ++-
 net/bluetooth/sco.c         |    6 ++++--
 3 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index e1378693cc90..d0fd8b04f2e6 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -1111,7 +1111,8 @@ static int l2cap_sock_shutdown(struct socket *sock, int how)
 		l2cap_chan_close(chan, 0);
 		lock_sock(sk);
 
-		if (sock_flag(sk, SOCK_LINGER) && sk->sk_lingertime)
+		if (sock_flag(sk, SOCK_LINGER) && sk->sk_lingertime &&
+		    !(current->flags & PF_EXITING))
 			err = bt_sock_wait_state(sk, BT_CLOSED,
 						 sk->sk_lingertime);
 	}
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index c603a5eb4720..8bbbb5ec468c 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -918,7 +918,8 @@ static int rfcomm_sock_shutdown(struct socket *sock, int how)
 		sk->sk_shutdown = SHUTDOWN_MASK;
 		__rfcomm_sock_close(sk);
 
-		if (sock_flag(sk, SOCK_LINGER) && sk->sk_lingertime)
+		if (sock_flag(sk, SOCK_LINGER) && sk->sk_lingertime &&
+		    !(current->flags & PF_EXITING))
 			err = bt_sock_wait_state(sk, BT_CLOSED, sk->sk_lingertime);
 	}
 	release_sock(sk);
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index c06dbd3938e8..dbbbc0292bd0 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -909,7 +909,8 @@ static int sco_sock_shutdown(struct socket *sock, int how)
 		sco_sock_clear_timer(sk);
 		__sco_sock_close(sk);
 
-		if (sock_flag(sk, SOCK_LINGER) && sk->sk_lingertime)
+		if (sock_flag(sk, SOCK_LINGER) && sk->sk_lingertime &&
+		    !(current->flags & PF_EXITING))
 			err = bt_sock_wait_state(sk, BT_CLOSED,
 						 sk->sk_lingertime);
 	}
@@ -929,7 +930,8 @@ static int sco_sock_release(struct socket *sock)
 
 	sco_sock_close(sk);
 
-	if (sock_flag(sk, SOCK_LINGER) && sk->sk_lingertime) {
+	if (sock_flag(sk, SOCK_LINGER) && sk->sk_lingertime &&
+	    !(current->flags & PF_EXITING)) {
 		lock_sock(sk);
 		err = bt_sock_wait_state(sk, BT_CLOSED, sk->sk_lingertime);
 		release_sock(sk);
-- 
1.7.10.4
