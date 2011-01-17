From: Michael =?ISO-8859-1?Q?B=FCsch?= <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: Merging SSB and HND/AI support
Date: Mon, 17 Jan 2011 12:57:48 +0100
Message-ID: <1295265468.24530.23.camel@maggie>
References: <AANLkTi=GDcy50zsC6=Dgv1-Ty3cYK2qpx9o=q3JdXuCh@mail.gmail.com>
	 <1295261783.24530.3.camel@maggie>
	 <AANLkTikJcug7LUTgX_YDD4Z8ZBrdkAdLq8_Epa6TkA5f@mail.gmail.com>
	 (sfid-20110117_122135_343461_FFFFFFFFFA00D75F)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jonas Gorski <jonas.gorski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTikJcug7LUTgX_YDD4Z8ZBrdkAdLq8_Epa6TkA5f-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org> (sfid-20110117_122135_343461_FFFFFFFFFA00D75F)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-01-17 at 12:21 +0100, Jonas Gorski wrote:=20
> On 17 January 2011 11:56, Michael B=C3=BCsch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org> wrote:
> > On Mon, 2011-01-17 at 11:46 +0100, Jonas Gorski wrote:
> >> a) Merge the HND/AI code into the current SSB code, or
> >>
> >> b) add the missing code for SoCs to brcm80211 and replace the SSB =
code with it.
> >
> > Why can't we keep those two platforms separated?
> > Is there really a lot of shared code between SSB and HND/AI?
>=20
> Yes, as far as I understand the AI bus behaves mostly like a SSB bus
> except for places like enabling/disabling cores. E.g. the AI bus also
> has a common core, which has a bit for telling whether its a SSB or A=
I
> bus, and has the mostly the same registers as the SSB common cores (s=
o
> most driver_chipcommon_* stuff also applies for the AI bus).

Well... I don't really like the idea of running one driver and
subsystem implementation on completely distinct types of silicon.
We will end up with the same mess that broadcom ended up with in
their "SB" code (broadcom's SSB backplane implementation).
=46or example, in their code the driver calls pci_enable_device() and
related PCI functions, even if there is no PCI device at all. The calls
are magically re-routed to the actual SB backplane.
You'd have to do the same mess with SSB. Calling ssb_device_enable()
will mean "enable the SSB device", if the backplane is SSB, and will
mean "enable the HND/AI" device, if the backplane is HND/AI.

So I'm still in favor of doing a separate HND/AI bus implementation,
even if
that means duplicating a few lines of code. I think that compared to th=
e
workarounds and conditionals needed for getting SSB to run on HND/AI
hardware, it will be a net win.

> > So why do we need to replace or merge SSB in the first place? Can't
> > it co-exist with HND/AI?
>=20
> It probably can, but then the SSB code must be at least made AI aware
> so it doesn't try to attach itself if it finds one.

SSB doesn't search for SSB busses in the system, because there's no
way to do so. The architecture (or the PCI/PCMCIA/SDIO device) register=
s
the bus,
if it detected an SSB device. So for the embedded case, it's hardcoded
in the arch code. For the PCI case it simply depends on the PCI IDs.
I don't see a problem here. Your arch code will already have to know
what machine it is running on. So it will have to decide whether to
register a SSB or HND/AI bus.

It's like a platform_device. However, it doesn't use the platform_devic=
e
mechanism. There's no technical reason. It would be trivial to port the
SSB bus registration to use platform_device, however.

> Also I don't know
> if it is a good idea to let arch-specific code depend on code in
> staging.

Sure. The code needs to be cleaned up and moved to the mainline kernel
_anyway_. You don't get around this.

--=20
Greetings Michael.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
