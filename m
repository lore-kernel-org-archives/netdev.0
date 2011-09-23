From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 1/8] pci: Add flag indicating device has been assigned
 by KVM
Date: Thu, 22 Sep 2011 21:16:18 -0700
Message-ID: <CAL3LdT7jDfytZD7WESmiHxvpmxKTEZ=uWRjzgsR9e4GtBPE31A@mail.gmail.com>
References: <1316599974-23205-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1316599974-23205-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	linux-pci@vger.kernel.org
To: davem@davemloft.net,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"ijc@hellion.org.uk" <ijc@hellion.org.uk>,
	Jesse Barnes <jbarnes@virtuousgeek.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1316599974-23205-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 21, 2011 at 03:12, Jeff Kirsher <jeffrey.t.kirsher@intel.co=
m> wrote:
> From: Greg Rose <gregory.v.rose@intel.com>
>
> Device drivers that create and destroy SR-IOV virtual functions via
> calls to pci_enable_sriov() and pci_disable_sriov can cause catastrop=
hic
> failures if they attempt to destroy VFs while they are assigned to
> guest virtual machines. =C2=A0By adding a flag for use by the KVM mod=
ule
> to indicate that a device is assigned a device driver can check that
> flag and avoid destroying VFs while they are assigned and avoid syste=
m
> failures.
>
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> =C2=A0include/linux/pci.h =C2=A0 =C2=A0 | =C2=A0 =C2=A02 ++
> =C2=A0virt/kvm/assigned-dev.c | =C2=A0 =C2=A02 ++
> =C2=A0virt/kvm/iommu.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A04 ++=
++
> =C2=A03 files changed, 8 insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/pci.h b/include/linux/pci.h
> index f27893b..4f511da 100644
> --- a/include/linux/pci.h
> +++ b/include/linux/pci.h
> @@ -174,6 +174,8 @@ enum pci_dev_flags {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0PCI_DEV_FLAGS_MSI_INTX_DISABLE_BUG =3D (__=
force pci_dev_flags_t) 1,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Device configuration is irrevocably los=
t if disabled into D3 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0PCI_DEV_FLAGS_NO_D3 =3D (__force pci_dev_f=
lags_t) 2,
> + =C2=A0 =C2=A0 =C2=A0 /* Provide indication device is assigned by KV=
M */
> + =C2=A0 =C2=A0 =C2=A0 PCI_DEV_FLAGS_ASSIGNED =3D (__force pci_dev_fl=
ags_t) 4,
> =C2=A0};
>
> =C2=A0enum pci_irq_reroute_variant {
> diff --git a/virt/kvm/assigned-dev.c b/virt/kvm/assigned-dev.c
> index 4e9eaeb..eaf3a50 100644
> --- a/virt/kvm/assigned-dev.c
> +++ b/virt/kvm/assigned-dev.c
> @@ -205,6 +205,8 @@ static void kvm_free_assigned_device(struct kvm *=
kvm,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0else
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_restore_st=
ate(assigned_dev->dev);
>
> + =C2=A0 =C2=A0 =C2=A0 assigned_dev->dev->dev_flags &=3D ~PCI_DEV_FLA=
GS_ASSIGNED;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_release_regions(assigned_dev->dev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_disable_device(assigned_dev->dev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_dev_put(assigned_dev->dev);
> diff --git a/virt/kvm/iommu.c b/virt/kvm/iommu.c
> index 78c80f6..967aba1 100644
> --- a/virt/kvm/iommu.c
> +++ b/virt/kvm/iommu.c
> @@ -187,6 +187,8 @@ int kvm_assign_device(struct kvm *kvm,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0goto out_unmap;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> + =C2=A0 =C2=A0 =C2=A0 pdev->dev_flags |=3D PCI_DEV_FLAGS_ASSIGNED;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0printk(KERN_DEBUG "assign device %x:%x:%x.=
%x\n",
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0assigned_dev->=
host_segnr,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0assigned_dev->=
host_busnr,
> @@ -215,6 +217,8 @@ int kvm_deassign_device(struct kvm *kvm,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0iommu_detach_device(domain, &pdev->dev);
>
> + =C2=A0 =C2=A0 =C2=A0 pdev->dev_flags &=3D ~PCI_DEV_FLAGS_ASSIGNED;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0printk(KERN_DEBUG "deassign device %x:%x:%=
x.%x\n",
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0assigned_dev->=
host_segnr,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0assigned_dev->=
host_busnr,
> --
> 1.7.6.2

Jesse/Konrad/Ian-

I sent this patch out as part of a pull request for David Miller's
net-next tree.  I know that Greg sent this originally out to the
linux-pci mailing list as a RFC. Since Greg also has a patch against
ixgbe which implemented this flag, I sent both patches for inclusion
into David Miller's net-next.

Dave is wanting to ensure that the PCI maintainers have reviewed this
and are ok with it before pulls my series of patches.

--=20
Cheers,
Jeff
