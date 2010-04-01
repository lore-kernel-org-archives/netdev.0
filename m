From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: check the length of the socket address passed to connect(2)
Date: Thu, 01 Apr 2010 16:58:26 +0800
Message-ID: <4BB46032.7030500@gmail.com>
Reply-To: xiaosuo@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiaosuo <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f179.google.com ([209.85.222.179]:40569 "EHLO
	mail-pz0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754484Ab0DAI6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 04:58:53 -0400
Received: by pzk9 with SMTP id 9so940656pzk.21
        for <netdev@vger.kernel.org>; Thu, 01 Apr 2010 01:58:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

check the length of the socket address passed to connect(2).

Check the length of the socket address passed to connect(2). If the
length is invalid, -EINVAL will be returned.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
net/bluetooth/l2cap.c | 3 ++-
net/bluetooth/rfcomm/sock.c | 3 ++-
net/bluetooth/sco.c | 3 ++-
net/can/bcm.c | 3 +++
net/ieee802154/af_ieee802154.c | 3 +++
net/ipv4/af_inet.c | 5 +++++
net/netlink/af_netlink.c | 3 +++
7 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 7794a2e..99d68c3 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -1002,7 +1002,8 @@ static int l2cap_sock_connect(struct socket *sock, struct sockaddr *addr, int al
 
 	BT_DBG("sk %p", sk);
 
-	if (!addr || addr->sa_family != AF_BLUETOOTH)
+	if (!addr || alen < sizeof(addr->sa_family) ||
+	    addr->sa_family != AF_BLUETOOTH)
 		return -EINVAL;
 
 	memset(&la, 0, sizeof(la));
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index 7f43976..8ed3c37 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -397,7 +397,8 @@ static int rfcomm_sock_connect(struct socket *sock, struct sockaddr *addr, int a
 
 	BT_DBG("sk %p", sk);
 
-	if (addr->sa_family != AF_BLUETOOTH || alen < sizeof(struct sockaddr_rc))
+	if (alen < sizeof(struct sockaddr_rc) ||
+	    addr->sa_family != AF_BLUETOOTH)
 		return -EINVAL;
 
 	lock_sock(sk);
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index e5b16b7..ca6b2ad 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -499,7 +499,8 @@ static int sco_sock_connect(struct socket *sock, struct sockaddr *addr, int alen
 
 	BT_DBG("sk %p", sk);
 
-	if (addr->sa_family != AF_BLUETOOTH || alen < sizeof(struct sockaddr_sco))
+	if (alen < sizeof(struct sockaddr_sco) ||
+	    addr->sa_family != AF_BLUETOOTH)
 		return -EINVAL;
 
 	if (sk->sk_state != BT_OPEN && sk->sk_state != BT_BOUND)
diff --git a/net/can/bcm.c b/net/can/bcm.c
index a2dee52..907dc87 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -1479,6 +1479,9 @@ static int bcm_connect(struct socket *sock, struct sockaddr *uaddr, int len,
 	struct sock *sk = sock->sk;
 	struct bcm_sock *bo = bcm_sk(sk);
 
+	if (len < sizeof(*addr))
+		return -EINVAL;
+
 	if (bo->bound)
 		return -EISCONN;
 
diff --git a/net/ieee802154/af_ieee802154.c b/net/ieee802154/af_ieee802154.c
index 79886d5..c7da600 100644
--- a/net/ieee802154/af_ieee802154.c
+++ b/net/ieee802154/af_ieee802154.c
@@ -127,6 +127,9 @@ static int ieee802154_sock_connect(struct socket *sock, struct sockaddr *uaddr,
 {
 	struct sock *sk = sock->sk;
 
+	if (addr_len < sizeof(uaddr->sa_family))
+		return -EINVAL;
+
 	if (uaddr->sa_family == AF_UNSPEC)
 		return sk->sk_prot->disconnect(sk, flags);
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index be1a6ac..a0beb32 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -531,6 +531,8 @@ int inet_dgram_connect(struct socket *sock, struct sockaddr * uaddr,
 {
 	struct sock *sk = sock->sk;
 
+	if (addr_len < sizeof(uaddr->sa_family))
+		return -EINVAL;
 	if (uaddr->sa_family == AF_UNSPEC)
 		return sk->sk_prot->disconnect(sk, flags);
 
@@ -574,6 +576,9 @@ int inet_stream_connect(struct socket *sock, struct sockaddr *uaddr,
 	int err;
 	long timeo;
 
+	if (addr_len < sizeof(uaddr->sa_family))
+		return -EINVAL;
+
 	lock_sock(sk);
 
 	if (uaddr->sa_family == AF_UNSPEC) {
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 274d977..6464a19 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -683,6 +683,9 @@ static int netlink_connect(struct socket *sock, struct sockaddr *addr,
 	struct netlink_sock *nlk = nlk_sk(sk);
 	struct sockaddr_nl *nladdr = (struct sockaddr_nl *)addr;
 
+	if (alen < sizeof(addr->sa_family))
+		return -EINVAL;
+
 	if (addr->sa_family == AF_UNSPEC) {
 		sk->sk_state	= NETLINK_UNCONNECTED;
 		nlk->dst_pid	= 0;


