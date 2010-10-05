From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] caif: fix two caif_connect() bugs
Date: Tue, 05 Oct 2010 10:42:08 +0200
Message-ID: <1286268128.2796.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:57132 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753068Ab0JEImO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 04:42:14 -0400
Received: by fxm4 with SMTP id 4so225699fxm.19
        for <netdev@vger.kernel.org>; Tue, 05 Oct 2010 01:42:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

caif_connect() might dereference a netdevice after dev_put() it.

It also doesnt check dev_get_by_index() return value and could
dereference a NULL pointer.

Fix it, using RCU to avoid taking a reference.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 net/caif/caif_socket.c |   21 +++++++++++++++------
 1 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 8ce9047..4bf28f2 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -827,6 +827,7 @@ static int caif_connect(struct socket *sock, struct sockaddr *uaddr,
 	long timeo;
 	int err;
 	int ifindex, headroom, tailroom;
+	unsigned int mtu;
 	struct net_device *dev;
 
 	lock_sock(sk);
@@ -896,15 +897,23 @@ static int caif_connect(struct socket *sock, struct sockaddr *uaddr,
 		cf_sk->sk.sk_state = CAIF_DISCONNECTED;
 		goto out;
 	}
-	dev = dev_get_by_index(sock_net(sk), ifindex);
+
+	err = -ENODEV;
+	rcu_read_lock();
+	dev = dev_get_by_index_rcu(sock_net(sk), ifindex);
+	if (!dev) {
+		rcu_read_unlock();
+		goto out;
+	}
 	cf_sk->headroom = LL_RESERVED_SPACE_EXTRA(dev, headroom);
+	mtu = dev->mtu;
+	rcu_read_unlock();
+
 	cf_sk->tailroom = tailroom;
-	cf_sk->maxframe = dev->mtu - (headroom + tailroom);
-	dev_put(dev);
+	cf_sk->maxframe = mtu - (headroom + tailroom);
 	if (cf_sk->maxframe < 1) {
-		pr_warning("CAIF: %s(): CAIF Interface MTU too small (%d)\n",
-			__func__, dev->mtu);
-		err = -ENODEV;
+		pr_warning("CAIF: %s(): CAIF Interface MTU too small (%u)\n",
+			   __func__, mtu);
 		goto out;
 	}
 


