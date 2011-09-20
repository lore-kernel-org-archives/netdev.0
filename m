From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] af_unix: dont send SCM_CREDENTIALS by
 default
Date: Tue, 20 Sep 2011 06:16:10 +0200
Message-ID: <1316492170.2455.43.camel@edumazet-laptop>
References: <1315488497.2456.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1315473888.2301.21.camel@schen9-mobl>
	 <1315544777.5410.19.camel@edumazet-laptop>
	 <20110918.210758.2207266633127640132.davem@davemloft.net>
	 <1316406528.2521.15.camel@edumazet-laptop>
	 <1316444524.2539.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1316447547.2539.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1316468398.4680.6.camel@schen9-DESK>
	 <6030.1316484637@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tim Chen <tim.c.chen@linux.intel.com>,
	David Miller <davem@davemloft.net>, zheng.z.yan@intel.com,
	yanzheng@21cn.com, netdev@vger.kernel.org, sfr@canb.auug.org.au,
	jirislaby@gmail.com, sedat.dilek@gmail.com, alex.shi@intel.com
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63714 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850Ab1ITEQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2011 00:16:19 -0400
Received: by wwf22 with SMTP id 22so194394wwf.1
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2011 21:16:18 -0700 (PDT)
In-Reply-To: <6030.1316484637@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 19 septembre 2011 =C3=A0 22:10 -0400, Valdis.Kletnieks@vt.edu =
a
=C3=A9crit :
> On Mon, 19 Sep 2011 14:39:58 PDT, Tim Chen said:
> > Do we have to worry about the case where peer socket changes its fl=
ag
> > to SOCK_PASSCRED while packets are in flight?  If there isn't such
> > pathological use case, the patch looks fine to me.
>=20
> I wouldn't think so - if you're sending a packet, and retroactively t=
rying to
> change the flag and expect it to work, your program is too ugly to li=
ve.  After
> all, if the scheduler had cut off your timeslice and scheduledthe rec=
eiving
> process before you set the flag, that packet would be delivered and d=
one with
> anyhow, and no amount of wishing will set that flag on an already-del=
ivered
> packet.
>=20
> What *is* worth checking is that we DTRT if a process/thread is doing=
 a send on
> one CPU, and another process/thread with a shared file descriptor for=
 that
> socket is diddling the flag.  But if we just define it as "atomic op =
to change
> the flag and other observers get whatever value their CPU sees at tha=
t
> instant", I'm OK with that too.. ;)
>=20

Note : The man page does states :

"To receive a struct ucred message the SO_PASSCRED option  must  be
enabled  on  the socket."

But it doesnt say if the SO_PASSCRED option must be enabled before the
sender sends its message, or before receiver attempts to read it.

Once a message is queued on an unix socket, flipping SO_PASSCRED cant
change its content (adding or removing credentials), since sender might
already have disappeared.

So current code includes credentials in all sent messages, just in case
receiver actually fetch credentials.

There are probably programs that assume they can set SO_PASSCRED right
before calling recvmsg(). Are we taking risk to break them, or are we
gentle and provide a sysctl option to ease the transition, I dont
know...
