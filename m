From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] PCI: lock each enable/disable num_vfs operation in
 sysfs
Date: Fri, 6 Jan 2017 12:49:23 +1100
Message-ID: <20170106014922.GA15658@gwshan>
References: <20170104004826.17866.77074.stgit@localhost6.localdomain6>
 <20170104004831.17866.11537.stgit@localhost6.localdomain6>
 <20170104021531.GA567@gwshan>
 <87618083B2453E4A8714035B62D67992507430EB@FMSMSX105.amr.corp.intel.com>
 <20170104231139.GA3726@gwshan>
 <87618083B2453E4A8714035B62D679925074474B@FMSMSX105.amr.corp.intel.com>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87618083B2453E4A8714035B62D679925074474B@FMSMSX105.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 06, 2017 at 12:55:08AM +0000, Tantilov, Emil S wrote:
>>On Wed, Jan 04, 2017 at 04:00:20PM +0000, Tantilov, Emil S wrote:
>>>>On Tue, Jan 03, 2017 at 04:48:31PM -0800, Emil Tantilov wrote:
>>>>>Enabling/disabling SRIOV via sysfs by echo-ing multiple values
>>>>>simultaneously:
>>>>>
>>>>>echo 63 > /sys/class/net/ethX/device/sriov_numvfs&
>>>>>echo 63 > /sys/class/net/ethX/device/sriov_numvfs
>>>>>
>>>>>sleep 5
>>>>>
>>>>>echo 0 > /sys/class/net/ethX/device/sriov_numvfs&
>>>>>echo 0 > /sys/class/net/ethX/device/sriov_numvfs
>>>>>
>>>>>Results in the following bug:
>>>>>
>>>>>kernel BUG at drivers/pci/iov.c:495!
>>>>>invalid opcode: 0000 [#1] SMP
>>>>>CPU: 1 PID: 8050 Comm: bash Tainted: G   W   4.9.0-rc7-net-next #2092
>>>>>RIP: 0010:[<ffffffff813b1647>]
>>>>>	  [<ffffffff813b1647>] pci_iov_release+0x57/0x60
>>>>>
>>>>>Call Trace:
>>>>> [<ffffffff81391726>] pci_release_dev+0x26/0x70
>>>>> [<ffffffff8155be6e>] device_release+0x3e/0xb0
>>>>> [<ffffffff81365ee7>] kobject_cleanup+0x67/0x180
>>>>> [<ffffffff81365d9d>] kobject_put+0x2d/0x60
>>>>> [<ffffffff8155bc27>] put_device+0x17/0x20
>>>>> [<ffffffff8139c08a>] pci_dev_put+0x1a/0x20
>>>>> [<ffffffff8139cb6b>] pci_get_dev_by_id+0x5b/0x90
>>>>> [<ffffffff8139cca5>] pci_get_subsys+0x35/0x40
>>>>> [<ffffffff8139ccc8>] pci_get_device+0x18/0x20
>>>>> [<ffffffff8139ccfb>] pci_get_domain_bus_and_slot+0x2b/0x60
>>>>> [<ffffffff813b09e7>] pci_iov_remove_virtfn+0x57/0x180
>>>>> [<ffffffff813b0b95>] pci_disable_sriov+0x65/0x140
>>>>> [<ffffffffa00a1af7>] ixgbe_disable_sriov+0xc7/0x1d0 [ixgbe]
>>>>> [<ffffffffa00a1e9d>] ixgbe_pci_sriov_configure+0x3d/0x170 [ixgbe]
>>>>> [<ffffffff8139d28c>] sriov_numvfs_store+0xdc/0x130
>>>>>...
>>>>>RIP  [<ffffffff813b1647>] pci_iov_release+0x57/0x60
>>>>>
>>>>>Use the existing mutex lock to protect each enable/disable operation.
>>>>>
>>>>>CC: Alexander Duyck <alexander.h.duyck@intel.com>
>>>>>Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
>>>>
>>>>Emil, It's going to change semantics of pci_enable_sriov() and
>>pci_disable_sriov().
>>>>They can be invoked when writing to the sysfs entry, or loading PF's
>>>>driver. With the change applied, the lock (pf->sriov->lock) isn't acquired and released
>>>>in the PF's driver loading path.
>>>
>>>The enablement of SRIOV on driver load is done via deprecated module parameter.
>>>Perhaps we can just remove it, although there are probably still people that use it
>>>and may not be happy if we get rid of it.
>>>
>>
>>Yeah, some drivers are still using the interface. So we cannot affect it
>>until it can be droped.
>>
>>>>I think the reasonable way would be adding a flag in "struct sriov", to
>>>>indicate someone is accessing the IOV capability through sysfs file. With this, the
>>>>code returns with "-EBUSY" immediately for contenders. With it, nothing is going
>>>>to be changed in PF's driver loading path.
>>>
>>>Flag is what I initially had in mind, but did not want to add extra locking if we
>>>can make use of the existing.
>>>
>>
>>The problem is sriov->lock wasn't introduced to protect the whole IOV capability.
>>Instead, it protects the allocation of virtual bus (if needed). In your patch,
>>it will be used to protect the whole IOV capability, ensure accessing the
>>IOV capability exclusively. So the usage of this lock is changed.
>>
>>     code extracted from pci.h:
>>
>>     struct pci_sriov {
>>            :
>>            struct mutex lock;      /* lock for VF bus */
>>            :
>>     }
>>
>>The lock was introduced by commit d1b054da8 ("PCI: initialize and release
>>SR-IOV capability"). If I'm correct enough, I don't think this lock is needed when
>>pci_enable_sriov() or pci_disable_sriov() are called in driver because of
>>module
>>parameters. I don't see the usage case calling pci_disable_sriov() while
>>previous pci_enable_sriov() isn't finished yet. Also, it's not needed in EEH
>>subsystem.
>>So I think the lock can be dropped, then it can be used to protect sysfs path.
>
>That's pretty much what this patch does, except I kept the locking for EEH since 
>it is the only driver that calls pci_iov_add/remove_virtfn() directly.
>
>I'll write it up and run some tests, although I have no way to test EEH.
> 

Yes, Your patch is close to what I suggested. I'm pretty sure EEH needn't
this lock. I'll fix it up if EEH is broken because of it.

>>>>Also, there are some minor comments as below and I guess most of them won't
>>>>be applied if you take my suggestion eventually. However, I'm trying to make
>>>>the comments complete.
>>>
>>>Thanks a lot for reviewing!
>>>
>>>>
>>>>>---
>>>>> drivers/pci/pci-sysfs.c |   24 +++++++++++++++++-------
>>>>> 1 file changed, 17 insertions(+), 7 deletions(-)
>>>>>
>>>>>diff --git a/drivers/pci/pci-sysfs.c b/drivers/pci/pci-sysfs.c
>>>>>index 0666287..5b54cf5 100644
>>>>>--- a/drivers/pci/pci-sysfs.c
>>>>>+++ b/drivers/pci/pci-sysfs.c
>>>>>@@ -472,7 +472,9 @@ static ssize_t sriov_numvfs_store(struct device
>>*dev,
>>>>> 				  const char *buf, size_t count)
>>>>> {
>>>>> 	struct pci_dev *pdev = to_pci_dev(dev);
>>>>>+	struct pci_sriov *iov = pdev->sriov;
>>>>> 	int ret;
>>>>>+
>>>>
>>>>Unnecessary change.
>>>>
>>>>> 	u16 num_vfs;
>>>>>
>>>>> 	ret = kstrtou16(buf, 0, &num_vfs);
>>>>>@@ -482,38 +484,46 @@ static ssize_t sriov_numvfs_store(struct device
>>>>*dev,
>>>>> 	if (num_vfs > pci_sriov_get_totalvfs(pdev))
>>>>> 		return -ERANGE;
>>>>>
>>>>>+	mutex_lock(&iov->dev->sriov->lock);
>>>>>+
>>>>> 	if (num_vfs == pdev->sriov->num_VFs)
>>>>>-		return count;		/* no change */
>>>>>+		goto exit;
>>>>>
>>>>> 	/* is PF driver loaded w/callback */
>>>>> 	if (!pdev->driver || !pdev->driver->sriov_configure) {
>>>>> 		dev_info(&pdev->dev, "Driver doesn't support SRIOV
>>>>configuration via sysfs\n");
>>>>>-		return -ENOSYS;
>>>>>+		ret = -EINVAL;
>>>>>+		goto exit;
>>>>
>>>>Why we need change the error code here?
>>>
>>>checkpatch was complaining about the use of the ENOSYS error code being specific
>>>and even though it was not my patch introducing it I had to change it to shut it up.
>>>
>>
>>Right, it's reserved for attempt to call nonexisting syscall, but I think
>>ENOENT might be more indicative than EINVAL in this specific case?
>
>ENOENT is for a missing file, but if we got this far in the code then there must've been 
>a sysfs file. This is pretty straightforward "not supported" error, which is why I picked
>EINVAL.
>

EINVAL means "invalid arguments" in my mind. The understanding matches with what's
said in https://linux.die.net/man/3/errno  I also treated ENOENT as missed callbacks.
However, it's not a big deal. Just pick the errno you like. What I concerned is user
might has some script to map the errno and exact failure. Precise and unique errno
from error path isn't bad.

Thanks,
Gavin
