From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH v9 1/4] PCI: Add new PCIe Fabric End Node flag,
 PCI_DEV_FLAGS_NO_RELAXED_ORDERING
Date: Wed, 9 Aug 2017 01:40:01 +0000
Message-ID: <MWHPR12MB1600249E96C320D5472F77ADC88B0@MWHPR12MB1600.namprd12.prod.outlook.com>
References: <1501917313-9812-1-git-send-email-dingtianhong@huawei.com>
 <1501917313-9812-2-git-send-email-dingtianhong@huawei.com>,<20170808232200.GO16580@bhelgaas-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "ashok.raj@intel.com" <ashok.raj@intel.com>,
        "bhelgaas@google.com" <bhelgaas@google.com>,
        Michael Werner <werner@chelsio.com>,
        Ganesh GR <ganeshgr@chelsio.com>,
        "asit.k.mallick@intel.com" <asit.k.mallick@intel.com>,
        "patrick.j.cramer@intel.com" <patrick.j.cramer@intel.com>,
        "Suravee.Suthikulpanit@amd.com" <Suravee.Suthikulpanit@amd.com>,
        "Bob.Shaw@amd.com" <Bob.Shaw@amd.com>,
        "l.stach@pengutronix.de" <l.stach@pengutronix.de>,
        "amira@mellanox.com" <amira@mellanox.com>,
        "gabriele.paoloni@huawei.com" <gabriele.paoloni@huawei.com>,
        "David.Laight@aculab.com" <David.Laight@aculab.com>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
        "catalin.marinas@arm.com" <catalin.marinas@arm.com>,
        "will.deacon@arm.com" <will.deacon@arm.com>,
        "mark.rutland@arm.com" <mark.r
To: Bjorn Helgaas <helgaas@kernel.org>,
        Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20170808232200.GO16580@bhelgaas-glaptop.roam.corp.google.com>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

| From: Bjorn Helgaas <helgaas@kernel.org>
| Sent: Tuesday, August 8, 2017 4:22 PM
|=20
| This needs to include a link to the Intel spec
| (https://software.intel.com/sites/default/files/managed/9e/bc/64-ia-32-ar=
chitectures-optimization-manual.pdf,
| sec 3.9.1).

  In the commit message or as a comment?  Regardless, I agree.  It's always
nice to be able to go back and see what the official documentation says.
However, that said, links on the internet are ... fragile as time goes by,
so we might want to simply quote section 3.9.1 in the commit message since
it's relatively short:

    3.9.1 Optimizing PCIe Performance for Accesses Toward Coherent Memory
          and Toward MMIO Regions (P2P)

    In order to maximize performance for PCIe devices in the processors
    listed in Table 3-6 below, the soft- ware should determine whether the
    accesses are toward coherent memory (system memory) or toward MMIO
    regions (P2P access to other devices). If the access is toward MMIO
    region, then software can command HW to set the RO bit in the TLP
    header, as this would allow hardware to achieve maximum throughput for
    these types of accesses. For accesses toward coherent memory, software
    can command HW to clear the RO bit in the TLP header (no RO), as this
    would allow hardware to achieve maximum throughput for these types of
    accesses.

    Table 3-6. Intel Processor CPU RP Device IDs for Processors Optimizing
               PCIe Performance

    Processor                            CPU RP Device IDs

    Intel Xeon processors based on       6F01H-6F0EH
    Broadwell microarchitecture

    Intel Xeon processors based on       2F01H-2F0EH
    Haswell microarchitecture

| It should also include a pointer to the AMD erratum, if available, or
| at least some reference to how we know it doesn't obey the rules.

  Getting an ACK from AMD seems like a forlorn cause at this point.  My
contact was Bob Shaw <Bob.Shaw@amd.com> and he stopped responding to me
messages almost a year ago saying that all of AMD's energies were being
redirected towards upcoming x86 products (likely Ryzen as we now know).  As
far as I can tell AMD has walked away from their A1100 (AKA "Seattle") ARM
SoC.

  On the specific issue, I can certainly write up somthing even more
extensive than I wrote up for the comment in drivers/pci/quirks.c.  Please
review the comment I wrote up and tell me if you'd like something even more
detailed -- I'm usually acused of writing comments which are too long, so
this would be a new one on me ... :-)

| Ashok, thanks for chiming in.  Now that you have, I have a few more
| questions for you:

  I can answer a few of these:

|  - Is the above doc the one you mentioned as being now public?

  Yes.  Ashok worked with me to the extent he was allowed prior to the
publishing of the public technocal note, but he couldn't say much.  (Believ=
e
it or not, it is possible to say less than the quoted section above.)  When
the note was published, Patrick Cramer sent me the note about it and pointe=
d
me at section 3.9.1.

|  - Is this considered a hardware erratum?

  I certainly consider it a Hardware Bug.  And I'm really hoping that Ashok
will be able to find a "Chicken Bit" which allows the broken feature to be
turned off.  Remember, the Relaxed Ordering Attribute on a Transaction Laye=
r
Packet is simply a HINT.  It is perfectly reasonable for a compliant
implementation to simply ignore the Relaxed Ordering Attribute on an
incoming TLP Request.  The sole responsibility of a compliant implementatio=
n
is to return the exact same Relaxed Ordering and No Snoop Attributes in any
TLP Response (The rules for ID-Based Ordering Attribute are more complex.)
=20
  Earlier Intel Root Complexes did exactly this: they ignored the Relaxed
Ordering Attribute and there was no performance difference for
using/not-using it.  It's pretty obvious that an attempt was made to
implement optimizations surounding the use of Relaxed Ordering and they
didn't work.

|  - If so, is there a pointer to that as well?

  Intel is historically tight-lipped about admiting any bugs/errata in thei=
r
products.  I'm guessing that the above quoted Section 3.9.1 is likely to be
all we ever get. The language above regarding TLPs targetting Coherent
Shared Memory are basically as much of an admission that they got it wrong
as we're going to get.  But heck, maybe we'll get lucky ...  Especially wit=
h
regard to the hoped for "Chicken Bit" ...

|  - If this is not considered an erratum, can you provide any guidance
|    about how an OS should determine when it should use RO?

  Software?  We don't need no stinking software!

  Sorry, I couldn't resist.

| Relying on a list of device IDs in an optimization manual is OK for an
| erratum, but if it's *not* an erratum, it seems like a hole in the specs
| because as far as I know there's no generic way for the OS to discover
| whether to use RO.

  Well, here's to hoping that Ashok and/or Patrick are able to offer more
detailed information ...

Casey
