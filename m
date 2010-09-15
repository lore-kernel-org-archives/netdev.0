From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH] Phonet: hook resource routing to userspace via ioctl()'s
Date: Thu, 16 Sep 2010 01:30:12 +0300
Message-ID: <1284589815-28302-2-git-send-email-remi@remlab.net>
References: <d214bd6716258777ce8b1023208bc347@chewa.net>
 <1284589815-28302-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:36524 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753715Ab0IOWaR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 18:30:17 -0400
In-Reply-To: <1284589815-28302-1-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

I wish we could use something cleaner, such as bind(). But that would
not work since resource subscription is orthogonal/in addition to the
normal object ID allocated via bind(). This is similar to multicasting
which also uses ioctl()'s.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/linux/phonet.h |    2 ++
 net/phonet/datagram.c  |   13 +++++++++++++
 net/phonet/socket.c    |    1 +
 3 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/include/linux/phonet.h b/include/linux/phonet.h
index 76edadf..85e14a8 100644
--- a/include/linux/phonet.h
+++ b/include/linux/phonet.h
@@ -47,6 +47,8 @@
=20
 /* ioctls */
 #define SIOCPNGETOBJECT		(SIOCPROTOPRIVATE + 0)
+#define SIOCPNADDRESOURCE	(SIOCPROTOPRIVATE + 14)
+#define SIOCPNDELRESOURCE	(SIOCPROTOPRIVATE + 15)
=20
 /* Phonet protocol header */
 struct phonethdr {
diff --git a/net/phonet/datagram.c b/net/phonet/datagram.c
index 1bd38db..2f03238 100644
--- a/net/phonet/datagram.c
+++ b/net/phonet/datagram.c
@@ -52,6 +52,19 @@ static int pn_ioctl(struct sock *sk, int cmd, unsign=
ed long arg)
 		answ =3D skb ? skb->len : 0;
 		release_sock(sk);
 		return put_user(answ, (int __user *)arg);
+
+	case SIOCPNADDRESOURCE:
+	case SIOCPNDELRESOURCE: {
+			u32 res;
+			if (get_user(res, (u32 __user *)arg))
+				return -EFAULT;
+			if (res >=3D 256)
+				return -EINVAL;
+			if (cmd =3D=3D SIOCPNADDRESOURCE)
+				return pn_sock_bind_res(sk, res);
+			else
+				return pn_sock_unbind_res(sk, res);
+		}
 	}
=20
 	return -ENOIOCTLCMD;
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index 4c29a23..d4f41af 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -158,6 +158,7 @@ void pn_sock_unhash(struct sock *sk)
 	spin_lock_bh(&pnsocks.lock);
 	sk_del_node_init(sk);
 	spin_unlock_bh(&pnsocks.lock);
+	pn_sock_unbind_all_res(sk);
 }
 EXPORT_SYMBOL(pn_sock_unhash);
=20
--=20
1.7.0.4

