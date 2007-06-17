From: Johannes Berg <johannes@sipsolutions.net>
Subject: wireless userspace MLME and generic netlink vs. multicast (was:
	Re: [Take 2] mac80211 IEEE802.11e/WMM code cleanup)
Date: Sun, 17 Jun 2007 14:03:51 +0200
Message-ID: <1182081831.23681.29.camel@johannes.berg>
References: <20070611085950.GA5540@mail.intel.com>
	 <200706161129.13782.flamingice@sourmilk.net>
	 <1182019869.9058.57.camel@johannes.berg>
	 <200706161516.16447.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-cnSohpizq01nHsi0itZT"
Cc: Zhu Yi <yi.zhu@intel.com>, linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	David Lamparter <lists@diac24.net>,
	Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>
To: Michael Wu <flamingice@sourmilk.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:49739 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758527AbXFQMD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jun 2007 08:03:58 -0400
In-Reply-To: <200706161516.16447.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-cnSohpizq01nHsi0itZT
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

[if you haven't seen the rest of the thread skip down to the =3D=3D=3D mark=
]

On Sat, 2007-06-16 at 15:16 -0700, Michael Wu wrote:

> > I don't think the implementation details are much of a problem. It's
> > just a bit of message bouncing which is trivial. Except of course when
> > you consider wext, but hey, no need to consider that for this discussio=
n
> > since you're proposing ditching wext completely. Not that I don't want
> > to ditch it, but people still use it and probably will. Heck, people
> > still use 'ifconfig'...
> >
> I'm not proposing to ditch wext completely. When did I say that?

You're saying that you want people to communicate directly with the
userspace MLME, so wext is out.

> It's a waste of time when nl80211 needs to be patched every time we want =
an=20
> additional command in the userspace MLME.

I actually see this as a benefit, that way the API gets some review...
Also, if you want to use a userspace library, that library will need
patching everytime you need an additional MLME command; if you don't
have any formal API then of course you don't have that problem but that
also means that all the applications aren't able to interoperate
properly.

It sounds to me like you're proposing that wpa_supplicant is the only
supported userspace MLME and that wpa_cli is the only way to configure
it, basically. I sure hope that isn't so.

> I don't think the needs of a firmware based MLME are necessarily the same=
 as a=20
> userspace MLME. Some commands will certainly be the same, but just becaus=
e=20
> the commands are there doesn't mean it's good to make them work if you ha=
ve=20
> to fake it. The kernel should show what the hardware/stack can do and not=
hing=20
> more.

No, you don't understand. Of course something should tell you what your
wireless connection can do. But if there's a userspace MLME used to
implement that wireless connection then that userspace MLME tells you
what it can do, which is fine.

Saying that it's not good to make commands work is like saying every
tiny hardware difference should get new API to perfectly match that
particular hardware instead of using common API to work with all
hardware in a unified way.

That's the goal here anyway, to work with hardware in a unified way. And
hopefully there'll be more userspace MLMEs rather than just
wpa_supplicant. There's xsupplicant too, maybe it'll have some support,
who knows.

[=3D=3D=3D]

Yes, talking with the userspace MLME via netlink is some form of IPC. In
fact, I just had this idea that instead of having the kernel bounce
messages to the userspace MLME we could instead have a MLME-multicast
group. The kernel listens on that multicast group and executes the
commands if no other program is listening on the group, and the
configuration programs simply multicast the configuration requests.
We'll have to sort out in userspace that we never have two MLMEs running
at the same time, but that is far less effort than trying to sort out
finding the MLME in userspace. It also lets us control the API.

At the same time, however, this doesn't seem to be implementable using
generic netlink right now because we cannot allow non-root users to
listen on the MLME-multicast group (this isn't actually possible for
normal netlink either right now because we need non-root users listening
on other groups, but that could be easily solved with a patch to give a
non-root group mask instead of a flag for the netlink code)

However, digging through the code it seems that generic netlink is a bit
weird with multicast anyway. Right now, what you do as a userspace
application is you ask for multicast on the generic netlink socket, but
you can then talk to multiple families. As far as I can tell that means
that you'll be receiving multicasts for ACPI events and for nl80211
events if they happen to use the same groups. I'd think that generic
netlink should be integrated a bit better and it should be possible to
sign up for groups within a family.

When then it also becomes possible to disallow certain groups for
non-root users, we should be able to solve the userspace MLME problem by
using a multicast group as above, I haven't tested it yet though.

johannes

--=-cnSohpizq01nHsi0itZT
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGdSMm/ETPhpq3jKURAgk0AJ9/ffT23Ie2gkh6qQZ/uWgexQxR8gCgiOiQ
DScmPzRpiUg0oQcfdd3WOe8=
=t22g
-----END PGP SIGNATURE-----

--=-cnSohpizq01nHsi0itZT--

