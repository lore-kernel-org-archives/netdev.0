From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 2/2] platform: Facilitate the creation of pseudo-platform buses
Date: Mon, 16 Aug 2010 23:58:42 +0000
Message-ID: <AANLkTink7MB8JbSz1cguVLviqkF0OTt=gHMjUi3j0bfB@mail.gmail.com>
References: <1281484174-32174-1-git-send-email-ppannuto@codeaurora.org>
	<1281484174-32174-3-git-send-email-ppannuto@codeaurora.org>
	<AANLkTi=GduvsmkXpxsVoN7k3gPDjjRgqe0E_Z2YeEVS5@mail.gmail.com>
	<4C6987B0.7030703@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Grant Likely <grant.likely@secretlab.ca>,
	linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	magnus.damm@gmail.com, gregkh@suse.de,
	Kevin Hilman <khilman@deeprootsystems.com>,
	Paul Mundt <lethal@linux-sh.org>,
	Magnus Damm <damm@opensource.se>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Eric Miao <eric.y.miao@gmail.com>,
	Dmitry Torokhov <dtor@mail.ru>, netdev@vger.kernel.org
To: Patrick Pannuto <ppannuto@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:37759 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752999Ab0HPX6o convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Aug 2010 19:58:44 -0400
In-Reply-To: <4C6987B0.7030703@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/8/16 Patrick Pannuto <ppannuto@codeaurora.org>:
> On 08/13/2010 03:05 PM, Grant Likely wrote:
>> On Tue, Aug 10, 2010 at 5:49 PM, Patrick Pannuto
[...]
>>> + * @bus: partially complete bus type to register
>>> + *
>>> + * This init will fill in any ommitted fields in @bus, however, it
>>> + * also allocates memory and replaces the pm field in @bus, since
>>> + * pm is const, but some of its pointers may need this one-time
>>> + * initialziation overwrite.
>>> + *
>>> + * @bus's registered this way should be released with
>>> + * pseudo_platform_bus_unregister
>>> + */
>>> +int pseudo_platform_bus_register(struct bus_type *bus)
>>> +{
>>> + =A0 =A0 =A0 int error;
>>> + =A0 =A0 =A0 struct dev_pm_ops* heap_pm;
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
[and so on ...]
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
> No, this won't work. (Unless, every pseudo_bus_type author did this s=
ame
> kludge to work around const - better to do once IMHO)

Actually you can do:

const struct dev_pm_ops test =3D {
    DEFAULT_PLATFORM_PM_OPS,
    .prepare =3D my_func,
    ...
};

where:

#define DEFAULT_PLATFORM_PM_OPS \
    .prepare =3D platform_pm_prepare, \
    .complete =3D platform_pm_complete, \
    ...

In case of repeated field assignments, gcc uses the last value (as per
http://gcc.gnu.org/onlinedocs/gcc/Designated-Inits.html).

Best Regards,
Micha=B3 Miros=B3aw
