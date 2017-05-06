From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH 1/2] PCI: Add new PCIe Fabric End Node flag,
 PCI_DEV_FLAGS_NO_RELAXED_ORDERING
Date: Sat, 6 May 2017 11:08:40 +0800
Message-ID: <22c46382-5778-022f-d0bd-74abec9e9c7c@huawei.com>
References: <cover.1493678834.git.leedom@chelsio.com>
 <758d0e431c732fe133e7b0e660bde5fc1beccdba.1493678834.git.leedom@chelsio.com>
 <CAKgT0UeuW88AHBX14H8xHteeG7vR0AH3apbjOeEDx_6p46x7tA@mail.gmail.com>
 <20170502165329.GB26406@linux.intel.com>
 <CAKgT0UcxjGCZu_QV-eF7_yWkDBbQpLpdaPqBf1gji8XXM5Cc=w@mail.gmail.com>
 <MWHPR12MB160095DF53CE981C923FE65DC8160@MWHPR12MB1600.namprd12.prod.outlook.com>
 <CAKgT0UdJ17DGAphuP5Y9co6ky-GBFdq2s-1nqctY_Tz_iz5__g@mail.gmail.com>
 <MWHPR12MB1600E78DD7F530AA9DC2433DC8EA0@MWHPR12MB1600.namprd12.prod.outlook.com>
 <CAKgT0Ucwkp+fi-9HhMbze6t_i15dj4e2WQBp13Coi6MegrDh=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>,
 Gabriele Paoloni <gabriele.paoloni@huawei.com>,
 Asit K Mallick <asit.k.mallick@intel.com>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>,
 LinuxArm <linuxarm@huawei.com>, "Raj, Ashok" <ashok.raj@intel.com>,
 Bjorn Helgaas <helgaas@kernel.org>, Ganesh GR <ganeshgr@chelsio.com>,
 Jeff Kirsher <jeffrey.t.kirsher@intel.com>, Bob Shaw <Bob.Shaw@amd.com>,
 Patrick J Cramer <patrick.j.cramer@intel.com>, "Arjun V." <arjun@chelsio.com>,
 Michael Werner <werner@chelsio.com>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
 Amir Ancel <amira@mellanox.com>, Netdev <netdev@vger.kernel.org>,
 David Laight <David.Laight@aculab.com>,
 Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>,
 Robin Murphy <robin.murphy@arm.com>, David Miller <davem@davemloft.net>,
 h <l.stach@pengutronix.de>
To: Alexander Duyck <alexander.duyck@gmail.com>, Casey Leedom
 <leedom@chelsio.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CAKgT0Ucwkp+fi-9HhMbze6t_i15dj4e2WQBp13Coi6MegrDh=w@mail.gmail.com>
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



On 2017/5/5 22:04, Alexander Duyck wrote:
> On Thu, May 4, 2017 at 2:01 PM, Casey Leedom <leedom@chelsio.com> wrote:
>> | From: Alexander Duyck <alexander.duyck@gmail.com>
>> | Sent: Wednesday, May 3, 2017 9:02 AM
>> | ...
>> | It sounds like we are more or less in agreement. My only concern is
>> | really what we default this to. On x86 I would say we could probably
>> | default this to disabled for existing platforms since my understanding
>> | is that relaxed ordering doesn't provide much benefit on what is out
>> | there right now when performing DMA through the root complex. As far
>> | as peer-to-peer I would say we should probably look at enabling the
>> | ability to have Relaxed Ordering enabled for some channels but not
>> | others. In those cases the hardware needs to be smart enough to allow
>> | for you to indicate you want it disabled by default for most of your
>> | DMA channels, and then enabled for the select channels that are
>> | handling the peer-to-peer traffic.
>>
>>   Yes, I think that we are mostly in agreement.  I had just wanted to make
>> sure that whatever scheme was developed would allow for simultaneously
>> supporting non-Relaxed Ordering for some PCIe End Points and Relaxed
>> Ordering for others within the same system.  I.e. not simply
>> enabling/disabling/etc.  based solely on System Platform Architecture.
>>
>>   By the way, I've started our QA folks off looking at what things look like
>> in Linux Virtual Machines under different Hypervisors to see what
>> information they may provide to the VM in the way of what Root Complex Port
>> is being used, etc.  So far they've got Windows HyperV done and there
>> there's no PCIe Fabric exposed in any way: just the attached device.  I'll
>> have to see what pci_find_pcie_root_port() returns in that environment.
>> Maybe NULL?
> 
> I believe NULL is one of the options. It all depends on what qemu is
> emulating. Most likely you won't find a pcie root port on KVM because
> the default is to emulate an older system that only supports PCI.
> 
>>   With your reservations (which I also share), I think that it probably
>> makes sense to have a per-architecture definition of the "Can I Use Relaxed
>> Ordering With TLPs Directed At This End Point" predicate, with the default
>> being "No" for any architecture which doesn't implement the predicate.  And
>> if the specified (struct pci_dev *) End Node is NULL, it ought to return
>> False for that as well.  I can't see any reason to pass in the Source End
>> Node but I may be missing something.
>>
>>   At this point, this is pretty far outside my level of expertise.  I'm
>> happy to give it a go, but I'd be even happier if someone with a lot more
>> experience in the PCIe Infrastructure were to want to carry the ball
>> forward.  I'm not super familiar with the Linux Kernel "Rules Of
>> Engagement", so let me know what my next step should be.  Thanks.
>>
>> Casey
> 
> For now we can probably keep this on the linux-pci mailing list. Going
> that route is the most straight forward for now since step one is
> probably just making sure we are setting the relaxed ordering bit in
> the setups that make sense. I would say we could probably keep it
> simple. We just need to enable relaxed ordering by default for SPARC
> architectures, on most others we can probably default it to off.
> 

Casey, Alexander:

Thanks for the wonderful discussion, it is more clearly that what to do next,
I agree that enable relaxed ordering by default only for SPARC and ARM64
is more safe for all the other platform, as no one want to break anything.

> I believe this all had started as Ding Tianhong was hoping to enable
> this for the ARM architecture. That is the only one I can think of
> where it might be difficult to figure out which way to default as we
> were attempting to follow the same code that was enabled for SPARC and
> that is what started this tug-of-war about how this should be done.
> What we might do is take care of this in two phases. The first one
> enables the infrastructure generically but leaves it defaulted to off
> for everyone but SPARC. Then we can go through and start enabling it
> for other platforms such as some of those on ARM in the platforms that
> Ding Tianhong was working with.
> 

According the suggestion, I could only think of this code:

@@ -3979,6 +3979,15 @@ static void quirk_tw686x_class(struct pci_dev *pdev)
 DECLARE_PCI_FIXUP_CLASS_EARLY(0x1797, 0x6869, PCI_CLASS_NOT_DEFINED, 8,
                              quirk_tw686x_class);

+static void quirk_relaxedordering_disable(struct pci_dev *dev)
+{
+ if (dev->vendor != PCI_VENDOR_ID_HUAWEI &&
+     dev->vendor != PCI_VENDOR_ID_SUN)
+         dev->dev_flags |= PCI_DEV_FLAGS_NO_RELAXED_ORDERING;
+}
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_INTEL_ID, PCI_ANY_ID, PCI_CLASS_NOT_DEFINED, 8,
+                       quirk_relaxedordering_disable);
+
 /*
  * Per PCIe r3.0, sec 2.2.9, "Completion headers must supply the same
  * values for the Attribute as were supplied in the header of the


What do you think of it?

Thanks
Ding


> - Alex
> 
> .
> 
