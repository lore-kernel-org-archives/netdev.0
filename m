From: Vegard Nossum <vegard.nossum@gmail.com>
Subject: [PATCH] net: fix setsockopt() locking errors
Date: Sat, 24 Jan 2009 23:49:30 +0100
Message-ID: <20090124224930.GA4456@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Martin =?utf-8?Q?MOKREJ=C5=A0?= <mmokrejs@ribosome.natur.cuni.cz>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f10.google.com ([209.85.219.10]:61183 "EHLO
	mail-ew0-f10.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751606AbZAXWyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jan 2009 17:54:19 -0500
Received: by ewy3 with SMTP id 3so272713ewy.13
        for <netdev@vger.kernel.org>; Sat, 24 Jan 2009 14:54:17 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This survives basic testing here, but I don't know what that counts for
when I couldn't reproduce the lockdep report in the first place. Please
review.


Vegard


=46rom cc8bcd1c4fd219a31d6d191aefa4b4b57dadb9b0 Mon Sep 17 00:00:00 200=
1
=46rom: Vegard Nossum <vegard.nossum@gmail.com>
Date: Sat, 24 Jan 2009 22:44:16 +0100
Subject: [PATCH] net: fix setsockopt() locking errors
MIME-Version: 1.0
Content-Type: text/plain; charset=3Dutf-8
Content-Transfer-Encoding: 8bit

Martin MOKREJ=C5=A0 <mmokrejs@ribosome.natur.cuni.cz> reported:
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> [ INFO: possible circular locking dependency detected ]
> 2.6.29-rc2-git1 #1
> -------------------------------------------------------
> tcpdump/3734 is trying to acquire lock:
>  (&mm->mmap_sem){----}, at: [<c1053294>] might_fault+0x30/0x6b
>
> but task is already holding lock:
>  (sk_lock-AF_PACKET){--..}, at: [<c12798c8>] sock_setsockopt+0x12b/0x=
4a4
>
> which lock already depends on the new lock.

It turns out that sock_setsockopt() is calling copy_from_user() while
holding the lock on the socket. We fix it by splitting the ioctl code
so that one switch handles the ioctls that have their own code for
reading from userspace, and one switch handles the cases that require
no additional reading.

Reported-by: Martin MOKREJ=C5=A0 <mmokrejs@ribosome.natur.cuni.cz>
Signed-off-by: Vegard Nossum <vegard.nossum@gmail.com>
---
 net/core/sock.c |  134 +++++++++++++++++++++++++++++++++++------------=
-------
 1 files changed, 87 insertions(+), 47 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index f3a0d08..6bd618d 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -424,6 +424,80 @@ out:
 	return ret;
 }
=20
+static int sock_linger(struct sock *sk, char __user *optval, int optle=
n)
+{
+	struct linger ling;
+
+	if (optlen < sizeof(ling))
+		return -EINVAL; /* 1003.1g */
+	if (copy_from_user(&ling, optval, sizeof(ling)))
+		return -EFAULT;
+
+	lock_sock(sk);
+
+	if (!ling.l_onoff)
+		sock_reset_flag(sk, SOCK_LINGER);
+	else {
+#if (BITS_PER_LONG =3D=3D 32)
+		if ((unsigned int) ling.l_linger >=3D MAX_SCHEDULE_TIMEOUT/HZ)
+			sk->sk_lingertime =3D MAX_SCHEDULE_TIMEOUT;
+		else
+#endif
+			sk->sk_lingertime =3D (unsigned int) ling.l_linger * HZ;
+		sock_set_flag(sk, SOCK_LINGER);
+	}
+
+	release_sock(sk);
+
+	return 0;
+}
+
+static int sock_set_rcvtimeo(struct sock *sk, char __user *optval, int=
 optlen)
+{
+	int ret;
+	long rcvtimeo;
+
+	ret =3D sock_set_timeout(&rcvtimeo, optval, optlen);
+
+	lock_sock(sk);
+	sk->sk_rcvtimeo =3D rcvtimeo;
+	release_sock(sk);
+
+	return ret;
+}
+
+static int sock_set_sndtimeo(struct sock *sk, char __user *optval, int=
 optlen)
+{
+	int ret;
+	long sndtimeo;
+
+	ret =3D sock_set_timeout(&sndtimeo, optval, optlen);
+
+	lock_sock(sk);
+	sk->sk_sndtimeo =3D sndtimeo;
+	release_sock(sk);
+
+	return ret;
+}
+
+static int sock_attach_filter(struct sock *sk, char __user *optval, in=
t optlen)
+{
+	int ret;
+	struct sock_fprog fprog;
+
+	if (optlen !=3D sizeof(struct sock_fprog))
+		return -EINVAL;
+
+	if (copy_from_user(&fprog, optval, sizeof(fprog)))
+		return -EFAULT;
+
+	lock_sock(sk);
+	ret =3D sk_attach_filter(&fprog, sk);
+	release_sock(sk);
+
+	return ret;
+}
+
 static inline void sock_valbool_flag(struct sock *sk, int bit, int val=
bool)
 {
 	if (valbool)
@@ -440,18 +514,27 @@ static inline void sock_valbool_flag(struct sock =
*sk, int bit, int valbool)
 int sock_setsockopt(struct socket *sock, int level, int optname,
 		    char __user *optval, int optlen)
 {
-	struct sock *sk=3Dsock->sk;
+	struct sock *sk =3D sock->sk;
 	int val;
 	int valbool;
-	struct linger ling;
 	int ret =3D 0;
=20
 	/*
-	 *	Options without arguments
+	 * Options with special locking requirements
 	 */
=20
-	if (optname =3D=3D SO_BINDTODEVICE)
+	switch (optname) {
+	case SO_BINDTODEVICE:
 		return sock_bindtodevice(sk, optval, optlen);
+	case SO_LINGER:
+		return sock_linger(sk, optval, optlen);
+	case SO_RCVTIMEO:
+		return sock_set_rcvtimeo(sk, optval, optlen);
+	case SO_SNDTIMEO:
+		return sock_set_sndtimeo(sk, optval, optlen);
+	case SO_ATTACH_FILTER:
+		return sock_attach_filter(sk, optval, optlen);
+	}
=20
 	if (optlen < sizeof(int))
 		return -EINVAL;
@@ -573,28 +656,6 @@ set_rcvbuf:
 			ret =3D -EPERM;
 		break;
=20
-	case SO_LINGER:
-		if (optlen < sizeof(ling)) {
-			ret =3D -EINVAL;	/* 1003.1g */
-			break;
-		}
-		if (copy_from_user(&ling,optval,sizeof(ling))) {
-			ret =3D -EFAULT;
-			break;
-		}
-		if (!ling.l_onoff)
-			sock_reset_flag(sk, SOCK_LINGER);
-		else {
-#if (BITS_PER_LONG =3D=3D 32)
-			if ((unsigned int)ling.l_linger >=3D MAX_SCHEDULE_TIMEOUT/HZ)
-				sk->sk_lingertime =3D MAX_SCHEDULE_TIMEOUT;
-			else
-#endif
-				sk->sk_lingertime =3D (unsigned int)ling.l_linger * HZ;
-			sock_set_flag(sk, SOCK_LINGER);
-		}
-		break;
-
 	case SO_BSDCOMPAT:
 		sock_warn_obsolete_bsdism("setsockopt");
 		break;
@@ -627,27 +688,6 @@ set_rcvbuf:
 		sk->sk_rcvlowat =3D val ? : 1;
 		break;
=20
-	case SO_RCVTIMEO:
-		ret =3D sock_set_timeout(&sk->sk_rcvtimeo, optval, optlen);
-		break;
-
-	case SO_SNDTIMEO:
-		ret =3D sock_set_timeout(&sk->sk_sndtimeo, optval, optlen);
-		break;
-
-	case SO_ATTACH_FILTER:
-		ret =3D -EINVAL;
-		if (optlen =3D=3D sizeof(struct sock_fprog)) {
-			struct sock_fprog fprog;
-
-			ret =3D -EFAULT;
-			if (copy_from_user(&fprog, optval, sizeof(fprog)))
-				break;
-
-			ret =3D sk_attach_filter(&fprog, sk);
-		}
-		break;
-
 	case SO_DETACH_FILTER:
 		ret =3D sk_detach_filter(sk);
 		break;
--=20
1.5.6.6

