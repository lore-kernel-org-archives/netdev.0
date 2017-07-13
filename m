From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH v6 0/3] Add new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
Date: Thu, 13 Jul 2017 00:52:23 +0000
Message-ID: <MWHPR12MB160080C62945A101FF0718DEC8AC0@MWHPR12MB1600.namprd12.prod.outlook.com>
References: <1498133721-21152-1-git-send-email-dingtianhong@huawei.com>
 <MWHPR12MB160087E9E0B17F7A17609714C8AA0@MWHPR12MB1600.namprd12.prod.outlook.com>
 <MWHPR12MB160006024D920ED58126048AC8AB0@MWHPR12MB1600.namprd12.prod.outlook.com>
 <CAKgT0Uc5KSJTj4A=9pSudiJ28AW0krc7FZpdW4upwY+FgpeArA@mail.gmail.com>
 <MWHPR12MB1600AECAE619EAA97E6B15D5C8AB0@MWHPR12MB1600.namprd12.prod.outlook.com>
 <CAKgT0UdqoRR8XLG1o3ygUZTqEBQ4dgNaneZ-n1OSNC1AiswO_g@mail.gmail.com>
 <MWHPR12MB16008EFFC5F2792880F7E80BC8A90@MWHPR12MB1600.namprd12.prod.outlook.com>,<16d18af6-f578-ef8a-a52e-46ec975e59e0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "ashok.raj@intel.com" <ashok.raj@intel.com>,
        "helgaas@kernel.org" <helgaas@kernel.org>,
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
        "mark.rutland@arm.com" <mark.rut
To: Ding Tianhong <dingtianhong@huawei.com>,
        Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <16d18af6-f578-ef8a-a52e-46ec975e59e0@huawei.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=A0 Sorry again for the delay.=A0 This time at least partially caused by a =
Chelsio-internal Customer Support request to simply disable Relaxed Orderin=
g entirely due to the performance issues with our 100Gb/s product and relat=
ively recent Intel Root Complexes.  Our Customer Support people are tired o=
f asking customers to try turning off Relaxed Ordering. (sigh)

  So, first off, I've mentioned a couple of times that the current cxgb4 dr=
iver hardwired the PCIe Capability Device Control[Relaxed Ordering Enable] =
on.  Here's the code which does it:

    drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c:4657:

    static void enable_pcie_relaxed_ordering(struct pci_dev *dev)
    {
        pcie_capability_set_word(dev, PCI_EXP_DEVCTL, PCI_EXP_DEVCTL_RELAX_=
EN);
    }

This is called from the PCI Probe() routine init_one() later in that file. =
 I just wanted to make sure people knew about this.  Obviously given our cu=
rrent very difficult thread, this would either need to be diked out or chan=
ged or a completely different mechanism put in place.

  Second, just to make sure everyone's on the same page, the above simply a=
llows the device to send TLPs with the Relaxed Ordering Attribute.  It does=
n't cause TLPs to suddenly all be sent with RO set.  The use of Relaxed Ord=
ering is selective.  For instance, in our hardware we can configure the RX =
Path to use RO on Ingress Packet Data delivery to Free List Buffers, but no=
t use RO for delivery of messages noting newly delivered Ingress Packet Dat=
a.  Doing this allows the destination PCIe target to [potentially] optimize=
 the DMA Writes to it based on local conditions (memory controller channel =
availability, etc.), but ensure that the message noting newly delivered Ing=
ress Packet Data isn't processed till all of the preceding TLPs with RO set=
 containing Ingress Packet Data have been processed.  (This by the way is t=
he essence of the AMD A1100 ARM SoC bug: its Root Complex isn't obeying tha=
t PCIe ordering rule.)

  Third, as noted above, I'm getting a lot of pressure to get this addresse=
d sooner than later, so I think that we should go with something fairly sim=
ple along the lines that you guys are proposing and I'll stop whining about=
 the problem of needing to handle Peer-to-Peer with Relaxed Ordering while =
not using it for deliveries to the Root Complex.  We can just wait for that=
 kettle of fish to explode on us and deal with the mess then.  (Hhmmm, the =
mixed metaphor landed in an entirely different place than I originally inte=
nded ... :-))

  If we try to stick as closely to Ding's latest patch set as possible, the=
n we can probably just add the diff to remove the enable_pcie_relaxed_order=
ing() code in cxgb4_main.c.

Casey=
