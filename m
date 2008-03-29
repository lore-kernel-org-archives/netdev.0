From: =?iso-8859-1?Q?Bj=F6rn?= Steinbrink <B.Steinbrink@gmx.de>
Subject: Re: Oops/Warning report for the week of March 28th 2008
Date: Sat, 29 Mar 2008 13:20:10 +0100
Message-ID: <20080329122010.GA10058@atjola.homenet>
References: <47ED3F1A.1090101@linux.intel.com> <alpine.LFD.1.00.0803281310480.14670@woody.linux-foundation.org> <alpine.LFD.1.00.0803281329340.14670@woody.linux-foundation.org> <20080328171407.ZZRA012@mailhub.coreip.homeip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:59837 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751047AbYC2MUP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Mar 2008 08:20:15 -0400
Content-Disposition: inline
In-Reply-To: <20080328171407.ZZRA012@mailhub.coreip.homeip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2008.03.28 17:16:42 -0400, Dmitry Torokhov wrote:
> On Fri, Mar 28, 2008 at 01:51:38PM -0700, Linus Torvalds wrote:
> >=20
> >=20
> > On Fri, 28 Mar 2008, Linus Torvalds wrote:
> > >=20
> > > Is there something obvious that I'm missing? I'd really like to s=
ee the=20
> > > whole posting that the oops came from. Do you save the originals =
or even=20
> > > just message ID's from the ones you pick from emails?
> >=20
> > Hmm. Definitely not from the kernel mailing list. I'm intrigued, wh=
ere did=20
> > that oops #5814 come from (picked a recent one at random)?
> >=20
> > The thing is recent, and oopses on "mutex_lock(dev->mutex)" in=20
> > input_release_device. In particular, the path *seems* to be this on=
e:
> >=20
> >   evdev_release ->
> >     evdev_ungrab ->
> >       input_release_device ->
> >         mutex_lock ->
> >           mutex_lock_nested ->
> >             __mutex_lock_common ->
> >               list_add_tail(&waiter.list, &lock->wait_list)
> >=20
> > where "lock->wait_list.prev" seems to be 0x6b6b6b6b6b6b6b6b, which =
is the=20
> > use-after-free poison pattern.
> >=20
> > (In fact, I think the access that actually oopses is when the=20
> > debug version of __list_add() does
> >=20
> > 	if (unlikely(prev->next !=3D next)) {
> >=20
> > because that "prev" pointer is crap).
> >=20
> > So it seems that when input_release_device() does:
> >=20
> > 	struct input_dev *dev =3D handle->dev;
> >=20
> > 	mutex_lock(&dev->mutex);
> >=20
> > the "dev" it uses has already been released. And this only shows up=
 as a=20
> > problem when you have slab debugging turned on (like the Fedora ker=
nels=20
> > do, thank you all Fedora guys).
> >=20
> > The odd thing is that I don't think any of this code has really cha=
nged=20
> > recently.=20
> >=20
>=20
> There is a patch from Pete that works around the problem by not
> calling input_release_device() on devices that are gone. But what
> I don't understand is why the parent input device is gone since
> sysfs/driver core should be keeping a reference to it since it is
> a parent of evdev. input_dev shoudl only be released after
> evdev_free() is called.

Hm? evdev_free only does the final kfree call. The calls to device_del
and put_device are already happening in device_disconnect, so the paren=
t
can go away any time after that. Do you say that that should be moved
into evdev_free instead? I'm not familiar with the code, but at first
sight, I'd say that we should have a "if (evdev->grab)
evdev_ungrab(evdev, evdev->grab)" in evdev_cleanup, looks like the
logical place to do that. Anything I'm missing?

Bj=F6rn
