From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Tue, 06 Sep 2011 11:50:19 -0700
Message-ID: <1315335019.2576.3048.camel@schen9-DESK>
References: <4E631032.6050606@intel.com>
	 <1315326326.2576.2980.camel@schen9-DESK>
	 <1315330805.2899.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Yan, Zheng" <zheng.z.yan@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>,
	"sedat.dilek@gmail.com" <sedat.dilek@gmail.com>, alex.shi@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:36730 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752588Ab1IFSsD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Sep 2011 14:48:03 -0400
In-Reply-To: <1315330805.2899.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-09-06 at 19:40 +0200, Eric Dumazet wrote:
> Le mardi 06 septembre 2011 =C3=A0 09:25 -0700, Tim Chen a =C3=A9crit =
:
> > On Sun, 2011-09-04 at 13:44 +0800, Yan, Zheng wrote:
> > > Commit 0856a30409 (Scm: Remove unnecessary pid & credential refer=
ences
> > > in Unix socket's send and receive path) introduced a use-after-fr=
ee bug.
> > > It passes the scm reference to the first skb. Skb(s) afterwards m=
ay
> > > reference freed data structure because the first skb can be destr=
ucted
> > > by the receiver at anytime. The fix is by passing the scm referen=
ce to
> > > the very last skb.
> > >=20
> > > Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
> > > Reported-by: Jiri Slaby <jirislaby@gmail.com>
> > > ---
> >=20
> > Thanks for finding this bug in my original patch.  I've missed the =
case
> > where receiving side could have released the all the references to =
the
> > credential before the send side is using the credential again for
> > subsequent skbs in the stream, thus causing the problem we saw.  Ge=
tting
> > an extra reference for pid/credentials at the beginning of the stre=
am
> > and not getting reference for the last skb is the right approach.
> >=20
> > Thanks also to Sedat, Valdis and Jiri for their extensive testing t=
o
> > discover the bug and testing the subsequent fixes.=20
> >=20
> > Acked-by: Tim Chen <tim.c.chen@linux.intel.com>
>=20
> What happens if message must be split in two skb,
> first skb is built, queued (without scm reference)

An extra scm reference is already first obtained in scm_send at the
beginning of unix_stream_sendmsg in Yan Zheng's patch.  So things shoul=
d
be okay as long as we only use this extra reference we got in scm_send
for the last skb in unix_stream_sendmsg instead of the first skb.

>=20
> Second skb allocation fails.
>=20
> Rule about refs/norefs games is : As soon as you put skb into a list,=
 it
> should have all appropriate references if this skb has pointer(s) to
> objects(s)

All the skbs put on the list does have proper reference on pid/scm.  In
the example you give, the first skb got the reference at this line:

err =3D unix_scm_to_skb(siocb->scm, skb, !fds_sent, fds_sent);

the second skb use the reference already obtained at the beginning of
unix_stream_sendmsg if the skb allocation is successful:

err =3D scm_send(sock, msg, siocb->scm);

Now if the second skb allocation failed, the extra scm reference will b=
e
released by scm_destroy in the error handling path.

>=20
> We should revert 0856a304091b33a and code the thing differently.
>=20
> Instead of storing pointer to pid and cred in UNIXSKB(), why dont we
> copy all needed information ? No ref counts at all.
>=20
> skb->cb[] is large enough.
>=20

If we can simply copy some information over, that will be ideal and
will resolve all the scalability problems. =20

However, I don't see other obvious info that we can pass to avoid
passing pid.  Our current credential is pid and uid based, and requires
the knowledge of sender's pid to interpret uid to do credentials
checking.  So without passing the sender pid, I don't see an easy way
for the receive side to interpret sender uid it got, which is needed in
user_ns_map_uid function when we call cred_to_ucred. =20

I was trying to do minimal changes to gain some performance.  The
approach you suggest is great but will probably require much more
changes to the credentials infrastructure.  Or maybe there are some eas=
y
way to do it that I don't see.

Thanks.

Tim
