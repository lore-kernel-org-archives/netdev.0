From: Brice Goglin <brice@myri.com>
Subject: Re: [PATCH][BNX2]: Disable MSI on 5706 if AMD 8132 bridge is present
Date: Sat, 30 Sep 2006 12:13:34 +0200
Message-ID: <451E434E.5040500@myri.com>
References: <1159564053.3741.19.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:65190 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S1750723AbWI3KNj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2006 06:13:39 -0400
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <1159564053.3741.19.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan a =E9crit :
> AMD believes this incompatibility is unique to the 5706, and
> prefers to locally disable MSI rather than globally disabling it
> using pci_msi_quirk.
>  =20

=46YI, pci_msi_quirk is the extreme solution, there is something in the
middle :) It is possible to disable MSI for only devices that are behin=
d
this bridge (by setting the NO_MSI flag in its bus flag). We just merge=
d
a couple patchs related to this NO_MSI flag and pci_msi_quirk (there ar=
e
very very few cases where MSI must be disabled globally, most of the
time a subset behind a bridge is enough) so I am very glad that you
didn't use it :)
Anyway, disabling locally is better here.

> +	if (CHIP_NUM(bp) =3D=3D CHIP_NUM_5706 && disable_msi =3D=3D 0) {
> +		struct pci_dev *amd_8132 =3D NULL;
> +
> +		while ((amd_8132 =3D pci_get_device(PCI_VENDOR_ID_AMD,
> +						  PCI_DEVICE_ID_AMD_8132_BRIDGE,
> +						  amd_8132))) {
>  =20

What if the machine has such a bridge and board, but the board is not
actually located somewhere behind the bridge? I would rather walk the
PCI hierarchy from the board to the top and check whether we find a
AMD8132. Probably something like:

	struct pci_dev * bridge =3D <the bnx2 pci_dev>;
	while (bridge->bus && bridge->bus->self)
		bridge =3D bridge->bus->self;
		if (bridge->vendor =3D=3D PCI_VENDOR_ID_AMD
		    && bridge->device =3D=3D PCI_VENDOR_ID_AMD_8132_BRIDGE)
			<do your stuff to disable MSI on your board>


Brice

