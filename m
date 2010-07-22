From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [PATCH] Driver-core: Fix bluetooth network device rename
	regression
Date: Thu, 22 Jul 2010 15:38:54 +0200
Message-ID: <AANLkTimM5Ea8mQ7aX4kDq3dgF3P-t2Wm3dERhckC69Ja@mail.gmail.com>
References: <20100621222938.GA20583@suse.de> <m1eig0dmhk.fsf@fess.ebiederm.org>
	<20100621231058.GA1066@suse.de> <m14ogwc4ou.fsf@fess.ebiederm.org>
	<20100622035631.GA3755@suse.de> <m1630q7x5v.fsf_-_@fess.ebiederm.org>
	<20100708211930.GA15385@kroah.com> <m1r5jdbobe.fsf@fess.ebiederm.org>
	<20100708230601.GB17002@kroah.com> <20100719133451.0862ca62.akpm@linux-foundation.org>
	<20100720201334.GA11991@suse.de> <m139vd5sms.fsf_-_@fess.ebiederm.org>
	<m1zkxj27xp.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg KH <greg@kroah.com>, "Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:64102 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759371Ab0GVNjK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 09:39:10 -0400
Received: by gyg10 with SMTP id 10so754552gyg.19
        for <netdev@vger.kernel.org>; Thu, 22 Jul 2010 06:39:09 -0700 (PDT)
In-Reply-To: <m1zkxj27xp.fsf_-_@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 22, 2010 at 11:16, Eric W. Biederman <ebiederm@xmission.com=
> wrote:
>
> With CONFIG_SYSFS_DEPRECATED_V2 enabled I can rename any network devi=
ce
> anything as long as the new name does not conflict with another netwo=
rk
> device.
>
> With CONFIG_SYSFS_DEPRECATED_V2 disabled without this fix bluetooth b=
enp
> devices, and the mac80211_hwsim driver can not be renamed to any arbi=
trary
> name that happens to conflict with any other name that is used in the=
ir
> parent devices directory.

This is true for all devices, that their children can not carry names
of existing attributes or directories of the parent. These drivers
manage the parent-child relation their own and know these limitations
very well, because they have created the conflicing names themselves.
The class glue directories which separate these namespaces are there
to prevent unknown clashes, not clashes originating from the same
subsystem.

The real fix is that the drivers should not try to stack classes, but
use buses. This is and never was supported by the core, especially not
for clashing names.

> --- a/drivers/base/core.c
> +++ b/drivers/base/core.c
> @@ -673,7 +673,7 @@ static struct kobject *get_device_parent(struct d=
evice *dev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (parent =3D=
=3D NULL)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0parent_kobj =3D virtual_device_parent(dev);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else if (parent->c=
lass)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else if (parent->c=
lass && (strcmp(dev->class->name, "net") !=3D 0))

Subsystems specific code must not leak into core code. We will never
be able to get rid of these hacks. As mentioned in earlier mails, it's
just plain wrong to do anything like this. It makes a specific
subsystem behave different from all others, just to fix some broken
drivers to work with the newly introduced network sysfs namespaces.

Since the issue is not a regression, and not even a bug in the core,
it should not be done this way for mainline.

Please try to fix these drivers instead, or mark the broken for
namespaces, if nobody can fix them right now.

Thanks,
Kay
