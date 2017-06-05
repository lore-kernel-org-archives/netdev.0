From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH v2 2/3] PCI: Enable PCIe Relaxed Ordering if supported
Date: Mon, 5 Jun 2017 21:33:19 +0800
Message-ID: <0853b74b-6c0e-68e9-225b-621d833615e4@huawei.com>
References: <1496462647-7632-1-git-send-email-dingtianhong@huawei.com>
 <1496462647-7632-3-git-send-email-dingtianhong@huawei.com>
 <CAKgT0UfKPLy7=swnZYiYOrLS8znhjxeXNZv=+CK5XS3Z1fkMbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>,
 Gabriele Paoloni <gabriele.paoloni@huawei.com>,
 Asit K Mallick <asit.k.mallick@intel.com>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>,
 Ashok Raj <ashok.raj@intel.com>, Bjorn Helgaas <helgaas@kernel.org>,
 Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
 "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
 Ganesh Goudar <ganeshgr@chelsio.com>, Bob Shaw <Bob.Shaw@amd.com>,
 Casey Leedom <leedom@chelsio.com>,
 Patrick J Cramer <patrick.j.cramer@intel.com>,
 Michael Werner <werner@chelsio.com>, linux-arm-kernel@lists.infradead.org,
 Amir Ancel <amira@mellanox.com>, Netdev <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 David Laight <David.Laight@aculab.com>,
 Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>,
 Robin Murphy <robin.murphy@arm.com>, David Miller <davem@
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CAKgT0UfKPLy7=swnZYiYOrLS8znhjxeXNZv=+CK5XS3Z1fkMbw@mail.gmail.com>
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



On 2017/6/4 2:19, Alexander Duyck wrote:
> On Fri, Jun 2, 2017 at 9:04 PM, Ding Tianhong <dingtianhong@huawei.com> wrote:
>> The PCIe Device Control Register use the bit 4 to indicate that
>> whether the device is permitted to enable relaxed ordering or not.
>> But relaxed ordering is not safe for some platform which could only
>> use strong write ordering, so devices are allowed (but not required)
>> to enable relaxed ordering bit by default.
>>
>> If a platform support relaxed ordering but does not enable it by
>> default, enable it in the PCIe configuration. This allows some device
>> to send TLPs with the relaxed ordering attributes set, which may
>> improve the performance.
>>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>>  drivers/pci/pci.c   | 42 ++++++++++++++++++++++++++++++++++++++++++
>>  drivers/pci/probe.c | 11 +++++++++++
>>  include/linux/pci.h |  3 +++
>>  3 files changed, 56 insertions(+)
>>
>> diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
>> index b01bd5b..f57a374 100644
>> --- a/drivers/pci/pci.c
>> +++ b/drivers/pci/pci.c
>> @@ -4878,6 +4878,48 @@ int pcie_set_mps(struct pci_dev *dev, int mps)
>>  EXPORT_SYMBOL(pcie_set_mps);
>>
>>  /**
>> + * pcie_set_relaxed_ordering - set PCI Express relexed ordering bit
>> + * @dev: PCI device to query
>> + *
>> + * If possible sets relaxed ordering
>> + */
>> +int pcie_set_relaxed_ordering(struct pci_dev *dev)
>> +{
>> +       return pcie_capability_set_word(dev, PCI_EXP_DEVCTL, PCI_EXP_DEVCTL_RELAX_EN);
>> +}
>> +EXPORT_SYMBOL(pcie_set_relaxed_ordering);
>> +
>> +/**
>> + * pcie_clear_relaxed_ordering - clear PCI Express relexed ordering bit
>> + * @dev: PCI device to query
>> + *
>> + * If possible clear relaxed ordering
>> + */
>> +int pcie_clear_relaxed_ordering(struct pci_dev *dev)
>> +{
>> +       return pcie_capability_clear_word(dev, PCI_EXP_DEVCTL, PCI_EXP_DEVCTL_RELAX_EN);
>> +}
>> +EXPORT_SYMBOL(pcie_clear_relaxed_ordering);
>> +
>> +/**
>> + * pcie_get_relaxed_ordering - check PCI Express relexed ordering bit
>> + * @dev: PCI device to query
>> + *
>> + * Returns true if relaxed ordering is been set
>> + */
>> +int pcie_get_relaxed_ordering(struct pci_dev *dev)
>> +{
>> +       u16 v;
>> +
>> +       pcie_capability_read_word(dev, PCI_EXP_DEVCTL, &v);
>> +
>> +       return (v & PCI_EXP_DEVCTL_RELAX_EN) >> 4;
>> +}
>> +EXPORT_SYMBOL(pcie_get_relaxed_ordering);
>> +
>> +/**
>> + * pcie_set_mps - set PCI Express maximum payload size
>> +/**
>>   * pcie_get_minimum_link - determine minimum link settings of a PCI device
>>   * @dev: PCI device to query
>>   * @speed: storage for minimum speed
>> diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
>> index 19c8950..aeb22b5 100644
>> --- a/drivers/pci/probe.c
>> +++ b/drivers/pci/probe.c
>> @@ -1701,6 +1701,16 @@ static void pci_configure_extended_tags(struct pci_dev *dev)
>>                                          PCI_EXP_DEVCTL_EXT_TAG);
>>  }
>>
>> +static void pci_configure_relaxed_ordering(struct pci_dev *dev)
>> +{
>> +       int ret;
>> +
>> +       if (dev && (dev->dev_flags & PCI_DEV_FLAGS_NO_RELAXED_ORDERING))
> 
> So there is a minor issue here. The problem is this is only trying to
> modify relaxed ordering for the device itself. That isn't what we
> want. What we want is to modify it on all of the upstream port
> interfaces where there is something the path to the root complex that
> has an issue. So if the root complex has to set the
> NO_RELAXED_ORDERING flag on a root port, all of the interfaces below
> it that would be pushing traffic toward it should not have the relaxed
> ordering bit set.
> 
> Also I am pretty sure this is a PCIe capability, not a PCI capability.
> You probably need to make sure you code is making this distinction
> which I don't know if it currently is. If you need an example of the
> kind of checks I am suggesting just take a look at
> pcie_configure_mps(). It is verifying the function is PCIe before
> attempting to make any updates. In your case you will probably also
> need to make sure there is a bus for you to walk up the chain of.
> Otherwise this shouldn't apply.
> 
> 
>> +               pcie_set_relaxed_ordering(dev);
>> +       else
>> +               pcie_clear_relaxed_ordering(dev);
>> +}
> 
> Also I am not a fan of the way this is handled currently. If you don't
> have relaxed ordering set then you don't need to do anything else, if
> you do have it set but there is no bus to walk up you shouldn't change
> it, and if there is a bus to walk up and you find that the root
> complex on that bus has the NO_RELAXED_ORDERING set you should clear
> it. Right now this code seems to be enabling relaxed ordering if the
> NO_RELAXED_ORDERING flag is set.
> 

Hi Alexander:

I reconsidered your suggestion and found I miss something here,
decide to modify the configure police as your solution, I think
it is close to our goal.

Thanks
Ding

diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 19c8950..68dee05 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -1701,6 +1701,45 @@ static void pci_configure_extended_tags(struct pci_dev *dev)
                                         PCI_EXP_DEVCTL_EXT_TAG);
 }

+static int pcie_clearing_relaxed_ordering(struct pci_dev *dev, void *data)
+{
+ int origin_ero;
+
+ if (!pci_is_pcie(dev))
+         return 0;
+
+ origin_ero = pcie_get_relaxed_ordering(dev);
+
+ /* If the releaxed ordering enable bit is not set, do nothing. */
+ if (!origin_ero)
+         return 0;
+
+ pcie_clear_relaxed_ordering(dev);
+
+ dev_info(&dev->dev, "Disable Relaxed Ordering\n");
+
+ return 0;
+}
+
+static void pci_configure_relaxed_ordering(struct pci_dev *dev)
+{
+ int origin_ero;
+
+ if (!pci_is_pcie(dev))
+         return;
+
+ origin_ero = pcie_get_relaxed_ordering(dev);
+ /* If the releaxed ordering enable bit is not set, do nothing. */
+ if (!origin_ero)
+         return;
+
+ if (dev->dev_flags & PCI_DEV_FLAGS_NO_RELAXED_ORDERING) {
+         pcie_clear_relaxed_ordering(dev);
+         pci_walk_bus(dev->bus, pcie_clearing_relaxed_ordering, NULL);
+         dev_info(&dev->dev, "Disable Relaxed Ordering\n");
+ }
+}
+
 static void pci_configure_device(struct pci_dev *dev)
 {
        struct hotplug_params hpp;
@@ -1708,6 +1747,7 @@ static void pci_configure_device(struct pci_dev *dev)

        pci_configure_mps(dev);
        pci_configure_extended_tags(dev);
+ pci_configure_relaxed_ordering(dev);

        memset(&hpp, 0, sizeof(hpp));
        ret = pci_get_hp_params(dev, &hpp);
diff --git a/include/linux/pci.h b/include/linux/pci.h



>> +
>>  static void pci_configure_device(struct pci_dev *dev)
>>  {
>>         struct hotplug_params hpp;
>> @@ -1708,6 +1718,7 @@ static void pci_configure_device(struct pci_dev *dev)
>>
>>         pci_configure_mps(dev);
>>         pci_configure_extended_tags(dev);
>> +       pci_configure_relaxed_ordering(dev);
>>
>>         memset(&hpp, 0, sizeof(hpp));
>>         ret = pci_get_hp_params(dev, &hpp);
>> diff --git a/include/linux/pci.h b/include/linux/pci.h
>> index e1e8428..84bd6af 100644
>> --- a/include/linux/pci.h
>> +++ b/include/linux/pci.h
>> @@ -1105,6 +1105,9 @@ int __pci_enable_wake(struct pci_dev *dev, pci_power_t state,
>>  void pci_pme_wakeup_bus(struct pci_bus *bus);
>>  void pci_d3cold_enable(struct pci_dev *dev);
>>  void pci_d3cold_disable(struct pci_dev *dev);
>> +int pcie_set_relaxed_ordering(struct pci_dev *dev);
>> +int pcie_clear_relaxed_ordering(struct pci_dev *dev);
>> +int pcie_get_relaxed_ordering(struct pci_dev *dev);
>>
>>  static inline int pci_enable_wake(struct pci_dev *dev, pci_power_t state,
>>                                   bool enable)
>> --
>> 1.9.0
>>
>>
> 
> .
> 
