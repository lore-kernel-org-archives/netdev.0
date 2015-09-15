From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [PATCH V4 1/2] pci: Add dev_flags bit to access VPD through
 function 0
Date: Tue, 15 Sep 2015 15:17:27 -0600
Message-ID: <1442351847.23936.155.camel@redhat.com>
References: <20150713183821.19985.52157.stgit@mdrustad-wks.jf.intel.com>
	 <20150713184001.19985.64867.stgit@mdrustad-wks.jf.intel.com>
	 <1442341152.23936.122.camel@redhat.com>
	 <F17F8A11-FB09-4131-A404-DE106F3944BB@intel.com>
	 <1442343860.23936.141.camel@redhat.com>
	 <5E6FC98D-C2B9-4F69-ABB9-84A39AE6D271@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "bhelgaas@google.com" <bhelgaas@google.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Myron Stowe <myron.stowe@redhat.com>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <5E6FC98D-C2B9-4F69-ABB9-84A39AE6D271@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-09-15 at 20:47 +0000, Rustad, Mark D wrote:
> > On Sep 15, 2015, at 12:04 PM, Alex Williamson <alex.williamson@redh=
at.com> wrote:
> >=20
> >=20
> > FRU-type information is only one of the use cases of VPD, the spec =
also
> > defines (PCI rev 3.0, 6.4):
> >=20
> >        ... a mechanism for storing information such as performance =
and
> >        failure data on the device being monitored.
> >=20
> > That information could very much be function specific.
>=20
> It is open to interpretation. I guess still I see it as the physical =
device as a whole.
>=20
> > When I was looking at whether we should provide VPD access of an
> > assigned device at all, I ran across this interesting statement in =
the
> > PCI spec (rev 3.0, I.3.1.1):
> >=20
> >        CP Extended Capability
> >=20
> >        This field allows a new capability to be identified in the V=
PD
> >        area. Since dynamic control/status cannot be placed in VPD, =
the
> >        data for this field identifies where, in the device=E2=80=99=
s memory or
> >        I/O address space, the control/status registers for the
> >        capability can be found. Location of the control/status
> >        registers is identified by providing the index (a value betw=
een
> >        0 and 5) of the Base Address register that defines the addre=
ss
> >        range that contains the registers, and the offset within tha=
t
> >        Base Address register range where the control/status registe=
rs
> >        reside. The data area for this field is four bytes long. The
> >        first byte contains the ID of the extended capability. The
> >        second byte contains the index (zero based) of the Base Addr=
ess
> >        register used. The next two bytes contain the offset (in
> >        little-endian order) within that address range where the
> >        control/status registers defined for that capability reside.
> >=20
> > Again, this sounds like function specific data, and both here and a=
bove,
> > blocking access to VPD could affect the functionality of drivers.  =
It
> > may be the case that Intel would find this use to be madness, but
> > there's no PCI spec requirement that separate functions are in any =
way
> > similar and we're looking at an interface that may be used by non-I=
ntel
> > devices as well.  Thanks,
>=20
> It isn't an interface as such, it is a quirk to address some
> widespread design problems with multi function devices with VPD. And
> you are right that functions can be different. In fact this quirk is
> needed only because now they often (usually in fact) are not
> different! I do hope to see some non-Intel devices use the quirk,
> because I'm pretty sure there are other devices that have the same
> issue.
>=20
> I realize that I covered a pretty wide swath by making the quirk appl=
y
> to all Intel Ethernet devices, but that still seems correct. The
> Skylake is not an issue because it does not have VPD so the
> pci_find_capability will fail before any handling of the quirk is
> possible. The code that applies the quirk could check specific
> devices, but it would make the code a lot bigger, and I see this kind
> of code as dead weight for so many systems that I tried to make it as
> small as possible. Since all Intel Ethernet seems to be correct now
> and as far as I can see into the future, that is what I did.
>=20
> Going back to something you mentioned before, I think you are right
> that the failure case for the pci_vpd_f0_dev_check could be made to
> simply clear the quirk and continue, since pci_vpd_f0_dev_check reall=
y
> should not fail in cases where the quirk is applicable. That does see=
m
> like a reasonable change to me the more I think about it.
>=20
> I think a whitelist would be unnecessary dead weight.

Yep, a whitelist is probably not the way to go.  AFAICT, you're looking
for plugin-cards where all the functions meet the criteria of having th=
e
same class, vendor, and device ID.  If we don't meet that criteria, the=
n
it's not a device we're expecting and we should leave it alone.

Also, rather than clearing the flag, can we move the tests done by
pci_vpd_f0_dev_check() into the
quirk setup function?  It seems like function 0 should be sufficiently
configured by the time we're probing non-zero functions that we can be
more selective in setting the flag rather than unsetting it later.
Thanks,

Alex
