From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH v9 1/4] PCI: Add new PCIe Fabric End Node flag,
 PCI_DEV_FLAGS_NO_RELAXED_ORDERING
Date: Wed, 9 Aug 2017 16:36:32 +0000
Message-ID: <MWHPR12MB1600289FF0943C59565B39B6C88B0@MWHPR12MB1600.namprd12.prod.outlook.com>
References: <1501917313-9812-1-git-send-email-dingtianhong@huawei.com>
 <1501917313-9812-2-git-send-email-dingtianhong@huawei.com>
 <20170808232200.GO16580@bhelgaas-glaptop.roam.corp.google.com>
 <MWHPR12MB1600249E96C320D5472F77ADC88B0@MWHPR12MB1600.namprd12.prod.outlook.com>
 <20170809030236.GA7191@bhelgaas-glaptop.roam.corp.google.com>,
 <d168687d-f849-4d09-1a2d-c9c6718b3318@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "mark.rutland@arm.com" <mark.rutland@arm.com>,
 "gabriele.paoloni@huawei.com" <gabriele.paoloni@huawei.com>,
 "asit.k.mallick@intel.com" <asit.k.mallick@intel.com>,
 "catalin.marinas@arm.com" <catalin.marinas@arm.com>,
 "will.deacon@arm.com" <will.deacon@arm.com>,
 "linuxarm@huawei.com" <linuxarm@huawei.com>,
 "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
 "ashok.raj@intel.com" <ashok.raj@intel.com>,
 "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
 "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
 Ganesh GR <ganeshgr@chelsio.com>, "Bob.Shaw@amd.com" <Bob.Shaw@amd.com>,
 "patrick.j.cramer@intel.com" <patrick.j.cramer@intel.com>,
 "bhelgaas@google.com" <bhelgaas@google.com>,
 Michael Werner <werner@chelsio.com>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
 "amira@mellanox.com" <amira@mellanox.com>,
 "netdev@vger.kerne
To: Ding Tianhong <dingtianhong@huawei.com>, Bjorn Helgaas <helgaas@kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <d168687d-f849-4d09-1a2d-c9c6718b3318@huawei.com>
Content-Language: en-US
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

| From: Ding Tianhong <dingtianhong@huawei.com>
| Sent: Wednesday, August 9, 2017 5:17 AM
|
| On 2017/8/9 11:02, Bjorn Helgaas wrote:
| >
| > On Wed, Aug 09, 2017 at 01:40:01AM +0000, Casey Leedom wrote:
| > >
| >> | From: Bjorn Helgaas <helgaas@kernel.org>
| >> | Sent: Tuesday, August 8, 2017 4:22 PM
| >> | ...
| >> | It should also include a pointer to the AMD erratum, if available, or
| >> | at least some reference to how we know it doesn't obey the rules.
| >>
| >>   Getting an ACK from AMD seems like a forlorn cause at this point.  My
| >> contact was Bob Shaw <Bob.Shaw@amd.com> and he stopped responding to me
| >> messages almost a year ago saying that all of AMD's energies were being
| >> redirected towards upcoming x86 products (likely Ryzen as we now know).
| >> As far as I can tell AMD has walked away from their A1100 (AKA
| >> "Seattle") ARM SoC.
| >>
| >>   On the specific issue, I can certainly write up somthing even more
| >> extensive than I wrote up for the comment in drivers/pci/quirks.c.
| >> Please review the comment I wrote up and tell me if you'd like
| >> something even more detailed -- I'm usually acused of writing comments
| >> which are too long, so this would be a new one on me ... :-)
| >
| > If you have any bug reports with info about how you debugged it and
| > concluded that Seattle is broken, you could include a link (probably
| > in the changelog).  But if there isn't anything, there isn't anything.
| ...
| OK, I could reorganize it, but still need the Casey to give me the link
| for the Seattle, otherwise I could remove the AMD part and wait until
| someone show it. Thanks

There are no links and I was never given an internal bug number at AMD.  As
I said, they stopped responding to my notes about a years ago saying that
they were moving the focus of all their people and no longer had resources
to pursue the issue.  Hopefully for them, Ryzen doesn't have the same
Data Corruption problem ...

As for how we diagnosed it, with our Ingress Packet delivery, we have the
Ingress Packet Data delivered (DMA Write) into Free List Buffers, and then
then a small message (DMA Write) to a "Response Queue" indicating delivery
of the Ingress Packet Data into the Free List Buffers.  The Transaction
Layer Packets which convey the Ingress Packet Data all have the Relaxed
Ordering Attribute set, while the following TLP carring the Ingress Data
delivery notification into the Response Queue does not have the Relaxed
Ordering Attribute set.

The rules for processing TLPs with and without the Relaxed Ordering
Attribute set are covered in Section 2.4.1 of the PCIe 3.0 specification
(Revision 3.0 November 10, 2010).  Table 2-34 "Ordering Rules Summary"
covers the cases where one TLP may "pass" (be proccessed earlier) than a
preceding TLP.  In the case we're talking about, we have a sequence of one
or more Posted DMA Write TLPs with the Relaxed Ordering Attribute set and a
following Posted DMA Write TLP without the Relaxed Ordering Attribute set.
Thus we need to look at the Row A, Column 2 cell of Table 2-34 governing
when a Posted Request may "pass" a preceeding Posted Request.  In that cell
we have:

    a) No
    b) Y/N

with the explanatory text:

    A2a    A Posted Request must not pass another Posted Request
           unless A2b applies.

    A2b    A Posted Request with RO[23] Set is permitted to pass
           another Posted Request[24].  A Posted Request with IDO
           Set is permitted to pass another Posted Request if the
           two Requester IDs are different.

    [23] In this section, "RO" is an abbreviation for the Relaxed
         Ordering Attribute field.

    [24] Some usages are enabled by not implementing this passing
         (see the No RO-enabled PR-PR Passing bit in Section
         7.8.15).

In our case, we were getting notifications of Ingress Packet Delivery in our
Response Queues, but not all of the Ingress Packet Data Posted DMA Write
TLPs had been processed yet by the Root Complex.  As a result, we were
picking up old stale memory data before those lagging Ingress Packet Data
TLPs could be processed.  This is a clear violation of the PCIe 3.0 TLP
processing rules outlined above.

Does that help?

Casey
