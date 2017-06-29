From: Mateusz Jurczyk <mjurczyk-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Bluetooth: Add sockaddr length checks before accessing sa_family in bind and connect handlers
Date: Thu, 29 Jun 2017 14:04:59 +0200
Message-ID: <20170629120459.16937-1-mjurczyk@google.com>
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
        Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
        Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Verify that the caller-provided sockaddr structure is large enough to
contain the sa_family field, before accessing it in bind() and connect()
handlers of the Bluetooth sockets. Since neither syscall enforces a minimum
size of the corresponding memory region, very short sockaddrs (zero or one
byte long) result in operating on uninitialized memory while referencing
sa_family.

Signed-off-by: Mateusz Jurczyk <mjurczyk-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 net/bluetooth/l2cap_sock.c  | 5 +++--
 net/bluetooth/rfcomm/sock.c | 3 ++-
 net/bluetooth/sco.c         | 6 ++----
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index 507b80d59dec..67a8642f57ea 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -87,7 +87,8 @@ static int l2cap_sock_bind(struct socket *sock, struct sockaddr *addr, int alen)
 
 	BT_DBG("sk %p", sk);
 
-	if (!addr || addr->sa_family != AF_BLUETOOTH)
+	if (!addr || alen < offsetofend(struct sockaddr, sa_family) ||
+	    addr->sa_family != AF_BLUETOOTH)
 		return -EINVAL;
 
 	memset(&la, 0, sizeof(la));
@@ -181,7 +182,7 @@ static int l2cap_sock_connect(struct socket *sock, struct sockaddr *addr,
 
 	BT_DBG("sk %p", sk);
 
-	if (!addr || alen < sizeof(addr->sa_family) ||
+	if (!addr || alen < offsetofend(struct sockaddr, sa_family) ||
 	    addr->sa_family != AF_BLUETOOTH)
 		return -EINVAL;
 
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index ac3c650cb234..2025b45a8bf8 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -339,7 +339,8 @@ static int rfcomm_sock_bind(struct socket *sock, struct sockaddr *addr, int addr
 	struct sock *sk = sock->sk;
 	int len, err = 0;
 
-	if (!addr || addr->sa_family != AF_BLUETOOTH)
+	if (!addr || addr_len < offsetofend(struct sockaddr, sa_family) ||
+	    addr->sa_family != AF_BLUETOOTH)
 		return -EINVAL;
 
 	memset(&sa, 0, sizeof(sa));
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index 728e0c8dc8e7..795e920a3281 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -524,10 +524,8 @@ static int sco_sock_bind(struct socket *sock, struct sockaddr *addr,
 
 	BT_DBG("sk %p %pMR", sk, &sa->sco_bdaddr);
 
-	if (!addr || addr->sa_family != AF_BLUETOOTH)
-		return -EINVAL;
-
-	if (addr_len < sizeof(struct sockaddr_sco))
+	if (!addr || addr_len < sizeof(struct sockaddr_sco) ||
+	    addr->sa_family != AF_BLUETOOTH)
 		return -EINVAL;
 
 	lock_sock(sk);
-- 
2.13.2.725.g09c95d1e9-goog
