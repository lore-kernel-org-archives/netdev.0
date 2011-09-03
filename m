From: "Yan, Zheng " <yanzheng@21cn.com>
Subject: Re: [next] unix stream crashes
Date: Sat, 3 Sep 2011 20:30:19 +0800
Message-ID: <CAAM7YAkB3VVNMmBMVuvEZuV6oGZeyog37_sjFGUunu+15apvZA@mail.gmail.com>
References: <4E5FEF28.60406@gmail.com>
	<3179.1314924559@turing-police.cc.vt.edu>
	<1314927645.2576.2939.camel@schen9-DESK>
	<6805.1314979936@turing-police.cc.vt.edu>
	<1315007703.2576.2965.camel@schen9-DESK>
	<6043.1315028115@turing-police.cc.vt.edu>
	<CA+icZUVuJWpLquLk4kHJzmMKtPw24oxud=u3Na0U0HhSYqwV1w@mail.gmail.com>
	<4E61C7F2.3090902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sedat.dilek@gmail.com, Sedat Dilek <sedat.dilek@googlemail.com>,
	Valdis.Kletnieks@vt.edu, Tim Chen <tim.c.chen@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	ML netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:54726 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751083Ab1ICMaV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Sep 2011 08:30:21 -0400
In-Reply-To: <4E61C7F2.3090902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The skb can be destructed before the while loop in unix_stream_sendmsg =
stops.
please try below patch.

---
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index e6d9d10..f6d7ed7 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1577,6 +1577,7 @@ static int unix_stream_sendmsg(struct kiocb
*kiocb, struct socket *sock,
 	int sent =3D 0;
 	struct scm_cookie tmp_scm;
 	bool fds_sent =3D false;
+	bool scm_ref =3D true;
 	int max_level;

 	if (NULL =3D=3D siocb->scm)
@@ -1637,12 +1638,19 @@ static int unix_stream_sendmsg(struct kiocb
*kiocb, struct socket *sock,
 		 */
 		size =3D min_t(int, size, skb_tailroom(skb));

+		/*
+		 * pass the scm reference to the skb if a single skb is large
+		 * enough to hold all data.
+		 */
+		if (!fds_sent && sent + size >=3D len)
+			scm_ref =3D false;

-		/* Only send the fds and no ref to pid in the first buffer */
-		err =3D unix_scm_to_skb(siocb->scm, skb, !fds_sent, fds_sent);
+		/* Only send the fds in the first buffer */
+		err =3D unix_scm_to_skb(siocb->scm, skb, !fds_sent,
+					fds_sent || scm_ref);
 		if (err < 0) {
 			kfree_skb(skb);
-			goto out;
+			goto out_err;
 		}
 		max_level =3D err + 1;
 		fds_sent =3D true;
@@ -1650,7 +1658,7 @@ static int unix_stream_sendmsg(struct kiocb
*kiocb, struct socket *sock,
 		err =3D memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
 		if (err) {
 			kfree_skb(skb);
-			goto out;
+			goto out_err;
 		}

 		unix_state_lock(other);
@@ -1667,10 +1675,10 @@ static int unix_stream_sendmsg(struct kiocb
*kiocb, struct socket *sock,
 		sent +=3D size;
 	}

-	if (skb)
-		scm_release(siocb->scm);
-	else
+	if (scm_ref)
 		scm_destroy(siocb->scm);
+	else
+		scm_release(siocb->scm);
 	siocb->scm =3D NULL;

 	return sent;
@@ -1683,9 +1691,10 @@ pipe_err:
 		send_sig(SIGPIPE, current, 0);
 	err =3D -EPIPE;
 out_err:
-	if (skb =3D=3D NULL)
+	if (scm_ref)
 		scm_destroy(siocb->scm);
-out:
+	else
+		scm_release(siocb->scm);
 	siocb->scm =3D NULL;
 	return sent ? : err;
 }


On Sat, Sep 3, 2011 at 2:23 PM, Jiri Slaby <jirislaby@gmail.com> wrote:
> On 09/03/2011 07:54 AM, Sedat Dilek wrote:
>>
>> I saw similiar call-traces with put_cred_rcu() - besides with
>> kmem_cache_alloc_trace().
>> My post-it says:
>> Kernel panic - not syncing: CRED: put_cred_rcu sees f67ac0c0 with us=
age
>> -43
>
> Hm, Tim, it looks like you put a pid which you did not get?
>
> regards,
> --
> js
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>
