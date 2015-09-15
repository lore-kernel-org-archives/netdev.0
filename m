From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [PATCH V4 1/2] pci: Add dev_flags bit to access VPD through
 function 0
Date: Tue, 15 Sep 2015 13:04:20 -0600
Message-ID: <1442343860.23936.141.camel@redhat.com>
References: <20150713183821.19985.52157.stgit@mdrustad-wks.jf.intel.com>
	 <20150713184001.19985.64867.stgit@mdrustad-wks.jf.intel.com>
	 <1442341152.23936.122.camel@redhat.com>
	 <F17F8A11-FB09-4131-A404-DE106F3944BB@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "bhelgaas@google.com" <bhelgaas@google.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Myron Stowe <myron.stowe@redhat.com>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51041 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750965AbbIOTEV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2015 15:04:21 -0400
In-Reply-To: <F17F8A11-FB09-4131-A404-DE106F3944BB@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-09-15 at 18:39 +0000, Rustad, Mark D wrote:
> > On Sep 15, 2015, at 11:19 AM, Alex Williamson <alex.williamson@redh=
at.com> wrote:
> >=20
> > In addition to the (PCI_SLOT() !=3D devfn) issue, I'm concerned abo=
ut
> > topologies like we see on Skylake.  IIRC, the integrated NIC appear=
s at
> > something like 00:1f.6.  I don't know if that specific NIC has VPD,=
 nor
> > am I sure it really matter because another example or some future
> > version might.  So we'll set the PCI_DEV_FLAGS_VPD_REF_F0 because w=
e do
> > so for all (PCI_FUNC() !=3D 0) Intel NICs, we'll call
> > pci_vpd_f0_dev_check(), which will error because function 0 has a
> > different class code and device ID, so we return error and if VPD e=
xists
> > on the device, it's now inaccessible.
>=20
> Yes, that is exactly what would happen.
>=20
> > I thought there was talk about whitelisting anything on the root bu=
s to
> > avoid strange root complex integrated devices (and perhaps avoid th=
e
> > general case for assigned devices within a VM), but I don't see any=
thing
> > like that here.
>=20
> I hadn't heard that talk, but I'm not on the PCI list and I guess I
> wasn't copied.
>=20
> > Perhaps instead of failing and hiding VPD we should fail, clear the
> > flag, and allow normal access.  Thanks,
>=20
> Because the purpose of VPD is to hold information about the device, I
> would suggest that VPD should never be provided for an embedded
> network device, but rather for the device as a whole. So while there
> may well be VPD for an SOC, that VPD should not be associated with on=
e
> of its embedded devices, but rather something more appropriate for th=
e
> device as a whole. And attaching VPD to a whole bunch of internal
> devices would just be madness.

=46RU-type information is only one of the use cases of VPD, the spec al=
so
defines (PCI rev 3.0, 6.4):

        ... a mechanism for storing information such as performance and
        failure data on the device being monitored.

That information could very much be function specific.

> So I understand the concern, but I don't think that it should really
> happen in real systems. I did think about this case when I was workin=
g
> on the patches. A networking device should really only have VPD when
> it is its own physical device, such as a NIC.
>=20

When I was looking at whether we should provide VPD access of an
assigned device at all, I ran across this interesting statement in the
PCI spec (rev 3.0, I.3.1.1):

        CP Extended Capability

        This field allows a new capability to be identified in the VPD
        area. Since dynamic control/status cannot be placed in VPD, the
        data for this field identifies where, in the device=E2=80=99s m=
emory or
        I/O address space, the control/status registers for the
        capability can be found. Location of the control/status
        registers is identified by providing the index (a value between
        0 and 5) of the Base Address register that defines the address
        range that contains the registers, and the offset within that
        Base Address register range where the control/status registers
        reside. The data area for this field is four bytes long. The
        first byte contains the ID of the extended capability. The
        second byte contains the index (zero based) of the Base Address
        register used. The next two bytes contain the offset (in
        little-endian order) within that address range where the
        control/status registers defined for that capability reside.

Again, this sounds like function specific data, and both here and above=
,
blocking access to VPD could affect the functionality of drivers.  It
may be the case that Intel would find this use to be madness, but
there's no PCI spec requirement that separate functions are in any way
similar and we're looking at an interface that may be used by non-Intel
devices as well.  Thanks,

Alex
