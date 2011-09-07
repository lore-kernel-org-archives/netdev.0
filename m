From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Wed, 07 Sep 2011 04:55:26 +0200
Message-ID: <1315364126.3400.64.camel@edumazet-laptop>
References: <4E631032.6050606@intel.com>
	 <1315326326.2576.2980.camel@schen9-DESK>
	 <1315330805.2899.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1315335019.2576.3048.camel@schen9-DESK>
	 <1315335660.3400.7.camel@edumazet-laptop>
	 <1315337580.2576.3066.camel@schen9-DESK>
	 <1315338186.3400.20.camel@edumazet-laptop>
	 <1315339157.2576.3079.camel@schen9-DESK>
	 <1315340388.3400.28.camel@edumazet-laptop>
	 <CAAM7YAnqLyK6JWPW_Y8wD=ykqWMn4fPdJ3_7yUUB+TQZWfDJzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tim Chen <tim.c.chen@linux.intel.com>,
	"Yan, Zheng" <zheng.z.yan@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>,
	"sedat.dilek@gmail.com" <sedat.dilek@gmail.com>, alex.shi@intel.com
To: "Yan, Zheng" <zheng.z.yan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62985 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753297Ab1IGCzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2011 22:55:39 -0400
Received: by wwf5 with SMTP id 5so6956430wwf.1
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2011 19:55:38 -0700 (PDT)
In-Reply-To: <CAAM7YAnqLyK6JWPW_Y8wD=ykqWMn4fPdJ3_7yUUB+TQZWfDJzQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 07 septembre 2011 =C3=A0 07:09 +0800, Yan, Zheng a =C3=A9cr=
it :
> On Wed, Sep 7, 2011 at 4:19 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> > Le mardi 06 septembre 2011 =C3=A0 12:59 -0700, Tim Chen a =C3=A9cri=
t :
> >> On Tue, 2011-09-06 at 21:43 +0200, Eric Dumazet wrote:
> >> > Le mardi 06 septembre 2011 =C3=A0 12:33 -0700, Tim Chen a =C3=A9=
crit :
> >> >
> >> > > Yes, I think locking the sendmsg for the entire duration of
> >> > > unix_stream_sendmsg makes a lot of sense.  It simplifies the l=
ogic a lot
> >> > > more.  I'll try to cook something up in the next couple of day=
s.
> >> >
> >> > Thats not really possible, we cant hold a spinlock and call
> >> > sock_alloc_send_skb() and/or memcpy_fromiovec(), wich might slee=
p.
> >> >
> >> > You would need to prepare the full skb list, then :
> >> > - stick the ref on the last skb of the list.
> >> >
> >> > Transfert the whole skb list in other->sk_receive_queue in one g=
o,
> >> > instead of one after another.
> >> >
> >> > Unfortunately, this would break streaming (big send(), and anoth=
er
> >> > thread doing the receive)
> >> >
> >> > Listen, I am wondering why hackbench even triggers SCM code. Thi=
s is
> >> > really odd. We should not have a _single_ pid/cred ref/unref at =
all.
> >> >
> >>
> >> Hackbench triggers the code because it has a bunch of threads send=
ing
> >> msgs on UNIX socket.
> >> >
> >>
> >> Well, if the lock socket approach doesn't work, then my original p=
atch
> >> plus Yan Zheng's fix should still work.  I'll try to answer your
> >> objections below:
> >>
> >>
> >> > I was discussing of things after proposed patch, not current net=
-next.
> >> >
> >> > This reads :
> >> >
> >> > err =3D unix_scm_to_skb(siocb->scm, skb, !fds_sent, scm_ref);
> >> >
> >> > So first skb is sent without ref taken, as mentioned in Changelo=
g ?
> >> >
> >>
> >> No. the first skb is sent *with* ref taken, as scm_ref is set to t=
rue for
> >> first skb.
> >>
> >> >
> >> > If second skb cannot be built, we exit this system call with an =
already
> >> > queued skb. Receiver can then access to freed memory.
> >> >
> >>
> >> No, we do have reference set.  For first skb, in unix_scm_to_skb. =
 For the
> >> second skb (which is the last skb), in scm_sent.  Should the secon=
d skb alloc failed,
> >> we'll release the ref in scm_destroy.  Otherwise, the receiver wil=
l release
> >> the references will consuming the skb.
> >>
> >
> > This is crap. This is not the intent of the code I read from the pa=
tch.
> >
> > unless scm_ref really means scm_noref ?
> >
> > I really hate this patch. I mean it.
> >
> > I read it 10 times, spent 2 hours and still dont understand it.
> >
>=20
> Sorry, scm_ref means "sender hold a scm reference". I should add comm=
ent for it.

There is no "sender holds a scm reference" requirement.

The process is running, so holds a pid and cred by itself.

If pid/cred pointers are stuffed into skb->cb[], then each last skb mus=
t
holds its own reference to pid and cred.

Problem is : we dont know wich skb _is_ the last one, because we can
fail skb allocation or user->kernel copy any time.

Please David just revert 0856a304091b33a8e

I'll work today on a fix to performance regression added in 7361c36c
