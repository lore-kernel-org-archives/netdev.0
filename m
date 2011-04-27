From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [RFC PATCH] netlink: Increase netlink dump skb message size
Date: Wed, 27 Apr 2011 19:29:38 +0200
Message-ID: <1303925378.3166.99.camel@edumazet-laptop>
References: <20110425220157.2012.96707.stgit@gitlad.jf.intel.com>
	 <1303799597.2747.214.camel@edumazet-laptop>
	 <20110425.235600.104065244.davem@davemloft.net>
	 <43F901BD926A4E43B106BF17856F0755018DC497D4@orsmsx508.amr.corp.intel.com>
	 <1303834864.3358.58.camel@edumazet-laptop>
	 <4DB83A60.5040102@solarflare.com>
	 <1303921809.3166.90.camel@edumazet-laptop>
	 <43F901BD926A4E43B106BF17856F0755018DF59D32@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steve Hodgson <shodgson@solarflare.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47970 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756236Ab1D0R3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 13:29:42 -0400
Received: by wya21 with SMTP id 21so1437842wya.19
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2011 10:29:41 -0700 (PDT)
In-Reply-To: <43F901BD926A4E43B106BF17856F0755018DF59D32@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 27 avril 2011 =C3=A0 10:15 -0700, Rose, Gregory V a =C3=A9c=
rit :
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel=
=2Eorg]
> > On Behalf Of Eric Dumazet
> > Sent: Wednesday, April 27, 2011 9:30 AM
> > To: Steve Hodgson
> > Cc: Rose, Gregory V; David Miller; netdev@vger.kernel.org;
> > bhutchings@solarflare.com
> > Subject: Re: [RFC PATCH] netlink: Increase netlink dump skb message=
 size
> >=20
> > Le mercredi 27 avril 2011 =C3=A0 16:46 +0100, Steve Hodgson a =C3=A9=
crit :
> > > On 04/27/2011 04:24 PM, Eric Dumazet wrote:
> > > > Le mardi 26 avril 2011 =C3=A0 09:12 -0700, Rose, Gregory V a =C3=
=A9crit :
> > > >
> > > >> I'm fine with however you folks want to approach this, just gi=
ve me
> > some direction.
> > > >
> > > > I would just try following patch :
> > > >
> > >
> > > This allows the sfc driver to use 102 VFs, up from the current li=
mit of
> > > 45 VFs.
> > >
> > > It's unfortunate that this patch isn't sufficient to allow all 12=
7 VFs
> > > to be used, but whilst we wait for a new netlink api this is an
> > > improvement worth having.
> > >
> >=20
> > netlink recvmsg() supports MSG_PEEK so user would get the needed si=
ze of
> > its buffer before calling the real recvmsg()
> >=20
> > big blobs could be attached as skb fragments (up to 64Kbytes), but =
do we
> > really want this...
> [Greg Rose]=20
>=20
> I'm looking into an approach in which we make the get info dump for V=
=46s orthogonal to the set VF info, i.e. like this:
>=20
> To set VF info we would follow the current convention:
>=20
> # ip link set eth(x) vf (n) mac xx:xx:xx:xx:xx:xx
> # ip link set eth(x) vf (n) vlan (nnnn)
>=20
> To see VF info:
>=20
> # ip link show eth(x) vf (n)
>=20
> would show that VF's mac and vlan and could then be expanded in the f=
uture to display more information required for additional features that=
 users are asking for.
>=20
> The IFLA_VF_INFO dump would be moved out of the info dump for the phy=
sical function interface and would no longer be nested which would get =
rid of the need for huge amounts of buffer for info dumps on VFs.  The =
ip link show command for the PF would need to report the number of VFs =
currently allocated to the PF so that could fed into a script that loop=
s to show each VFs info.
>=20
> I think this approach would fix the problems we're looking at right n=
ow.
>=20

Hmm, if you look at "ip link ..." you'll see it dumps everything from
kernel and does the filter inside user command.

BTW "ip" uses a 16384 bytes buffer, not a 8192 bytes one.


$ strace -e trace=3Drecvmsg ip link
recvmsg(3, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0, groups=3D0=
0000000},
msg_iov(1)=3D[{"\340\3\0\0\20\0\2\0dR\270M\224s\0\0\0\0\4\3\1\0\0\0I\0\=
1\0
\0\0\0\0"..., 16384}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D 3000
recvmsg(3, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0, groups=3D0=
0000000},
msg_iov(1)=3D[{"\364\3\0\0\20\0\2\0dR\270M\224s\0\0\0\0\1\0\4\0\0\0C\24=
\1
\0\0\0\0\0"..., 16384}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D 302=
4
recvmsg(3, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0, groups=3D0=
0000000},
msg_iov(1)=3D[{"\34\4\0\0\20\0\2\0dR\270M\224s\0\0\0\0\1\0\7\0\0\0C\20\=
1\0
\0\0\0\0"..., 16384}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D 2104
recvmsg(3, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0, groups=3D0=
0000000},
msg_iov(1)=3D[{"\24\0\0\0\3\0\2\0dR\270M\224s\0\0\0\0\0\0\7\0\0\0C\20\1=
\0
\0\0\0\0"..., 16384}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D 20

=2E..


