From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] PCI: lock each enable/disable num_vfs operation in
 sysfs
Date: Wed, 4 Jan 2017 13:15:31 +1100
Message-ID: <20170104021531.GA567@gwshan>
References: <20170104004826.17866.77074.stgit@localhost6.localdomain6>
 <20170104004831.17866.11537.stgit@localhost6.localdomain6>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-pci@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        alexander.h.duyck@intel.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Emil Tantilov <emil.s.tantilov@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170104004831.17866.11537.stgit@localhost6.localdomain6>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 03, 2017 at 04:48:31PM -0800, Emil Tantilov wrote:
>Enabling/disabling SRIOV via sysfs by echo-ing multiple values
>simultaneously:
>
>echo 63 > /sys/class/net/ethX/device/sriov_numvfs&
>echo 63 > /sys/class/net/ethX/device/sriov_numvfs
>
>sleep 5
>
>echo 0 > /sys/class/net/ethX/device/sriov_numvfs&
>echo 0 > /sys/class/net/ethX/device/sriov_numvfs
>
>Results in the following bug:
>
>kernel BUG at drivers/pci/iov.c:495!
>invalid opcode: 0000 [#1] SMP
>CPU: 1 PID: 8050 Comm: bash Tainted: G   W   4.9.0-rc7-net-next #2092
>RIP: 0010:[<ffffffff813b1647>]
>	  [<ffffffff813b1647>] pci_iov_release+0x57/0x60
>
>Call Trace:
> [<ffffffff81391726>] pci_release_dev+0x26/0x70
> [<ffffffff8155be6e>] device_release+0x3e/0xb0
> [<ffffffff81365ee7>] kobject_cleanup+0x67/0x180
> [<ffffffff81365d9d>] kobject_put+0x2d/0x60
> [<ffffffff8155bc27>] put_device+0x17/0x20
> [<ffffffff8139c08a>] pci_dev_put+0x1a/0x20
> [<ffffffff8139cb6b>] pci_get_dev_by_id+0x5b/0x90
> [<ffffffff8139cca5>] pci_get_subsys+0x35/0x40
> [<ffffffff8139ccc8>] pci_get_device+0x18/0x20
> [<ffffffff8139ccfb>] pci_get_domain_bus_and_slot+0x2b/0x60
> [<ffffffff813b09e7>] pci_iov_remove_virtfn+0x57/0x180
> [<ffffffff813b0b95>] pci_disable_sriov+0x65/0x140
> [<ffffffffa00a1af7>] ixgbe_disable_sriov+0xc7/0x1d0 [ixgbe]
> [<ffffffffa00a1e9d>] ixgbe_pci_sriov_configure+0x3d/0x170 [ixgbe]
> [<ffffffff8139d28c>] sriov_numvfs_store+0xdc/0x130
>...
>RIP  [<ffffffff813b1647>] pci_iov_release+0x57/0x60
>
>Use the existing mutex lock to protect each enable/disable operation.
>
>CC: Alexander Duyck <alexander.h.duyck@intel.com>
>Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>

Emil, It's going to change semantics of pci_enable_sriov() and pci_disable_sriov().
They can be invoked when writing to the sysfs entry, or loading PF's driver. With
the change applied, the lock (pf->sriov->lock) isn't acquired and released in the
PF's driver loading path.

I think the reasonable way would be adding a flag in "struct sriov", to indicate
someone is accessing the IOV capability through sysfs file. With this, the code
returns with "-EBUSY" immediately for contenders. With it, nothing is going to
be changed in PF's driver loading path.

Also, there are some minor comments as below and I guess most of them won't be
applied if you take my suggestion eventually. However, I'm trying to make the
comments complete.

>---
> drivers/pci/pci-sysfs.c |   24 +++++++++++++++++-------
> 1 file changed, 17 insertions(+), 7 deletions(-)
>
>diff --git a/drivers/pci/pci-sysfs.c b/drivers/pci/pci-sysfs.c
>index 0666287..5b54cf5 100644
>--- a/drivers/pci/pci-sysfs.c
>+++ b/drivers/pci/pci-sysfs.c
>@@ -472,7 +472,9 @@ static ssize_t sriov_numvfs_store(struct device *dev,
> 				  const char *buf, size_t count)
> {
> 	struct pci_dev *pdev = to_pci_dev(dev);
>+	struct pci_sriov *iov = pdev->sriov;
> 	int ret;
>+

Unnecessary change.

> 	u16 num_vfs;
>
> 	ret = kstrtou16(buf, 0, &num_vfs);
>@@ -482,38 +484,46 @@ static ssize_t sriov_numvfs_store(struct device *dev,
> 	if (num_vfs > pci_sriov_get_totalvfs(pdev))
> 		return -ERANGE;
>
>+	mutex_lock(&iov->dev->sriov->lock);
>+
> 	if (num_vfs == pdev->sriov->num_VFs)
>-		return count;		/* no change */
>+		goto exit;
>
> 	/* is PF driver loaded w/callback */
> 	if (!pdev->driver || !pdev->driver->sriov_configure) {
> 		dev_info(&pdev->dev, "Driver doesn't support SRIOV configuration via sysfs\n");
>-		return -ENOSYS;
>+		ret = -EINVAL;
>+		goto exit;

Why we need change the error code here?

> 	}
>
> 	if (num_vfs == 0) {
> 		/* disable VFs */
> 		ret = pdev->driver->sriov_configure(pdev, 0);
>-		if (ret < 0)
>-			return ret;
>-		return count;
>+		goto exit;
> 	}
>
> 	/* enable VFs */
> 	if (pdev->sriov->num_VFs) {
> 		dev_warn(&pdev->dev, "%d VFs already enabled. Disable before enabling %d VFs\n",
> 			 pdev->sriov->num_VFs, num_vfs);
>-		return -EBUSY;
>+		ret = -EBUSY;
>+		goto exit;
> 	}
>
> 	ret = pdev->driver->sriov_configure(pdev, num_vfs);
> 	if (ret < 0)
>-		return ret;
>+		goto exit;
>
> 	if (ret != num_vfs)
> 		dev_warn(&pdev->dev, "%d VFs requested; only %d enabled\n",
> 			 num_vfs, ret);
>
>+exit:
>+	mutex_unlock(&iov->dev->sriov->lock);
>+
>+	if (ret < 0)
>+		return ret;
>+
> 	return count;

The code might be clearer if @ret is returned here. In that case, We need
set it properly in error paths.

> }
>

Thanks,
Gavin
