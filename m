From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Thu, 08 Sep 2011 09:33:04 +0200
Message-ID: <1315467184.2532.22.camel@edumazet-laptop>
References: <4E631032.6050606@intel.com>
	 <1315326326.2576.2980.camel@schen9-DESK>
	 <1315330805.2899.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1315335019.2576.3048.camel@schen9-DESK>
	 <1315335660.3400.7.camel@edumazet-laptop>
	 <1315337580.2576.3066.camel@schen9-DESK>
	 <1315338186.3400.20.camel@edumazet-laptop>
	 <1315339157.2576.3079.camel@schen9-DESK>
	 <1315340388.3400.28.camel@edumazet-laptop>
	 <CAAM7YAn0c0SpAD42PcT+-HDXjT9HMajhmfZD6D68_0E21i2tSQ@mail.gmail.com>
	 <1315372100.3400.76.camel@edumazet-laptop> <4E66FF38.9000107@intel.com>
	 <1315381503.3400.85.camel@edumazet-laptop>
	 <1315396903.2364.23.camel@schen9-mobl>
	 <CA+icZUVqJVn4ONuSDV5YdgpEcmetVMM9X=Sxt2EqM8qdegMnjQ@mail.gmail.com>
	 <CA+icZUW5Biu8cMhaJcz=MwtMOVn-NFD92PTpT0-DfEDKrRmaUQ@mail.gmail.com>
	 <1315406256.6287.7.camel@schen9-mobl>  <4E680BF1.8000901@intel.com>
	 <1315429583.2361.3.camel@schen9-mobl>
	 <1315461572.2532.7.camel@edumazet-laptop>  <4E685F19.6030407@intel.com>
	 <1315465919.2532.19.camel@edumazet-laptop>  <4E686D71.30603@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tim Chen <tim.c.chen@linux.intel.com>,
	"sedat.dilek@gmail.com" <sedat.dilek@gmail.com>,
	"Yan, Zheng" <yanzheng@21cn.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>,
	"Shi, Alex" <alex.shi@intel.com>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
To: "Yan, Zheng" <zheng.z.yan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36246 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932140Ab1IHHdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2011 03:33:11 -0400
Received: by wwf5 with SMTP id 5so548637wwf.1
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2011 00:33:09 -0700 (PDT)
In-Reply-To: <4E686D71.30603@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 08 septembre 2011 =C3=A0 15:23 +0800, Yan, Zheng a =C3=A9crit =
:

> This code looks great, except "goto out;" is still there. I think we =
should replace it with "goto out_err;" :)
>=20

Indeed, you're right, thanks

 include/net/scm.h  |    9 ---------
 net/unix/af_unix.c |   32 +++++++++++++++++---------------
 2 files changed, 17 insertions(+), 24 deletions(-)

diff --git a/include/net/scm.h b/include/net/scm.h
index 68e1e48..2a5b42f 100644
--- a/include/net/scm.h
+++ b/include/net/scm.h
@@ -78,15 +78,6 @@ static __inline__ void scm_destroy(struct scm_cookie=
 *scm)
 		__scm_destroy(scm);
 }
=20
-static __inline__ void scm_release(struct scm_cookie *scm)
-{
-	/* keep ref on pid and cred */
-	scm->pid =3D NULL;
-	scm->cred =3D NULL;
-	if (scm->fp)
-		__scm_destroy(scm);
-}
-
 static __inline__ int scm_send(struct socket *sock, struct msghdr *msg=
,
 			       struct scm_cookie *scm)
 {
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index e6d9d10..c8a08ba 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1379,15 +1379,18 @@ static int unix_attach_fds(struct scm_cookie *s=
cm, struct sk_buff *skb)
 }
=20
 static int unix_scm_to_skb(struct scm_cookie *scm, struct sk_buff *skb=
,
-			   bool send_fds, bool ref)
+			   bool send_fds, bool steal_refs)
 {
 	int err =3D 0;
-	if (ref) {
+
+	if (!steal_refs) {
 		UNIXCB(skb).pid  =3D get_pid(scm->pid);
 		UNIXCB(skb).cred =3D get_cred(scm->cred);
 	} else {
 		UNIXCB(skb).pid  =3D scm->pid;
 		UNIXCB(skb).cred =3D scm->cred;
+		scm->pid =3D NULL;
+		scm->cred =3D NULL;
 	}
 	UNIXCB(skb).fp =3D NULL;
 	if (scm->fp && send_fds)
@@ -1454,7 +1457,7 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb=
, struct socket *sock,
 	if (skb =3D=3D NULL)
 		goto out;
=20
-	err =3D unix_scm_to_skb(siocb->scm, skb, true, false);
+	err =3D unix_scm_to_skb(siocb->scm, skb, true, true);
 	if (err < 0)
 		goto out_free;
 	max_level =3D err + 1;
@@ -1550,7 +1553,7 @@ restart:
 	unix_state_unlock(other);
 	other->sk_data_ready(other, len);
 	sock_put(other);
-	scm_release(siocb->scm);
+	scm_destroy(siocb->scm);
 	return len;
=20
 out_unlock:
@@ -1577,6 +1580,7 @@ static int unix_stream_sendmsg(struct kiocb *kioc=
b, struct socket *sock,
 	int sent =3D 0;
 	struct scm_cookie tmp_scm;
 	bool fds_sent =3D false;
+	bool steal_refs =3D false;
 	int max_level;
=20
 	if (NULL =3D=3D siocb->scm)
@@ -1638,11 +1642,14 @@ static int unix_stream_sendmsg(struct kiocb *ki=
ocb, struct socket *sock,
 		size =3D min_t(int, size, skb_tailroom(skb));
=20
=20
-		/* Only send the fds and no ref to pid in the first buffer */
-		err =3D unix_scm_to_skb(siocb->scm, skb, !fds_sent, fds_sent);
+		/* Only send the fds in first buffer
+		 * Last buffer can steal our references to pid/cred
+		 */
+		steal_refs =3D (sent + size >=3D len);
+		err =3D unix_scm_to_skb(siocb->scm, skb, !fds_sent, steal_refs);
 		if (err < 0) {
 			kfree_skb(skb);
-			goto out;
+			goto out_err;
 		}
 		max_level =3D err + 1;
 		fds_sent =3D true;
@@ -1650,7 +1657,7 @@ static int unix_stream_sendmsg(struct kiocb *kioc=
b, struct socket *sock,
 		err =3D memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
 		if (err) {
 			kfree_skb(skb);
-			goto out;
+			goto out_err;
 		}
=20
 		unix_state_lock(other);
@@ -1667,10 +1674,7 @@ static int unix_stream_sendmsg(struct kiocb *kio=
cb, struct socket *sock,
 		sent +=3D size;
 	}
=20
-	if (skb)
-		scm_release(siocb->scm);
-	else
-		scm_destroy(siocb->scm);
+	scm_destroy(siocb->scm);
 	siocb->scm =3D NULL;
=20
 	return sent;
@@ -1683,9 +1687,7 @@ pipe_err:
 		send_sig(SIGPIPE, current, 0);
 	err =3D -EPIPE;
 out_err:
-	if (skb =3D=3D NULL)
-		scm_destroy(siocb->scm);
-out:
+	scm_destroy(siocb->scm);
 	siocb->scm =3D NULL;
 	return sent ? : err;
 }
