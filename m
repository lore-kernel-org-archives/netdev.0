From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Wed, 07 Sep 2011 05:01:43 -0700
Message-ID: <1315396903.2364.23.camel@schen9-mobl>
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
	 <1315372100.3400.76.camel@edumazet-laptop>  <4E66FF38.9000107@intel.com>
	 <1315381503.3400.85.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Yan, Zheng" <zheng.z.yan@intel.com>,
	"Yan, Zheng" <yanzheng@21cn.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>,
	"sedat.dilek@gmail.com" <sedat.dilek@gmail.com>,
	"Shi, Alex" <alex.shi@intel.com>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:57195 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756663Ab1IGTBp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Sep 2011 15:01:45 -0400
In-Reply-To: <1315381503.3400.85.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-09-07 at 09:45 +0200, Eric Dumazet wrote:
> Le mercredi 07 septembre 2011 =C3=A0 13:20 +0800, Yan, Zheng a =C3=A9=
crit :
>=20
> > Is code like this OK? Thanks
> > ---
> > 	if (sent + size < len) {=20
> > 		/* Only send the fds in the first buffer */
> > 		/* get additional ref if more skbs will be created */
> > 		err =3D unix_scm_to_skb(siocb->scm, skb, !fds_sent, true);
> > 	} else {
> > 		err =3D unix_scm_to_skb(siocb->scm, skb, !fds_sent, false);
> > 		ref_avail =3D false;
> > 	}
> >=20
> >=20
>=20
> Whats wrong with using ref_avail in the unix_scm_to_skb() call itself=
 ?
>=20
> something like :
>=20

Eric,

Your updated patch looks good when I tested it on my side.  It makes th=
e
patch much more readable.  If this patch looks good with you and Yan
Zheng, can you and Yan Zheng add your Signed-off-by to the patch?

Jiri, Sedat or Valdis, if you can verify that the patch fixed commit
0856a30409, that will be appreciated.

Eric, are you planning to do a fast path patch that doesn't do pid ref
for the case where CONFIG_PID_NS is not set?

Thanks.

Tim

---

Commit 0856a30409 (Scm: Remove unnecessary pid & credential references
in Unix socket's send and receive path) introduced a use-after-free bug=
=2E
The sent skbs from unix_stream_sendmsg could be consumed and destructed=
=20
by the receive side, removing all references to the credentials,=20
before the send side has finished sending out all=20
packets. However, send side could continue to consturct new packets in =
the=20
stream, using credentials that have lost its last reference and been
freed. =20

In this fix, we don't steal the reference to credentials we have obtain=
ed=20
in scm_send at beginning of unix_stream_sendmsg, till we've reached
the last packet.  This fixes the problem in commit 0856a30409.

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
Reported-by: Jiri Slaby <jirislaby@gmail.com>
Tested-by: Sedat Dilek <sedat.dilek@googlemail.com>
Tested-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
---

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 136298c..4a324a0 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1383,10 +1383,11 @@ static int unix_attach_fds(struct scm_cookie *s=
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
@@ -1458,7 +1459,7 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb=
, struct socket *sock,
 	if (skb =3D=3D NULL)
 		goto out;
=20
-	err =3D unix_scm_to_skb(siocb->scm, skb, true, false);
+	err =3D unix_scm_to_skb(siocb->scm, skb, true, true);
 	if (err < 0)
 		goto out_free;
 	max_level =3D err + 1;
@@ -1581,6 +1582,7 @@ static int unix_stream_sendmsg(struct kiocb *kioc=
b, struct socket *sock,
 	int sent =3D 0;
 	struct scm_cookie tmp_scm;
 	bool fds_sent =3D false;
+	bool steal_refs =3D false;
 	int max_level;
=20
 	if (NULL =3D=3D siocb->scm)
@@ -1642,8 +1644,11 @@ static int unix_stream_sendmsg(struct kiocb *kio=
cb, struct socket *sock,
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
 			goto out;
@@ -1671,7 +1676,7 @@ static int unix_stream_sendmsg(struct kiocb *kioc=
b, struct socket *sock,
 		sent +=3D size;
 	}
=20
-	if (skb)
+	if (steal_refs)
 		scm_release(siocb->scm);
 	else
 		scm_destroy(siocb->scm);
