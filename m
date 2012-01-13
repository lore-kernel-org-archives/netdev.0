From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Consequences of commit 16e5726269611b71c930054ffe9b858c1cea88eb
Date: Fri, 13 Jan 2012 06:50:47 +0100
Message-ID: <1326433847.2617.6.camel@edumazet-laptop>
References: <CAO+b5-pGcKbTYQWdWo=kbiQ2ORbgn8GAV_cfYjGzOARmgrsUxQ@mail.gmail.com>
	 <1326401943.2617.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Eric Paris <eparis@redhat.com>
To: Bart Van Assche <bvanassche@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:46867 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751559Ab2AMFuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 00:50:52 -0500
Received: by wibhm14 with SMTP id hm14so99391wib.19
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 21:50:51 -0800 (PST)
In-Reply-To: <1326401943.2617.0.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 12 janvier 2012 =C3=A0 21:59 +0100, Eric Dumazet a =C3=A9crit =
:
> Le jeudi 12 janvier 2012 =C3=A0 19:14 +0000, Bart Van Assche a =C3=A9=
crit :
> > Hi,
> >=20
> > If my analysis is correct commit
> > 16e5726269611b71c930054ffe9b858c1cea88eb ("af_unix: dont send
> > SCM_CREDENTIALS by default") changes the value of
> > NETLINK_CREDS(skb)->pid from the sender pid into zero. Does that me=
an
> > that the code using that construct did work in kernel 3.1 but that =
it
> > is broken in kernel 3.2 ? Should that commit be reverted or will
> > someone fix the code that uses NETLINK_CREDS() ? Would changing
> > NETLINK_CREDS(skb)->pid into NETLINK_CB(skb).pid be sufficient ?
> >=20
> > Thanks,
> >=20
> > Bart.
> >=20
> > $ git grep 'NETLINK_CREDS([a-zA-Z0-9_]*)->pid'
> > drivers/scsi/scsi_netlink.c:	pid =3D NETLINK_CREDS(skb)->pid;
> > kernel/audit.c:	pid  =3D NETLINK_CREDS(skb)->pid;
>=20
>=20
> What is your problem exactly ?
>=20
>=20

So the underlying question is : should netlink_sendmsg() always include
credentials of the sender, or should the sender use the right API for
that.

If we include a default credential, we still allow the sender to
override it.

Probably netlink is not performance sensitive so following patch could
address the problem ?

I am still not sure its really needed.

Comments ?

diff --git a/include/net/scm.h b/include/net/scm.h
index d456f4c..4af5f90 100644
--- a/include/net/scm.h
+++ b/include/net/scm.h
@@ -71,9 +71,13 @@ static __inline__ void scm_destroy(struct scm_cookie=
 *scm)
 }
=20
 static __inline__ int scm_send(struct socket *sock, struct msghdr *msg=
,
-			       struct scm_cookie *scm)
+			       struct scm_cookie *scm, bool populate)
 {
 	memset(scm, 0, sizeof(*scm));
+
+	if (populate)
+		scm_set_cred(scm, task_tgid(current), current_cred());
+
 	unix_get_peersec_dgram(sock, scm);
 	if (msg->msg_controllen <=3D 0)
 		return 0;
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 629b061..c040277 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1323,7 +1323,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, s=
truct socket *sock,
 	if (NULL =3D=3D siocb->scm)
 		siocb->scm =3D &scm;
=20
-	err =3D scm_send(sock, msg, siocb->scm);
+	err =3D scm_send(sock, msg, siocb->scm, true);
 	if (err < 0)
 		return err;
=20
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index aad8fb6..f788eb9 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1438,7 +1438,7 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb=
, struct socket *sock,
 	if (NULL =3D=3D siocb->scm)
 		siocb->scm =3D &tmp_scm;
 	wait_for_unix_gc();
-	err =3D scm_send(sock, msg, siocb->scm);
+	err =3D scm_send(sock, msg, siocb->scm, false);
 	if (err < 0)
 		return err;
=20
@@ -1599,7 +1599,7 @@ static int unix_stream_sendmsg(struct kiocb *kioc=
b, struct socket *sock,
 	if (NULL =3D=3D siocb->scm)
 		siocb->scm =3D &tmp_scm;
 	wait_for_unix_gc();
-	err =3D scm_send(sock, msg, siocb->scm);
+	err =3D scm_send(sock, msg, siocb->scm, false);
 	if (err < 0)
 		return err;
=20
