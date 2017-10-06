From: Bjorn Helgaas <helgaas@kernel.org>
Subject: Re: [Intel-wired-lan] [PATCH] PCI: Check/Set ARI capability before
 setting numVFs
Date: Fri, 6 Oct 2017 13:19:22 -0500
Message-ID: <20171006181922.GF25517@bhelgaas-glaptop.roam.corp.google.com>
References: <20171004155258.35634-1-anthony.l.nguyen@intel.com>
 <20171004230114.GO25517@bhelgaas-glaptop.roam.corp.google.com>
 <CAKgT0UfL6sASMFfUbN7qkJxAMEU9BwJgMJeFmHRZsk1fhVYzZQ@mail.gmail.com>
 <20171005195959.GW25517@bhelgaas-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Netdev <netdev@vger.kernel.org>,
        Bjorn Helgaas <bhelgaas@google.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171005195959.GW25517@bhelgaas-glaptop.roam.corp.google.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 05, 2017 at 04:07:41PM -0500, Bjorn Helgaas wrote:
> On Wed, Oct 04, 2017 at 04:29:14PM -0700, Alexander Duyck wrote:
> > On Wed, Oct 4, 2017 at 4:01 PM, Bjorn Helgaas <helgaas@kernel.org> wrote:
> > > On Wed, Oct 04, 2017 at 08:52:58AM -0700, Tony Nguyen wrote:
> > >> This fixes a bug that can occur if an AER error is encountered while SRIOV
> > >> devices are present.

I applied the patch below with Alex's ack to pci/virtualization for v4.15.

> commit 95594dedd443e42ab0c16b9fba0109e955e7be13
> Author: Tony Nguyen <anthony.l.nguyen@intel.com>
> Date:   Wed Oct 4 08:52:58 2017 -0700
> 
>     PCI: Restore "ARI Capable Hierarchy" before setting numVFs
>     
>     In the restore path, we previously read PCI_SRIOV_VF_OFFSET and
>     PCI_SRIOV_VF_STRIDE before restoring PCI_SRIOV_CTRL_ARI, which
>     affects the offset and stride:
>     
>       pci_restore_state
>         pci_restore_iov_state
>           sriov_restore_state
>             pci_iov_set_numvfs
>               pci_read_config_word(... PCI_SRIOV_VF_OFFSET, &iov->offset)
>             pci_write_config_word(... PCI_SRIOV_CTRL, iov->ctrl)
>     
>     The effect is that suspend/resume and AER recovery, which use
>     pci_restore_state(), may corrupt iov->offset and iov->stride.  The iov
>     state is associated with the device, not the driver, so if we reload the
>     driver, it will use the the corrupted data, which may cause crashes like
>     this:
>     
>       kernel BUG at drivers/pci/iov.c:157!
>       RIP: 0010:pci_iov_add_virtfn+0x2eb/0x350
>       Call Trace:
>        pci_enable_sriov+0x353/0x440
>        ixgbe_pci_sriov_configure+0xd5/0x1f0 [ixgbe]
>        sriov_numvfs_store+0xf7/0x170
>        dev_attr_store+0x18/0x30
>        sysfs_kf_write+0x37/0x40
>        kernfs_fop_write+0x120/0x1b0
>        vfs_write+0xb5/0x1a0
>        SyS_write+0x55/0xc0
>     
>     The occurs since during AER recovery the ARI Capable Hierarchy bit, which
>     can affect the values for First VF Offset and VF Stride, is not set until
>     after pci_iov_set_numvfs() is called.  This can cause the iov structure to
>     be populated with values that are incorrect if the bit is later set.
>     Check and set this bit, if needed, before calling pci_iov_set_numvfs() so
>     that the values being populated properly take the ARI bit into account.
>     
>     Signed-off-by: Tony Nguyen <anthony.l.nguyen@intel.com>
>     [bhelgaas: changelog, add comment, also clear ARI if necessary]
>     Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
>     CC: Alexander Duyck <alexander.h.duyck@intel.com>
>     CC: Emil Tantilov <emil.s.tantilov@intel.com>
> 
> diff --git a/drivers/pci/iov.c b/drivers/pci/iov.c
> index ce24cf235f01..6bacb8995e96 100644
> --- a/drivers/pci/iov.c
> +++ b/drivers/pci/iov.c
> @@ -498,6 +498,14 @@ static void sriov_restore_state(struct pci_dev *dev)
>  	if (ctrl & PCI_SRIOV_CTRL_VFE)
>  		return;
>  
> +	/*
> +	 * Restore PCI_SRIOV_CTRL_ARI before pci_iov_set_numvfs() because
> +	 * it reads offset & stride, which depend on PCI_SRIOV_CTRL_ARI.
> +	 */
> +	ctrl &= ~PCI_SRIOV_CTRL_ARI;
> +	ctrl |= iov->ctrl & PCI_SRIOV_CTRL_ARI;
> +	pci_write_config_word(dev, iov->pos + PCI_SRIOV_CTRL, ctrl);
> +
>  	for (i = PCI_IOV_RESOURCES; i <= PCI_IOV_RESOURCE_END; i++)
>  		pci_update_resource(dev, i);
>  
