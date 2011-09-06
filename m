From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Tue, 06 Sep 2011 12:59:17 -0700
Message-ID: <1315339157.2576.3079.camel@schen9-DESK>
References: <4E631032.6050606@intel.com>
	 <1315326326.2576.2980.camel@schen9-DESK>
	 <1315330805.2899.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1315335019.2576.3048.camel@schen9-DESK>
	 <1315335660.3400.7.camel@edumazet-laptop>
	 <1315337580.2576.3066.camel@schen9-DESK>
	 <1315338186.3400.20.camel@edumazet-laptop>
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
Received: from mga02.intel.com ([134.134.136.20]:6747 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752691Ab1IFT47 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Sep 2011 15:56:59 -0400
In-Reply-To: <1315338186.3400.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-09-06 at 21:43 +0200, Eric Dumazet wrote:
> Le mardi 06 septembre 2011 =C3=A0 12:33 -0700, Tim Chen a =C3=A9crit =
:
>=20
> > Yes, I think locking the sendmsg for the entire duration of
> > unix_stream_sendmsg makes a lot of sense.  It simplifies the logic =
a lot
> > more.  I'll try to cook something up in the next couple of days.
>=20
> Thats not really possible, we cant hold a spinlock and call
> sock_alloc_send_skb() and/or memcpy_fromiovec(), wich might sleep.
>=20
> You would need to prepare the full skb list, then :
> - stick the ref on the last skb of the list.
>=20
> Transfert the whole skb list in other->sk_receive_queue in one go,
> instead of one after another.
>=20
> Unfortunately, this would break streaming (big send(), and another
> thread doing the receive)
>=20
> Listen, I am wondering why hackbench even triggers SCM code. This is
> really odd. We should not have a _single_ pid/cred ref/unref at all.
>=20

Hackbench triggers the code because it has a bunch of threads sending
msgs on UNIX socket.
>=20

Well, if the lock socket approach doesn't work, then my original patch
plus Yan Zheng's fix should still work.  I'll try to answer your
objections below:


> I was discussing of things after proposed patch, not current net-next=
=2E
>=20
> This reads :
>=20
> err =3D unix_scm_to_skb(siocb->scm, skb, !fds_sent, scm_ref);
>=20
> So first skb is sent without ref taken, as mentioned in Changelog ?
>=20

No. the first skb is sent *with* ref taken, as scm_ref is set to true f=
or
first skb.

>=20
> If second skb cannot be built, we exit this system call with an alrea=
dy
> queued skb. Receiver can then access to freed memory.
>=20

No, we do have reference set.  For first skb, in unix_scm_to_skb.  For =
the=20
second skb (which is the last skb), in scm_sent.  Should the second skb=
 alloc failed,
we'll release the ref in scm_destroy.  Otherwise, the receiver will rel=
ease
the references will consuming the skb.

Tim
