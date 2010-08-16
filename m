From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 2/2] platform: Facilitate the creation of pseudo-platform buses
Date: Mon, 16 Aug 2010 14:25:18 -0600
Message-ID: <AANLkTimxOgZPC_MiecEDRXoAcGRnsuUe31KkJJKDekev@mail.gmail.com>
References: <1281484174-32174-1-git-send-email-ppannuto@codeaurora.org>
 <1281484174-32174-3-git-send-email-ppannuto@codeaurora.org>
 <AANLkTi=GduvsmkXpxsVoN7k3gPDjjRgqe0E_Z2YeEVS5@mail.gmail.com> <4C6987B0.7030703@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	magnus.damm@gmail.com, gregkh@suse.de,
	Kevin Hilman <khilman@deeprootsystems.com>,
	Paul Mundt <lethal@linux-sh.org>,
	Magnus Damm <damm@opensource.se>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Eric Miao <eric.y.miao@gmail.com>,
	Dmitry Torokhov <dtor@mail.ru>, netdev@vger.kernel.org
To: Patrick Pannuto <ppannuto@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:57162 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756283Ab0HPUZj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Aug 2010 16:25:39 -0400
In-Reply-To: <4C6987B0.7030703@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 16, 2010 at 12:47 PM, Patrick Pannuto
<ppannuto@codeaurora.org> wrote:
> On 08/13/2010 03:05 PM, Grant Likely wrote:
>>> @@ -1017,6 +1022,87 @@ struct bus_type platform_bus_type =3D {
>>> =A0};
>>> =A0EXPORT_SYMBOL_GPL(platform_bus_type);
>>>
>>> +/** pseudo_platform_bus_register - register an "almost platform bu=
s"
>>
>> Kerneldoc style error. =A0Should be:
>>
>> +/**
>> + * pseudo_platform_bus_register - register an "almost platform bus"
>>
>
> Fixed.

Actually, I also made a kerneldoc style error here because the braces
are missing.  This should be:

+/**
+ * pseudo_platform_bus_register() - register an "almost platform bus"

See Documentation/kernel-doc-nano-HOWTO.txt for details.

I'm also not fond of the "pseudo" name.  It isn't really a pseudo bus,
but rather a different bus type that happens to inherit most of the
platform_bus infrastructure.  It may be better just to expose the
platform_bus helper functions without any reference to pseudo, and let
the users be responsible for any naming differentiation.  This is
particularly true if the custom bus becomes responsible for
registering itself and only the initialization functions are exposed.

[...]
>>> + =A0 =A0 =A0 heap_pm =3D kmalloc(sizeof (*heap_pm), GFP_KERNEL);
>>> +
>>> + =A0 =A0 =A0 if (!heap_pm)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
>>> +
>>> + =A0 =A0 =A0 if (!bus->dev_attrs)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->dev_attrs =3D platform_bus_type.=
dev_attrs;
>>> + =A0 =A0 =A0 if (!bus->match)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->match =3D platform_bus_type.matc=
h;
>>> + =A0 =A0 =A0 if (!bus->uevent)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->uevent =3D platform_bus_type.uev=
ent;
>>> + =A0 =A0 =A0 if (!bus->pm)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcpy(heap_pm, &platform_bus_type.pm=
, sizeof(*heap_pm));
>>> + =A0 =A0 =A0 else {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->prepare =3D (bus->pm->prepar=
e) ?
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->prepare : pl=
atform_pm_prepare;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->complete =3D (bus->pm->compl=
ete) ?
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->complete : p=
latform_pm_complete;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->suspend =3D (bus->pm->suspen=
d) ?
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->suspend : pl=
atform_pm_suspend;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->resume =3D (bus->pm->resume)=
 ?
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->resume : pla=
tform_pm_resume;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->freeze =3D (bus->pm->freeze)=
 ?
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->freeze : pla=
tform_pm_freeze;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->thaw =3D (bus->pm->thaw) ?
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->thaw : platf=
orm_pm_thaw;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->poweroff =3D (bus->pm->power=
off) ?
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->poweroff : p=
latform_pm_poweroff;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->restore =3D (bus->pm->restor=
e) ?
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->restore : pl=
atform_pm_restore;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->suspend_noirq =3D (bus->pm->=
suspend_noirq) ?
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->suspend_noir=
q : platform_pm_suspend_noirq;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->resume_noirq =3D (bus->pm->r=
esume_noirq) ?
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->resume_noirq=
 : platform_pm_resume_noirq;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->freeze_noirq =3D (bus->pm->f=
reeze_noirq) ?
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->freeze_noirq=
 : platform_pm_freeze_noirq;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->thaw_noirq =3D (bus->pm->tha=
w_noirq) ?
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->thaw_noirq :=
 platform_pm_thaw_noirq;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->poweroff_noirq =3D (bus->pm-=
>poweroff_noirq) ?
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->poweroff_noi=
rq : platform_pm_poweroff_noirq;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->restore_noirq =3D (bus->pm->=
restore_noirq) ?
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->restore_noir=
q : platform_pm_restore_noirq;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->runtime_suspend =3D (bus->pm=
->runtime_suspend) ?
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->runtime_susp=
end : platform_pm_runtime_suspend;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->runtime_resume =3D (bus->pm-=
>runtime_resume) ?
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->runtime_resu=
me : platform_pm_runtime_resume;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 heap_pm->runtime_idle =3D (bus->pm->r=
untime_idle) ?
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus->pm->runtime_idle=
 : platform_pm_runtime_idle;
>>> + =A0 =A0 =A0 }
>>> + =A0 =A0 =A0 bus->pm =3D heap_pm;
>>> +
>>> + =A0 =A0 =A0 error =3D bus_register(bus);
>>> + =A0 =A0 =A0 if (error)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(bus->pm);
>>> +
>>> + =A0 =A0 =A0 return error;
>>> +}
>>> +EXPORT_SYMBOL_GPL(pseudo_platform_bus_register);
>>
>> Ick, this is a nasty list of conditional statements. =A0:-) =A0Inste=
ad it
>> could have an unconditional initialize function which sets it up jus=
t
>> like the platform bus without registering. =A0Then allow the
>> foo_bus_type initialization code override the ones it cares about, a=
nd
>> then register directly.
>>
>
> No, this won't work. (Unless, every pseudo_bus_type author did this s=
ame
> kludge to work around const - better to do once IMHO)
>
> struct bus_type {
> =A0 =A0 =A0 =A0...
> =A0 =A0 =A0 =A0const struct dev_pm_ops *pm;
> =A0 =A0 =A0 =A0...
> };
>
> That const is there to *prevent* device/driver writers from overridin=
g
> pm ops on accident, and to that end, it has value. What we would real=
ly
> like here is 'const after registered' semantics, where the bus author
> can fill in half the structure, and the platform code can fill in the
> rest. However, allowing subclasses to modify private data elements is=
n't
> possible in C :)

Okay then, here is a better approach:  Don't do any allocation in this
function.  Just initialize the bus_type exactly the way it is
initialized for the platform bus and assign the default dev_pm_ops.
If the custom bus needs to override them, then it should be
responsible to kmemdup the default dev_pm_ops structure and modify the
copy.  The code will be a lot simpler that way.

> I believe the 'const' here provides valuable safety. My original atte=
mpt
> at doing this removed the const, and I overwrote one of the pointers =
in
> platform_dev_pm_ops on my first try at implementing it!

Yes, overriding the const is a bad idea and you'd be wrong to override =
it.  :-)

Cheers,
g.
