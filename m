From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 2/2] Convert smsc911x to use ACPI as well as DT
Date: Thu, 24 Sep 2015 16:15:46 +0100
Message-ID: <20150924151546.GJ13823@e104818-lin.cambridge.arm.com>
References: <1439417187-21411-1-git-send-email-jeremy.linton@arm.com>
 <1439417187-21411-3-git-send-email-jeremy.linton@arm.com>
 <1443033714.74600.18.camel@infradead.org>
 <560310EA.2070805@intel.com>
 <1443042212.74600.30.camel@infradead.org>
 <56033C10.2040708@linaro.org>
 <1443082579.74600.48.camel@infradead.org>
 <20150924103152.GG13823@e104818-lin.cambridge.arm.com>
 <1443095558.74600.84.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: steve.glendinning@shawell.net, netdev@vger.kernel.org,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	Jeremy Linton <jeremy.linton@arm.com>,
	Hanjun Guo <hanjun.guo@linaro.org>,
	Suravee.Suthikulpanit@amd.com, grant.likely@linaro.org,
	linux-arm-kernel@lists.infradead.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:38844 "EHLO foss.arm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753400AbbIXPPv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2015 11:15:51 -0400
Content-Disposition: inline
In-Reply-To: <1443095558.74600.84.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 24, 2015 at 12:52:38PM +0100, David Woodhouse wrote:
> On Thu, 2015-09-24 at 11:31 +0100, Catalin Marinas wrote:
> > PRP0001 opens the door to any DT-like properties in ACPI and, knowi=
ng
> > how the ARM ecosystem works, I'm pretty sure we'll soon lose contro=
l (if
> > we haven't already; not all the developments are done in the open).
>=20
> No. That door is wide open already =E2=80=94 people can already do wh=
atever
> they like in _DSD properties. If they're going to screw up DT
> properties, they'll screw up ACPI-only _DSD properties just the same.

_DSD isn't something I like either. But since we now allow it, we shoul=
d
try to restrict its use to the bare minimum.

> You speak of maintaining "tight control of the _DSD properties that
> are going to be used in ACPI tables"... but if you're going to
> confiscate their crackpipe and stand over them while they work, you c=
an
> do that just as well whether they're using "PRP0001" or "FOO1234" as
> their HID value.

With "PRP0001", they can skip the _DSD properties review process (not
that they bother much currently) as long as the existing DT support
covers their needs. However, we don't want to emulate DT in ACPI but
first try the established ACPI methods and only use _DSD where these ar=
e
insufficient. Automatically converting existing drivers and encouraging
people to use "PRP0001" does not provide them with any incentive to try
harder and learn the "ACPI way".

> In that sense, the HID is entirely orthogonal.
>=20
> And think about it... we *really* don't want a given peripheral devic=
e
> to have *different* bindings depending on whether it's discovered wit=
h
> a specific ACPI HID, vs. when it's discovered via DT or the PRP0001
> HID. That way lies complete insanity.

I'm fine with reusing the same property names between _DSD and DT but I
strongly consider that _DSD should only cover a _subset_ of the DT
bindings and they should be reviewed independently.

Take the smsc911x driver for example: the DT bindings for the ARM Juno
platform include things like "clocks", "vdd33a-supply". Such concepts
are not available in ACPI (but we've seen people trying to emulate
them), so rather than enabling such clocks in firmware, vendors will be
tempted to do things the DT way, possibly with "PRP0001" HIDs covering
the clock devices (though I think they currently require some kernel
changes).

> In some ways, your proposal would be actively *counterproductive*. Yo=
u
> say you want to train people *not* to keep patching the kernel. But
> where they *could* have just used PRP0001 and used a pre-existing
> kernel, you then tell them "oh, but now you need to patch the kernel
> because we want you to make up a new HID and not be compatible with
> what already exists."

I gave an example above with the clocks but let's take a simpler,
device-specific property like "smsc,irq-active-high". Is this documente=
d
anywhere apart from the kernel driver and the in-kernel DT smsc911x.txt=
?
No. Are other non-Linux OS vendors going to look in the kernel source
tree to implement support in their drivers? I doubt it and we could end
up with two different paths in firmware for handling the same device.
ACPI probably never was truly OS agnostic but with "PRP0001" we don't
even try.

The idea of registering a HID is to also have a process for getting
corresponding _DSD properties approved, published. Some of them like
"mac-address" would be more generic and not require further review but
we'll have more specific properties.

Patching a kernel driver to support a new HID is a (weak) method of
keeping track of which devices are used with ACPI. Given how quickly
these two patches were merged while still under discussion, I doubt tha=
t
arch maintainers would be in a position to review/reject drivers using
non-approved _DSD properties.

> If you go down this road, I predict we'll start seeing *separate*
> drivers for identical components, because the bindings for DT vs. ACP=
I
> properties are different. We really don't want that.

What if Linux is not the first targeted OS? We either convince the
vendor to change the firmware or we'll have to support properties
invented for other operating system.

> > The pro ARM ACPI camp has been very vocal against DT in the server
> > space. I'd like to seem them as vocal about PRP0001, unless they fi=
nd it
> > acceptable (and should apologise for bashing DT ;)).
>=20
> Fundamentally, that DT vs. ACPI distinction has gone away with the
> introduction of _DSD. We *need* the flexibility that we gain from
> being able to provide device properties rather than inventing a new
> HID for every permutation, and with that flexibility comes a certain
> amount of responsibility to do things sensibly.

You may trust the x86 world to be responsible. I can't say the same
about the ARM SoC world ;).

While I understand the need for the flexibility of _DSD, I think the
main difference of opinion is that I do not consider ACPI+_DSD equal to
DT. It's fine to borrow some concepts from DT but I'm definitely agains=
t
emulating it entirely, which is pretty much what "PRP0001" is doing.

> People have not always designed their bindings sensibly. But that
> isn't going to be magically solved in the ACPI world, unless you *do*
> actually stand over them with their crackpipe in your hand, as I joke=
d
> above. And eschewing PRP0001 really doesn't help you with that. It
> just makes things harder.

I agree with you that _DSD already opened the door to even more "mess".
But, IMO, our approaches differ: you are trying to avoid such mess
affecting the kernel by hiding it behind "PRP0001"; what I'm trying is
to restrict (as much as I can) the mess developing in the early days of
ARM ACPI. I don't think either method will be fully successful, we may
just end up with a combination of the two.

Apart from a _DSD properties review process, what we need is (main) OS
vendors enforcing it, possibly with stricter ACPI test suite. Disabling
PRP0001 for ARM wouldn't solve the problem but at least it would make
people think about what _DSD properties they need registered for their
device (or I'm over optimistic and I should just stop caring ;)).

--=20
Catalin
