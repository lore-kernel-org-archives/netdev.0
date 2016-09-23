From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 5/5] PCI: disable FLR for 82579 device
Date: Fri, 23 Sep 2016 14:05:26 -0700
Message-ID: <1474664726.2389.7.camel@intel.com>
References: <1474612741-75681-1-git-send-email-jeffrey.t.kirsher@intel.com>
         <1474612741-75681-6-git-send-email-jeffrey.t.kirsher@intel.com>
         <20160923140136.GC1514@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-6rZG+nE6UJJ23m524nQR"
Cc: davem@davemloft.net, bhelgaas@google.com,
        Sasha Neftin <sasha.neftin@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com, linux-pci@vger.kernel.org
To: Bjorn Helgaas <helgaas@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:31818 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753235AbcIWVFc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 17:05:32 -0400
In-Reply-To: <20160923140136.GC1514@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-6rZG+nE6UJJ23m524nQR
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-09-23 at 09:01 -0500, Bjorn Helgaas wrote:
> On Thu, Sep 22, 2016 at 11:39:01PM -0700, Jeff Kirsher wrote:
> >=20
> > From: Sasha Neftin <sasha.neftin@intel.com>
> >=20
> > 82579 has a problem reattaching itself after the device is detached.
> > The bug was reported by Redhat. The suggested fix is to disable
> > FLR capability in PCIe configuration space.
> >=20
> > Reproduction:
> > Attach the device to a VM, then detach and try to attach again.
> >=20
> > Fix:
> > Disable FLR capability to prevent the 82579 from hanging.
>=20
> Is there a bugzilla or other reference URL to include here?=C2=A0=C2=A0Sh=
ould
> this be marked for stable?

So the author is in Israel, meaning it is their weekend now. =C2=A0I do not
believe Sasha monitors email over the weekend, so a response to your
questions won't happen for a few days.

I tried searching my archives for more information, but had no luck finding
any additional information.

> > Signed-off-by: Sasha Neftin <sasha.neftin@intel.com>
> > Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> > =C2=A0drivers/pci/quirks.c | 21 +++++++++++++++++++++
> > =C2=A01 file changed, 21 insertions(+)
> >=20
> > diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
> > index 44e0ff3..59fba6e 100644
> > --- a/drivers/pci/quirks.c
> > +++ b/drivers/pci/quirks.c
> > @@ -4431,3 +4431,24 @@ static void quirk_intel_qat_vf_cap(struct
> > pci_dev *pdev)
> > =C2=A0	}
> > =C2=A0}
> > =C2=A0DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_INTEL, 0x443,
> > quirk_intel_qat_vf_cap);
> > +/*
> > + * Workaround FLR issues for 82579
> > + * This code disables the FLR (Function Level Reset) via PCIe, in
> > order
> > + * to workaround a bug found while using device passthrough, where the
> > + * interface would become non-responsive.
> > + * NOTE: the FLR bit is Read/Write Once (RWO) in config space, so if
> > + * the BIOS or kernel writes this register * then this workaround will
> > + * not work.
>=20
> This doesn't sound like a root cause.=C2=A0=C2=A0Is the issue a hardware
> erratum?=C2=A0=C2=A0Linux PCI core bug?=C2=A0=C2=A0VFIO bug?=C2=A0=C2=A0D=
evice firmware bug?
>=20
> The changelog suggests that the problem only affects passthrough,
> which suggests some sort of kernel bug related to how passthrough is
> implemented.
>=20
> >=20
> > + */
> > +static void quirk_intel_flr_cap_dis(struct pci_dev *dev)
> > +{
> > +	int pos =3D pci_find_capability(dev, PCI_CAP_ID_AF);
> > +	if (pos) {
> > +		u8 cap;
> > +		pci_read_config_byte(dev, pos + PCI_AF_CAP, &cap);
> > +		cap =3D cap & (~PCI_AF_CAP_FLR);
> > +		pci_write_config_byte(dev, pos + PCI_AF_CAP, cap);
> > +	}
> > +}
> > +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_INTEL, 0x1502,
> > quirk_intel_flr_cap_dis);
> > +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_INTEL, 0x1503,
> > quirk_intel_flr_cap_dis);
> > --=C2=A0
> > 2.7.4
> >=20
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-pci" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at=C2=A0=C2=A0http://vger.kernel.org/majordomo-info=
.html

--=-6rZG+nE6UJJ23m524nQR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJX5ZkWAAoJEOVv75VaS+3OBWcQAJLEgTVx2fAXP30EyNtL9y0p
Da7A33HKyJr3RzKnZCj9wFPnmOO6nuZVcRdDNfd/CBAIw0pNv8/2bpfHKMbGyLMy
vzEiPrNxps1s6CwjqXByduDsLBU94j/iYYLRYuN7QR7EIm1oeWmwTIfod6k68aQt
eJFc5dQoGF5VDRi1SEvz0UBM5hFw1+6rtT7ezcHgBNbnT6R7HX1jvb5AbD8bnH5c
5QjRDMXbsjB9C8mVbdR3SCa7w7m7Iw/Q/29dSiEJ0o9fsI4xrMm0J/yojeO/dxjX
et3QlqHnaW9xSNWCB64HdHcb2xGOD9B8WLv8QzQDJFskNbXCVtyrCmy1nFgBmhLH
jOeZ5QsKJAOEHWulh/rgNd7W2vpqymSrcbgO1tyr0ShLGN+Ry+RrGZeoN5bEJ5Xj
3SAJkuUdD0f/tDmHwdgOPLeonfOKHGSy1vS8byaWjxjfMdommvDuPL8fB6b3sIdy
faNhUabbcNu5O/k75pxLgRuzpt/2SofyeGt3ceKvbWRHmf+y+befWwhMSgrM8KT8
+oT2PnaI6CsKHirS8kMsqdvCvCmhjbW8z9sGf7SvBfAC87a05U5/Cr2pgvkJx4Z6
uPXKQFnnDz7p4+UJvSOWsfmeARAAQ0E5YoeAvUqoym0W1WLYOCtoHotec4i6wh5/
NqMbJn4KKXah6SJwQUIc
=0NCx
-----END PGP SIGNATURE-----

--=-6rZG+nE6UJJ23m524nQR--
