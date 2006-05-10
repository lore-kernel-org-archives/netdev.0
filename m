From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: Dscape ieee80211: enabling/disabling the radio
Date: Wed, 10 May 2006 15:53:48 +0200
Message-ID: <200605101553.52031.IvDoorn@gmail.com>
References: <200605061401.01795.IvDoorn@gmail.com> <20060510124217.0d3810bd@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2347234.qsEeauaoaR";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Olivier <o.cornu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:52820 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S964963AbWEJNwK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 May 2006 09:52:10 -0400
Received: by nf-out-0910.google.com with SMTP id x29so828497nfb
        for <netdev@vger.kernel.org>; Wed, 10 May 2006 06:52:08 -0700 (PDT)
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060510124217.0d3810bd@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2347234.qsEeauaoaR
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 10 May 2006 12:42, Jiri Benc wrote:
> On Sat, 6 May 2006 14:00:58 +0200, Ivo van Doorn wrote:
> > In rt2x00 the config() handler schedules all configuration changes by u=
sing a workqueue,
> > this is required since several configuration changes in rt2x00 need sle=
eping and for
> > USB devices all register access requires sleeping. And the config() han=
dler is often
> > called from interrupt context so it complains a lot when the workqueue =
is not used.
> >=20
> > This seemed fine, untill the radio_enabled field was introduced to the =
configuration structure.
> > When the radio_enable field is set, the radio must be enabled, but enab=
ling
> > the radio is something that can (at least in rt2x00) fail. So schedulin=
g the enabling of the radio
> > to the workqueue is not something that is desired since the stack can n=
ot be notified that the
> > device is not able to enable the radio.
>=20
> This is probably more general problem. I can imagine a card that will
> need to sleep to switch channels and can fail. This doesn't matter now
> (as we cannot handle failure in switching channels) but it should be
> solved in some way.
>=20
> Currently, only switching channels is made in interrupt context. You can
> depend on this for now.
>=20
> > Moving the enabling of the radio outside the workqueue function and int=
o the config()
> > handler results in scheduling while atomic issues since the enabling of=
 the radio requires
> > sleeping for both PCI and USB devices.
>=20
> Or am I wrong? I see no place when radio_enabled is changed in interrupt =
context.

I think the problem is what the dscape exactly expects the driver to do when
add_interface() is called by the stack. When that call has finished, does t=
he stack
expects the radio to be enabled, or should it instruct the driver to enable=
 the radio later
on through a field in the config structure.

What currently happens in rt2x00 (Which might not be doing what the stack e=
xpects)
is that when add_interface() is called the radio remains off untill open() =
is called or
radio_enabled has been set in the config structure.
What happens is that the first call of config() (which is being made before=
 open()) comes
from the scan handler requesting a channel change, which is in interrupt co=
ntext, but
when the channel is changed, the radio is also supposed to be enabled which=
 results
in the problems of radio enabling requirement to be scheduled.

But this might be resolved by demanding that the driver is keeping track of=
 the number
of interfaces added, and enabling the radio when at least 1 interface has b=
een added
and only disable the radio when all interfaces have been removed. And compl=
etely
remove the open() and stop() handlers since they would only confuse matters.

> > Instead of using a config field radio_enabled, wouldn't it be better to=
 add 2 handlers
> > to the ieee80211_hw structure, something like enable_radio() and disabl=
e_radio()?
> > If these functions are called from normal context the dscape stack can =
still enable
> > and disable the radio whenever it is desired, and it is able to check t=
he return value
> > to see if the request has actually succeeded.
>=20
> I don't think this is the best idea. In such case we would need to move
> almost all the stuff from ieee80211_conf to separate functions. This is
> something we don't want.

True, but I actually meant that these 2 functions would replace the open() =
and stop() functions.
Which is not required if the above suggestion of the number of added interf=
aces counter
is applied to the drivers.

> > What I am wondering about afterwards is what exactly should happen when=
 the open()
> > and stop() handlers are being called? Because those are basicly intente=
d to enable
> > and stop the radio as well. I checked bcm43xx to see what they do, and =
they don't seem
> > to check the radio_enabled field, so I don't know what they do besides =
enabling the radio.
>=20
> open and stop callbacks are obsolete. They were replaced by
> add_interface and remove_interface callbacks and will be removed after
> drivers are converted to use the new callbacks.

Ah ok, I'll fix rt2x00 then to do the correct behaviour and no longer rely =
on open() and stop()
for the radio, and add the counter for the number of interfaces that are up=
 so the radio
will behave in the correct fashion. :)

Thanks.

Ivo

--nextPart2347234.qsEeauaoaR
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEYfBwaqndE37Em0gRAqLAAJ0U/RNrkSij2pvLh1HZOXKqSKGZBgCgyr3M
CfcVWDxZK+diP5v7JxRcM/o=
=JwEa
-----END PGP SIGNATURE-----

--nextPart2347234.qsEeauaoaR--
