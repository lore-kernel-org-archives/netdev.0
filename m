From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] af_unix: dont send SCM_CREDENTIALS by
 default
Date: Mon, 28 Nov 2011 14:38:53 +0100
Message-ID: <1322487533.2292.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1315488497.2456.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	  <1315473888.2301.21.camel@schen9-mobl>
	  <1315544777.5410.19.camel@edumazet-laptop>
	  <20110918.210758.2207266633127640132.davem@davemloft.net>
	  <1316406528.2521.15.camel@edumazet-laptop>
	  <1316444524.2539.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	  <1316447547.2539.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	  <1316468398.4680.6.camel@schen9-DESK>
	  <6030.1316484637@turing-police.cc.vt.edu>
	 <1316492170.2455.43.camel@edumazet-laptop> <4ED38B39.5010206@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Valdis.Kletnieks@vt.edu, Tim Chen <tim.c.chen@linux.intel.com>,
	David Miller <davem@davemloft.net>, zheng.z.yan@intel.com,
	yanzheng@21cn.com, netdev@vger.kernel.org, sfr@canb.auug.org.au,
	jirislaby@gmail.com, sedat.dilek@gmail.com, alex.shi@intel.com
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:64352 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752652Ab1K1Ni5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 08:38:57 -0500
Received: by qadc14 with SMTP id c14so1124548qad.19
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 05:38:57 -0800 (PST)
In-Reply-To: <4ED38B39.5010206@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 novembre 2011 =C3=A0 14:23 +0100, Michal Schmidt a =C3=A9cr=
it :
> On 09/20/2011 06:16 AM, Eric Dumazet wrote:
> > Note : The man page does states :
> >
> > "To receive a struct ucred message the SO_PASSCRED option  must  be
> > enabled  on  the socket."
> >
> > But it doesnt say if the SO_PASSCRED option must be enabled before =
the
> > sender sends its message, or before receiver attempts to read it.
> >
> > Once a message is queued on an unix socket, flipping SO_PASSCRED ca=
nt
> > change its content (adding or removing credentials), since sender m=
ight
> > already have disappeared.
> >
> > So current code includes credentials in all sent messages, just in =
case
> > receiver actually fetch credentials.
> >
> > There are probably programs that assume they can set SO_PASSCRED ri=
ght
> > before calling recvmsg(). Are we taking risk to break them, or are =
we
> > gentle and provide a sysctl option to ease the transition, I dont
> > know...
>=20
> Such a case has just appeared:
> https://bugzilla.redhat.com/show_bug.cgi?id=3D757628
>=20
> systemd allows on-demand socket activation of services. It creates a=20
> listening socket without the SO_PASSCRED flag. When the first message=
=20
> arrives to the socket, systemd spawns the service and passes the=20
> socket's fd to it. The service sets SO_PASSCRED before actually=20
> receiving the message.
>=20
> I can fix that in systemd, but there may be more cases like this.


Yes, we were afraid of this.

Performance drop is really huge and deserves some fixes in userland...

People add features to kernel (in this case namespaces) without thinkin=
g
on performance regression. So poor guys like us have to "fix" things
later, in a reasonable way.
