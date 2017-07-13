From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH v6 0/3] Add new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
Date: Thu, 13 Jul 2017 09:18:48 +0800
Message-ID: <3aed2e2d-025d-b35c-46fa-bced87789037@huawei.com>
References: <1498133721-21152-1-git-send-email-dingtianhong@huawei.com>
 <MWHPR12MB160087E9E0B17F7A17609714C8AA0@MWHPR12MB1600.namprd12.prod.outlook.com>
 <MWHPR12MB160006024D920ED58126048AC8AB0@MWHPR12MB1600.namprd12.prod.outlook.com>
 <CAKgT0Uc5KSJTj4A=9pSudiJ28AW0krc7FZpdW4upwY+FgpeArA@mail.gmail.com>
 <MWHPR12MB1600AECAE619EAA97E6B15D5C8AB0@MWHPR12MB1600.namprd12.prod.outlook.com>
 <CAKgT0UdqoRR8XLG1o3ygUZTqEBQ4dgNaneZ-n1OSNC1AiswO_g@mail.gmail.com>
 <MWHPR12MB16008EFFC5F2792880F7E80BC8A90@MWHPR12MB1600.namprd12.prod.outlook.com>
 <16d18af6-f578-ef8a-a52e-46ec975e59e0@huawei.com>
 <MWHPR12MB160080C62945A101FF0718DEC8AC0@MWHPR12MB1600.namprd12.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
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
To: Casey Leedom <leedom@chelsio.com>,
        Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <MWHPR12MB160080C62945A101FF0718DEC8AC0@MWHPR12MB1600.namprd12.prod.outlook.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017/7/13 8:52, Casey Leedom wrote:
>   Sorry again for the delay.  This time at least partially caused by a Chelsio-internal Customer Support request to simply disable Relaxed Ordering entirely due to the performance issues with our 100Gb/s product and relatively recent Intel Root Complexes.  Our Customer Support people are tired of asking customers to try turning off Relaxed Ordering. (sigh)
> 
>   So, first off, I've mentioned a couple of times that the current cxgb4 driver hardwired the PCIe Capability Device Control[Relaxed Ordering Enable] on.  Here's the code which does it:
> 
>     drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c:4657:
> 
>     static void enable_pcie_relaxed_ordering(struct pci_dev *dev)
>     {
>         pcie_capability_set_word(dev, PCI_EXP_DEVCTL, PCI_EXP_DEVCTL_RELAX_EN);
>     }

we should remove it.

> 
> This is called from the PCI Probe() routine init_one() later in that file.  I just wanted to make sure people knew about this.  Obviously given our current very difficult thread, this would either need to be diked out or changed or a completely different mechanism put in place.
> 
>   Second, just to make sure everyone's on the same page, the above simply allows the device to send TLPs with the Relaxed Ordering Attribute.  It doesn't cause TLPs to suddenly all be sent with RO set.  The use of Relaxed Ordering is selective.  For instance, in our hardware we can configure the RX Path to use RO on Ingress Packet Data delivery to Free List Buffers, but not use RO for delivery of messages noting newly delivered Ingress Packet Data.  Doing this allows the destination PCIe target to [potentially] optimize the DMA Writes to it based on local conditions (memory controller channel availability, etc.), but ensure that the message noting newly delivered Ingress Packet Data isn't processed till all of the preceding TLPs with RO set containing Ingress Packet Data have been proces
 sed.  (This by the way is the essence of the AMD A1100 ARM SoC bug: its Root Complex isn't obeying that PCIe ordering rule.)
> 
>   Third, as noted above, I'm getting a lot of pressure to get this addressed sooner than later, so I think that we should go with something fairly simple along the lines that you guys are proposing and I'll stop whining about the problem of needing to handle Peer-to-Peer with Relaxed Ordering while not using it for deliveries to the Root Complex.  We can just wait for that kettle of fish to explode on us and deal with the mess then.  (Hhmmm, the mixed metaphor landed in an entirely different place than I originally intended ... :-))
> 

Ok, we could fix them when we trigger this, I think it is not a big problem.

>   If we try to stick as closely to Ding's latest patch set as possible, then we can probably just add the diff to remove the enable_pcie_relaxed_ordering() code in cxgb4_main.c.
> 

If no other more suggestion, I will send a new version and remove the enable_pcie_relaxed_ordering(), thanks.  :)

Ding
> Casey
> .
> 
