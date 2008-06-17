From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] firmware: convert acenic driver to request_firmware()
Date: Tue, 17 Jun 2008 11:40:20 +0100
Message-ID: <1213699220.26255.977.camel@pmac.infradead.org>
References: <1213608300.26255.665.camel@pmac.infradead.org>
	 <4856CE43.4020706@garzik.org>
	 <1213652749.26255.842.camel@pmac.infradead.org>
	 <4856E50C.5050908@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jes Sorensen <jes@trained-monkey.org>, netdev@vger.kernel.org,
	jaswinder@infradead.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:50235 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752893AbYFQKk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 06:40:28 -0400
In-Reply-To: <4856E50C.5050908@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-06-16 at 18:11 -0400, Jeff Garzik wrote:
> An intermediate request_firmware() step is something that can go into=
 an=20
> upstream kernel _immediately_, without even needing firmware/ install=
=20
> infrastructure.

Not before 2.6.26, it can't -- it's much too late for that. And I'm
planning to ask Linus to take the 'make firmware_install' infrastructur=
e
as soon as the merge window opens for 2.6.27. So there's certainly no
need to separate them on _those_ grounds.

The parts which live in the Fedora kernel specfile to spit out the
kernel-firmware subpackage are also ready to get merged as soon as the
infrastructure is upstream.

> That, in turn, enables the ability to test a driver with externally=20
> loaded firmwares, while still being able to fall back to a known=20
> working, guaranteed present built-in firmware.
>=20
> IOW, the first step for each driver should be:
>=20
> +	request_firmware()
> +	if (success)
> +		use externally-loaded firmware
> +	else
> 		use built-in firmware
>=20
> and that's it.  Nothing else [in the first patch].

If it were that simple, I would agree with you. In practice, it hasn't
turned out to be that simple. I really do think it would be
counter-productive for both review and testing purposes.=20

=46or review because, as I said, we'd end up providing new copies of
certain functions in the first patch (or conditional noise in them), an=
d
then ripping out the old code path in the second -- the patch which it
would make sense to _read_ and review would be the combined one.

=46or testing because there's quite a large chance that if something go=
es
wrong with the request_firmware() path, it'd fall back to the other pat=
h
and people would say "OK, that works" when it doesn't. And we both know
that kind of thing will still happen even if we have a bloody great
warning printk in the fallback case.

I suppose what we _could_ do is make your 'use built-in firmware' path
use that firmware in the _same_ form as we have it provided by
request_firmware(). That way, we really are testing the same code path.
Would that meet your approval?

If you look closely, you'll see that that is exactly what I've done
already. But without the complexity in the driver -- the driver just
calls request_firmware(), and the firmware is either provided from
within the kernel image, or from userspace.

> While I'm on the subject, I think the most user-friendly,=20
> developer-friendly, and time-friendly ordering is
>=20
> 0) prepare kernel-firmware package with extracted firmwares from kern=
el=20
> tree, and have it available in rawhide, cooker, opensuse-devel, etc.
>=20
> 1) what I said above: request_firmware() for every driver
>=20
> At this point, users have udev-loadable firmware in hand and a driver=
=20
> capable of loading said firmware, and can immediately start operating=
 in=20
> the desired environment.
>=20
> 2) start peeling built-in firmwares out of the C source

Why would you insist that we support request_firmware() in _every_
driver, before we _depend_ on it in any? That doesn't seem to make a lo=
t
of sense. Especially since we already _have_ a whole bunch of drivers
which _depend_ on request_firmware().

Would you suggest that we shouldn't have drivers like myri10ge dependin=
g
on request_firmware(), just because the tg3 driver still doesn't have
that option?

Each driver stands alone, and can just be converted in one step.

> What I think you don't get is that moving the firmware out of the dri=
ver=20
> is the _easy_ part that comes _last_.
>=20
> The core problem with request_firmware() loading external firmwares i=
s=20
> usability:  the user damn well needs to have their firmware available=
,=20
> otherwise their hardware doesn't work.
>=20
> That means the pressure is on you to have all the elements in place w=
ith=20
> all the major distros _before_ you do the easy part.

=46irstly, distributions already _have_ all the elements in place for
loading firmware, and even for including it in the initrd as necessary.
It's not as if we're making them cope with something new and exciting.
So there should be no particular concern on that front. All they need t=
o
do is put the firmware into /lib/firmware.

Secondly, we are still allowing people to build firmware into the kerne=
l
-- we're not _forcing_ them to use udev or initrds at all. So it really
isn't hard for them to cope with the transition. at all.

> Otherwise the user experience is going to suck, the last thing we all=
=20
> want...

I've given a lot of thought to how the transition affects userspace,
have implemented the Fedora packaging side of it and spoken to some of
the people who would take the brunt of the users' displeasure if it goe=
s
wrong. And I didn't reach the same conclusions you did.

> The truth of the matter is, the user really does want to set that=20
> Kconfig option, during the initial time period after your patches are=
=20
> applied.

They shouldn't need to do that. "make firmware_install" works right now=
,
and the rest of the infrastructure is _already_ in place and actively
used by a lot of other drivers.

> Once things settled down and infrastructure is in place, the 'default=
 y'=20
> could go away.

=46or distributions it doesn't matter; it'll get dealt with properly.
=46edora is already ready; other distributions shouldn't find it hard t=
o
do the same when they update their kernel to 2.6.27.

=46or individuals, they either need to run 'make firmware_install' or
build the firmware in. Preferably the former, which is why we've put
"Say 'N'" in the help texts for these options.

Perhaps we could put a big reminder in the final output for the
modules_install or vmlinux targets, saying:
	You need to run 'make firmware_install'

I don't think it's a particularly valid concern, though.

> >> 3) there are enough changes to warrant a requirement of a "driver =
still=20
> >> works" test before going in, IMO
> >=20
> > Most definitely. As I said, I've been very careful to ensure that t=
he
> > converted firmware is correct, in conjunction with the driver chang=
es
> > (like the endianness considerations in this case). But that is no
> > substitute for testing.
>=20
> Cool :)

I'm sorry, perhaps I misspoke. I don't actually plan to hold off on
merging patches until I've got positive testing results for each and
every one, although obviously I'd like to. It's just not practical,
though. For some things, like Ambassador ATM cards, I'm not even sure
anyone still _has_ the hardware. And the changes are, for the most part=
,
Obviously Correct=E2=84=A2 janitorial-style stuff.

But I am actively trying to get people to test these patches on real
hardware, and would be very _happy_ if they were tested before they go
in. That's one of the reasons they're in linux-next already.

And because they _don't_ automatically fall back to the old code paths,
I know that a success report in linux-next is a success report for the
changes we've made.

--=20
dwmw2

