From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Mon, 21 Dec 2009 10:34:26 -0500
Message-ID: <4B2F9582.5000002@gmail.com>
References: <4B1D4F29.8020309@gmail.com> <20091218215107.GA14946@elte.hu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig339CE623483715AAA136F863"
Cc: Avi Kivity <avi@redhat.com>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20091218215107.GA14946@elte.hu>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig339CE623483715AAA136F863
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12/18/09 4:51 PM, Ingo Molnar wrote:
>=20
> * Gregory Haskins <gregory.haskins@gmail.com> wrote:
>=20
>> Hi Linus,
>>
>> Please pull AlacrityVM guest support for 2.6.33 from:
>>
>> git://git.kernel.org/pub/scm/linux/kernel/git/ghaskins/alacrityvm/linu=
x-2.6.git
>> for-linus
>>
>> All of these patches have stewed in linux-next for quite a while now:
>>
>> Gregory Haskins (26):
>=20
> I think it would be fair to point out that these patches have been obje=
cted to=20
> by the KVM folks quite extensively,

Actually, these patches have nothing to do with the KVM folks.  You are
perhaps confusing this with the hypervisor-side discussion, of which
there is indeed much disagreement.

To that point, it's certainly fair to point out the controversy on the
host side.  It ultimately is what forced the creation of the AlacrityVM
project, after all.  However, it should also be pointed out that this
pull request is not KVM specific, nor even KVM related per se.  These
patches can (and in fact, do) work in other environments that do not use
KVM nor even AlacrityVM at all.

VBUS, the underlying technology here, is a framework for creating
optimized software-based device models using a Linux-kernel as a host
and their corresponding "driver" resources to the backend.  AlacrityVM
is the application of these technologies using KVM/Linux/Qemu as a base,
but that is an implementation detail.

For more details, please see the project wiki

http://developer.novell.com/wiki/index.php/AlacrityVM

This pull request is for drivers to support running a Linux kernel as a
guest in this environment, so it actually doesn't affect KVM in any way.
 They are just standard Linux drivers and in fact can load as
stand-alone KMPs in any modern vanilla distro.  I haven't even pushed
the host side code to linux-next yet specifically because of that
controversy you mention.


> on multiple technical grounds - as=20
> basically this tree forks the KVM driver space for which no valid techn=
ical=20
> reason could be offered by you in a 100+ mails long discussion.

You will have to be more specific on these technical grounds you
mention, because I believe I satisfactorily rebutted any issues raised.
 To say that there is no technical reason is, at best, a matter of
opinion.  I have in fact listed numerous reasons on a technical,
feature, and architectural basis on what differentiates my approach, and
provided numbers which highlights their merits.  Given that they are all
recorded in the archives of said 100+ email thread as well as numerous
others, I wont rehash the entire list here.  Instead, I will post a
summary of the problem space from the performance perspective, since
that seems to be of most interest atm.

=46rom my research, the reason why virt in general, and KVM in particular=

suffers on the IO performance front is as follows: IOs
(traps+interrupts) are more expensive than bare-metal, and real hardware
is naturally concurrent (your hbas and nics are effectively parallel
execution engines, etc).

Assuming my observations are correct, in order to squeeze maximum
performance from a given guest, you need to do three things:  A)
eliminate as many IOs as you possibly can, B) reduce the cost of the
ones you can't avoid, and C) run your algorithms in parallel to emulate
concurrent silicon.

So to that front, we move the device models to the kernel (where they
are closest to the physical IO devices) and use "cheap" instructions
like PIOs/Hypercalls for (B), and exploit spare host-side SMP resources
via kthreads for (C).  For (A), part of the problem is that virtio-pci
is not designed optimally to address the problem space, and part of it
is a limitation of the PCI transport underneath it.

For example, PCI is somewhat of a unique bus design in that it wants to
map signals to interrupts 1:1.  This works fine for real hardware where
interrupts are relatively cheap, but is quite suboptimal on virt where
the window-exits, injection-exits, and MMIO-based EIOs hurt
substantially (multiple microseconds per).

One core observation is that we don't technically need 1:1 interrupts to
signals in order to function properly.  Ideally we will only bother the
CPU when work of a higher priority becomes ready.  So the alacrityvm
connector to vbus uses a model were we deploy a lockless shared-memory
queue to inject interrupts.  This means that temporal interrupts (of
both intra and inter device variety) of similar priority can queue
without incurring any extra IO.  This means fewer exits, fewer EOIs, etc.=


The end result is that I can demonstrate that even with a single stream
to a single device, I can reduce exit rate by over 45% and interrupt
rate > 50% when compared to the equivalent virtio-pci ABI.  This scales
even higher when you add additional devices to the mix.  The bottom line
is that we use significantly less CPU while producing the highest
throughput and lowest latency.  In fact, to my knowledge vbus+venet is
still the highest performing 802.x device for KVM to my knowledge, even
when turning off its advanced features like zero-copy.

The parties involved have demonstrated a close mindedness to the
concepts I've introduced, which is ultimately why today we have two
projects.  I would much prefer that we didn't, but that is not in my
control.  Note that the KVM folks eventually came around regarding the
in-kernel and concurrent execution concepts, which is a good first step.
 I have yet to convince them about the perils of relying on PCI, which I
believe is an architectural mistake.  I suspect at this point it will
take community demand and independent reports from users of the
technology to convince them further.  The goal of the alacrityvm project
is to make it easy for interested users to do so.

Don't get me wrong.  PCI is a critical feature for full-virt guests.
But IMO it has limited applicability once we start talking about PV, and
AlacrityVM aims to correct that.

>=20
> (And yes, i've been Cc:-ed to much of that thread.)
>=20
> The result will IMO be pain for users because now we'll have two framew=
orks,=20
> tooling incompatibilities, etc. etc.

Precedent defies your claim, as that situation already exists today that
has nothing to do with my work.  Even if you scoped the discussion
specifically to KVM, users can select various incompatible IO methods
([realtek, e1000, virtio-net], [ide. lsi-scsi, virtio-blk], [std-vga,
cirrus-vga], etc), so this claim about user pain seems dubious at best.
 I suspect that if a new choice is available that offers
features/performance improvements, users are best served by having that
choice to make themselves, instead of having that choice simply unavailab=
le.

The reason why we are here having this particular conversation as it
pertains to KVM is that I do not believe you can achieve the
performance/feature goals that I have set for the project in a backwards
compatible way (i.e. virtio-pci compatible).  At least, not is a way
that is not a complete disaster code-base wise.  So while I agree that a
new incompatible framework vs backwards compatible is suboptimal, I
believe it's necessary to ultimately fix the problems in the most ideal
way.  Therefore, I would rather take this lump now than 5 years from now.=


The KVM maintainers apparently do not agree on that fundamental point,
so we are deadlocked.

So far, the only legitimate objection I have seen to these guest side
drivers is Linus', and I see his point.  I won't make a pull request
again until I feel enough community demand has been voiced to warrant a
reconsideration.

Kind Regards,
-Greg


--------------enig339CE623483715AAA136F863
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAksvlYIACgkQP5K2CMvXmqGpcgCdGeXMauWQg+GX3kXK1lIziKMH
QrwAn0wgx2hGu2HwsMg0byLoOmG4ox0F
=2M35
-----END PGP SIGNATURE-----

--------------enig339CE623483715AAA136F863--
