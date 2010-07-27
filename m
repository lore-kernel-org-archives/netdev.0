From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] Driver-core: Fix bluetooth network device rename regression
Date: Tue, 27 Jul 2010 11:17:31 -0700
Message-ID: <m14ofkiybo.fsf@fess.ebiederm.org>
References: <AANLkTimM5Ea8mQ7aX4kDq3dgF3P-t2Wm3dERhckC69Ja@mail.gmail.com>
	<m1vd87toy9.fsf@fess.ebiederm.org>
	<AANLkTil3Q1Vobw48AvStl9gphaJcyUGlt6ZnMLanDMVn@mail.gmail.com>
	<1279822828.12439.24.camel@jlt3.sipsolutions.net>
	<20100722182827.GA12821@suse.de>
	<1279823801.12439.31.camel@jlt3.sipsolutions.net>
	<20100722185449.GB528@suse.de> <m1eievugon.fsf@fess.ebiederm.org>
	<20100726180941.GB4883@kroah.com>
	<AANLkTincg-0-h1aqW4A=z6A+HTbOfkCCWKDD18ZUEGSn@mail.gmail.com>
	<20100727134904.GA4994@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kay Sievers <kay.sievers@vrfy.org>, Greg KH <gregkh@suse.de>,
	Johannes Berg <johannes@sipsolutions.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	netdev <netdev@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:50664 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308Ab0G0SR5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 14:17:57 -0400
In-Reply-To: <20100727134904.GA4994@kroah.com> (Greg KH's message of "Tue\, 27 Jul 2010 06\:49\:04 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH <greg@kroah.com> writes:

> On Tue, Jul 27, 2010 at 11:10:26AM +0200, Kay Sievers wrote:
>> On Mon, Jul 26, 2010 at 20:09, Greg KH <greg@kroah.com> wrote:
>> >> Does this version of the change look less bleh worthy? =C2=A0The =
effect is
>> >> the same as my previous patch but the test is more abstract so th=
e
>> >> effect is not strictly limited to /sys/class/net.
>> >
>> > What other class type has a namespace at this point in time?
>> > Essentially this is the same exact thing, just in a different form=
at
>> > that obfuscates what you are really doing here.
>>=20
>> The patch still looks broken, and does not belong into the core the
>> way it is done. We denied hacks like this for good reason. But
>> out-of-the-blue it was a bluetooth naming regression to fix in the
>> driver core? Interesting!

This is hardly out of the blue.  I reported a problem 3 years ago
which is one of the reasons we have the class directories in the
first place.

What is different is simply that it was noticed that there were
cases the existing heuristic in get_device_parent did not catch.

Any class that has sysfs namespace support requires the class directory=
=2E
Which means that the test !dev->class->ns_type is exactly the right
test to avoid the magic exception in get_device_parent.

>> If someone is going to add namespaces to 'block' or 'input', the sys=
fs
>> layout will break, and userspace will be unable to handle the
>> resulting changes.

Yes.  We don't even have a namespace that we can put those in, so worry=
ing
about namespaces other than the network namespace or the user namespace
is looking much too far into the future.

What is in the near term is wireless phys getting network namespace sup=
port
in sysfs, and in practice the exact same issues apply.

> When that happens, I'm sure Eric will be willing to fix up any proble=
ms
> that are found as he is the one that insisted on pushing it to Linus
> around our objections.
>
> Right Eric?

Yes.  I certainly will.  The point of the namespace support in sysfs
is to keep these things invisible to userspace.  If something is visibl=
e
it is generally a bug.

> And Eric, where are you working on the "real" patches to solve the
> problems of the bnet and wireless driver problems so we can remove th=
is
> check from the driver core as soon as possible?  Any idea when they w=
ill
> be done?

I looked at that, and it is arguable in the mac80211_hwsim case as that
is just a simulation for testing the infrastructure for wireless develo=
pers
as best as I understand it.  The more a simulation differs from reality
the more it matters.

=46or bluetooth drivers or for any other existing subsystem replacing a=
 class
device with a bus device is totally inappropriate.

Let me say this again clearly.

class -> bus BROKEN

In the case of bluetooth it would require changing /sys/class/bluetooth
to /sys/bus/bluetooth.  Which is user visible in the worst possible
way and quick google search confirmed it will break user space scripts.

So as much as I sympathize with the position that buses have a better
layout than classes, after having examined the issue I completely oppos=
e
changing one into the other with our current code base.

So for the medium term I think we are fine.

=46or the long term moving the driver core from a mandatory policy of
sysfs device node creation, to a default library for sysfs device node
creation that can be overridden in whole or in part on a subsystem by
subsystem basis looks like the right way to go.  Based on my
experience with sysfs this is likely to be a multi-year project, and=20
one I'm uncertain how motivated I am to tackle.

Eric

