From: Stuffed Crust <pizza@shaftnet.org>
Subject: Re: [RFC] cfg80211 and nl80211
Date: Thu, 5 Oct 2006 09:13:53 -0400
Message-ID: <20061005131353.GA3432@shaftnet.org>
References: <1159435399.2648.17.camel@ux156> <1159805711.2834.67.camel@localhost.localdomain> <1159947674.2817.19.camel@ux156> <1159971561.2817.87.camel@ux156> <1159984658.3287.98.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="82I3+IH0IqGh5yIs"
Cc: Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Jouni Malinen <jkm@devicescape.com>,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-73-230-86.se.biz.rr.com ([24.73.230.86]:14510 "EHLO
	shaft.shaftnet.org") by vger.kernel.org with ESMTP id S1751455AbWJENL7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 09:11:59 -0400
To: Dan Williams <dcbw@redhat.com>
Content-Disposition: inline
In-Reply-To: <1159984658.3287.98.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--82I3+IH0IqGh5yIs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 04, 2006 at 01:57:38PM -0400, Dan Williams wrote:
> * None
>     - Crypto: None
>     - 802.11 Auth: Open System
>=20
> * Static WEP
>     - Keys: up to 4 group keys
>     - Crypto: WEP-40, WEP-104, WEP-152, WEP-256
>     - 802.11 Auth: Open System or Shared Key
>     - Key Mgmt/Auth: none
>=20
> * Dynamic WEP (LEAP?)
>     - Keys: up to 4 group keys
>     - Crypto: WEP-40, WEP-104, WEP-152, WEP-256
>     - 802.11 Auth: Open System (only?)
>     - Key Mgmt/Auth: IEEE 802.1x with LEAP or EAP
>=20
> * WPA PSK
>     - Keys: pairwise & group
>     - Use WPA IEs
>     - 802.11 Auth: Open System
>     - Crypto: TKIP or CCMP
>     - Key Mgmt/Auth: WPA-PSK (elided 802.1x)
>=20
> * WPA Enterprise
>     - Keys: pairwise & group
>     - Use WPA IEs
>     - 802.11 Auth: Open System
>     - Crypto: TKIP or CCMP
>     - Key Mgmt/Auth: WPA-EAP (full 802.1x)
>=20
> * WPA2 PSK
>     - Keys: pairwise & group
>     - Use RSN IEs
>     - 802.11 Auth: Open System
>     - Crypto: TKIP or CCMP
>     - Key Mgmt/Auth: WPA-PSK (elided 802.1x)
>=20
> * WPA2 Enterprise
>     - Keys: pairwise & group
>     - Use RSN IEs
>     - 802.11 Auth: Open System
>     - Crypto: TKIP or CCMP
>     - Key Mgmt/Auth: WPA-EAP (full 802.1x)

This strikes me as overly complicated; to figure out what's necessary=20
you shoudn't be looking at the WEXT API -- The 802.11 standards are=20
all you need, and they lay things out fairly clearly, complete with=20
rx/tx path flowcharts.  :)

Essentially, you have two crypto paradigms, pre-802.11i and=20
post-802.11i.  (WPA uses the latter, and LEAP/CCX v1 is mostly the=20
former; newer ones use the latter)

(Leave out the RSNIE, AuthType and KeyMgmt stuff; while they're=20
 used in the actual key negotiation/derivation, they're separate=20
 problems and have no bearing on the crypto layer.  From the driver's=20
 perspective the RSNIE is just an opaque blob to be appended to=20
 beacons,presps and [re]assoc frames, KeyMgmt is purely a matter for=20
 the authenticator/supplicant, and AuthType is just a toggle that=20
 happens to be off for post-802.11i, although LEAP v1 adds some=20
 complications there..)

The old way:

* Four "default" keys. (used globally)
* PrivacyInvoked
* SetDefaultKeyIndex

The new way:

* PrivacyInvoked
* SetProtection (tx&|rx -- essentially "require crypto for a given macaddr)
* SetKeyMapping (one key per macaddr)

Each key has:

* Key type (WEP/TKIP/AES-CCMP/NONE)
* Key length (implied, but WEP can have varying key lengths)
* Key index (only '0' is generally used for unicast frames, but 802.11i=20
             requires use of simultaneous broadcast keys)
* Macaddr (ucast addr or broadcast aka pairwise vs group)
* RxSequence (mainly for bcast aka group keys)

It's fairly easy to implement the old stuff in terms of the new stuff,=20
if you assume that "if I don't have a per-sta key, just use the=20
global/bcast key".   The 802.11i rx/tx frame path flow handles the old=20
crypto style just fine.

=2E..Meanwhile.  It's foolish to ignore the 802.11 MLME.  It lists out
pretty much everything that's necessary to get a working connection, and
looking at its evolution (and changes in the pipeline) shows that it's
impossible to do it all (right) the first time, and that changes, not
just additions, will be necessary.

(Did I mention that I really like how the ALSA people manage this?  The=20
 userspace-kernelspace API is effectively private; apps write to the =20
 libs, which do the hard work of maintaining backwards compatibility as=20
 the internals change and get new features, but now I'm really just=20
 armchair quarterbacking, so I'll shut up now.)

> Wheee!  So you basically have a bunch of buckets and you just pull shit
> out of them at random, stick it all together, and you've got a wireless
> connection :)  Thank you, Cisco.  Thank you, Wi-Fi Alliance.

You forgot the part about sacrificing rubber chickens with pulleys=20
in the middle.  While hopping on one foot.  Under a new moon.=20

Bah, it's too early in the morning to be thinking about this stuff. =20

 - Solomon=20
--=20
Solomon Peachy        		       pizza at shaftnet dot org	=20
Melbourne, FL                          ^^ (mail/jabber/gtalk) ^^
Quidquid latine dictum sit, altum viditur.          ICQ: 1318344


--82I3+IH0IqGh5yIs
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.7 (GNU/Linux)

iD8DBQFFJQURPuLgii2759ARArfhAJ0YnLzgccO7U8V4KxOvNJf1drs5yACggKl9
gcYSBwuJH8PhoJJL9dctpmY=
=YxBA
-----END PGP SIGNATURE-----

--82I3+IH0IqGh5yIs--
