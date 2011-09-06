From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Tue, 06 Sep 2011 21:01:00 +0200
Message-ID: <1315335660.3400.7.camel@edumazet-laptop>
References: <4E631032.6050606@intel.com>
	 <1315326326.2576.2980.camel@schen9-DESK>
	 <1315330805.2899.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1315335019.2576.3048.camel@schen9-DESK>
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
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64024 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753173Ab1IFTBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2011 15:01:11 -0400
Received: by wwf5 with SMTP id 5so6583999wwf.1
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2011 12:01:10 -0700 (PDT)
In-Reply-To: <1315335019.2576.3048.camel@schen9-DESK>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 06 septembre 2011 =C3=A0 11:50 -0700, Tim Chen a =C3=A9crit :
> On Tue, 2011-09-06 at 19:40 +0200, Eric Dumazet wrote:
> > Le mardi 06 septembre 2011 =C3=A0 09:25 -0700, Tim Chen a =C3=A9cri=
t :
> > > On Sun, 2011-09-04 at 13:44 +0800, Yan, Zheng wrote:
> > > > Commit 0856a30409 (Scm: Remove unnecessary pid & credential ref=
erences
> > > > in Unix socket's send and receive path) introduced a use-after-=
free bug.
> > > > It passes the scm reference to the first skb. Skb(s) afterwards=
 may
> > > > reference freed data structure because the first skb can be des=
tructed
> > > > by the receiver at anytime. The fix is by passing the scm refer=
ence to
> > > > the very last skb.
> > > >=20
> > > > Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
> > > > Reported-by: Jiri Slaby <jirislaby@gmail.com>
> > > > ---
> > >=20
> > > Thanks for finding this bug in my original patch.  I've missed th=
e case
> > > where receiving side could have released the all the references t=
o the
> > > credential before the send side is using the credential again for
> > > subsequent skbs in the stream, thus causing the problem we saw.  =
Getting
> > > an extra reference for pid/credentials at the beginning of the st=
ream
> > > and not getting reference for the last skb is the right approach.
> > >=20
> > > Thanks also to Sedat, Valdis and Jiri for their extensive testing=
 to
> > > discover the bug and testing the subsequent fixes.=20
> > >=20
> > > Acked-by: Tim Chen <tim.c.chen@linux.intel.com>
> >=20
> > What happens if message must be split in two skb,
> > first skb is built, queued (without scm reference)
>=20
> An extra scm reference is already first obtained in scm_send at the
> beginning of unix_stream_sendmsg in Yan Zheng's patch.  So things sho=
uld
> be okay as long as we only use this extra reference we got in scm_sen=
d
> for the last skb in unix_stream_sendmsg instead of the first skb.
>=20
> >=20
> > Second skb allocation fails.
> >=20
> > Rule about refs/norefs games is : As soon as you put skb into a lis=
t, it
> > should have all appropriate references if this skb has pointer(s) t=
o
> > objects(s)
>=20
> All the skbs put on the list does have proper reference on pid/scm.  =
In
> the example you give, the first skb got the reference at this line:
>=20
> err =3D unix_scm_to_skb(siocb->scm, skb, !fds_sent, fds_sent);

This is the current code. We know its buggy.

I was discussing of things after proposed patch, not current net-next.

This reads :

err =3D unix_scm_to_skb(siocb->scm, skb, !fds_sent, scm_ref);

So first skb is sent without ref taken, as mentioned in Changelog ?

If second skb cannot be built, we exit this system call with an already
queued skb. Receiver can then access to freed memory.

>=20
> the second skb use the reference already obtained at the beginning of
> unix_stream_sendmsg if the skb allocation is successful:
>=20
> err =3D scm_send(sock, msg, siocb->scm);
>=20
> Now if the second skb allocation failed, the extra scm reference will=
 be
> released by scm_destroy in the error handling path.
>=20
> >=20
> > We should revert 0856a304091b33a and code the thing differently.
> >=20
> > Instead of storing pointer to pid and cred in UNIXSKB(), why dont w=
e
> > copy all needed information ? No ref counts at all.
> >=20
> > skb->cb[] is large enough.
> >=20
>=20
> If we can simply copy some information over, that will be ideal and
> will resolve all the scalability problems. =20
>=20
> However, I don't see other obvious info that we can pass to avoid
> passing pid.  Our current credential is pid and uid based, and requir=
es
> the knowledge of sender's pid to interpret uid to do credentials
> checking.  So without passing the sender pid, I don't see an easy way
> for the receive side to interpret sender uid it got, which is needed =
in
> user_ns_map_uid function when we call cred_to_ucred. =20
>=20
> I was trying to do minimal changes to gain some performance.  The
> approach you suggest is great but will probably require much more
> changes to the credentials infrastructure.  Or maybe there are some e=
asy
> way to do it that I don't see.

My approach would basically revert the 7361c36c commit too :(

I am sorry, but the only way to avoid too many pid/cred references is t=
o
lock the socket [aka unix_state_lock(other);] for the whole send()
duration.

This way, you can really increment the pid/cred reference on the last
pushed skb, because no reader can 'catch first skb'

As soon as unix_state_unlock(other) is called, everything can happen, s=
o
skb must be self contained, as I stated in my earlier mail.
