From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH net-next 1/4] ixgbe: sparc: rename the
 ARCH_WANT_RELAX_ORDER to IXGBE_ALLOW_RELAXED_ORDER
Date: Fri, 28 Apr 2017 18:42:36 +0000
Message-ID: <MWHPR12MB1600E090394DD648BC27E0FFC8130@MWHPR12MB1600.namprd12.prod.outlook.com>
References: <20170401.112603.1991545644693496714.davem@davemloft.net>
         <42428725-89f1-1508-4e3d-723e087b3bbb@huawei.com>
         <EE11001F9E5DDD47B7634E2F8A612F2E205199C0@FRAEML521-MBX.china.huawei.com>
         <063D6719AE5E284EB5DD2968C1650D6DCFFD3C52@AcuExch.aculab.com>
         <DB5PR05MB138288172B04713EB0C1DB55D3190@DB5PR05MB1382.eurprd05.prod.outlook.com>
         <a2239141-a185-1bb8-0abd-7a05b9fde015@huawei.com>
         <CAKgT0Uc4L=GgYbpO-Fm9OfN+_fLypbDP1c+X4T_ta90ecQiyGQ@mail.gmail.com>
         <20170427171938.GA10705@bhelgaas-glaptop.roam.corp.google.com>,<1493369471.13947.11.camel@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        Ding Tianhong <dingtianhong@huawei.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Amir Ancel <amira@mellanox.com>,
        Gabriele Paoloni <gabriele.paoloni@huawei.com>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        LinuxArm <linuxarm@huawei.com>,
        David Laight <David.Laight@aculab.com>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Robin Murphy <robin.murphy@arm.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>
To: Lucas Stach <l.stach@pengutronix.de>,
        Bjorn Helgaas <helgaas@kernel.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1493369471.13947.11.camel@pengutronix.de>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

| From: Lucas Stach <l.stach@pengutronix.de>
| Sent: Friday, April 28, 2017 1:51 AM
|    =20
| Am Donnerstag, den 27.04.2017, 12:19 -0500 schrieb Bjorn Helgaas:
| >=20
| >=20
| > I thought Relaxed Ordering was an optimization.  Are there cases where
| > it is actually required for correct behavior?
|=20
| Yes, at least the Tegra 2 TRM claims that RO needs to be enabled on the
| device side for correct operation with the following language:
|=20
| "Tegra 2 requires relaxed ordering for responses to downstream requests
| (responses can pass writes). It is possible in some circumstances for PCI=
e
| transfers from an external bus masters (i.e. upstream transfers) to becom=
e
| blocked by a downstream read or non-posted write. The responses to these
| downstream requests are blocked by upstream posted writes only when PCIe
| strict ordering is imposed. It is therefore necessary to never impose str=
ict
| ordering that would block a response to a downstream NPW/read request and
| always set the relaxed ordering bit to 1. Only devices that are capable o=
f
| relaxed ordering may be used with Tegra 2 devices."

  (woof) Reading through the above paragraph is difficult because the autho=
r
seems to shift language and terminology mid sentence and isn't following
standard PCI terminology conventions.  The Root Complex is "Upstream", a
non-Root Complex Node in the PCIe Fabric is "Downstream", Requests that a
Downstream Device (End Point) send to the Root Complex are called "Upstream
Requests", responses that the Root Complex send to a Device are called
"Downstream Responses" (or, even more pedantically, "Responses sent
Downstream for an earlier Upstream Request").

  Because a Root Complex is Upstream, but the Requests it sent Downstream,
and Downstream Devices send their Requests Upstream, it's very important
that we use exceedingly precise language.

  So, it ~sounds like~ the nVidia Tegra 2 document is talking about the nee=
d
for Downstream Devices to echo the Relaxed Ordering Attribute in their
Responses directed Upstream to Requests sent Downstream from the Root
Complex.  Moreover, there's code in drivers/pci/host/pci-tegra.c:
tegra_pcie_relax_enable() which appears to set the PCIe Capability Device
Control[Enable Relaxed Ordering] bit on all PCIe Fabric Nodes.

  If my reading of the intent of the nVidia document is correct -- and
that's a Big If because of the extremely imprecise language used -- that
means that the tegra_pcie_relax_enable() is completely bogus.  The PCIe 3.0
Specification states that Responses MUST reflect the Relaxed Ordering and N=
o
Snoop Attributes of the Requests for which they are responding.  Section
2.2.9 of PCI Express(r) Base Specification Revision 3.0 November 10, 2010:
"Completion headers must supply the same values for the Attribute as were
supplied in the header of the corresponding Request, except as explicitly
allowed when IDO is used."

  And, specifically, the PCIe Capability Device Control[Enable Relaxed
Ordering] bit _only_ affects the ability of that Device to originate
Transaction Layer Packet Requests with the Relaxed Ordering Attribute set.
Thus, tegra_pcie_relax_enable() setting those bits on all the Downstream
Devices (and intervening Bridges) does not _cause_ those Devices to generat=
e
Requests with Relaxed Ordering set.  And, if the Devices are PCIe 3.0
compliant, it also doesn't affect the Responses that they send back Upstrea=
m
to the Root Complex.

  I apologize for the incredibly detailed nature of these responses, but
it's very easy for people new to PCIe to get these things wrong and/or
misinterpret the PCIe Specifications.

Casey
