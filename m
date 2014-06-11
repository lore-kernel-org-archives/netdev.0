From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [PATCH] pci/msi: fix memory leak in free_msi_irqs()
Date: Wed, 11 Jun 2014 11:25:08 -0600
Message-ID: <20140611172508.GA14357@google.com>
References: <1401922190-25357-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>, linux-pci@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1401922190-25357-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 04, 2014 at 03:49:50PM -0700, Alexei Starovoitov wrote:
> free_msi_irqs() is leaking memory, since
> list_for_each_entry(entry, &dev->msi_list, list) {...}
> is never executed, because dev->msi_list is made empty by
> the loop just above this one.
> 
> Fix it by relying on zero termination of attribute array like
> populate_msi_sysfs() does.
> 
> Fixes: 1c51b50c2995 ("PCI/MSI: Export MSI mode using attributes, not kobjects")
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

I added Neil and Greg's acks and a stable tag and will merge this for
v3.16.  Thanks!

> ---
> 
> This was found by kmemleak report:
> unreferenced object 0xffff880808eda600 (size 64):
>   comm "modprobe", pid 1526, jiffies 4294902299 (age 58422.716s)
>   hex dump (first 32 bytes):
>     20 c4 66 09 08 88 ff ff 24 01 00 00 00 00 00 00   .f.....$.......
>     50 97 77 82 ff ff ff ff 00 00 00 00 00 00 00 00  P.w.............
>   backtrace:
>     [<ffffffff816e5fc8>] kmemleak_alloc+0x28/0x50
>     [<ffffffff811b885e>] kmem_cache_alloc_trace+0xde/0x230
>     [<ffffffff813aa286>] populate_msi_sysfs+0xc6/0x250
>     [<ffffffff813aafdb>] pci_enable_msix+0x34b/0x430
>     [<ffffffff813ab0ec>] pci_enable_msix_range+0x2c/0x70
>     [<ffffffffa0034ade>] igb_init_interrupt_scheme+0x9e/0x420 [igb]
>     [<ffffffffa003d668>] igb_probe+0x4a8/0x1250 [igb]
>     [<ffffffff813930de>] local_pci_probe+0x4e/0xa0
>     [<ffffffff813933e9>] pci_device_probe+0xd9/0x120
>     [<ffffffff814697cd>] driver_probe_device+0x8d/0x250
>     [<ffffffff81469a3b>] __driver_attach+0xab/0xb0
>     [<ffffffff8146799d>] bus_for_each_dev+0x5d/0xa0
>     [<ffffffff814691de>] driver_attach+0x1e/0x20
>     [<ffffffff81468e57>] bus_add_driver+0x117/0x220
>     [<ffffffff8146a104>] driver_register+0x64/0xf0
>     [<ffffffff813923f4>] __pci_register_driver+0x64/0x70
> 
> IGB driver is calling pci_enable_msix_range() and immediately pci_disable_msix()
> which leaks the memory.
> Obviously the leak happens with any driver.
> 
>  drivers/pci/msi.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/pci/msi.c b/drivers/pci/msi.c
> index 955ab7990c5b..fb02fc2fb034 100644
> --- a/drivers/pci/msi.c
> +++ b/drivers/pci/msi.c
> @@ -414,7 +414,7 @@ static void free_msi_irqs(struct pci_dev *dev)
>  	if (dev->msi_irq_groups) {
>  		sysfs_remove_groups(&dev->dev.kobj, dev->msi_irq_groups);
>  		msi_attrs = dev->msi_irq_groups[0]->attrs;
> -		list_for_each_entry(entry, &dev->msi_list, list) {
> +		while (msi_attrs[count]) {
>  			dev_attr = container_of(msi_attrs[count],
>  						struct device_attribute, attr);
>  			kfree(dev_attr->attr.name);
> -- 
> 1.7.9.5
> 
