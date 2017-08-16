From: Thierry Reding <thierry.reding@gmail.com>
Subject: Re: [PATCH net RESEND] PCI: fix oops when try to find Root Port for
 a PCI device
Date: Wed, 16 Aug 2017 21:33:03 +0200
Message-ID: <20170816193303.GA14147@ulmo>
References: <1502810688-12420-1-git-send-email-dingtianhong@huawei.com>
 <20170815170331.GA4099@bhelgaas-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="8t9RHnE3ZwKMSgU+"
Cc: Ding Tianhong <dingtianhong@huawei.com>, mark.rutland@arm.com,
        gabriele.paoloni@huawei.com, asit.k.mallick@intel.com,
        catalin.marinas@arm.com, will.deacon@arm.com, linuxarm@huawei.com,
        alexander.duyck@gmail.com, ashok.raj@intel.com,
        eric.dumazet@gmail.com, jeffrey.t.kirsher@intel.com,
        linux-pci@vger.kernel.org, ganeshgr@chelsio.com, Bob.Shaw@amd.com,
        leedom@chelsio.com, patrick.j.cramer@intel.com,
        bhelgaas@google.com, werner@chelsio.com,
        linux-arm-kernel@lists.infradead.org, amira@mellanox.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        David.Laight@aculab.com, Suravee.Suthikulpanit@amd.com,
        robin.murphy@arm.com, davem@davemloft.net, l.stach@pengutronix.de
To: Bjorn Helgaas <helgaas@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170815170331.GA4099@bhelgaas-glaptop.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--8t9RHnE3ZwKMSgU+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Aug 15, 2017 at 12:03:31PM -0500, Bjorn Helgaas wrote:
> On Tue, Aug 15, 2017 at 11:24:48PM +0800, Ding Tianhong wrote:
> > Eric report a oops when booting the system after applying
> > the commit a99b646afa8a ("PCI: Disable PCIe Relaxed..."):
> > ...
>=20
> > It looks like the pci_find_pcie_root_port() was trying to
> > find the Root Port for the PCI device which is the Root
> > Port already, it will return NULL and trigger the problem,
> > so check the highest_pcie_bridge to fix thie problem.
>=20
> The problem was actually with a Root Complex Integrated Endpoint that
> has no upstream PCIe device:
>=20
>   00:05.2 System peripheral: Intel Corporation Device 0e2a (rev 04)
>         Subsystem: Intel Corporation Device 0e2a
>         Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParEr=
r- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- =
<TAbort- <MAbort- >SERR- <PERR- INTx-
>         Capabilities: [40] Express (v2) Root Complex Integrated Endpoint,=
 MSI 00
>                 DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <6=
4ns, L1 <1us
>                         ExtTag- RBE- FLReset-
>                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal+ Uns=
upported+
>                         RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
>                         MaxPayload 128 bytes, MaxReadReq 128 bytes

I've started seeing this crash on Tegra K1 as well. Here's the device
for which it oopses:

00:02.0 PCI bridge: NVIDIA Corporation TegraK1 PCIe x1 Bridge (rev a1) (pro=
g-if 00 [Normal decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+=
 Stepping- SERR+ FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 391
        Bus: primary=3D00, secondary=3D01, subordinate=3D01, sec-latency=3D0
        I/O behind bridge: 00001000-00001fff [size=3D4K]
        Memory behind bridge: 13000000-130fffff [size=3D1M]
        Prefetchable memory behind bridge: 0000000020000000-00000000200ffff=
f [size=3D1M]
        Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort- <MAbort- <SERR- <PERR-
        BridgeCtl: Parity+ SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
                PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
        Capabilities: [40] Subsystem: NVIDIA Corporation TegraK1 PCIe x1 Br=
idge
        Capabilities: [48] Power Management version 3
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0+,D1+,D2=
+,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
        Capabilities: [50] MSI: Enable+ Count=3D1/2 Maskable- 64bit+
                Address: 000000fcfffff000  Data: 0000
        Capabilities: [60] HyperTransport: MSI Mapping Enable- Fixed-
                Mapping Address Base: 00000000fee00000
        Capabilities: [80] Express (v2) Root Port (Slot+), MSI 00
                DevCap: MaxPayload 128 bytes, PhantFunc 0
                        ExtTag+ RBE+
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsup=
ported-
                        RlxdOrd+ ExtTag+ PhantFunc- AuxPwr- NoSnoop+
                        MaxPayload 128 bytes, MaxReadReq 512 bytes
                DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- Tr=
ansPend-
                LnkCap: Port #1, Speed 5GT/s, Width x1, ASPM L0s, Exit Late=
ncy L0s <512ns
                        ClockPM- Surprise- LLActRep+ BwNot+ ASPMOptComp-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk+
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLA=
ctive+ BWMgmt+ ABWMgmt-
                SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Su=
rprise-
                        Slot #0, PowerLimit 0.000W; Interlock- NoCompl-
                SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPI=
rq- LinkChg-
                        Control: AttnInd Off, PwrInd On, Power- Interlock-
                SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ I=
nterlock-
                        Changed: MRL- PresDet+ LinkState+
                RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna+=
 CRSVisible-
                RootCap: CRSVisible-
                RootSta: PME ReqID 0000, PMEStatus- PMEPending-
                DevCap2: Completion Timeout: Range AB, TimeoutDis+, LTR-, O=
BFF Not Supported ARIFwd-
                         AtomicOpsCap: Routing- 32bit- 64bit- 128bitCAS-
                DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR=
-, OBFF Disabled ARIFwd-
                         AtomicOpsCtl: ReqEn- EgressBlck-
                LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- Speed=
Dis-
                         Transmit Margin: Normal Operating Range, EnterModi=
fiedCompliance- ComplianceSOS-
                         Compliance De-emphasis: -6dB
                LnkSta2: Current De-emphasis Level: -3.5dB, EqualizationCom=
plete-, EqualizationPhase1-
                         EqualizationPhase2-, EqualizationPhase3-, LinkEqua=
lizationRequest-
        Kernel driver in use: pcieport

> > Fixes: a99b646afa8a ("PCI: Disable PCIe Relaxed Ordering if unsupported=
")
>=20
> This also
>=20
> Fixes: c56d4450eb68 ("PCI: Turn off Request Attributes to avoid Chelsio T=
5 Completion erratum")
>=20
> which added pci_find_pcie_root_port().  Prior to this Relaxed Ordering
> series, we only used pci_find_pcie_root_port() in a Chelsio quirk that
> only applied to non-integrated endpoints, so we didn't trip over the
> bug.
>=20
> > Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> > ---
> >  drivers/pci/pci.c | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> >=20
> > diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
> > index af0cc34..7e2022f 100644
> > --- a/drivers/pci/pci.c
> > +++ b/drivers/pci/pci.c
> > @@ -522,7 +522,8 @@ struct pci_dev *pci_find_pcie_root_port(struct pci_=
dev *dev)
> >  		bridge =3D pci_upstream_bridge(bridge);
> >  	}
> > =20
> > -	if (pci_pcie_type(highest_pcie_bridge) !=3D PCI_EXP_TYPE_ROOT_PORT)
> > +	if (highest_pcie_bridge &&
> > +	    pci_pcie_type(highest_pcie_bridge) !=3D PCI_EXP_TYPE_ROOT_PORT)
> >  		return NULL;
> > =20
> >  	return highest_pcie_bridge;
> > --=20
>=20
> I think structuring the fix as follows is a little more readable:
>=20
> diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
> index af0cc3456dc1..587cd7623ed8 100644
> --- a/drivers/pci/pci.c
> +++ b/drivers/pci/pci.c
> @@ -522,10 +522,11 @@ struct pci_dev *pci_find_pcie_root_port(struct pci_=
dev *dev)
>  		bridge =3D pci_upstream_bridge(bridge);
>  	}
> =20
> -	if (pci_pcie_type(highest_pcie_bridge) !=3D PCI_EXP_TYPE_ROOT_PORT)
> -		return NULL;
> +	if (highest_pcie_bridge &&
> +	    pci_pcie_type(highest_pcie_bridge) =3D=3D PCI_EXP_TYPE_ROOT_PORT)
> +		return highest_pcie_bridge;
> =20
> -	return highest_pcie_bridge;
> +	return NULL;
>  }
>  EXPORT_SYMBOL(pci_find_pcie_root_port);

In case of Tegra, dev actually points to the root port. Now if I read
the above code correctly, highest_pcie_bridge will still be NULL in that
case, which in turn will return NULL from pci_find_pcie_root_port(). But
shouldn't it really return dev?

The patch that I used to fix the issue is this:

--->8---
diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
index 2c712dcfd37d..dd56c1c05614 100644
--- a/drivers/pci/pci.c
+++ b/drivers/pci/pci.c
@@ -514,7 +514,7 @@ EXPORT_SYMBOL(pci_find_resource);
  */
 struct pci_dev *pci_find_pcie_root_port(struct pci_dev *dev)
 {
-       struct pci_dev *bridge, *highest_pcie_bridge =3D NULL;
+       struct pci_dev *bridge, *highest_pcie_bridge =3D dev;
=20
        bridge =3D pci_upstream_bridge(dev);
        while (bridge && pci_is_pcie(bridge)) {
--->8---

That works correctly if this function ends up being called on the PCIe
root port, though perhaps that's not what this function is supposed to
do. It's somewhat unclear from the kerneldoc what the function should
be doing when called on a root port device itself.

Thierry

--8t9RHnE3ZwKMSgU+
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAlmUnesACgkQ3SOs138+
s6GBLg/9HY5b3a30fvxNknvsOYsP1Voypt2uW4u20f7CZCclsXNDQ/t1K0PQMuOh
ELLCt1dmkY/e5FHwnFfUcD5WpjPbY8J3KgXzCvmXz5w5o27uXYmt873VuBe7b11N
QOh+LngNMQ6vl6Bvd59uu9uRigxYmA66NmTDLWDsBY9tfmPDIfAuAPZyJ0FIXm1E
8boBY82DVi8Fp9AUxWkTRF+gsu0V4aKLE3YQ18XiUeZ21Mr0rwFICKsL/Sfq+98r
Ab2NmpKf1suYY5F4H8au0dTEGmKJo1KHF9vKlqK0XJlSeRpB9Jw4ldxo5IhtMA0V
XR4LRCpcpXH1goMTx03pd2ieilDH4i+LT5uvPdBRrDq8Pxu05TiO0ixz7BmpTW5G
ypdaP5E+3xiOBcuUFcGVxisKirSBuDxBAi9K+lGc510/rqsBFmR4fPJ3l5G57YlI
YD/IMlrjaO364TElLH7X4CJE0IRk251XqwBLW1WFMOjW/meZsTl1M4oAW2Gfimn+
nmWASva6Cn1W3cc3dTVoFgGfXxbW1VQIHPQDNkOeXQ8pOEzrt8JmQI2K7TMrDwZD
iJajrvdOplDBJwnVErorEWv8fB70MEPBex0U7qbA6Z6Lcm/XRcWeMejOFxCr8o8p
EmgOA83OasH/9fYxZwGTF/uRQo6/kCgfUFu/MrfPQzBPP0RJUpA=
=tFfC
-----END PGP SIGNATURE-----

--8t9RHnE3ZwKMSgU+--
