From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: Dscape ieee80211: enabling/disabling the radio
Date: Wed, 10 May 2006 00:01:16 +0200
Message-ID: <200605100001.20180.IvDoorn@gmail.com>
References: <200605061401.01795.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3048860.zQdaEovpmV";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:7499 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1750746AbWEIV7m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 May 2006 17:59:42 -0400
Received: by nf-out-0910.google.com with SMTP id b2so1291604nfe
        for <netdev@vger.kernel.org>; Tue, 09 May 2006 14:59:40 -0700 (PDT)
To: netdev@vger.kernel.org, Olivier <o.cornu@gmail.com>
In-Reply-To: <200605061401.01795.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3048860.zQdaEovpmV
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

> While working on the rt2x00 driver, I keep hitting against some problems =
with scanning.
> Basicly the dscape stack handles scanning in 2 ways, through the
> passive_scan() handler in the ieee80211_hw structure, and by calling
> the config() handler in the ieee80211_hw stucture.
>=20
> The usage of the first handler, does not give any problems at this time.
> The main source of problems during scanning in rt2x00 seems to come
> when the config() handler is used.
>=20
> In rt2x00 the config() handler schedules all configuration changes by usi=
ng a workqueue,
> this is required since several configuration changes in rt2x00 need sleep=
ing and for
> USB devices all register access requires sleeping. And the config() handl=
er is often
> called from interrupt context so it complains a lot when the workqueue is=
 not used.
>=20
> This seemed fine, untill the radio_enabled field was introduced to the co=
nfiguration structure.
> When the radio_enable field is set, the radio must be enabled, but enabli=
ng
> the radio is something that can (at least in rt2x00) fail. So scheduling =
the enabling of the radio
> to the workqueue is not something that is desired since the stack can not=
 be notified that the
> device is not able to enable the radio.
>=20
> Moving the enabling of the radio outside the workqueue function and into =
the config()
> handler results in scheduling while atomic issues since the enabling of t=
he radio requires
> sleeping for both PCI and USB devices.
>=20
> Instead of using a config field radio_enabled, wouldn't it be better to a=
dd 2 handlers
> to the ieee80211_hw structure, something like enable_radio() and disable_=
radio()?
> If these functions are called from normal context the dscape stack can st=
ill enable
> and disable the radio whenever it is desired, and it is able to check the=
 return value
> to see if the request has actually succeeded.
>=20
> What I am wondering about afterwards is what exactly should happen when t=
he open()
> and stop() handlers are being called? Because those are basicly intented =
to enable
> and stop the radio as well. I checked bcm43xx to see what they do, and th=
ey don't seem
> to check the radio_enabled field, so I don't know what they do besides en=
abling the radio.
>=20
> Well this was just some stuff I have been trying to figure out while tryi=
ng to solve several
> rt2x00 bugs... ;)

A user on the forums Olivier Cornu (added to the CC list) has done some inv=
estigation into the
scanning behaviour of the dscape stack.
Basicly the dscape stack is performing active scanning while the device is =
down,
but during the active scan it is sending packets out, or at least attemptin=
g to do so.
Besides the question if active scanning is preferred over passive scanning =
while interface is down,
active scanning fails because the packets that should be send are being sen=
d through the regular
xmit routines of the interface. (IFF_UP is not set for the interface)

This means that besides enabling the radio which should be done in the driv=
er, the stack should either bring
up the interface when doing an active scan, or resort to passive scanning w=
hile interface is down.

Ivo

--nextPart3048860.zQdaEovpmV
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEYREwaqndE37Em0gRAr4AAJ4kPqkElJMHKHoyWT6W2/4kdYkhMQCgnW5S
UEuC6e6OlQR+ielgZG3slNs=
=vhD7
-----END PGP SIGNATURE-----

--nextPart3048860.zQdaEovpmV--
