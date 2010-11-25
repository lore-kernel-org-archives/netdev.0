From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fwd: Simple kernel attack using socketpair. easy, 100%
 reproductiblle, works under guest. no way to protect :(
Date: Thu, 25 Nov 2010 15:11:39 +0100
Message-ID: <1290694299.2858.330.camel@edumazet-laptop>
References: <AANLkTikCeddPFRGojPGuB6oq3xGYgovtm8r4=WhjEDpe@mail.gmail.com>
	 <1290666501.2798.84.camel@edumazet-laptop>
	 <AANLkTik8Fxmd-KwGw498fMyONfVNteFcfCmz+9-V_QZh@mail.gmail.com>
	 <1290668246.2798.93.camel@edumazet-laptop>
	 <AANLkTinQa8BCH-k0m=ndu4u8L-kCiD00jYjKvsvoxK2E@mail.gmail.com>
	 <AANLkTin3SAdiRR4eda3SDdDV4XfKTqH5Z0a7Pih2O4jZ@mail.gmail.com>
	 <1290672978.2798.151.camel@edumazet-laptop>
	 <AANLkTi=NTFXXY42nh+j3xM4n-NTPaz=fWKmAY=MpsHze@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?=D0=9C=D0=B0=D1=80=D0=BA_?=
	 =?UTF-8?Q?=D0=9A=D0=BE=D1=80=D0=B5=D0=BD=D0=B1=D0=B5=D1=80=D0=B3?=
	<socketpair@gmail.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35264 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752460Ab0KYOLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 09:11:45 -0500
Received: by wyb28 with SMTP id 28so911716wyb.19
        for <netdev@vger.kernel.org>; Thu, 25 Nov 2010 06:11:44 -0800 (PST)
In-Reply-To: <AANLkTi=NTFXXY42nh+j3xM4n-NTPaz=fWKmAY=MpsHze@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 25 novembre 2010 =C3=A0 13:35 +0500, =D0=9C=D0=B0=D1=80=D0=BA =
=D0=9A=D0=BE=D1=80=D0=B5=D0=BD=D0=B1=D0=B5=D1=80=D0=B3 a =C3=A9crit :
> quick and dirty fix will be not to allow to pass unix socket inside
> unix socket. I think it would not break much applications.

Really, if it was not needed, net/unix/garbage.c would not exist at
all...

It is needed by some apps.


[PATCH] af_unix: limit recursion level

Its easy to eat all kernel memory and trigger NMI watchdog, using an
exploit program that queues unix sockets on top of others.

lkml ref : http://lkml.org/lkml/2010/11/25/8

This mechanism is used in applications, one choice we have is to have a
recursion limit.

Other limits might be needed as well (if we queue other types of files)=
,
since the passfd mechanism is currently limited by socket receive queue
sizes only.

Add a recursion_level to unix socket, allowing up to 4 levels.

Each time we send an unix socket through sendfd mechanism, we copy its
recursion level (plus one) to receiver. This recursion level is cleared
when socket receive queue is emptied.

Reported-by: =D0=9C=D0=B0=D1=80=D0=BA =D0=9A=D0=BE=D1=80=D0=B5=D0=BD=D0=
=B1=D0=B5=D1=80=D0=B3 <socketpair@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/af_unix.h |    2 ++
 net/unix/af_unix.c    |   37 ++++++++++++++++++++++++++++++++-----
 net/unix/garbage.c    |    2 +-
 3 files changed, 35 insertions(+), 6 deletions(-)

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 90c9e28..18e5c3f 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -10,6 +10,7 @@ extern void unix_inflight(struct file *fp);
 extern void unix_notinflight(struct file *fp);
 extern void unix_gc(void);
 extern void wait_for_unix_gc(void);
+extern struct sock *unix_get_socket(struct file *filp);
=20
 #define UNIX_HASH_SIZE	256
=20
@@ -56,6 +57,7 @@ struct unix_sock {
 	spinlock_t		lock;
 	unsigned int		gc_candidate : 1;
 	unsigned int		gc_maybe_cycle : 1;
+	unsigned char		recursion_level;
 	struct socket_wq	peer_wq;
 };
 #define unix_sk(__sk) ((struct unix_sock *)__sk)
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 3c95304..2268e67 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1343,9 +1343,25 @@ static void unix_destruct_scm(struct sk_buff *sk=
b)
 	sock_wfree(skb);
 }
=20
+#define MAX_RECURSION_LEVEL 4
+
 static int unix_attach_fds(struct scm_cookie *scm, struct sk_buff *skb=
)
 {
 	int i;
+	unsigned char max_level =3D 0;
+	int unix_sock_count =3D 0;
+
+	for (i =3D scm->fp->count - 1; i >=3D 0; i--) {
+		struct sock *sk =3D unix_get_socket(scm->fp->fp[i]);
+
+		if (sk) {
+			unix_sock_count++;
+			max_level =3D max(max_level,
+					unix_sk(sk)->recursion_level);
+		}
+	}
+	if (unlikely(max_level > MAX_RECURSION_LEVEL))
+		return -ETOOMANYREFS;
=20
 	/*
 	 * Need to duplicate file references for the sake of garbage
@@ -1356,9 +1372,11 @@ static int unix_attach_fds(struct scm_cookie *sc=
m, struct sk_buff *skb)
 	if (!UNIXCB(skb).fp)
 		return -ENOMEM;
=20
-	for (i =3D scm->fp->count-1; i >=3D 0; i--)
-		unix_inflight(scm->fp->fp[i]);
-	return 0;
+	if (unix_sock_count) {
+		for (i =3D scm->fp->count - 1; i >=3D 0; i--)
+			unix_inflight(scm->fp->fp[i]);
+	}
+	return max_level;
 }
=20
 static int unix_scm_to_skb(struct scm_cookie *scm, struct sk_buff *skb=
, bool send_fds)
@@ -1393,6 +1411,7 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb=
, struct socket *sock,
 	struct sk_buff *skb;
 	long timeo;
 	struct scm_cookie tmp_scm;
+	int max_level;
=20
 	if (NULL =3D=3D siocb->scm)
 		siocb->scm =3D &tmp_scm;
@@ -1431,8 +1450,9 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb=
, struct socket *sock,
 		goto out;
=20
 	err =3D unix_scm_to_skb(siocb->scm, skb, true);
-	if (err)
+	if (err < 0)
 		goto out_free;
+	max_level =3D err + 1;
 	unix_get_secdata(siocb->scm, skb);
=20
 	skb_reset_transport_header(skb);
@@ -1514,6 +1534,8 @@ restart:
 	if (sock_flag(other, SOCK_RCVTSTAMP))
 		__net_timestamp(skb);
 	skb_queue_tail(&other->sk_receive_queue, skb);
+	if (max_level > unix_sk(other)->recursion_level)
+		unix_sk(other)->recursion_level =3D max_level;
 	unix_state_unlock(other);
 	other->sk_data_ready(other, len);
 	sock_put(other);
@@ -1544,6 +1566,7 @@ static int unix_stream_sendmsg(struct kiocb *kioc=
b, struct socket *sock,
 	int sent =3D 0;
 	struct scm_cookie tmp_scm;
 	bool fds_sent =3D false;
+	int max_level;
=20
 	if (NULL =3D=3D siocb->scm)
 		siocb->scm =3D &tmp_scm;
@@ -1607,10 +1630,11 @@ static int unix_stream_sendmsg(struct kiocb *ki=
ocb, struct socket *sock,
=20
 		/* Only send the fds in the first buffer */
 		err =3D unix_scm_to_skb(siocb->scm, skb, !fds_sent);
-		if (err) {
+		if (err < 0) {
 			kfree_skb(skb);
 			goto out_err;
 		}
+		max_level =3D err + 1;
 		fds_sent =3D true;
=20
 		err =3D memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
@@ -1626,6 +1650,8 @@ static int unix_stream_sendmsg(struct kiocb *kioc=
b, struct socket *sock,
 			goto pipe_err_free;
=20
 		skb_queue_tail(&other->sk_receive_queue, skb);
+		if (max_level > unix_sk(other)->recursion_level)
+			unix_sk(other)->recursion_level =3D max_level;
 		unix_state_unlock(other);
 		other->sk_data_ready(other, size);
 		sent +=3D size;
@@ -1845,6 +1871,7 @@ static int unix_stream_recvmsg(struct kiocb *iocb=
, struct socket *sock,
 		unix_state_lock(sk);
 		skb =3D skb_dequeue(&sk->sk_receive_queue);
 		if (skb =3D=3D NULL) {
+			unix_sk(sk)->recursion_level =3D 0;
 			if (copied >=3D target)
 				goto unlock;
=20
diff --git a/net/unix/garbage.c b/net/unix/garbage.c
index c8df6fd..a2d99a5 100644
--- a/net/unix/garbage.c
+++ b/net/unix/garbage.c
@@ -96,7 +96,7 @@ static DECLARE_WAIT_QUEUE_HEAD(unix_gc_wait);
 unsigned int unix_tot_inflight;
=20
=20
-static struct sock *unix_get_socket(struct file *filp)
+struct sock *unix_get_socket(struct file *filp)
 {
 	struct sock *u_sock =3D NULL;
 	struct inode *inode =3D filp->f_path.dentry->d_inode;


