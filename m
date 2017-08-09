From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH v9 2/4] PCI: Disable PCIe Relaxed Ordering if unsupported
Date: Wed, 9 Aug 2017 12:33:34 +0000
Message-ID: <MWHPR12MB1600255ACFCD3FB3C80EB8B6C88B0@MWHPR12MB1600.namprd12.prod.outlook.com>
References: <1501917313-9812-1-git-send-email-dingtianhong@huawei.com>
 <1501917313-9812-3-git-send-email-dingtianhong@huawei.com>,<20170809022239.GP16580@bhelgaas-glaptop.roam.corp.google.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170809022239.GP16580@bhelgaas-glaptop.roam.corp.google.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

| From: Bjorn Helgaas <helgaas@kernel.org>
| Sent: Tuesday, August 8, 2017 7:22 PM
| ...
| and the caller should do something like this:
|=20
|     if (pcie_relaxed_ordering_broken(pci_find_pcie_root_port(pdev)))
|         adapter->flags |=3D ROOT_NO_RELAXED_ORDERING;
|=20
| That way it's obvious where the issue is, and it's obvious that the
| answer might be different for peer-to-peer transactions than it is for
| transactions to the root port, i.e., to coherent memory.
| ...

Which is back to something very close to what I initially suggested in my
first patch submission.  Because you're right, this isn't about broken
Source Devices, it's about broken Completing Devices.

Unfortunately, as Alexander Duyck noted, in a Virtual Machine we won't be
able to see our Root Port in order to make this determination.  (And in som=
e
Hypervisor implementations I've seen, there's not even a synthetic Root Por=
t
available to the VM at all, let alone read-only access to the real one.)

So the current scheme was developed of having the Hypervisor kernel travers=
e
down the PCIe Fabric when it finds a broken Root Port implementation (the
issue that we've mostly been primarily focused upon), and turning off the
PCIe Capability Device Control[Relaxed Ordering Enable].  This was to serve
two purposes:

 1. Turn that off in order to prevent sending any Transaction Layer
    Packets with the Relaxed Ordering Attribute to any Completer.
    Which unfortunately would also prevent Peer-to-Peer use of the
    Relaxed Ordering Attribute.

 2. Act as a message to Device Drivers for those downstream devices
    that the they were dealing with a broken Root Port implementation.
    And this would work even for a driver in a VM with an attached
    device since it would be able to see the PCIe Configuration Space
    for the attached device.

I haven't been excited about any of this because:

 A. While so far all of the examples we've talked about are broken
    Root Port Completers, it's perfectly possible that other devices
    could be broken -- say an NVMe Device which is not "Coherent
    Memory".  How would this fit into the framework APIs being
    described?

 B. I have yet to see a n example of how the currently proposed
    API framework would be used in a hybrid environment where
    TLPs to the Root Port would not use Relaxed Ordering, but TLPs
    to a Peer would use Relaxed Ordering.  So far its all been about
    using a "big hammer" to completely disable the use of Relaxed
    Ordering.

But the VM problem keeps cropping up over and over.  A driver in a VM
doesn't have access to the Root Port to determine if its on a "Black List"
and our only way of communicating with the driver in the VM is to leave the
device in a particular state (i.e. initialize the PCIe Capability Device
Control[Relaxed Ordering Enable] to "off").

Oh, and also, on the current patch submission's focus on broken Root Port
implementations: one could suggest that even if we're stuck with the "Devic=
e
attached to a VM Conundrum", that what we should really be thinking about i=
s
if ANY device within a PCIe Fabric has broken Relaxed Ordering completion
problems, and, if so, "poisoning" the entire containing PCIe Fabric by
turning off Relaxed Ordering Enable for every device, up, down sideways --
including the Root Port itself.

| ...
| This associates the message with the Requester that may potentially
| use relaxed ordering. But there's nothing wrong or unusual about the
| Requester; the issue is with the *Completer*, so I think the message
| should be in the quirk where we set PCI_DEV_FLAGS_NO_RELAXED_ORDERING.
| Maybe it should be both places; I dunno.
|=20
| This implementation assumes the device only initiates transactions to
| coherent memory, i.e., it assumes the device never does peer-to-peer
| DMA.  I guess we'll have to wait and see if we trip over any
| peer-to-peer issues, then figure out how to handle them.
| ...

Yes, as soon as we want to implement the hybrid use of Relaxed Ordering I
mentioned above.  And that the Intel document mentions itself.

Casey
