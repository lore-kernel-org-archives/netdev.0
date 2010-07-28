From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [PATCH] Driver-core: Fix bluetooth network device rename
	regression
Date: Wed, 28 Jul 2010 07:26:15 +0200
Message-ID: <AANLkTikoLQMH5LZCgKmQivTrtvtCf8oksk-HwBQQ+Tte@mail.gmail.com>
References: <1279822828.12439.24.camel@jlt3.sipsolutions.net>
	<20100722182827.GA12821@suse.de> <1279823801.12439.31.camel@jlt3.sipsolutions.net>
	<20100722185449.GB528@suse.de> <m1eievugon.fsf@fess.ebiederm.org>
	<20100726180941.GB4883@kroah.com> <AANLkTincg-0-h1aqW4A=z6A+HTbOfkCCWKDD18ZUEGSn@mail.gmail.com>
	<20100727134904.GA4994@kroah.com> <m14ofkiybo.fsf@fess.ebiederm.org>
	<AANLkTi=ttTjec7RjUZRM9v5WtLEYNPtH9L2qx8Js1WCT@mail.gmail.com>
	<20100727183624.GB30363@kroah.com> <m1zkxcg3xe.fsf@fess.ebiederm.org>
	<AANLkTi=LB7qV3S1miOocpQCtCaxhqJsLS51UDcnGjK+u@mail.gmail.com>
	<m1aapcejf5.fsf@fess.ebiederm.org> <AANLkTimA9Mo0B6MOn31KQ=L+raeCUg6eH3Mqf=vB5AYz@mail.gmail.com>
	<m1aapcqje4.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <greg@kroah.com>, Greg KH <gregkh@suse.de>,
	Johannes Berg <johannes@sipsolutions.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:43476 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752068Ab0G1F0b convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jul 2010 01:26:31 -0400
Received: by gwb20 with SMTP id 20so785478gwb.19
        for <netdev@vger.kernel.org>; Tue, 27 Jul 2010 22:26:30 -0700 (PDT)
In-Reply-To: <m1aapcqje4.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 28, 2010 at 07:12, Eric W. Biederman <ebiederm@xmission.com=
> wrote:
> Kay Sievers <kay.sievers@vrfy.org> writes:
>> On Tue, Jul 27, 2010 at 22:53, Eric W. Biederman <ebiederm@xmission.=
com> wrote:
>>> Kay Sievers <kay.sievers@vrfy.org> writes:
>>
>>>> It should only be used if it's really needed for known used usersp=
ace
>>>> interfaces. A few others that got converted already did not need i=
t.
>>>
>>> Interesting. =C2=A0The symlink creation is slightly buggy in that i=
t is
>>> created after the uevent for device creation has been sent. =C2=A0W=
hich can
>>> lead to some interesting races in userspace.
>>
>> At uevent time the 'subsystem' is specified by the 'sybsystem' link
>> and the SUBSYSTEM property in the event environment. The device shou=
ld
>> not really rely on finding itself linked in class. The class and bus
>> link collections are only to find a group of devices of the same
>> subsystem, and this should not be a real world problem here.
>
> I agree that there should be no real world problems.
> The bottom line is that every sysfs attribute should be created
> before we send the uevent or else we get horribly subtle
> races or we get user space code that starts looping looking
> for the interface.

Yeah, but most of these things we should have fixed over the last
years. There is no single WAIT_FOR instruction left in udev rules. :)

>> Also there are plans to merge struct class and struct bus_type
>> completely and keep only a few flags around where stuff should show =
up
>> for compatibility. At that point all stuff will be created at the sa=
me
>> time.
>
> That part seems reasonable.
>
>>> As for the rest the bus compat code is similar but not quite the sa=
me
>>> as the class code, so I would be extremely reluctant to deploy it
>>> except in extremely limited cases. =C2=A0Backwards compatibility is
>>> important, and we should strive our best to maintain backwards
>>> compatibility it for the kernel<->userspace ABIs.
>>
>> Today, the only real difference between class and bus devices are
>> these 'collection links', the devices otherwise look completely the
>> same. There should be no important difference.
>
> I don't see the class subdirectories created for bus devices, and I
> don't see any equivalent.

Sure, I meant, if the class-compat stuff is used when a conversion is d=
one.

> At least for the network devices this is a
> huge difference, because the device namespace is controlled by
> userspace and it is NOT ok to have namespace conflicts with arbitrary
> sysfs attributes.

Yeah, that's why the class-glue directories exist. But so far we did
not support stacking of classes of different types.

>> Buses are very much preferred over classes today, no new stuff shoul=
d
>> create any class. The bus directories are extendable and have a
>> reasonable layout with the devices/ subdirectory, unlike the flat
>> class directories where people got the silly idea to mix devices lis=
ts
>> with attributes to confuse everything.
>
> Which is generally reasonable. =C2=A0However buses appear to have the=
 silly
> idea that it is ok to mix child child device lists of different kinds
> of children with attributes and confuse everything.

Classes do the same. They are usually distinguished by its name, like
mouseX, inputX, sdX, sdX3, they are all different, but still belong to
the same 'subsystem'.

> At the subsystem level bus devices look better.
> At the individual device level bus devices stacked on bus devices
> appear to be a namespace disaster.

They are usually created by the same code, in many cases by the same
drivers, and have not been a real problem so far. As you said, network
devices are special here, because of the ability to rename them from
userspace.

At some time in the future, when buses and classes are merged, I
expect stuff can just set a flag to have a 'glue dir' created or not.

=46or now 'glue dirs' are limited to be created between a bus and a
class device. It could possibly be extended to be created between
classes of different types to handle issues like this.

Kay
