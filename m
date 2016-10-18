From: "Koehrer Mathias (ETAS/ESW5)" <mathias.koehrer@etas.com>
Subject: RE: Kernel 4.6.7-rt13: Intel Ethernet driver igb causes huge
 latencies in cyclictest
Date: Tue, 18 Oct 2016 08:43:56 +0000
Message-ID: <2c1c6a2b71ce476aa8495f22bb32e1e5@FE-MBX1012.de.bosch.com>
References: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D8045E418@FMSMSX113.amr.corp.intel.com>
 <29250f87b1d84aacb8aa312935582291@FE-MBX1012.de.bosch.com>
 <20161010193958.GE22235@jcartwri.amer.corp.natinst.com>
 <e9661abf93194ad3849e3864a8361993@FE-MBX1012.de.bosch.com>
 <b77ea8ab312149d2b20a717d3ab0a8dc@FE-MBX1012.de.bosch.com>
 <20161013161839.GV10625@jcartwri.amer.corp.natinst.com>
 <f395ea6cd1274fac83d2744121da7441@FE-MBX1012.de.bosch.com>
 <20161014195536.GB27124@jcartwri.amer.corp.natinst.com>
 <82dcd5bb210f4f82af1e88313c3ec742@FE-MBX1012.de.bosch.com>
 <CAKgT0Uf-F9V+AeP0+92Gf=40Tye-687_GFbhp4Sex=Hat+Ha+w@mail.gmail.com>
 <20161017183209.GA18465@jcartwri.amer.corp.natinst.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
        boundary="_003_2c1c6a2b71ce476aa8495f22bb32e1e5FEMBX1012deboschcom_"
Cc: Bjorn Helgaas <helgaas@kernel.org>,
        "linux-rt-users@vger.kernel.org" <linux-rt-users@vger.kernel.org>,
        Sebastian Andrzej Siewior <sebastian.siewior@linutronix.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        Matthew Garrett <mjg59@coreos.com>,
        "Bjorn Helgaas" <bhelgaas@google.com>, Greg <gvrose8192@gmail.com>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: Julia Cartwright <julia@ni.com>,
        Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <20161017183209.GA18465@jcartwri.amer.corp.natinst.com>
Content-Language: de-DE
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--_003_2c1c6a2b71ce476aa8495f22bb32e1e5FEMBX1012deboschcom_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi all,

> > >>
> > >> Can you continue your bisection using 'git bisect'?  You've already
> > >> narrowed it down between 4.0 and 4.1, so you're well on your way.
> > >>
> > >
> > > OK - done.
> > > And finally I was successful!
> > > The following git commit is the one that is causing the trouble!
> > > (The full commit is in the attachment).
> > > +++++++++++++++++++++ BEGIN +++++++++++++++++++++++++++
> > > commit 387d37577fdd05e9472c20885464c2a53b3c945f
> > > Author: Matthew Garrett <mjg59@coreos.com>
> > > Date:   Tue Apr 7 11:07:00 2015 -0700
> > >
> > >     PCI: Don't clear ASPM bits when the FADT declares it's
> > > unsupported
> > >
> > >     Communications with a hardware vendor confirm that the expected
> behaviour
> > >     on systems that set the FADT ASPM disable bit but which still gra=
nt full
> > >     PCIe control is for the OS to leave any BIOS configuration intact=
 and
> > >     refuse to touch the ASPM bits.  This mimics the behaviour of Wind=
ows.
> > >
> > >     Signed-off-by: Matthew Garrett <mjg59@coreos.com>
> > >     Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
> > > +++++++++++++++++++++ HEADER +++++++++++++++++++++++++++
> > >
> > > The only files that are modified by this commit are
> > > drivers/acpi/pci_root.c drivers/pci/pcie/aspm.c
> > > include/linux/pci-aspm.h
> > >
> > > This is all generic PCIe stuff - however I do not really understand
> > > what the changes of the commit are...
> > >
> > > In my setup I am using a dual port igb Ethernet adapter.
> > > This has an onboard PCIe switch and it might be that the
> > > configuration of this PCIe switch on the Intel board is causing the t=
rouble.
> > >
> > > Please see also the output of "lspci -v" in the attachment.
> > > The relevant PCI address of the NIC is 04:00.0 / 04:00.1
> > >
> > Hi Mathias,
> >
> > If you could set the output of lspci -vvv it might be more useful as
> > most of the configuration data isn't present in the lspci dump you had
> > attached.  Specifically if you could do this for the working case and
> > the non-working case we could verify if this issue is actually due to
> > the ASPM configuration on the device.
> >
> > Also one thing you might try is booting your kernel with the kernel
> > parameter "pcie_aspm=3Doff".  It sounds like the extra latency is likel=
y
> > due to your platform enabling ASPM on the device and this in turn will
> > add latency if the PCIe link is disabled when you attempt to perform a
> > read as it takes some time to bring the PCIe link up when in L1 state.
>=20
> So if we assume it's this commit causing the regression, then it's safe t=
o assume that
> this system's BIOS is claiming to not support ASPM in the FADT, but the B=
IOS is
> leaving ASPM configured in some way on the relevant devices.
>=20
> Also, unfortunately, taking a look at the code which handles "pcie_aspm=
=3Doff", it
> won't be sufficient to disable ASPM on these this system, as disabling th=
ese states is
> skipped when the FADT doesn't advertise ASPM support.
>=20
> What would be needed is an option like "force", but which force _disables=
_ ASPM.
> "force-disable", maybe.
>=20

OK, I have now built a "good" kernel=20
(using commit 37a9c502c0af013aaae094556830100c2bb133ac) and
a "bad" kernel
(using commit 387d37577fdd05e9472c20885464c2a53b3c945f).

Please find attached the outputs of "lspci -vvv" for both cases.
As assumed, in the "bad" case, the PCIe switch on the NIC board and the
two Ethernet controllers show "ASPM L1 Enabled" in "LnkCtl".
In the "good" case this is "ASPM disabled".

I tried also the kernel option "pcie_aspm=3Doff" in the "bad" case.
However this had no impact, the issue still occurred!


Switching to kernel 4.8 I set the configuration for=20
"Default ASPM policy" to CONFIG_PCIEASPM_PERFORMANCE
however this did not show any effect.=20
This in contrast to the help text provided in the kernel configuration:
"Disable PCI Express ASPM L0s and L1, even if the BIOS enabled them."

For me the first step should be to make the CONFIG_PCIEASPM_PERFORMANCE
work as expected: It this is set, the ASPM should be forced to be disabled.
This is currently not the case.

During the boot phase I see in dmesg:=20
"ACPI FADT declares the system doesn't support PCIe ASPM, so disable it"
This leads to a call of pcie_no_aspm() and this sets the aspm_policy to POL=
ICY_DEFAULT
instead to the value that has been selected in the kernel configuration.

The following patch fixes the issue for me on kernel 4.8.
The config value CONFIG_PCIEASPM_PERFORMANCE is considered correctly.

+++++++++++++++++++++++ BEGIN +++++++++++++++++++
Consider the CONFIG_PCIEASPM_* values within pcie_no_aspm().

Signed-off-by: Mathias Koehrer <mathias.koehrer@etas.com>

---
 drivers/pci/pcie/aspm.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

Index: linux-4.8/drivers/pci/pcie/aspm.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-4.8.orig/drivers/pci/pcie/aspm.c
+++ linux-4.8/drivers/pci/pcie/aspm.c
@@ -79,10 +79,13 @@ static LIST_HEAD(link_list);
=20
 #ifdef CONFIG_PCIEASPM_PERFORMANCE
 static int aspm_policy =3D POLICY_PERFORMANCE;
+static int aspm_default_config_policy =3D POLICY_PERFORMANCE;
 #elif defined CONFIG_PCIEASPM_POWERSAVE
 static int aspm_policy =3D POLICY_POWERSAVE;
+static int aspm_default_config_policy =3D POLICY_POWERSAFE;
 #else
 static int aspm_policy;
+static int aspm_default_config_policy;
 #endif
=20
 static const char *policy_str[] =3D {
@@ -946,7 +949,7 @@ void pcie_no_aspm(void)
 	 * (b) prevent userspace from changing policy
 	 */
 	if (!aspm_force) {
-		aspm_policy =3D POLICY_DEFAULT;
+		aspm_policy =3D aspm_default_config_policy;
 		aspm_disabled =3D 1;
 	}
 }
+++++++++++++++++++++++ END +++++++++++++++++++

Apart from that a kernel parameter - as proposed by Julia - like
"pcie_aspm=3Dforce-disable" would be helpful as well.

Any feedback is welcome!

Regards

Mathias


--_003_2c1c6a2b71ce476aa8495f22bb32e1e5FEMBX1012deboschcom_
Content-Type: application/x-gzip; name="lspci.bad.gz"
Content-Description: lspci.bad.gz
Content-Disposition: attachment; filename="lspci.bad.gz"; size=5127;
	creation-date="Tue, 18 Oct 2016 08:07:38 GMT";
	modification-date="Tue, 18 Oct 2016 06:11:43 GMT"
Content-Transfer-Encoding: base64

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

--_003_2c1c6a2b71ce476aa8495f22bb32e1e5FEMBX1012deboschcom_
Content-Type: application/x-gzip; name="lspci.good.gz"
Content-Description: lspci.good.gz
Content-Disposition: attachment; filename="lspci.good.gz"; size=5123;
	creation-date="Tue, 18 Oct 2016 08:07:38 GMT";
	modification-date="Tue, 18 Oct 2016 06:03:37 GMT"
Content-Transfer-Encoding: base64

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

--_003_2c1c6a2b71ce476aa8495f22bb32e1e5FEMBX1012deboschcom_--

