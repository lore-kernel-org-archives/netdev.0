From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Tue, 06 Sep 2011 22:19:48 +0200
Message-ID: <1315340388.3400.28.camel@edumazet-laptop>
References: <4E631032.6050606@intel.com>
	 <1315326326.2576.2980.camel@schen9-DESK>
	 <1315330805.2899.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1315335019.2576.3048.camel@schen9-DESK>
	 <1315335660.3400.7.camel@edumazet-laptop>
	 <1315337580.2576.3066.camel@schen9-DESK>
	 <1315338186.3400.20.camel@edumazet-laptop>
	 <1315339157.2576.3079.camel@schen9-DESK>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Yan, Zheng" <zheng.z.yan@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>,
	"sedat.dilek@gmail.com" <sedat.dilek@gmail.com>, alex.shi@intel.com
To: Tim Chen <tim.c.chen@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40918 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754903Ab1IFUUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2011 16:20:00 -0400
Received: by wwf5 with SMTP id 5so6667356wwf.1
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2011 13:19:59 -0700 (PDT)
In-Reply-To: <1315339157.2576.3079.camel@schen9-DESK>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 06 septembre 2011 =C3=A0 12:59 -0700, Tim Chen a =C3=A9crit :
> On Tue, 2011-09-06 at 21:43 +0200, Eric Dumazet wrote:
> > Le mardi 06 septembre 2011 =C3=A0 12:33 -0700, Tim Chen a =C3=A9cri=
t :
> >=20
> > > Yes, I think locking the sendmsg for the entire duration of
> > > unix_stream_sendmsg makes a lot of sense.  It simplifies the logi=
c a lot
> > > more.  I'll try to cook something up in the next couple of days.
> >=20
> > Thats not really possible, we cant hold a spinlock and call
> > sock_alloc_send_skb() and/or memcpy_fromiovec(), wich might sleep.
> >=20
> > You would need to prepare the full skb list, then :
> > - stick the ref on the last skb of the list.
> >=20
> > Transfert the whole skb list in other->sk_receive_queue in one go,
> > instead of one after another.
> >=20
> > Unfortunately, this would break streaming (big send(), and another
> > thread doing the receive)
> >=20
> > Listen, I am wondering why hackbench even triggers SCM code. This i=
s
> > really odd. We should not have a _single_ pid/cred ref/unref at all=
=2E
> >=20
>=20
> Hackbench triggers the code because it has a bunch of threads sending
> msgs on UNIX socket.
> >=20
>=20
> Well, if the lock socket approach doesn't work, then my original patc=
h
> plus Yan Zheng's fix should still work.  I'll try to answer your
> objections below:
>=20
>=20
> > I was discussing of things after proposed patch, not current net-ne=
xt.
> >=20
> > This reads :
> >=20
> > err =3D unix_scm_to_skb(siocb->scm, skb, !fds_sent, scm_ref);
> >=20
> > So first skb is sent without ref taken, as mentioned in Changelog ?
> >=20
>=20
> No. the first skb is sent *with* ref taken, as scm_ref is set to true=
 for
> first skb.
>=20
> >=20
> > If second skb cannot be built, we exit this system call with an alr=
eady
> > queued skb. Receiver can then access to freed memory.
> >=20
>=20
> No, we do have reference set.  For first skb, in unix_scm_to_skb.  Fo=
r the=20
> second skb (which is the last skb), in scm_sent.  Should the second s=
kb alloc failed,
> we'll release the ref in scm_destroy.  Otherwise, the receiver will r=
elease
> the references will consuming the skb.
>=20

This is crap. This is not the intent of the code I read from the patch.

unless scm_ref really means scm_noref ?

I really hate this patch. I mean it.=20

I read it 10 times, spent 2 hours and still dont understand it.


@@ -1577,6 +1577,7 @@ static int unix_stream_sendmsg(struct kiocb *kioc=
b, struct socket *sock,
        int sent =3D 0;
        struct scm_cookie tmp_scm;
        bool fds_sent =3D false;
+       bool scm_ref =3D true;
        int max_level;
=20
        if (NULL =3D=3D siocb->scm)
@@ -1637,12 +1638,15 @@ static int unix_stream_sendmsg(struct kiocb *ki=
ocb, struct socket *sock,
                 */
                size =3D min_t(int, size, skb_tailroom(skb));
=20
+               /* pass the scm reference to the very last skb */

HERE: I understand : on the last skb, set scm_ref to false.
So comment is wrong.

+               if (sent + size >=3D len)
+                       scm_ref =3D false;
=20
-               /* Only send the fds and no ref to pid in the first buf=
fer */
-               err =3D unix_scm_to_skb(siocb->scm, skb, !fds_sent, fds=
_sent);
+               /* Only send the fds in the first buffer */
+               err =3D unix_scm_to_skb(siocb->scm, skb, !fds_sent, scm=
_ref);
                if (err < 0) {
                        kfree_skb(skb);
-                       goto out;
+                       goto out_err;
                }



As I said, we should revert the buggy patch, and rewrite a performance
fix from scratch, with not a single get_pid()/put_pid() in fast path.

read()/write() on AF_UNIX sockets should not use a single
get_pid()/put_pid().

This is a serious regression we should fix at 100%, not 50% or even 75%=
,
adding serious bugs.
